Building AudioQuake
===================

AudioQuake can be built into a stand-alone application for Mac or Windows. This can be run directly by the user, without having to install anything. This file documents the following four main steps:

-   Getting your development environment set up for the first time (this differs between Mac and Windows).
-   Getting the AudioQuake code and required libraries.
-   Compiling the engine on Windows (this is automated on the Mac).
-   Running the build script to produce a stand-alone AudioQuake application.

Please note that builds are platform-specific, i.e. if you build on the Mac, you will get a Mac version of AudioQuake; if you build on Windows you'll get a Windows version. You can only build an AudioQuake package for the OS you're running.

First-time set-up: Mac
----------------------

These instructions were tested on macOS Mojave (10.14).

### Pre-requisites

-   To compile anything and to use the suggested package manager, you will need the XCode command line tools to have been installed. You can do this by running `xcode-select --install`.
-   We strongly recommend using [Homebrew](http://brew.sh) as this makes the installation and update of third-party libraries and tools easy.
-   We also strongly recommend that you install the packages `git` and `bash-completion` (which allows you to quickly tab-complete many commands) to make working on the command line easy. Do this by running `brew install bash-completion` and `brew install git`. If you prefer a graphical UI for Git (and GitHub), you can install [GitHub Desktop](http://desktop.github.com).
-   Make sure you've added homebrew's install location, `/usr/local/`, to your path, so that later on when you install Python via homebrew, it will run that version rather than the macOS system version.

After the above steps, you should end up with something like the following in your `~/.bashrc` file—you'll probably need to restart your shell for this to take effect.

```bash
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi
```

### Python

We recommend installing your own Python and not using the system one: this makes it easy to clean up any third-party libraries you install, and to control precisely which Python version is used.

-   Install Python 3.x with: `brew install python`.
-   To test it's set up correctly, run `which python3` and you should find that the result is: `/usr/local/bin/python3` (if it's not pointing to the correct python then later on you will get errors about missing packages even if you've installed them).

### The Simple DirectMedia Layer (SDL) library

You will also need the SDL library and development files: `brew install sdl`

First-time set-up: Windows
--------------------------

**FIXME—these need updating**

These instructions were tested on Windows 8.1 32-bit. If you experience problems, please let us know the version you are using, and include any error messages.

### Visual Studio

-   We used Visual Studio Express 2013. Make sure you get "Visual Studio Express for Windows Desktop". It's free, but you'll need a Microsoft Account.
-   You need to install "Microsoft Foundation Classes for C++" as the code depends on these (if you don't, you'll get errors during compilation talking about `afxres.h`). We have updated the Visual Studio project files so that you should not need to do anything other than install MFC. You can do this by running a default install of the [Windows 2003 DDK](http://download.microsoft.com/download/9/0/f/90f019ac-8243-48d3-91cf-81fc4093ecfd/1830_usa_ddk.iso).

For reference, though it should not be required, as explained above: full instructions to download and install MFC and update the Visual Studio project config files are [provided by CodeProject](http://www.codeproject.com/Articles/30439/How-to-compile-MFC-code-in-Visual-C-Express) -- though these instructions shouldn't be required and they refer to an older version of Visual Studio and an obsolete DDK download link.

### Python and Python Windows Extensions

-   [Install Python 3.x](http://www.python.org/downloads/).
-   FIXME-TODO (can be done via pip if needed?): Install the [Python Windows Extensions](http://sourceforge.net/projects/pywin32/files/pywin32/) (the most recent build is the one nearest the top; you'll need to download the ".exe" file that matches your Python version (i.e. 2.7) and CPU type).

Getting the AudioQuake code and Python libraries
------------------------------------------------

The following instructions give the Git command lines you need to complete them, but you can always use the [GitHub Desktop](http://desktop.github.com) GUI app if you prefer.

-   Get the code by cloning from GitHub: `git clone https://github.com/matatk/agrip.git`

    There are two main branches in this repo: "master", where the AudioQuake development is done, and "gh-pages" which holds the AGRIP website. You need to be on the "master" branch, in the `audioquake/` directory, to peform the rest of these steps.

-   Finally you can install the third-party Python libraries that AudioQuake needs: `pip3 install -r requirements.txt`

Compiling the Engine (Windows-only)
-----------------------------------

On Windows this must be done separately to the main build process. The main build script will pick up the compiled engine and QuakeC compiler binaries during the build process.

-   To compile the ZQuake engine, go to the `audioquake\zq-repo\zquake\source\` folder and open `zquake.sln`. Be sure to select the whole solution in the "Solution Explorer" and then select the "GLRelease" configuration on the main Visual Studio toolbar before buidling the project. When the project is built, you will get the server, client/server and client binaries (only the first two are needed).
-   You'll also need to compile the QuakeC compiler. Go to the `audioquake\zq-repo\zqcc\` folder and open `zqcc.sln`. Select the "Release" configuration and build.

Running the build script
------------------------

The result of the build process is a stand-alone application that can be run on a given platform (an .app bundle on the Mac; a simple folder on Windows). To run a build, the steps are as follows.

1.  If you are using Windows, ensure you've compiled the engine and QuakeC compiler, as above (you don't need to do this if they have not changed since the last build).
2.  On Mac or Windows, run `python3 build.py` to perform all the steps above and create the standalone application.

There is a cleanup script (`clean.py`) to tidy things up (i.e. remove the compiled code, data files and downloaded assets) so that the repo is back to the state it was in when cloned.

### What does the build script do?

-   (On the Mac) compiles ZQuake, zqcc and the QuakeC gamecode.
-   FIXME it's meant to compile the GC on Windows too
-   Converts the user manual, sound legend appendix (so it can be referred to separately), development manuals, README and LICENCE files from Markdown to HTML.
-   Checks if you have local copies of the various game data files, as follows, and downloads them for you if not.
    -   AudioQuake maps (i.e. compiled, `.bsp` versions of the maps in the git repo).
    -   AudioQuake demos.
    -   Standard skins.
    -   Shareware Quake data.
    -   Mindgrid sounds.
-   Runs [PyInstaller](http://www.pyinstaller.org) to "freeze" the Python code (so that it runs like a normal executable, without requiring Python on the player's computer) and combine it with the engine binaries and all the data mentioned above.

