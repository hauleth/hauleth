+++
title = "Log all the things"
date = 2021-10-13

[taxonomies]
tags = [
  "elixir",
  "programming",
  "observability"
]

[[extra.thanks]]
name = "Kai Wern Choong"
+++

In Elixir 1.11 landed set of new features that allows for more powerful logging
by utilising Erlang's [`logger`][erl-log] features. Here I will try to describe
new possibilities and how You can use them to improve your logs.

<!-- more -->

## New log levels {#levels}

Elixir gained 4 new log levels to total 8 (from most verbose to least verbose):

- debug
- info
- **notice** *
- warning (renamed from warn)
- error
- **critical** *
- **alert** *
- **emergency** *

<small>* new levels</small>

This allow to provide finer graded verbosity control, due to compatibility
reasons, in Elixir backends we need to translate these levels back to "old" set
of 4. The current table looks like:

| Call level            | What Elixir backend will see |
| --                    | --                           |
| `debug`               | `debug`                      |
| `info`                | `info`                       |
| `notice`              | **`info`** *                 |
| `warning` (or `warn`) | `warn`                       |
| `error`               | `error`                      |
| `critical`            | **`error`** *                |
| `alert`               | **`error`** *                |
| `emergency`           | **`error`** *                |

<small>* "translated" messages</small>

We can set verbosity to all levels. This may be confusing during the transition
period, but we cannot change the behaviour until Elixir 2 (which is not
happening any time soon).

Usage of the new levels is "obvious":

```elixir
Logger.notice("Hello")
```

Will produce message with `notice` level of verbosity.

Additionally the `logger.level` option in configuration supports 2 additional
verbosity levels that you can use in your config:

- `:all` - all messages will be logged, logically exactly the same as `:debug`
- `:none` - no messages will be logged

## Per module log level {#per-module-level}

This is change that can be quite handy during debugging sessions. With this
change we have 4 new functions in `Logger` module:

