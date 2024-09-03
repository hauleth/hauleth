+++
title = "Who Watches Watchmen? - Part 2"
date = 2023-11-14

description = """
Continuation of travel into making systemd to work for us, not against us. This
time we will talk about socket activation and how to make our application run
only when we need it to run.
"""

[taxonomies]
tags = [
  "beam",
  "systemd"
]

[[extra.thanks]]
name = "Nicodemus"
why = "helping me with my poor English"
+++

This is continuation of [Part I][part-i] where I described the basics of the
supervising BEAM applications with systemd and how to create basic, secure
service for your Elixir application with it. In this article I will assume that
you have read [the previous one][part-i].

______________________________________________________________________

We already have our super simple service description. Just to refresh your
memory, it is the `hello.service` file once again:

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

However there is one small problem. It allows our service to listen on **any**
restricted port, not just `80` that we want to listen on. This can be
troublesome as an attacker that gains RCE on our server can then capture any
traffic on any port that we do not want to open (for example exposing port 22
using the [`ssh`] module).

It would be nice if we could somehow inject sockets for only the ports we want
to listen to into our application.

## Socket passing

Thanks to the [`systemd.socket`][systemd.socket] feature we can achieve that
with a little work on our side.

First we need to create new unit named `hello.socket` next to our
`hello.service`:

```ini
[Unit]
Description=Listening socket
Requires=sockets.target

[Socket]
ListenStream=80
BindIPv6Only=both
ReusePort=true
NoDelay=true
```

It will create a socket connected to TCP 80 (because we used `ListenStream=`,
and TCP is the stream protocol). By default it will bind that socket to a
service named the same as our socket, so now we need to edit our `hello.service`
a little bit:

```ini
[Unit]
Description=Hello World service
Requires=network.target

[Service]
Type=notify
Environment=PORT=80
ExecStart=/opt/hello/bin/hello start
WatchdogSec=1min

# See, we no longer need to insecurely allow binding to any port
# CapabilityBoundingSet=CAP_NET_BIND_SERVICE

# Hardening
DynamicUser=true
PrivateDevices=true
Environment=ERL_CRASH_DUMP_SECONDS=0
```

And we need to modify our `Hello.Application.cowboy_opts/0` to handle the socket
which is passed to us a file descriptor:

```elixir
# hello/application.ex
defmodule Hello.Application do
  use Application

  def start(_type, _opts) do
    fds = :systemd.listen_fds()

    children = [
      {Plug.Cowboy, [scheme: :http, plug: Hello.Router] ++ cowboy_opts(fds)},
      {Plug.Cowboy.Drainer, refs: :all}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  # If there are no sockets passed to the application, then start listening on
  # the port specified by the `PORT` environment variable
  defp cowboy_opts([]) do
    [port: String.to_integer(System.get_env("PORT", "5000"))]
  end

  # If there are any socket passed, then use first one
  defp cowboy_opts([socket | _]) do
    fd =
      case socket do
        # Sockets can be named, which will be passed as the second element in
        # a tuple
        {fd, _name} -> fd
        # Or unnamed, and then it will be just the file descriptor
        fd -> fd
      end

    [
      net: :inet6, # (1)
      port: 0,     # (2)
      fd: fd       # (3)
    ]
  end
end
```

1. Systemd sockets are IPv6 enabled (we explicitly said that we want to listen
   on both). That means, that we need to mark our connection as an INET6
   connection. This will not affect IPv4 (INET) connections.
1. We are required to pass `:port` key, but its value will be ignored, so we
   just pass `0`.
1. We pass the file descriptor that will be then passed to the Cowboy listener.

Now when we will start our service:

```txt
# systemctl start hello.service
```

It will be available at `https://localhost/` while still running as an
unprivileged user.

### Multiple ports

The question may arise - how to allow our service to listen on more than one
port, for example you want to have your website available as HTTPS alongside
"regular" HTTP. This means that our application needs to listen on two
restricted ports:

- 80 - for HTTP
- 443 - for HTTPS

Now we need to slightly modify a little our socket service and add another one.
First rename our `hello.socket` to `hello-http.socket` and add a line
`Service=hello.service` and `FileDescriptorName=http` to `[Socket]` section, so
we end with:

```ini
[Unit]
Description=HTTP Socket
Requires=sockets.target

[Socket]
# We declare the name of the file descriptor here to simplify extraction in
# the application afterwards. By default it will be the socket name (so
# `hello-http` in our case), but `http` is much cleaner.
FileDescriptorName=http
ListenStream=80
Service=hello.service
BindIPv6Only=both
ReusePort=true
NoDelay=true
```

Next we create a similar file, but for HTTPS named `hello-https.socket`

```ini
[Unit]
Description=HTTPS Socket
Requires=sockets.target

[Socket]
FileDescriptorName=https
ListenStream=443
Service=hello.service
BindIPv6Only=both
ReusePort=true
NoDelay=true
```

And we add the dependency on both of our sockets to the `hello.service`:

```ini
[Unit]
Description=Hello World service
After=hello-http.socket hello-https.socket
BindTo=hello-http.socket hello-https.socket

[Service]
ExecStart=/opt/hello/bin/hello start

# Hardening
DynamicUser=true
PrivateDevices=true
Environment=ERL_CRASH_DUMB_SECONDS=0
```

Now we need to somehow differentiate between our sockets in the
`Hello.Application`, so we will be able to pass the proper FD to each of the
listeners. The `:systemd.listen_fds/0` will return a list of file descriptors,
and if they are named, the format will be a 2-tuple where the first element is
the file descriptor and the second is the name as a string:

