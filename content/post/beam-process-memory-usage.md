+++
date = 2023-06-10
title = "How much memory is needed to run 1M Erlang processes?"
description = "How to not write benchmarks"

[taxonomies]
tags = [
  "beam",
  "elixir",
  "erlang",
  "benchmarks",
  "programming"
]
+++

Recently [benchmark for concurrency implementation in different
languages][benchmark]. In this article [Piotr Kołaczkowski][] used Chat GPT to
generate the examples in the different languages and benchmarked them. This was
poor choice as I have found this article and read the Elixir example:

[benchmark]: https://pkolaczk.github.io/memory-consumption-of-async/ "How Much Memory Do You Need to Run 1 Million Concurrent Tasks?"
[Piotr Kołaczkowski]: https://github.com/pkolaczk

```elixir
tasks =
    for _ <- 1..num_tasks do
        Task.async(fn ->
            :timer.sleep(10000)
        end)
    end

Task.await_many(tasks, :infinity)
```

And, well, it's pretty poor example of BEAM's process memory usage, and I am
not talking about the fact that it uses 4 spaces for indentation.

For 1 million processes this code reported 3.94 GiB of memory used by the process
in Piotr's benchmark, but with little work I managed to reduce it about 4 times
to around 0.93 GiB of RAM usage. In this article I will describe:

- how I did that
- why the original code was consuming so much memory
- why in the real world you probably should not optimise like I did here
- why using ChatGPT to write benchmarking code sucks (TL;DR because that will
  nerd snipe people like me)

## What are Erlang processes?

Erlang is ~~well~~ known of being language which support for concurrency is
superb, and Erlang processes are the main reason for that. But what are these?

In Erlang *process* is the common name for what other languages call *virtual
threads* or *green threads*, but in Erlang these have small neat twist - each of
the process is isolated from the rest and these processes can communicate only
via message passing. That gives Erlang processes 2 features that are rarely
spotted in other implementations:

- Failure isolation - bug, unhandled case, or other issue in single process will
  not directly affect any other process in the system. VM can send some messages
  due to process shutdown, and other processes may be killed because of that,
  but by itself shutting down single process will not cause problems in any
  process not related to that.
- Location transparency - process can be spawned locally or on different
  machine, but from the viewpoint of the programmer, there is no difference.

The above features and requirements results in some design choices, but for our
purpose only one is truly needed today - each process have separate and (almost)
independent memory stack from any other process.

### Process dictionary

Each process in Erlang VM has dedicated *mutable* memory space for their
internal uses. Most people do not use it for anything because in general it
should not be used unless you know exactly what you are doing (in my case, a bad
carpenter could count cases when I needed it, on single hand). In general it's
*here be dragons* area.

How it's relevant to us?

Well, OTP internally uses process dictionary (`pdict` for short) to store
metadata about given process that can be later used for debugging purposes. Some
data that it store are:

- Initial function that was run by the given process
- PIDs to all ancestors of the given process

Different processes abstractions (like `get_server`/`GenServer`, Elixir's
`Task`, etc.) can store even more metadata there, `logger` store process
metadata in process dictionary, `rand` store state of the PRNGs in the process
dictionary. it's used quite extensively by some OTP features.

### "Well behaved" OTP process

In addition to the above metadata if the process is meant to be "well behaved"
process in OTP system, i.e. process that can be observed and debugged using OTP
facilities, it must respond to some additional messages defined by [`sys`][]
module. Without that the features like [`observer`][] would not be able to "see"
the content of the process state.

[`sys`]: https://erlang.org/doc/man/sys.html
[`observer`]: https://erlang.org/doc/man/observer.html

## Process memory usage

As we have seen above, the `Task.async/1` function form Elixir **must** do
much more than just simple "start process and live with it". That was one of the
most important problems with the original process, it was using system, that was
allocating quite substantial memory alongside of the process itself, just to
operate this process. In general, that would be desirable approach (as you
**really, really, want the debugging facilities**), but in synthetic benchmarks,
it reduce the feasibility of such benchmark.

If we want to avoid that additional memory overhead in our spawned processes we
need to go back to more primitive functions in Erlang, namely `erlang:spawn/1`
(`Kernel.spawn/1` in Elixir). But that mean that we cannot use
`Task.await_many/2` anymore, so we need to workaround it by using custom
function:

```elixir
defmodule Bench do
  def await(pid) when is_pid(pid) do
    # Monitor is internal feature of Erlang that will inform you (by sending
    # message) when process you monitor die. The returned value is type called
    # "reference" which is just simply unique value returned by the VM.
    # If the process is already dead, then message will be delivered
    # immediately.
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, :process, _, _} -> :ok
    end
  end

  def await_many(pids) do
    Enum.each(pids, &await/1)
  end
end

tasks =
  for _ <- 1..num_tasks do
    # `Kernel` module is imported by default, so no need for `Kernel.` prefix
    spawn(fn ->
      :timer.sleep(10000)
    end)
  end

Bench.await_many(tasks)
```

We already removed one problem (well, two in fact, but we will go into
details in next section).

## All your lists belongs to us now

