+++
title = "Who Watches Watchmen? - Part 1"
date = 2021-04-20T15:40:35Z
draft = true
+++

Recently I gave talk about this topic on CODE Beam V Americas, but I think it
went terribly wrong. In this post I will try to describe what my presentation
was meant to be about. For anyone participating sorry for my terrible
performance and I hope that this article will be clearer.

If you are wondering about the presentation, [the slides are on SpeakerDeck][slides].

## Abstract

Currently most of the operating systems are multi-process and multi-user
operating systems. This has a lot of positive aspects, like to be able to do
more than one thing at the time at our devices, but it introduces a lot of
complexities that in most cases are hidden from the users and developers.
However these things still need to be handled in one or another way. The most
basic problems are:

- some processes need to be ran before user can interact with the OS
  in meaningful (for them) way (for example mounting filesystems, logging,
  etc.)
- some processes require strict startup ordering, for example you may need
  logging to be started before starting HTTP server
- system operator somehow need to know when the process is ready to do their
  work, which is often some time after process start
- system operator should be able to check process state in case when debugging
  is needed, most commonly via logs
- shutdown of the processes should be handled in a way, that will allow other
  processes to be shut down cleanly (for example application that uses DB should
  be down before DB itself)

## Why we need system supervisor?

System supervisor is a process started early in the OS boot, that should handle
starting and managing all other processes that will be ran on our system. It is
often the init process (first process started by the OS that is running with PID
1) or it is first (and sometimes only) process started by the init process.
Popular examples of such supervisors (often integrated with init systems):

- SysV which is "traditional" implementation that originates at UNIX System
  V (hence the name)
- BSD init that with some variations is used in BSD-based OSes (NetBSD,
  FreeBSD), it shares some similarities to SysV init and services description is
  provided by shell scripts
- OpenRC that also uses shell-based scripts for service description, used by
  Linux distributions like Gentoo or Alpine
- `launchd` that is used on Darwin (macOS, iPadOS, iOS, watchOS) systems that uses
  XML-based `plists` for services description
- `runit` which is very small init and supervisor, but quite capable, used by
  Void Linux
- Upstart created by Canonical Ltd. as a replacement for SysV-like init system
  in Ubuntu (no longer in use in Ubuntu), still used in some distributions like
  ChromeOS or Synology NAS
- `systemd` (this is the name, not "SystemD") that was created by Red Hat
  employee, (in)famous Lennart Poettering, and later was adopted by almost all
  major Linux distributions which spawned some heated discussion about it

In this article I will focus on systemd and it's approach to "new-style system
daemons".

---

**DISCLAIMER**

Each of the solutions mentioned above has its strong and weak points. I do not
want to start another flame war whether it is good or not. It has some good in
it, and it has some bad in it, but we can say that it "won" over the most used
distributions, and despite our love or hate towards it, we need to learn how to
live with that.

---

## Why `systemd`?

`systemd` became a thing because SysV approach to ordering services' startup was
mildly irritating and non-parallelizable. In short, SysV is starting processes
exactly in lexicographical order of files in given directory. This meant, that
even if your service didn't need the DB at all, but it somehow ended further in
the directory listing, you ended in waiting for the DB startup. Additionally
SysV wasn't really monitoring services, it just assumed that when process forked
itself to the background, then it is "done" with the startup and we can
continue. This is obviously not true in many cases, for example, if your
previous shutdown wasn't clean because of power shortage or other issue, then
your DB probably need a little bit time to rebuild state from journal. This
causes even more slowdown for the processes further in the list. This is highly
undesired in modern, cloud-based, environment, where you can often start the
machines on-demand during autoscaling actions. When there is a spike in the
traffic that need autoscaling, then the sooner new machine is in usable state
the sooner it can take load from other machines. In case of very sudden spikes
(like slashdot effect) it can be difference between life and death of your
infrastructure.

Different tools take different approach to solve that issue there. `systemd`
take approach that is derived from `launchd` - do not do stuff, that is not
needed. It achieved that by merging D-Bus into the `systemd` itself, and then
making all service to be D-Bus daemons (which are started on request), and
additionally it provides bunch of triggers for that daemons. We can trigger on
action of other services (obviously), but also on stuff like socket activity,
path creation/modification, mounts, connection or disconnection of device,
time events, etc.

---

**DIGRESSION**

