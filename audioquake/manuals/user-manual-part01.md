Copyright (c)  2004-2020  Matthew Tylee Atkinson

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.2 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled "GNU Free Documentation License".

# Introduction

This part of the manual aims to introduce *AudioQuake* and gives you details on how to get it set up on your computer.

If you're interested in historical details, this is the section for you—but if you just want to get into playing the game, by all means visit [the "Playing *AudioQuake*" section](#playing-audioquake) instead.

## Digital archaeology note from 2020

<!-- Note: from repo README -->

*AudioQuake* and the *Level Description Language* were successful experiments started in 2003 to see if it was possible to make a mainstream first-person shooter (FPS) accessible to blind and vision-impaired gamers. We sought to afford access not only to the game *Quake*, but also to the surrounding community of modding and even the creation of new levels ("maps").

These aims were realised, with the help of the community during 2003, when we focussed on single-player and 2004, when the first networked accessible deathmatches were played and user-made mods were debuted. *Level Description Language*, which allows blind people to architect 3D maps, was released in 2008.

Whilst the original *Quake* game is no longer mainstream, the experiment was successful (in that a number of single-player maps and many deathmatch maps are accessible, and blind gamers have created additional mods and maps for the game) and the lessons learnt apply equally well to modern FPSs. Also, we developed some accessibility techniques we'd like to share and that we'd be delighted if others might adopt for their own projects; particularly the *Level Description Language* as this empowers blind gamers (and its present "90-degree expressiveness" limitation is due only to a lack of advanced geometry on our part).

Over the years since, it's been truly awesome to witness the strides and leaps in game accessibility that have been made possible by the continuing hard work of independent and large-scale developers, gamers and advocates the world over. We can't wait to find out what's next!

## What is *AudioQuake*?

**This section of the document is kept relatively unchanged from the mid-2000s. Whilst *Quake* is now ancient (but still a milestone in gaming) and accessible games and mainstream game accessibility have taken off massively, we wanted to preserve the spirit of this part. It also mentions things that, whilst we'd've loved to work on, we never got time—but again they're preserved here for posterity.**

*AudioQuake* is essentially a series of modifications to the game *Quake* by id Software that enable blind and vision-impaired people to play it. Actually, it is (or will be) quite a lot more than just that. This chapter explains the main things you need to know about *AudioQuake* to understand what it does and why it's here.

So, *AudioQuake* is…

### More than just an "accessible game"

*AudioQuake* is based on earlier software from AGRIP called "*AccessibleQuake*". The previous game's ethos was to prove that accessibility barriers can be lowered and it allowed blind gamers to play singleplayer *Quake* (or offline multiplayer with computer-generated opponents). *AudioQuake*'s philosophy is to take this idea to its logical extreme and allow blind and vision-impaired players not only access to *Quake*, but *equal* access to both the game *and* the community of Internet play and level design and creation of new modified games that surrounds it. *AudioQuake* provides this via the following three main features:

* Support for Internet multiplayer games in a variety of game modes such as co-operative, deathmatch, team deathmatch and capture the flag (provided via our use of the *ZQuake* "*QuakeWorld*" game engine). The traditional singleplayer gametypes are, of course, supported.

* "Implicit Accessibility"—The use of modern 3D audio and special effects technology to make the game inherently more accessible. This, in turn, means that the difference between the software that the sighted and blind use is dramatically minimised. For all intents and purposes, you'll be playing *the same* game.

* Accessible level-editing tools. These will allow you to create your own levels ("maps") for the game; something that sighted gamers have been able to do for some time. Coupling this with the fact that you can create your own code modifications easily, *AudioQuake* could be used as a platform for making your own games\!

**Note:** Please remember that at the current stage of development only the first of these three features have been fully implemented. We await community feedback on how we're doing so far and will continue to develop *AudioQuake* over time to bring you these benefits.

### *Quake*

At first it may seem obvious that *AudioQuake* is, well, *Quake*. This idea, however, has had a profound impact on how the game is designed. At all times, we have tried to maintain the spirit of *Quake*. You will not find a lot of voice-over information because *Quake* didn't have it—our accessibility features are designed to use intuitive techniques and sounds so that you are not distracted from playing the game. We have only added the accessibility features necessary to play the game effectively. To keep things fair, we've not allowed *AudioQuake* players to do anything *Quake* players can't (within reason).

This design philosophy comes across in the way the accessibility features present themselves in the game. The idea is that an *AudioQuake* player is no different than a *Quake* player, but they have in their possession certain "objects" that provide accessibility features such as enemy detection (the EtherScan RADAR), item detection (the Detector 5000) and navigation (the Navigation Helper). Many features can be toggled on or off according to your individual taste and level of sight.

#### ImplicitAccessibility

As *AudioQuake* development brings more of the key features mentioned above into play, these objects, or parts of them, should start to disappear. This is because the information they provide will be presented through the more realistic (audio) modelling of the environment.

