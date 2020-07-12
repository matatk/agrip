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
/* AGRIP Waypoint Marker Object */


// PROTOTYPES

void()              snap_marker_constructor;
void(float quiet)   snap_marker_destructor;
void()              snap_marker_touch;


// IMPLEMENTATIONS

/**
    Set up the marker object.

    Like other constructors, this function is run as the player.
        Properties:
            * .classname is set to "agrip_marker".
            * .items is set to the number of the marker.
            * .netname is set to the name of the player whose marker it is.
            * .ammo_shells is the last called time.
            * .ammo_rockets is the time to pause between hits.
        Sound Properties:
            * .frags is the volume.
            * .message is the file to play.
            * .health is the delay time.
*/
void() snap_marker_constructor =
{
    local entity new_agmarker;
    local string marker_number;

    // Limit number of markers...
    if( self.agrip_aux.health > 19 )
    {
        snap_misc_m2m("The Arena Masters are angered at your marker-spammage!\n");
        return;
    }
                                                                                          
    // Set up new marker object's physical properties...
    new_agmarker = spawn();
    new_agmarker.movetype = MOVETYPE_NONE;
    new_agmarker.solid = SOLID_TRIGGER;
    setorigin(new_agmarker, self.origin);
    setmodel(new_agmarker, "progs/s_light.spr");

    // Sound...
    new_agmarker.message = "nav/marker.wav";
    new_agmarker.health = 2;

    // Volume throttle for the sound this object will make...
    new_agmarker.frags = stof(infokey(self, "agv_marker_volume_throttle"));
    if( new_agmarker.frags > 1 || new_agmarker.frags < 0 )
        new_agmarker.frags = 0.3;
  
    // Connect the object and player...
    new_agmarker.owner = self;

    // Work out which number it is to be...
    self.agrip_aux.health = self.agrip_aux.health + 1;
    new_agmarker.items = self.agrip_aux.health;

    // Set up the classname...
    new_agmarker.classname = "agrip_marker";

    // Give it life...
    new_agmarker.ammo_shells = time;
    new_agmarker.ammo_rockets = 2;
    new_agmarker.think = snap_se_loopedsound;
    new_agmarker.touch = snap_marker_touch;
    new_agmarker.nextthink = time + 0.1;

    // Done!
    marker_number = ftos(new_agmarker.items);
    snap_misc_m2m("Marker number ");
    sprint(self, 1, marker_number);
    sprint(self, 1, " created.\n");
};

/**
    Destroy the last created marker.
   
    @return indicates if it deleted a marker.
   
    This is run from the perspective of the player, too.
*/
void(float quiet) snap_marker_destructor =
{
    local float exitflag;
    local entity find_start_ent;
    local entity found_ent;
    local string marker_number;

    // debug info
    /*dprint(self.netname);
    dprint(" md START.  num: ");
    dprint(ftos(self.agrip_aux.health));
    dprint("\n");*/

    if( self.agrip_aux.health == 0 )
    {
        // No markers...
        snap_misc_m2m("No waypoint markers to delete.\n");
        safe_soundtoclient(self, self, CHAN_AUTO, "deny.wav", 1, ATTN_NORM);
    }
    else
    {
        // Markers exist...
        find_start_ent = world;
  
        // Look for this player's last marker and remove it.
        // This could be called by the dietidy() hook, in which case don't spam
        // the player with messages saying each one has been remved.
        while( !exitflag )
        {
            found_ent = find(find_start_ent, classname, "agrip_marker");

            // debug info
            /*dprint(self.netname);
            dprint(" md PREMID.  num: ");
            dprint(ftos(self.agrip_aux.health));
            dprint("  thismkrnum: ");
            dprint(ftos(found_ent.items));
            dprint("  found_ent.owner.netname = ");
            dprint(found_ent.owner.netname);
            dprint("\n");*/
           
            if(    found_ent.owner == self
                && found_ent.items == self.agrip_aux.health )
            {
                // debug info
                /*dprint(self.netname);
                dprint(" md MID.  num: ");
                dprint(ftos(self.agrip_aux.health));
                dprint("  marker.items: ");
                dprint(ftos(found_ent.items));
                dprint("\n");*/

                remove(found_ent);
                if( !quiet )
                {
                    marker_number = ftos(self.agrip_aux.health);
                    snap_misc_m2m("Waypoint marker ");
                    sprint(self, 1, marker_number);
                    sprint(self, 1, " deleted.\n");
                }
                self.agrip_aux.health = self.agrip_aux.health - 1;
                exitflag = true;
            }
            else
            {
                find_start_ent = found_ent;
            }
        }
    }

    // debug info
    /*dprint(self.netname);
    dprint(" md END.  num: ");
    dprint(ftos(self.agrip_aux.health));
    dprint("\n");*/
};

/*
    Tell the user they've found a marker.
*/
void() snap_marker_touch =
{
    local string marker_number;

    if( other == self.owner && time > self.ammo_shells + self.ammo_rockets )
    {
        marker_number = ftos(self.items);
        sprint(other, 1, "!You found marker ", marker_number, ".\n");
        self.ammo_shells = time;
    }
};

/* $AGRIP-END */
