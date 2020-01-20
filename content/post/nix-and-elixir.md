---
title: "Nix and Elixir"
date: 2019-12-01T16:43:05+01:00
draft: true
tags:
  - elixir
  - erlang
  - nix
  - programming
---

There is a lot of tools to manage versions of your runtime in Elixir's world,
the common popular choice AFAIK is the ASDF (which I have been using in the past
as well). However recently I have picked up different tool: [Nix][nix].

Nix is the package manager and programming language designed for [NixOS][] which
is Linux-based that do not follow [FHS][]. It is declarative and functional in
it's nature, which provides some interesting properties.

## Nix language

The most important thing in Nix is that it is not only package manager, but also
programming language. This brings enormous possibilities and power to your
environment definitions. However for now let's see at the Nix syntax a little:

```nix
arg: body
```

This is a definition of the function that takes an argument `arg` and has
`body`. All functions in Nix **always** take only one argument, so if you want
to have multi-argument function you need to manually curry it like that:

```nix
a: b: a + b
```

Or you need to use sets, which I will describe soon.

Other basic types in Nix are:

- Integers and floats, denoted in their "regular form" `1` for integer and `1.0`
  for floats
- Booleans - `true` and `false`
- Lists, denoted `[a b]` (no comma needed)
- Strings `"foo"` or `''foo''` (the second form supports multiline strings, like
  Elixir's `sigil_s`), strings can be interpolated in form of `"${foo}"`
- Paths `/foo`, `./foo`, or `<foo>` which are direct aliases to the underlying
  OS paths. The different forms have different meaning:

    + `/foo` mean that this is **absolute** path relative to the root of the
      filesystem
    + `./foo` mean that this is **relative** path relative to the path of
      **current script** (to not confuse with path of the runner)
    + `<foo>` which are paths defined by the `NIX_PATH` environment variable, most
      often used to point to the source of Nix packages (which we will cover
      later)

    In their pure form these are equivalent to strings containing absolute paths,
    but due to their common usage language provides shorthand to use them.

- Sets, which are key-value maps and are denoted as `{ key = value; }`. Sets by
  default aren't recursive which mean that something like:

    ```nix
    {
      a = 10;
      b = a;
    }
    ```

    Will not work, however by using `rec` keyword before set definition we can
    make it recursive, so:

    ```nix
    rec {
      a = 10;
      b = a;
    }
    ```

    Will work as expected

You often will see sets used as an arguments to the functions, so above function
would be in most cases implemented as:

```nix
{ a, b }: a + b
```

Where `{ a, b }` is a pattern matching to extract `a` and `b` from the set. You
can see it as an equivalent to Elixir function in form of:

```elixir
fn %{a: a, b: b} -> a + b end
```

Other very important things in the language are control mechanisms:

- `import path` which will evaluate file stored in `path` and return computed
  value. If `path` is a directory it will instead try to load `path/default.nix`
  file if it exists.
- `with set; body` will make all keys in `set` accessible in `body` without
  prefixing them with `set` (similarly to `import` in Elixir)
- `let name = value in body` will allow to define new variables in the scope of
  `body`
- `inherit name` which is shorthand for `name = name;` inside sets
- `if cond then truthy else falsey`

If you want, you can test it out in REPL that is accessible via `nix repl`:

```nix
nix> 1 + 1
2
nix> 4*5
20
nix> 7-4
3
nix> builtins.div 6 3 # Nix is not general purpose language so / is used for different purposes
2
nix> let foo = "a"; in "\${foo} = ${foo}"
"${foo} = a"
```

One thing to be wary of - dash `-` can be part of the identifier, so this:

```
let
  a = 5;
  b = 3;
in
  a-b;
```

Will not work, you need to write it as `a - b` (spaces around `-` are
important).

---

Above should pretty easily allow you to understand what is happening in below
script:

```nix
{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;

mkShell {
  buildInputs = [ hugo git-lfs yarn ];
}
```

For now just ignore what it does. The only important thing is `...` in the set
pattern matching. In contrast to Elixir, Nix always matches sets exactly, so
this:

```nix
let
  func = {a, b}: a + b
in
  func {a = 1; b = 2; c = 3;}
```

Will fail as there are extra arguments which aren't matched in the pattern.

Additionally `?` means that the argument is optional and the thing on the right
is the default value of the given key.

So step by step:

- This is a function that accepts set as an argument
- Argument set can contain `pkgs` key, if it is not present then it will be set
  to the result of the evaluation of `<nixpkgs>` file with argument `{}` (empty
  set). This is because `import` has higher precedence so this is the same as
  `(import <nixpkgs>) {}`.
- Within body it will import all keys of the `pkgs` set.
- It will call function `mkShell` with set containing one key `buildInputs` that
  is list of `hugo`, `git-lfs`, and `yarn`.

For now this doesn't mean much to us, abut I will try to make it clear later.

Oh, and all of the above is lazy evaluated, so this example:

```nix
let
  failure = builtins.div 4 0;
  good = builtins.div 4 2;
in
  good;
```

Will not fail, as the value of `failure` will never be computed.

## Derivations

Very (most?) important thing in Nix language are special kinds of functions
called derivations. Derivations are **the** raison d'être of the Nix language,
as these are what other package managers would call package definitions.

Derivations are special kind of sets that are stored in `.drv` files which are
"package definition" in the Nix world. These files will contain description how
to build your package from the ground up and store it in the Nix store, which is
by default in `/nix/store` directory.

There is a lot of inner workings how this works, but fortunately we do not need
to deal with all of that, as there is [Nixpkgs][] which is "the standard
library" which contains a lot of utilities for working with Nix and vast set of
derivations (and if you install Nix on your OS then it is automatically
installed as well). One of the most commonly used helpers in the Nixpkgs is the
`mkDerivation` function which simplifies creation of derivations and at the same
time provides set of standard tools for building (like GNU coreutils, GNU Make,
and compiler, GCC or Clang, depending on the OS).

Simple example derivation built with `mkDerivation` is for [encpipe][] tool:

```nix
{ stdenv, git }:

let
  libhydrogen = fetchGit {
    url = "https://github.com/jedisct1/libhydrogen.git";
    ref = "master";
  };
in
  stdenv.mkDerivation rec {
    name = "encpipe-${version}";
    version = "0.5";

    nativeBuildInputs = [ git ];

    preBuild = ''
      cp -R ${libhydrogen}/* ext/libhydrogen/
      '';

    src = fetchGit {
      url = "https://github.com/jedisct1/encpipe.git";
      ref = "master";
    };
  }
```

The idea is pretty simple:

- Fetch `libhydrogen` and `encpipe` via Git (it will be stored in special
  temporary path)
- Before build it copies `libhydrogen` source from that special path to the
  place where `Makefile` of the `encpipe` expects it
- Build package using standard builder (which will run `./configure` if it
  exists and then `make` and `make install`, everything with proper `PREFIX` and
  other flags for installing in proper paths)

You can test this out by saving that file into `encpipe.nix` and then running:

```sh
$ nix-shell -E 'with import <nixpkgs> {}; callPackage ./encpipe.nix {}'
[nix-shell]$ encpipe --help
Usage:
    encpipe -G
    encpipe {-e | -d} {-p <string> | -P <file>} [-i <file>] [-o <file>]

Options:
    -G, --passgen          generate a random password
    -e, --encrypt          encryption mode
    -d, --decrypt          decryption mode
    -p, --pass <password>  use <password>
    -P, --passfile <file>  read password from <file>
    -i, --in <file>        read input from <file>
    -o, --out <file>       write output to <file>
    -h, --help             print this message
```

In this way you ended in new shell, that contains your new `encpipe` command.
What is important is that this command is available only within that shell, just
exit this shell and test for `encpipe --help` and you will see that the command
"vanished". This presents one of the very important feature of the Nix
- profiles. Profile is something like "workspaces" or "sets of packages", and
each profile can contain different versions of the same packages while still
sharing packages themselves between different profiles. In simple words
- profiles are set of symlinks to the different packages.

## `nix-shell`

`nix-shell` command is a tool to create temporary profile that will contain
defined set of the packages. You can use it to test out commands when needed or
to build working environments that will not interfere with "main" system. For
example imagine that we already installed Nix on our system, but we do not have
`mix` available globally. We can start new project via:

```sh
$ nix-shell -p elixir
[nix-shell]$ mix new my_project
[nix-shell]$ cd project
```

Here you are in Bash shell that have Elixir and Erlang installed, but the funny
thing, as we didn't defined Erlang as a direct dependency of your shell, we
cannot access it directly:

```sh
[nix-shell]$ erl
erl: command not found
```

While we still have full access to Elixir:

```sh
[nix-shell]$ iex
iex(1)>
```

If you want more packages to be available within your shell you can add them to
the command line:

```sh
$ nix-shell -p elixir -p neovim
```

However at some point it can become tedious to write all these packages in the
CLI. So instead of passing them always in the shell we can create file
`shell.nix` that will contain derivation used for working in shell:

```nix
{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;

mkShell {
  buildImputs = [ elixir neovim ];
}
```

And now using simply `nix-shell` will create our shell with all packages needed.
This especially useful when our shell definition will grow in time and will
contain more logic (like for example `nixpkgs` version pinning, which we will
cover later).

## Direnv

[`direnv`][direnv] is a simple shell tool that allows running custom commands
and setting environment variables in per-directory fashion. One of the important
features is that it comes out with native support for Nix. With this tool we
will be able to automatically enter shell as soon as we enter the directory.
Just follow the installation instruction on the web page to install it, and then
create `.envrc` in directory with `shell.nix` that will contain:

```sh
use nix
```

And then allow it to be ran:

```sh
direnv allow
```

And now correct `$PATH` and other variables will be available for you as soon as
you will enter the project directory.

[nix]: https://nixos.org/nix
[NixOS]: https://nixos.org/nixos
[FSH]: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard "File Hierarchy Standard"
[Nixpkgs]: https://nixos.org/nixpkgs
[encpipe]: https://github.com/jedisct1/encpipe
[direnv]: https://direnv.net
