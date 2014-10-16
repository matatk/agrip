AGRIP AudioQuake and Level Description Language
===============================================

AudioQuake and the Level Description Language were successful
experiments started in 2003 to see if it was possible to make a
mainstream First-person Shooter (FPS) accessible to blind and
vision-impaired gamers. We sought to afford access not only to the game,
but also to the surrounding community of modding and even the creation
of new levels ("maps").

These aims were realised, with the help of the community during 2003,
when we focussed on single-player and 2004, when the first networked
accessible deathmatches were played and user-made mods were debuted.
Level Description Language (LDL), which allows blind people to architect
3D maps, was released in 2008.

Whilst the original Quake game is no longer mainstream, the experiment
was successful (in that a number of single-player maps and many
deathmatch maps are accessible, and blind gamers have created additional
mods and maps for the game) and the lessons learnt apply equally well to
modern FPSs. Also, we developed some accessibility techniques we'd like
to share and that we'd be delighted if others might adopt for their own
projects; particularly the Level Description Language as this empowers
blind gamers (and its present "90-degree expressiveness" limitation is
due only to a lack of advanced geometry on our part).

The aims of this repo are to...

-   ensure it's easier than ever to play AudioQuake and use the Level
    Description Language;
-   preserve our contribution accessible gaming for the future and
-   to welcome any contributions and improve upon components such as the
    base game, tools, sounds, and other aspects.

AGRIP stands for "Accessible Gaming Rendering Independence Possible".
For more information and links to academic research papers, visit
<http://agrip.org.uk>.

AudioQuake
----------

AudioQuake is a version of Quake (by id Software) that has enhanced
audio and speech output, so that blind and vision-impaired gamers can
play it (including a number of the standard maps). The code is based on
the ZQuake engine, is mature and supports various forms of networked
play. A tutorial, documentation and some specifically-designed
accessible maps are included.

It is also possible to create mods for the game, by changing the sounds
(and other content) and modifying the QuakeC gamecode. A number of
community members have created mods, from "excessive overkill"-style
bloodbaths, to the obligatory and most-welcome Star Wars conversions.
The standard modding tools can be used for this, as they are inherently
accessible.

You need access to some official Quake data files for the game to work.
The shareware version and an enhanced sound pack are included. You can
also use the full ("registered") Quake data files too.

Level Description Language
--------------------------

The Level Description Language (LDL) allows people to describe maps for
the game using structured text and have the computer automatically
create the 3D world. It has some geometrical limitations, as above, but
is a robust and fully 3D map creation and styling system and has been
used by blind people to make maps for the game.
