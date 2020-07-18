# Building AudioQuake and the Level Description Language

<!--TOC-->

- [Overview](#overview)
- [First-time set-up](#first-time-set-up)
  - [Mac](#mac)
  - [Windows](#windows)
- [Your first build](#your-first-build)
  - [Build scripts](#build-scripts)
  - [Build environment](#build-environment)
  - [Compiling stuff](#compiling-stuff)
  - [What do the build scripts do?](#what-do-the-build-scripts-do)
  - [If things go wrong](#if-things-go-wrong)
- [Re-building](#re-building)
- [Distributing](#distributing)

<!--TOC-->

## Overview

There are three main components that are brought together by the build process.

1. The engine, QuakeC compiler, gamecode and Quake map compilation tools, written predominantly in C (with some QuakeC), which need to be compiled. These can be found in the "giants" directory.
2. AudioQuake is based on these and adds all of the custom game assets, launcher, support for mods, and documentation. The "audioquake" directory contains all of that stuff. The AudioQuake launcher and build system is written in Python.
3. The Level Description Language tools and documentation can be found in the "ldl" directory—though the relevant files from there are automagically brought in to AudioQuake builds, so anyone can access them via the GUI launcher. You only need to venture into LDL's directory if you want to use it stand-alone on the command-line, and that's only currently supported on the Mac. LDL is also written in Python.

When you make a build of AudioQuake and Level Description Language, the Python code is "frozen" into a form that runs without the need for Python to be installed. A build has to be made on the platform (Mac or Windows) on which it's intended to be run.

## First-time set-up

The day-to-day process of building the "giants" and AudioQuake is actually quite simple: you only need to run one command. However there is some set-up that needs doing before you can run a build for the first time.

### Mac

These instructions were tested on macOS Catalina (10.15).

#### Pre-requisites

* To compile anything and to use the suggested package manager, you will need the XCode command line tools to have been installed. You can do this by running `xcode-select --install`.
* We strongly recommend using [Homebrew](http://brew.sh) as this makes the installation and update of third-party libraries and tools easy.
* We also strongly recommend that you install the packages `git` and `bash-completion` (which allows you to quickly tab-complete many commands) to make working on the command line easy. Do this by running `brew install bash-completion` and `brew install git`. If you prefer a graphical UI for Git (and GitHub), you can install [GitHub Desktop](http://desktop.github.com).
* Make sure you've added Homebrew's install location, `/usr/local/`, to your path, so that later on when you install Python via Homebrew, it will run that version rather than the macOS system version.

After the above steps, you should end up with something like the following in your `~/.bashrc` file—you'll probably need to restart your shell for this to take effect.

```bash
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi
```

#### Python

We recommend installing your own Python and not using the system one: this makes it easy to control the version that is installed, and guarantees it's up-to-date.

* Install Python 3.x with: `brew install python`.
* To test it's set up correctly, run `which python3` and you should find that the result is: `/usr/local/bin/python3`

#### The Simple DirectMedia Layer (SDL) library

You will also need the SDL library and development files: `brew install sdl`

### Windows

These instructions have been tested on Windows 10 Home, 64-bit.

You don't need to download all of Visual Studio: whilst you _can_ use the graphical IDE to compile ZQuake and ZQCC, you don't need to. If you want to use it, or already have it, check out the subsection below.

* Install the [Build Tools for Visual Studio](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2019) (that link takes you to part-way down the page. There is also an MSDN page called [Use the Microsoft C++ toolset from the command line](https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line) that may be of interest.
  + In "Workloads" choose "C++ build tools"
  + In the "Installation details" section (a list of checkboxes) be sure to select "C++ MFC for latest v142 build tools (x86 & x64)" (this causes the corresponding ATL option to be selected too).
* [Install Python 3.x](http://www.python.org/downloads/).
  + The default installer from that page comes as 32-bit; that's fine.
  + There is an "Add Python [version] to PATH" checkbox at the bottom of the first page of the install wizard (below the "Install now" button); be sure to select it.
  + You can then use the "Install now" button.
  + You do not necessarily need to extend the path length limit, when asked.

#### Using the Visual Studio GUI, or customising an existing install

You can use [Visual Studio Community 2019](https://visualstudio.microsoft.com/vs/community/). The build scripts will still work automatically via the command-line, but they will use the Visual Studio development environment scripts, rather than the command-line ones.

Here's what you need to ensure is installed:

* In "Workloads" choose "Desktop development with C++"
* In the "Installation details" section (a list of checkboxes) be sure to select "C++ MFC for latest v142 build tools (x86 & x64)".

## Your first build

**tl;dr:** the `build-all.py` script will set up the build environment and run a complete build for you. Run the script from a command line in the root of the checked-out repo:

* **Mac:** `./build-all.py`
* **Windows:** `python build-all.py`

You can easily open the Terminal, or Command Prompt in the root of the repo from the [GitHub Desktop](http://desktop.github.com) GUI app.

There are a couple of other scripts, too. The following sections explain what the scripts do, and why.

### Build scripts

* `build-all.py` sets up the environment, installs required packages and then calls the other two build scripts.
* `build-giants.py` orchestrates compiling of the engine, QuakeC compiler, gamecode and Quake mapping tools.
* `build-audioquake.py` assembles the above components together with all of the supporting launcher and LDL code, assets and documentation and then "freezes" this into a coherent release that can actually be run.

### Build environment

In order to keep the packages required by AudioQuake and Level Description Language isolated from other projects on your system, the build process sets up a virtual Python environment in which to store them.

This also allows easy sharing of a couple of the common bits of code between components: the Level Description Language library and most of the build system's code. Both are actually cast as Python packages and installed in "editable" or "developer" mode, so that they're both neatly shared (with no duplication) and editable in real-time.

Please note that when you've finished working inside the virtual environment, you need to deactivate it, with the `deactivate` command.

You can use things like the awesome [direnv](https://direnv.net/) to automatically activate, deactivate and even create the virtual environment, but this is something you'll need to set up. The direnv Wiki page on Python has [a section about using direnv with Python's venv module](https://github.com/direnv/direnv/wiki/Python#venv-stdlib-module) that is really helpful.

### Compiling stuff

On both Mac and Windows, the build scripts can compile the engine and related components for you.

On Windows, a batch file that's part of the MS Build tools, or Visual Studio, is used to ensure that the compiler can be found. The `build-all.py` script assumes that you're using Command Prompt (not PowerShell) as your command-line interface.

Further, on Windows, to ensure that the environment variables are usable, `build-all.py` actually creates a batch file that calls Microsoft's one to set up the development tools and then calls `build-giants.py` and `build-audioquake.py`—this is all handled for you, though.

### What do the build scripts do?

#### What does `build-all.py` do?

1. Creates a Python virtual environment.
2. Updates `pip` and then uses it to install the required packages and shared code mentioned above.
3. Calls `build-giants.py` to build the low-level components (details below).
4. Calls `build-audioquake.py` to assemble a full release (details in [audioquake/BUILD.md](audioquake/BUILD.md)).

#### What does `build-giants.py` do?

1. Compiles the ZQuake engine.
2. Compiles the ZQuake QuakeC compiler ("ZQCC").
3. Uses the compiled ZQCC to compile the AudioQuake gamecode (which is under the "giants" directory as the ZQuake maintainers were kind enough to host our code in there).
4. The Quake map compilation tools are included in this repo by way of a git submodule that references id Software's main repo. The filenames of the map tools sources are upper-case, which is awkward on some *nix systems, so the build script renames them to be lower-case.
5. The Quake map tools are also hard-coded to look for certain files in certain places, which is no longer appropriate, so the build script patches them (with the patch files in "ldl/patches/") to adjust this behaviour.
6. Finally the Quake map tools are compiled so they can be used by the Level Description Language tools, on the command-line or as part of AudioQuake distributions.

The engine, QuakeC compiler, gamecode and map tools binaries remain in their respective directories under "giants" (they are picked up by the LDL tools and AudioQuake build script).

#### What does `build-audioquake.py` do?

All the info can be found in [audioquake/BUILD.md](audioquake/BUILD.md)).

### If things go wrong

The output of the build process is designed to be minimal: success messages will not be reported, in order to keep things manageable. If a build step encounters an error, however, the command will be re-run with all output shown.

On Windows, the path to the "vcvars*.bat" files, which are needed to set up the command-line development environment, varies between versions of Visual Studio, so could be fragile.

## Re-building

You can always re-run `build-all.py` to rebuild in future. The virtual environment and any build objects/progress on the low-level components are always saved, so subsequent builds are much faster.

You can also use the standard tools such as `pip` in the virtual environment, and you can call `build-giants.py` and `build-audioquake.py` separately if you prefer.

On Windows you can even compile engine (including client and server) and QuakeC compiler with the Visual Studio GUI if you prefer. Be sure that you have installed the support files highlighted above, and select the "GLRelease" (ZQuake) or "Release" (ZQCC) configurations. The Quake map tools must be compiled with the command-line `nmake` tool.

## Distributing

The outcome of the build process is a platform-specific AudioQuake distribution. On the Mac, this is an ".app" bundle and on Windows this is a directory that contains "AudioQuake.exe". Both can be zipped up for distribution.
