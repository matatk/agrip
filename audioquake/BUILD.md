Building AudioQuake
===================

**Note:** currently this file does not explain how to build the user and
development manuals, because this process is Mac-specific, though we are
working on making it cross-platform as we have the rest of the build
process.

AudioQuake can be built into a stand-alone application for Mac or
Windows. This can be run directly by the user, without having to install
anything.

The build process is fairly simple (though compiling the engine on
Windows takes some time to set up) and similar whether you are on a Mac
or Windows. However, before you can run your first build, you need to
set up your development environment. The instructions for this depends
on which platform you are using.

Please note that builds are platform-psecific, i.e. if you build on the
Mac, you will get a Mac version of AudioQuake; if you build on Windows
you'll get a Windows version. You can only build an AudioQuake package
for the OS you're running.

Set-up: Mac
-----------

These instructions were tested on OS X "Mavericks" (10.9) and "Yosemite"
(10.10).

### Pre-requisites

-   To compile anything and to use the suggested package manager, you
    will need the XCode command line tools to have been installed. You
    can do this on Mavericks by running `xcode-select --install` (if you
    get an error that the software cannot be found, but running
    `cc --version` works, then the software is installed OK).
-   We strongly recommend using [Homebrew](http://brew.sh) as this makes
    the installation and update of third-party libraries and tools easy.
-   We also strongly recommend that you install the packages `git` and
    `bash-completion` (which allows you to quickly tab-complete many
    commands) to make working on the command line easy. Do this by
    running `brew install bash-completion` and `brew install git`.
-   Make sure you've added homebrew's install location, `/usr/local/`,
    to your path, so that later on when you install Python via homebrew,
    it will run that version rather than the OS X system version. You
    should end up with the following in your `~/.bashrc` file.

<!-- -->

    export PATH=/usr/local/sbin:/usr/local/bin:$PATH
    if [ -f `brew --prefix`/etc/bash_completion ]; then
        . `brew --prefix`/etc/bash_completion
    fi

### Python and third-party libraries

For various reasons, it is recommended to build your own Python and not
use the system one. Following these steps will also install a decent
Python package manager called pip that will help with some package
installation.

-   Install Python 2.x with: `brew install python`.
-   To test it's set up correctly, run `which python` and you should
    find that the result is: `/usr/local/bin/python`.
-   You'll need PyObjC, which you should install by running
    `pip install -U pyobjc-core` and then `pip -U pyobjc`.
-   Get the text-to-speech library with: `pip install pyttsx`.
-   Install PyGUI by downloading the .tar.gz file from
    <http://www.cosc.canterbury.ac.nz/greg.ewing/python_gui/> and
    extracting it. Then run: `python setup.py install`.
-   Finally install cx\_Freeze, which compiles all of the above into an
    executable for easy redistribution. We rely on a feature that is
    currently only present in the development version, which you can get
    from: <https://bitbucket.org/anthony_tuininga/cx_freeze>. After
    getting the code, run `python setup.py install`.

### Engine, AudioQuake Code and Required Libraries

-   Get the code by cloning from GitHub.
-   It may checkout the "gh-pages" branch (where the website is
    developed); switch to the master branch by issuing
    `git checkout master`.
-   You will also need the SDL library and development files:
    `brew install sdl`.

### User and Development Manuals

The manuals are written in Markdown (previously they were written in
DocBook XML and those original files are still lurking, for now). We use
a program called Pandoc to convert them from Markdown to HTML. There are
three ways to get this installed, as follows.

-   **Quick'n'simple way:** get and run the [installer
    package](https://github.com/jgm/pandoc/releases/latest/).
-   **Homebrew way:** if you use Homebrew and wish to compile and
    install Pandoc this way, issue `brew install haskell-platform` and
    then `cabal install --global pandoc` (if you don't specify
    `--global` it will instal in the current user's home directory).
-   **MacPorts:** if you use MacPorts and want to compile and install
    Pandoc with it, there is a pandoc package that should also work
    (though we have not tested it).

Set-up: Windows
---------------

These instructions were tested on Windows 8.1 32-bit. If you experience
problems, please let us know the version you are using, and include any
error messages.

### GitHub

-   Install [GitHub for Windows](http://windows.github.com).
-   Grab the code and ensure that the master branch (as opposed to
    "gh-pages", which holds the website) is the active branch.

### Compiling the Engine

On Windows this must be done separately to the main build process. The
main build script will pick up the compiled engine and QuakeC compiler
binaries during the build process.

-   We used Visual Studio Express 2013. Make sure you get "Visual Studio
    Express for Windows Desktop". It's free, but you'll need a Microsoft
    Account.
-   You need to install "Microsoft Foundation Classes for C++" as the
    code depends on these (if you don't, you'll get errors during
    compilation talking about `afxres.h`). We have updated the Visual
    Studio project files so that you should not need to do anything
    other than install MFC. You can do this by running a default install
    of the [Windows 2003
    DDK](http://download.microsoft.com/download/9/0/f/90f019ac-8243-48d3-91cf-81fc4093ecfd/1830_usa_ddk.iso).
-   To compile the ZQuake engine, go to the
    `audioquake\zq-repo\zquake\source\` folder and open `zquake.sln`. Be
    sure to select the whole solution in the "Solution Explorer" and
    then select the "GLRelease" configuration on the main Visual Studio
    toolbar before buidling the project. When the project is built, you
    will get the server, client/server and client binaries (only the
    first two are needed).
-   You'll also need to compile the QuakeC compiler. Go to the
    `audioquake\zq-repo\zqcc\` folder and open `zqcc.sln`. Select the
    "Release" configuration and build.

For reference, though it should not be required, as explained above:
full instructions to download and install MFC and update the Visual
Studio project config files are [provided by
CodeProject](http://www.codeproject.com/Articles/30439/How-to-compile-MFC-code-in-Visual-C-Express)
-- though these instructions shouldn't be required and they refer to an
older version of Visual Studio and an obsolete DDK download link.

### Python Stuff for Build and Launcher

To get the Python side of things working, including the program that
will turn the Python code and all the supporting libraries into an
executable for easy redistribution, follow these steps.

-   You will need 7zip or similar to extract some of the files for
    installing the required libraries. You can get 7zip from
    <http://www.7-zip.org>.
-   Get Python 2.x from: <http://www.python.org/downloads/>
-   Install the Python Windows Extensions:
    <http://sourceforge.net/projects/pywin32/files/pywin32/> (the most
    recent build is the one nearest the top; you'll need to download the
    ".exe" file that matches your Python version (i.e. 2.7) and CPU
    type).
-   Install `setuptools` (required for installing third-party
    libraries): <https://pypi.python.org/pypi/setuptools/1.1.6#windows>.
-   To install the text-to-speech library and ensure it can be compiled
    for redistribution later on, run in a command window:
    `\Python27\Scripts\easy_install.exe --always-unzip pyttsx`.
-   Install PyGUI by downloading the .tar.gz file from
    <http://www.cosc.canterbury.ac.nz/greg.ewing/python_gui/> and
    extracting it. Then, in a command window, run: `setup.py install`.
    Version 2.5.3 has a bug on Windows that must be fixed by changing
    line 6 of the file `\Python27\Lib\site-packages\GUI\ButtonBases.py`
    to: `from GUI.GControls import Control as GControl`.
-   Finally install cx\_Freeze, which compiles all of the above into an
    executable for easy redistribution. Due to [a bug in version
    4.3.2](https://bitbucket.org/anthony_tuininga/cx_freeze/issue/44/win32com-relies-on-modules-with-non),
    you will need to get version 4.3.1 from:
    <http://sourceforge.net/projects/cx-freeze/files/4.3.1/>.

### User and Development Manuals

The manuals are written in Markdown (previously they were written in
DocBook XML and those original files are still lurking, for now). We use
a program called Pandoc to convert them from Markdown to HTML.

Download and run the latest [Windows
installer](https://github.com/jgm/pandoc/releases/latest/).

Building AudioQuake
-------------------

The result of the build process is a stand-alone application that can be
run on a given platform (an .app bundle on the Mac; a simple folder on
Windows). There are two steps to the build process.

1.  A "preparation" script is run that will get everything required to
    run AudioQuake into a "staging area". This script downloads support
    files (compiled maps, skins, demos and the shareware and mindgrid
    data), compiles the gamecode and puts all of the required engine
    binaries and data in the staging area. On the Mac this will
    automatically compile the engine and QuakeC compiler; on Windows you
    need to have done this previously (as above). The launcher in the
    staging area is still just a Python script.

2.  A cx\_Freeze "setup" script is run to ask cx\_Freeze to convert the
    staging area into an application. This includes converting the
    launcher into a stand-alone program that does not require Python to
    be installed on the end-user's machine.

To run a build, the steps are as follows (using a command line in the
`audioquake` directory).

-   If you are using Windows, ensure you've compiled the engine and
    QuakeC compiler, as above (you don't need to do this if they have
    not changed since the last build).
-   Run `prepare.py` to create the staging area.
-   Run the setup script, according to your platform as follows.
    -   On a Mac, run `./prepare.py`.
    -   On Windows, run `prepare.py`.
-   Change directory into `app-staging`.
-   Run the setup script in there, as follows.
    -   On a Mac, run `python setup.py bdist_mac`.
    -   On Windows, you first need to run `AudioQuake.py` to ensure that
        the code is properly hooked up to the Speech API through COM,
        then you can freeze the code for distribution by running
        `setup.py build`.

There is a cleanup script to help tidy things back to varying degrees
(e.g. removing the compiled code, support files), but currently this is
only available for the Mac.
