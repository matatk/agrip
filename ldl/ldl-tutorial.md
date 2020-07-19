# LDL Concept Release Tutorial

This document is about the preliminary LDL concept release. For the latest information on LDL, which will be changing frequently at this early stage, please visit <http://www.agrip.org.uk/ldl/>.

Please help out Matthew’s research by filling in the short survey on your feelings about LDL, which is available at <http://www.agrip.org.uk/ldl/survey/>. I need answers to these questions by the start of May if possible (though up to and including the 4th would be manageable). Please accept my apologies for the short notice but it’s been a very busy few months working on LDL and also applying for funding for my work.

# What is LDL?

The AGRIP *Level Description Language*, or LDL, is a language being developed to allow people to easily describe 3D spaces. Currently the description is written in a type of XML file, but later we aim to expand to more natural language and also provide level-editing programs. LDL is currently aimed at blind gamers who want to make maps for Quake. This is a very preliminary concept release, so it’s important to say what it does, doesn’t and will do (this will be discussed shortly).

## Before LDL

How would one go about making maps for Quake before LDL? If you just want to find out how to use LDL you can skip this section, however it does provide useful background information on the area that we are now working on providing access to.

1.  Well first off you’d have to be able to see well enough to use a graphical CAD-like program - a level/map editor - to draw the shapes of your rooms on the screen.

2.  The shapes you draw - brushes - would make up the rooms in the map. It works like building blocks and you have to put many blocks together to make a single room - one for the floor, ceiling and all of the sides. If you wanted to put a hole in a wall (for a door, for example), you would have to build the brushes around the space where you wanted the hole to be.
    
    Later editors alleviated the difficulties caused by this system and made up “smart” brushes that automatically created the gaps for holes (the editor used by the AGRIP project, QuArK, does this).

3.  Textures would have to be applied to the brushes. Entities (weapons, lights, monsters) would be added to the map to make it more interesting. Doors and buttons are special entities that are associated with a brush (that moves, for example, when you walk near it).

4.  When the map is finished it must be saved as a *.map* file so that the level compilation tools can read it. The *.map* file is even lower-level than many level editors’ internal formats. It contains a list of the brushes and entities in the map, but with the bushes defined in terms of triples of points on the 3D planes that make them up.

5.  Finally the *.map* file can be compiled with the Quake map compilation tools. These would be run as follows.
    
      - bsp *mapname*  
        This converts the textual description of planes and so on in the text file to a binary format that can be read by the engine.
    
      - light *mapname*  
        This calculates all of the lighting values (more modern game engines do some/all of this on-the-fly during game-play but doing it as a pre-processing stage saves a lot of resource requirement later on).
    
      - vis *mapname*  
        This helps the engine work out which parts of the map don’t need to be displayed depending on the viewpoint of the player, thus saving the engine from having to draw everything in the map at all times and speeding things up dramatically.

## How Does LDL Work?

The operating principle of LDL is that we start with as high-level a description as possible and gradually transform it, by filling in the details, into a low-level description suitable for compiling with the standard Quake map tools. This allows you to talk in terms of rooms and connections between them, whereas the map tools at the bottom of the chain want to know about scary things like intersecting 3D planes.

LDL - the code - is actually a chain as mentioned above. Each stage is a separate program and the whole thing works by feeding the output of one into the next, until we have our final answer - the *.map* file.

You start by writing a pretty high-level XML file that describes your map (later we plan to add even easier ways to get data into the system, such as natural language, or an interactive editor program but for now we need to test the basic premise). An XML file is just a plain text file (think similar to HTML if you’ve used that before), which you can edit with any text editor (e.g. Notepad, Notepad++, ViM, …)

The work-flow for using LDL is as follows.

1.  Write your XML file with a text editor, as per the examples in the tutorial section below.

2.  Run the LDL tools on it (a script/batch file is provided to automate this). They should be run from a terminal/command window.
    
    The scripts will check that your XML file is “well-formed” before going further. This means checking that you have typed it in without mistakes such as unclosed tags.
    
    If it doesn’t work, there could be an error in your XML file (or a bug in the LDL code, which we implore you to report\!) Go back to the XML, try to fix the problem (error messages will try to help you do this) and try again.
    
    If/when it does work, you will then be able to play the map in AudioQuake.

## What Does the LDL Test Release Do?

The test release is focused on describing the spaces and making simple deathmatch maps. It does the following.

  - Allows you to describe rooms - their size and style (which causes texturing and lighting to be automatically applied so that sighted people can play your maps too).

  - Allows you to specify how rooms are connected (directly) to each other - i.e. you can specify that a given room is positioned north of another room and that there should be a door between them and both rooms will be positioned correctly - including at the right height - and the door - and any required stairs or an elevation platform - inserted.

  - Placement of items within rooms (such as player start points and weapons) on a compass directions system (this is planned to be expanded into percentage-based coordinates in the future).

