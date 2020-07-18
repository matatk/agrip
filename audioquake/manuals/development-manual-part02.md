# Getting and Compiling the Source

This part details what you’ll need to do to get the code for AudioQuake and compile it. The Stats and Servers infrastructure and other tools are beyond the scope of this chapter. Here you’ll find a quick overview of what you need to do. Subsequent chapters will elaborate on why things are the way they are.

**Note:** These instructions are written with UNIX-like systems in mind (upon which you’ll need to have the **subversion** package installed). You can get and compile the source for ZQuake on Windows, but some of the AudioQuake build scripts only work on UNIX-like systems, so to make a full AudioQuake release you will either need to use a UNIX-like system, or carry out the steps manually on Windows. We recommend use of [TortoiseSVN](http://tortoisesvn.tigris.org/) to get the sources on Windows.

## From Source to Package – the Overall Process

The entire process of getting the source and turning it into a releasable package is as follows. The rest of this chapter describes these steps in more detail. As some steps have to be done on certain operating systems, the systems required are indicated for each one.

1.  Get the source using a Subversion client. (Doable on Linux and Windows.)

2.  Compile the ZQuake Engine and AudioQuake gamecode. (Automated on Linux; a little extra work on Windows.)

3.  Use the build scripts provided to set up the above engine and gamecode on your machine, for testing purposes. (Automated on Linux.)

4.  Use the build scripts to compile the documentation into HTML files for distribution. (Automated on Linux; doable with work on Windows.)

5.  Use the build scripts to package the game engine, gamecode and documentation into packages suitable for release. This contains a few separate stages, as follows.
    
    1.  Put all engine binaries in a known location for the build scripts to pick them up.
    
    2.  Check the `setup` script, which is the Linux self-installer script and update it as necessary. (Applicable to Linux.)
    
    3.  Issue the build script command that requests releases packages be made and indicate which releases you’d like to make (i.e. Linux/PowerPC, Linux/x86, Windows). The result of this is a self-installer for Linux and ZIP files for Windows that need further processing. (Automated on Linux.)
    
    4.  For Windows releases, the ZIP files need to be extracted and the `setup.iss` file compiled with Inno Setup to create a standard Windows setup program. (Applicable to Windows.)
        
        **Note:** If you wish to include the SAPI runtime and/or voices with your release, you’ll have to follow Microsoft’s documentation on how to do that separately. The license does not permit redistribution of such modules outside of installers for full applications.

6.  The final stage is to put the files somewhere public and point people towards them. Remember to test them first, though\!

## Locating the Source

All of the code for AudioQuake, ZQuake, the QuakeC gamecode, MAUTH and stats system (as well as other components as they’re added) is available from the AGRIP Subversion repository. Subversion is a version control system very similar to CVS, which you may have used before. More information can be found in [the section called “Version Control Systems”](#ref-vcs "Version Control Systems").

Currently we provide a read-only anonymous access repository at <http://svn.agrip.org.uk/> and a private one for development which is accessible via the `svn://` protocol. Community members are welcome to have full-access accounts created for the primary development repository.

### Repository Structure

Code found in the AGRIP Subversion repository is grouped at the highest level into *trunk* (where development is done), *branches* (where major features are staged before being entered into the (relatively) stable mainline of development) and *tags* (where the code for released versions is stored.

Below this level, sub-components may be found – for example “audioquake”, “sns” (Stats and Servers), “mauth” (Master AUTHentication protocol tools) and “ldl” (Level Description Language).

### Available Modules

  - Engine  
    ZQuake can be obtained from the `/trunk/zq-repo/zquake/` module in the repository. This code is forked (for convenience of access via our repository from the ZQuake [project](http://www.sourceforge.net/projects/zquake/) on SourceForge.

  - Gamecode  
    A modular version of the Quake, QuakeWorld and gamecode for other popular modifications (including the AGRIP accessibility extensions) can be found in the `zq-repo/qc/` module in our repository.
    
    **Note:** To compile the gamecode, you’ll need the ZQuake QuakeC Compiler (“ZQCC”). In a totally groundbreaking and novel move, it’s source has been included in our repository too (`/trunk/zq-repo/zqcc/`).
    
    The AudioQuake build scripts will automatically compile **zqcc** for you, if you’ve checked out the code, during the AudioQuake build process.

  - Manuals, Launcher, Support Files and Build Scripts  
    This is also all hosted in our Subversion repository (`/trunk/audioquake/`). Included are all of the support files, documentation and build scripts you need to create working AudioQuake packages for the supported operating systems.

  - Stats and Servers Infrastructure and Site  
    We are constantly developing this side of the project, too, and make the results available in our Subversion repository.

## Getting the Code – Step by Step

1.  Use your SVN client of choice to download either the whole development tree, or individual parts of it.
    
    ``` screen
    svn co http://svn.agrip.org.uk/trunk/
    ```
    
    The above command will get you *all* of the components being developed (so that’s at least the entire ZQuake codebase, AudioQuake, MAUTH protocol tools and the Stats and Servers web application).
    
    If you just want ZQuake and AudioQuake (the minimum requirements to build a release of AudioQuake), you could issue the following commands.
    
    ``` screen
    svn co http://svn.agrip.org.uk/trunk/zq-repo/
    svn co http://svn.agrip.org.uk/trunk/audioquake/
    ```
    
    If you do that, because of the way the build system works, it would be helpful for you to make a `trunk/` directory (it can have any name, though) and check out the individual components into it. This will help you later on, when you will need to put things such as engine binaries in places the build system can find.
    
    If you are behind a nasty proxy, this may not work, in which case you can use the URL `svn://agrip.org.uk/agrip/trunk/audioquake/` but don’t supply any authentication information.

2.  You can update your working copy at any time by issuing the **svn up** command in any checked-out directory.

## Compiling the Code – Step by Step

Remember that the build scripts, used to generate packages for releases, will only work on UNIX-like systems (currently). Other notes on the use of Windows can be found below.

### From Source to Package for Release (UNIX-like Systems Only)

1.  To compile the ZQuake engine, go into the `trunk/zq-repo/zquake/` directory relative to the place where you checked-out from Subversion.

2.  You can then compile ZQuake by issuing **make** on a UNIX-like system, or using Visual Studio on Windows.
    
    **Note:** Currently on UNIX-like systems, X is required. We are working on removing the need for graphical output and hopefully in the future this will not be the case. Using **make help** should give you the information you need to choose a compilation target.

3.  The standard build scripts for AudioQuake assume that ZQuake engine binaries for various platforms and architectures (e.g. Linux/PowerPC, Windows (x86)) are placed in a certain directory for inclusion in release packages. This directory is, by default, `../../redist/`. If you checked-out the `trunk/` from Subversion, put a `redist/` directory in the same place as it n your filesystem. If you place engine binaries there, they’ll be picked up. Conversely, if you *don’t* they won’t be and your release packages may be out-of-date\!

4.  Go into the `trunk/audioquake/` directory (from the location you checked-out from) and issue **compile-mod-tree** to compile the latest gamecode (**zqcc** is automatically built for you during this process, from the code in the `trunk/zq-repo/zqcc/` directory) and have a release of AudioQuake installed into your home directory.
    
    As part of the build process, the standard set of maps (compiled into BSP form), demos and skins are downloaded from <http://docs.agrip.org.uk/devfiles/>. This means that you don’t need to worry about compiling/finding them when you build a release.
    
    If you’re happy with the results, you can make packages for release by issuing **make-release**. By default, packages are generated in `../../releases/`. This means that if you check out the `trunk/`, you can make a `releases/` directory next to it, along with the `redist/` one from earlier.
    
    **Note:** Windows releases need to be further processed into `setup.exe`–style files for distribution. This must be done on Windows. A ZIP file with an appropriate `setup.iss` (Inno Setup) file for this release will be generated; you can then put that on a Windows box to create the installer.

### Compiling the ZQuake Engine on Windows

To create packages for release, you need to use a UNIX-like system currently (it will create ZIP files that are turned into self-installers for Linux and can be turned, with the help of Inno Setup on Windows, into a Windows setup program). The previous section contains instructions on this.

It is possible to build the ZQuake engine alone on Windows without using a UNIX-like system, however. To compile with Visual Studio 2003, take the following steps.

1.  You’ll need the **gas2masm** and **ml** utilities to assemble the `.asm` files used by the engine. You can download an archive containing these from [the AGRIP documentation site](http://docs.agrip.org.uk/devfiles/src-need.zip). Extract this archive into your `/trunk/zq-repo/zquake/source/` directory.

2.  To ensure you’re using the right settings for compilation, copy the `.sln` and `.vcproj` files from `/trunk/zq-repo/zquake/vidnull/` to `/trunk/zq-repo/zquake/source/`.

3.  To compile the server and OpenGL engine, open the `.sln` file in VS2003 and choose the “GLRelease” configuration from the configuration manager. Then compile **zqds** and **zquake** projects.

4.  To apply the vidnull patch, needed for users of screen readers that cannot cope with OpenGL applications, copy the `.c` files from `/trunk/zq-repo/zquake/vidnull/` to `/trunk/zq-repo/zquake/source/`.

5.  To compile the vidnull patch, go back into VS2003 by opening the `.sln` file as before, then choose the “VNRelease” configuration and compile the **zquake** project.

## Documentation, Build Scripts and AGSay

Lots of the programs in the AudioQuake area of the repository are documentation and build scripts. They can all be built on UNIX, provided you have the requisite tools (the only potentially exotic requirement is a DocBook XML installation and an XML/XSLT processor). You will also find an Inno Setup script for creating installers on Windows.

**Note:** It is possible to compile DocBook documents on Windows, but the set-up of the various tools required is laborious. We have previously done this and may be able to provide a ZIP of the appropriate set-up for you, but cannot provide support for it. Contributions on DocBook toolchains for Windows are welcome\!

The “AGSay” program is used by `start.pl` to interface with the SAPI TTS on Windows. If you need to compile it, you need to have a SAPI 5.x series SDK installed. Licencing restrictions prevent us from including certain parts of this – such as the MSI Merge Modules – so if you want to build an entire release that includes SAPI components you’ll unfortunately have to download those too).

On UNIX platforms, eflite (the Emacspeak Flite speech server) is used for speech and standard serial ports and settings may be used for Braille output.
