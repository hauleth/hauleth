---
title: "Erlang in Mix"
date: 2019-07-24T12:32:07+02:00
draft: true
---

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

Mix's `mix.exs` is completely imperative (being functional programming language
doesn't change a thing there), which mean that this is simply compiled and ran
module that exposes 1 function `config/0`. This mean that `mix.exs` can do
anything that regular Elixir script can, that include:

- Accessing your disk
- Sending data via HTTP requests
- Scanning local network
- Etc.

> With great power comes great responsibility.

In contrast to that, Rebar file is completely declarative. Accordingly to
[Wikipedia][declarative programming]:

> In computer science, declarative programming is a programming paradigm—a style
> of building the structure and elements of computer programs—that expresses the
> logic of a computation without describing its control flow.

In other words, we only describe **what** without focusing on **how**. This mean
that we have less direct control over our configuration while requiring less
knowledge to configure properly (of course except learning Erlang's
`file:consult/1` file format).

Of course there are situations when you **really** need to run some code to make
adjustments due to the OS/libraries positions/other stuff that author's of Rebar
do not thought of. Then you always can use `rebar.config.script` which is Erlang
script that need to output updated configuration.

## Tasks

[declarative programming]: https://en.wikipedia.org/wiki/Declarative_programming
