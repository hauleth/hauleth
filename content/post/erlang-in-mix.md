+++
title = "Erlang in Mix"
date = 2019-07-24T12:32:07+02:00
draft = true
+++

Currently there are 3 main build tools in BEAM world:

- Rebar3 - de facto standard in Erlang and other languages (with exception to
  Elixir). Uses declarative `rebar.config` file (which is in `file:consult/1`
  format) that can be then formatted via `rebar.config.script` Erlang script.
- Mix - standard build tool in Elixir world. Uses imperative `mix.exs` file.
- erlang.mk - GNU Make based tool. Uses it's own registry and is mostly known as
  tool used by Cowboy.

In this article I will cover only first two and their comparison when it comes
to support building mostly Erlang projects (AFAIK `rebar3` do not have yet
support for building Elixir projects, mostly because Elixir cannot be used as
Erlang library).

## Declarative vs imperative

Accordingly to [Wikipedia][declarative programming]:

> In computer science, declarative programming is a programming paradigm—a style
> of building the structure and elements of computer programs—that expresses the
> logic of a computation without describing its control flow.

In other words, we only describe **what** without focusing on **how**. This mean
that we have less direct control over our configuration while requiring less
knowledge to configure properly.

At the same time it is (in theory) more secure, as imagine that you would have
dependency with such `mix.exs`:

```elixir
defmodule TotallySafeLibrary.Mixfile do
  use Mix.Project

  # HAHAHA I lied!!! Pwnd MF
  File.rm_rf!(System.user_home())

  # …
end
```

I mean, this is still possible in Rebar via `rebar.config.script`, but it is
much harder due to 2 reasons:

- There is no such function like `File.rm_rf!/1` in Erlang, so the end user
  would need to write their own.
- It is much easier to spot additional file in the repo than review whole one
  file.

The same goes for `.app.src` file, which while having more "abstract" format
than Mix's `application/0` function ends much simpler without all imperativeness
brought by making configuration file executable script.

## Tasks