We have tried our best to make it possible for *AudioQuake* players to use the original *Quake* maps. Currently there are a number of maps from the game that cam be played by blind players. A series of tutorial maps is provided to help you get used to the game and we hope to provide a range of custom-built accessible maps in the future.

In the end, the main point of *AudioQuake* is not to prove that video game accessibility is possible, as this has already been established. The main point is that *community* accessibility is possible—that blind and vision-impaired players can use *the exact same software*, join Internet games and contribute new maps and modifications, just as the sighted are able to.

#### Not for under-15s

*Quake* has a "15" certificate. For obvious reasons, we do not recommend nor condone the use of this software by anyone below 15 years of age.

### Customisable

The game has been built to be customisable. You can change a great many of the game-play aspects described below quite easily so that they suit your taste and style of play. We are here to cater for a large range of people from the blind to the vision-impaired. Everyone is different and we're confident that you'll get a lot more out of *AudioQuake* if you customise it.

The process of customisation is described [in the "Customising *AudioQuake*" section](#customising-audioquake). It's not difficult and there is help provided along the way. It is probably a good idea to read the next part and learn how to play the game before you delve in to tweaking it, however\!

### Free (as in Freedom)

Everything we have created for the project (code, sounds, tools) is available for you to use, modify and redistribute. The licence we have used for the project, the GNU General Public Licence, permits anyone to do these things as long as they keep the source code to their work available for others, just as we have for you.

Our reasons for making *AudioQuake* Free are that it should make it easier for people to get hold of and play the game. The most important reason, however, is described in the following section…

### Only the beginning

We're building not just a game, but a framework with which you can create your own games. This framework currently allows you to alter all aspects of the way the game works and sounds, with level editing planned for the future, as we get closer to the 1.0.0 version number.

With a number of commercial game engines now made Open Source, the possibility of making other titles accessible is a reality. Some even use the *Quake* engine—*Half-Life* would make a most amazing and immersive accessible game due to its amazing sounds, AI, story line and massively popular online game modes.

It is possible that later engines such as *Quake III* and *Unreal* could be made accessible even without access to the engine code. We wanted to produce a Free game, which is why we didn't choose these titles. We also thought that *Quake* would be a good starting point as it marked the dawn of modern game engine design.

We would love to see a community spring up around *AudioQuake* and make other games based on it. You can use any of our code and sounds. The techniques we've used should be applicable to newer engines, too.

## Installing *AudioQuake*

Installing both *AudioQuake* and the *Level Description Language (LDL)* is just a case of extracting the ZIP file you downloaded and running either "AudioQuake.app" on the Mac, or "AudioQuake.exe" on Windows. However, there are a couple of other things you need to know.

### Playing *Open Quartz* out-of-the-box

You need some game data files to actually play the game. *AudioQuake* comes with the Open Source and Free Software *Open Quartz* data pack. It's similar in spirit to *Quake* in that it's a first-person shooter and aims to be a drop-in replacement for *Quake*, but it sounds (and looks) quite different and is a game in its own right (though much smaller in size and scope, and not single-player focused).

You can start playing *Open Quartz* with all the accessibility features that *AudioQuake* provides out-of-the box. You can also make your own maps with *Level Description Language (LDL)* using the *Open Quartz* textures and even some high-contrast textures, courtesy of *Prototype.wad* too.

Whilst using *Open Quartz* supports custom mapping and even some mods originally made for *AudioQuake*, there are some limitations at the moment: *Open Quartz* doesn't have replacements for some of *Quake*'s data, so you will find that some maps and mods won't work.

<!-- FIXME -->

Currently at least one of the *Level Description Language (LDL)* maps requires some of this data and won't run under *Open Quartz*.

### Buying *Quake*

We recommend that you buy *Quake* so you can use its data with *AudioQuake* (not all the levels are accessible, but a number are—having the full *Quake* data also means you can experience its ambience and use it in your own maps). Whilst there is a Shareware episode of *Quake*, it doesn't permit using custom maps, which *AudioQuake* provides, and the *Level Description Language (LDL)* allows you to create.

You can buy *Quake* online from the following places. Please note that ***AudioQuake* does not support the mission packs**.

* Good Old Games: [*Quake: The Offering* (includes both mission packs)](https://www.gog.com/game/quake_the_offering)
* Steam: [*Quake*](https://store.steampowered.com/app/2310/QUAKE/)

<!--
    * [*Quake Mission Pack 1: Scourge of Armagon*](https://store.steampowered.com/app/9040/QUAKE_Mission_Pack_1_Scourge_of_Armagon/)
    * [*Quake Mission Pack 2: Dissolution of Eternity*](https://store.steampowered.com/app/9030/QUAKE_Mission_Pack_2_Dissolution_of_Eternity/)
-->

