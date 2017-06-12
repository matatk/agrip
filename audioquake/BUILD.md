Building AudioQuake
===================

AudioQuake can be built into a stand-alone application for Mac or Windows. This can be run directly by the user, without having to install anything.

The build process is fairly simple (though compiling the engine on Windows takes some time to set up) and similar whether you are on a Mac or Windows. However, before you can run your first build, you need to set up your development environment. The instructions for this depends on which platform you are using.

Please note that builds are platform-specific, i.e. if you build on the Mac, you will get a Mac version of AudioQuake; if you build on Windows you'll get a Windows version. You can only build an AudioQuake package for the OS you're running.

**Note:** currently this file does not explain how to build the user and development manuals, because this process is Mac-specific, though we are working on making it cross-platform as we have the rest of the build process.

First-time set-up: Mac
----------------------

These instructions were tested on macOS Sierra (10.12).

### Pre-requisites

-   To compile anything and to use the suggested package manager, you will need the XCode command line tools to have been installed. You can do this by running `xcode-select --install`.
-   We strongly recommend using [Homebrew](http://brew.sh) as this makes the installation and update of third-party libraries and tools easy.
-   We also strongly recommend that you install the packages `git` and `bash-completion` (which allows you to quickly tab-complete many commands) to make working on the command line easy. Do this by running `brew install bash-completion` and `brew install git`. If you prefer a graphical UI for Git (and GitHub), you can install [GitHub Desktop](http://desktop.github.com).
-   Make sure you've added homebrew's install location, `/usr/local/`, to your path, so that later on when you install Python via homebrew, it will run that version rather than the macOS system version. You should end up with something like the following in your `~/.bashrc` file—you'll probably need to restart your shell for this to take effect.

```bash
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi
```

### Python

We recommend installing your own Python and not using the system one: this makes it easy to clean up any third-party libraries you install, and to control precisely which Python version is used.

-   Install Python 3.x with: `brew install python3`.
-   To test it's set up correctly, run `which python3` and you should find that the result is: `/usr/local/bin/python3` (if it's not pointing to the correct python then later on you will get errors about missing packages even if you've installed them).

### The Simple DirectMedia Layer (SDL) library

You will also need the SDL library and development files: `brew install sdl`

### User and Development Manuals

The manuals are written in Markdown (previously they were written in DocBook XML and those original files are still lurking, for now). We use a program called Pandoc to convert them from Markdown to HTML. There are three ways to get this installed, as follows.

-   **Direct way:** get and run the [installer package](https://github.com/jgm/pandoc/releases/latest/).
-   **Homebrew way:** `brew install pandoc`
-   **MacPorts:** there is a pandoc package that should also work (though we have not tested it).

First-time set-up: Windows
--------------------------

These instructions were tested on Windows 8.1 32-bit. If you experience problems, please let us know the version you are using, and include any error messages.

### Python and Python Windows Extensions

-   [Install Python 3.x](http://www.python.org/downloads/).
-   Install the [Python Windows Extensions](http://sourceforge.net/projects/pywin32/files/pywin32/) (the most recent build is the one nearest the top; you'll need to download the ".exe" file that matches your Python version (i.e. 2.7) and CPU type).

### User and Development Manuals

The manuals are written in Markdown (previously they were written in DocBook XML and those original files are still lurking, for now). We use a program called Pandoc to convert them from Markdown to HTML.

Download and run the latest [Windows installer](https://github.com/jgm/pandoc/releases/latest/).

Getting the Code and Python libraries
-------------------------------------

The following instructions give the Git command lines you need to complete them, but you can always use the [GitHub Desktop](http://desktop.github.com) GUI app if you prefer.

-   Get the code by cloning from GitHub: `git clone https://github.com/matatk/agrip.git`
-   It may checkout the "gh-pages" branch (where the website is developed); switch to the master branch: `git checkout master`
-   Finally you can install all of the third-party Python libraries that AudioQuake needs: `pip3 install -r requirements.txt`

### Compiling the Engine (Windows-only)

On Windows this must be done separately to the main build process. The main build script will pick up the compiled engine and QuakeC compiler binaries during the build process.

-   We used Visual Studio Express 2013. Make sure you get "Visual Studio Express for Windows Desktop". It's free, but you'll need a Microsoft Account.
-   You need to install "Microsoft Foundation Classes for C++" as the code depends on these (if you don't, you'll get errors during compilation talking about `afxres.h`). We have updated the Visual Studio project files so that you should not need to do anything other than install MFC. You can do this by running a default install of the [Windows 2003 DDK](http://download.microsoft.com/download/9/0/f/90f019ac-8243-48d3-91cf-81fc4093ecfd/1830_usa_ddk.iso).
-   To compile the ZQuake engine, go to the `audioquake\zq-repo\zquake\source\` folder and open `zquake.sln`. Be sure to select the whole solution in the "Solution Explorer" and then select the "GLRelease" configuration on the main Visual Studio toolbar before buidling the project. When the project is built, you will get the server, client/server and client binaries (only the first two are needed).
-   You'll also need to compile the QuakeC compiler. Go to the `audioquake\zq-repo\zqcc\` folder and open `zqcc.sln`. Select the "Release" configuration and build.

For reference, though it should not be required, as explained above: full instructions to download and install MFC and update the Visual Studio project config files are [provided by CodeProject](http://www.codeproject.com/Articles/30439/How-to-compile-MFC-code-in-Visual-C-Express) -- though these instructions shouldn't be required and they refer to an older version of Visual Studio and an obsolete DDK download link.

Building AudioQuake
-------------------

The result of the build process is a stand-alone application that can be run on a given platform (an .app bundle on the Mac; a simple folder on Windows). There are two steps to the build process.

-   A "preparation" script is run that will get everything required to run AudioQuake into a "staging area". This script downloads support files (compiled maps, skins, demos and the shareware and mindgrid data), compiles the gamecode and puts all of the required engine binaries and data in the staging area. On the Mac this will automatically compile the engine and QuakeC compiler; on Windows you need to have done this previously (as above). The launcher in the staging area is still just a Python script.

-   A cx\_Freeze "setup" script is run to ask cx\_Freeze to convert the staging area into an application. This includes converting the launcher into a stand-alone program that does not require Python to be installed on the end-user's machine.

To run a build, the steps are as follows (using a command line in the `audioquake` directory).

1.  If you are using Windows, ensure you've compiled the engine and QuakeC compiler, as above (you don't need to do this if they have not changed since the last build).
2.  Run `python3 prepare.py` to create the staging area.
3.  Change directory into the stating area: `cd app-staging`
4.  Run the setup script in there, as follows.
    -   On a Mac, run `python setup.py bdist_mac`.
    -   On Windows, you first need to run `AudioQuake.py` to ensure that the code is properly hooked up to the Speech API through COM, then you can freeze the code for distribution by running `setup.py build`. **FIXME: is that needed?**

There is a cleanup script (`clean.sh`) to help tidy things back to varying degrees (e.g. removing the compiled code, support files), but currently this is only available for the Mac.
