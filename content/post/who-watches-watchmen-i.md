+++
title = "Who Watches Watchmen? - Part 1"
date = 2022-01-17T21:22:18+01:00

description = """
A lot of application use systems like Kubernetes for their deployment. In my
humble opinion it is often overkill as system ,that offers most of the stuff such
thing provide, is already present in your OS. In this article I will try to
present how to utilise the most popular system supervisor from Elixir
applications.
"""

[taxonomies]
tags = [
  "elixir",
  "programming",
  "systemd",
  "deployment"
]
+++

I gave talk about this topic on CODE Beam V Americas, but I wasn't really
satisfied with it. In this post I will try to describe what my presentation was
meant to be about.

If you are wondering about the presentation, [the slides are on SpeakerDeck][slides].

[slides]: https://speakerdeck.com/hauleth/who-supervises-supervisors

## Abstract

Most of the operating systems are multi-process and multi-user operating
systems. This has a lot of positive aspects, like to be able to do more than one
thing at the time at our devices, but it introduces a lot of complexities that
in most cases are hidden from the users and developers. These things still need
to be handled in one or another way. The most basic problems are:

- some processes need to be started before user can interact with the OS
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
starting and managing all other processes that will be run on our system. It is
often the init process (first process started by the OS that is running with PID
1\) or it is first (and sometimes only) process started by the init process.
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
- `runit` which is small init and supervisor, but quite capable, for example
  used by Void Linux
- Upstart created by Canonical Ltd. as a replacement for SysV-like init system
  in Ubuntu (no longer in use in Ubuntu), still used in some distributions like
  ChromeOS or Synology NAS
- `systemd` (this is the name, not "SystemD") that was created by Red Hat
  employee, (in)famous Lennart Poettering, and later was adopted by almost all
  major Linux distributions which spawned some heated discussion about it

In this article I will focus on systemd, and its approach to "new-style system
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
the directory listing, you ended in waiting for the DB startup. Additionally,
SysV wasn't really monitoring services, it just assumed that when process forked
itself to the background, then it is "done" with the startup, and we can
continue. This is obviously not true in many cases, for example, if your
previous shutdown wasn't clean because of power shortage or other issue, then
your DB probably need a bit of time to rebuild state from journal. This causes
even more slowdown for the processes further in the list. This is highly
undesired in modern, cloud-based, environment, where you can often start the
machines on-demand during autoscaling actions. When there is a spike in the
traffic that need autoscaling, then the sooner new machine is in usable state
the sooner it can take load from other machines.

Different tools take different approach to solve that issue there. `systemd`
take approach that is derived from `launchd` - do not do stuff, that is not
needed. It achieved that by merging D-Bus into the `systemd` itself, and then
making all service to be D-Bus daemons (which are started on request), and
additionally it provides a bunch of triggers for that daemons. We can trigger on
action of other services (obviously), but also on stuff like socket activity,
path creation/modification, mounts, connection or disconnection of device,
time events, etc.

---

**DIGRESSION**

This is exactly the reason why `systemd` has its infamous "feature creep", it
doesn't "digest" all services like Cron or `udev`. It is not that these are
"tightly" intertwined into `systemd`. You can still replace them with their
older counterparts, you will just lose all the features these bring with them.

---

Such lazy approach sometimes require changes into the service itself. For
example to let supervisor know, that you are ready (not just started), you need
some way to communicate with supervisor. In `systemd` you can do so via UNIX
socket pointed by `NOTIFY_SOCKET` environment variable passed to your
application. With the same socket you can implement another useful feature
\- watchdog/heartbeat process. This mean that if for any reason your process
became non-responsive (but it will refuse to die), then supervisor will
forcefully bring process down and restart it, assuming that the error was
accidental.

About restarting, we can define behaviour of service after main process die. It
can be restarted regardless of the exit code, it can be restarted on abnormal
exit, it can remain shut, etc. Does this ring a bell? This works similarly to
OTP supervisors, but "one level above". If your service utilize system
supervisor right, you can make your application almost ultimately self-healing
(by restarts).

## Basic setup

Now, when we know a little about how and why `systemd` works as it works, we
now can go to details on how to utilize that with services in Elixir.

As a base we will implement super simple Plug application:

```elixir
# hello/application.ex
defmodule Hello.Application do
  use Application

  def start(_type, _opts) do
    children = [
      {Plug.Cowboy, [scheme: :http, plug: Hello.Router] ++ cowboy_opts()},
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
```

```elixir
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

[mix-release]: https://hexdocs.pm/mix/Mix.Tasks.Release.html

### systemd unit file

We have only one thing left, we need to define our [`hello.service`][systemd.service]:

```ini
[Unit]
Description=Hello World service

