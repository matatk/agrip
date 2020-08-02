# QMODs

## An Introduction to QMODs

### What?

This is all about a format for packaging your modifications that will make them easy to install by end-users. The QMOD system is basically a rip-off of a similar idea used by the game Unreal – users are given a single file that contains the modification and some metadata; when they open this file, the game interprets the metadata and presents a set-up routine specific to that mod but using the game’s standard user interface.

### Why?

As far as the user is concerned, installing mods for the game will be easy, with a guaranteed user interface and level of accessibility. They also get to choose which mod to play, from a list of installed ones, via the launcher. Finally, they can also uninstall mods easily, again via the launcher.

For the developer, you get the benefit of giving your users the above benefits with very little work – simply package your mod up in the way described here, adding the required metadata\! In addition, you can ask the launcher to keep your mod’s config files up-to-date with any changes put into the user’s standard game config files (at no development cost to yourself).

#### Why Not?

We’ve designed this system to make it ideal for people to mod *AudioQuake*; it does all of the chores of setting up mods for the user and adds little extra work for the developer. There is, however, one situation in which it is not the best way to proceed: total conversions. Total conversions modify the game engine as well as the content and/or gamecode, so they are technically different games.

We felt that those of you making total conversions would want to make your own separate game with its own installer. Naturally, the QMOD system can be used to create mods for any total conversion of *AudioQuake*, just as it can with *AudioQuake* itself, so even if you’re a total conversion developer, you can still take advantage of it\!

## How? (for Developers)

It’s easy\! You need to package up all the files required by your mod, in a particular way, then create an INI file to describe your mod to the installer. Here is how…

1.  Ensure that you have packaged up all the files your mod needs (sound, progs, models, maps, graphics) into the correct directory structure below your *AudioQuake* parent directory.

    Furthermore, ensure that anything that *isn’t* required is not in this directory\! This includes source code (that should be distributed separately).

2.  Ensure your mod’s config instructions are included in a single file, mod.cfg. You can add mod-specific keys in this file. This file overrides settings in the user’s `config.cfg` and `autoexec.cfg` files.

    Later on, you must specify if you want the game launcher to keep your mod updated with changes the user makes to their `config.cfg` and `autoexec.cfg` files.

    Here is part of the `mod.cfg` file from the “JediQuake” modification:

    ``` screen
    // Commands specific to this MOD...

    bind "h" "+Blaster"
    // default key to use blaster is "h"
    ```

3.  Take your mod directory and put it in a new directory that has the name of your mod. If you are naming your mod directories with an appended version number (`jediquake37`, for example), the name you give to the parent directory should *not* include this (`jediquke`, for example).

4.  Construct an INI file for your mod in this parent directory, next to your mod’s installation directory. The INI file should be called `qmod.ini`. For details of all available options, consult [Appendix B, *QMOD INI File Settings*](#ref-qmodini "Appendix B. QMOD INI File Settings"). Here is an example, again taken from the “JediQuake” modification:

    ``` screen
    [general]
    name=JediQuake
    shortdesc=Audio *Quake* with a Star Wars flair!
    version=3.7
    gamedir=jediquake37
    watch_config=yes
    watch_autoexec=yes

    [longdesc]
    00=This mod adds various Star Wars style weapons to the game along with
    01=force powers, new weapons and modifications of existing weapons...
    02=The bots may also surprise you as well...
    03=See the jediquake folder for documentation.
    ```

5.  ZIP up the parent directory so that you have created a ZIP file with two items in it – the MOD’s installation directory and the `qmod.ini` file.

    Finally, rename the ZIP file to the name of the parent directory (i.e. the MOD’s name) with a `.qmod` extension to replace the `.zip` one it pops out of your ZIP creator with.

## How? (for Users)

Very easy\! On Windows, a simple double-click should open the game launcher in QMOD installation mode. On Linux, entering the following command, in the user’s ZQuake directory, will do the job:

``` screen
$ ./start.pl filename.qmod

```
