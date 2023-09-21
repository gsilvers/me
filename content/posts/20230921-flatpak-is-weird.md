---
title: "20230921 Flatpak Is Weird"
date: 2023-09-21T12:00:40-04:00
draft: false
---

# Once upon a SteamDeck

As I continue exploring my SteamDeck I keep learning things about Linux I really never had to deal with as the "installer" or as a day to day developer using Linux tooling. The example today came up trying to get [Ispell](https://www.emacswiki.org/emacs/InteractiveSpell "Ispell") working within emacs. Generally as a Linux user or even MacOS user this has been a pretty simple excursion. Within emacs usually something to the effect of:

```emacs-lisp
(setq ispell-program-name "aspell")
```

added to your config gets the tool pointing at the right program and a simple:

```bash
brew install aspell
```

pick your poison for package manager gets the actual software installed an on your path. This all gets messy however if and when you use Emacs from a Flatpak. [Flatpak](https://flatpak.org/ "Flatpak") in case you didn't know is an open source, Linux friendly answer to packing per application dependencies. While many Linux package managers and Unixes in general tend to drive applications to share libraries in something like `/usr/lib` Windows traditionally encouraged developers to package dependencies with their installers, locally within the space of the application. 

This obviously uses a lot more disk space but in the age of pennies cheap storage this is much less of a concern than say, developers not pinning a dependency version properly. 

Flatpak solves this and one thing it does that is "fun" is your application gets its own "sandbox" such that `/` for your application is not the same `/` as the rest of your system. This can cause some fun things for applications that call other applications like perhaps a terminal emulator but certainly Emacs. Emacs flatpak seems to know by default where the system /usr/bin etc are but when such programs have their own shared resources such as Aspell's dictionaries in `/usr/lib/aspell` things get fun. Emacs can invoke aspell but gets an error in the form of `Error: No word lists can be found for the language "en_US"`.

Thankfully aspell has a handy `aspell dump dicts` and `aspell dump config` to let you poke at the issues. Likewise emacs has its venerable describe-variable which lets you browse the various ispell/aspell settings available for configuration. This exposes quite a few ways to fix the issue but a simple one is:

1. Create a aspell.conf file which tells a flatpak program where the dictionary is outside of the sandbox. FYI Flatpak can access the host's files via the path `/var/run/host/<rest-of-the-path`.
2. Tweak your emacs config to run aspell this way.

The aspell.conf file can be as simple as:

```conf
dict-dir /var/run/host/usr/lib/aspell-0.60
```

Your emacs config then just needs to invoke aspell with the --conf=file option like so:

```emacs-lisp
(setq ispell-program-name "/var/run/host/usr/bin/aspell")

(setq ispell-extra-args '("--conf=/home/deck/aspell.conf"))
```

And off you go you can spell check:

![Screenshot of emacs with ispell running](/me/20230921/emacs_capture.png)

So flatpak is a little weird, and while maybe not as easy as getting my macbook running or even an off the shelf system 76 box, it still makes sense and I'm better for the exploration.