## What Does it *Not* do?

  - It can’t make connections between rooms that are not next to each other - that is to say you need to specify the corridors that connect between rooms (as rooms themselves, which they are - they’re usually just longer and thinner).

## Supported, Planned and Blue Sky Features

The lower levels of LDL support many features, not all of which are currently enabled. The test release is designed mainly to assess how well the tool works as a way to allow blind people to specify 3D spaces, so doesn’t contain all of the features of regular Quake, but we will be adding many (and fixing reported bugs) quickly over the coming weeks and months.

Some features are planned for future releases of LDL, as follows.

  - Higher-level descriptions - giving you the ability to say roughly where some rooms are in 3D space and the programs working out the best way to link them (i.e. with corridors, stairs or lifts).

  - Providing a natural language-like interface.

  - Providing a level editor application to make writing the descriptions and make error-checking easier.

Some limitations of the system that may be addressed in future include the inability of it to cope with angled/slanted brushes. This isn’t so much of a limitation at the moment as we can use stairs and so on - and are not aware of the best way to present such complex structures. Once we’ve done more research into how to navigate such maps and how to represent them in LDL this may be an area of improvement.

For now, however, there’s a great deal you *can* do - as we hope the tutorial below will show.

# Getting LDL

## Requirements

LDL currently runs on Linux and Windows, with plans to support MacOS X as soon as possible. To make it run, you will need Python 2.5. If you’re on Linux this should be as easy as

``` 
 apt-get install python2.5
```

or similar. On Windows, you should get the Windows Installer package from <http://python.org/ftp/python/2.5.2/python-2.5.2.msi> and install it.

## Getting LDL

The test release is available from <http://www.agrip.org.uk/ldl/>. It contains the LDL map translation scripts and Quake map compilation tools.

## Running LDL

Here are the (brief) instructions for setting up LDL on your system.

### …on Linux

There are no restrictions on where you should unpack the zip file and run the scripts from. However, you’ll need to copy the Quake map compilation tools (*qbsp*, *light* and *vis*) to somewhere on your path (such as /usr/local/bin/ or \~/bin/ if it’s on your path).

To test your installation, open a terminal and issue the following commands.

``` 
 cd ~/.zquake/ldl/
 ./mkmap.sh tut08
```

### …on Windows

