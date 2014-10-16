Multiplayer Game Modes
======================

Quake is not just a singleplayer fragfest! In fact, many would say that
it is far more fun to play over the Internet both with and against other
humans. This part explains the variety of game modes on offer and how
you can join in the fun.

AudioQuake gives you the ability to play true Internet multiplayer games
in a variety of modes. You can also play offline practice games against
computer-generated “bots”. This will allow you to hone your skills
before joining real multiplayer games and allows you to play any time
you like (not just when your friends are online).

Because the gametypes available are common to both practice matches and
multiplayer games, the gametypes will be described in the next chapter.
The following chapters detail how you can actually play practice matches
and multiplayer games.

Finally, details are given on how you can run your own Quake server.
This is allows you total control over the gametypes and maps you play,
as well as broadening the availability of accessible Quake matches for
others on the Internet (more on this later).

Gametypes
---------

This chapter details the three main multiplayer gametypes currently
available in AudioQuake. At this time, three popular gametypes are on
offer. More gametypes will be made available as AudioQuake develops.

### Deathmatch

The classic multiplayer game mode. No monsters to get in the way. No
exit. An arena designed solely for combat between players.

In a deathmatch game, you have to move around the deathmatch arena (a
special map designed to make this type of play more enjoyable through
being easy to navigate) and find other players. You must *frag* (blow to
bits) any players you do find along the way.

**Tip:** In deathmatch games, the ESR can detect your nearest enemy
instead of the nearest monster (this behaviour is enabled by default).

#### Deathmatch Variations

There are a few different variations on how items behave in deathmatch
games. These variants on the basic deathmatch rules are described below:

Deathmatch 1
:   Weapons disappear after being picked up but will *respawn* (come
    back) after a short delay. Items (powerups and ammo) will respawn.
    This is one of the most popular types of deathmatch and allows for
    more tactical gameplay because areas of the map that contain
    important weapons and/or items can be guarded.

Deathmatch 2
:   Weapons will not disappear after being picked up. Items (powerups
    and ammo) will disappear. This variation is hardly ever played; it's
    a throwback to the old days of multiplayer Doom games.

Deathmatch 3
:   Weapons don't disappear after being picked up. Items (powerups and
    ammo) will respawn. This is also one of the most popular types of
    deathmatch, especially with new players.

#### Frag and Time Limits

All multiplayer games go on for as long as it takes for one of the
preset game limits to be reached. There are two main limits; the
fraglimit and the timelimit.

The fraglimit is the target score for the match. The first player to get
this many frags is the winner.

The above may take some time, so a timelimit is usually set. This ends
the match after a specific number of minutes has gone past. The winner
is the player with the highest number of frags at the end of this time.

### Team Deathmatch

This mode is similar to the last one but has one main difference: You
are not on your own – you can have an epic battle in which all the
players on your team are against all the players/bots on the enemy team!

Team Deathmatch games are started in the same way as regular
deathmatches and can have frag and time limits, except that the
fraglimit is the number of frags that a team must score to win.

**Tip:** In team games, the ESR detects enemy players or bots, as it
does in deathmatch. It can also detect your team mates. To help you
distinguish between the two, it makes a different sound to represent
team mates than it makes when it detects enemies.

To actively participate in team deathmatches, you must set your
“teamname” the same as a group of other players on the map. You can do
this using the following console command:

~~~~ {.screen}
team red
                
~~~~

The above example would put you on the “red” team.

#### Additional Team Deathmatch Variations

Team deathmatch games are based on deathmatch games. Consequently, they
can use any of the deathmatch variations discussed in the section on
that gametype above. There are also a number of teamplay-specific
variations which can be coupled with the deathmatch ones. They're
described below.

Teamplay 1
:   You can't hurt yourself and you can't hurt your teammates.

Teamplay 2
:   You can hurt yourself and your teammates. You'll lose one frag for
    killing a teammate. This is pretty much the most popular teamplay
    mode.

Teamplay 3
:   You can hurt yourself but not your teammates. This mode is quite
    popular with new players.

### Co-Operative (“co-op”)

This is probably the most interesting game mode and has been the focus
of many a LAN party. In this mode, you play the singleplayer campaign
with the help of other players or bots. You can all work together
against the monsters. Coupled with eh chat facilities on offer, this
gametype can be very enjoyable.

**Tip:** As with deathmatch and team games, the ESR can help you out in
co-op mode too. It will identify the nearest monster, enemy and team
mate and will use a different type of sound for each.

Offline Practice with Bots
--------------------------

