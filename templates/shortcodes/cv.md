# Łukasz Jan Niemier

## Personal information

Email:
  <~@hauleth.dev>

Website:
  <https://hauleth.dev>

Twitter:
  [@hauleth](https://twitter.com/hauleth)

## Education

- Poznań University of Technology: Computer Science - no degree - 2012-2015
    + Secretary of AKAI - Students' Association of Web Developers

## Experience

- Hauleth.dev - Consultant - 2021+
    + DockYard/Karambit.ai - 2025
        * Architectural analysis of Karambit product
        * Prepared security analysis with detailed report with fixes
    + Eiger - 2022-2023
        * Forte.io
            - Implemented Interledger protocol for cross-chain transactions
        * Aleo Blockchain
            - Implemented GraphQL API for the on-chain data
            - Created syntax colouring library for Aleo assembly-like language
              for smart contracts
    + Erlang Solutions/Kloeckner GmbH - 2021 - Consultant for Elixir, Ruby,
      and SQL (PostgreSQL)
        * Optimised DB query performance by providing PostgreSQL structure
          analysis and improving indices usage
    + Remote Inc. - Senior Backend Engineer - 2020-2021
        * Architectural analysis of existing codebase
    + Kobil GmbH - Erlang/Elixir Developer - 2019-2020
        * Maintained MongoDB driver for Elixir
        * Implemented transactions for MongoDB driver in Elixir
- Supabase - 2023-2025
    + Logflare - logs aggregation service:
        * Implemented on-the-fly decompression of incoming data that improved
          ingestion possibilities and reduced transfer usage (created library
          [`plug_caisson`][] for that purpose)
        * Implemented DataDog-compatible ingestion endpoint for seamless
          transition from DataDog provider to Logflare
        * Improved BigQuery pipeline workflow to reduce congestion on database
          connections
        * Added support for AWS Cloud Events metadata extraction
        * Improved CI usage by splitting different actions to separate steps ran
          in parallel
        * Replaced dynamic generation of connection modules for PostgreSQL
          storage system with Ecto's dynamic repositories to avoid atom exhaustion
    + Supavisor - a cloud-native, multi-tenant Postgres connection pooler
        * Deployment management
        * Optimised metrics gathering system that resulted in an order of
          magnitude performance boost
        * Updated used OTP and Elixir versions from OTP 24 to OTP 27 and Elixir
          from 1.14 to 1.18
        * Reduced usage of mocking in tests to improve tests performance and
          volatility, resulting in reduced CI usage and improved developer
          experience
        * Implemented e2e tests against existing Node.js PostgreSQL clients to
          improve production issues
        * Implemented multi-region deployment system to provide blue/green
          deployments
        * Improved system observability features by making it more resilient and
          performant
        * Replaced usage of `ct_slave` with newer `peer` module in OTP
- AppUnite - Full-stack Developer/DevOps - 2016-2019:
    + JaFolders/AlleFolders
        * 2x performance improvement by optimising PostgreSQL usage
        * Reduced geo-queries using PostGIS thanks to better indices and
          materialised views usage
        * Implemented UI and brochure viewer in Vue and SVG
    + OneMedical/Helium Health
        * Architectural redesign of application from Rails/MongoDB to
          Phoenix/PostgreSQL
        * Prepared hybrid deployment with on-premise/in-cloud system
        * Migrated of the existing deployments from MongoDB to PostgreSQL
- Nukomeet - Full-stack Developer - 2015-2016
- Prograils - Junior Developer - 2013

### Organisations

- Erlang Ecosystem Foundation - member of the Observability WG
- OpenTelemetry Project - member of the Erlang WG

### Other fields

- Volunteer:
    + Pyrkon Fan Convention
        * Helper - 2011, 2012, 2013, 2014, 2016
        * Organizer - 2015
    + UEFA Championship 2012 - Poland-Ukraine
        * ICT Accreditation support
- Times Person of the Year - 2006

### Languages

- Polish - mother tongue
- English - fluent

### Showcase

- GitHub: <https://github.com/hauleth>
- GitLab: <https://gitlab.com/hauleth>
- SourceHut: <https://sr.ht/~hauleth>
- StackOverflow: <https://stackoverflow.com/u/1017941>

### Notable contributions

- Elixir language:
    + Logger reimplementation on top of Erlang's `logger` module
    + `mix test --cover` CLI output
    + Support for `NO_COLOR` environment variable
    + `is_struct/1`
    + Fixing module inspection on case-insensitive file systems
    + Support for parsing extra arguments via `mix eval` and `eval` command in
      release
- Erlang OTP:
    + Support for custom devices in `logger_std_h`
    + Fixing `socket` module to support broader set of protocols (for example
      ICMP)
    + Support for global metadata in `logger`
    + Support for reconfiguration of `logger` (needed for better Mix and Rebar3
      integration)
    + Several fixes to `logger` and `socket` modules
    + Add support for τ constant in `math`
- Git:
    + Add support for Elixir in diff
- Ecto:
    + Support aggregations over `*`
    + Better error on duplicated `schema` block
- Elixir MongoDB driver
    + Support for transactions

### Notable projects

- <https://github.com/hauleth/erlang-systemd> - systemd integration for Erlang
  projects
- <https://github.com/hauleth/mix_unused> - Mix compiler for detecting unused
  code
- <https://github.com/open-telemetry/opentelemetry-erlang> - maintainer of
  the Erlang's OpenTelemetry implementation
- Vim plugins:
    + <https://github.com/hauleth/asyncdo.vim> - simple asynchronous task runner
    + <https://github.com/hauleth/sad.vim> - search and replace text - faster
    + <https://gitlab.com/hauleth/qfx.vim> - display signs next to QF matches

### Languages and Frameworks

- Elixir
    + Phoenix
    + Ecto
- Erlang
    + OpenTelemetry collaborator
    + EEF Member
    + OTP contributor
- Nix/NixOS
- Rust
- PostgreSQL
- sh/Bash
- Ruby
    + Ruby on Rails

### Technologies

- Git
- Vim
- HashiStack
    + Terraform
    + Consul
    + Nomad
- GNU/Linux and other UNIX-like systems
- TDD/BDD methodologies
- Property testing

## Other

- Viking reenactor
- Keyboard fan
- Sci-fi/Fantasy fan and Poznań's Sci-fi/Fantasy club member

[`plug_caisson`]: https://github.com/supabase/plug_caisson
