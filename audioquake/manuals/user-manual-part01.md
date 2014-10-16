Introduction
============

This part of the manual aims to introduce AudioQuake and gives you
details on how to get it set up on your computer.

Important Note
--------------

AudioQuake builds on the foundation laid by AccessibleQuake. This is a
tried-and-tested stable release, which allows you to take advantage of
the new features that have been implemented over and above our previous
game. Currently these are full support of Internet play, various related
enhancements to the user interface and manual, a new setup routine and a
large number of minor improvements to the gameplay. The other planned
improvements will be introduced as we reach version 1.0.0.

By all means, join in the development and make AudioQuake what you want
it to be. Feel free to give feedback on the [mailing
lists](http://www.agrip.org.uk/CommunityResources/MailingLists), join
the web community and voice your opinions. This project has always been
and will always be what you make of it.

What is AudioQuake?
-------------------

AudioQuake is essentially a series of modifications to the game Quake by
id Software that enable blind and vision-impaired people to play it.
Actually, it is (or will be) quite a lot more than just that. This
chapter explains the main things you need to know about AudioQuake to
understand what it does and why it's here.

So, AudioQuake is...

### More than just an “Accessible Game”

AudioQuake is based on earlier software from AGRIP called
“AccessibleQuake”. The previous game's ethos was to prove that
accessibility barriers can be lowered and it allowed blind gamers to
play singleplayer Quake (or offline multiplayer with computer-generated
opponents). AudioQuake's philosophy is to take this idea to its logical
extreme and allow blind and vision-impaired players not only access to
Quake, but *equal* access to both the game *and* the community of
Internet play and level design and creation of new modified games that
surrounds it. AudioQuake provides this via the following three main
features:

-   Support for Internet multiplayer games in a variety of game modes
    such as co-operative, deathmatch, team deathmatch and capture the
    flag (provided via our use of the ZQuake “QuakeWorld” game engine).
    The traditional singleplayer gametypes are, of course, supported.

-   “Implicit Accessibility” – The use of modern 3D audio and special
    effects technology to make the game inherently more accessible.
    This, in turn, means that the difference between the software that
    the sighted and blind use is dramatically minimised. For all intents
    and purposes, you'll be playing *the same* game.

-   Accessible level-editing tools. These will allow you to create your
    own levels (“maps”) for the game; something that sighted gamers have
    been able to do for some time. Coupling this with the fact that you
    can create your own code modifications easily, AudioQuake could be
    used as a platform for making your own games!

**Note:** Please remember that at the current stage of development only
the first of these three features have been fully implemented. We await
community feedback on how we're doing so far and will continue to
develop AudioQuake over time to bring you these benefits.

### Quake

At first it may seem obvious that AudioQuake is, well, Quake. This idea,
however, has had a profound impact on how the game is designed. At all
times, we have tried to maintain the spirit of Quake. You will not find
a lot of voice-over information because Quake didn't have it – our
accessibility features are designed to use intuitive techniques and
sounds so that you are not distracted from playing the game. We have
only added the accessibility features necessary to play the game
effectively. To keep things fair, we've not allowed AudioQuake players
to do anything Quake players can't (within reason).

This design philosophy comes across in the way the accessibility
features present themselves in the game. The idea is that an AudioQuake
player is no different than a Quake player, but they have in their
possession certain “objects” that provide accessibility features such as
enemy detection (the EtherScan RADAR), item detection (the Detector
5000) and navigation (the Navigation Helper). Many features can be
toggled on or off according to your individual taste and level of sight.

**ImplicitAccessibility**

As AudioQuake development brings more of the key features mentioned
above into play, these objects, or parts of them, should start to
disappear. This is because the information they provide will be
presented through the more realistic (audio) modelling of the
environment.

We have tried our best to make it possible for AudioQuake players to use
the original Quake maps. Currently there are a number of maps from the
game that cam be played by blind players. A series of tutorial maps is
provided to help you get used to the game and we hope to provide a range
of custom-built accessible maps in the future.

In the end, the main point of AudioQuake is not to prove that video game
accessibility is possible, as this has already been established. The
main point is that *community* accessibility is possible – that blind
and vision-impaired players can use *the exact same software*, join
Internet games and contribute new maps and modifications, just as the
sighted are able to.

#### Not for Under-15s

Quake has a “15” certificate. For obvious reasons, this also applies to
AudioQuake. We do not recommend or condone the use of this software by
anyone below 15 years of age.

### Customisable

The game has been built to be customisable. You can change a great many
of the game-play aspects described below quite easily so that they suit
your taste and style of play. We are here to cater for a large range of
people from the blind to the vision-impaired. Everyone is different and
we're confident that you'll get a lot more out of AudioQuake if you
customise it.

The process of customisation is described [later
on](#customising "Part VI. Customising AudioQuake"). It's not difficult
and there is help provided along the way. It is probably a good idea to
read the next part and learn how to play the game before you delve in to
tweaking it, however!

### Free (as in Freedom)

Everything we have created for the project (code, sounds, tools) is
available for you to use, modify and redistribute. The licence we have
used for the project, the GNU General Public Licence, permits anyone to
do these things as long as they keep the source code to their work
available for others, just as we have for you.

Our reasons for making AudioQuake Free are that it should make it easier
for people to get hold of and play the game. The most important reason,
however, is described in the following section...

### Only the Beginning

We're building not just a game, but a framework with which you can
create your own games. This framework currently allows you to alter all
aspects of the way the game works and sounds, with level editing planned
for the future, as we get closer to the 1.0.0 version number.

With a number of commercial game engines now made Open Source, the
possibility of making other titles accessible is a reality. Some even
use the Quake engine – Half-Life would make a most amazing and immersive
accessible game due to its amazing sounds, AI, story line and massively
popular online game modes.

It is possible that later engines such as Quake3 and Unreal could be
made accessible even without access to the engine code. We wanted to
produce a Free game, which is why we didn't choose these titles. We also
thought that Quake would be a good starting point as it marked the dawn
of modern game engine design.

We would love to see a community spring up around AudioQuake and make
other games based on it. You can use any of our code and sounds. The
techniques we've used should be applicable to newer engines, too.

Installing AudioQuake
---------------------

This chapter explains how to get the game set up on your computer and
how to start it. For details on playing the game, please read the next
part of the book. The [download
page](http://www.agrip.org.uk/DownloadPage) on our web site provides all
of the information you'll need to get hold of the software. This section
explains what to do after you've got hold of it.

### Why Quake is Required and How to Try Before You Buy

As explained above, AudioQuake is a series of modifications to the game
Quake. For AudioQuake to function correctly, you must have Quake. Our
website details [how you can get hold of the
game](http://www.agrip.org.uk/DownloadPage/GettingQuake).

If you're uncertain as to whether you should go to the trouble of
getting hold of a copy of Quake, you can try running AudioQuake with the
“shareware” version of the game. This is a demonstration version that
only includes one of the four “episodes” of the full game. It contains
no deathmatch arenas so two game modes (deathmatch and team deathmatch)
will not be fully available. It should, however, give you a good idea of
if AudioQuake is for you.

The setup program for AudioQuake will give you the option of having the
shareware version of Quake automatically downloaded and installed. If
you've got the full version of the game on CD, this isn't necessary.

### mindgrid:audio

An excellent expansion pack has been created that upgrades many of the
sounds in the game to much more high-resolution and visceral levels. You
can elect to have this pack installed when you install the game – and it
is highly recommended.

The pack was not made by AGRIP; more information on mindgrid:audio can
be found [on its web
page](http://www.mindabuse.com/mindgrid/audio/quake/).

### Installing AudioQuake on Linux

Currently, binary packages are available for PowerPC and x86 machines.
To install the game from one of these packages, simply download it,
ensure it is executable and run it. For example:

~~~~ {.screen}
$ ./AudioQuake-0.3.0_linux-ppc.run
                
~~~~

Then simply follow the on-screen instructions.

**Note:** To ensure that you don't lose any data from previous
installations, the installer will back up your `.zquake`{.filename}
directory to a `dot-zquake-date`{.filename} directory. This may be
safely deleted when you're usre that all is well with the new install.

### Installing AudioQuake on Windows

A setup program is provided to ease the task of getting AudioQuake up
and running. Because some people may already have some of the speech
software AudioQuake requires, we've created three different sizes of
setup program. This means that you can download the smallest one you
need. The following list should help you decide which size is
appropriate for you:

-   The smallest download contains just AudioQuake. This is suitable for
    people who've either used AudioQuake before or already have
    Microsoft SAPI 5.0 or greater and the extra SAPI voices.

-   If you use Windows XP, you already have a suitable version of SAPI
    (5.0), but you may wish to install some extra voices (Mary and Mike)
    if you don't already have these, as they're much clearer than the
    voice Windows XP comes with by default (Sam). If this applies to
    you, choose the medium-sized AudioQuake download.

-   If you have an older version of SAPI than 5.0 (most likely if you're
    running an earlier version of Windows than XP) you'll need to
    download the largest AudioQuake setup program. This includes SAPI
    5.1 and the additional voices mentioned above.

You only need to download *one* of the setup programs mentioned above.
Once you've decided which you need (choose the largest one if you're
unsure), you can follow the installation procedure as described below:

1.  Download your chosen setup package from the [download
    page](http://www.agrip.org.uk/DownloadPage) on the AGRIP web site.

2.  Run the program you downloaded. The installer uses a familiar
    “wizard”-type interface and will guide you through the setup
    process.

    The setup program will automatically download and install the
    Shareware version of Quake for you, if you ask it to (likewise for
    mindgrid:audio). It will also offer you the choice of installing
    SAPI and/or the extra voices for Windows XP, if you downloaded one
    of the setup programs with speech components included.

    **Note:** If you have the CD version of Quake, you don't need to
    install the shareware version – make sure that you ask the installer
    *not* to download it for you. Then, when you first run AudioQuake,
    you'll be given the option of installing the game data from your CD.

You should now be ready to play the game – read on for information on
how to do this...

### Installing from Source

If you're a developer, or a curious user, you may be interested in
looking at the source code for AudioQuake. Source packages are provided
for both Linux and Windows. Instructions for installing AudioQuake from
source are provided [in an
appendix](#ref-installsrc "Appendix C. Installing AudioQuake from Source").
