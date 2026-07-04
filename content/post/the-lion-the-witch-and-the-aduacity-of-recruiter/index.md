+++
date = 2026-07-04
title = "The Lion, The Witch, and the audacity of recruiters"
description = """
Some stories of how recruitment processes went completely bonkers. Incompetence,
lies, and plain lack of any respect or common sense from recruiters that I
encountered.
"""

[taxonomies]
tags = [
    "culture",
    "rant"
]
+++

I am searching for a job. If you've read my posts recently you may have noticed
<a href="#for-hire">my "for hire" block</a> (hopefully it will disappear soon).
During that search I noticed a lot of different behaviours from recruitment
teams. However, two of them pushed me to write this article because of how bad
they were.

![The Lion, The Witch, and the audacity of this Recruiter](cover.png)

Company names and details are changed to avoid any legal troubles. I will
try to stay as close to my experiences, but some details may be blurry.

## Story 1: Hop.NS

While I was checking some old colleagues of mine at ~~Microsoft managed
corporate echo chamber~~ LinkedIn, I noticed that one of my old colleagues works
there and they had open positions available. I know the company from the past, when
they had quite an "interesting" hiring process, where they ordered you to work for
a week on the take-home project (fortunately they paid for that time). I hoped
it changed a little since then, and it did - now they hire you for one week,
where you work on the project. But let's not get ahead.

I pinged two friends that work there so they could pass my details to the HR to
speed up the process a little bit. They were quite happy to do so and after that
I had a scheduled call with their CTO. The position was described as "Senior
Elixir Developer", which fit my area of expertise and interest perfectly. I
talked with the CTO, we discussed details of the process, the teams, the job as
an *Elixir* developer, and everything seemed perfect. They sent me papers to
sign for my trial contract for that one week, where, according to the CTO, I was
supposed to work on a task, *that would become my job if they hired me*.
The paperwork went through smoothly. I waited for that Monday to see what
interesting projects I might be working on for that one week. Monday came. At
09:00, I was ready, and the wild ride began.

### Day 1

I checked my email and saw some credentials to log in to my (temporary)
corporate email, standard stuff. I wanted to join their Slack workspace - uh oh,
it didn't work. It said that I needed to contact the administrator. Okay, but I
didn't have any way of contacting them. I tried a few times and when it didn't
work, I sighed and went to LinkedIn to message my friend over there to make
someone give me access. It took a while, so after spending 2–3 of my 40
contracted hours just trying to access Slack, I finally got in. Now I needed
access to GitHub. After some more pleading and another two hours of waiting, I
was able to clone the repository. Cool. However, I still didn't know what I
would be doing there, as the person who was my overseer was in South America, so
I had a call scheduled at 18:00 to get details of my assignment. Nice, a whole
20% of my time there would be spent watching paint dry. So while I was waiting I
was reviewing the Elixir codebase (remember, that job was described as *Elixir*
developer). The codebase wasn't that bad. I opened a small PR with a few fixes.

On the evening of the first day there was a call with a person who was
responsible for my task for the trial week. I wanted to see what interesting
task awaited me. The task was clear - I was supposed to maintain their browser
extension, written in TypeScript, and extend it with new features and UI design.
I asked whether that was really what they wanted me to do, as I had a little
experience with that stuff. I did it to make them reflect on what they just
said, but the person on the other end of the conversation confirmed that it was
what I was supposed to do. They even told me, directly to my face, that:

> I do not need to worry, because all backend work should be already done.

Awesome… So you say that I do not need to worry, because the job that I want to
do is what is already done, and the job that I really do not want to do is what
I need to do…

The call ended, and I went to sleep, wondering what they were trying to achieve.
Because it feels that it was making me to go postal.

### Day 2

I tried to run and understand what the hell I was supposed to do and how it even
worked. For that I needed to install Google Chrome, which I prefer to avoid in
favour of Safari and Firefox. I spent a few hours trying to build that thing
locally and figure out how to run it, which required some additional ping-pong
with other people to obtain credentials and other bits of access.

In the meantime I talked with one of the people that vouched for me for this job.
The conversation went a little bit like this:

> **Me**: Is it normal that for the trial week, you give a task that is
> completely unrelated to the area of expertise of the candidate?
>
> **Friend**: Normally it is done in a way that the candidate should be out of
> their comfort zone. However, if a backend developer would receive purely
> frontend work, then I would say that something went wrong.
>
> **Me**: Guess what…

I discussed the matter with them for a while, and they said that if they would
be in my position, then they would call it off right there. I decided to
continue just because of my respect to the two people that vouched for me there.

In the dedicated Slack channel for my recruitment process, I asked a simple
question:

> If I am hired after this process, will I continue working on this project, or
> will it be something else?

The answer wasn't reassuring:

> Not always.

Of course you will, but we will not say that straight to your face.

In the meantime I, yet again, needed to chase people responsible for my task to
provide me with the design templates. It took several more hours and I
finally managed to run the browser extension locally. After about 10-12 hours of
the 40 hours of my trial week.

### Day 3

I managed to see how to work on this thing and I had some basic understanding of
what was going on and what needed to be done. Though I still hadn't acquired the
arcane knowledge about debugging browser extensions. Yay, small steps forward.

