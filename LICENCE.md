AudioQuake, Level Description Language and distributed software -- Licences
============================================================================

**Note:** only certain components of the game and supporting tools are distributed under a "Free Software" licence.  Some parts, which are downloaded during compilation/installation, were not developed by us and are owned by their respective developers.

This file aims to clarify the licencing terms that AudioQuake, Level Description Language (LDL) and the supporting data and programs distributed with them fall under.  It exists to make sure that you're completely aware of what you (and we) can and can't do with the software.  Each section describes a component of the AudioQuake and LDL distribution and the licence used for it.


Quake Data Files
-----------------

There are two types of Quake data file -- the shareware data (mostly contained in "pak0.pak") and the registered data (mostly contained in "pak1.pak").  Both types of data cannot be modified.  They are owned by id Software.  The shareware data can be redistributed as-is (and the build scripts do this when compiling the application bundle) but the registered data cannot.

The Quake data files constitute the Quake sounds, models, textures, maps, miscellaneous 2D graphics, original Quake text files (such as the README, MANUAL and TECHINFO files), DOS/Windows game executables, VXD, BAT and DLL files and the original Quake game code (not used by AudioQuake but distributed as part of the Quake data files).


mindgrid:audio Quake Sound Files
---------------------------------

Please visit http://www.mindabuse.com/mindgrid/audio/quake/ for more information (and to give feedback) after reading this file.

These sounds upgrade the ones in Quake to give you a truly visceral experience :-).  Note that the documentation supplied with the distribution points out that the sounds are licenced material and are not to be redistributed outside of their original form (the build scripts download a compressed version of the "mindgrid-audio_quake_2003.02.22/" directory and extract it for you).  These sounds are not to be used for modifying anything but Quake, either.  The aforementioned directory contains both README files, which echo the information given on the web site above.


ZQuake
-------

This is the QuakeWorld game engine on which AudioQuake is based.  It is distributed under the GNU General Public Licence (GPL).  For more information, please read the COPYING file.


AudioQuake (The Program)
-------------------------

Our modified gamecode (the .dat files in "agrip/"), maps (files in "agrip/maps") and sounds (files in and under the "agrip/sounds" directory) fall under this category.  It is the code and data that we have added to the ZQuake QuakeWorld engine, game code and original Quake data to make it accessible.  The licence used here is the GNU GPL.  For details on what this means, please consult the COPYING file.


Level Description Language (Translation Programs)
--------------------------------------------------

These were developed as part of AGRIP and are released under the GNU GPL, as above.


Quake Engine Map Compilation Tools
-----------------------------------

These were not developed by us, but the QuakeForge project.  They are also released under the GNU GPL.


AudioQuake and Level Description Language Documentation
--------------------------------------------------------

The manual for AudioQuake and documentation for LDL are distributed under the GNU Free Documentation Licence (FDL).  A copy of this is included in an appendix of the AudioQuake manual.