This chapter explains how to play the gametypes listed above with bots,
so that you can practice in preparation for real Internet games.

### Deathmatch

The quickest way to start a deathmatch game in the first deathmatch
level is to enter the **dm** console command. However, you'll find that
this limits the variety of your games, as it always uses the same
deathmatch mode and map. To customise the game mode and map, bring down
the console and type:

~~~~ {.screen}
deathmatch mode
                
~~~~

where *`mode`* is a number that corresponds to the variation on the
weapon/item rules as described in the last chapter. For example, if you
wanted to play the most popular type of deathmatch, you'd specify number
one.

**Tip:** If you specify a zero in the above command, deathmatch mode is
disabled. This (coupled with “maxclients 1”) switches you into
singleplayer mode.

The above command simply tells the game that when you next start a map,
you'll want to play it in deathmatch. You now need to chose a map to
play on. In the full version of Quake (not shareware), there are 6
deathmatch maps. They are named “dm1” to “dm6”. AudioQuake provides a
number of extra maps. Use the “map” console command to load one of them
(just as with single-player).

~~~~ {.screen}
map agdm01
                
~~~~

When you're in the map, you will notice that there is not much going on.
To create (“spawn”) a bot, press the comma or dot key on your keyboard.
An enemy will be provided for you to play with. When either of you is
fragged, you'll “respawn” at a random teleporter in the map, ready to
resume the game – but with a slightly decreased frag count (your score).

Please note that the bots act like players; they use all the weapons and
navigate the map on their own. In other words, they're tough!

**Note:** You *can* play deathmatch and other multiplayer gametypes on
the singleplayer maps but it is not as fun due to them only having one
spawnpoint and not looping back on themselves. A deathmatch game is only
as good as the “flow” from room to room in the map.

#### Setting Frag and Time Limits

It is possible to set limits as described in the previous chapter. This
section explains how to do this.

**Warning:** You must type in the commands described here before you
open the deathmatch map you want to play on, or they won't take effect.

To set the fraglimit, simply enter the following command in the console:

~~~~ {.screen}
fraglimit frags
                    
~~~~

where *`frags`* is the number of frags a player must get to win the
match. Set this depending on how many bots you expect to add. A good
general value is 20. The time limit can be set similarly. To set a
10-minute time limit, for example, you'd enter the following into the
console:

~~~~ {.screen}
timelimit 10
                        
~~~~

### Team Deathmatch

Team Deathmatch games are started in the same way as regular
deathmatches and can have frag and time limits. The previous section
explains how to set these up. The important thing to note about starting
team deathmatches is that the teamplay mode must be set before you open
the map and start spawning bots. This can be achieved by using the
simple **teamdm** console command. As above, you can take more control
over the game mode and may by setting them manually – for example:

~~~~ {.screen}
teamplay 1
                
~~~~

You can of course replace the number one above with the number
corresponding to the teamplay rules you prefer (described in the
previous chapter) or specify a zero to disable teamplay (useful when
returning to a singleplayer game afterwards).

Once you're in the game, you can spawn friendly bots with the comma key
and enemy bots with the dot key. You can also call bots to your aid with
the forward slash key. When they hear your call, they'll let you know
and try to get to you. If they make it, they'll let you know when they
arrive, too. When they get to your side, they'll start looking for
enemies again.

**Tip:** In team games, the ESR detects enemy players or bots, as it
does in deathmatch. It can also detect your team mates. To help you
distinguish between the two, it makes a different sound to represent
team mates than it makes when it detects enemies.

### Co-Op

You can start a basic co-op game in the start map using the **co**
console command. Once again, to get more control over the game, you can
do things manually, as follows:

~~~~ {.screen}
deathmatch 0
teamplay mode
coop 1
                
~~~~

Deathmatch mode needs to be disabled to allow access to the co-op
gametype. The **coop** command toggles the game into co-operative mode
and *`mode`* in the **teamplay** command signifies that you can, as with
team deathmatch, choose which teamplay rules you'd like to use. After
the above commands have been entered, you can start the map you wish to
play. For example:

~~~~ {.screen}
map e1m1
                
~~~~

As with team deathmatch practice games, you can spawn friendly bots with
the comma key and enemy bots with the dot key. You can still call bots
to your aid with the forward slash key. When they hear your call,
they'll let you know and try to get to you. If they make it, they'll let
you know when they arrive, too. When they get to your side, they'll
start looking for enemies again.

**Tip:** As with deathmatch and team deathmatch games, the ESR can help
you out in co-op mode too. It will identify the nearest monster, enemy
and team mate and will use a different type of sound for each.