[Service]
Environment=PORT=80
ExecStart=/opt/hello/bin/hello start
```

Now you can create file with that content in
`/usr/local/lib/systemd/system/hello.service` and then start it with:

```
# systemctl start hello.service
```

This is the simplest service imaginable, however from the start we have few
issues there:

- It will run service as user running supervisor, so if it is run using global
  supervisor, then it will run as `root`. You do not want to run anything as
  `root`.
- On error it will produce (BEAM) core dump, which may contain sensitive data.
- It can read (and, due to being run as `root`, write) everything in the system,
  like private data of other processes.

[systemd.service]: https://www.freedesktop.org/software/systemd/man/systemd.service.html#

## Service readiness

Erlang VM isn't really the best tool out there wrt the startup times. In
addition to that our application may need some preparation steps before it can
be marked as "ready". This is problem that I sometimes encounter in Docker,
where some containers do not really have any health check, and then I need to
have loop with check in some of the containers that depend on another one. This
"workaround" is frustrating, error prone, and can cause nasty Heisenbugs when
the timing will be wrong.

Two possible solutions for this problem are:

- Readiness probe - another program that is ran after the main process is
  started, that checks whether our application is ready to work.
- Notification system where our application uses some common protocol to inform
  the supervisor that it finished setup and is ready for work.

systemd supports the second approach via [`sd_notify`][sd_notify]. The approach
there is simple - we have `NOTIFY_SOCKET` environment variable that contain path
to the Unix datagram socket, that we can use to send informations about state of
our application. This socket accept set of different messages, but right now,
for our purposes, we will focus only on few of them:

- `READY=1` - marks our service as ready, aka it is ready to do its work (for
  example accept incoming HTTP connections in our example). It need to be sent
  withing given timespan after start of the VM, otherwise the process will be
  killed and possibly restarted
- `STATUS=name` - sets status of our application that can be checked via
  `systemctl status hello.service`, this allows us to have better insight into
  what is the high level state without manually traversing through logs
- `RELOADING=1` - marks, that our application is reloading, which in general may
  mean a lot of things, but there it will be used to mark `:init.restart/0`-like
  behaviour (due to [erlang/otp#4698][] there is wrapper for that function in
  `systemd` library). The process need then to send `READY=1` within given
  timespan, or the process will be marked as a malfunctioning, and will be
  forcefully killed and possibly restarted
- `STOPPING=1` - marks, that our application began shutting down process, and
  will be closing soon. If the process will not close within given timespan, it
  will be forcefully killed

These messages provide us enough power to not only mark the service as ready,
but also provides additional information about system state, so even operator,
who knows a little about Erlang or our application runtime, will be able to
understand what is going on.

The main thing is that systemd will wait with activation of the dependants of
our system as well as the `systemctl start` and `systemctl restart` commands
will wait until our service declare that it is ready.

Usage of such feature is quite simple:

```ini
[Unit]
Description=Hello World service

