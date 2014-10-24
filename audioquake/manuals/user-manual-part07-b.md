Key to the AudioQuake Sounds
----------------------------

This appendix is a list of the sounds AudioQuake uses to tell you what's
going on. It contains links to the sounds and descriptions of them.
Additionally, it gives you an example or two of when you'll hear the
sounds.

Depending on how your browser is set up, you should be able to listen to
these sounds quite easily whilst reading the book (tell your browser to
open them with a program that can play WAVE files and also tell it to do
this automatically for all WAVE files).

**Note:** Many in-game events are spoken to you so you won't find them
included in this list. Also, some of the sounds we use are in the Quake
data files and as such cannot be included here because we don't own the
copyright on the Quake data.

### Toggle Sounds

This section explains the meaning of the various toggle sounds used in
the game.

  Sound                                          Description                                                           Played when...
  ---------------------------------------------- --------------------------------------------------------------------- -------------------------------------------------------------------------------------------
  [On](../id1/sound/toggles/on.wav)              The generic “item is activated” sound.                                Played when any device (for example the ESR, D5k or side hazard detection) is turned on.
  [Off](../id1/sound/toggles/off.wav)            The generic “item has been de-activated” sound.                       Played when any device (for example the ESR, D5k or side hazard detection) is turned off.
  [Mode switch](../id1/sound/toggles/mode.wav)   Used to indicate when a multi-mode device switches to another mode.   Played when the ESR switches from mode 1 to mode 2 or back from mode 2 to mode 1.

### Navigation Sounds

This section explains the meaning of the sounds that the navigation
helper makes.