Playing Matches with other People
---------------------------------

Now you know how to play the various game modes and have had some
practice with bots, you are ready to pit your skills against the world!
This chapter explains how you can play games against other humans over
the Internet.

### Multiplayer Basics

When you play any of the gametypes (singleplayer or practice matches)
mentioned above, it is your computer that controls all aspects of the
game – from the generation of game sounds to the behaviour of the
monsters or bots you're playing the game with. When you play a game over
the Internet, this isn't the case. What happens is that your computer
connects to another computer which acts as a *server*. The server
manages connections from all of the players and controls most
game-related things (such as keeping track of players' scores and
movements round a map). Your computer still takes care of dealing with
your input and playing back sounds, but it doesn't control the match
being played in any way.

So, to join an Internet game, you need to connect to a server that other
people may also connect to. There are many QuakeWorld servers out there
but most don't provide the accessibility features that AudioQuake does.
You'll need to connect to a specific AudioQuake server in order to play
the game.

**Note:** We're hoping that AudioQuake will become popular enough that
many people start running servers and many people start playing on these
servers. This will mean that, as with sighted games, you'll always be
able to find some humans to game with. It will, however, take time for
such networks to spring up. In the meantime, we've set up a couple of
servers you can use, but please feel free (and encouraged) to set up
your own servers for you and your friends!

### Setting Your Player Information

When you install AudioQuake, your player name will be set to
“AGRIPUser”. Before you join a multiplayer game, it is a very good idea
to change this to something else, so that your friends can recognise you
(and so that everyone has a different name).

To change your name, you can use the following console command:

~~~~ {.screen}
name yourname
                
~~~~

Most characters are acceptable in player names. If you include any
carets in your name, they won't be displayed as they are a signal to
Quake that you want the next character in your name to be displayed with
a highlight.

If you're going to be playing a team deathmatch game, you'll probably
want to give yourself a team (maybe the collective name that you and
your friends play under, or perhaps a colour). You can do this with the
**team**, as described in the first chapter of this part.

There are two other personalisations you can make regarding your
appearance to others in multiplayer games. These are the colour of your
character's uniform within the game. The console commands **topcolor**
and **bottomcolor** can be used to change these. We mention them here
for completeness.

Now you've made yourself a little more unique in the virtual world, it
is time to join a game...

### Joining a Game

We have set up a few game servers under the AGRIP banner (details can be
found in an appendix), but you're certainly not restricted to playing
AudioQuake on one of these – in fact, we encourage you to seek out other
servers on the Internet to play on and/or to set up a server of your
own. This can be especially rewarding if you know a few people that
you'd like to play the game with. Anyone who sets up a server (covered
later in the manual) can have it automatically advertised to every other
AudioQuake player, via the AGRIP master server. This keeps a list of all
active AudioQuake game servers on the Internet. By using a program that
searches this list (known as a *server browser*), you can find a game to
join. As server admins are free to chose any gametype and selection of
maps that their server runs, you should be able to find a match that
suits your tastes.

