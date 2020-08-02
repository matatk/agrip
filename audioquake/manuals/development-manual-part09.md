# QMOD INI File Settings

The following sections detail the various options available to MOD authors in QMOD INI files. The are split into the two (current) sections of the INI file – "general" and "longdesc".

### General

This section contains details that the installer and launcher will both use. It allows you to provide the user with basic information about the MOD and determines how it will react to the user's (potentially customised) config files.

**Table B.1. Configuration Items for the General Section of QMOD INI files**

| Key             | Notes                                                                                                                                                                  | Example(s)                                    |
| :-------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------- |
| name            | Name that users are presented with (in the installer and mod list)                                                                                                     | JediQuake                                     |
| shortdesc       | Short(\!\!) description used by installer and mod list in the launcher                                                                                                 | *AudioQuake* with a Star Wars flair\!           |
| version         | The (user-facing) version number of your mod                                                                                                                           | 3.7                                           |
| gamedir         | Which directory your mod must run from                                                                                                                                 | jediquake37                                   |
| watch\_config   | Should your mod be updated with the user's latest `config.cfg` file when it changes? Note that this does not change your mod's `mod.cfg` file, which has precedence.   | yes (or anything else if you don't want this) |
| watch\_autoexec | Should your mod be updated with the user's latest `autoexec.cfg` file when it changes? Note that this does not change your mod's `mod.cfg` file, which has precedence. | yes (or anything else if you don't want this) |

#### Example

For your convenience, here's an example "general" section:

``` screen
[general]
name=JediQuake
shortdesc=Audio *Quake* with a Star Wars flair!
version=3.7
gamedir=jediquake37
watch_config=yes
watch_autoexec=yes

```

### Longdesc

This section is optional and, if included, is used to give the user more information about the MOD when they select it in the game launcher's menu.

Create it by assigning each "chunk" of your MOD's description to a key. Each chunk must be less than 80 characters long. Use keys which, when sorted, will result in the correct ordering of chunks (i.e. just number each chunk).

The obligatory example:

``` screen
[longdesc]
00=This mod adds various Star Wars style weapons to the game along with
01=force powers, new weapons and modifications of existing weapons...
02=The bots may also surprise you as well...
03=See the jediquake folder for documentation.

```
