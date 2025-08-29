+++
title = "How to be good, or at least perceived as such"
date = 2023-03-07T16:03:09+01:00
draft = true

description = """
Foo
"""

[taxonomies]
tags = [
  "programming",
  "practices",
  "personal",
  "elixir"
]

[[extra.thanks]]
name = "Abdullah Alhusaini"
url = "https://github.com/a-alhusaini"
why = "inspiration to write this post"
+++

Recently I was asked over the Discord:

> You seem to be quite knowledgeable when it comes to elixir. I was wondering if
> you could give me some pointers on how to boost my own knowledge/expertise
> when it comes to programming.

And that got me thinking:

- What does it mean to be *knowledgeable*?
- How did I acquire knowledge?

And honestly, I do not really know. I have some thoughts what I could do to be
perceived as such, so maybe I will try to verbalise some of them.

## What does it mean to be *knowledgeable*?

> **knowledgeable** */ˈnɑːlɪʤəbəl/*
>
> : having information, understanding, or skill that comes from experience or
> education : having knowledge
>
> -- [Britannica Dictionary](https://www.britannica.com/dictionary/knowledgeable)

Can I be called knowledgeable about Elixir? Well, using above definition then I
think that it fits. Though I wouldn't say that about myself. I learned some
Elixir through the years, I have been called out Member of the Year few times on
<https://elixirforums.com> (I do not have time to search how many times, but a
few), I have helped few people over Slack, Discord, forum, IRC, and maybe few
other channels.

The thing is that while I have some knowledge about Elixir and Erlang inner
workings on high level, I often did not dig a lot into the underlying
implementation (ok, with exception to Erlang's `socket` NIF).

But my knowledge is still limited, I still have a lot to learn, and I make
mistakes, confuse things, and in general show lack of knowledge from time to
time. I may have knowledge of some Elixir and Erlang, but I will probably not
**know** Elixir, Erlang, or just any other piece of technology, and neither will
you. In the end we are human beings and knowing everything is way beyond our
capabilities.

From there we can define my first step to gathering knowledge. You need to
understand **and accept** that there is, and always be, stuff that you do not
know.

## How did I acquire knowledge?

This is way harder to describe, as I cannot just go to Britannica or other
dictionary/encyclopedia and copy paste definition here. That would be nice if
that would be possible, but unfortunately for our world, that is not how it is
working.

### Documentation

The main source of my understanding of Elixir and Erlang (and few other
technologies to be honest) is, well, reading documentation. There are few
technologies that have documentation so stellar that for me it is almost single
source of knowledge. These technologies are:

- Elixir
- Erlang
- (Neo)Vim
- PostgreSQL

Unfortunately, while Rust documentation is **very** good, I find it quite hard
to search and fully read from time to time. It also lacks another thing that is
one of my main sources of knowledge - integration with [Dash] (for
<https://docs.rs>, as "core Rust docs" are available).

I cannot express how much of the reason why I am perceived as an *expert* come
from the fact that I am just super fast at searching the documentation. And I
can search documentation at light speed mostly thanks to Dash (for non-macOS
users there is [Zeal] but I find it less feature complete and bit more crude).
That and then you are just <kbd>⌥ ⌘ B</kbd> and <kbd>⌘ P</kbd> away from being
perceived as a person that has immense knowledge of almost any technology.

On slightly more serious tone (though the above is 100% true) it will also make
you better without invoking documentation search over and over again. Why?
Because remembering stuff often comes with repeating the same thing over and
over again. When you regularly read the same piece of text, then after a while
you will know that by heart. I am 100% sure that it works, because I am also a
father of 2.5 years old boy, and I already know some of his books by heart due
to repetitive strain on my brain from reading it over and over again. And when
you work with documentation over and over again, by reading and searching in it
for the same phrases over and over again, then after some time you will not only
learn about existence of some functions (even obscure ones). This will also give
you some insights into the documentation author mind, which will allow you to be
better at searching such documentation in the future.

Documentation is also not just the list of all functions with description what
they do. Documentation often will contain additional information that will help
you with learning.

[Dash]: https://kapeli.com/dash
[Zeal]: https://zealdocs.org