Erlang, like most of the functional programming languages, have 2 built-in
sequence types:

- Tuples - which are non-growable product type of the values, so you can access
  any field quite fast, but adding more values is performance no-no
- (Singly) linked lists - growable type (in most case it will have single type
  values in it, but in Erlang that is not always the case), which is fast to
  prepend or pop data from the beginning, but do not try to do anything else if
  you care about performance.

In this case we will focus on the 2nd one, as there tuples aren't important at
all.

Singly linked list is simple data structure. It's either special value `[]`
(an empty list) or it's something called "cons-cell". Cons-cells are also
simple structures - it's 2ary tuple (tuple with 2 elements) where first value
is head - the value in the list cell, and another one is the "tail" of the list (aka
rest of the list). In Elixir the cons-cell is denoted like that `[head | tail]`.
Super simple structure as you can see, and perfect for the functional
programming as you can add new values to the list without modifying existing
values, so you can be immutable and fast. However if you need to construct the
sequence of a lot of values (like our list of all tasks) then we have problem.
Because Elixir promises that list returned from the `for` will be **in-order**
of the values passed to it. That mean that we either need to process our data
like that:

```elixir
def map([], _), do: []

def map([head | tail], func) do
  [func.(head) | map(tail, func)]
end
```

Where we build call stack (as we cannot have tail call optimisation there, of
course sans compiler optimisations). Or we need to build our list in reverse
order, and then reverse it before returning (so we can have TCO):

```elixir
def map(list, func), do: do_map(list, func, [])

def map([], _func, agg), do: :lists.reverse(agg)

def map([head | tail], func, agg) do
  map(tail, func, [func.(head) | agg])
end
```

Which one of these approaches is more performant is irrelevant[^erlang-perf],
what is relevant is that we need either build call stack or construct our list
*twice* to be able to conform to the Elixir promises (even if in this case we do
not care about order of the list returned by the `for`).