[Service]
# Define `Type=` to `notify`
Type=notify
Environment=PORT=80
ExecStart=/opt/hello/bin/hello start
WatchdogSec=1min
```

And then in our supervisor tree we need add `:systemd.ready()` **after** last
process needed for proper functioning of our application, in our simple example
it is after `Plug.Cowboy`:

```elixir
# hello/application.ex
defmodule Hello.Application do
  use Application

  def start(_type, _opts) do
    children = [
      {Plug.Cowboy, [scheme: :http, plug: Hello.Router] ++ cowboy_opts()},
      :systemd.ready(), # <-- it is function call, as it returns proper
                        # `child_spec/0`
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
```

Now restarting our service will not finish immediately, but will wait until our
service will declare that it is ready.

```shell
# systemctl restart hello.service
```

About `STOPPING=1` - the magic thing is that the `systemd` library takes care of
it for you. As soon as the system will be scheduled to shutdown this message
will be automatically sent, and the operator will be notified about this fact.

We can also provide more information about state of our application. As you may
have already noticed, we have [`Plug.Cowboy.Drainer`][] there. It is process that
will delay shutdown of our application while there are still open connections.
This can take some time, so it would be handy if the operator would see that the
draining is in progress. We can easily achieve that by again changing our
supervision tree to:

```elixir
# hello/application.ex
defmodule Hello.Application do
  use Application

  def start(_type, _opts) do
    children = [
      {Plug.Cowboy, [scheme: :http, plug: Hello.Router] ++ cowboy_opts()},
      :systemd.ready(),
      :systemd.set_status(down: [status: "drained"]),
      {Plug.Cowboy.Drainer, refs: :all, shutdown: 10_000},
      :systemd.set_status(down: [status: "draining"])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp cowboy_opts do
    [
      port: String.to_integer(System.get_env("PORT", "4000"))
    ]
  end
end
```

Now when we will shutdown our application by:

```shell
# systemctl stop hello.service
```

And we have some connections open to our service (you can simulate that with
`wrk`) then when we ran `systemctl status hello.service` in separate terminal
(previous will be blocked until our service shuts down) then you will be able to
see something like:

```
● hello.service - Example Plug application
     Loaded: loaded (/usr/local/lib/systemd/system/hello.service; static; vendor preset: enabled)
          Active: deactivating (stop-sigterm) since Sat 2022-01-15 17:46:30 CET;
          1s ago
          Main PID: 1327 (beam.smp)
          Status: "draining"
          Tasks: 19 (limit: 1136)
          Memory: 106.5M
```

You can notice that the `Status` is set to `"draining"`. As soon as all
connections will be drained it will change to `"drained"` and then the
application will shut down and service will be marked as `inactive`.

[sd_notify]: https://www.freedesktop.org/software/systemd/man/sd_notify.html
[erlang/otp#4698]: https://github.com/erlang/otp/issues/4698
[`Plug.Cowboy.Drainer`]: https://hexdocs.pm/plug_cowboy/2.5.2/Plug.Cowboy.Drainer.html

## Watchdog

Watchdog allows us to monitor our application for responsiveness (as mentioned
above). It is simple feature that requires our application to ping systemd
within specified interval, otherwise the application will be forcibly shut down
as malfunctioning. Fortunately for us, the `systemd` library that provides our
integration, have that feature out of the box, so all we need to do to achieve
expected result is set `WatchdogSec=` option in our `systemd.service` file:

```ini
[Unit]
Description=Hello World service

[Service]
Environment=PORT=80
Type=notify
ExecStart=/opt/hello/bin/hello start
WatchdogSec=1min
```

This configuration says that if the VM will not send healthy message each 1
minute interval, then the service will be marked as malfunctioning. From the
application side we can manage state of the watchdog in several ways:

- By setting `systemd.watchdog_check` configuration option we can configure the
  function that will be called on each check, if that function return `true`
  then it mean that application is healthy and the systemd should be notified
  with ping, if it returns `false` or fail, then the check will be omitted.
- Manually sending trigger message in case of detected problems via
  `:systemd.watchdog(trigger)`, it will immediately mark service as
  malfunctioning and will trigger action defined in service unit file (by
  default it will restart application)
- Disabling built in watchdog process via `:systemd.watchdog(:disable)` and then
  manually sending `:systemd.watchdog(:ping)` within expected intervals
  (discouraged)

## Security

We should start with changing default user and group which is assigned to our
process. We can do so in 2 different ways:

1. Use some existing user and group by defining `User=` and `Group=` directives
   in our service definition; or
2. Create ephemeral user on-demand before our service starts, by using directive
  `DynamicUser=true` in service definition.

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
hard to achieve, it is just using `Environment=ERL_CRASH_DUMP_SECONDS=0`.

Our new, more secure, `hello.service` will look like:

```ini
[Unit]
Description=Hello World service
Requires=network.target

[Service]
Type=notify
Environment=PORT=80
ExecStart=/opt/hello/bin/hello start
WatchdogSec=1min

# We need to add capability to be able to bind on port 80
CapabilityBoundingSet=CAP_NET_BIND_SERVICE

# Hardening
DynamicUser=true
PrivateDevices=true
Environment=ERL_CRASH_DUMP_SECONDS=0
```

The problem with that configuration is that our service is now capable on
binding **any** port under 1024, so for example, if there is some security
issue, then the malicious party can open any of the restricted ports and then
serve whatever data they want there. This can be quite problematic, and the
solution for that problem will be covered in Part 2, where we will cover socket
passing and socket activation for our service.

With that we achieved quite basic level of isolation to what Docker (or other
container runtime) is providing, but it do not require `overlayfs` or anything
more, than what you already have on your machine. That means, updates done by
your system package manager will be applied to all running services. With that
you do not need to rebuild all your containers when there is security patch
issued for any of your dependencies.

Of course it only scratches the surface of what is possible with systemd wrt
the hardening of the services. More information can be found in [RedHat
article][rh-systemd-hardening] and in [`systemd-analyze security` command
output][systemd-analyze-security]. Possible features are:

- creation of the private networks for your services
- disallowing creation of socket connections that are outside of the specified
  set of families
- make only some paths readable
- hide some paths from the process
- etc.

Coverage of just that topic is a little bit out of scope for this blog post, so
I encourage you to read the documentation of [`systemd.exec`][systemd.exec] and
articles mentioned above for more details.

[crash]: https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/crash_dumps
[rh-systemd-hardening]: https://www.redhat.com/sysadmin/mastering-systemd
[systemd-analyze-security]: https://www.freedesktop.org/software/systemd/man/systemd-analyze.html#systemd-analyze%20security%20%5BUNIT...%5D
[systemd.exec]: https://www.freedesktop.org/software/systemd/man/systemd.exec.html

## Summary

This blog post is already quite lengthy, so I will split it into separate parts.
There probably will be 3 of them:

- [Part 1 - Basics, security, and FD passing (this one)](?1)
- Part 2 - Socket activation
- Part 3 - Logging
