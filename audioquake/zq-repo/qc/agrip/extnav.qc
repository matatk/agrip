/*  Copyright 2005 Matthew Tylee Atkinson

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
/* AGRIP Extra Navigation functions not depending on the nav object */


// CONSTANTS

// <none>


// PROTOTYPES

void()                              snap_extnav_osd;
float(vector v_start, vector v_off) snap_extnav_osd_check;
void()                              snap_extnav_osd_sound;
void()                              snap_extnav_compass;


// IMPLEMENTATIONS

/**
    Show the player where big open spaces are
    
    * This function is executed as the player.groundentity object.
    * The function must pause at each detected open space.  It does this
      by returning with a nextthink in the future.  The entry point on
      return is governed by the self.frags property.
    * self.health should be set by the caller (in hooks.qc) and is the
      detection range.
*/
void() snap_extnav_osd =
{
    local float do_sound, cycle_time, skipover_time;
    local vector v_start;
    v_start = self.owner.origin - '0 0 20';
    
    // Time for each sounder event...
    cycle_time = 0.5;
    skipover_time = 0;

    // Are we in the middle of a cycle?
    if( self.frags == 0 )
    {
        makevectors(self.owner.angles);
        self.frags = 1;
        self.nextthink = time + skipover_time;
        setmodel(self, "progs/s_explod.spr");
    }
    else if( self.frags == 1 )
    {
        // Left...
        do_sound = snap_extnav_osd_check(v_start, (v_start - self.health * v_right));
        if( do_sound > 0 )
        {
            setorigin(self, trace_endpos);
            snap_extnav_osd_sound();
            self.nextthink = time + cycle_time;
        }
        else
        {
            self.nextthink = time + skipover_time;
        }
        self.frags = 2;
    }
    else if( self.frags == 2 )
    {
        // ``NW''
        do_sound = snap_extnav_osd_check(v_start, (v_start - (self.health/2 * v_right) + (self.health/2 * v_forward)  ) );
        if( do_sound > 0 )
        {
            setorigin(self, trace_endpos);
            snap_extnav_osd_sound();
            self.nextthink = time + cycle_time;
        }
        else
        {
            self.nextthink = time + skipover_time;
        }
        self.frags = 3;
    }
    else if( self.frags == 3 )
    {
        // Forward...
        do_sound = snap_extnav_osd_check(v_start, (v_start + self.health * v_forward));
        if( do_sound > 0 )
        {
            setorigin(self, trace_endpos);
            snap_extnav_osd_sound();
            self.nextthink = time + cycle_time;
        }
        else
        {
            self.nextthink = time + skipover_time;
        }
        self.frags = 4;
    }
    else if( self.frags == 4 )
    {
        // ``NE''
        do_sound = snap_extnav_osd_check(v_start, (v_start + (self.health/2 * v_right) + (self.health/2 * v_forward)  ) );
        if( do_sound > 0 )
        {
            setorigin(self, trace_endpos);
            snap_extnav_osd_sound();
            self.nextthink = time + cycle_time;
        }
        else
        {
            self.nextthink = time + skipover_time;
        }
        self.frags = 5;
    }
    else if( self.frags == 5 )
    {
        // Right...
        do_sound = snap_extnav_osd_check(v_start, (v_start + self.health * v_right));
        if( do_sound > 0 )
        {
            setorigin(self, trace_endpos);
            snap_extnav_osd_sound();
        }
        self.frags = 0;
        // Finished sweep; vanish...
        remove(self);
    }
    else
    {
        // Error!
        local string reentryno;
        reentryno = ftos(self.frags);
        objerror("OSD: space detection given incorrect reentry point of ", reentryno, ".\nPlease report this bug to the developers and quote the\nreentry point specifed above.  Thank you.\n");
    }
};

/**
    Check for free space in a given direction...
    
    @param v_start  the start position
    @param v_off    the left/right/fwd offset
    @return either  true or false
*/
float(vector v_start, vector v_off) snap_extnav_osd_check =
{
    local float retval;
    
    retval = true;
    
    traceline(v_start, v_off, true, self);
    if( trace_fraction != 1 )
        retval = false;

    return retval;
};

/**
    Sound out the free space that has been found...
*/
void() snap_extnav_osd_sound =
{
    //local float sndlev;

    if( self.owner.waterlevel > 1)
    {
        //sndlev = 2 * self.owner.ammo_cells;
        //if( sndlev > 1 )
        //    sndlev = 1;
        safe_soundtoclient(self.owner, self, CHAN_AUTO, "misc/water2.wav", 1, ATTN_NORM);
    }
    else
    {
        safe_soundtoclient(self.owner, self, CHAN_AUTO, "nav/wind.wav", 1, ATTN_NORM);
    }
};

/**
    This works out which way the player is pointing and tells them!
    It uses the snap_misc_normalyaw() function.
    
    The global variable ``SNAP_MISC_NORMYAW_OFFSET'' set in the function
    ``PutClientInServer'' in client.qc is used as an offset.
    This is because the player could spawn at any angle in a map -- we need
    to make sure that ``North'' is always considered to be the way they are
    facing when they spawn.
*/
void () snap_extnav_compass =
{
    local float normal_yaw;
    
    // Get Normalised yaw...
    normal_yaw = snap_misc_normalyaw(self.angles_y);
 
    // Work out what direction we're pointing in... 
    if( normal_yaw >= 337.5 )
        snap_misc_m2m("North North West.\n");
    else if( normal_yaw >= 330 )
        snap_misc_m2m("330 degrees.\n");
    else if( normal_yaw >= 315 )
        snap_misc_m2m("North West.\n"); 
    else if( normal_yaw >= 300 )
        snap_misc_m2m("300 degrees.\n");
    else if( normal_yaw >= 292.5 )
        snap_misc_m2m("West North West.\n");
    else if( normal_yaw >= 270 )
        snap_misc_m2m("West.\n");
    else if( normal_yaw >= 247.5 )
        snap_misc_m2m("West South West.\n");
    else if( normal_yaw >= 240 )
        snap_misc_m2m("240 degrees.\n");
    else if( normal_yaw >= 225 )
        snap_misc_m2m("South West.\n");
    else if( normal_yaw >= 210 )
        snap_misc_m2m("210 degrees.\n");
    else if( normal_yaw >= 202.5 )
        snap_misc_m2m("South South West.\n");
    else if( normal_yaw >= 180 )
        snap_misc_m2m("South.\n");
    else if( normal_yaw >= 157.5 )
        snap_misc_m2m("South South East.\n");
    else if( normal_yaw >= 150 )
        snap_misc_m2m("150 degrees.\n");
    else if( normal_yaw >= 135 )
        snap_misc_m2m("South East.\n");
    else if( normal_yaw >= 120 )
        snap_misc_m2m("120 degrees.\n");
    else if( normal_yaw >= 112.5 )
        snap_misc_m2m("East South East.\n");
    else if( normal_yaw >= 90 )
        snap_misc_m2m("East.\n");
    else if( normal_yaw >= 67.5 )
        snap_misc_m2m("East North East.\n");
    else if( normal_yaw >= 60 )
        snap_misc_m2m("60 degrees.\n");
    else if( normal_yaw >= 45 )
        snap_misc_m2m("North East.\n");
    else if( normal_yaw >= 30 )
        snap_misc_m2m("30 degrees.\n");
    else if( normal_yaw >= 22.5 )
        snap_misc_m2m("North North East.\n");
    else if( normal_yaw >= 0 )
        snap_misc_m2m("North.\n");
};

/* $AGRIP-END */
