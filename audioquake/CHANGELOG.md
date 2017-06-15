AudioQuake 2014.0 (???)
=======================

* Shiny new GUI launcher, now based on wxWidgets.
? The GUI can load in the registered Quake data if you bought the game.
? You can now also install QMOD files via the GUI.
* Slicker Text-to-Speech performance.
? Documentation updates.
* Much code cleanup behind the scenes.
  - All of the Python code has been tidied up a lot.
  - We are now using PyInstaller to bundle the app.

AudioQuake 2014.0 (???)
=======================

This is a re-release where we've massively revamped the code to run on
modern platforms, with a new launcher and modern, cross-platform build
system. There are no functionality changes, but it should be a great
deal easier to get, play and modify the game now!

We'll be updating the user and development documentation, and including
Level Description Language (LDL) as part of the bundle in future
releases, to make it even easier to get into and to modify and create
maps for the game.

AudioQuake 0.3.0 (02/01/2008)
=============================

This is the first release of AudioQuake; a game based on AccessibleQuake
that aims to take accessibility and community involvement to its logical
extreme. This release represents a move in game engine and many months
of hard work. So much has changed that only a summary is given here.

-   Move to the ZQuake QuakeWorld engine -- the first Open Source
    mainstream accessible game engine (many thanks to Tonik and the
    other developers for allowing our patches in).
-   Port of the AccessibleQuake game code to ZQuake's QuakeC system
    (which supports multiple online and offline gametypes).
-   Internet Multiplayer support -- Yes; you can play Quake online a
    variety of game modes!
-   Internet Game Server -- Set up your own games with total control
    over maps and game rules.
-   Online statistics -- track your progress with respect to other
    AudioQuake players.
-   http://stats.agrip.org.uk/ is a portal for all online features of
    the game.
-   Manual re-written to take into account new features and be even more
    helpful :-).
-   Ease of setup increased due to more support programs being included
    and the ability to install from a Registered Quake CD on Windows and
    Linux, as well as being able to use the data from the downloadable
    version of Quake for Windows.
-   Many bug fixes and feature enhancements to both the engine and game
    code in this move -- such as new footstep sounds (from Davy Loots)
    and movement speed indication, ESR enhancements and general gameplay
    review.

Future releases in the 0.3.x series will be bug fixes and gameplay
optimisations (according to feedback). We may also add new multiplayer
game types (such as Capture The Flag). Major new features (such as
ImplicitAccessibility and LevML support) shall be added in future
release series.

AccessibleQuake 0.2.1 (29/07/2004)
==================================

Changed the name of this "product" to AccessibleQuake (from "AGRIP") to
differentiate it from the name of the organisation and of the other
project we now host ("AudioQuake").

-   Made the console editing messages (such as "No character to delete."
    high priority.

-   Made the ESR prefer monsters on your own level above all overs.
    Increased tolerance to make this more noticeable.

-   Made ESR level determination Z tolerance configurable (it was a very
    long time ago, as I remember).

-   Major line editing improvements -- punctuation characters (such as
    the bang, tick dot and dash) are now announced properly when typed
    or reviewed.

-   Added a key that repeats the last spoken message.

-   Fixed bug in manual regarding not explaining running jumps.

-   Continued making event messages that are the result of key-presses
    high-priority.

-   Made trigger areas in maps smaller.

-   When bots are spawned, you'll be told if they're on your side or
    not.

-   Footsteps won't happen whilst your in the middle of a jump any more
    :-).

-   Fixed the problem of spawn points with weird angles messing up the
    player's orientation on some maps (by forcing spawn points to
    N/S/E/W angles).

-   Open space detection works underwater.

AGRIP 0.2.0 (06/07/2004)
========================

In development this was 0.1.1 but the decision to release as 0.2.0 was
made because there have been a number of big improvements.

-   Put the startup text filter inside QF. This will make the Windows
    helper much easier to write as it no longer needs to be
    cross-platform.