```elixir
# hello/application.ex
defmodule Hello.Application do
  use Application

  def start(_type, _opts) do
    fds = :systemd.listen_fds()

    router = Hello.Router

    children = [
      {Plug.Cowboy, [
        scheme: :http,
        plug: router
      ] ++ cowboy_opts(fds, "http")},
      {Plug.Cowboy, [
        scheme: :https,
        plug: router,
        keyfile: "path/to/keyfile.pem",
        certfile: "path/to/certfile.pem",
        dhfile: "path/to/dhfile.pem"
      ] ++ cowboy_opts(fds, "https")},
      {Plug.Cowboy.Drainer, refs: :all}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp cowboy_opts(fds, protocol) do
    case List.keyfind(fds, protocol, 1) do
      # If there is socket passed for given protocol, then use that one
      {fd, ^protocol} ->
        [
          net: :inet6,
          port: 0,
          fd: fd
        ]

      # If there are no sockets passed to the application that match
      # the protocol, then start listening on the port specified by
      # `PORT_{protocol}` environment variable
      _ ->
        [
          port: String.to_integer(System.get_env("PORT_#{protocol}", "5000"))
        ]
  end
end
```

Now our application will listen on both - HTTP and HTTPS, despite running as
unprivileged user.

## Socket activation

Now, that we can inject sockets to our application with ease we can achieve even
more fascinating feature - socket activation.

Some of you may used `inetd` in the past, that allows you to dynamically start
processes on network requests. It is quite an interesting tool that detects
traffic on certain ports, then spawns a new process to handle it, passing data
to and from that process via `STDIN` and `STDOUT`. There was a quirk though, it
required the spawned process to shutdown after it handled the request and it was
starting a new instance for each request. That works poorly with VMs like BEAM
that have substantial startup time and are expected to be long-running systems.
BEAM is capable of handling network requests on it's own.

Fortunately for us, the way that we have implemented our systemd service is all
that we need to have our application dynamically activated. To observe that we
just need to shutdown everything:

```txt
# systemctl stop hello-http.socket hello-https.socket hello.service
```

And now relaunch **only the sockets**:

```txt
# systemctl start hello-http.socket hello-https.socket
```

We can check, that our service is not running:

```txt
$ systemctl status hello.service
● hello.service - Hello World service
     Loaded: loaded (/usr/local/lib/systemd/system/hello.service; static; vendor preset: enabled)
     Active: inactive (dead)
TriggeredBy: ● hello-http.socket ● hello-https.socket
```

We can see the `TriggeredBy` section that tells us, that this service will be
started by one of the sockets listed there. Let see what will happen when we
will try to request anything from our application:

```txt
$ curl http://localhost/
Hello World!
```

You can see that we got a response from our application. This mean that our
application must have started, and indeed when we check:

```txt
$ systemctl status hello.service
● hello.service - Hello
     Loaded: loaded (/usr/local/lib/systemd/system/hello.service; static; vendor preset: enabled)
     Active: active (running) since Thu 2022-02-03 13:20:27 CET; 4s ago
TriggeredBy: ● hello-http.socket ● hello-https.socket
   Main PID: 1106 (beam.smp)
      Tasks: 19 (limit: 1136)
     Memory: 116.7M
     CGroup: /system.slice/hello.service
             ├─1106 /opt/hello/erts-12.2/bin/beam.smp -- -root /opt/hello -progname erl -- -home /run/hello -- -noshell -s elixir start_cli -mode embedded -setcookie CR63SVI6L5JAMJSDL3H4XPNMOPHEWSV2FPHCHCAN65CY6ASHMXBA==== -sname hello -c>
             └─1138 erl_child_setup 1024
```

It seems to be running, and if we stop it, then we will get information that it
still can be activated by our sockets:

```txt
# systemctl stop hello.service
Warning: Stopping hello.service, but it can still be activated by:
  hello-http.socket hello-https.socket
```

That means, that systemd is still listening on the sockets that we defined, even
when our application is down, and will start our application again as soon as
there are any incoming requests.

Let test that out again:

```txt
$ curl http://localhost/
Hello World!
$ systemctl status hello.service
● hello.service - Hello
     Loaded: loaded (/usr/local/lib/systemd/system/hello.service; static; vendor preset: enabled)
     Active: active (running) since Thu 2022-02-03 13:22:27 CET; 4s ago
TriggeredBy: ● hello-http.socket ● hello-https.socket
   Main PID: 3452 (beam.smp)
      Tasks: 19 (limit: 1136)
     Memory: 116.7M
     CGroup: /system.slice/hello.service
             ├─3452 /opt/hello/erts-12.2/bin/beam.smp -- -root /opt/hello -progname erl -- -home /run/hello -- -noshell -s elixir start_cli -mode embedded -setcookie CR63SVI6L5JAMJSDL3H4XPNMOPHEWSV2FPHCHCAN65CY6ASHMXBA==== -sname hello -c>
             └─3453 erl_child_setup 1024
```

Our application got launched again, automatically, just by the fact that
there was incoming TCP connection.

Does it work for HTTPS connection as well?

```txt
# systemctl stop hello.service
$ curl -k https://localhost/
Hello World!
```

It seems so. Independently of which port we try to reach our application on, it
will be automatically launched for us and the connection will be properly
handled. Do note that systemd will not shut down our process after serving the
request. It will continue to run from that point forward.

## Summary

I know that it took quite while since the last post (ca. 1.5 years), but I hope
that I will be able to write the final part much sooner than this.

- [Part 1 - Basics, security, and FD passing][part-i]
- [Part 2 - Socket activation (this one)](./#top)
- Part 3 - Logging

[part-i]: @/post/who-watches-watchmen-i.md
[systemd.socket]: https://www.freedesktop.org/software/systemd/man/systemd.socket.html
[`ssh`]: https://erlang.org/doc/man/ssh.html
