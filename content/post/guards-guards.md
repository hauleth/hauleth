+++
date = 2026-06-27
title = "Guards! Guards!"
description = """
Small gotcha about boolean operators in Elixir.
"""

[taxonomies]
tags = [
    "beam"
]
+++

Let's start with simple quiz.

---

Given module defined as:

```elixir
defmodule Foo do
  def a(x) when is_integer(x) or is_map_key(x, :foo), do: true
  def a(x), do: false

  def b(x) when is_map_key(x, :foo) or is_integer(x), do: true
  def b(x), do: false
end
```

Try to answer these questions.

{% question(
    name="a-map",
    desc="What will be result of `Foo.a(%{foo: 21})`?",
    options = ["`true`", "`false`"],
    correct = 0
) %}
This one is straightforward.

We check guard, it has one condition `is_integer(x) or is_map_key(x, :foo)`.
First one returns `false`, second returns `true`, Boolean's alternative results
in `true` and first case is matched.
{% end %}

{% question(
    name="a-int",
    desc="What will be result of `Foo.a(37)`?",
    options = ["`true`", "`false`"],
    correct = 0
) %}
This one is straightforward as well.

We check guard, it has one condition `is_integer(x) or is_map_key(x, :foo)`.
First one returns `true`, second one isn't fired at all, because `or` operator
is short circuiting.
{% end %}

{% question(
    name="b-map",
    desc="What will be result of `Foo.b(%{foo: 21})`?",
    options = ["`true`", "`false`"],
    correct = 0
) %}
Again, similar to the previous questions.

We check guard, it has one condition `is_map_key(x, :foo) or is_integer(x)`.
First one returns `true` and the rest is short circuited.
{% end %}

{% question(
    name = "b-int",
    desc = "What will be result of `Foo.b(37)`?",
    options = ["`true`", "`false`"],
    correct = 1
) %}
Ouch, something changed…

Again, we check guard, one condition `is_map_key(x, :foo) or is_integer(x)`. We
hit first clause `is_map_key(x, :foo)` and this **doesn't** return `false`,
instead it fail. Failure in one of guard functions isn't converted to `false`
but instead makes whole guard expression fail. This mean that `is_integer(x)`
part will **never** be called.
{% end %}

---

This behaviour is often surprising for a lot of Elixir developers, as it
seemingly breaks commutative property of boolean operators. However, to be
honest, these never were commutative because of short circuiting.

It seems that Elixir at the time of writing (Elixir 1.20.1, OTP 29) do not warn
about this issue.
