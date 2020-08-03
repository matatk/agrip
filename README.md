AGRIP AudioQuake and Level Description Language
===============================================

*AudioQuake* and the *Level Description Language* were successful
experiments started in 2003 to see if it was possible to make a
mainstream first-person shooter (FPS) accessible to blind and
vision-impaired gamers. We sought to afford access not only to the game
*Quake*, but also to the surrounding community of modding and even the
creation of new levels ("maps").

These aims were realised, with the help of the community during 2003,
when we focussed on single-player and 2004, when the first networked
accessible deathmatches were played and user-made mods were debuted.
*Level Description Language*, which allows blind people to architect 3D
maps, was released in 2008.

Whilst the original *Quake* game is no longer mainstream, the experiment
was successful (in that a number of single-player maps and many
deathmatch maps are accessible, and blind gamers have created additional
mods and maps for the game) and the lessons learnt apply equally well to
modern FPSs. Also, we developed some accessibility techniques we'd like
to share and that we'd be delighted if others might adopt for their own
projects; particularly the *Level Description Language* as this empowers
blind gamers (and its present "90-degree expressiveness" limitation is
due only to a lack of advanced geometry on our part).

Over the years since, it's been truly awesome to witness the strides and
leaps in game accessibility that have been made possible by the
continuing hard work of independent and large-scale developers, gamers
and advocates the world over. We can't wait to find out what's next!

The aims of this repo are to...

-   ensure it's easier than ever to play *AudioQuake* and use the *Level
    Description Language*;
-   preserve this part of accessible gaming for the future and
-   to welcome any contributions and improve upon components such as the
    base game, tools, sounds, and other aspects.

AGRIP stands for "Accessible Gaming Rendering Independence Possible".
For more information and links to academic research papers, visit
<http://agrip.org.uk>.

AudioQuake
----------

*AudioQuake* is a version of *Quake* (by id Software) that has enhanced
audio and speech output, so that blind and vision-impaired gamers can
play it (including a number of the standard maps). The code is based on
the *ZQuake* engine, is mature and supports various forms of networked
play. A tutorial, documentation and some specifically-designed
accessible maps are included.

It is also possible to create mods for the game, by changing the sounds
(and other content) and modifying the QuakeC gamecode. A number of
community members have created mods, from the obligatory and
most-welcome Star Wars conversions to "excessive overkill"-style
fragfests. The standard modding tools can be used for this, as they are
inherently accessible.

You need the official *Quake* data files for the game to work.

*Quake* has a "15" certificate. For obvious reasons, we do not recommend
nor condone the use of this software by anyone below 15 years of age.

Level Description Language
--------------------------

The *Level Description Language* allows people to describe maps for the
game using structured text and have the computer automatically create
the 3D world. It has some geometrical limitations, as mentioned above,
but is a robust and fully 3D map creation and styling system that has
been used by blind people to make maps for the game.

You can access and use the *Level Description Language* tools via the
*AudioQuake* launcher.
