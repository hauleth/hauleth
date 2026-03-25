+++
title = "Łukasz Niemier"

[extra]
no_comments = true
sitemap = false
+++

**Email:** <lukasz@niemier.pl>  
**Website:** <https://hauleth.dev>  

**GitHub**: <https://github.com/hauleth>  
**Tangled**: <https://tangled.com/@hauleth.dev>  
**StackOverflow**: <https://stackoverflow.com/u/1017941>  

## Technical Skills

**Languages & Frameworks**: Elixir, Erlang (OTP), Rust, PostgreSQL, Ruby on Rails, Bash, Nix/NixOS  
**Tools & Technologies**: Git, Terraform, Consul, Nomad, Docker, GNU/Linux  

## Notable contributions

- Elixir - logger reimplementation on top of Erlang's `logger` module, `mix test
  --cover` CLI output,  Support for `NO_COLOR` environment variable, add
  `is_struct/1` guard, fix module inspection on case-insensitive file systems,
  support for parsing extra arguments via `mix eval` and `eval` command in
  release
- Erlang OTP - add support broader set of protocols in `socket` module, support
  for custom devices in `logger_std_h`, support for global metadata in `logger`,
  support for reconfiguration of `logger` (needed for better Mix and Rebar3
  integration)
- Ecto - support aggregations over `*`, better error on duplicated `schema` block

## Professional Experience

{% section() %}
### DockYard - Consultant

<small>2025</small>

Architectural analysis of client product codebase with preparation of security
analysis with detailed report with proposed solutions
{% end %}

{% section() %}
### Supabase Supavisor - Lead Elixir Developer

<small>2023&ndash;2025</small>

- Optimised metrics gathering system that resulted in an order of
  magnitude performance boost
- Updated used OTP and Elixir versions from OTP 24 to OTP 27 and Elixir
  from 1.14 to 1.18
- Reduced usage of mocking in tests to improve tests performance and
  volatility, resulting in reduced CI usage and improved developer
  experience
- Implemented e2e tests against existing Node.js PostgreSQL clients to
  improve production issues
- Implemented multi-region deployment system to provide blue/green
  deployments
- Replaced usage of `ct_slave` with newer `peer` module in OTP
{% end %}

{% section() %}
### Supabase Logflare - Senior Elixir Developer

<small>2023</small>

- Implemented on-the-fly decompression of incoming data that improved
  ingestion possibilities and reduced transfer usage
- Implemented DataDog-compatible ingestion endpoint for seamless
  transition from DataDog provider to Logflare
- Improved BigQuery pipeline workflow to reduce congestion on database
  connections
- Added support for AWS Cloud Events metadata extraction
- Improved CI usage by splitting different actions to separate steps ran
  in parallel
- Replaced dynamic generation of connection modules for PostgreSQL
  storage system with Ecto's dynamic repositories to avoid atom exhaustion
{% end %}

{% section() %}
### Eiger - Consultant

<small>2022&ndash;2023</small>

- **Forte.io** - implemented Interledger protocol for cross-chain transactions
- **Aleo Blockchain** - implemented GraphQL API for the on-chain data; created
  syntax colouring library for Aleo assembly-like language for smart contracts
{% end %}

{% section() %}
### Erlang Solutions/Kloeckner GmbH - Consultant

<small>2021</small>

Optimised DB query performance by providing PostgreSQL structure analysis and
improving indices usage
{% end %}

{% section() %}
### Remote Inc. - Consultant

<small>2020&ndash;2021</small>
{% end %}

{% section() %}
### Kobil GmbH - Erlang/Elixir Consultant

<small>2019&ndash;2020</small>

Implementation of transactions in MongoDB driver for Elixir
{% end %}

{% section() %}
### AppUnite - Full-stack Developer/DevOps

<small>2016&ndash;2019</small>

- **JaFolders/AlleFolders** - 2&times; performance improvement by optimising
  PostgreSQL usage by reducing geo-queries using PostGIS thanks to better
  indices and materialised views; implemented UI and brochure viewer in Vue and
  SVG
- **OneMedical/Helium Health** - architectural redesign and reimplementation of
  application from Rails/MongoDB to Phoenix/PostgreSQL; prepared hybrid
  deployment with on-premise/in-cloud system; migrated of the existing
  deployments from MongoDB to PostgreSQL
{% end %}
