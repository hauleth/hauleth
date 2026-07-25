+++
title = "Łukasz Niemier"

[extra]
no_comments = true
sitemap = false
+++

<small>Senior Elixir Developer</small>

**Email:** <lukasz@niemier.pl>  
**Website:** <https://hauleth.dev>  

**GitHub**: <https://github.com/hauleth>  
**Tangled**: <https://tangled.org/hauleth.dev>  
**LinkedIn**: <https://linkedin.com/in/niemier>  
**Professional profile**: <https://sifa.id/p/hauleth.dev>  

{% section() %}
## Summary

Senior-level Elixir/Erlang Engineer with 10+ years of experience building
distributed cloud-native platforms and high-performance backend services.
Contributor to Elixir, Erlang/OTP, and Ecto. Specializing in performance
engineering, distributed systems, and fault-tolerant platforms.

**Areas of expertise**:  
Distributed Systems &middot; BEAM/OTP &middot; Performance Engineering &middot; System Architecture &dot; Technical Mentoring
{% end %}

{% section() %}
## Technical Skills

**Core Technologies**: Elixir, Erlang/OTP, Phoenix, Ecto, PostgreSQL  
**Additional Experience**: Rust, Terraform, Nomad, Consul, Docker, Nix/NixOS  
{% end %}

{% section() %}
## Open Source & Ecosystem Contributions

Recognized contributor to the BEAM ecosystem through open-source development,
conference speaking, and standards working groups.

- Contributor to Elixir core
- Contributor to Erlang/OTP
- Contributor to Ecto
- Changes accepted across logging, networking, tooling, and language features
- Member of Erlang Ecosystem Foundation Observability Working Group
- Member of OpenTelemetry Erlang Working Group
- *Member of the Year* on Elixir Forum in years 2019&ndash;2025
{% end %}

## Professional Experience

{% section() %}
### Hauleth.dev - Owner

<small>Nov 2016 - Present</small>

- Publish technical articles on Elixir, Erlang, Rust, distributed systems, and
  culture
- Develop and maintain open-source projects used by the BEAM community
- Deliver conference talks and participate in ecosystem working groups
{% end %}

{% section() %}
### DockYard - Elixir Consultant

<small>Nov 2025 &ndash; Dec 2025</small>

- Performed architecture and security review of a large Elixir codebase
- Delivered a detailed report with recommendations covering architecture,
  scalability, fault tolerance and security
{% end %}

{% section() %}
### Supabase - Lead Elixir Developer

<small>Nov 2023 &ndash; Jun 2025</small>

- Redesigned metrics gathering architecture resulting in 10&times; throughput
  improvement and lower infrastructure costs
- Upgraded production platform from OTP 24 to OTP 27 and Elixir 1.14 to 1.18
- Simplified test architecture, reducing CI resource usage while improving
  reliability and developer experience
- Implemented e2e tests against existing 3rd-party PostgreSQL clients to improve
  platform reliability for external clients
- Led design and implementation of multi-region deployment strategy improving
  platform fault tolerance and availability
- Mentored engineers in Erlang/OTP profiling and performance analysis of
  production systems
{% end %}

{% section() %}
### Supabase - Senior Elixir Consultant

<small>Mar 2023 &ndash; Nov 2023</small>

- Implemented on-the-fly decompression of incoming data that improved ingestion
  possibilities and reduced transfer usage by up to 50%
- Implemented DataDog-compatible ingestion endpoint for seamless transition from
  DataDog to Logflare
- Reduced BigQuery congestion by 10% by architectural redesign of existing
  pipelines
- Added support for AWS Cloud Events metadata extraction
- Improved CI utilisation by 35% thanks to splitting different actions to
  separate steps ran in parallel
- Replaced dynamic generation of connection modules for PostgreSQL storage
  system with Ecto's dynamic repositories to prevent DoS attack via atom
  exhaustion
- Maintained Rust NIF bindings to `pg_query` SQL parser library
{% end %}

{% section() %}
### Eiger - Consultant

<small>Aug 2022 &ndash; Feb 2023</small>

