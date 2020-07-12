Building
========

There are three main parts, two of which need building before they can be used and distributed...

1. The engine, QuakeC compiler, gamecode and Quake map compilation tools, written predominantly in C (with some QuakeC), which need to be compiled. These can be found in the "giants" directory.
2. AudioQuake is based on these and adds all of the custom game assets, launcher, support for mods, and documentation. The "audioquake" directory contains all of that stuff.
3. The Level Description Language tools and documentation can be found in the "ldl" directory—though the relevant files from there are automagically brought in to AudioQuake builds. You only need to venture into the LDL directory if you want to use it stand-alone on the command-line, and that's only currently supported on the Mac.

The day-to-day process of building the "giants" and AudioQuake is actually quite simple: you only need to run one command. However there is some set-up that needs doing before you can run a build for the first time.

First-time set-up: Mac
----------------------

These instructions were tested on macOS Catalina (10.15.5).

### Pre-requisites

* To compile anything and to use the suggested package manager, you will need the XCode command line tools to have been installed. You can do this by running `xcode-select --install`.
* We strongly recommend using [Homebrew](http://brew.sh) as this makes the installation and update of third-party libraries and tools easy.
* We also strongly recommend that you install the packages `git` and `bash-completion` (which allows you to quickly tab-complete many commands) to make working on the command line easy. Do this by running `brew install bash-completion` and `brew install git`. If you prefer a graphical UI for Git (and GitHub), you can install [GitHub Desktop](http://desktop.github.com).
* Make sure you've added homebrew's install location, `/usr/local/`, to your path, so that later on when you install Python via homebrew, it will run that version rather than the macOS system version.

After the above steps, you should end up with something like the following in your `~/.bashrc` file—you'll probably need to restart your shell for this to take effect.

```bash
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi
```

### Python

We recommend installing your own Python and not using the system one: this makes it easy to clean up any third-party libraries you install, and to control precisely which Python version is used.

* Install Python 3.x with: `brew install python`.
* To test it's set up correctly, run `which python3` and you should find that the result is: `/usr/local/bin/python3` (if it's not pointing to the correct python then later on you will get errors about missing packages even if you've installed them).

### The Simple DirectMedia Layer (SDL) library

You will also need the SDL library and development files: `brew install sdl`

First-time set-up: Windows
--------------------------

These instructions have been tested on Windows 10 Home, 64-bit.

* Download [Visual Studio Community 2019](https://visualstudio.microsoft.com/vs/community/). When installing:
  + In "Workloads" choose "Desktop development with C++"
  + In the "Installation details" section (a list of checkboxes) be sure to select "C++ MFC for v142 build tools"
* [Install Python 3.x](http://www.python.org/downloads/).

Mac and Windows: Running a build
--------------------------------

Ensure you have the latest supporting Python packages with: `pip3 install -r requirements.txt` (the file lists everything needed by both AudioQuake and LDL).

To run a complete build, issue the following commands at the command-line in the root of the repo:

* **Mac:** `./build-all.sh`
* **Windows:** `build-all.bat`

Both of these call "build-giants.py" in the root and "build-audioquake.py" in its directory. What does "build-giants.py" do?

1. Compiles the ZQuake engine.
2. Compiles the ZQuake QuakeC compiler ("ZQCC").
3. Uses the compiled ZQCC to compile the AudioQuake gamecode (which is under the "giants" directory as the ZQuake maintainers were kind enough to host our code in there).
4. The Quake map compilation tools are included in this repo by way of a git submodule that references id Software's main repo. The filenames of the map tools sources are all upper-case, which is awkward on some *nix systems, so the build script renames them all lower-case.
5. The Quake map tools are also hard-coded to look for certain files in certain places, which is no longer appropriate, so the build script patches them (with the patch files in "ldl/patches/") to adjust this behaviour.
6. Finally the Quake map tools are compiled so they can be used by the Level Description Language tools, on the command-line or as part of AudioQuake distributions.

The engine, QuakeC compiler, gamecode and map tools binaries remain in their respective directories under "giants" (they are picked up by the LDL tools and AudioQuake build script).

For more info on the AudioQuake part of the build process, please read [audioquake/BUILD.md](audioquake/BUILD.md).
