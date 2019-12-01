---
title: "Libless Elixir: Phoenix Authorization"
date: 2019-11-28T22:48:19+01:00
tags:
  - elixir
  - programming
  - phoenix
  - libless
draft: true
---

One of the most "requested" library for the Phoenix applications is
authorization library. Of course there exist some of such, but in this article
we will try to write such feature while using as little external libraries as
possible (and no "authorization frameworks").

## Requirements

Stuff that is needed for secure authorization in any web application:

- User need to know 2 pieces:
  + email
  + password
- Session management
- Password should be stored in hashed form that is secure for password storing
  (so no general-use cryptographic hashes like SHA or BLAKE)
- [No JWT][]

In this article I will not describe how to prevent brute-force attacks or how to
implement 2FA. The second one maybe will be covered in future articles.

## Used libraries

- `phoenix`
- `comeonin`
- `ecto_sql`

## Implementation

### Session

`Plug` (which is hard requirement for Phoenix) already supports session
management via [`Plug.Session`](https://hexdocs.pm/plug/1.8.3/Plug.Session.html),
which is pluggable API to store session data in different stores. By default
Plug provides 2 super-simple and super-basic implementations:

- [`Plug.Session.ETS`](https://hexdocs.pm/plug/1.8.3/Plug.Session.ETS.html) - in
  memory store that should not be used if the application is deployed to more
  than one machine, as the state will be available only on one of them.
- [`Plug.Session.COOKIE`](https://hexdocs.pm/plug/1.8.3/Plug.Session.COOKIE.html) -
  which stores session data directly in encrypted and signed cookie, but if you
  want to store more data in such cookie, then it is not recommended as it will
  bloat all the requests.

On Hex you can easily find other stores like:

- [`plug_session_mnesia`](https://hex.pm/packages/plug_session_mnesia) that uses
  [Mnesia](http://www.erlang.org/doc/man/mnesia.html) database which is part of
  the OTP.
- [`plug_session_redis_store`](https://hex.pm/packages/plug_session_redis_store)
  which offers storing session data in Redis
- [`plug_session_memcached`](https://hex.pm/packages/plug_session_memcached) -
  as above, but uses Memcached instead of Redis

However in this article we use neither, and instead we will implement our own
session store that will use Ecto.

### Passwords

[Comeonin](https://github.com/riverrun/comeonin) is a simple interface for
hashing passwords in secure way. It also provides some implementations of the
proven to be safe password based key derivation functions (PBKDF). Here we will
use Argon2 implementation which is currently considered as a state-of-art PBKDF
function which you should also use if possible.

Interface is pretty simple:

- `add_hash/1` will generate map `%{password_hash: hash, password: nil}`
- `check_pass/2` will check if `password_hash` field of the map passed as a
  first argument match password passed as a second one, if the 1st argument is
  `nil` then it will fake password check to prevent timing-attacks

### Plugging everything together

Let's create new scope `Users` in our application:

```elixir
defmodule AcmeApp.Users do
  alias AcmeApp.Users.User
  alias AcmeApp.Repo

  @doc """
  Create new account
  """
  @spec register(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register(data) do
    data
    |> User.register_changeset()
    |> Repo.insert()
  end

  @doc """
  Sign in user
  """
  @spec sign_in(binary(), binary()) :: {:ok, User.t()} | :error
  def sign_in(email, password) do
    User
    |> Repo.get_by(email: email)
    |> Argon2.check_pass(password)
  end
end
```

This module should be simple enough. 2 functions, one create account, second
will try ti sign in user with given credentials. It is worth noticing, that
`sign_in/2` function returns only vague `:error` as you should **never** inform
user which one of the credentials was incorrect as this can allow attacker to
gain some informations about your users.

Where `AcmeApp.Users.User` schema looks like:

```elixir
defmodule AcmeApp.Users.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :email, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    field :password_hash, :string
  end

  def register_changeset(changes) do
    %__MODULE__{}
    |> cast(changes, ~w[email password password_confirmation]a)
    |> validate_required(~w[email password]a)
    # Passwords with less than 8 characters for sure aren't secure enough
    |> validate_length(:password, min: 8)
    # Force user to type password twice
    |> validate_confirmation(:password)
    # Simplest, and most correct way to prevent simple mistakes
    # in email addresses
    |> validate_format(:email, ~r/[^@]@[^@]/)
    |> hash_password()
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> change(changeset, Argon2.add_hash(password))
    end
  end
end
```

This one should be pretty obvious as well. Just one change function that should
be pretty simple for anyone that have at leas read `Ecto.Schema` and
`Ecto.Changeset` docs.

Migration contain no magic as well:

```elixir
defmodule AcmeApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, null: false
    end

    create index(:users, [:email], using: :hash)
  end
end
```

Index is useful, as will greatly improve the lookup for users via email.

[No JWT]: http://cryto.net/~joepie91/blog/2016/06/13/stop-using-jwt-for-sessions/
