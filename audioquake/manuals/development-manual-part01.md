Copyright (c)  2005-2021  Matthew Tylee Atkinson

Copyright (c)  2007  Sabahattin Gucukoglu

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.2 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled "GNU Free Documentation License".

# Getting Started

## Digital archaeology note from 2021

As with the user manual, please note this has been edited to keep it technically up-to-date, but is largely as written in the mid-2000s. Whilst you still *could* use *AudioQuake* as a development platform, it'd be more fun to work on creating the next accessible games development platform :-).

Alas the *Stats and Servers* system is no longer in operation due to time and support constraints, and we'd rather work to the future regarding the accessible level-editing tools mentioned here&mdash;but you can still use them to make levels non-visually, as discussed in the *Level Description Language (LDL)* tutorial.

## Background information

### Target audience

This manual is aimed at people who are either curious about how *AudioQuake* works, want to develop modifications to it or use the engine/gamecode as the basis for their own projects. It is expected that the reader is reasonably familiar with software development.

### Development ethos

Our goal was to provide blind and vision-impaired people with the tools to make their own audio and audio/visual games.

### What's provided

*AudioQuake* provides an accessible platform for game development, including some of the tools you can use to create the games. The following main features are provided:

* The accessible game engine from the *ZQuake* project.

* The gamecode that gives *Quake*/*QuakeWorld* their personality, but also makes them, and your mods accessible, due to the AGRIP additions.

* A comprehensive framework of utility and accessibility functions that you can take advantage of when creating your own game modifications.

* Information on how the accessibility features in and outside of the engine work together.

* ~~The [Stats and Servers](http://stats.agrip.org.uk/) system, including authentication protocol.~~

* ~~Plans for OpenAL ("ImplicitAccessibility") support.~~

* ~~Plans for level editing tools. Long-term plans point to some work that will require significant research and development. Whilst this is ongoing, we will look into a tool that will help create simple levels at least.~~

### Licencing

AGRIP is an Open Source project, based on the groundbreaking work of id Software, the *ZQuake* and *QuakeForge* projects, and many others. Anyone is welcome to use our tools and code in the creation of their own games, provided that they keep their creations open (i.e. release the source and derived data files, under the GNU General Public Licence).

If you are interested in using our software as the basis for your own, you must read the licence fully and ensure that you are aware of its ramifications.

## Components

### Engine, Gamecode and Data

It is important to be aware that there are three main parts of modern first-person shooters, all of which you can modify. The following list summarises these parts and how modifying them can affect the game.

* **The Engine** is the part of the game that computes all of the 3D graphics and takes care of other low-level issues such as sound, networking and receiving input from the keyboard and other peripherals.

  Modifying the engine may result in vastly different appearance (some mods for *Quake* have made it appear drawn as if it were a cartoon, or pencil outline drawing, for example). It may also improve the output of sound and/or networking capacity.

* **Gamecode** is the high-level code that determines how the gameworld works. It controls things like how the player interacts with doors and buttons, how the weapons and power-ups work and the behaviour of monsters.

  Modifying the gamecode can introduce new enemy or friendly characters, upgrade or replace weapons, items and alter the way that the environment (doors, slime and so on) works. Modifying the gamecode to create new gametypes is one of the most popular ways of developing with modern computer games and is relatively easy to do thanks to the high-level nature of the gamecode language ("QuakeC" in this case).

* **Data.** The engine and gamecode are pointless without content that can be supplied to the user. The maps, textures (graphics applied to the 3D environment to increase realism), models (3D shapes of enemies, items, weapons), skins (textures applied to models) and sounds presented to the user are collectively known as the game data.

  Modifying the data alone can have a striking impact on the game, from adding new environments (maps) to making existing ones appear quite different. Different player and enemy models can also change things quite a bit (and are popular online). Sounds can improve the player's experience significantly and alter the feel of the game.

**Note:** A "Total Conversion (TC)" of a game with this architecture is a modification that replaces all components of the data, gamecode and engine with modified versions. We welcome anyone to create TCs that turn *AudioQuake* into the accessible 3D game they've always wanted to play!

### *AudioQuake*'s Components

When running, the game "*AudioQuake*" is actually made up of the following semi-separate parts:

* An accessible build of the *ZQuake* game engine.

  ZQuake is a mainstream *QuakeWorld* engine that has been made accessible by a series of small modifications. The maintainers have kindly allowed it to be used by the AGRIP project as the basis of *AudioQuake*.

* The game code. The standard QuakeC gamecode has been customised to include a library of accessibility features. It is here that 90%+ of the AGRIP code runs.

* The *AudioQuake* launcher. A front-end to the engine that provides a channel for text-to-speech data to exit the engine for further processing before it is announced. But it also provides tools for setting up the game, installing and managing mods, and helping users make their own maps non-visually via the *Level Description Language (LDL)* tools (documented in the LDL tutorial).

To build yourself a working release, you'll need the code for all these parts of the game, as well as the game data. The data is the sounds, models, maps and textures that make up the game world. The gamecode directs the engine to play/render the data at the appropriate time (for example, the gamecode for the D5k tells the engine when and where to play sounds that correspond to items in the map).

Building the supporting tools and documentation is covered in the `BUILD.md` files in the repository.

## Fundamental concepts

This chapter introduces some vital concepts you need to be aware of and understand before you can understand how modifying any aspect of the game actually works.

### The virtual file system (VFS)

A file system is basically the organised arrangement of objects (normally files and directories) which make up your data. The VFS (Virtual File System) is, as its name suggests, virtual. File systems on your disks are not–they are stored on disk and comprise data you put on that disk in that file system. The source of the data is a physical device, and usually exclusively that device. By contrast, the VFS is virtual–objects in the file system are loaded sequentially from various sources, and the prevailing object in case of a conflict is the one loaded last. This is important in understanding how a mod works.

When *Quake* starts, it scans a directory looking for files called "pak files", so-called because their extension is .pak. These pak files are numbered, starting from zero, and *Quake* loads these files in ascending order. The pak file contains a file system, and this is loaded into the in-game file system. The process is repeated for each pak file in this directory.

Next, *Quake* will read a file system from a directory in your "Real" disk file system. That directory typically contains a mod, and the user specifies it with a command-line parameter to *Quake* when it is started. Putting the files in the mod directory is equivalent to putting them into an additional pak file (tools exist to help you do that) in the pak files directory.

In both cases, when a file exists in the virtual file system, any version loaded later with the same path will replace the one loaded before it. Since the file system is virtual, the source of these files is insignificant–it may be either the pak files or the mod directory, and the loading behaviour will usually mean that mods get loaded over in-game objects. The programmed game code does not make any special differentiation between files loaded from one place as opposed to another–it simply references the object desired, and the engine will determine the ultimate location of the object.

<!-- FIXME?
#### Try it yourself!

The best way to learn about how the pak files are created is to extract the data from them and experiment with changing it. You can use tools such as [PakExplorer](http://quakestuff.telefragged.com/) to do this.
-->

### Procedure for Modding AudioQuake

This section describes the overall process for modifying the game. The list below describes a typical set-up that allows you to test your mod, tweak things and quickly re-test. When you want to make packages of your mod for end-users to quickly install and easily manage, you'll need to read the part on [QMODs](#qmod). The rest of the manual goes into more detail on how you carry out certain stages in this process, such as modifying content or gamecode.

1. Add to/modify the gamecode, or add new content. (Note that modifying the engine would make the game no longer *AudioQuake*, hence it's not mentioned here, but accessible total conversions into entirely new games are very much encouraged!)

2. Place your modifications into a new directory inside the *AudioQuake* directory, beside the `id1/` directory that's already there. Any files in your directory with the same name as ones in `id1/` (or inside the `.pak` files) will override the pre-existing ones.

   For example, if you have changed some of the sounds in the game, you can recreate the directory structure of the `.pak` files in `id1`, including only the sounds you changed (the rest will still be loaded from the `.pak` files). If your mod is called "testmod", the sounds may be in `testmod/sound/player/`. If you've modified the gamecode, put `progs.dat` and `spprogs.dat` into the `testmod/` directory and they'll override the ones in `id1/*.pak`.

3. Start the game, telling it to load in your new modifications over the top of the default gamecode and content in `id1/`. This is the standard way that mods work, by replacing certain parts of the original game content and/or code.

4. Tweak and test, repeat as necessary.

5. Package up your mod into a QMOD file. This requires that you put any mod-specific settings into a file named `mod.cfg` in your mod's directory. Ensure that any `autoexec.cfg` and/or `config.cfg` files have been removed, as the QMOD system can copy over the user's settings into your mod for you. This ensures that key bindings and settings are consistent from the user's perspective. The QMOD system can keep your mod up-to-date with changes in the user's settings automatically. Read the [QMODs](#qmod) part of this manual for information on the other steps you need to take.

The rest of this manual explains how to perform the modifications of gamecode and engine, as well as packaging up your modification in QMOD form.

For non-visual map editing, please refer to the *Level Description Language (LDL)* tutorial.
