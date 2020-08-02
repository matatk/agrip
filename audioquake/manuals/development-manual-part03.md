# Creating/Modding Gamecode

## QuakeC

### Basic Overview of the Technology

QuakeC is a high-level gamecode language that is compiled into bytecode/assembly instructions for the QuakeC Virtual Machine (in much the same way that Java and Perl work). The virtual machine is what executes your compiled-down code (the .dat files). The reasons why a virtual machine is used are portability (QuakeC works on all platforms that *Quake* does) and security (your mod cannot access anything outside of the QuakeC VM, other than the “builtin” functions that the *Quake* engine provides).

The engine provides builtin functions for doing performance-critical calculations (such as working out if a particular 3D vector corresponding to the aim of a weapon would hit a player) and interfacing with the outside world via the presentation of content to the user, such as sounds (e.g. when a weapon fires, a sound is made).

The whole gamecode for *Quake*, with AGRIP extensions, and any modifications you make must be compiled together into one `.dat` file. All of the code you need is in the Subversion repository. Unfortunately this has the side effect that only one modification can running any time; the Unreal engine (which powers a competing series of games) provides some ways to combat this and run multiple modifications at once. Alas it is not Open Source so hasn’t been made accessible yet. In practise this limitation of the *Quake* engine should not make too much difference, as the user can have multiple mods installed at any time (the game launcher and QMOD system take care of this).

### The Language

