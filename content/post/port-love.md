+++
title = "For F**k Interface"
date = 2025-11-03
draft = true

[taxonomies]
tags = [
    "beam"
]
+++

Erlang provides multiple forms of FFI:

- C Nodes - external applications, that (despite the name) can be implemented in
  any language, not just C. It communicates with BEAM VM via Distributed Erlang,
  and for all needs and purposes looks like "regular" Erlang node in cluster
  (just can be implemented in any language). It provides greatest isolation, as
  technically these two nodes do not even need to be on the same machine.
- Ports - an external program, that is ran by BEAM VM and then communicates
  via unnamed Unix pipes[^pipes]. It relies on OS for process isolation, which
  mean that in the isolation level ladder it is placed in the middle.
  [^pipes]: I do not know what this mechanism is called on Windows, sorry.
- NIF (Native Implemented Function) - with that you write dynamic libraries,
  that are loaded into the same address space as BEAM VM and then you can call
  functions from this module like "normal" BEAM functions. That gives the best
  performance out of three, but at the same time it isolates least. Writing well
  behaving NIF is not easy, as you need to take into consideration the function
  run time or use dirty scheduler, unhandled runtime errors will cause problems
  for whole VM, and stuff like that.


Technically there is another FFI option, but that one is legacy:

- Port Drivers - mostly a legacy stuff, these are modules, that are loaded
  within the same address space as BEAM VM, but communication between different
  languages is done like with Ports (just within single memory space). That mean
  that you have disadvantages of both Ports (indirect communication) and NIFs
  (system destabilisation in case of error), but without any real benefit.