By noon of the third day, just in the middle of my trial week, I received a message
that they were extending the scope of the task to some additional things. That
was when I finally snapped and prepared the wall of text explaining how
ridiculous they were with this task. I explained that it was nowhere near what
they marketed to me, and that the job description didn't contain anything about
TypeScript and browser extensions. I repeatedly pointed out that I was a
"backend-and-ops" kind of engineer. This project was draining every last
bit of my sanity. I wrote to them: "I prefer to take a bath with a toaster
rather than work another minute on this". I told them that the task was a waste
of both my time, and that the only reason I hadn't called it off immediately was
out of respect for my friends who had vouched for me. I also noted that I would
write a piece about the whole process on my blog. The CTO's answer was that they
understood, they wanted to check if I was "a good fit for their culture" (of
hiring backend engineers and assigning them unrelated frontend work), and they
asked me to not publish it because "they felt they hadn't done anything wrong".

It took some time, but as you, my dear readers, could have noticed, I do not
give a damn about what they want.

### Summary

They paid me for that agonising 20 hours of my "work" there. 3-4 weeks later their
CTO wrote to me a message over LinkedIn to ask if I was interested in their
position of Staff Software Engineer. I asked him whether they still used that
bait-and-switch tactic.

## Story 2: PerhapsMaybe

This one will be a shorter one. Again a company where I have some friends. I
noticed that they had a position open for Software Engineer with Elixir and I
applied. I pinged these friends whether they could bump my application. One of
them was able to put me right in front of their VP of Infrastructure, who
supposedly was hiring manager for this position, so I hoped that it would be
quite quick.

It was not.

I sent my details on 27 May 2026. First contact from their recruitment team was
11 June 2026, over two weeks later, and only when I stalked the VP on LinkedIn
and sent them an invitation. The recruiter contacted me to schedule a call with
the said VP about my previous experiences and some introductions. The call in
question went rather smoothly. That one-hour conversation made me even more
interested in the role. It sounded like something I'd really enjoy.

After that call, they contacted me to ask about my availability for technical
calls. The "interesting" part was that it was meant to last for 5½ hours. Quite
substantial, but what you won't do for a job (I also quite like talking with
fellow engineers, so it wasn't much of a problem).

The interview consisted of three parts:

- A one-hour "Systems Design" - where I was tasked with designing some asynchronous
  payment system with synchronous payment gateway. I think it went quite okay.
- A one-hour "Coding Interview" - LeetCode-like tasks where I was tasked with writing
  some "algorithms" (cross product and some chess-horse jumping across a
  keypad). I made some mistakes there while analysing big-O complexity of second
  task, but overall, I felt quite good with my solutions.
- A one-hour "Technical Deep Dive" - where I was talking about some of my old
  projects (in this case [Ultravisor](https://github.com/Ultravisor/ultravisor))
  and the technical details of it. What I did there and how I had done it. I
  felt good, but my gut told me, that the other side wasn't impressed or was
  expecting something else.

All of that happened during one day, but with breaks between calls (30 minutes
and 2 hours respectively).

After these calls I waited. One day passed. Then another. At the end of the second
day I asked the recruiter whether they had any updates. They had, but the answer
was not what I expected - they rejected me. Well, disappointing, but it happens.
Shame, as I really wanted to work with my friends over there, as I know that
they're excellent engineers. The email contained one line though, that made me
facepalm:

> Please note that due to the high volume of applicants, we do not share
> individualized feedback.

Probably anyone that is looking for a job right now has seen that multiple
times already.

I would let it slip, if only they would not send me another email a week later.
The email read:

> **From**: PerhapsMaybe Hiring Team  
> **Subject**: PerhapsMaybe Candidate Experience Survey
>
> Hi Łukasz,
>
> We want to ensure that our recruiting process is efficient and candidates have
> a great experience. We're sending you this survey to gather some honest
> feedback about your recent interview.
>
> Please take a moment to give us your feedback and tell us what you think could
> be improved about your experience.
>
> \[link to survey\]
>
> Sincerely, The PerhapsMaybe Talent Team

Despite having about 5 hours of recordings and probably some automated
notes from meetings (of course I was forbidden from using any AI for notes), are
you not willing to compose 3-4 sentences of why you do not want to hire me? But
I am supposed to provide you with details of how your process is going and how
you can reject more candidates faster? That requires some audacity.

My response to that was that, as I see it, I wasn't a candidate, but rather a
contractor whose task was to assess their hiring process. So I asked the
recruiter for their billing details so I could invoice them at my contractor
rates.

## Final Words

The hiring market is fucked up. [Recruiters will blame you for using LLMs in the
application process][li-ai-recruiter]. The applications often contain crap like:
"why do you want to work for XYZ" or "what is the most exciting thing about
working for XYZ". It isn't my job to sell your product to you. I want to do some
stuff that interests me and in return get money. There is no additional depth.
The only person in the world who can truly say they are excited about your
product is the company's founder. At least until the IPO, as after that, the
shareholders do not give a damn either, all they want is to increase their
value.

Just to end with some light (unfortunately, I think that this light is at the
wrong end of the tunnel). There are some recruiters that I can say something
good about. When I was applying to [Fresha](https://www.fresha.com/) I was
speaking with [Christine Wong](https://www.linkedin.com/in/christinekwong/).
She, after I was rejected due to "not enough coding agents experience", asked me
to schedule a call to give me personalised feedback face to face. In that bleak
world we live, it was actually nice to see a real person showing respect for
candidates. And I am really grateful for that.

[li-ai-recruiter]: https://www.linkedin.com/feed/update/urn:li:activity:7464732348287373312/