QuakeC is similar to C in nature. This is not a tutorial on the language itself; it is assumed the reader is used to programming in general. Much information can be found through the resources listed in [appendix section](#ref-qc "QuakeC") on the matter.

### Building Code – The Basics

QuakeC (`.qc`) files must be compiled into a `.dat` to be run by the game. The gamecode for the entire game is composed of many QuakeC files. Some of the files are only applicable to the single-player game and some are multiplayer-specific, so actually two `.dat` files are usually built (one for each type of gameplay).

Which QuakeC files are compiled together, and the order in which that’s done, is dictated by a `.src` file. This is a text file that lists the name of the output file on the first line and, on following lines, the QuakeC files to be processed. ZQuake is a *QuakeWorld* (multiplayer) game engine, but has had the single player monsters and AI ported to it. Because of this, the convention is for there to be a `progs.src` file used to produce the multiplayer `progs.dat` code, and a `spprogs.src` file that is used to create the singleplayer `spprogs.dat`.

Building of the QuakeC code as part of the whole *AudioQuake* release is covered in more detail elsewhere in the manual. The important part from a QuakeC perspective is that the ZQuake QuakeC Compiler (**zqcc**) must be run on a suitable `progs.src` file to turn the QuakeC files into a `.dat` file for the game to run.

### ZQuake Modular Gamecode

The ZQuake project hosts gamecode for a number of popular game modes and mods. This includes a version of the classic single-player *Quake* gamecode ported to *QuakeWorld*. It is laid out in a number of directories as follows.

  - ctf, kteams, ktffa
    Gametypes that have not yet been made accessible. Note that this version of CTF is not under active development and kteams is a deathmatch-like mode (we decided to make the classic *Quake* TeamDM more akin to that found in later games such as Unreal Tournament rather than adopt this mod).

  - tutor, zeus, kteamsbot, frikbot
    Code for various bots which we don’t use.

  - hipnotic
    Code for the mission pack “The Scourge of Armagon” (also unused).

  - qw
    Where it all started – a maintained version of the *QuakeWorld* (DM, Classic TeamDM) gamecode.

  - qwsp
    The extra code on top of that in the `qw/` directory to add all the elements of single player classic *Quake*.

    **Note:** As with other code here, lots of it is linked and depends on code in other directories. Most code uses a lot of the stuff in the `qw/` directory and this one is no exception.

    Such tight linking of code keeps the codebase small, easy to maintain and reliable.

  - agrip
    Our accessibility hooks into the main game (both QW and QWSP versions are catered for, though the use of different `.src` files, which tell ZQCC how to build the AGRIPified gamecode `.dat`s.

    **Note:** Again, our code links heavily to that in the `qw/` and `qwsp/` directories.

As has been pointed out, much of the code hare is linked and when you develop a mod, we recommend you start a new top-level directory in here and reuse as much of the existing code as you can. Start with one of the AGRIP `progs.src` files and add any extra `.qc` files you might need in your own directory.

**Note:** If you need to override any functions in the main code, don’t replace an entire file with your own version – there is a way for you to override individual functions elsewhere in the code, which will be explained later.

Constructing your mod in this way has the advantages of much easier upgrades between AGRIP versions (as if you follow the guidelines here you’ll be hooking into our code mostly and won’t have to worry about changes in the stock ZQuake code). It also keeps your mod’s codebaese small, simple and therefore easy to maintain and (hopefully\!) more reliable.

Guidelines for constructing your mod in this way can be found throughout this guide.

## AGRIP Gamecode System

### Philosophy

The gamecode used in *AudioQuake* has two main goals:

  - Providing Game Accessibility
    This is achieved by adding features to the gameplay such as navigation aids and audio cues for events. Techniques used include the addition of entities, use of impulses, addition of sound functions (some directed at specific clients) and bots.
  - Supporting Development
    By acting as a layer on top of the *Quake* gamecode, the AGRIP code allows developers to hook into it, use its accessibility functions and not have to worry about changes in the underlying gamecode. Developers’ lives are made easier when they use the modular ZQuake/AGRIP gamecode system as they can keep the footprint of their mods as small as possible. Ways to do this are detailed throughout this manual, but include the ability to re-use all existing standard and AGRIP code and the provision of hooks into the AGRIP code at convenient points.

Many functions created in the development of *AudioQuake* are written to be as generic as possible. They form what could be thought of as an “accessibility library” on top of the standard QuakeC.

**Note:** This modular design approach was tested… all bot navigation code was modified to use the AGRIP accessibility aid functions. This meant that the bots’ perception of the world was essentially that of a blind player. The bots performed well and began to navigate in a similar style to that of most blind gamers.

### Layout and Design

Our recommended method of setting up your mod, in terms of directory structure and code re-use, can be found above. This section explains how the AGRIP code is laid out internally (i.e. inside the `agrip/` directory).

**Tip:** The source code is heavily commented; take advantage of this to learn how to make best use of the library code that has been written for your mods.

  - agrip\_defs.qc
    Stores definitions (global variables, entity fields) for the AGRIP mod. This file should be read by mod developers to learn about the various hooks in our code that are available to them. An example hook is AGRIP\_MODHOOK\_PRECACHE, which allows you to define a function that is called to precache extra data your mod needs.

    **Note:** If you need a hook into a function and we don’t provide one currently, you should ask us to create one. The reason is that in future, if the QC code for ZQuake changes, your mod may well not work. If you hook into ours, though, we can shield you from such effects of change to the underlying gamecode. Proposals for new hooks should be sent to the mailing list.

  - d5k.qc
    The Detector 5000.

  - epi.qc
    The “Auxiliary/Extended Player Information” object. This is needed because the player doesn’t have enough entity fields spare to store all of the information we need to store (such as is used for collision detection). Each player is given a private one of these when they spawn and the information it records is used by lots of other AGRIP code.

  - esr.qc
    The EtherScan RADAR.

  - extnav.qc
    Navigational aids that do not rely on the presence of the “nav” object.

  - hooks.qc
    Hooks from AGRIP into the main QuakeC gamecode. DO NOT confuse this with the way we provide hooks into our code for mod developers; this file simply contains AGRIP code that we’ve put here to lower the footprint on the QuakeC gamecode as a whole.

    The procedure for hooking into our code is described FIXME elsewhere.

  - marker.qc
    The waypoint marker object.

  - nav.qc
    This is a huge QC file that contains the core navigation helper object. The player uses this to get feedback on where they are, what hazards are present and so on.

  - progs.src
    This is the “makefile” for the *QuakeWorld* gamecode. It lists all the `.qc` files that need to be compiled for the multiplayer game modes to work. The first line gives the output filename (a `.dat` file, that contains the compiled QuakeC gamecode).

    You’ll notice that some external files are included (from other QC source directories described above). They are from the original *QuakeWorld* gamecode; the AGRIP code augments them and hooks into them in certain places. Your mod code should aim to avoid hooking directly into these files; rather it should hook into the AGRIP code where possible (please tell us if that isn’t possible)

  - se.qc
    Sound entity object, created to provide loopable, movable and removable sounds. Used extensively by other AGRIP code.

  - spprogs.src
    This is the same type of file as `progs.src`, but is aimed at the single-player gamecode. Therefore, the monster and AI code is included too.

  - tutor.qc
    The bot we use, written by Darryl “Coffee” Atchison.

  - tutor\_support.qc
    A file that contains the functions that the Tutor Bot needs to function when compiled for multiplayer gamecode (it requires some AI and other functions from the singleplayer code).

### Comprehensive Documentation on the AGRIP Gamecode Library

Each function contains a header comment. The information provided by the comment is designed to help you use the function in your own modifications. In fact, all of the code has been prepared in such a way that a special tool can process it and turn it into a website that allows you to learn about any individual function. The idea is that you can look up functions by name, or the type of work they do, and see where they fit into the rest of the code (and how they work).

If you’d like to visit the “Doxygen” documentation on the AGRIP QuakeC code, go to [the AGRIP documentation site](http://docs.agrip.org.uk/).
