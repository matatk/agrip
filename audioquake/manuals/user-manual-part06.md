# Customising AudioQuake

As has been touched on before, you are strongly encouraged to tailor the way AudioQuake works to suit your own taste and level of sight. Here are examples of the types of thing you can customise in the game:

  - Navigation aid and EtherScan RADAR detection ranges.

  - Detector 5000 detection interval.

  - How far the player turns (angle-wise) per press of the left and right arrow keys.

  - The keys you press to use any of the navigation aids/devices.

  - How the spoken interface works – changing voices or using hardware synthesisers or Braille displays.

In this part, you’ll learn how to change settings such as these and more.

## Menu–Based Customisation with the Launcher

The game launcher provides a few important features for customising the accessibility-related features of the game. Using the menu items of the launcher, you can:

  - Examine and edit your keybindings. These are the settings that determine which keys activate which game features or player actions (e.g. toggling the D5k or firing your weapon).

  - Adjust options such as which devices are activated when you enter the game, which sub-features of the devices are enabled by default, sound volume levels and detection distances.

Instructions are provided by the launcher on how to make use of these features and change/review your settings.

**Tip:** If you’re an advanced user, you might like to edit the configuration files directly. They are all commented to explain how things work. Read the next section for details.

## `autoexec.cfg`

If you’re an advanced user, or are thinking of setting up a server, you’ll not be a stranger to editing text files and may find doing so to be more productive than using the menu as described in the previous chapter.

As part of the start-up procedure, the game looks for user settings in a number of files. `autoexec.cfg` is one of these files. By convention, it is the place where all AudioQuake-specific settings are kept. As the game starts, it reads this file and acts on the commands found in it.

**Tip:** There is another file, called `config.cfg` that is also read. This contains general Quake settings. The curious may want to read this file too, but it is beyond the scope of this book.

You can customise the way AudioQuake behaves by editing the file `autoexec.cfg`. This file can be found in your `~/.zquake/AudioQuake/` directory on Linux, or the `AudioQuake` folder where you installed AudioQuake if you’re using Windows (if you used the default, that would make it `C:\Program Files\AudioQuake\autoexec.cfg`).

The file has a number of sections and has many comments in it to explain what each individual setting actually does. This part of the book will not repeat what is written in the file, but gives a general overview of what each section of the file is for.

**Tip:** To edit the file, you need to use a plain-text editor. Vim, Emacs, Nano or Notepad will do the job.

### Object Toggle Settings

This section controls which objects and which features of these objects, are to be activated when the game starts.

If you use the toggle keys to turn things on/off and then complete a map, the settings you had at the end of the last one will be carried on to the new map.

### Detection Settings

This part of the file allows you to configure things like the detection distance, ESR and D5k field of view and if they are to make sounds when an item or enemy is outside of your field of view. You can specify the default player turning angle here, too (this is the angle the player turns when you press the left or right arrow key).

### Sound Volume Settings

Here you can control how loud various sounds AudioQuake makes actually are. They act as “throttles” that AudioQuake will apply before it makes sounds. You can control the volume of all of the AudioQuake objects.

### Key Bindings

Key bindings just tell the game what you want to happen when you press a certain key on the keyboard. This section allows you to redefine which keys cause which things to happen in the game (such as toggling devices on/off or using the compass).

Bindings work by specifying a key and then the command that key is meant to activate. In Quake, these commands can be quite cryptic so we have added “aliases” for them. These aliases are much more readable names for the in-game commands and should make configuring AudioQuake much easier for you.

### Aliases

As mentioned above, aliases exist to provide human-readable equivalents to the commands Quake actually uses. You don’t need to edit this section – it is maintained by us for each release. It only exists to make configuration easier.

## The Launcher – Alternative Speech/Braille Settings

Customising the launcher itself is not hard to do and allows you to make big changes to how the interface of AudioQuake works. Read on for more information.

### Changing the Default SAPI Voice

This is not strictly customising the launcher, but does have a great effect on how AudioQuake sounds if you’re using the SAPI interface. Your default voice is set in the “Speech” Control Panel applet and it is this voice that the SAPI interface uses to talk to you. Here are the steps you would need to follow to change the default voice:

1.  Get to the Control Panel (`Start`, `Settings`, `Control Panel`).

