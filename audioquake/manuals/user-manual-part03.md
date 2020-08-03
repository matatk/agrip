<a name="singleplayer-game-modes"></a>
# Singleplayer game modes

This part describes the singleplayer game moves on offer and how you can start playing them.

## The *AudioQuake* Tutorial

A series of tutorial maps has been created for you to practice with before entering the world of *Quake*. These maps start very simple and the learning curve is quite shallow. Topics covered include:

  - Navigation (including stairs, corners, open spaces, drops and jumps).

  - How to detect where enemies are and switch weapons.

  - Using switches and doors.

The idea of the tutorial maps is to let you get used to the features of *AudioQuake* and *Quake* slowly before jumping in to a real game. To start the tutorial, either choose the appropriate option from the game launcher or, if you're already in the game, bring down the console and enter:

``` screen
tut

```

**Tip:** For power users, the above is equivalent to entering the following three commands…

``` screen
deathmatch 0
maxclients 1
map agtut01

```

This takes the game out of multiplayer mode and loads the first tutorial map. You can then play through the entire set of tutorials. Each tutorial map is linked to the next. If you wish to jump into a certain tutorial map, don't\! You can use the save and load features of the game to pause and resume your journey through the tutorial—for example…

``` screen
save tutorial

```

Would save your current game under the name "tutorial". To later resume this game, use the **load** command, specifying the same game name.

As you move around the tutorial maps, you'll receive short messages that include important information and/or tips on how to play. You can repeat these messages by using the repeat last message key if you miss any of them.

Remember that when you've come to the end of a map, the game will pause for a few moments. To move on, press <kbd>Space</kbd> (you'll only be able to do this after a few seconds).

## Single-player

The traditional game mode. This is the classic "story" mode in which you fight your way through four episodes of monsters in various evil hideouts. You're encouraged to read id Software's `MANUAL.txt` file if you want to know the full "plot" of the game.

The basic idea is that scientists have created devices called "slipgates" that allow people to travel to other dimensions. Sadly those that go through seem to come back in some form of rage (if at all). It is down to you to dive in, get to whatever is in charge of all this destruction and kill it.

There are four episodes in *Quake*. Each one starts on Earth, in one of the four slipgate facilities. When you've fought your way through these facilities, you leave to the dimension that the slipgate points to. At the end of each episode, you collect a "Rune". When you have all four of these, the door to *Quake*'s domain is opened!

At the start of the game, there is a special map that allows you to chose your skill level and episode. To open it, bring down the console and type:

``` screen
sp

```

**Tip:** For power users, the above is equivalent to entering the following three commands…

``` screen
deathmatch 0
maxclients 1
map start

```

This disables deathmatch mode and loads the map. You'll be facing three corridors. The one to the left sets the skill to "easy". The one in the middle to "normal" and if you are able to survive the right-hand corridor, it will set the skill to "hard" as you walk down the corridors, you'll be told this. When you get to the end, step through the teleporter to be taken to the next chamber.

Choosing which episode to play is done by entering one of the four doors in the room you'll now find yourself in. As with the skill corridors you just walked through, the game tells you which episode you're attempting to enter. Episode 1 is forward a little and on the left as you arrive here and is a good place to start. (It's up some stairs; walk forward a little, turn to your left and go forward to find it.)

**Warning:** *AudioQuake* provides fairly decent accessibility on some of the game's maps, but they weren't designed with accessibility in mind, so it's most likely not possible to complete them all.

The maps are named using a format "e*X*m*Y*" where *x* is a number from 1 to 4 and *y* is a number between 1 and 8. Episodes 2 and 3 only have 7 maps so that second (map) number is lower for them. The last map is always the secret one for that episode (i.e. it is found via a secret area on one of the other maps).

To load a map in single-player mode, type

``` screen
deathmatch 0
maxclients 1
map e1m1

```

(for example) into the console. The command shown would take you to the first map of episode 1. Of course, this is not how you are meant to play the game, but we thought it best to let you in on this information so that you could at least find maps you like to play.

### Difficulty level

The skill setting has been touched on above. By default, if you start *AudioQuake* from the launcher and tell it to jump straight in to a certain episode, the medium ("normal") difficulty level will be used. If you are new to the game, it can be quite hard. To switch to the "easy" skill level, bring down the console and type:

``` screen
skill 0

```

Now some monsters will disappear and others' attacks will not cause as much damage.

**Note:** You must re-open the map you want to play on after changing the skill level. The new skill level will then take effect until you change it again (set it to 1 for medium, 2 for hard and 3 for nightmare difficulty).

### Game Saving and Loading

As you progress through the game and collect bigger, badder weapons and the almighty runes, you'll want to preserve your progress. To save and load games, use the console. Here are the commands you'll need to know about:

* **save** This command requires that you type in a name for your game. You can save as many games as you like. They'll end up in the `agrip/` directory under your *AudioQuake* installation.
* **load** This command is used to restore games saved with the **save**. Remember to supply the game's name when you use it.

**Tip:** The commands only work if you've previously used "maxclients 1" as described above. That forces the *Quake* into single-player mode (allows only you to enter the game) and makes saving of games possible.
