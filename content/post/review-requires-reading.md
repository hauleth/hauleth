+++
date = 2026-06-04
title = "Reviewing code requires reading"

[taxonomies]
tags = [
  "ai",
  "culture"
]
+++

On [Lobste.rs][] I have found today the article written by the Charity
Majors - CTO of the Honeycomb.io ["AI enthusiasts are in a race against time, AI
skeptics are in a race against entropy"][art]. This was pretty good read until
there was this question posed:

[Lobste.rs]: https://lobste.rs
[art]: https://charitydotwtf.substack.com/p/ai-enthusiasts-are-in-a-race-against

> What would it take for you to feel comfortable shipping code to production
> without reading it?

<!-- more -->

Her proposed solutions were:

> Better evals? Better tests? Better feature flags, guardrails, observability?
> Work on decoupling dependencies and reducing blast radius? Start with
> something small and out of the critical path? What is the work we need to do
> to prepare? What comes first, ordering-wise? Can we put that on the roadmap?

But that is completely missing a point. The point of doing review is to [diffuse
responsibility][dor]. No one want to be the sole person responsible for the
downtime of the system. No one want to be the sole person responsible for
security issues. No one want to be responsible for accidental data removal. And
the sole purpose of reviews is to remove that burden form single individual and
instead make it *team responsibility*. That way, the blame is "spread" among
writer and all reviewers.

[dor]: https://en.wikipedia.org/wiki/Diffusion_of_responsibility

If someone wants to remove that group responsibility and instead tell you to
"approve without reading" then why ask me to push the button manually at all? If
you want to pay someone for pushing a button without thinking then there you
are, here is a button for them to click:

---

<div>
    <center>
        <button id="pointless-button">Push me!</button>
    </center>
{% script() %}
    const LYRICS = [
        "Push me!",
        "And then just touch me!",
        "Till I can get my",
        "Satisfaction"
    ]
    let curr = 0

    document.addEventListener("DOMContentLoaded", () => {
        let button = document.getElementById("pointless-button")

        button.addEventListener("click", (ev) => {
            curr = (curr + 1) % LYRICS.length
            ev.target.innerText = LYRICS[curr]
        })
    })
{% end %}
</div>

<small>This is demo of my upcoming SaaS - button roulette, which will merge random PR
assigned to you that has all CI green. Perfect for "AI enthusiastic"
CTOs.</small>

---

Another reason why we do reviews is to *learn codebase*. In many projects the
codebase is too big to be constantly aware of all parts of the system. The
review is to force more people to have a look into different parts, to reduce
[bus factor][], increase familiarity of the team with different parts, to teach
new team members about codebase and code culture.

[bus factor]: https://en.wikipedia.org/wiki/Bus_factor

If we force everyone to "approve without reading", then we lose all that. That
way it not only increase the bus factor to 1, but also [externalise it to 3rd
party][claude-down].

[claude-down]: https://www.independent.co.uk/tech/claude-down-not-working-anthropic-ai-b2987749.html

---

So to answer Charity's question:

> What would it take for you to feel comfortable shipping code to production
> without reading it?

My answer is:

> Written waiver of responsibility in case of bugs, security issues, downtime,
> etc. written by the person that issued such statement.

If I am forced to "feel comfortable shipping unread code to production", then I
also want to feel secure from any consequences of such action. Simple as that,
but I highly doubt that I will get such waiver from anyone.
