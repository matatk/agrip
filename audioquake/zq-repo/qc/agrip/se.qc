/*  Copyright 2004 Matthew Tylee Atkinson

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

/* $AGRIP-START */
/* AGRIP Sound Entities */

/**\file
// NOTES
// 
// All functions here, unless specifed by ``_public'' at the end of their names,
// are intended to work with the safe_soundtoclient() builtin and provide private
// sound messaging to their owner in-game.
*/

// PROTOTYPES

void()  snap_se_singlesound;
void()  snap_se_stickysound;
void()  snap_se_cornersound;
void()  snap_se_loopedsound;
void()  snap_se_loopedsound_public;


// IMPLEMENTATIONS

/**
    Facilitates us making delayed sounds.
    
    Is spawned at the right position and given the apprpriate
    nextthink time.
    Removes itself when done.
*/
void() snap_se_singlesound =
{
    safe_soundtoclient(self.owner, self, CHAN_AUTO, self.message, self.frags, ATTN_NORM);
    remove(self);
};

/**
    Facilitates us making delayed sounds.
    But doesn't kill itself.
    
    + An entity should be spawned at the right position and given the
      apprpriate nextthink time.
    + This is the object's .think function.
    + To avoid eating bandwidth, you should not call this more than twice
      per second.
*/
void() snap_se_stickysound =
{
    safe_soundtoclient(self.owner, self, CHAN_AUTO, self.message, self.frags, ATTN_NORM);
};

/**
    Facilitates us making delayed corner sounds.
    
    * The following properties are used:
        + self.dest1    - vector to far mid point.
        + self.dest2    - vector to corner point.
        + self.frags    - volume of far mid point's sound.
        + self.health   - volume of corner point's sound.
     This entity removes itself when completed.
*/
void() snap_se_cornersound =
{
    // Check if we've made the first sound yet or not...
    if( ! self.items )
    {
        // No, we haven't...
        setorigin(self, self.dest1);
        safe_soundtoclient(self.owner, self, CHAN_AUTO, self.message, self.frags, ATTN_NORM);
        self.nextthink = time + 0.2;
        self.items = true;
    }
    else
    {
        // Yes, we have; do the corner sound now...
        setorigin(self, self.dest2);
        safe_soundtoclient(self.owner, self, CHAN_AUTO, self.message, self.health, ATTN_NORM);
        remove(self);
    }
};

/**
    Make a looped sound (not ambient, as we might want to delete it
    at some point later on).
*/
void() snap_se_loopedsound =
{
    safe_soundtoclient(self.owner, self, CHAN_AUTO, self.message, self.frags, ATTN_NORM);
    self.nextthink = time + self.health;
};

/*
    Make a looped sound (not ambient, as we might want to delete it
    at some point later on).
*/
void() snap_se_loopedsound_public =
{
    // for debugging...
    if( self.frags < 0 )
        error("PLEASE REPORT THIS BUG TO THE DEVELOPERS INCLUDING ALL TEXT MESSAGES!\n");
    else if( self.frags > 1 )
        error("PLEASE REPORT THIS BUG TO THE DEVELOPERS INCLUDING ALL TEXT MESSAGES!\n");

    sound(self, CHAN_AUTO, self.message, self.frags, ATTN_NORM);
    self.nextthink = time + self.health;
};

/* $AGRIP-END */
