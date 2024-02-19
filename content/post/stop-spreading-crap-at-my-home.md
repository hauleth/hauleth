+++
title = "Stop Spreading Crap at My `$HOME`"
date = 2020-04-15T12:00:19+02:00

[taxonomies]
tags = [
  "culture"
]
+++

**Disclaimer:** Yes, this is a rant. Yes, I am displeased with state of
software. And yes, I can use some harsh words. You were warned.

For a some time now we have [Filesystem Hierarchy Standard][fhs] which describes
which data goes where in your \*nix installation. In fact we have that for 28
years, which is almost as long as I live. This is quite some time. But for
whatever reason we apply that only for the system hierarchy and we cannot have
the same for something much closer to our heart - our dear `$HOME`.

Common practice for storing all the stuff for different applications is to use
dot files stored in `$HOME`. These are files or directories starting with dot in
their name which makes such files "hidden" on Unix systems. There is problem
though. First let me show you all the files starting with dot in my `$HOME`:

```
-r--------  1 hauleth staff     9 Mar 30  2019 .CFUserTextEncoding
-rw-r--r--  1 hauleth staff 16388 Apr  9 11:46 .DS_Store
drwx------  2 hauleth staff    64 Apr 13 20:54 .Trash
-rw-------  1 hauleth staff 17835 Apr 10 21:17 .bash_history
drwx------ 12 hauleth staff   384 Mar 30  2019 .bash_sessions
drwxr-xr-x 13 hauleth staff   416 Mar 26 14:02 .cache
lrwxr-xr-x  1 hauleth staff    40 Aug 21  2019 .chunkwmrc
drwxr-xr-x 20 hauleth staff   640 Apr 15 21:59 .config
drwx------  3 hauleth staff    96 Apr 20  2019 .cups
lrwxr-xr-x  1 hauleth staff    39 Aug 21  2019 .curlrc
lrwxr-xr-x  1 hauleth staff    43 Aug 21  2019 .dir_colors
-rw-r--r--  1 hauleth staff  2587 Sep 10  2019 .direnvrc
drwxr-xr-x  6 hauleth staff   192 Apr 14 18:27 .docker
drwx------ 14 hauleth staff   448 Oct  1  2019 .dropbox
-r--------  1 hauleth staff    20 Apr  1  2019 .erlang.cookie
drwxr-xr-x  3 hauleth staff    96 Jul  1  2019 .gem
-rw-r--r--  1 hauleth staff   518 Mar 25 22:44 .gitconfig
drwx------ 14 hauleth staff   448 Apr 15 22:03 .gnupg
drwxr-xr-x  4 hauleth staff   128 Apr  2  2019 .hammerspoon
drwxr-xr-x  5 hauleth staff   160 Apr 14 19:39 .hex
drwx------  3 hauleth staff    96 Apr 26  2019 .httpie
-rw-r--r--  1 hauleth staff   165 Feb 22 13:50 .jlassetregistry.json
drwxr-xr-x  3 hauleth staff    96 Nov 29 22:13 .jssc
drwxr-xr-x  9 hauleth staff   288 Feb 21 17:46 .julia
drwx------ 14 hauleth staff   448 Oct  2  2019 .keychain
drwxr-x---  5 hauleth staff   160 Jan 24 12:20 .kube
-rw-------  1 hauleth staff   720 Apr 15 16:29 .lesshst
drwxr-x---  3 root    staff    96 Apr  3  2019 .lldb
drwx------  4 hauleth staff   128 Dec 18 14:16 .local
drwxr-xr-x  8 hauleth staff   256 Mar 20 12:29 .mitmproxy
drwxr-xr-x 18 hauleth staff   576 Apr 13 14:36 .mix
-rw-r--r--  1 hauleth staff   116 Apr 13 20:59 .nix-channels
drwxr-xr-x  4 hauleth staff   128 Apr 14 13:47 .nix-defexpr
lrwxr-xr-x  1 hauleth staff    46 Feb  1 22:13 .nix-profile
drwxr-xr-x  3 hauleth staff    96 Sep 27  2019 .npm
drwxr-xr-x  3 hauleth staff    96 Dec 19 14:05 .pex
-rw-r--r--  1 hauleth staff   183 May  2  2019 .profile
drwxr-xr-x  5 hauleth staff   160 Mar 20 16:27 .proxyman
drwxr-xr-x  2 hauleth staff    64 Feb 17 14:09 .proxyman-data
-rw-------  1 hauleth staff  1391 Jan 22 11:46 .psql_history
-rw-------  1 hauleth staff  1950 Feb 19 12:42 .python_history
lrwxr-xr-x  1 hauleth staff    37 Aug 21  2019 .skhdrc
drwx------ 11 hauleth staff   352 Oct  2  2019 .ssh
drwxr-xr-x  4 hauleth staff   128 May  8  2019 .terraform.d
drwxr-xr-x  4 hauleth staff   128 Dec  1 21:52 .thumbnails
drwxr-xr-x  9 hauleth staff   288 Mar  9 17:14 .vagrant.d
-rw-------  1 hauleth staff 11124 Apr 13 20:21 .viminfo
lrwxr-xr-x  1 hauleth staff    37 Aug 21  2019 .vimrc
drwx------  4 hauleth staff   128 Nov  8 16:51 .w3m
drwxr-xr-x 37 hauleth staff  1184 Apr 13 21:21 .weechat
```