When you’ve installed Python 2.5 and downloaded the test release, please unzip it into your AudioQuake directory, so that the *ldl/* folder is inside your AudioQuake folder, alongside *id1/*.

To test your installation, open a command prompt and issue the following commands.

``` 
 cd "C:\Program Files\AudioQuake\ldl\"
 mkmap tut08
```

Once this command has completed, issue the following command to test the map.

``` 
 test tut08
```

### Expected Test Results

This should (a) transform the XML into a *.map* file using the LDL scripts, then (b) compile the map using the quake map tools and (c) run it using AudioQuake.

If this is not what happens, consult <http://www.agrip.org.uk/ldl/> and the AGRIP-discuss mailing list for help - <http://lists.agrip.org.uk/cgi-bin/mailman/listinfo/agrip-discuss>. Any error messages will be output to the command window for you to read and submit as part of your email to the mailing list. If you are working on your own map, it’s also a good idea to send in your XML file so we can see if there are any errors in it.

# Making Maps with LDL

This section is a tutorial on making levels with LDL. It assumes you’ve followed the set-up instructions above and that the system is working.

## Basic Concepts

Before you start, please be aware of the following.

  - LDL maps are XML files (which are plain text files and look similar to HTML files). You can edit them with any text editor. You should be able to copy and paste from this document into a text file - name it something like *tutorial.xml* and run it through the LDL system in a terminal/command window, as above.
    
    If you are new to XML don’t worry - you can copy the examples given here. Also, there is a tutorial on XML at <http://xml.resource.org/authoring/draft-mrose-writing-rfcs.html#xml_basics>.

  - When you run the LDL scripts on a map, you should not include the *.xml* part of the map’s name.

  - It is strongly recommended that you compile and test the map as you go along with writing it as often as you can do so. This will help you appreciate how the system works and help you to determine when an error in your map (or bug in our code) has been introduced.
    
    The LDL scripts will point out errors in the XML file such as unclosed tags. These need to be fixed before you can continue (an example is given below).

  - Unless you add enough deathmatch player start points, you will have great problems running the map in deathmatch mode, as all of the bots will try to spawn out of one start point. You’ll read later how to add start points.
    
    For now, be aware that the map test script/batch file is provided so that you can test your maps in non-deathmatch mode. For that to work, you have to have one - and only one - info\_player\_start entity in your map. Again, more on this later.

## Hello, World\!

Let’s start with a very simple example map.

``` 
 <map name='tut01' style='base'>
     <room id='start'>
        <item type='info_player_start' pos='c' />
     </room>
 </map>
```

That’s the simplest map you can make with LDL that can be played. Let’s take a look at each line and see what it does…

``` 
 <map name='tut01' style='base'>
```

This starts our map off; it’s an XML *element* called “map”. Elements are written inside angle-brackets and may also have additional information specified about them by way of *attributes*. The map element has two attributes:

  - A name, which is “test” in this case. This is what is displayed in the console when the map is loaded.

  - A *style*, which is “base” in this case. This affects lighting, texturing, sounds and key types used in the map.
    
    The style of a map is used to denote which texture, lighting and - to some extent - sound scheme is applied. Currently, LDL supports “base” and “medieval”.

As well as having attributes, an element can contain other elements. When we get to the end of the map, we must *close* the map element with \</map\>.

Back to the map file…

``` 
 <room id='start'>
```

This and the following 2 lines represent a room and its contents. Note that you must always close \<room\> elements, just like any other.

The room has been given an *id* so that LDL can uniquely identify it later. You must supply an ID for all rooms in your map. We didn’t bother to specify a size for it, so it will default to being “medium” in size in all 3 directions - width, depth and height.

``` 
 <item type='info_player_start' pos='c' />
```

This room contains one *item* - a player start point which, according to its `pos` attribute, is to be positioned in the centre of its containing room. The item itself does not contain anything (this wouldn’t make much sense) so it can be closed simply by writing a forward slash before the closing angle bracket. This is the same as if we had written it out in full, as follows.

``` 
 <item type='info_player_start' pos='c'></item>
```

We close the room element because we have no more items to add.

``` 
 </room>
```

Finally we have got to the end of the map file so we can close the map element.

``` 
 </map>
```

Try running this map through the LDL system. As part of the conversion to a *.map* file (which will be converted by the standard Quake mapping tools to a *.bsp*) the level will be textured and lit appropriately for the style chosen above. Save the XML as *tut01.xml* and convert, compile and test the map with, if you’re using Linux:

``` 
 ./mkmap.sh tut01
```

or, in Windows:

``` 
 mkmap tut01
 test tut01
```

Remember to just type the part of the filename before the *.xml* extension. Once the LDL scripts have run and the Quake map tools have finished processing, the game will start and you should be in a medium-sized room with not much else going on.

## Room Sizes

When you don’t specify a size for the room, it’s made “medium” by default. Let’s try specifying a different size for the room. Here’s the whole map, with the size altered.

``` 
 <map name='tut02' style='base'>
    <room id='start' size='large'>
        <item type='info_player_start' pos='c' />
    </room>
 </map>
```

Try saving it and running it. You should find that you can walk much further in any direction before hitting the walls.

There are several room sizes: vsmall, small, med, big, large, vlarge, xlarge, huge, vhuge and xhuge.

If you were to specify a size that is not valid, you would get an error message. Try that now, with the following input.

``` 
 <map name='tut03' style='base'>
    <room id='start' size='reallyreallyreallysmall'>
        <item type='info_player_start' pos='c' />
    </room>
 </map>
```

Because the room is a 3D object, you can also specify its size in the 3 dimensions - width, depth and height. Different programs and systems use these terms differently, so to avoid any possible confusion, we’ll define them as LDL uses them here.

  - width  
    is, if you are stood inside the room facing north (which is how you start off), the size of the room from left to right.

  - depth  
    is the distance from back to front

  - height  
    is the distance from floor to ceiling.

When you only give one word for the size, LDL will work out an appropriate 3D room size based on the one given. If you want more control, though, you’ll need to specify all three (note that you can’t specify just 2 of the 3 dimensions - in that case, LDL could not know which 2 of the 3 you were referring to).

Try making the room into a corridor - copy and paste the following into a file, then save, compile and test it.

``` 
 <map name='tut04' style='base'>
    <room id='start' size='vsmall big small'>
        <item type='info_player_start' pos='c' />
    </room>
 </map>
```

You will spawn in the middle of a thin, but long, corridor-shaped room. Try strafing left/right and notice you hit the walls almost immediately. Then try going back and forward.

One last thing to note about room sizes in LDL is that the sizes in the width and depth dimensions have been designed to increase more quickly than in height - that is to say that a room with the size “med” (which is the same as “med med med”) will be wider and deeper than it is tall. It will be as wide as it is deep but it won’t be quite as high. This is because in most Quake maps, as with most buildings, rooms are not completely cube-shaped. This feature is designed to make it easy for you to make realistically-sized rooms even when you only specify one word for the size attribute.

If you really really want to make your room exactly cube-shaped, you can - use any of the following for your room’s size attribute “vsmall vsmall small”, “small small big”, “med med vlarge”, “big big xlarge”, “large large huge”, “xlarge xlarge vhuge” or “huge huge xhuge”.

### XML Errors

We will now purposely introduce an error into the file, so that you can experience the effects and the solution, which will hopefully help you fix errors in your own maps, should they occur. Because XML files are very structured in nature, in our case with rooms inside maps and items inside rooms, they are sensitive to errors such as omitted information.

In the example above we have a \<map\> element and a \<room\> element, which in turn contains an \<item\>. The map has a start and an end, signified by \<map name=‘tut04’ style=‘base’\> in this case, and an end, signified by \</map\>. The room likewise has a start and end, as does the item (though the end is signified by putting a slash before the end of the element, as the item doesn’t itself contain anything). If we miss off the closing \</room\> tag, it will cause an error because the computer will find the end of the map (\</map\>) before it finds the end of the room.

Try removing the closing room tag (\</room\>) and run LDL on the map as usual. You will get an error such as the following.

``` 
 Stage 05 ERROR! The XML you supplied is not valid: mismatched tag: line 4, column 3
```

This is saying that on what is now line 4 of the map file, there was an unexpected tag. Line 4 used to be “\</room\>” but now it is “\</map\>”. This means that the computer was expecting something other than “\</map\>” which was, in this case the closing room tag “\</room\>”. The computer complains because it doesn’t make sense structurally to put the marker that says “that’s the end of the entire map” inside one of the rooms\! Naturally you can fix the error by reintroducing the expected \</room\> tag.

A similar thing would have happened if you had changed the \<item\> line, from

``` 
 <item type='info_player_start' pos='c' />
```

to

``` 
 <item type='info_player_start' pos='c'>
```

Now we’ve just got the start of the item tag. What the computer reads next it will assume is meant to be insie the item (which doesn’t make any sense to us of course, as items, like weapons, spawn points or powerups can’t actually contain anything). On reading the \</room\> tag, the computer will realise there is a problem as the thing we’ve effectively tried to put inside the item is the end of the room\! Clearly there has been an error (we know this to be a missing \</item\> or a missing “/” before the end of the \<item\> tag) but the computer doesn’t have the brains to work out what that error is, so it will just tell you about it.

So, if you ever get such errors on your own maps, you now know what they mean. If you want help in fixing them, please mail the AGRIP-discuss list.

## Connecting Rooms

Now to make the map a bit more interesting\! We will create two rooms and link them.

``` 
 <map name='tut05' style='base'>
    <room id='start'>
        <item type='info_player_start' pos='c' />
        <con wall='n' target='other' type='door' />
    </room>
    <room id='other' />
 </map>
```

There are now 2 rooms, “start” and “other”, which are linked by a door. LDL places the room “other” to the north of “start” because we asked the connection to “other” to be made via the north wall (“n”) of “start”. The north wall is the one you face when spawning in the map for the first time; west and east correspond to left and right respectively and south is behind you.

This is the same as the way directions work in most Interactive Fiction games. If it helps, you could imagine being above the map and looking down on it as if it was an, erm, map. Then, north would be to the top, south to the bottom, west to the left and east to the right. (Both ways of imagining the situation are the same - hopefully at least one will be helpful.)

Above we specified the connection inside the room “start”. It works the other way around too, so that was exactly the same as if we had said the following instead.

``` 
 <map name='tut06' style='base'>
    <room id='start'>
        <item type='info_player_start' pos='c' />
    </room>
    <room id='other'>
        <con wall='s' target='start' type='door' />
    </room>
 </map>
```

Run the map through LDL and experiment. The room you start in will lead onto another room, which you will access via a door that is directly in front of you when you start (LDL places doors in the middle of the wall they’re on and at ground level by default - more on this later).

## Items and Monsters

Let’s make the last map a little more interesting. We’ll move the player start point to the south end of the start room, add a shiny weapon for you to pick up and, in the northern room, place a monster for you to use it on.

``` 
 <map name='tut07' style='medieval'>
    <room id='start'>
        <item type='info_player_start' pos='s' />
        <item type='weapon_supernailgun' pos='c' />
        <con wall='n' target='other' type='door' />
    </room>
    <room id='other'>
        <item type='monster_ogre' pos='n' />
    </room>
 </map>
```

As this map is in the medieval style, you may have noticed the door making a different sound when it opened. The texturing and lighting of the level will also be different and more appropriate to the medieval style (meaning that sighted games might like to play your map too).

### Compass Points

Currently the way to specify the location of items within rooms is to use compass points. When you specify the location of an item, it works in a similar way to connections above.

We plan to implement other ways to specify locations soon but, for now, you can specify the following points: “nw” (north-west); “n” (north); “ne” (north-east); “e” (east); “se” (south-east); “sw” (south-west); “w” (west) and “c” (centre).

Currently we don’t provide a mechanism to control at what height within the room that items will be placed; this will be added later.

## Making Deathmatch-Suitable Maps

So far we have made some simple maps that are designed for the single-player version of the game. Single-player maps have one `info_player_start`. Deathmatch maps require many `info_player_deathmatch` spawn points. If you only have one `info_player_deathmatch`, all of the bots and clients will spawn from that one point and keep telefragging each other, causing the level to be over quite quickly\! Let’s make a very simple deathmatch level, suitable for a small number of players. This time, we’ll construct the map step by step before giving the whole XML file that you can copy and paste.

Let’s make our map have one large central room that is surrounded by four smaller rooms, which will contain the spawn points. One of those rooms can also contain an `info_player_start` so we can test the level in single-player mode without being fragged by bots. It’s safe to put both of these on the same spot in your map as only one would ever be used at a given time (the `info_player_start` if we’re in single-player mode, or the `info_player_deathmatch` otherwise).

The basics of the central room may be something like this

``` 
 <room id='central' size='large'>
     <item pos='c' type='weapon_rocketlauncher' />
     <item pos='n' type='item_armorInv' />
     <item pos='s' type='item_armorInv' />
     <item pos='w' type='item_health' />
     <item pos='e' type='item_health' />
 </room>
```

Each surrounding room may be something like this

``` 
 <room id='spawn'>
     <item pos='c' type='info_player_deathmatch' />
 </room>
```

We need to give each of these rooms a unique ID attribute, however, so we may as well name them partly after the compass points, as we’ll be using those to place them around the outside of the central room. So, our side room IDs will be “spawn\_south”, “spawn\_north”, “spawn\_east” and “spawn\_west”. We’ll put our `info_player_start` in the southern one, so it will look more like this:

``` 
 <room id='spawn_south'>
     <item pos='c' type='info_player_start' />
     <item pos='c' type='info_player_deathmatch' />
     <item pos='n' type='item_rockets' />
 </room>
```

Note that we’ve also added some rockets for the player as no ammo was given in the main room above. To make it easy for the player to pick up the rockets, we’ve put them in the north of this room (which is on the way from the centre of this spawn room to the main room, because the main spawn room is to the north of the southern spawn room).

We’ll need to list the connections to the spawn rooms in the main room’s definition. These will be as follows and can be placed anywhere between the opening and closing \<room\> tags for the central room.

``` 
 <con wall='s' target='spawn_south' />
 <con wall='n' target='spawn_north' />
 <con wall='w' target='spawn_west' />
 <con wall='e' target='spawn_east' />
```

We’ve got the basics of a deathmatch map covered, but before we compile it, we need to consider one last thing: the direction the player faces when spawning. We have positioned spawn rooms around a central room. By default the player will spawn facing north. This is fine if they spawn in the southern room because they’d spawn facing the door that leads onto the main room. However, when the player spawns in one of the other side rooms, they will be facing the wrong way. To correct this, we can supply an `angle` attribute for the spawn points.

For example: consider the westerly spawn room. This is positioned to the west of the main room so if someone spawns there they’ll need to move to the east to get out of the spawn room and into the main room. In that case, we can make their life easier by writing the spawn point in the west room as follows.

``` 
 <item pos='c' angle='e' type='info_player_deathmatch' />
```

This ensures that when the player spawns there they’ll be facing east and thus be able to walk straight forward into the main room.

Now we’ve discussed all the parts of the map we need, here is the full version of it, which you can paste in and try for yourself.

``` 
 <map name='tut08' style='medieval'>
    <room id='central' size='large'>
        <con wall='s' target='spawn_south' type='door' />
        <con wall='n' target='spawn_north' type='door' />
        <con wall='w' target='spawn_west' type='door' />
        <con wall='e' target='spawn_east' type='door' />
        <item pos='c' type='weapon_rocketlauncher' />
        <item pos='n' type='item_armorInv' />
        <item pos='s' type='item_armorInv' />
        <item pos='w' type='item_health' />
        <item pos='e' type='item_health' />
    </room>
    <room id='spawn_south'>
        <item pos='c' type='info_player_start' />
        <item pos='c' type='info_player_deathmatch' />
        <item pos='n' type='item_rockets' />
    </room>
    <room id='spawn_north'>
        <item pos='c' type='info_player_deathmatch' angle='s' />
        <item pos='s' type='item_rockets' />
    </room>
    <room id='spawn_west'>
        <item pos='c' type='info_player_deathmatch' angle='e' />
        <item pos='e' type='item_rockets' />
    </room>
    <room id='spawn_east'>
        <item pos='c' type='info_player_deathmatch' angle='w' />
        <item pos='w' type='item_rockets' />
    </room>
 </map>
```

When you run the normal LDL compilation and test scripts on this map, you’ll be in single-player mode and can walk around and test the shape of the map as normal. To play in deathmatch mode, issue the following console commands.

``` 
 deathmatch 1
 kill
```

Hopefully you have now had a pleasant deathmatch experience in your own map\!

### Directional Issues

Up until AudioQuake 0.3.0.1, there was a bug that caused the direction the player faced when spawning to always be labelled as “north”. This has now been alleviated and thus if you upgrade your AudioQuake installation, you will be able to use LDL with it and not have this problem. Maps made with LDL will still work fine on older versionos of AudioQuake, but there may well be some confusion with directions. It is best to at least test your maps on at least version 0.3.0.1 of AudioQuake for this reason.

### Co-Operative Maps

These are similar to deathmatch maps in that you need to include more than one spawn point. However, the spawn points are usually situated together at the “start” of the map and must be of type `info_player_coop` (you can have as many as you like).

Remember, to play a co-op map, set the console variables as follows.

``` 
 deathmatch 0
 coop 1
 map mapname
```

## Connections Reloaded

We’ll now revisit our previous example of two connected rooms. So far we’re able to specify that two rooms are linked by making a connection from one to another, which may be in the form of a door or just a hole in the connecting wall. By default the connection is made in the middle of the wall at floor level.

To make things a bit more exciting, however, you might want to make some rooms have different heights relative to each other. Here’s a quick example.

``` 
 <map name='tut09' style='base'>
    <room id='start'>
        <item pos='c' type='info_player_start' />
        <con type='door' target='other' wall='n' pos='t' elevtype='stairs' />
    </room>
    <room id='other' />
 </map>
```

This is very similar to the example above (*tut05*), however, we have added two attributes to the connection from the room “start” to the room “other”. These are:

  - pos  
    This is the position *on the connecting wall* that you want the hole/door to be created. That is to say: when you specify a position
    
      - “top” (t) in this case - you are specifying the position on that wall where you want the hole to be made, as if you were standing in front of the wall itself.
    
    Valid positions are: “tl” (top left), “t” (top centre), “tr” (top right), “r” (right), “br” (bottom right), “b” (bottom centre - which is the default), “bl” (bottom left) and “c” (centre).

  - elevtype  
    When you specify that the connecting hole/door is to be placed somewhere other than at ground level on the wall, it might be necessary to provide some means for the player to access the hole - i.e. stairs or a plat (lifting platform). You will be warned when this may be necessary, but as it’s a design decision and you may not wish the player to be granted access through this route, you can specify “none” to disable the creation of such a device.

Try running this map - walk straight forward and you will find some stairs. Carry on and you’ll go up into the second room.

If you’d like to try a plat instead of stairs, change the value of the `elevtype` attribute for the connection to “plat” and try the map again.

### Even More Positioning

Try changing the `pos` to “tl” from “t” and you’ll find that you have to move to the left/west to find the stairs up to room “other”.

It is important to note that even when you use the `pos` attribute to change the position on the wall in the “start” room, you still always end up in “other” at the same place - the connection on that side is made in the default place of the middle of the connecting wall, at ground level.

Once you’re happy with this, you might be asking how you can reposition the connector on the target room’s side. The answer is that you can. Let’s take the example above and change it so that both rooms are actually at the same height but the door between them is at the top of the wall. Stairs will be built to get up to and down from the door on both sides.

``` 
 <map name='tut10' style='base'>
    <room id='start'>
        <item pos='c' type='info_player_start' />
        <con type='door' target='other' wall='n' pos='t' elevtype='stairs' />
    </room>
    <room id='other'>
        <con target='start' wall='s' pos='t' elevtype='stairs' />
    </room>
 </map>
```

### Making Connection Corridors

Say you have two rooms, at different heights and you want to make a connection between them, in the form of a corridor with stairs in it. This is an example of how you might go about doing so.

We have two rooms - “start” and “other” as ever. We will position “other” to the north of “start”, also as ever. This time, though, we will place a corridor between the two. The corridor will be not very wide, quite long and quite tall so that it can accommodate the change in height from “start” to “other”.

As the corridor will be connecting “start” and “other” we’ll give it the ID “start2other”. This quickly identifies it as a corridor. Here is the map…

``` 
 <map name='tut11' style='base'>
    <room id='start'>
        <item type='info_player_start' pos='c' />
        <con wall='n' type='door' target='start2other' />
    </room>
    <room id='start2other' size='vsmall small big'>
        <con wall='n' target='other' pos='t' elevtype='stairs' />
    </room>
    <room id='other'>
        <item pos='c' type='weapon_rocketlauncher' />
    </room>
 </map>
```

When you enter this map, you’ll find a door in front of you and then a corridor, which has a set of steps at the end that lead (without a door) into a room with the rocket launcher.

But those steps are very steep and - as you’re using the entirety of start2other as a corridor - it would be much better if those steps filled the whole room rather than just a small part of it. You can make this happen, as follows…

``` 
 <con wall='n' target='other' pos='t' elevtype='stairs' extent='+' />
```

We’ve added an attribute, `extent`, to the connection and given it the size “+”. That should be read as “fill all available space”. Try making this change and running the map - the stairs will take up all of the available space in the corridor but not above the height they’re meant to be).

You can specify sizes (“small”, “med” and so on) in the `extent` attribute, as you can with rooms. You can also mix and match, so saying `extent='+ med'` means “take up all available width, but be only medium-sized in depth”. Bear in mind that if the corridor was going from east to west (or vice-verse) these would be reversed (which is why it’s often easier to just use “+” as the size specifier).

### Vertical Connections to Other Rooms

It is possible for you to position one room entirely on top of or underneath another and link them with connections as discussed earlier, though you’d use “u” (up) and “d” (down) to identify the walls the connections lie on. Currently it is not possible to make elevation devices for these connections (e.g. a plat) but this is under development and will be released soon.

We’re also working on implementing teleporters, so you can move between rooms instantaneously.

## Feedback

This has been a tutorial of the LDL system’s concept release. There is a lot more to do and a lot of feedback to collect on how it is going so far\! If you need more information, please consult <http://www.agrip.org.uk/ldl/> and the AGRIP-discuss mailing list - <http://lists.agrip.org.uk/cgi-bin/mailman/listinfo/agrip-discuss>.

Please, if you can, help Matthew in his research and us in building a great level-editing system for you by providing constructive criticism of the system. Bear in mind the stage we’re at and let us know what direction it should take in future.

Please also feel free to send us your maps (in XML form) - we’d love to play them\!

# Some Golden Rules

  - Always write well-formed XML. This means closing tags and quotes properly, or you will get a “parse error”.

  - Maps must only contain one \<map\> element.

  - Rooms must all have a unique `id` attribute.

  - Connections between rooms are seen as if we’re looking down onto the map, as in Interactive Fiction games. We use compass directions like “e” (east) to say that, when we are in room A and room B is to the east, we must turn to the right.
    
    If a room is on top of, or underneath another room, we use the directions “u” (up) and “d” (down).

  - We place items in rooms according to the same compass direction scheme.

  - When assigning sizes to things like rooms, we may say “large” or, if we want to be more precise, specify the size in each of the 3 dimensions of width, depth and height, separated by spaces - e.g. “medium large medium”. When facing north in a room, its width is the distance from your left to your right; its depth is the distance from back to front and its height is vertical distance between its floor and ceiling.

# Test Maps Included with LDL

The tutorial files (*tut\*.xml* are also provided for your reference.

The test maps (*test\_nn\_\*.xml* files) included with LDL provide some examples on how to use the system. The number in the name indicates which level of the system the map is written for. You will only be interested in level 05 maps because the lower levels rely on absolute coordinates and are there only to allow the higher levels to be simpler (and will not work with the mkmap script).

# The End

This has been a tutorial of the LDL system’s concept release. There is a lot more to do and a lot of feedback to collect on how it is going so far\! If you need more information, please consult <http://www.agrip.org.uk/ldl/> and the AGRIP-discuss mailing list - <http://lists.agrip.org.uk/cgi-bin/mailman/listinfo/agrip-discuss>.

Please, if you can, help Matthew in his research and us in building a great level-editing system for you by providing constructive criticism of the system. Bear in mind the stage we’re at and let us know what direction it should take in future.

Please also feel free to send us your maps (in XML form) - we’d love to play them\!

# Reference Information

## The Style File - Automating Texturing and Lighting

One helpful feature of LDL is that it automates the process of texturing and lighting a map. This often tedious stage involves applying appropriate pictures to the walls of the brushes (solid shapes) in the map and also adding light entities in the right places to create the desired “look”. Though LDL cannot compete with a sighted human on artistic grounds, it goes a long way and provides somewhat atmospheric lighting for sighted players.

The file *style.xml* included with LDL contains information on the textures and lighting. It will be document more fully in the coming releases.

## List of Valid Entities

This list is available on most Quake mapping websites, such as “Quake MAP Specs”.

Please note that most, but not all, entities are supported by the current release of LDL. We will be adding support for the rest quickly as time goes on and according to user demand.

  - air\_bubbles  
    Rising bubbles

  - ambient\_drip  
    Dripping sound

  - ambient\_drone  
    Engine/machinery sound

  - ambient\_comp\_hum  
    Computer background sounds

  - ambient\_flouro\_buzz  
    Flourescent buzzing sound

  - ambient\_light\_buzz  
    Buzzing sound from light

  - ambient\_suck\_wind  
    Wind sound

  - ambient\_swamp1  
    Frogs croaking

  - ambient\_swamp2  
    Slightly different sounding frogs croaking

  - ambient\_thunder  
    Thunder sound

  - event\_lightning  
    Lightning (Used to kill Cthon, shareware boss)

  - func\_door  
    Door

  - func\_door\_secret  
    A door that is triggered to open

  - func\_wall  
    A moving wall?

  - func\_button  
    A button

  - func\_train  
    A platform (moves along a “train”)

  - func\_plat  
    A lift/elevator

  - func\_dm\_only  
    A teleporter that only appears in deathmatch

  - func\_illusionary  
    Creates brush that appears solid, but isn’t.

  - info\_null  
    Used as a placeholder (removes itself)

  - info\_notnull  
    Used as a placeholder (does not remove itself)

  - info\_intermission  
    Cameras positioning for intermission (?)

  - info\_player\_start  
    Main player starting point (only one allowed)

  - info\_player\_deathmatch  
    A deathmatch start (more than one allowed)

  - info\_player\_coop  
    A coop player start (more than one allowed)

  - info\_player\_start2  
    Return point from episode

  - info\_teleport\_destination  
    Gives coords for a teleport destination using a targetname

  - item\_cells  
    Ammo for the Thunderbolt

  - item\_rockets  
    Ammo for Rocket/Grenade Launcher

  - item\_shells  
    Ammo for both Shotgun and SuperShotgun

  - item\_spikes  
    Ammo for Perforator and Super Perforator

  - item\_weapon  
    Generic weapon class

  - item\_health  
    Medkit

  - item\_artifact\_envirosuit  
    Environmental Protection Suit

  - item\_artifact\_super\_damage  
    Quad Damage

  - item\_artifact\_invulnerability  
    Pentagram of Protection

  - item\_artifact\_invisibility  
    Ring of Shadows (Invisibility)

  - item\_armorInv  
    Red armor

  - item\_armor2  
    Yellow armor

  - item\_armor1  
    Green armor

  - item\_key1  
    Silver Key

  - item\_key2  
    Gold Key

  - item\_sigil  
    Sigil (a rune)

  - light  
    A projected light. No visible lightsource.

  - light\_torch\_small\_walltorch  
    Small wall torch (gives off light)

  - light\_flame\_large\_yellow  
    Large yellow fire (gives off light)

  - light\_flame\_small\_yellow  
    Small yellow fire (gives off light)

  - light\_flame\_small\_white  
    Small white fire (gives off light)

  - light\_fluoro  
    Fluorescent light? (Gives off light, humming sound?)

  - light\_fluorospark  
    Fluorescent light? (Gives off light, makes sparking sound)

  - light\_globe  
    Light that appears as a globe sprite

  - monster\_army  
    Grunt

  - monster\_dog  
    Attack dog

  - monster\_ogre  
    Ogre

  - monster\_ogre\_marksman  
    Ogre (synonymous with monster\_ogre)

  - monster\_knight  
    Knight

  - monster\_zombie  
    Zombie

  - monster\_wizard  
    Scragg (Wizard)

  - monster\_demon1  
    Fiend (Demon)

  - monster\_shambler  
    Shambler

  - monster\_boss  
    Cthon (Boss of Shareware Quake)

  - monster\_enforcer  
    Enforcer

  - monster\_hell\_knight  
    Hell Knight

  - monster\_shalrath  
    Shalrath

  - monster\_tarbaby  
    Slime

  - monster\_fish  
    Fish

  - monster\_oldone  
    Shubb-Niggurath (requires a misc\_teleportrain and a info\_intermission)

  - misc\_fireball  
    Small fireball (gives off light, harms player)

  - misc\_explobox  
    Large Nuclear Container

  - misc\_explobox2  
    Small Nuclear Container

  - misc\_teleporttrain  
    Spiked ball needed to telefrag monster\_oldone

  - path\_corner  
    Used to define path of func\_train platforms

  - trap\_spikeshooter  
    Shoots spikes (nails)

  - trap\_shooter  
    Fires nails without needing to be triggered.

  - trigger\_teleport  
    Teleport (all trigger\_ tags are triggered by walkover)

  - trigger\_changelevel  
    Changes to another level

  - trigger\_setskill  
    Changes skill level

  - trigger\_counter  
    Triggers action after it has been triggered count times.

  - trigger\_once  
    Triggers action only once

  - trigger\_multiple  
    Triggers action (can be retriggered)

  - trigger\_onlyregistered  
    Triggers only if game is registered (registered == 1)

  - trigger\_secret  
    Triggers action and awards secret credit.

  - trigger\_monsterjump  
    Causes triggering monster to jump in a direction

  - trigger\_relay  
    Allows delayed/multiple actions from one trigger

  - trigger\_push  
    Pushes a player in a direction (like a windtunnel)

  - trigger\_hurt  
    Hurts whatever touches the trigger

  - weapon\_supershotgun  
    Super Shotgun

  - weapon\_nailgun  
    Perforator

  - weapon\_supernailgun  
    Super Perforator

  - weapon\_grenadelauncher  
    Grenade Launcher

  - weapon\_rocketlauncher  
    Rocket Launcher

  - weapon\_lightning  
    Lightning Gun