-   Made map information messages (such as "You can jump in here..." and
    "You need the Gold key." get echoed to the console.

-   The console now announces when it is entered and left.

-   Started making some tutorial maps.

-   Updated the manual in line with all of these improvements. Also
    added more notices about the benefits of using Braille displays and
    hardware synthesisers.

-   Created the Windows installer with the Inno Setup QuickStart Pack
    and Visual Studio Installer 1.1 (used to create ".msi"s out of the
    SAPI 5.1 redist' ".msm"s).

-   After too many problems -- the killer being that Windows just
    doesn't do pipes -- we have fallen back to using Perl for the
    start-agrip / TTS interface launcher. This does have the advantage
    that we can do a nice cross-platform front-end.

-   Altered make-release.sh so that it makes separate "nix" and "win32"
    releases. The win32 releases can then be copied to a suitable
    development box where the Inno Setup script can be compiled to
    create executable setup packages.

-   Improved my QF patch code to go through Con\_Printf (so that
    fflush() is done implicitly).

-   Removed a load of sounds from the QuakeC side so as to make way for
    SAPI.

-   Finally been able to add spoken health, armour and ammo indicators
    :-).

-   Fixed a few little niggling ESR and D5k bugs.

-   Corner detection works underwater. Open space detection currently
    doesn't because we don't have a suitable sound for it, but it would
    be trivial to make it work when we do (COASD was always designed
    with this in mind).

-   Water support in footsteps code.

-   Fixed some bugs that caused double sets of items to be activated
    when respawning in a coop or teamplay game. This also fixed the bug
    where your devices would still be active after you are killed in the
    game.

-   Added waypoint markers (very handy).

-   Altered QF so that it doesn't print bangs onto the screen when
    outputting a high priority message. Added the beginnings of a
    priority locking system.

-   Added a number of sounds from Sebby (up, down, deny, marker).
    Unfortunately we still have not been able to find any footstep
    sounds after a great deal of searching.

AGRIP 0.1.0 (11/06/2004)
========================

Whilst in development, this was 0.0.5, but was re-released as 0.1.0
(beta) due to the new sounds going in.

-   Added the echoing of information needed to make the console
    accessible. Sebby is writing a filter/SAM interface that will allow
    this information to be piped to speech and Braille in Windows.

-   Now using the latest QF config.cfg file format. This has solved a
    bug whereby some values got reset back to their Quake/QF defaults on
    the second run of AGRIP. This was causing problems because the
    accessible set-up had been reverted to one that could confuse some
    AGRIP objects.

-   Fixed a bug where the bots would render you SOLID\_NOT on coming to
    your aid (caused by me not escaping from the goal item grabbing
    routine if the goal item is a player).

-   Drastically improved the accuracy of up/down slope detection.

-   Improved the Linux set-up script and manual in a number of ways (age
    restriction info, how to set up the shareware episode as a
    try-before-you-buy, updates to the Linux install process regarding
    the QF patches).

-   Sebby's sounds are now in! These include ESR, D5k and toggle sounds.

AGRIP 0.0.4 (22/05/2004)
========================

-   Added jump detection -- you can press J for a description of ho you
    will be able to make a jump. If the hazard doesn't represent a jump,
    or you can't make it, you'll hear the "access denied" sound. If you
    can make it with a running jump, you'll hear a shotgun-like sound.
    If you need to do a running jump, you'll hear a big rocket type
    sound.

-   Fixed a bug where raised flooring areas such as bridges are detected
    as drops.

-   Made it make oomph sounds when you continue to try to walk into
    walls.

-   Re-wrote the function that normalises yaws and the compass to
    reflect this. Doing this has fixed a number of bugs with FOV
    detection.

-   Fixed an ESR FOV bug (was a wider problem with using 360 degrees to
    represent North over 0 degrees (now used and much more
    sensible/consistent).

-   Made the ESR beep faster when in Hazard Mode to help with making
    jumps. Practice on the jump near the first door in e1m1. The jumps
    either side of the bridge (just after the downward lift, after the
    first door) are very hard.

-   Added corner detection. It detects corners that could lead to
    corridors, alcoves, etc. Turnings are detected in front of the
    player, to their left and right. When a turning is detected, you'll
    be alerted by a sound right in front of you. This sound is quickly
    followed by the same tone played from the position of the corner.
    That way you can easily determine if the corner points left or
    right. If both left and right corners are detected, the announcement
    of them will be separated by a small gap.

-   Added open space detection. Gives you a bit more of a feel for how
    big the area around you actually is. It will play a gentle wind
    sound at various points in front of you if there are no walls/other
    obstacles in that direction over the entire navigation detection
    range (set by the user).

-   Made debugging easier with a common function to highlight points on
    the map.

-   Added notions of "sound entities" to the code.

-   Added bots! These are computer simulations of human players and are
    designed to fulfil the multiplayer purposes of the game. They can
    play with or against you in co-op and deathmatch modes! We have made
    them a bit more intelligent than your average bots by re-using some
    AGRIP navigation code to tell them when it is safe to jump gaps for
    example.

-   You can tell the bots to come to your aid with a toggle key. They
    will tell you when they are near you and will resume looking for
    things to fight with automatically.

-   The ESR can now find monsters, enemy players/bots and friendly
    players/bots. Sound sets for these three types of detected object
    will be added soon. Until then they share the same sound set (i.e.
    same lower/same level/higher/beyond FOV sounds). You can toggle
    detection of each of the three on/off.

-   Changed the default key setup so that it is much more logical.

-   Included Sebby's on/off toggle sounds for various items.

AGRIP 0.0.3 (13/05/2004)
========================

First release after 0.0.x has been extended.

-   The "wall\_hit\_warnings" are now "wall\_touch\_warnings". By
    default they're off but if on, they keep the walls making sound if
    you're still near them.

-   Added a number of extra configuration options to help make the nav
    system quieter and more customisable (toggles for all
    wall/wall-touch sounds on/off and user-adjustable volume throttles
    for them).

-   Made it so that all wall-hit warnings except the one in front are
    played at half volume.

-   Made autoexec.cfg much more helpful and easy to read.

-   Drop/Ledge detection. There are three types of drops: small (you can
    jump over), big (you can't jump over) and huge (that will hurt you
    if you fell down them and landed on the ground). Drops are detected
    at all sides or just in front (depending on how you set it up).
    Press the "d" key to get a description of what is in the pit in
    front of you (if you are close enough to it). You'll be told that
    it's either: a drop onto the ground or into water, slime or lava. If
    there is no drop in front of you, or you're not close enough to the
    one in front of you, you'll hear an "access denied" sound. The
    defaults are "a" toggles hazard warnings and "i" toggles left/right
    hazard warnings. By default only hazards in front of the player are
    sounded out.

-   The Detector 5000 now alters the volume of the items it has detected
    according to how close the player is to them.

-   An "oomph" sound is generated when you first hit a wall. By default,
    no sound is generated as you continue to stand next to a wall (but
    this can be enabled in autoexec.cfg).

-   Footsteps stop when you're stuck on something. If you are scraping
    along a (diagonal, most likely) wall, you'll hear the wall-scrape
    sound (that was wall-hit.wav in previous releases). You'll also hear
    footsteps (as you *are* moving) but they'll play at half the speed.

-   The ESR can be toggled from its normal mode of operation (enemy
    detection) to a new mode called "hazard detection". This mode
    behaves like the original one but instead of sounding out enemies it
    sounds out ledges/drops in front of you. You can use this feature to
    make sure that you perform jumps and running jumps properly. The ESR
    automatically reverts back to normal operation on level change and
    when you pass over the edge of the drop you're trying to jump over.

-   The ESR and D5k make different sounds to indicate when an object is
    outside of your "field of view". You can set your FOV. You can also
    disable this sound so that no sound whatsoever is made when an
    object is outside your FOV.

AGRIP 0.0.2 (15/04/2004)
========================

Same as 0.0.1 but with the following fixes:

-   README and INSTALL files updated and some minor bug fixes.

-   Increased the range of the ESR to make it easier to work out where
    enemies are. More changes are coming in this department in 0.1.x to
    make it as fair yet accessible as possible. This particular change
    reverts the ESR back to the way it's been for most of AGRIP's life.

-   Made the wall-hit sound that is played if your back is touching a
    wall half of the volume of the other wall-hit sounds (so you know
    that the wall is behind, not in front, of you).

AGRIP 0.0.1 (14/04/2004)
========================

The first alpha release. This is also the first release to support
Windows.

-   A special sound is made if the player is in contact with a wall.
    We'll be improving this to better show if the player is stuck or
    scraping against it in the future.

-   The "sounding" of walls to the left and right of the player can now
    be toggled on/off. We're also making the wall sounding quieter (i.e.
    fall off faster with distance from the wall). They've started to get
    quieter and will continue to do so for a while, until we think we've
    got a good balance.

-   Footsteps are included and can be toggled on/off (though we need
    decent sounds for them at the moment).

-   "Accessible turning" has been implemented in the QuakeForge engine.
    I have made it so that pressing the arrow keys snaps the player a
    certain number of degrees in the direction of the arrow key they
    pressed. The number of degrees is configurable (as with most other
    things) in autoexec.cfg.

-   The documentation has been improved (we're now informing users about
    things like autoexec.cfg) :-).

-   A compass has been added and works quite well (a few minor tweaks
    are on their way).

AGRIP 0.0.0 (14/03/2004)
========================

Initial pre-alpha release.
