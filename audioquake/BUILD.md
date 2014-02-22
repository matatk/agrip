Building AudioQuake
====================

This is very-much a work-in-progress as we move to a new build system that should work across Mac and Windows.

**Note:** if you build on the Mac, you will get a Mac bundled version of AudioQuake; if you build on Windows you'll get a Windows version.  You can only build an AudioQuake package for the OS you're running.

Mac
----

### Pre-requisites

* To compile anything and to use the suggested package manager, you will need the XCode command line tools to have been installed.
* We strongly recommend using [Homebrew](http://brew.sh) as this makes the installation and update of third-party libraries and tools easy.
* We also strongly recommend that you install the packages `git` and `bash-completion` (which allows you to quickly tab-complete many commands) to make working on the command line easy.  Do this by running `brew install git` and `brew install bash-completion`.
* Make sure you've added homebrew's install location, `/usr/local/`, to your path, so that later on when you install Python via homebrew, it will run that version rather than the OS X system version.  You should end up with the following in your `~/.bashrc` file.

```
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
if [ -f `brew --prefix`/etc/bash_completion ]; then
	. `brew --prefix`/etc/bash_completion
fi
```

### Python and third-party libraries

For various reasons, it is recommended to build your own Python and not use the system one.  Following these steps will also install a decent Python package manager called pip that will help with some package installation.

* Install Python 2.x with: `brew install python`
* To test it's set up correctly, run `which python` and you should find that the result is: `/usr/local/bin/python`
* You'll need PyObjC, which you should install by running `pip install -U pyobjc-core` and then `pip -U pyobjc`
* Get the text-to-speech library with: `pip install pyttsx`
* Install PyGUI by downloading the .tar.gz file from <http://www.cosc.canterbury.ac.nz/greg.ewing/python_gui/> and extracting it.  Then run: `python setup.py install`
* To install cx_Freeze, download from <http://cx-freeze.sourceforge.net>, extract and then run: `python setup.py install`

### Engine and AudioQuake code

* Get the code by cloning from GitHub.
* It may checkout the gh-pages branch (where the website is developed); switch to the master branch by issuing `git checkout master`.
* You will also need the SDL library and development files: `brew install sdl`

### Using the AudioQuake build system

* Dependencies will be downloaded by the build scripts when run (and kept locally for future reuse).
* To ensure that the engine and gamecode are compiled, download the support files (if need be) and get all the files ready to be built into an application, run the `prepare.py` script.
* The results of running the build script will be "staging area" called `app-staging`, which includes all of the files needed to build an redistributable version of AudioQuake (i.e. AudioQuake.app, if run on the Mac).  To actually create the redistributable using `cx_Freeze`, run `python setup.py bdist_mac` from within the staging directory.
* You can also clean various parts of the software using the `./clean` script, which will print out help/usage information when run with no parameters.


Windows
--------

**Note:** currently there's no way to run a proper build on Windows; this will change very shortly as the new build system written in Python is now being tested on and tweaked for Windows.

To get the Python side of things working, including the program that will turn the Python code and all the supporting libraries into an executable for easy redistribution, follow these steps.

* You will need 7zip or similar to extract some of the files for installing the required libraries.  You can get 7zip from <http://www.7-zip.org>.
* Need Python 2.x from: <http://www.python.org/download/>
* Install the Python Windows Extensions: <http://sourceforge.net/projects/pywin32/>
* Install `setuptools` (required for installing third-party libraries): <https://pypi.python.org/pypi/setuptools/1.1.6#windows>
* To install the text-to-speech library and ensure it can be compiled for redistribution later on, run in a command window: `easy_install --always-unzip pyttsx`
* Install PyGUI by downloading the .tar.gz file from <http://www.cosc.canterbury.ac.nz/greg.ewing/python_gui/> and extracting it.  Then, in a command window, run: `setup.py install`
* Finally install cx_Freeze, which compiles all of the above into an executable for easy redistribution, from: <http://cx-freeze.sourceforge.net>

For compiling the ZQuake engine binaries, follow these steps.

* We used Visual Studio Express 2013, though 2010 and 2012 should work fine.
* You need to install 'Microsoft Foundation Classes for C++' by following CodeProject's instructions: <http://www.codeproject.com/Articles/30439/How-to-compile-MFC-code-in-Visual-C-Express> -- however the download link for the Windows 2003 DDK is actually now <http://download.microsoft.com/download/9/0/f/90f019ac-8243-48d3-91cf-81fc4093ecfd/1830_usa_ddk.iso>.
* You should then be able to compile the engine executables on Windows.
