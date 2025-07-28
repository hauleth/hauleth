+++
title = "Jeopardy! world"
date = 2025-07-28

[taxonomies]
tags = ["ai", "culture"]
+++

Some time ago, there was an anime available on Netflix — *Godzilla Singular
Point*. It wasn't a spectacular success, but it featured a plot device that I
think reflects something increasingly common today: you need to know the answer
to your question before you can ask it.

This is something I see all the time in the current wave of AI hype. You need to
know what the answer *should* be before you can write a useful prompt.

<!-- more -->

The issue I have with many AI use cases is this: unless you have specialized
knowledge about the topic you're asking about, you can't reliably tell the
difference between a solid AI answer and complete nonsense.

I've had a few discussions about this on various Discord servers. The example I
often use is this simple question posed to an AI:

> Does 6 character long identification number, that contains digits and upper
> case letters (with exception to 0, O, 1, I, and L) is enough to randomly
> assign unique identification numbers for 10 million records?

You can see for your self answer from ChatGPT [there][chatgpt].

At first glance, the answer looks valid and sensible. The math checks out. It
calculates the number of available combinations correctly. Everything seems
*fine*.

**BUT…**

There is huge issue there, and probably most of the people who have been working
with basic statistic or cryptography will notice it. ChatGPT (and any other AI
that I have tested out) fail to notice very important word there

> \[…] randomly \[…]

This single word invalidates the entire reasoning, despite the correct
calculations. Because of the [birthday problem][], the answer isn't feasible.
While it's technically possible to assign a unique ID to every record, doing so
randomly introduces a high probability of collisions.

- At around 30,000 generated IDs, there's already a 50% chance of a collision
- At around 42,000, the chance of at least one duplicate reaches 99.9%

So even though the math is correct, the logic fails under the randomness constraint.

## *Jeopardy!* world

This is my main issue with AI tools: if you already have knowledge about the
subject, you don’t really need to ask the AI. But if you don’t have that
knowledge, you have no reliable way of knowing whether the answer makes sense or
not. It’s like playing *Jeopardy!* — you need to know the answer before you can
phrase the right question.

In my view, AI is most useful in areas where the results can be quickly reviewed
and discarded if needed. That’s why the whole “vibe coding” (aka slop
generation) approach falls short. If you don’t have a good sense of what the
output should look like, you probably don’t have the expertise to verify it.

[And gods forbid you from allowing AI to do anything on production][replit-fuckup].

[chatgpt]: https://chatgpt.com/share/68879fe7-d4e0-8007-9a30-3a9e2ace791d
[birthday problem]: https://en.wikipedia.org/wiki/Birthday_problem
[replit-fuckup]: https://www.businessinsider.com/replit-ceo-apologizes-ai-coding-tool-delete-company-database-2025-7?op=1