2.  Open the “Speech” icon to start the Speech Control Panel applet.

3.  When the applet opens, you’ll be on the first of three tabs (“Speech Recognition”). The option for the default voice is on the second tab, “Text To Speech”. Move to the second tab and then down through the controls. Quite soon, you’ll get to a section labelled “Voice Selection”. There is a drop-down list here that allows you to chose the default voice. We recommend either Mary or Mike.

4.  To save your changes, move to the `OK` button and activate it.

5.  You can now close the Control Panel. Your new choice of default voice will be used when you next start the AudioQuake launcher.

### Editing Launcher Options

The next sections in this chapter cover options you set inside the launcher itself. This section explains the general procedure for editing launcher settings.

The launcher is actually a plain text file and can be easily edited with your favourite text editor (such as vim or notepad). In this file, there are a number of lines you can edit to change the way speech output works. They’ve been grouped together into a configuration section. At the time of writing, this section starts on line 46 of the `start.pl` file (there are comments in the file that explain where it starts and ends).

#### What to Configure

There are a number of settings (“variables”) you can configure. For example, if you want to change from using the SAPI interface to using a hardware synthesiser and you’re running Windows, you’d change the line:

``` programlisting
my $win32_talker = '|ag_say.exe';
                    
```

To something more like this:

``` programlisting
my $win32_talker = '>COM1:';
                    
```

**Note:** When you’re changing a variable, only edit what lies between the two single or double quotes on that line of the script.

Please read on for more specific information about changing to a hardware speech synthesiser; this was just an example.

**Tip:** There are a lot of comments in the file (lines beginning with a hash) that explain the meaning of these variables and give suggestions of how you might like to alter them.

#### Linux and Windows Differences

The **start.pl** program is the same on Linux and Windows. Some configuration variables only take effect on either of the two systems.

If you’re running Linux, you can ignore all variables that have “win32” in their names – you need to edit variables with “nix” in their names.

Likewise, if you’re running Windows, you need to edit only the variables with “win32” in their names and can safely ignore variables with “nix” in their names.

### Using a Different Software Synthesiser

If you’re using Linux, you might want to customise which software synthesiser AudioQuake should use. Do this by editing the “$nix\_talker” variable. Examples of possible TTS engines are given in the script.

It is not expected that Windows users would need to use a different TTS program but it is as simple as altering the “$win32\_talker” variable.

**Note:** Remember that if you’re using a software synthesiser, you’ll want to put the pipe (“|”) character before the first letter of the path to the program. This instructs the AudioQuake launcher to send data to the program in the correct way.

### Using a Hardware Speech Synthesiser or Braille Display

If you have a hardware speech synthesiser or Braille display attached to your computer’s serial port, you can set up the launcher to work with it instead of the SAPI interface.

To set up a serial speech synthesiser or Braille display, you will need to change the following variables:

  - If you’re on Linux, change the “$nix\_talker” variable to “\>/dev/ttyS0” (or ttyS1 if the device is attached to your second serial port).
    
    If you’re running Windows, change the “$win32\_talker” variable to “\>COM1” (or COM2 if the device is attached to your second serial port).

  - Modify the “$nix\_init\_command” or “$win32\_init\_command” variable accordingly. These variables are used to set up the serial port so that it sends data to the device in the right format.
    
    Examples of commands you could put into these variables are given in the file and in most cases a simple copy and paste should be all that’s required to get things going. If it’s not working, consult the device’s manual.

  - Modify the “$init\_string” variable if necessary. Some synthesisers require a message to be sent to them before they can start talking (to set up the voice, for example). This variable contains that message. Not all devices require this, so you might not need to alter it.

  - You’ll probably want to change the “$high\_priority\_prefix” variable too. This is the data that is sent to the device just before a message of high importance. The reason for having this feature is so that we can force the device to stop speaking what it was saying and say an important message straight away.
    
    Again, details on what you’ll probably want to change this variable to can be found in the `start.pl` script.

### Other Options

Currently there is only one other launcher option. This controls if the launcher prints out anything on the console/screen it was started from. It’s on by default.

The variable is called “$print\_to\_stdout\_flag” and there are comments below it that explain why you may or may not want to alter it.
