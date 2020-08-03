<a name="playing-audioquake"></a>
# Playing *AudioQuake*

This part of the manual is a guide to playing *AudioQuake*. It is aimed at people who have played accessible games such as *Shades of Doom* and *Monkey Business* before—though if you're used to playing 3D/FPS games in general, you should feel at home.

*AudioQuake* has a number of game modes. This part explains only what is common between all game modes. The [Singleplayer game modes](#singleplayer-game-modes) and [Multiplayer game modes](#multiplayer-game-modes) sections tell you more about each individual mode.

**Tip:** The following sections tell you which keys you can use to toggle various gameplay elements on and off. Please be aware that you're welcome to change them. To learn how to redefine keys, please read the [Customising *AudioQuake*](#customising-audioquake) section.

## The user interface

There are two main ways to interact with the game and surrounding tools.

### The launcher

The *AudioQuake* launcher is a GUI app that lets you do the following:

* Playing the game (including the tutorial).
* Using the *Level Description Language (LDL)* to make and try out your own maps.
* Installing and playing mods.
* Customising settings (via editing your config files).

You need to use a screen reader to access the launcher.

### The console

The console is a command-line interface. To reach it, press the tilde (<kbd>~</kbd>) key on your keyboard. Here you can type in commands to start new games, play the tutorial maps or join in a multiplayer match. Instructions on how to do this can be found throughout the rest of this manual. All of the in-game events are self-voicing, including text editing within the console.

**Tip:** Issue the **help** command to get a list of some very useful commands you can use to interact with the game.

**Tip:** If you get the syntax of a command wrong when you type it into the console, you'll be presented with a message that explains the correct syntax for that command.

### *Quake* menu

In the original *Quake*, there was a traditional partly-graphical hierarchical menu. This is not present in *AudioQuake* due to its graphical nature, but the console allows you to do more, is faster to use and is also the way most players choose to interact with the game nowadays, anyway.

## Navigation

This section explains how you can navigate when you're in the game. If you've not played it yet, and want to try it, try engaging the tutorial mode from the launcher.

### How best to listen

*AudioQuake* runs in stereo sound and will sound better with headphones rather than speakers.

### Moving around

To move around, use the arrow keys. Turning is implemented in a familiar way to users of accessible games—pressing the arrow keys snaps the player round a certain number of degrees. By default, the player has a 16-point turn (that is to say each tap of the arrow keys will turn you 22.5 degrees in that direction).

A very important move in *Quake* is "strafing". To strafe, hold down <kbd>Alt</kbd> and press-and-hold the <kbd>Left</kbd> or <kbd>Right</kbd> arrow key. This moves you from side-to-side and helps you avoid incoming enemy fire.

To jump, press <kbd>Space</kbd>. To jump over a gap in front of you, move up to the gap using the up arrow and press <kbd>Space</kbd> as you reach the edge. If you need to do a running jump, hold down the <kbd>Shift</kbd> key as well as the <kbd>Up</kbd> arrow. Holding down <kbd>Shift</kbd> makes you run instead of walk.

### Navigation helper

*AudioQuake* provides a number of features to help you get around maps. These can all be toggled on/off. Some, but not all of them, are on by default (again, please read the customisation section for more information).

To toggle the whole of the navigation subsystem on/off, use the <kbd>N</kbd> key.

#### Obstacle (wall, door and slope) indications

If turned on, you'll hear a sound to your left, in front of you and to your right to indicate if a [wall](../id1/sound/nav/wall.wav), [slope](../id1/sound/nav/slope.wav) (which could be some steps or a ramp) or a [door](../id1/sound/nav/door.wav) is present near you in any of these directions. The sounds get louder the closer you are to the obstacle in question.

The sound that walls make falls off more quickly than the sound steps/ramps and doors make. Also, side wall warnings are off by default—though you'll always be told about doors and slopes to your left and right. The fact that walls are given lower priority than slopes and doors should allow you to locate the key features of the map more efficiently. You can toggle the announcement of walls to your left and right with the <kbd>E</kbd> key. All obstacle sounds can be turned off with the <kbd>W</kbd> key.

##### Wall hit and touch warnings

If you bump in to a wall, you'll hear an "oomph" sound to indicate this has happened. Depending on how you've set up *AudioQuake*, you may also hear a continuous "wall-touch" sound played as long as you are still touching the wall.

To toggle the sound that indicates you're still right next to a wall, use the <kbd>T</kbd> key.

#### Hazard detection

The Navigation Helper also tells you when you are coming up to a ledge, drop or pit of some kind. If you are, it will produce a beep every half-second in the direction the drop can be found. Toggle hazard warnings with <kbd>H</kbd> and toggle the announcement of drops to your sides on/off with <kbd>I</kbd>.

Press <kbd>J</kbd> to be told if you can make a jump or a running jump over the drop. If you're not facing a ledge, you'll hear an ["access denied"](../id1/sound/deny.wav) sound.

**Tip:** The EtherScan RADAR (which you'll learn about shortly) has a mode that helps you to make jumps over pits.

You can find out how big a drop is by the pitch of the beep. There are 4 classifications:

* Negligible drop—not announced.

* [Small drop](../id1/sound/haz/drop-small.wav)—requires jumping to get over.

* [Big drop](../id1/sound/haz/drop-big.wav)—a drop that is too tall for you to jump back out of and get back to where you were before you fell down it.

* [Huge drop](../id1/sound/haz/drop-huge.wav)—a drop this big will hurt you if you fall all the way to the ground (note that water will cushion you).

To find out what's at the bottom, use the K key. You will get the ["access denied"](../id1/sound/deny.wav) sound if you are too far away or not facing a ledge. If you are successful, you'll be told that the drop is either onto the ground or into water, slime or the dreaded lava.

**Tip:** Pick up a BioSuit Power-Up to survive slime.

#### Open space detection

This gives you a bit more of a feel for how big the area around you actually is. It will play a [gentle wind](../id1/sound/nav/wind.wav) sound at various points in front of you if there are no walls or other obstacles in that direction. The sounds are generated in a sweep from left to right around you, in response to a pres of the L key. It works as if you were using a mobility cane to scan the area—though it has significantly greater range.

The distance over which obstacles are scanned for is the navigation detection range and is customisable (please read [Customising *AudioQuake*](#customising-audioauake) for more details).

#### Corner detection

Corner detection searches for corners that could lead to corridors, alcoves, etc. Left and right turnings are detected in the direction the player is facing. When a turning is detected, you'll be alerted by a sound right in front of you. This sound is quickly followed by the same tone played from the position just 'round the corner.

If corners are detected in both the left and right directions, the left corner is announced first.

Toggle corner detection on/off with the <kbd>X</kbd> key.

### Independent navigation aids

The navigation helper described in the previous section has a number of sub-features. They are all disengaged when you toggle the navigation helper off (as they are all linked).

This chapter describes some helpful features that are not tied to, or part of, the main navigation helper.

#### Footsteps

Footsteps can tell you a lot—whether you're moving and, if so, how fast. They can be toggled with the letter <kbd>F</kbd> key. As with all other keys, this can be customised.

When you are totally stuck on an object, you will not be able to move. Consequently your footsteps will stop. If you're scraping along a wall (i.e. caught on it but still moving) you'll hear a [scraping sound](../id1/sound/nav/wall-scrape.wav) as you walk along—you'll also hear the footsteps' speed drop to indicate you're not walking freely.

If you're stuck on an object, you'll continue to hear the "oomph" sound described above when you try to move in the direction it lies.

#### The compass

To find out what direction you're pointing in, use the compass (<kbd>C</kbd> by default). As a convention, you're always pointing "North" when you start a map.

**Note:** The compass works best when the player turn angle (the number of degrees you've specified that the player should turn for each press of an arrow key, `agv_mov_turnvalue` in `autoexec.cfg`) is 30, 22.5 or 45. This is because the compass only knows the names of so many directions you could be pointing in. It'll announce the nearest one it can if you're not pointing at a known direction exactly.

#### Waypoint markers

This is a helpful feature that will tell you if you've been somewhere before. You can leave a marker at any point in a map. It will make a [sound](../id1/sound/nav/marker.wav) continuously to let you know it is there. When you walk through it, you'll be informed which marker number it is (the number is incremented each time you drop a marker).

To drop a marker, press <kbd>Insert</kbd>. To delete the last one you dropped, press <kbd>Delete</kbd>.

## Creature and hazard detection—the EtherScan RADAR

The EtherScan RADAR ("ESR" as it is known for short) is a device that alerts you to proximity of things. It has two modes, described below.

### Monster detection

To toggle monster detection on/off, press <kbd>R</kbd>. This acts as a kind of RADAR that lets you know where enemies are. The faster the beeps, the nearer the monster. The sound is actually two close-together beeps; the pitch difference between which tells you where (vertically) the monster is with respect to you. For example, if the monster is [lower](../id1/sound/esr/monster-lower.wav) or [higher](../id1/sound/esr/monster-higher.wav) than you. If the monster is roughly on the [same level](../id1/sound/esr/monster-same.wav) as you, the beeps will both have the same pitch.

**Note:** Just as in regular *Quake*, you're not given the ability to detect enemies through walls with the ESR. In *AccessibleQuake*, this was the case, and it proved to be both unnecessary and confusing (from feedback from the community).

### Hazard detection

If there is a hazard in front of you—some kind of ledge/drop—you'll be told about it by the navigation helper. If you want to try and jump over the pit, you can use this alternative ESR mode to help you do so. Pressing the <kbd>R</kbd> key again when you have a drop in front of you will make the ESR lock onto it instead of enemies. It automatically falls back to detecting enemies when you lose the lock on the pit (by jumping over it successfully, falling in or just turning and facing another way).

If it can't find a pit, it will just turn the ESR off.

**Tip:** It is a good idea to check that you *can* make the jump (with the <kbd>K</kbd> key) first. Also, if you are not terribly confident of bing able to make it, you should check, with the D key, that the pit doesn't contain something harmful.

### Is it a monster, enemy or friend?

The ESR is capable of detecting the nearest [monster](../id1/sound/esr/monster-same.wav), [enemy](../id1/sound/esr/enemy-same.wav) (player or bot not on your team) and [friend](../id1/sound/esr/friend-same.wav) (player or bot team member) to the player. It uses a different sound to indicate which is which, so that you know not to fire at team mates (vertical level information, as described for monsters above, is provided for all three types of detection).

By default, the <kbd>T</kbd> key toggles if monsters are detected, <kbd>Y</kbd> toggles enemy detection and <kbd>U</kbd> enables/disables the announcement of friends. All three features are enabled by default.

## Item detection, weapons, health and ammo

### The Detector 5000

You have at your disposal a device called the Detector 5000 (or the "D5k" for short). It will help you find a number of things that'll enhance your chances of survival. The items it looks for include health, ammo, armour, weapons and keys.

If the D5k finds more than one item in your vicinity, it will space out the announcement of the items so that you can get a better fix on where they are.

Item detection can pick up ammo, weapons, armour and health. You can toggle it with the <kbd>D</kbd> key.

### Using the Weapons

To fire, press <kbd>Ctrl</kbd>.

To switch weapons, use the keys <kbd>1</kbd>-<kbd>8</kbd> on they keyboard. You won't start off with more than an axe (<kbd>1</kbd>) and a shotgun (<kbd>2</kbd>). By default, you'll be using the gun at the start of any game.

From <kbd>1</kbd> to <kbd>8</kbd>, the weapons available in *Quake* are: axe, shotgun, double-barrelled shotgun, nailgun, super nailgun, grenade launcher (grenades are often affectionately known as pineapples), rocket launcher (the "boomstick") and the lightning gun. There are four different types of ammo you can pick up: shells, nails, rockets and cells (the grenade launcher uses rocket ammo).

Some weapons are more effective against certain types of enemy than others—you'll begin to get an idea of how your implements of destruction are working as you play the game. There are also a number of special moves you can do with some of the weapons. Again, you'll begin to learn techniques as you play but to help you on your way, here are the names of some of the most interesting ones are the "rocket jump" and the "pineapple jump". Beware of mixing liquids and electricity, too…

If you run out of ammo, you'll automatically switch to the next best weapon for which you do have enough for at least 1 shot. For more information on weapons, please consult *Quake*'s `MANUAL.txt` file.

### Health, ammo and armour indicators

You're going to need to know when it's time to find some health or when your favourite weapon is running low on ammo.

To be given a verbal report on your health and armour levels, press <kbd>9</kbd>. Your current level of health will be announced, along with how many armour points you have. There are three types of armour in the game, each saves a certain fraction of the damage that would otherwise take health points off you. This fraction is also read out.

Unless you have a special power-up, your health will never get above 100 points. Even if you do find a MegaHealth power-up, your health can't go over 200 points and it'll gradually decay back down to 100 over time.

To get a rundown of your ammo counts, press <kbd>0</kbd>. The quantity of each ammo type that you posses will be announced.

## Completing a map and miscellaneous keys

### Completing a map

When you've come to the end of a map, the game will pause for a few moments. To move on, press <kbd>Space</kbd> (you'll only be able to do this after a few seconds).

A number of things may cause a map to end. This largely depends on what game mode you're playing in and could include such events as: You've reached a slipgate or exit, one of your team has reached a slipgate or exit, the timelimit has been reached or the fraglimit has been reached. The meaning of these events will become clear after you've read the next part of the manual.

### Other keys and exiting the game

One of *Quake*'s strengths is that it allows total control over which keys do what. *AudioQuake* does not take any of this control away from you (please read the [Customising *AudioQuake*](#customising-audioauake) section for details) but it does, by default, limit the number of defined keys. Originally, there were many ways to perform some game actions (like jumping or shooting). We have disabled a lot of the keys so that the likelihood of pressing a key you don't mean to and getting yourself into an unknown situation because of it is reduced.

Some extra keys you may be interested in are:

* <kbd>Home</kbd>—To have the last message that was announced repeated, press this key.

* <kbd>End</kbd>—Pressing this key mutes all currently queued speech.

* <kbd>F10</kbd>—Press to exit *Quake* and return to the *AudioQuake* launcher's main menu.

* <kbd>Pause</kbd>—Erm, pauses the game. Press again (or <kbd>Escape</kbd>, or <kbd>Ctrl</kbd>) to un-pause.

**Note:** You'll find that there are some keys for keeping up with chat messages in multiplayer games. These are discussed later on.
