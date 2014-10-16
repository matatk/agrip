Playing AudioQuake
==================

This part of the manual is a guide to playing AudioQuake. It is aimed at
people who have played accessible games such as Shades of Doom and
Monkey Business before. If you'd like more help and/or information than
is provided here, please contact us and we'll do what we can to help you
out.

AudioQuake has a number of game modes. This part explains only what is
common between all game modes. Please read the next part of the manual
to find out more about each individual mode.

**Tip:** The following sections tell you which keys you can use to
toggle various gameplay elements on and off. Please be aware that you're
welcome to change these – only the defaults are listed here. To learn
how to redefine keys, please read the [Customising
AudioQuake](#customising "Part VI. Customising AudioQuake") section.

Starting AudioQuake
-------------------

This section describes how to get the game running. Later sections in
this part provide information on how to actually play it.

### Running the Game

The “game launcher” (described in more detail shortly) is your entry
point to AudioQuake. To start the game launcher in Linux, simply run
**start.pl** from the directory where AudioQuake was installed. In
Windows you can run the launcher via the Start Menu – Choose
`Start`{.constant}, `Programs`{.constant}, `AudioQuake`{.constant},
`Start AudioQuake`{.constant}.

**Warning:** Please unload any access software such as a screen reader
or magnifier before running AudioQuake. The game is self-voicing so
additional access software is not required. You may also find that
running access software alongside AudioQuake makes the game run slowly.

The game launcher should now begin talking to you. Please send an e-mail
to our tech support address (found on the
[ContactUs](http://www.agrip.org.uk/ContactUs) page of our site) if you
are having problems and we'll do our best to help you out.

### Initial Data File Set–up

When run AudioQuake for the first time, the game will asess which
version of the data files you have available. It will search for the
registered Quake data on your hard disk (which is useful if you've
purchased the electronic download of the game or have installed it from
CD before). If when you installed AudioQuake, you indicated that you
have a retail CD (by not having the Shareware episode downloaded for
you), this is when you'll be asked to insert the CD so that the data can
be installed.

### How Best to Listen

AudioQuake runs in stereo sound and gives far superior performance on
headphones than with traditional desktop computer speakers. We strongly
recommend the use of headphones as they will let you get the most out of
the game.

Many people are now looking into, or own, surround-sound systems.
Surround sound is something that we are going to be adding before
AudioQuake reaches 1.0.0 (it is the core of the “Implicit Accessibility”
feature).

The User Interface
------------------

AudioQuake gives you the ability to interact with Quake the same way
that sighted gamers do. This chapter describes the main user interface
for the game (the *console*) as well as the *game launcher*, which we
provided to make setting some options more convenient.

### The Game Launcher

As mentioned above, this program acts as a front-end to AudioQuake. It
exists to allow you to adjust many accessibility-related options and
review your keybindings before starting the game. The launcher has a
spoken menu-based interface. To enter a menu choice simply type the
letter that corresponds to your choice and press ENTER.

You can adjust many settings of the game by using the launcher – visit
[Part VI, “Customising
AudioQuake”](#customising "Part VI. Customising AudioQuake") for more
information.

### The Console

When you start Quake itself, you'll be presented with a pre-recorded
demo. To get to the console, press the key below ESC on your keyboard.
Here you can type in commands to start new games, play the tutorial maps
or join in a multiplayer match. Instructions on how to do this can be
found throughout the rest of the manual. All of the in-game events are
self-voicing, including text editing within the console. After you exit
the game by typing the “quit” command into the console, the launcher's
main menu will re-appear. To fully exit AudioQuake, choose the exit (X)
option from the main menu.

**Tip:** Type the **aghelp** command to get a list of some very useful
commands you can use to interact with the game.

**Tip:** If you get the syntax of a command wrong when you type it into
the console, you'll be presented with a message that explains the
correct syntax for that command.

### Quake Menu

In the original Quake, there was a traditional hierarchical menu. This
is not present in AudioQuake as the console allows you to do more, is
faster to use and is also the way most players choose to interact with
the game nowadays, anyway.

Navigation
----------

### Moving Around

To move around, use the arrow keys. Turning is implemented in a familiar
way to users of accessible games – pressing the arrow keys snaps the
player round a certain number of degrees. By default, the player has a
16-point turn (that is to say each tap of the arrow keys will turn you
22.5 degrees in that direction).

**Tip:** You can adjust the turning value, as well as many other aspects
of the game – read [Customising
AudioQuake](#customising "Part VI. Customising AudioQuake") to find out
how.

A very important move in Quake is “strafing”. To strafe, hold down ALT
and press-and-hold the left or right arrow key. This moves you from
side-to-side and helps you avoid incoming enemy fire.

To jump, press SPACE. To jump over a gap in front of you, move up to the
gap using the up arrow and press SPACE as you reach the edge. If you
need to do a running jump, hold down the SHIFT key as well as the up
arrow. Holding down SHIFT makes you run instead of walk.

### Navigation Helper

AudioQuake provides a number of features to help you get around maps.
These can all be toggled on/off. Some, but not all of them, are on by
default (again, please read the customisation section for more
information).

To toggle the whole of the navigation subsystem on/off, use the N key.

#### Obstacle (Wall, Door and Slope) Indications

If turned on, you'll hear a sound to your left, in front of you and to
your right to indicate if a [wall](../id1/sound/nav/wall.wav),
[slope](../id1/sound/nav/slope.wav) (which could be some steps or a
ramp) or a [door](../id1/sound/nav/door.wav) is present near you in any
of these directions. The sounds get louder the closer you are to the
obstacle in question.

The sound that walls make falls off more quickly than the sound
steps/ramps and doors make. Also, side wall warnings are off by default
– though you'll always be told about doors and slopes to your left and
right. The fact that walls are given lower priority than slopes and
doors should allow you to locate the key features of the map more
efficiently. You can toggle the announcement of walls to your left and
right with the E key. All obstacle sounds can be turned off with the W
key.

##### Wall Hit and Touch Warnings

If you bump in to a wall, you'll hear an “oomph” sound to indicate this
has happened. Depending on how you've set up AudioQuake, you may also
hear a continuous “wall-touch” sound played as long as you are still
touching the wall.

To toggle the sound that indicates you're still right next to a wall,
use the T key.

#### Hazard Detection

The Navigation Helper also tells you when you are coming up to a ledge,
drop or pit of some kind. If you are, it will produce a beep every
half-second in the direction the drop can be found. Toggle hazard
warnings with H and toggle the announcement of drops to your sides
on/off with I.

Press J to be told if you can make a jump or a running jump over the
drop. If you're not facing a ledge, you'll hear an [“access
denied”](../id1/sound/deny.wav) sound.

**Tip:** The EtherScan RADAR (which you'll learn about shortly) has a
mode that helps you to make jumps over pits.

You can find out how big a drop is by the pitch of the beep. There are 4
classifications:

-   Negligible drop – not announced.

-   [Small drop](../id1/sound/haz/drop-small.wav) – requires jumping to
    get over.

-   [Big drop](../id1/sound/haz/drop-big.wav) – a drop that is too tall
    for you to jump back out of and get back to where you were before
    you fell down it.

-   [Huge drop](../id1/sound/haz/drop-huge.wav) – a drop this big will
    hurt you if you fall all the way to the ground (note that water will
    cushion you).

To find out what's at the bottom, use the K key. You will get the
[“access denied”](../id1/sound/deny.wav) sound if you are too far away
or not facing a ledge. If you are successful, you'll be told that the
drop is either onto the ground or into water, slime or the dreaded lava.

**Tip:** Pick up a BioSuit Power-Up to survive slime.

#### Open Space Detection

This gives you a bit more of a feel for how big the area around you
actually is. It will play a [gentle wind](../id1/sound/nav/wind.wav)
sound at various points in front of you if there are no walls or other
obstacles in that direction. The sounds are generated in a sweep from
left to right around you, in response to a pres of the L key. It works
as if you were using a mobility cane to scan the area – though it has
significantly greater range.

The distance over which obstacles are scanned for is the navigation
detection range and is customisable (please read [Customising
AudioQuake](#customising "Part VI. Customising AudioQuake") for more
details).

#### Corner Detection

Corner detection searches for corners that could lead to corridors,
alcoves, etc. Left and Right turnings are detected in the direction the
player is facing. When a turning is detected, you'll be alerted by a
sound right in front of you. This sound is quickly followed by the same
tone played from the position just 'round the corner.

If corners are detected in both the left and right directions, the left
corner is announced first.

Toggle corner detection on/off with the X key.

### Independent Navigation Aids

The navigation helper described in the previous section has a number of
sub-features. They are all disengaged when you toggle the navigation
helper off (as they are all linked).

This chapter describes some helpful features that are not tied to, or
part of, the main navigation helper.

#### Footsteps

Footsteps can tell you a lot – whether you're moving and, if so, how
fast. They can be toggled with the letter F key. As with all other keys,
this can be customised.

When you are totally stuck on an object, you will not be able to move.
Consequently your footsteps will stop. If you're scraping along a wall
(i.e. caught on it but still moving) you'll hear a [scraping
sound](../id1/sound/nav/wall-scrape.wav) as you walk along – you'll also
hear the footsteps' speed drop to indicate you're not walking freely.

If you're stuck on an object, you'll continue to hear the “oomph” sound
described above when you try to move in the direction it lies.

#### The Compass

To find out what direction you're pointing in, use the compass (C by
default). As a convention, you're always pointing “North” when you start
a map.

**Note:** The compass works best when the player turn angle (the number
of degrees you've specified that the player should turn for each press
of an arrow key, `agv_mov_turnvalue`{.constant} in
`autoexec.cfg`{.filename}) is 30, 22.5 or 45. This is because the
compass only knows the names of so many directions you could be pointing
in. It'll announce the nearest one it can if you're not pointing at a
known direction exactly.

#### Waypoint Markers

This is a helpful feature that will tell you if you've been somewhere
before. You can leave a marker at any point in a map. It will make a
[sound](../id1/sound/nav/marker.wav) continuously to let you know it is
there. When you walk through it, you'll be informed which marker number
it is (the number is incremented each time you drop a marker).

To drop a marker, press INSERT. To delete the last one you dropped,
press DELETE.

Creature and Hazard Detection – The EtherScan RADAR
---------------------------------------------------

The EtherScan RADAR (“ESR” as it is known for short) is a device that
alerts you to proximity of things. It has two modes, described below.

### Monster Detection

To toggle monster detection on/off, press R. This acts as a kind of
RADAR that lets you know where enemies are. The faster the beeps, the
nearer the monster. The sound is actually two close-together beeps; the
pitch difference between which tells you where (vertically) the monster
is with respect to you. For example, if the monster is
[lower](../id1/sound/esr/monster-lower.wav) or
[higher](../id1/sound/esr/monster-higher.wav) than you. If the monster
is roughly on the [same level](../id1/sound/esr/monster-same.wav) as
you, the beeps will both have the same pitch.

**Note:** Just as in regular Quake, you're not given the ability to
detect enemies through walls with the ESR. In AccessibleQuake, this was
the case and it proved to be both unnecessary and potentially confusing.
This way is much more fun :-).

### Hazard Detection

If there is a hazard in front of you – some kind of ledge/drop – you'll
be told about it by the navigation helper. If you want to try and jump
over the pit, you can use this alternative ESR mode to help you do so.
Pressing the R key again when you have a drop in front of you will make
the ESR lock onto it instead of enemies. It automatically falls back to
detecting enemies when you lose the lock on the pit (by jumping over it
successfully, falling in or just turning and facing another way).

If it can't find a pit, it will just turn the ESR off.

**Tip:** It is a good idea to check that you *can* make the jump (with
the K key) first. Also, if you are not terribly confident of bing able
to make it, you should check, with the D key, that the pit doesn't
contain something harmful.

### Is it a Monster, Enemy or Friend?

The ESR is capable of detecting the nearest
[monster](../id1/sound/esr/monster-same.wav),
[enemy](../id1/sound/esr/enemy-same.wav) (player or bot not on your
team) and [friend](../id1/sound/esr/friend-same.wav) (player or bot team
member) to the player. It uses a different sound to indicate which is
which, so that you know not to fire at team mates (vertical level
information, as described for monsters above, is provided for all three
types of detection).

By default, the T key toggles if monsters are detected, Y toggles enemy
detection and U enables/disables the announcement of friends. All three
features are enabled by default.

Item Detection, Weapons, Health and Ammo
----------------------------------------

### The Detector 5000

You have at your disposal a device called the Detector 5000 (or the
“D5k” for short). It will help you find a number of things that'll
enhance your chances of survival. The items it looks for include health,
ammo, armour, weapons and keys.

If the D5k finds more than one item in your vicinity, it will space out
the announcement of the items so that you can get a better fix on where
they are.

Item detection can pick up ammo, weapons, armour and health. You can
toggle it with the D key.

### Using the Weapons

To fire, press CTRL.

To switch weapons, use the keys 1-8 on they keyboard. You won't start
off with more than an Axe (1) and a Shotgun (2). By default, you'll be
using the gun at the start of any game.

From 1 to 8, the weapons available in Quake are: Axe, Shotgun,
Double-Barrelled Shotgun, Nailgun, Super Nailgun, Grenade Launcher
(grenades are often affectionately known as pineapples), Rocket Launcher
(the “boomstick”) and the Lightning Gun. There are four different types
of ammo you can pick up: Shells, Nails, Rockets and Cells (the grenade
launcher uses Rocket ammo).

Some weapons are more effective against certain types of enemy than
others – you'll begin to get an idea of how your implements of
destruction are working as you play the game. There are also a number of
special moves you can do with some of the weapons. Again, you'll begin
to learn techniques as you play but to help you on your way, here are
the names of some of the most interesting ones are the “rocket jump” and
the “pineapple jump”. Beware of mixing liquids and electricity, too...

If you run out of ammo, you'll automatically switch to the next best
weapon for which you do have enough for at least 1 shot. For more
information on weapons, please consult Quake's `MANUAL.txt`{.filename}
file.

### Health, Ammo and Armour Indicators

You're going to need to know when it's time to find some health or when
your favourite weapon is running low on ammo.

To be given a verbal report on your health and armour levels, press 9.
Your current level of health will be announced, along with how many
armour points you have. There are three types of armour in the game,
each saves a certain fraction of the damage that would otherwise take
health points off you. This fraction is also read out.

Unless you have a special power-up, your health will never get above 100
points. Even if you do find a MegaHealth power-up, your health can't go
over 200 points and it'll gradually decay back down to 100 over time.

To get a rundown of your ammo counts, press 0. The quantity of each ammo
type that you posses will be announced.

Completing a Map and Miscellaneous Keys
---------------------------------------

### Completing a Map

When you've come to the end of a map, the game will pause for a few
moments. To move on, press SPACE (you'll only be able to do this after a
few seconds).

A number of things may cause a map to end. This largely depends on what
game mode you're playing in and could include such events as: You've
reached a slipgate or exit, one of your team has reached a slipgate or
exit, the timelimit has been reached or the fraglimit has been reached.
The meaning of these events will become clear after you've read the next
part of the manual.

### Other Keys and Exiting the Game

One of Quake's strengths is that it allows total control over which keys
do what. AudioQuake does not take any of this control away from you
(please read the [Customising
AudioQuake](#customising "Part VI. Customising AudioQuake") section for
details) but it does, by default, limit the number of defined keys.
Originally, there were many ways to perform some game actions (like
jumping or shooting). We have disabled a lot of the keys so that the
likelihood of pressing a key you don't mean to and getting yourself into
an unknown situation because of it is reduced.

Some extra keys you may be interested in are:

-   Home – To have the last message that was announced repeated, press
    this key.

-   End – Pressing this key mutes all currently queued speech.

-   F10 – Press F10 to exit Quake and return to the AudioQuake
    launcher's main menu.

-   Pause – Erm, pauses the game. Press again (or ESC, or FIRE) to
    un-pause.

**Note:** You'll find that there are some keys for keeping up with chat
messages in multiplayer games. These are discussed later on.
