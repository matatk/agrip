/*  Copyright 2004-2005 Matthew Tylee Atkinson

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
/* AGRIP Detector 5000 Object */


// PROTOTYPES

void() snap_d5k_constructor;
void() snap_d5k_starter;
void() snap_d5k_main;


// IMPLEMENTATIONS

/**
    This function sets up the detector object.

    As with the other constructors, this function is run from the
    perspective of the player.
*/
void() snap_d5k_constructor =
{
    local entity new_agd5k;
                                                                                           
    new_agd5k = spawn();
                                                                                           
    // Set up new nav object...
    new_agd5k.movetype = MOVETYPE_NONE;
    new_agd5k.solid = SOLID_NOT;
                                                                                           
    /*  Give it the preferences the user specified...
        To save memory, we're using existing (and empty for this entity) fields... */
    
    // Interval (seconds) between uses of the nav object...
    new_agd5k.health = stof(infokey(self, "agv_d5k_interval"));
    
    // Detection range...
    new_agd5k.frags = stof(infokey(self, "agv_d5k_objdist"));
    
    // Volume throttle for the sound this object will make...
    new_agd5k.items = stof(infokey(self, "agv_d5k_volume_throttle"));
    if( new_agd5k.items > 1 || new_agd5k.items < 0 )
        new_agd5k.items = 1;

    // Connect the nav object and player...
    new_agd5k.owner = self;
    self.agrip_d5k = new_agd5k;
                                                                                           
    // Give it life!
    new_agd5k.think = snap_d5k_main;
    new_agd5k.nextthink = time + 0.1;
};

/**
    This function acquires the entity chain and sets going one scan of the d5k.

    When the entity chain has been created, the D5k's ``.think'' function is set
    to snap_d5k_main() so that it can sound out the appropriate entities found.
*/
void() snap_d5k_starter =
{
    // Search for entities near to player...
    self.goalentity = findradius(self.owner.origin, self.frags);

    self.think = snap_d5k_main;
    self.nextthink = time + 0.1;

    //dprint("-------------------------\n");
};