This is exactly the reason why `systemd` has its infamous "feature creep", it
doesn't "digest" all services like Cron or `udev`. It is not that these are
"tightly" intertwined into `systemd`. You can still replace them with their
older counterparts, you will just loose all the features these bring with them.

---

Such lazy approach sometimes require changes into the service itself. For
example to let supervisor know, that you are ready (not just started), you need
some way to communicate with supervisor. In `systemd` you can do so via UNIX
socket pointed by `NOTIFY_SOCKET` environment variable passed to your
application. With the same socket you can implement another useful feature
- watchdog/heartbeat process. This mean that if for any reason your process
became non-responsive (but it will refuse to die), then supervisor will
forcefully bring process down and restart it, assuming that the error was
accidental.

About restarting, we can define behaviour of service after main process die. It
can be restarted regardless of the exit code, it can be restarted on abnormal
exit, it can remain shut, etc. Does this ring a bell? This works similarly to
OTP supervisors, but "one level above". If your service utilise system
supervisor right, you can make your application almost ultimately self-healing
(by restarts).

## BEAM integration

So now when we know a little about how and why `systemd` works as it works. We
now can go to details on how to utilise that with services in Elixir.

As a base we will implement super simple Plug application.

```elixir
# hello/application.ex
defmodule Hello.Application do
  use Application

  def start(_type, _opts) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Hello.Router, options: cowboy_opts()},
      {Plug.Cowboy.Drainer, refs: :all}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp cowboy_opts do
    [
      port: String.to_integer(System.get_env("PORT", "4000"))
    ]
  end
end

# hello/router.ex
defmodule Hello.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello World!")
  end
end
```

I will also assume that we are using [Mix release][mix-release] named `hello`
that we later copy to `/opt/hello`.

So there is only one thing left, we need to define our
[`hello.service`][service]:

```
[Unit]
Description=Hello World service

[Service]
Environment=PORT=4000
ExecStart=/opt/plug/bin/plug start
```

Now you can create file with that content in
`/usr/local/lib/systemd/system/hello.service` and then start it with:

```
# systemctl start hello.service
```

This is the simplest service imaginable, however from the start we have few
issues there:

- It will run service as user running supervisor, so if it is ran using global
  supervisor, then it will run as `root`. You do not want to run anything as
  `root`.
- On error it will produce (BEAM) core dump, which may contain sensitive data.
- It can read (and, due to being run as `root`, write) everything in the system,
  like private data of other processes.

So we need to secure that a little bit.

### Security

We should start with changing default user and group which is assigned to our
process. We can do so in 2 different ways:

1. Use some existing user and group by defining `User=` and `Group=` directives
   in our service definition; or
2. Create ephemeral user that will be created on-demand before our service
   starts, by using directive `DynamicUser=true` in service definition.

I prefer second option, as it additionally provides a lot of other security
related options, like creating private `/tmp` directory, making system
read-only, etc. This has also some disadvantages, like removing all of given
data on service shutdown, however there are options to keep some data between
launches.

In addition to that we can add `PrivateDevices=true` that will hide all
physical devices from `/dev` leaving only pseudo devices like `/dev/null` or
`/dev/urandom` (so you will be able to use `:crypto` and `:ssl` modules without
problems).

Next thing is that we can do, is to [disable crash dumps generated by BEAM][crash].
While not strictly needed in this case, it is worth remembering, that it isn't
hard to achieve, it is just using `Environment=ERL_CRASH_DUMB_SECONDS=0`.

So our new, more secure `hello.service` will look like:

```
[Unit]
Description=Hello World service

[Service]
Environment=PORT=4000
ExecStart=/opt/hello/bin/hello start

# Hardening
DynamicUser=true
PrivateDevices=true
Environment=ERL_CRASH_DUMB_SECONDS=0
```

With that we achieved quite similar level of isolation to what Docker (or other
container runtime) is providing, but using your OS file system. That mean, that
updates done by your system package manager will be applied to all running
services. That mean that you do not need to rebuild all your containers when
there is security patch issued for one of your dependencies.

## Summary

This is getting pretty long now, so I decided to split it into multiple parts.
Let's call it part 1 of more to come.

[slides]: https://speakerdeck.com/hauleth/who-supervises-supervisors
[mix-release]: https://hexdocs.pm/mix/Mix.Tasks.Release.html
[service]: https://www.freedesktop.org/software/systemd/man/systemd.service.html#
[crash]: https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/crash_dumps