[^erlang-perf]: Sometimes body recursion will be faster, sometimes TCO will be
faster. it's impossible to tell without more benchmarking. For more info check
out [superb article by Ferd Herbert](https://ferd.ca/erlang-s-tail-recursion-is-not-a-silver-bullet.html).

Of course we could mitigate our problem by using `Enum.reduce/3` function (or
writing it on our own) and end with code like:

```elixir
defmodule Bench do
  def await(pid) when is_pid(pid) do
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, :process, _, _} -> :ok
    end
  end

  def await_many(pids) do
    Enum.each(pids, &await/1)
  end
end

tasks =
  Enum.reduce(1..num_tasks, [], fn _, agg ->
    # `Kernel` module is imported by default, so no need for `Kernel.` prefix
    pid =
      spawn(fn -> :timer.sleep(10000) end)

    [pid | agg]
  end)

Bench.await_many(tasks)
```

Even then we build list of all PIDs.

Here I can also go back to the "second problem* I have mentioned above.
`Task.await_many/1` *also construct a list*. it's list of return value from all
the processes in the list, so not only we constructed list for the tasks' PIDs,
we also constructed list of return values (which will be `:ok` for all processes
as it's what `:timer.sleep/1` returns), and immediately discarded all of that.

How we can better? See that **all** we care is that all `num_task` processes
have gone down. We do not care about any of the return values, all what we want
is to know that all processes that we started went down. For that we can just
send messages from the spawned processes and count the received messages count:

```elixir
defmodule Bench do
  def worker(parent) do
    :timer.sleep(10000)
    send(parent, :done)
  end

  def start(0), do: :ok
  def start(n) when n > 0 do
    this = self()
    spawn(fn -> worker(this) end)

    start(n - 1)
  end

  def await(0), do: :ok
  def await(n) when n > 0 do
    receive do
      :done -> await(n - 1)
    end
  end
end

Bench.start(num_tasks)
Bench.await(num_tasks)
```

Now we do not have any lists involved and we still do what the original task
meant to do - spawn `num_tasks` processes and wait till all go down.

## Arguments copying

One another thing that we can account there - lambda context and data passing
between processes.

You see, we need to pass `this` (which is PID of the parent) to our newly
spawned process. That is suboptimal, as we are looking for the way to reduce
amount of the memory (and ignore all other metrics at the same time). As Erlang
processes are meant to be "share nothing" type of processes there is problem -
we need to copy that PID to all processes. it's just 1 word (which mean 8 bytes
on 64-bit architectures, 4 bytes on 32-bit), but hey, we are microbenchmarking,
so we cut whatever we can (with 1M processes, this adds up to 8 MiBs).

Hey, we can avoid that by using yet another feature of Erlang, called
*registry*. This is yet another simple feature that allows us to assign PID of
the process to the atom, which allows us then to send messages to that process
using just name, we have given. While atoms are also 1 word that wouldn't make
sense to send it as well, but instead we can do what any reasonable
microbenchmarker would do - *hardcode stuff*:

```elixir
defmodule Bench do
  def worker do
    :timer.sleep(10000)
    send(:parent, :done)
  end

  def start(0), do: :ok
  def start(n) when n > 0 do
    spawn(fn -> worker() end)

    start(n - 1)
  end

  def await(0), do: :ok
  def await(n) when n > 0 do
    receive do
      :done -> await(n - 1)
    end
  end
end

Process.register(self(), :parent)

Bench.start(num_tasks)
Bench.await(num_tasks)
```

Now we do not pass any arguments, and instead rely on the registry to dispatch
our messages to respective processes.

## One more thing

As you may have already noticed we are passing lambda to the `spawn/1`. That is
also quite suboptimal, because of [difference between remote and local call][remote-vs-local].
This mean that we are paying slight memory cost for these processes to keep the
old module in memory. Instead we can use either fully qualified function capture
or `spawn/3` function that accepts MFA (module, function name, arguments list)
argument. We end with:

[remote-vs-local]: https://www.erlang.org/doc/reference_manual/code_loading.html#code-replacement

```elixir
defmodule Bench do
  def worker do
    :timer.sleep(10000)
    send(:parent, :done)
  end

  def start(0), do: :ok
  def start(n) when n > 0 do
    spawn(&__MODULE__.worker/0)

    start(n - 1)
  end

  def await(0), do: :ok
  def await(n) when n > 0 do
    receive do
      :done -> await(n - 1)
    end
  end
end

Process.register(self(), :parent)

Bench.start(num_tasks)
Bench.await(num_tasks)
```

## Results

With given Erlang compilation:

```txt
Erlang/OTP 25 [erts-13.2.2.1] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1]

Elixir 1.14.5 (compiled with Erlang/OTP 25)
```

> Note no JIT as Nix on macOS currently[^currently] disable it and I didn't bother to enable
> it in the derivation (it was disabled because there were some issues, but IIRC
> these are resolved now).

[^currently]: Nixpkgs rev `bc3ec5ea`

The results are as follow (in bytes of peak memory footprint returned by
`/usr/bin/time` on macOS):

| Implementation |       1k |      100k |         1M |
| -------------- | -------: | --------: | ---------: |
| Original       | 45047808 | 452837376 | 4227715072 |
| Spawn          | 43728896 | 318230528 | 2869723136 |
| Reduce         | 43552768 | 314798080 | 2849304576 |
| Count          | 43732992 | 313507840 | 2780540928 |
| Registry       | 44453888 | 311988224 | 2787237888 |
| RemoteCall     | 43597824 | 310595584 | 2771525632 |

As we can see we have reduced the memory use by about 30% by just changing
from `Task.async/1` to `spawn/1`. Further optimisations reduced memory usage
slightly, but with no such drastic changes.

Can we do better?

Well, with some VM flags tinkering - of course.

You see, by default Erlang VM will not only create some data required for
handling process itself[^word]:

[^word]: Again, word here mean 8 bytes on 64-bit and 4 bytes on 32-bit architectures.

> | Data Type | Memory Size |
> | - | - |
> | … | … |
> | Erlang process | 338 words when spawned, including a heap of 233 words. |
>
> -- [Erlang Efficiency Guide: 11. Advanced](https://erlang.org/doc/efficiency_guide/advanced.html#Advanced)

As we can see, there are 105 words that are required and 233 words which are
used for preallocated heap. But this is microbenchmarking, so as we do not need
that much of memory (because our processes basically does nothing), we can
reduce it. We do not care about time performance anyway. For that we can use
`+hms` flag and set it to some small value, for example `1`.

In addition to heap size Erlang by default load some additional data from the
BEAM files. That data is used for debugging and error reporting, but again, we
are microbenchmarking, and who need debugging support anyway (answer: everyone,
so **do not** do it in production). Luckily for us, the VM has yet another flag
for that purpose `+L`.

Erlang also uses some [ETS][] (Erlang Term Storage) tables by default (for
example to support process registry we have mentioned above). ETS tables can be
compressed, but by default it's not done, as it can slow down some kinds of
operations on such tables. Fortunately there is, another, flag `+ec` that has
description:

> Forces option compressed on all ETS tables. Only intended for test and
> evaluation.

[ETS]: https://erlang.org/doc/man/ets.html

Sounds good enough for me.

With all these flags enabled we get peak memory footprint at 996257792 bytes.

Compare it in more human readable units.

|                          | Peak Memory Footprint for 1M processes |
| ------------------------ | -------------------------------------- |
| Original code            | 3.94 GiB                               |
| Improved code            | 2.58 GiB                               |
| Improved code with flags | 0.93 GiB                               |

Result - about 76% of the peak memory usage reduction. Not bad.

## Summary

First of all:

> Please, do not use ChatGPT for writing code for microbenchmarks.

The thing about *micro*benchmarking is that we write code that does as little as
possible to show (mostly) meaningless features of the given technology in
abstract environment. ChatGPT cannot do that, not out of malice or incompetence,
but because it used (mostly) *good* and idiomatic code to teach itself,
microbenchmarks rarely are something that people will consider to have these
qualities. It also cannot consider other features that [wetware][] can take into
account (like our "we do not need lists there" thing).

[wetware]: https://en.wikipedia.org/wiki/Wetware_(brain)