To search for games over the whole Internet, you can use either the
AudioQuake Stats and Servers site, or a command-line program called
QStat. This is a very powerful, popular and accessible tool, which
allows you fine control over your searches. For more information on
using QStat, visit it's web site at <http://www.qstat.org/>. Information
on the AudioQuake Stats and Servers web site can be found [in the next
chapter](#mmodes-statsnservers "Chapter 15. AudioQuake Stats and Servers Website").

When you've found a server to join, you can connect to it from within
AudioQuake by issuing the **connect** command, specifying the IP address
or host name of the server. For example, the following two commands both
connect to the primary AGRIP server:

~~~~ {.screen}
connect agrip.org.uk
connect 195.137.71.106
                
~~~~

Remember to seek out and join servers other than the official AGRIP
ones, especially if they are geographically closer to you, as they'll
offer better performance. This will also encourage others to run
third-party servers, thus spreading the AudioQuake work network.

### Chatting

When you're in the game, you may notice some additional messages being
announced, other than the usual item/powerup-related ones. These are
chat messages that are being sent from one player to the other players
on the server. You can send a chat message too; in the console, issue:

~~~~ {.screen}
say message
                
~~~~

This will broadcast a message to all other players. Your message can
contain spaces and there is no requirement to surround it in quotes. If
you only want to send a message to your teammates (perhaps because it
reveals where you are or some other tactical information), you can use
the following command:

~~~~ {.screen}
say_team message
                
~~~~

**Warning:** Be nice to the other people on the server – if you're not,
the server admin has the power to *kick* you from the game and ban you
from reconnecting!

#### Chat History

It's quite likely that, in the heat of battle, you'll miss some chat
message uttered by other players. The following keys can be used to
havigate around the chat history whilst you play:

-   To move back through the history, from the newest to the olders
    message, press PAGE UP. Your position in the list is remembered,
    even when new messages arrive.

-   To move from older to newer messages, press PAGE DOWN. Again, your
    position in the list is saved even when new messages come in.

-   Pressing END mutes all speech and moves you to the newest message in
    the history.

-   If you simply want to repeat the last message that came in, but
    don't want to lose your place in the history, press HOME.

### Playing the Game

There is not much to say specifically about this stage, other than have
fun! Try to be considerate of your teammates, if you're playing a team
gametype. If not, then friendly competition is always good!

#### Scores and Scoreboards

To view the current scoreboard press the TAB key. Players are listed
from the leader down. Scoring is relatively simple; you get one frag for
each enemy you kill. If you kill a team-mate or yourself, you lose a
frag.

The scorebaord will display different information based on what game
mode you're playing in. Team information, for example, is displayed in
team deathmatch games.

#### Online Statistics

As you play games on any of the public servers, your progress is tracked
and can be viewed relative to that of other players on the web. Please
read the section on the [AudioQuake Stats and Servers
Site](#mmodes-statsnservers "Chapter 15. AudioQuake Stats and Servers Website")
for more information.

### Leaving a Game

There are three main ways to leave a game:

-   Say bye to everyone and leave with the **disconnect** command. This
    will remove you from the game in progress, returning you to the
    console.

-   Network problems may forcibly disconnect you from the server. If
    this happens, you could try reconnecting with the **reconnect**
    command.

-   You may have been kicked from the server because of unacceptable
    behaviour. Leaving a game in this way is not recommended.

When you've left a game, you'll be back at the console. From here you
can quit AudioQuake, or start a new single or multiplayer game.

AudioQuake Stats and Servers Website
------------------------------------

This chapter describes the web-based extension to AudioQuake; what it
is, why it's here and how you can use it.

### What is it?

The Stats and Servers website is part of the online community
surrounding AudioQuake. As well as [the community resources on the AGRIP
Wiki](http://www.agrip.org.uk/CommunityResources), the Stats and Servers
site exists to help you get more out of the game. By visiting the site,
you can:

-   Track your progress as an AudioQuake player. Examine the statistics
    gleaned from your recorded frags when playing the game. These
    include your efficiency, kill ratio and overall rank.

-   Compare how you're doing to other players via the global ranking
    tables. these list the top AudioQuake players in a number of orders
    and over varying timeframes.

-   Find Internet games using a web-based server browser (as opposed to
    using the command-line tool [QStat](http://www.qstat.org/)).

### Quick Tour

When you visit the stats and servers site, you're presented with a
number of choices on where to go. The main page lists the sections you
can visit, providing a brief description of each one. The most important
areas of the site fall under a few categories:

-   Pages containing global ranking tables, based on a number of
    criteria. They may be frags, efficiency, overall ranking or
    time-based (e.g. frags for the current day or month).

-   Detailed stats for each known AudioQuake player (accessed via global
    players list).

-   The active servers list.

-   Help and support in the form of a FAQ section.

You can skip to any section at any time by using the global navigation
bar, which is present on most pages in the site.

### Getting Your Stats Included

To get your stats included, all you need to do is play on any of the
public servers that advertise themselves as logging stats. Most servers
do this; some may not (because they're aimed at providing practice for
new players, for example).

Setting up and Running your own Server
--------------------------------------

Running your own AudioQuake server allows total control over which maps,
gametypes and rules you play. It can also be a fun and rewarding thing
to do. If you would like to try setting up your own server, we recommend
that you have a go – it will provide you with your ideal game setup and
other AudioQuake players with an extra place to play (if you run a
public server).

### Clients and Dedicated vs. Listen Servers

Quake is a “client-server” game. This means that at any time, to play
the game you need a client and a server. The client is the program that
the user interacts with, that outputs audio/video and captures input (to
be used when moving the player or typing in the console). The server
runs the game itself. It controls the environment (lifts, buttons) and
items in it (powerups, monsters) and keeps track of scoring in
multiplayer games. If you're playing a singleplayer game or practice
match on your own computer, the client and the server are both running
on your computer. If you're playing an Internet multiplayer game, the
server could be hundreds of miles away.

When setting up a server, the most fundamental decision is what type of
server to set up. Dedicated servers are programs that only perform the
task of running the game. They do not output any audio/video and don't
allow you to play a game on them directly. Listen servers, however, act
as the singleplayer and offline game modes do – except that they allow
connections from other players on the Internet. From your point-of-view,
this makes listen servers “feel” very similar to the on or offline games
you've been accustomed to playing up until now.

#### Why Use Dedicated Servers?

Though they may seem much more convenient and useful, it is generally
seen as bad practice to run a listen server. The main idea is that there
is a delay involved for all players on a server (measured by their
“ping” time). This delay is introduced due to the fact that the player's
input and output data has to be transmitted over the Internet to and
from the server. A player who is directly connected to a listen server
has no delay and therefore the lowest ping time on that server. This
gives them a great advantage when playing the game.

Most servers on the Internet are dedicated ones. They try to be as fair
as possible with respect to ping times by being remote from all players.
For this reason, we strongly recommend that you run a dedicated server
if you can. Even if you only have one computer or the server is on your
local network (and therefore quick to access) we still recommend you run
a dedicated server because it's the standard. The instructions in this
chapter will assume you're using a dedicated server but they will work
similarly in listen mode.

Another advantage to dedicated servers (which is most likely welcomed by
anyone setting one up) is that they don't require terribly fancy
computers to run on. This is partly because they don't need to perform
any rendering of audio/video data, which can take quite a lot of
computing power.

### Public vs. Private and Stats Logging

This topic and many others is dealt with on the [Stats and Servers
site](http://stats.agrip.org.uk/) (in the FAQ section) – be sure to
check it out for the latest information.

### Interacting with the Server Directly

You can do all sorts of things with the server by interacting with its
console when you start it. Tasks such as setting the gametype and map,
getting status and kicking players (as well as chatting to the players
from outside) can be done via the server's console directly. However,
this is not always practical (you may be in the game yourself when you
want to change the map, for example). In this case, you can use the
“remote console” admin feature. It is beyond the scope of this manual to
explain, but you can find out a lot about it and many other features by
using the approach detailed in [Appendix B, *Finding out More – The Web
is Your
Friend!*](#ref-weblinks "Appendix B. Finding out More – The Web is Your Friend!").

It is recommended that you run a dedicated server on Linux, using the
[screen](http://www.gnu.org/software/screen/) program. This allows you
to safely detatch from the machine without stopping the server.
Furthermore, it is recommended that you copy the standard output of the
server to a log file (this will help us fix bugs, should they arise).

### Configuring Your Server

It is very important that you configure your server properly before
running it. To do this you will need to edit the `server.cfg`{.filename}
file, which lives in the `id1/`{.filename} subdirectory of your
AudioQuake installation. Please use a plain text editor on the file.
There are many comments in the file that explain how to set things up,
so they will not be reiterated here.

This section does, however, explain some of the more complex parts of
the configuration.

#### Port

You may need your server to listen for incoming connections on a port
other than the standard one (27500). This could be because of
restrictions on your network, for example. To configure the server to
listen on a particular port, you'll need to specify the port you want it
to listen on on the command line. The following is an example of setting
the dedicated server to listen on port 4242.

~~~~ {.screen}
$ zqds [other options] -port 4242
                    
~~~~

The port should show up in the Stats and Servers site, but it may be a
good idea to remind your players to type in your server's address in the
form `hostname:port`{.filename} when they wish to connect to it.

#### Map Cycles

You can specify a list of maps in your config file so that the server is
not always playing on the same level. The server will move to the next
map after each game is over. By making this list circular (i.e. after
the last map, we tell the server to start again) we can keep the
rotation going.

Here is an example of how you'd set up such a map cycle (or “rotation”)
in `server.cfg`{.filename}. Say you have four maps; A, B, C and D. You
wish for them all to be used one after the other ad infinitum. Here is
what you'd put into the config file:

~~~~ {.programlisting}
localinfo A B
localinfo B C
localinfo C D
localinfo D A
                    
~~~~

**Note:** You can only specify two maps with each use of **localinfo** –
you're effectively telling the game which map is next given the current
one.

### Admin Tasks

You'll find yourself needing to carry out a number of tasks as an admin.
To get the best information on how to do these jobs, please consult
[Appendix B, *Finding out More – The Web is Your
Friend!*](#ref-weblinks "Appendix B. Finding out More – The Web is Your Friend!").
Also, please join the mailing list for server admins. We use it to
provide a lot of useful information and arrange regular matches.
