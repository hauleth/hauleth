+++
title = "Łukasz Niemier"

[extra]
no_comments = true
sitemap = false
+++

**Email:** <lukasz@niemier.pl>  
**Website:** <https://hauleth.dev>  

**GitHub**: <https://github.com/hauleth>  
**Tangled**: <https://tangled.org/hauleth.dev>  

{% section() %}
## Summary

Principal-level Elixir/Erlang Engineer with 10+ years of experience building
distributed cloud-native platforms and high-performance backend services.
Contributor to Elixir, Erlang/OTP, and Ecto. Specializing in performance
engineering, distributed systems, and fault-tolerant platforms.

**Areas of expertise**:  
Distributed Systems &middot; BEAM/OTP &middot; Performance Engineering &middot; System Architecture &dot; Technical Mentoring
{% end %}

## Technical Skills

**Core Technologies**: Elixir, Erlang/OTP, Phoenix, Ecto, PostgreSQL  
**Additional Experience**: Rust, Terraform, Nomad, Consul, Docker, Nix/NixOS  

{% section() %}
## Open Source & Ecosystem Contributions

- Contributor to Elixir core
- Contributor to Erlang/OTP
- Contributor to Ecto
- Changes accepted across logging, networking, tooling, and language features
- Member of Erlang Ecosystem Foundation Observability Working Group
- Member of OpenTelemetry Erlang Working Group
- Speaker at CodeBEAM V America - *Who supervises supervisors?*
- Speaker at ElixirConf EU 2022 - *"`config.exs` is simple" and Other Lies*
- Guest at Thinking Elixir Episode 149 - *Elixir's Unified Logger*
- *Member of the Year* on Elixir Forum in years 2019&ndash;2025
{% end %}

## Professional Experience

{% section() %}
### DockYard - Consultant

<small>2025</small>

- Architectural analysis of client product codebase with preparation of system
  analysis with detailed report
- Proposed several improvements in areas of security, architecture design, fault
  tolerance, and scalability
{% end %}

{% section() %}
### Supabase - Lead Elixir Developer

<small>2023&ndash;2025</small>

- Redesigned metrics gathering architecture resulting in 10&times; throughput
  improvement and lower infrastructure costs
- Updated used OTP and Elixir versions from OTP 24 to OTP 27 and Elixir from
  1.14 to 1.18
- Reduced usage of mocking in tests to improve tests performance and volatility,
  resulting in reduced CI usage and improved developer experience
- Implemented e2e tests against existing 3rd-party PostgreSQL clients to improve
  platform reliability for external clients
- Led design and implementation of multi-region deployment strategy improving
  platform fault tolerance and availability
- Mentored team about Erlang and Elixir profiling tooling and performance
  analysis for hot code paths
{% end %}

{% section() %}
### Logflare - Senior Elixir Developer

<small>2023</small>

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
{% end %}

{% section() %}
### Eiger - Consultant

<small>2022&ndash;2023</small>

- Implemented Interledger protocol for cross-chain financial transactions
- Led implementation of GraphQL APIs for blockchain data platforms
- Led small engineering team and delivered developer tooling for smart contract
  ecosystems
{% end %}

{% section() %}
### Erlang Solutions/Kloeckner GmbH - Consultant

<small>2021</small>

- Optimised database query performance by 15% via PostgreSQL structure analysis
  and improved indices usage.
- Prepared company-wide learning materials for PostgreSQL utilisation and
  configuration. Mentored team about their SQL queries
writing skills.
{% end %}

{% section() %}
### Kobil GmbH - Erlang/Elixir Consultant

<small>2019&ndash;2020</small>

- Maintenance of open-source MongoDB driver
- Implemented support for transactions in MongoDB driver for Elixir
- Migrated build system from Rebar3 to Mix to improve integration with Elixir
  dependencies
- Created Hex-compatible package registry for serving internal packages together
  with HexDocs-compatible documentation viewer
{% end %}

{% section() %}
### AppUnite - Full-stack Developer/DevOps

<small>2016&ndash;2019</small>

- 2&times; performance improvement by optimising PostgreSQL usage by reducing
  geo-queries using PostGIS thanks to better indices and materialised views
- Implemented UI and brochure viewer in Vue and SVG
- Architectural redesign and reimplementation of application from Rails/MongoDB
  to Phoenix/PostgreSQL
- Prepared hybrid deployment with on-premise/in-cloud system
- Migrated of the existing deployments from MongoDB to PostgreSQL
{% end %}