/**
    Detect nearby objects and make sounds to identify them based on object
    type and distance from player.
    
    The function snap_d5k_starter() is called when the entity chain is empty,
    to repopulate it.  This is done by changing the ``.think'' enity of the D5k
    to snap_d5k_starter().

    The entities are processed one after the other, as they are all chained
    together.  The volume of the sound is calculated, then a sound is made at
    the appropriate position, with the appropriate sound to signify the type
    of entity found.
*/
void() snap_d5k_main =
{
    local float sound_vol, matched;
    local vector switch_origin;

    matched = false;

    if(self.goalentity)
    {
        if( self.goalentity.classname != "func_button" )
        {
            // Work out what volume of sound we are going 
            sound_vol = vlen(self.goalentity.origin - self.owner.origin) / self.frags;
            sound_vol = ( 1 - sound_vol ) * self.items;
            
            //snap_misc_showpoint(self.goalentity.origin, "progs/s_light.spr", 3);
        }
        else
        {
            /* Must work out its origin first...
            switch_origin_x = ( self.goalentity.maxs_x + self.goalentity.mins_x ) / 2;
            switch_origin_y = ( self.goalentity.maxs_y + self.goalentity.mins_y ) / 2;
            switch_origin_z = ( self.goalentity.maxs_z + self.goalentity.mins_z ) / 2;*/

            switch_origin = self.goalentity.mins - '0 0 1';
            if( pointcontents(switch_origin) != CONTENT_EMPTY )
                    switch_origin = self.goalentity.maxs + '0 0 1';
            
            // Work out what volume of sound we are going 
            sound_vol = vlen(switch_origin - self.owner.origin) / self.frags;
            sound_vol = ( 1 - sound_vol ) * self.items;

            //snap_misc_showpoint(switch_origin, "progs/s_light.spr", 3);
        }
        
        // If we have moved away from the item since the scan and it is
        // now out of detection range, sound_vol would be -ve.
        // Also, we shouldn't sound things that would be too quiet to hear.
        if( sound_vol > 0.2 )
        {
            // Make sound based on classname...
    
    	    // ARMOR...
    	    if( (  self.goalentity.classname == "item_armor1"
    	        || self.goalentity.classname == "item_armor2"
    	        || self.goalentity.classname == "item_armorInv" )
    	        && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
                safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "items/armor1.wav", sound_vol, ATTN_NORM);
            }
    	    // HEALTH...
            else if( self.goalentity.classname == "item_health" 
    	          && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
    		    safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "items/health1.wav", sound_vol, ATTN_NORM);
            }
            // AMMO...
    	    else if( (  self.goalentity.classname == "item_shells"
    	             || self.goalentity.classname == "item_spikes"
    	             || self.goalentity.classname == "item_rockets"
    	             || self.goalentity.classname == "item_cells" )
    	             && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
    	        safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "weapons/lock4.wav", sound_vol, ATTN_NORM);
            }
            // DROPPED BACKPACK...
            else if( self.goalentity.classname == "" 
                  && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
    	        safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "d5k/backpack.wav", sound_vol, ATTN_NORM);
            }
            // SWITCH...
            // Note: Assume state = STATE_TOP if it isn't STATE_BOTTOM.
            else if( self.goalentity.classname == "func_button" 
                  && snap_misc_ownervisible(switch_origin) )
            {
                matched = true;

                if( self.goalentity.state == STATE_BOTTOM )
                {
    		        safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "buttons/switch04.wav", sound_vol, ATTN_NORM);
                }
                else if( self.skin )
                {
    		        safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "buttons/switch04.wav", sound_vol, ATTN_NORM);
                }
            }
            // POWERUP (EnvSuit, Pentogram, RoS, Quad)...
    	    else if( self.goalentity.classname == "item_artifact_envirosuit" 
    		      && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
    	        safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "items/suit.wav", sound_vol, ATTN_NORM);
            }
            else if( self.goalentity.classname == "item_artifact_invulnerability" 
    		      && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
    	        safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "items/protect.wav", sound_vol, ATTN_NORM);
            }
            else if( self.goalentity.classname == "item_artifact_invisibility" 
    		      && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
    	    	safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "items/inv1.wav", sound_vol, ATTN_NORM);
            }
            else if( self.goalentity.classname == "item_artifact_super_damage" 
    		      && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
    	        safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "items/damage3.wav", sound_vol, ATTN_NORM);
            }
            // KEY...
    	    else if( (  self.goalentity.classname == "item_key1"
    		         || self.goalentity.classname == "item_key2" )
    		         && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
    	        // AG_FIXME: sound change needed for key
    		    safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "misc/talk.wav", sound_vol, ATTN_NORM);
            }
            // WEAPON...
            else if( (  self.goalentity.classname == "weapon_nailgun"
    		         || self.goalentity.classname == "weapon_supernailgun"
    	             || self.goalentity.classname == "weapon_supershotgun"
    		         || self.goalentity.classname == "weapon_rocketlauncher"
    		         || self.goalentity.classname == "weapon_grenadelauncher"
    		         || self.goalentity.classname == "weapon_lightning" )
    		         && snap_misc_ownervisible(self.goalentity.origin) )
            {
                matched = true;
    		    safe_soundtoclient(self.owner, self.goalentity, CHAN_ITEM, "weapons/pkup.wav", sound_vol, ATTN_NORM);
            }
        }

        if( matched )
        {
            self.nextthink = time + 0.5;
            // Debug.info
            /*dprint("CT: ");dprint(ftos(time));
            dprint(" NT: ");dprint(ftos(self.nextthink));
            dprint(" SV: ");dprint(ftos(sound_vol));
            dprint(" GE: ");dprint(self.goalentity.classname);
            dprint(" GEO: ");dprint(vtos(self.goalentity.origin));
            dprint(" M: ");dprint(ftos(matched));
            dprint("\n");*/
        }
        else
        {
            self.nextthink = time + 0.01;
        }

	    // Go to next entity in chain retunred by findradius()...
	    self.goalentity = self.goalentity.chain;
    }
    else
    {
        // Finished this scan... when do we do it all again?
        self.think = snap_d5k_starter;
        self.nextthink = time + self.health;
    }
};

/* $AGRIP-END */
