Getting Started
===============

Background Information
----------------------

### Target Audience

This manual is aimed at people who are either curious about how
AudioQuake works, want to develop modifications to it or use the
engine/gamecode as the basis for their own projects. It is expected that
the reader is reasonably familiar with software development using Linux
or Windows. Please be aware, however, that support is available from the
AGRIP team and mailing lists.

### Development Ethos

We work on providing blind and vision-impaired people with the tools to
make their own audio and audio/visual games. [The project
roadmap](http://www.agrip.org.uk/ProjectInfoSection/TheRoadmap) details
what our plans (influenced by community feedback) and this page explains
a little of how we do it – and how your projects can benefit.

### What we Provide

AudioQuake provides an accessible platform for game development,
including some of the tools you can use to create the games. The
following main features are provided:

-   The accessible [game engine](http://www.agrip.org.uk/GameEngine)
    known as ZQuake.

-   The [game code](http://www.agrip.org.uk/GameCode) that makes Quake,
    QuakeWorld and your mods accessible.

-   A comprehensive framework of utility and accessibility functions
    that you can take advantage of when creating your own game
    modifications.

-   Information on how the accessibility features in and outside of the
    engine work together.

-   The [Stats and Servers](http://stats.agrip.org.uk/) system,
    including authentication protocol.

-   Plans for OpenAL ("ImplicitAccessibility") support.

-   Plans for level editing tools. Long-term plans point to some work
    that will require significant research and development. Whilst this
    is ongoing, we will look into a tool that will help create simple
    levels at least.

It is highly recommended that new developers read
<http://www.agrip.org.uk/ProjectInfoSection> – specifically all of "The
Technology we Use" - for information on how all of this fits together.

### Licencing

AGRIP is an Open Source project. Anyone is welcome to use our tools and
code in the creation of their own games, provided that they keep their
creations open (i.e. release the source and derived data files, under
the GNU General Public Licence).

If you are interested in using our software as the basis for your own,
you must read [the licence](http://www.gnu.org/copyleft/gpl.html) fully
and ensure that you are aware of its ramifications. We are happy to
answer any licencing questions – please [contact
us](http://www.agrip.org.uk/ContactUs) to find out more.

Some chapters of the distributed packages are not subject to the GPL but
other licences – the LEGALINFO file you received (and agreed to when
installing AudioQuake) explains all.

If you feel that you absolutely must develop proprietary software based
on our code, please [contact us](http://www.agrip.org.uk/ContactUs) and
we may be able to arrange an alternative licence.

Components
----------

### Engine, Gamecode and Data

It is important to be aware that there are three main parts of modern
first-person shooters, all of which you can modify. The following list
summarises these parts and how modifying them can affect the game.

The Engine
:   The engine is the part of the game that computes all of the 3D
    graphics and takes care of other low-level issues such as sound,
    networking and receiving input from the keyboard and other
    peripherals.

    Modifying the engine may result in vastly different appearance (some
    mods for Quake have made it appear drawn as if it were a cartoon, or
    pencil outline drawing, for example). It may also improve the output
    of sound and/or networking capacity.

Gamecode
:   Gamecode is the high-level code that determines how the gameworld
    works. It controls things like how the player interacts with doors
    and buttons, how the weapons and powerups work and the behaviour of
    monsters.

    Modifying the gamecode can introduce new enemy or friendly
    characters, upgrade or replace weapons, items and alter the way that
    the environment (doors, slime and so on) works. Modifying the
    gamecode to create new gametypes is one of the most popular ways of
    developing with modern computer games and is relatively easy to do
    thanks to the high-level nature of the gamecode language (“QuakeC”
    in this case).

Data
:   The engine and gamecode are pointless without content that can be
    supplied to the user. The maps, textures (graphics applied to the 3D
    environment to increase realism), models (3D shapes of enemies,
    items, weapons), skins (textures applied to models) and sounds
    presented to the user are collectively known as the game data.

    Modifying the data alone can have a striking impact on the game,
    from adding new environments (maps) to making existing ones appear
    quite different. Different player and enemy models can also change
    things quite a bit (and are popular online). Sounds (such as the
    mindgrid expansion pack) can improve the player's experience
    significantly and alter the feel of the game.

**Note:** A “Total Conversion” of a game with this architecture is a
modification that replaces all components of the data, gamecode and
engine with modified versions. We welcome anyone to create TCs that turn
AudioQuake into the accessible 3D game they've always wanted to play!

### AudioQuake's Components

When running, the game “AudioQuake” is actually made up of the following
semi-separate parts:

An accessible build of the ZQuake [game engine](http://www.agrip.org.uk/GameEngine)
:   ZQuake is a mainstream QuakeWorld engine that has been made
    accessible by a series of small modifications. The maintainers have
    kindly allowed it to be used by the AGRIP project as the basis of
    AudioQuake.

The [game code](http://www.agrip.org.uk/GameCode)
:   The standard QuakeC gamecode has been customised to include a
    library of accessibility features. It is here that 90%+ of the AGRIP
    code runs.

The game launcher
:   A front-end to the engine that helps users set accessibility options
    and provides a channel for text-to-speech data to exit the engine
    for further processing before it is rendered. This allows us to
    provide high-level processing on text generated by the game that is
    inappropriate for the engine to deal with. It facilitates the use of
    multiple speech/braille back-ends, though this has not yet been
    used.

To build yourself a working release, you'll need the code for all these
parts of the game, as well as the game data. The data is the sounds,
models, maps and textures that make up the game world. The gamecode
directs the engine to play/render the data at the appropriate time (for
example, the gamecode for the D5k tells the engine when and where to
play sounds that correspond to items in the map).

Building the supporting tools and documentation will be covered in later
parts.

Fundamental Concepts
--------------------

This chapter introduces some vital concepts you need to be aware of and
understand before you can understand how modifying any aspect of the
game actually works.

### The Virtual File System (VFS)

A file system is basically the organised arrangement of objects
(normally files and directories) which make up your data. The VFS
(Virtual File System) is, as its name suggests, virtual. File systems on
your disks are not–they are stored on disk and comprise data you put on
that disk in that file system. The source of the data is a physical
device, and usually exclusively that device. By contrast, the VFS is
virtual–objects in the file system are loaded sequentially from various
sources, and the prevailing object in case of a conflict is the one
loaded last. This is important in understanding how a mod works.

When Quake starts, it scans a directory looking for files called “PAK
files”, so-called because their extension is .pak. These pak files are
numbered, starting from zero, and Quake loads these files in ascending
order. The pak file contains a file system, and this is loaded into the
in-game file system. The process is repeated for each pak file in this
directory.

Next, Quake will read a file system from a directory in your "Real" disk
file system. That directory typically contains a mod, and the user
specifies it with a command-line parameter to Quake when it is started.
Putting the files in the mod directory is equivalent to putting them
into an additional pak file (tools exist to help you do that) in the pak
files directory.

In both cases, when a file exists in the virtual file system, any
version loaded later with the same path will replace the one loaded
before it. Since the file system is virtual, the source of these files
is insignificant–it may be either the pak files or the mod directory,
and the loading behaviour will usually mean that mods get loaded over
in-game objects. The programmed game code does not make any special
differentiation between files loaded from one place as opposed to
another–it simply references the object desired, and the engine will
determine the ultimate location of the object.

#### Try it Yourself!

The best way to learn about how the PAK files are created is to extract
the data from them and experiment with changing it. You can use tools
such as [PakExplorer](http://quakestuff.telefragged.com/) to do this.

### Procedure for Modding AudioQuake

This section describes the overall process for modifying the game. The
list below describes a typical set-up that allows you to test your mod,
tweak things and quickly re-test. When you want to make packages of your
mod for end-users to quickly install and easily manage, you'll need to
read the part on
[QMODs](#qmod-intro "Chapter 11. An Introduction to QMODs"). The rest of
the manual goes into more detail on how you carry out certain stages in
this process, such as modifying content or gamecode.

1.  Add to/modify the gamecode, or add new content. (Note that modifying
    the engine would make the game no longer AudioQuake, hence it's not
    mentioned here, but accessible total conversions into entirely new
    games are very much encouraged!)

2.  Place your modifications into a new directory inside the AudioQuake
    directory, beside the `id1/`{.filename} directory that's already
    there. Any files in your directory with the same name as ones in
    `id1/`{.filename} (or inside the `.pak`{.filename} files) will
    override the pre-existing ones.

    For example, if you have changed some of the sounds in the game, you
    can recreate the directory structure of the `.pak`{.filename} files
    in `id1`{.filename}, including only the sounds you changed (the rest
    will still be loaded from the `.pak`{.filename} files). If your mod
    is called “testmod”, the sounds may be in
    `testmod/sound/player/`{.filename}. If you've modified the gamecode,
    put `progs.dat`{.filename} and `spprogs.dat`{.filename} into the
    `testmod/`{.filename} directory and they'll override the ones in
    `id1/*.pak`{.filename}.

3.  Start the game, telling it to load in your new modifications over
    the top of the default gamecode and content in `id1/`{.filename}.
    This is the standard way that mods work, by replacing certain parts
    of the original game content and/or code.

    In normal Quake, this would be done by specifying “+gamedir
    *`mod_directory`*” on the command line. In AudioQuake, however, this
    is done by changing the “default\_gamedir” line in the “general”
    section of `start.ini`{.filename} to the directory of your mod, as
    opposed to “id1”. This points the game at your mod for an extra
    source of content and gamecode (the contents of the
    `id1/`{.filename} directory will still be loaded into the VFS,
    however, as that's the standard Quake behaviour).

    **Warning:** This technique is intended to be used only by mod
    developers, when testing their mod (note that it stops you from
    being able to run standard AudioQuake). To make packages of your mod
    for end-users, please see the
    [QMODs](#qmod-intro "Chapter 11. An Introduction to QMODs") part.
    There are a number of advantages in using the QMOD method: users can
    install mods simply by double-clicking; they can switch between
    multiple mods easily via the launcher instead of having to edit a
    Perl script and your mod can be kept up-to-date with changes to the
    users' settings automagically by the AudioQuake launcher.

4.  Tweak and test, repeat as necessary.

5.  Package up your mod into a QMOD file. This requires that you put any
    mod-specific settings into a file named `mod.cfg`{.filename} in your
    mod's directory. Ensure that any `autoexec.cfg`{.filename} and/or
    `config.cfg`{.filename} files have been removed, as the QMOD system
    can copy over the user's settings, which are likely to be different
    than the ones you've specifed, into your mod for you. This enusres
    that key bindings and settings are consistent from the user's
    perspecitve. The QMOD system can keep your mod up-to-date with
    changes in the user's settings automatically. Read the
    [QMOD](#qmod-intro "Chapter 11. An Introduction to QMODs") part of
    this manual for information on the other steps you need to take.

The rest of this manual explains how to perform the modifications of
gamecode and engine, as well as packaging up your modification in QMOD
form, building AudioQuake releases from source and how the Stats and
Servers infrastructure works.

As map editing is not (currently) possible, it is not described. Work on
making map editing accessible is ongoing, however.