**Table A.1. Structures**

  Sound                                                 Description                                                                             Played when...
  ----------------------------------------------------- --------------------------------------------------------------------------------------- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [Wall](../id1/sound/nav/wall.wav)                     Sound indicating a wall has been detected.                                              Played when there is a wall near you (at a volume proportional to your distance from it). Walls are “sounded” at half the volume of stairs and doors (to stop them getting in the way).
  [Slope](../id1/sound/nav/slope.wav)                   Sound indicating a up or downwards slope (or set of stairs) has been detected.          Played when there is a slope near you (at a volume proportional to your distance from it).
  [Door](../id1/sound/nav/door.wav)                     Sound indicating a door has been detected.                                              Played when there is a door near you (at a volume proportional to your distance from it).
  Touching a Wall (in Quake's sounds)                   This indicates you're stood right next to (touching) a wall.                            Played when you're touching a wall and have wall touch warnings enabled.
  [Scraping a Wall](../id1/sound/nav/wall-scrape.wav)   This indicates you're walking but a wall is in your way and you're scraping along it.   Played when a wall is in your way but you are able to walk, sliding along it.
  [Wind](../id1/sound/nav/wind.wav)                     This indicates that a lot of empty space can be found in a certain direction.           Played when there is a large amount of empty space in a given direction from you (when a sweep has been initiated with the L key).

\
 **Table A.2. Vertical Movement**

  Sound                               Description                                            Played when...
  ----------------------------------- ------------------------------------------------------ -----------------------------------------------------
  [Up](../id1/sound/nav/up.wav)       This sound indicates you're going up in the world.     Played when you go up stairs, slopes or on lifts.
  [Down](../id1/sound/nav/down.wav)   This sound indicates you're going down in the world.   Played when you go down stairs, slopes or on lifts.

\
 **Table A.3. Hazard (Drop/Ledge) Warnings**

  Sound                                           Description               Played when...
  ----------------------------------------------- ------------------------- ----------------------------------------------------------------------------------------------------------------
  [Small drop](../id1/sound/haz/drop-small.wav)   Indicates a small drop.   Played when a small drop is detected near you (and hazard warnings and/or side hazard warnings are turned on).
  [Big drop](../id1/sound/haz/drop-big.wav)       Indicates a big drop.     Played when a big drop is detected near you (and hazard warnings and/or side hazard warnings are turned on).
  [Huge drop](../id1/sound/haz/drop-huge.wav)     Indicates a huge drop.    Played when a huge drop is detected near you (and hazard warnings and/or side hazard warnings are turned on).

#### Jump Descriptions

When you ask if you can make a jump, you'll either be told (via speech
or Braille, depending on how you've set AudioQuake up) that you can make
it with a normal jump or you'll need to do a running jump.

If this information is not available (i.e. if there is no jump in front
of you, or you're too far away from one), you'll hear this generic
[“access denied”](../id1/sound/deny.wav)-type sound.

You'll also hear the above sound if you ask for a description of what
lies in the drop (ground, water, slime or lava) and there is no drop in
front of you or you are too far away from one.

### Independent Navigation Aid Sounds

This section explains the meaning of sounds made by the independent
navigation aids.

**Table A.4. Waypoint Marker Sounds**

  Sound                                                 Description                                 Played when...
  ----------------------------------------------------- ------------------------------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [Marker homing signal](../id1/sound/nav/marker.wav)   Emanates from the marker's location.        This lets you know where a marker is. When you touch a marker, you'll be told which waypoint number it is (the number increases with every marker you add).
  [Denied](../id1/sound/deny.wav)                       Indicates that an action is not possible.   This sound is used in a number of places to let you know that you can't do something. In this case, it is played when you press the “delete last marker” key and there is no marker to delete.

#### Compass Sounds

When you activate the compass, you will be told the name of the
direction you're pointing in (or your bearing in degrees if the
direction doesn't have a full name).

### Detector 5000 Sounds

This section explains the meaning of the sounds the D5k makes.

  Sound                                                     Description                                                                                                                                                         Played when...
  --------------------------------------------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------- --------------------------------------------------------------------------------------------------------------
  (standard Quake sounds)                                   The Quake “item activation” sounds (such as health, ammo, armour, weapon or power-up pickup sounds) are played to indicate what type of object has been detected.   The sounds are played when you're near an object (at a volume proportional to your distance from it).
  [Backpack](../id1/sound/d5k/backpack.wav)                 A dropped backpack. (Quake didn't have a sound for these.)                                                                                                          Played when a dropped backpack is near you. Monsters drop them when they die (if they've not been exploded).
  [Item is outside FOV](../id1/sound/d5k/outside-fov.wav)   Indicates that a D5k-detected item lies beyond your field of view.                                                                                                  Played when the D5k detects an item outside of your FOV (at a volume proportional to your distance from it).

### Weapon Sounds

When you pick up a new weapon, or switch weapons, the name of the weapon
you're using is announced.

If you run out of ammo, you'll hear the
[ammo-out](../id1/sound/ammo-out.wav) sound. You'll also hear this sound
if you try to switch to a weapon that you possess but don't have any
ammo for.

If you try to use a weapon you don't yet possess, you'll hear this
[“access denied”](../id1/sound/deny.wav) sound.

### EtherScan RADAR Sounds

This section explains the meaning of the sounds that the ESR makes.

**Table A.5. Monster Indication Sounds**

  Sound                                                            Description                                                                        Played when...
  ---------------------------------------------------------------- ---------------------------------------------------------------------------------- -----------------------------------------------------------------------------
  [Monster on lower level](../id1/sound/esr/monster-lower.wav)     Sound indicating that a monster is at a lower level (elevation) to the player.     Played when a monster is detected and is on the lower level as the player.
  [Monster on same level](../id1/sound/esr/monster-same.wav)       Sound indicating that a monster is at a similar level (elevation) to the player.   Played when a monster is detected and is on the same level as the player.
  [Monster on higher level](../id1/sound/esr/monster-higher.wav)   Sound indicating that a monster is at a higher level (elevation) to the player.    Played when a monster is detected and is on the higher level as the player.

\
 **Table A.6. Enemy (Player or Bot) Indication Sounds**

  Sound                                                        Description                                                                      Played when...
  ------------------------------------------------------------ -------------------------------------------------------------------------------- ---------------------------------------------------------------------------
  [Enemy on lower level](../id1/sound/esr/enemy-lower.wav)     Sound indicating that a enemy is at a lower level (elevation) to the player.     Played when a enemy is detected and is on the lower level as the player.
  [Enemy on same level](../id1/sound/esr/enemy-same.wav)       Sound indicating that a enemy is at a similar level (elevation) to the player.   Played when a enemy is detected and is on the same level as the player.
  [Enemy on higher level](../id1/sound/esr/enemy-higher.wav)   Sound indicating that a enemy is at a higher level (elevation) to the player.    Played when a enemy is detected and is on the higher level as the player.

\
 **Table A.7. Friend (Player or Bot) Indication Sounds**

  Sound                                                          Description                                                                       Played when...
  -------------------------------------------------------------- --------------------------------------------------------------------------------- ----------------------------------------------------------------------------
  [Friend on lower level](../id1/sound/esr/friend-lower.wav)     Sound indicating that a friend is at a lower level (elevation) to the player.     Played when a friend is detected and is on the lower level as the player.
  [Friend on same level](../id1/sound/esr/friend-same.wav)       Sound indicating that a friend is at a similar level (elevation) to the player.   Played when a friend is detected and is on the same level as the player.
  [Friend on higher level](../id1/sound/esr/friend-higher.wav)   Sound indicating that a friend is at a higher level (elevation) to the player.    Played when a friend is detected and is on the higher level as the player.

#### Hazard Detection Mode

When the ESR is in mode 2 (hazard detection), it makes a [“hazard
detected” sound](../id1/sound/esr/haz.wav) if there is a near-by hazard.

### End of Level

When you complete a map, you'll hear [this delightful little
tune](../id1/sound/endlevel.wav).