- Implemented Interledger protocol for cross-chain financial transactions
- Implemented Elixir FFI bindings to Rust library Zcash
- Led implementation of GraphQL APIs for blockchain data platforms
- Led small engineering team and delivered developer tooling for smart contract
  ecosystems
{% end %}

{% section() %}
### Erlang Solutions/Kloeckner GmbH - Consultant

<small>Apr 2021 &ndash; Dec 2021</small>

- Optimised database query performance by 15% via PostgreSQL structure analysis
  and improved indices usage
- Prepared company-wide learning materials for PostgreSQL utilisation and
  configuration. Mentored team about their SQL queries
  writing skills
{% end %}

{% section() %}
### Remote.com - Elixir Developer

<small>Oct 2020 &ndash; Apr 2021</small>

- Refactored and fixed multi-currency handling logic within the payment
  processing subsystem, improving correctness and maintainability of currency
  conversion code paths
{% end %}

{% section() %}
### Kobil GmbH - Erlang/Elixir Developer

<small>Mar 2019 &ndash; Sep 2020</small>

- Created Hex-compatible package registry for serving internal packages together
  with HexDocs-compatible documentation viewer
- Migrated build system from Rebar3 to Mix to improve integration with Elixir
  dependencies
- Implemented support for transactions in MongoDB driver for Elixir
- Maintenance of open-source MongoDB driver
{% end %}

{% section() %}
### AppUnite - Full-stack Developer/DevOps

<small>Nov 2016 &ndash; Mar 2019</small>

- 2&times; performance improvement by optimising PostgreSQL usage by reducing
  geo-queries using PostGIS thanks to better indices and materialised views
- Implemented UI and brochure viewer in Vue and SVG
- Architectural redesign and reimplementation of application from Rails/MongoDB
  to Phoenix/PostgreSQL
- Prepared hybrid deployment with on-premise/in-cloud system
- Migrated of the existing deployments from MongoDB to PostgreSQL
- Implemented service to decode Dutch and Belgian postal codes to approximate
  geographical locations
{% end %}

{% section() %}
### Nukomeet - Ruby Developer

<small>Apr 2015 &ndash; Nov 2016</small>

- Maintain and expand conference management and ticketing system for conferences
  organised by the company
{% end %}

{% section() %}
## Selected Projects

- **Ultravisor** (Elixir and Rust) — Ultravisor is a scalable, cloud-native
  Postgres connection pooler. An Ultravisor cluster is capable of proxying
  millions of Postgres end-client connections into a stateful pool of native
  Postgres database connections
- **e9p** (Erlang) — Implementation of 9p filesystem protocol in pure Erlang
- **erlang-systemd** (Erlang) — Integration library between Erlang applications
  and systemd service descriptions
- **mix_unused** (Elixir) — Mix task and compiler hook that locates unused
  public functions in your Elixir projects.
- **dolores** (Rust) - local development proxy with local TLS certificate
  generation and dynamic project registration
{% end %}

## Public Appearances

### Thinking Elixir Episode 149 - *Elixir's Unified Logger*

I have talked about my work to unify Erlang and Elixir loggers. History,
troubles, and new features that were added during that work.

- Thinking Elixir Podcast &middot; May 2023 &middot; Guest

### "config.exs is Simple" and Other Lies

Talk about `config.exs` file in Elixir projects showing how compile-time
configuration intermingles with runtime configuration. My approaches to the
handling systems configuration.

- ElixirConf EU &middot; Jun 2022 &middot; London, UK &middot; Presenter
- Elixir Meetup #2 Curiosum &middot; Feb 2022 &middot; Presenter

### Who Supervises Supervisors?

OTP supervisors allow programmers to write reliable software in occurrence of
errors in our code, but what happens when there is a bug in the OTP itself? Or
in cases when our system becomes unresponsive despite the fact that all
processes are up and running. That is where the system supervisor, like systemd,
comes to play to help operations to keep the application up and running while
being able to reliably observe the state of application.

- Code BEAM V America · Mar 2021 · San Francisco · Presenter · Virtual

## Languages

- Polish - native
- English - full professional
- German - elementary
