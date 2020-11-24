+++
title = "Dumb Elixir VIsual (and iMproved) editor"
description = "How I have configured Vim for working with Elixir and Erlang projects"
date = 2019-04-13T21:40:05+02:00

[taxonomies]
tags = [
  "elixir",
  "erlang",
  "vim",
  "neovim",
  "programming"
]
+++

> Earlier published on [Medium](https://medium.com/@hauleth/dumb-elixir-visual-and-improved-editor-53c23a0800e4)

![My example session in NeoVim with QuickFix displaying Credo warnings](/img/vim-session.png)

I am quite orthodox Vim user and I like to know everything that is happening in
my editor configuration. By no means I am "minimal" Vim user, I currently have
48 plugins installed, I just very carefully pick my plugins (few of them I have
written myself) to use only plugins that I understand and I can fix on my own in
case of problems. This results with configuration I understand and control in
all means.

## What this article is not

This isn't "introduction into Vim" article neither "how to configure Vim for
Elixir development". Here I will try to describe how I use Vim for Elixir and
Erlang development, you can find some nice ideas and tips that may help you, but
by any means I do not mean that this is configuration you should or should not
use. You should use whatever you like (even if I do not like what you use) as
long as you understand what you use and why you use that.

> *Any sufficiently complicated set of Vim plugins contains an ad hoc,
> informally-specified, bug-ridden, slow implementation of half of Vim's
> features.*
> -- robertmeta's tenth rule.

Now we can start.

## Basics

I am using NeoVim 0.3.4, but almost everything I will describe there should work
in Vim 8.1+ as well. If you will encounter any problems, then please let me
know.

Vim doesn't (as 13.04.2019) support Elixir out of the box, so what we
need is to install [`vim-elixir`][] plugin which will provide niceties like syntax
colouring and indentation. Even if syntax colouring isn't your thing then I
would still recommend installing it as it provides other things that it provides
few other niceties that I will describe later.

But how to install it? In truly minimal setup you can just create
`pack/elixir/start` directory within your `~/.vim` folder
(`$XDG_CONFIG_DIR/nvim` in case of NeoVim) and clone given repository there,
however I am using [`vim-packager`][] which is based on [`minpac`][] and is
truly minimal package manager (it is important distinction from [`vim-plug`][]
or others that also manages plugin loading, these plugins only manage fetching)
which even do not need to be loaded during "normal" runtime, only when you are
updating plugins.

## Project navigation

A lot of people, when come from other editors, often install NERDTree to have
"project drawer" functionality within Vim, because this is what they are used
to. Unfortunately "[split windows and the project drawer go together like oil
and vinegar][oil-and-vinegar]" and it can result in painful experience or, which
is even worse, avoiding built in functionalities, because these do not mix well.
Vim comes with built in NetRW plugin for working with remote files and directory
tries. However for me this plugin is bloated as well and I would love to get rid
of it (unfortunately it is not currently possible as few functionalities relies
on it, namely dictionaries) so I replaced everything with [`dirvish`][].
Additionally I often use fuzzy finder, which in my case is [`vim-picker`][] with
[`fzy`][] which for me is much faster and more precise than popular FZF.

These tools are great when we are navigating in tree that is new to us or do not
have explicit structure. When we are working on Elixir projects then we know
before hand that there will be some commonly shared structure, like
`lib/<name>.ex` will contain source code, `test/<name>_test.exs` will contain
test files, etc. What is more we know that `<name>` part will be shared between
file and its unit tests. This is very powerful assumption, as this allow us to
use [`vim-projectionist`][] with ease. This plugin provide 3 main
functionalities (for me):

- Jumping to the files basing on their path, so for example I can use `:Elib
  foo` to automatically jump to file `lib/foo.ex`. It doesn't seems like much,
  but it also provides fuzzy finding, and allows me to define more specific
  matches, like `:Econtroller foo` will open
  `lib/app_web/controllers/foo_controller.ex` (not exactly that as I use
  different project layout, but that is topic on another article).
- File templates, so when I start editing file (doesn't matter how I opened it,
  so this do not require to use above `:Elib` command), so when I start editing
  test file it automatically add scaffold which I can configure per project.
- Alternate files which in short are "related" files. For example when I edit
  file `lib/foo/bar/baz.ex` and I run `:A` it will create (if not exist) and
  jump to the file `test/foo/bar/baz_test.exs` which will be already scaffolded
  by the earlier functionality. Recently it even became possible to have
  multiple alternates.

Whole plugin is configured by `.projections.json` file, but it would be
infeasible to add this file to each project you work for. Fortunately there is
solution for that, we can define "heuristics" that will try to match for given
project structure and provide such features "globally". My configuration for
that looks like this:

```vim
let g:projectionist_heuristics['mix.exs'] = {
            \ 'apps/*/mix.exs': { 'type': 'app' },
            \ 'lib/*.ex': {
            \   'type': 'lib',
            \   'alternate': 'test/{}_test.exs',
            \   'template': ['defmodule {camelcase|capitalize|dot} do', 'end'],
            \ },
            \ 'test/*_test.exs': {
            \   'type': 'test',
            \   'alternate': 'lib/{}.ex',
            \   'template': [
            \       'defmodule {camelcase|capitalize|dot}Test do',
            \       '  use ExUnit.Case',
            \       '',
            \       '  alias {camelcase|capitalize|dot}, as: Subject',
            \       '',
            \       '  doctest Subject',
            \       'end'
            \   ],
            \ },
            \ 'mix.exs': { 'type': 'mix' },
            \ 'config/*.exs': { 'type': 'config' },
            \ '*.ex': {
            \   'makery': {
            \     'lint': { 'compiler': 'credo' },
            \     'test': { 'compiler': 'exunit' },
            \     'build': { 'compiler': 'mix' }
            \   }
            \ },
            \ '*.exs': {
            \   'makery': {
            \     'lint': { 'compiler': 'credo' },
            \     'test': { 'compiler': 'exunit' },
            \     'build': { 'compiler': 'mix' }
            \   }
            \ }
            \ }

let g:projectionist_heuristics['rebar.config'] = {
            \ '*.erl': {
            \   'template': ['-module({basename}).', '', '-export([]).', ''],
            \ },
            \ 'src/*.app.src': { 'type': 'app' },
            \ 'src/*.erl': {
            \   'type': 'src',
            \   'alternate': 'test/{}_SUITE.erl',
            \ },
            \ 'test/*_SUITE.erl': {
            \   'type': 'test',
            \   'alternate': 'src/{}.erl',
            \ },
            \ 'rebar.config': { 'type': 'rebar' }
            \ }
```

### This will provide:

#### For Elixir:

- `lib` that will contain project source files which will be already filled with
  module named `Foo.BarBaz` for file named `lib/foo/bar_baz.ex` (jump by `:Elib
  foo/bar_baz`)
- `test` for test files which will be instantiated with module named
  `Foo.BarBazTest` for file `test/foo/bar_baz_test.exs` that will already use
  `ExUnit.Case` (you can jump via `:Etest foo/bar_baz`), will define
  `alias Foo.BarBaz, as: Subject`, and will run doctests for that module
- `config` for configuration files
- `mix` for `mix.exs`

It will also define test files as default alternates for each source file (and
vice versa, because alternate files do not need to be symmetric), so if you
run `:A` in file `lib/foo/bar_baz.ex` it will automatically jump to the
`test/foo/bar_baz_test.exs`.

#### For Erlang:

- `src` for source files
- `app` for `*.app.src` files
- `test` for common test suites
- `rebar` for `rebar.config` file

The relation between source files and test files is exactly the same as in
Elixir projects.

One thing can bring your attention, why the hell I define helpers for `mix.exs`
and `rebar.config` as you can simply use `:e <file>`. The answer is simple, `:e`
will work for files in Vim working directory while `:E` will work form the
projectionist root, aka directory where is `.projections.json` file defined (or
in case of heuristics, from the directory that matched files). This mean that
when I edit files in umbrella application I can use `:Emix` (or `:Erebar`) to
edit current sub-project config file and `:e mix.exs` to edit global one.

## Completion and language server

For completion and code formatting I use [`vim-lsp`][]. I have tried most of the
language server clients out there, but I always come back to this one for a few
reasons:

- It is implemented only in VimL which mean that I am not forced to installing
  any compatibility layers or fighting with different runtimes.
- It is simple enough that I can easily dig into it, and fix problems that I
  have encountered.
- It doesn't override any built in Vim functionality and instead provide set of
  commands that you can then bind to whatever mappings you want.
- It do not force me to use autocompletion, which I do not use at all. At the
  same time it provides seamless integration with built-in Vim functionality of
  omnicompletion and user completion by providing `lsp#complete` function.

This approach of not providing default mappings is really nice for power users,
as this allow us to define everything on our own. For example some of plugins
use <kbd>&lt;C-]&gt;</kbd> for jumping to definition, which I often use (it is
jump to tag definition) and shadowing it would be problematic for me. So in the
end I have created my own set of mappings, that have additional feature of being
present only if there is any server that supports them:

```vim
func! s:setup_ls(...) abort
    let l:servers = lsp#get_whitelisted_servers()

    for l:server in l:servers
        let l:cap = lsp#get_server_capabilities(l:server)

        if has_key(l:cap, 'completionProvider')
            setlocal omnifunc=lsp#complete
        endif

        if has_key(l:cap, 'hoverProvider')
            setlocal keywordprg=:LspHover
        endif

        if has_key(l:cap, 'definitionProvider')
            nmap <silent> <buffer> gd <plug>(lsp-definition)
        endif

        if has_key(l:cap, 'referencesProvider')
            nmap <silent> <buffer> gr <plug>(lsp-references)
        endif
    endfor
endfunc

augroup LSC
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'ElixirLS',
                \ 'cmd': {_->['elixir-ls']},
                \ 'whitelist': ['elixir', 'eelixir']
                \})
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'RLS',
                \ 'cmd': {_->['rls']},
                \ 'whitelist': ['rust']
                \})
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'solargraph',
                \ 'cmd': {server_info->['solargraph', 'stdio']},
                \ 'initialization_options': {"diagnostics": "true"},
                \ 'whitelist': ['ruby'],
                \ })
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'dot',
                \ 'cmd': {server_info->['dot-language-server', '--stdio']},
                \ 'whitelist': ['dot'],
                \ })

    autocmd User lsp_server_init call <SID>setup_ls()
    autocmd BufEnter * call <SID>setup_ls()
augroup END
```

## Running tasks and linting

A lot of people "cannot live" without lint-as-you-type feature, but I think,
that not using such functionality makes me a less sloppy and better programmer.
It makes me to think when I write and do not rely on some magical friend that
will always watch over my shoulder. However when the problem happens in my code
I would like to know where and quickly jump to the place where error occurred.
Additionally I would like to run tasks in the background without interruption to
my current work. All of it became possible with introduction of asynchronous
tasks in NeoVim and Vim 8. So I have created plugin [`asyncdo.vim`][] that
allows me to easily implement `:Make` command that works exactly like built
in [`:make`][], but do not halt my normal work. Together with [`vim-makery`][]
(which nicely integrates with `vim-projectionsit`) and built in functionality of
[`:compiler`][], which is supported by `vim-elixir`, it allows me to easily run all
sorts of commands very easily. If you look into projectionist heuristics above
you will see that there is `"makery"` key defined for `*.ex` and `*.exs` files.
That allows me to run `:Mlint %` to run Credo on current file and the results
will be present within QuickFix window which together with my [`qfx.vim`][] will
mark lines with errors using signs. In the same manner I can run `:Mtest` to run
tests for whole project and have failed tasks visible in QuickFix window.

## Other utilities

There is bunch of other plugins that are quite helpful when it comes to working
on Elixir projects and do not interfere with Vim features, ex.:

- [`vim-dadbod`][] which allows you to run SQL queries from within Vim, and [I
  have written integration with Ecto][ecto-dadbod] which is provided with
  `vim-elixir` by default. So if you are working on Elixir application that has
  `MyApp.Repo` Ecto repository then you can run `:DB MyApp.Repo` and Vim will
  open your DB client within separate terminal that will be connected to your DB
- [`vim-endwise`][] that will automatically add end to your do blocks
- [`direnv.vim`][] simplify management of environment variables in per-directory
  manner
- [`vim-editorconfig`][] ([sgur][]'s one, not official one) - pure VimL support
  for [EditorConfig][] files

## Summary

I hope that you find some nice ideas within this article that will help in
improving your own Vim configuration without adding much clutter.

No, I will not publish my own `vimrc` in fear that some of you will copy it as
is (also not that this is particularly troublesome for anyone who is aware of
Google to find it). Instead I highly suggest You to dig into your own
configuration and for each line ask yourself:


- Do I know what this line **does**?
- Do I really **need** this line?

And if answer for any of these questions is **no** then remove such line. In the
end you either learn what for it was, or that you never needed it.

[`dirvish`]: https://github.com/justinmk/vim-dirvish
[oil-and-vinegar]: http://vimcasts.org/blog/2013/01/oil-and-vinegar-split-windows-and-project-drawer/
[`vim-elixir`]: https://github.com/elixir-editors/vim-elixir
[`vim-packager`]: https://github.com/kristijanhusak/vim-packager
[`minpac`]: https://github.com/k-takata/minpac
[`vim-plug`]: https://github.com/junegunn/vim-plug
[`vim-picker`]: https://github.com/srstevenson/vim-picker
[`fzy`]: https://github.com/jhawthorn/fzy
[`vim-projectionist`]: https://github.com/tpope/vim-projectionist
[`vim-lsp`]: https://github.com/prabirshrestha/vim-lsp
[`asyncdo.vim`]: https://github.com/hauleth/asyncdo.vim
[`vim-makery`]: https://github.com/igemnace/vim-makery
[`qfx.vim`]: https://gitlab.com/hauleth/qfx.vim
[`vim-dadbod`]: https://github.com/tpope/vim-dadbod
[`vim-endwise`]: https://github.com/tpope/vim-endwise
[`direnv.vim`]: https://github.com/direnv/direnv.vim
[`vim-editorconfig`]: https://github.com/sgur/vim-editorconfig
[sgur]: https://github.com/sgur
[ecto-dadbod]: https://github.com/elixir-editors/vim-elixir/pull/481
[EditorConfig]: https://editorconfig.org
[`:make`]: https://vimhelp.org/quickfix.txt.html#%3Amake
[`:compiler`]: https://vimhelp.org/quickfix.txt.html#%3Acompiler
