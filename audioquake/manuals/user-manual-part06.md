<a name="customising-audioquake"></a>
# Customising *AudioQuake*

As has been touched on before, you are strongly encouraged to tailor the way *AudioQuake* works to suit your own taste and level of sight. Here are examples of the types of thing you can customise in the game:

* Navigation aid and EtherScan RADAR detection ranges.

* Detector 5000 detection interval.

* How far the player turns (angle-wise) per press of the left and right arrow keys.

* The keys you press to use any of the navigation aids/devices.

* How the spoken interface works – changing voices or using hardware synthesisers or Braille displays.

In this part, you'll learn how to change settings such as these and more.

## Config files

There are two files that you can edit to customise the game. The game runs through the contents of these files when it starts up.

* `autoexec.cfg`—by convention, this is the place where all *AudioQuake*-specific settings are kept. As the game starts, it reads this file and acts on the commands found in it.

* `config.cfg`—contains general *Quake* settings. The curious may want to read this file too, but it is beyond the scope of this section.

You can open these files for editing via the launcher. They're plain text files. They have a number of sections and many comments (indicated by lines starting with two forward slashes) in it to explain what each individual setting actually does. This section doesn't repeat what is written in the file, but gives a general overview of what each section of the file is for.

## `autoexec.cfg` settings

### Object toggle settings

This section controls which objects and which features of these objects, are to be activated when the game starts.

If you use the toggle keys to turn things on/off and then complete a map, the settings you had at the end of the last one will be carried on to the new map.

### Detection settings

This part of the file allows you to configure things like the detection distance, ESR and D5k field of view and if they are to make sounds when an item or enemy is outside of your field of view. You can specify the default player turning angle here, too (this is the angle the player turns when you press the left or right arrow key).

### Sound volume settings

Here you can control how loud various sounds *AudioQuake* makes actually are. They act as "throttles" that *AudioQuake* will apply before it makes sounds. You can control the volume of all of the *AudioQuake* objects.

### Key bindings

Key bindings just tell the game what you want to happen when you press a certain key on the keyboard. This section allows you to redefine which keys cause which things to happen in the game (such as toggling devices on/off or using the compass).

Bindings work by specifying a key and then the command that key is meant to activate. In *Quake*, these commands can be quite cryptic so we have added "aliases" for them. These aliases are much more readable names for the in-game commands and should make configuring *AudioQuake* much easier for you.

### Aliases

As mentioned above, aliases exist to provide human-readable equivalents to the commands *Quake* actually uses. You don't need to edit this section – it is maintained by us for each release. It only exists to make configuration easier.
