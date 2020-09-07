AudioQuake, Level Description Language and distributed software---Licences
==========================================================================

This file describes the licencing terms for AudioQuake, the Level
Description Language (LDL) tools and the supporting data and programs
distributed with them (not all created by us). It exists to make sure
that you're completely aware of what you (and we) can and can't do with
the software. After the following summary, each section describes a
component of the AudioQuake and LDL distribution and the licence used
for it.

tl;dr:
------

There are three licences in use:

-   The documentation (AudioQuake user and development manuals, and
    Level Description Language tutorial, as well as other text files
    such as this) is distributed under the GNU Free Documentation
    Licence (GFDL).
-   The Prototype textures are copyright 2017-2019 by Aleksander
    "Khreathor" Marhall (<khreathor@khreathor.xyz>;
    <https://twitter.com/khreathor>). They're freely usable in Quake or
    any game, as long as Aleksander gets a credit, which is totally
    reasonable: thanks Aleksander!
-   Everything else is distributed under the GNU General Public Licence
    (GPL), version 2 or later.

ZQuake
------

This is the QuakeWorld game engine on which AudioQuake is based. It is
distributed under the GNU General Public Licence (GPL). For more
information, please read the COPYING file.

Quake map compilation tools
---------------------------

This repo builds on id's "Quake Tools" code, which is also released
under the GNU GPL.

That code is linked to this repo via a submodule, and the compiled tools
are distributed as part of the AudioQuake and LDL bundle. Some patches
(maintained in this repo) are applied to ensure the software will build,
and to relax constraints it places on the paths where WAD files are
located. Those patches, as they're both applicable to GPL'd software,
and reside in this repo, are too distributed under the GPL.

Open Quartz data pack
---------------------

The Open Quartz game data, which includes sounds, textures, models,
maps, gamecode (although the AGRIP gamecode is used instead) and UI
graphics, is included out-of-the-box. This means you can have fun right
away, even if you haven't bought Quake. You can make maps and play
multiplayer games with Open Quartz.

The project is hosted on another service, but development stopped some
time ago, so the latest data files are included here and, as usual, are
covered by the GNU GPL.

AudioQuake (gamecode and data)
------------------------------

Our modified gamecode and sounds are the resources we've added to the
ZQuake engine, vanilla gamecode and in-game data to make it accessible.
The licence used here is the GPL. For details on what this means, please
consult the COPYING file.

We did not create all of the sounds from scratch: some are derivative
works and some were donated to us. However they are all distributed
under the GPL too. Please check out the [AudioQuake
ACKNOWLEDGEMENTS](audioquake/ACKNOWLEDGEMENTS.md) file for details---and
many thanks to everyone on whose work we've been able to build!

AudioQuake and LDL launcher
---------------------------

The launcher is a separate program to the game engine and data. It
provides a UI for running, customising, modding and making maps for the
game, as well as text-to-speech facilities for when the game is running.
Again, this is distributed under the GNU GPL. For details on what this
means, please consult the COPYING file.

Level Description Language tools
--------------------------------

The LDL library and UI (integrated into the launcher) were developed as
part of AGRIP and are released under the GNU GPL, as above.

Prototype textures
------------------

These textures are used in the high-contrast variants of maps. They are
freely usable in Quake or other games, and are copyright 2017-2019 by
Aleksander "Khreathor" Marhall (<khreathor@khreathor.xyz>;
<https://twitter.com/khreathor>). Thank you, Aleksander!

AudioQuake and Level Description Language documentation
-------------------------------------------------------

The manual for AudioQuake and documentation for LDL are distributed
under the GNU Free Documentation Licence (FDL). A copy of this is
included in an appendix of the AudioQuake manual.