- [`get_module_level/1`](https://hexdocs.pm/logger/Logger.html#get_module_level/1)
- [`put_module_level/2`](https://hexdocs.pm/logger/Logger.html#put_module_level/2)
- [`delete_module_level/1`](https://hexdocs.pm/logger/Logger.html#delete_module_level/1)
- [`delete_all_module_level/0`](https://hexdocs.pm/logger/Logger.html#delete_all_module_level/0)

These allow us to manipulate verbosity level on per-module basis. What is
non-obvious and is super handy is that it allows both lowering **and raising**
verbosity for given module. This mean that:

```elixir
require Logger

Logger.configure(level: :error)

defmodule Foo do
  def run do
    Logger.debug("I am still there")
  end
end

Foo.run() # Does not log anything

# Set `debug` level for `Foo` module only
Logger.put_module_level(Foo, :debug)
Foo.run()
# `I am still there` is logged
Logger.debug("I will not be printed")
# Nothing got logged as top-level verbositi is still set to `:error`
```

Of course it will not work if you decide to use [compile time purging][logger-purge]

## Logger handlers {#handlers}

---

**Warning!** This is not fully implemented in both - Erlang and Elixir. Writing
your own handlers without additional knowledge can cause overload problems.

---

Erlang together with their logging implementation needed to provide a way to
ingest these logs somehow. This is done via Erlang logger handlers (in this
article called *handlers* in contrast to Elixir backends called *backends*
there).

Handlers are modules that export at least 1 function `log/2` that takes 2
arguments:

- `log_event` which is a map with 3 fields:
  - `:level` - verbosity level
  - `:msg` - tuple describing message:
    - `{:io.format(), [term()]}` - format string and list of terms that should
      be passed to `:io_lib.format/2` function
    - `{:report, map() | keyword()}` - report that can be formatted into string
      by `report_cb/{1,2}` set in metadata map (see below)
    - `{:string, :unicode.chardata()}` - raw string that should be printed as
      a message
  - `:meta` - map containing all metadata for given event. All keys should be
    atoms and values can be anything. Some keys have special meaning, and some
    of them will be populated automatically by the `Logger` macros and functions.
    These are:
    - `:pid` - PID of the process that fired log event
    - `:gl` - group leader of the process that fired log event
    - `:mfa` - tuple in form of `{module(), name :: atom(), arity :: non_neg_integer()}`
      that describe function that fired log event
    - `:file` - filename of file that defines the code that fired log event
    - `:line` - line in the given file where the log event was fired
    - `:domain` - list of atoms that can be used to describe log events
      hierarchy which then can be used for filtering. All events fired using
      `Logger` macros and functions will have `:elixir` prepended to their
      domain list.
    - `:report_cb` - function that will be used to format `{:report, map() |
      keyword()}` messages. This can be either 1-ary function, that takes report
      and returns `{:io.format(), [term()]}` leaving truncation and further
      formatting up to the main formatter, or 2-ary function that takes report
      and configuration map `%{depth: pos_integer() | :unlimited, chars_limit:
      pos_integer() | :unlimited, single_line: boolean()}` and returns already
      formatted `:unicode.chardata()`. More about it can be found in [separate
      section](#structured-logging).

Return value of this function is ignored. If there will be any exception raised
when calling this function, then it will be captured and failing handler will be
removed. This is important, as if such handler is the only one, then you can be
left without any logging handler and miss logs.

The important thing about Erlang handlers and Elixir backends is that Erlang
handlers functions are called **within caller process** while Elixir backends
are called in separate process. This mean that wrongly written Erlang handler
can cause quite substantial load on application.

To read on other, optional, callbacks that can be defined by Erlang handler, that
will not be covered there, I suggest looking into [Erlang documentation][formatter_cb].

## Structured logging {#structured-logging}

One of the biggest new features in the Elixir 1.11 is support for structured
logging. This mean that the log message do not need to be free-form string, but
instead we can pass structure, that can provide more machine-readable data for
processing in log aggregators. In Elixir 1.11 is simple as passing map as a
first argument to the `Logger` macros:

```elixir
Logger.info(%{
  status: :completed,
  response: :ok
})
```

This will produce message that looks like:

```log
14:08:46.849 [info]  [response: :ok, status: :completed]
```

As we can see, the map (called *report*) is formatted as a keyword list. This is
default way to present the report data. Unfortunately we cannot access the
metadata from the Elixir backends, but we have 2 ways to make these messages
more readable for the human operator:

1. Utilise [`Logger`'s translators](https://hexdocs.pm/logger/Logger.Translator.html)
1. Using `:report_cb` field in metadata

1st option is described quite good in Elixir documentation and is available
since Elixir 1.0 as it was used to translate `error_logger` messages in old
Erlang versions. Here I will describe the 2nd option which provide way for
**caller** to define how report should be formatted into human-readable string.

`:report_cb` accepts 2 kind of functions as an argument:

- 1-ary function, that takes report as an argument and should return tuple
  in form of `{:io.format(), [term()]}` that will be later formatted
  respectively by the formatters.
- 2-ary function that takes report and configuration map as an arguments and
  should return formatted string.

1st option is much easier for most use cases, as it do not force you to worry
about handling width, depth, and multiline logs, as it will all be handled for
you.

For example, instead of doing:

```elixir
Logger.info("Started HTTP server on http://localhost:8080")
```

We can do:

```elixir
Logger.info(
  %{
    protocol: :http,
    port: 8080,
    address: "localhost",
    endpoint: MyEndpoint,
    handler: Plug.Cowboy
  },
  report_cb: &__MODULE__.report_cb/1
)

# …

def report_cb(%{protocol: protocol, port: port, address: address}) do
  {"Started ~s server on ~s://~s:~B", [protocol, protocol, address, port]}
end
```

While the second entry seems much more verbose, with proper handler, it can
provide much more detailed output. Just imagine that we would have handler that
output JSON data and what information we could contain in such message:

```json
{
  "msg": "Started HTTP server on http://localhost:8080",
  "metadata": {
    "mfa": "MyMod.start/2",
    "file": "foo.ex",
    "line": 42
  }
}
```

Now our log aggregation service need to parse `msg` field to extract all
information that is contained there, like port, address, and protocol. With
structured logging we can have that message available already there while
presenting the "human readable" form as well:

```json
{
  "text": "Started HTTP server on http://localhost:8080",
  "msg": {
    "address": "localhost",
    "port": 8080,
    "protocol": "http",
    "endpoint": "MyEndpoint",
    "handler": "Plug.Cowboy"
  },
  "metadata": {
    "mfa": "MyMod.start/2",
    "file": "foo.ex",
    "line": 42
  }
}
```

You can see there that we can have more information available in the structured
log that would otherwise needed to be crammed somewhere into the text message,
even if it is not important in "regular" Ops observability.

This can raise a question - why not use metadata for such functionality, like it
is available in [`LoggerJSON`][] or [`Ink`][]? The reason is that their reason
existence is different. Metadata meant for "meta" stuff like location, tracing
ID, but not for the information about the message itself. It is best shown on
example. For this use Elixir's implementation of `GenServer` wrapper that
produces error log entry on unknown message handled by default `handle_info/2`:

```elixir
Logger.error(
  # Report
  %{
    label: {GenServer, :no_handle_info},
    report: %{
      module: __MODULE__,
      message: msg,
      name: proc
    }
  },
  # Metadata
  %{
    error_logger: %{tag: :error_msg},
    report_cb: &GenServer.format_report/1
  }
)
```

As we can see there, the report contains informations like:

- `:label` - that describes type of the event
- `:report` - content of the "main" event
  - `:module` - module that created the event, it is important to notice, that
    it is also present in metadata (as part of `:mfa` key), but their meaning is
    different. Module name here is meant for the operator to know the name of
    the implementor that failed to handle message, while `:mfa` is meant to
    describe the location of the code that fired the event.
  - `:message` - the message itself that hasn't been handled. Notice, that it is
    not stringified in any way there, it is simply passed "as is" to the
    report. It is meant to be stringified later by the `:report_cb` function.
  - `:name` - name of the process. Remember, similarly to `:module`, the PID of
    the current process is part of the metadata, so in theory we could use value
    from there, but their meaning is different (additionally this one may be an
    atom in case if the process is locally registered with name).

Metadata on the other hand contains information that will be useful for
filtering or formatting of the event.

The rule of thumb you can follow is:

> If it is thing that you will want to filter on, then it probably should be
> part of the metadata. If you want to aggregate information or just display
> them, it should be part of the message report.

## Log filtering

Finally we come to first feature that is not directly accessible from the Elixir
`Logger` API (yet). Erlang's `logger` have powerful functionality for filtering
log messages which allows us to dynamically decide which message should, or
should not be logged. These even can alter messages on the fly.

Currently that functionality is available only via `:logger` module. It can be
used like:

```elixir
defmodule MyFilter do
  def filter(log_event, opts) do
    # …
  end
end

:logger.add_primary_filter(:my_filter, {&MyFilter.filter/2, opts})
# Or
:logger.add_handler_filter(handler_id, :my_filter, {&MyFilter.filter/2, opts})
```

Few important things that need to be remembered when writing such filters:

- It is best practice to make such functions public and define filters using
  remote function capture, like `&__MODULE__.process_disabled/2` (so not
  anonymous functions either). It will make such filter much easier for VM to
  handle (it is bigger topic why it is that, I may to cover it in another post).
- Filters are ran **within the same process that fired log event**, so it is
  important to make such filters as fast as possible, and do not do any heavy
  work there.

Filters can be used for 2 different things:

- preventing some messages from being logged
- modifying a message

While the former is much more common, I will try to describe both use cases
there, as the latter is also quite useful.

Filters are defined as 2-ary functions where 1st argument is log event, and
second argument is any term that can be used as a configuration for filter.
Filter should return one of these 3 values:

- `:stop` - which will immediately discard message and do not run any additional
  filters.
- `:ignore` - which mean that given filter didn't recognise the given message
  and leaves it up to other filters to decide on the action. If all filters
  return `:ignore` then `:filter_default` option for the handler will be taken.
  By default it is `:log`, which mean that message will be logged, but default
  handler has it set to `:stop` by default, which mean, that non-matching
  messages will be discarded.
- Just log event (possibly modified) that will cause next filter to be called
  with altered message. The message returned by the last filter (or in case of
  `:ignore` return, previous filters) will be the message passed to handler.

### Preventing some messages from being logged

Most common use-case for filters will probably be rejecting messages that aren't
important for us. [Erlang even prepared some useful filters][logger_filters]:

- `domain` - allow filtering by metadata `:domain` field (remember as I said
  that metadata is for filtering?). It supports multiple possible relations
  between the log domain and defined domain.
- `level` - allow filtering (in or out) messages depending on their level, in
  both directions. It will allow you to filter messages with higher level for
  some handlers. Just remember, that it will not receive messages that will not
  pass primary/module level.
- `progress` - filters all reports from `supervisor` and
  `application_controller`. Simply, reduces startup/process shutdown chatter
  that often is meaningless for most time.
- `remote_gl` - filters messages coming from group leader on another node.
  Useful when you want to discard/log messages coming from other nodes in
  cluster.

### Modifying a message

Sometimes there is need to alter messages in the system. For example we may need
to prevent sensitive information from being logged. When using "old" Elixir
approach you could abuse translators, but that was error prone, as first
successful translator was breaking pipeline, so you couldn't just smash one on
top and then keep rest working as is. With "new" approach and structured logging
you can just traverse the report and replace all occurrences of the unsafe data
with anonymised data. For example:

```elixir
def filter_out_password(%{msg: {:report, report}} = event, _opts) do
  %{event | msg: {:report, replace(report)}}
end

@filtered "[FILTERED]"

defp replace(%{password: _} = map) do
  for {k, v} <- %{map | password: @filtered}, into: %{} do
    {k, replace(v)}
  end
end

defp replace(%{"password" => _} = map) do
  for {k, v} <- %{map | "password" => @filtered}, into: %{} do
    {k, replace(v)}
  end
end

defp replace(list) when is_list(list) do
  for elem <- list do
    case elem do
      {:password, _} -> {:password, @filtered}
      {"password", _} -> {"password", @filtered}
      {k, v} -> {k, replace(v)}
      other -> replace(other)
    end
  end
end

defp replace(other), do: other
```

This snippet will replace all occurrences of `:password` or `"password"` with
filtered out value.

The disadvantage of such approach - it will make all messages with such fields
allowed in case if your filter has `:filter_default` set to `:stop`. That mean,
that if you want to make some of them rejected anyway, then you will need to
manually add additional step to reject messages that do not fit into your
patterns. Alternatively you can use `filter_default: :log` and then use opt-out
logging. There currently is no way to alter the message and make other filters
decide whether log it or not (as of OTP 24).

## Summary

New features and possibilities with relation to logging in Elixir 1.11 can be
overwhelming. Fortunately all of the new features are optional and provided in
addition to "good 'ol `Logger.info("logging")`". But for the people who works on
the observability in BEAM (EEF Observability WG, Sentry, Logflare, etc.) it
brings a lot of new powerful capabilities.

I am thrilled to see what will people create using all that power.

[erl-log]: https://erlang.org/doc/man/logger.html
[syslog]: https://en.wikipedia.org/wiki/Syslog#Severity_level
[`LoggerJSON`]: https://github.com/Nebo15/logger_json
[`Ink`]: https://hex.pm/packages/ink
[logger_filters]: https://erlang.org/doc/man/logger_filters.html
[logger-purge]: https://hexdocs.pm/logger/Logger.html#module-application-configuration
[formatter_cb]: https://erlang.org/doc/man/logger.html#formatter-callback-functions