As you can see, there is bunch of them, some are linked to my dotfiles
repository, but most are not. What is the problem there?

The spread.

All of the data is smeared between gazillion of different filed with different
types of data. This causes headaches because:

- I cannot easily backup all the configuration as I need to check each file
  independently to check if this is configuration file or it is data
- I cannot exclude data from my backups in a uniform way. I need to check each
  file independently and exclude it, remembering to do that for each new tool
  that I add. Alternatively I can use whitelist instead of blacklist of paths
  that I want to backup, but that pretty much defies the idea of having
  automatic backup.
- Cleaning up the old caches and data is troublesome as user need to review all
  the folders and know what data they see mean.

But what We can do? Well, the macOS and Windows got it somewhat right, these
OSes provide special paths for storing all configuration, caches, user-data,
etc. in special, dedicated, and well known locations within user directories. It
is like mentioned earlier FHS but for `$HOME`.

Unfortunately no other OS out there had:

1. Power to force developers to behave reasonably
2. Standard to which developers should adhere to

Unfortunately the 1st point is still true, but the 2nd one is somewhat resolved
in form of [XDG Base Directory Specification][xdg]. This is pretty short,
simple, and straightforward spec where which data should go.

This makes life so much easier:

- Want to have backup your configuration? Just copy `$HOME/.config` where you
  want.
- Want to reset your configuration to base one? Just delete `$HOME/.config`.
- Want to cleanup caches? Remove `$HOME/.cache`.
- Etc.

It makes your `$HOME` much cleaner, much more manageable, much more like your
place, where you are the ruler, not as a manager of the bulletin board or the
storage house.

At one point I was even considering to have approach similar to [one taken by
Graham Christensen][delete-your-darlings], but that would make my life even more
miserable instead of forcing developers to fix their software.

Just in case, this is not only mine view on the state of configuration files,
just see [old Google+ post by Rob Pike][pike] where he states exactly the same
thing that FreeDesktop team try to address. I may not agree on all the concepts
with Commander, but this one I vote all-fours.

For these who want to stop that madness and fix at least some software out there
that is broken, you can check out [my script][xdg-please] that tries to fix
(at least partially) non-conforming software.

---

**TL;DR**

Please, stop leaving your c\*\*p in my `$HOME` and call it "installation". If
you want that, then I think you should find nearest Modern Art Gallery.

---

You can comment it on [Lobste.rs](https://lobste.rs/s/va7gic/stop_spreading_c_p_at_my_home)
[Reddit](https://www.reddit.com/r/programming/comments/g2210g/stop_spreading_cp_at_my_home/)
or @ me on Twitter.

[fhs]: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
[xdg]: https://specifications.freedesktop.org/basedir-spec/latest/index.html
[delete-your-darlings]: https://grahamc.com/blog/erase-your-darlings
[pike]: https://web.archive.org/web/20180827160401/plus.google.com/+RobPikeTheHuman/posts/R58WgWwN9jp
[xdg-please]: https://github.com/hauleth/xdg-rlz
