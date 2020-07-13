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
/* AGRIP Navigation Assistant Object */


// CONSTANTS

// <defined in agrip-misc.qc>


// PROTOTYPES

void() snap_nav_constructor;
void() snap_nav_main;

void() snap_nav_struct_main;
float(float dir, vector v_start, vector v_out, vector v_out_up) snap_nav_struct_detect;
void(float dir, float objtype) snap_nav_struct_soundout;

void() snap_nav_haz_main;
float(float fwd, vector v_start, vector v_dir, float reverse, float snd) snap_nav_haz_detect;

float() snap_nav_z_main;

void() snap_nav_corners_main;
float(vector v_cmid, vector v_coff) snap_nav_corners_check;


// IMPLEMENTATIONS

// OBJECT MANAGEMENT FUNCTIONS

/**
    This is the ``constructor'' of the nav object.  It sets up the device
    with all the user-defined settings and sets it off scanning.
   
    Constructors, unlike other object functions, are run from the
    perspective of the player.
*/
void() snap_nav_constructor =
{
    local entity new_agnav, child_drop;

    // Let there be light!       
    new_agnav = spawn();
       
    // Set up new nav object...
    new_agnav.movetype = MOVETYPE_NONE;
    new_agnav.solid = SOLID_NOT;
       
    /*  Give it the preferences the user specified...
        To save memory, we're using existing (and empty for this entity) fields... */
   
    // Interval (seconds) between uses of the nav object:
    new_agnav.health = 0.5;
   
    // Detection range:
    new_agnav.frags = stof(infokey(self, "agv_nav_detrange"));
    // AG_FIXME: error check on nav detrange?
   
    // Volume throttle for the wall sounds...
    new_agnav.ammo_rockets = stof(infokey(self, "agv_nav_wall_volume_throttle"));
    if( new_agnav.ammo_rockets > 1 || new_agnav.ammo_rockets < 0 )
        new_agnav.ammo_rockets = 1;

    // Volume throttle for the wall-touch sounds...
    new_agnav.ammo_shells = stof(infokey(self, "agv_nav_wall_touch_volume_throttle"));
    if( new_agnav.ammo_shells > 1 || new_agnav.ammo_shells < 0 )
        new_agnav.ammo_shells = 1;

    // Volume throttle for the ledge/drop sounds...
    new_agnav.skin = stof(infokey(self, "agv_nav_haz_volume_throttle"));
    if( new_agnav.skin > 1 || new_agnav.skin < 0 )
        new_agnav.skin = 1;

    // Volume throttle for the corner sounds...
    new_agnav.lip = stof(infokey(self, "agv_nav_corner_volume_throttle"));
    if( new_agnav.lip > 1 || new_agnav.lip < 0 )
        new_agnav.lip = 1;

    // Connect the nav object and player...
    new_agnav.owner = self;
    self.agrip_nav = new_agnav;

    // Set up the child entity that is the drop marker...
    child_drop = spawn();
    child_drop.movetype = MOVETYPE_NONE;
    child_drop.solid = SOLID_NOT;
    setmodel(child_drop, "progs/s_bubble.spr");
    child_drop.classname = "agrip_hazard";
    child_drop.owner = self.agrip_nav;
    self.agrip_nav.aiment = child_drop;
    self.agrip_nav.view_ofs = '0 0 0';

    // Set previous run time for CAOSD...
    new_agnav.wait = time;

    // Tell it there weren't any corners yet...
    self.count = 0;
    self.state = 0;

    // Give it life!
    new_agnav.think = snap_nav_main;
    new_agnav.nextthink = time + 0.1;
};

/**
    Main navigation aid function.  Calls all the other ones.
*/
void() snap_nav_main =
{
    local float z_changed;
   
    // Find walls, slopes and doors...
    snap_nav_struct_main();
   
    // Tell the player if they're moving up/down...
    z_changed = snap_nav_z_main();

    // Find drops, water, slime, lava and jumps...
    // DO NOT detect ledges if we're moving up/down, though!
    if( z_changed != true )
    if( infokey(self.owner, "agv_t_nav_haz_warnings") == "1" )
        snap_nav_haz_main();

    // Find corners, etc...
    snap_nav_corners_main();

    // Finished this scan... when do we do it all again?
    self.nextthink = time + self.health;
};


// WALLS, SLOPES and DOORS DETECTION FUNCTIONS

/**
    Work out the vectors involved in detecting walls, slopes and doors
    around the player and call the functions that do the detection and
    ``sounding'' of such objects.
*/
void() snap_nav_struct_main =
{
    // Declare the vectors to store the various points we are going to test for obstacles
    local vector    v_start,
                    v_nav_fwd, v_nav_fwd_up,
                    v_nav_lft, v_nav_lft_up,
                    v_nav_rgt, v_nav_rgt_up,
                    v_nav_bck, v_nav_bck_up;

    // Store the type of object that was detected in a given direction...
    local float     objtype;
       
    // Get the correct starting point for the vectors...
    // (owner origin not appropriate as it is too high and thus confuses the detection)
    v_start = self.owner.origin - '0 0 20';

    // Calculate the vectors along which we need to `look'...
    // (We need two so that we can try to find SLOPE/slopes.)
    makevectors(self.owner.angles);
    // Forward vectors
    v_nav_fwd = v_start + self.frags * v_forward;
    v_nav_fwd_up = v_nav_fwd + ( 50 * v_up );
    // Left vectors
    v_nav_lft = v_start - self.frags * v_right;
    v_nav_lft_up = v_nav_lft + ( 50 * v_up );
    // Right vectors
    v_nav_rgt = v_start + self.frags * v_right;
    v_nav_rgt_up = v_nav_rgt + ( 50 * v_up );
    // Back vectors
    v_nav_bck = v_start - self.frags * v_forward;
    v_nav_bck_up = v_nav_bck + ( 50 * v_up );

    // Now detect and sound stuff...
  
    // Forward and Back...
    objtype = snap_nav_struct_detect(SNAP_NAV_DIR_FWD, v_start, v_nav_fwd, v_nav_fwd_up);
    snap_nav_struct_soundout(SNAP_NAV_DIR_FWD, objtype);
    //dprint("\nNAV: f = ");dprint(ftos(objtype));
    objtype = snap_nav_struct_detect(SNAP_NAV_DIR_BCK, v_start, v_nav_bck, v_nav_bck_up);
    snap_nav_struct_soundout(SNAP_NAV_DIR_BCK, objtype);
    //dprint("  b = ");dprint(ftos(objtype));

    // Left and Right...   
    objtype = snap_nav_struct_detect(SNAP_NAV_DIR_LFT, v_start, v_nav_lft, v_nav_lft_up);
    snap_nav_struct_soundout(SNAP_NAV_DIR_LFT, objtype);
    //dprint("  l = ");dprint(ftos(objtype));
    objtype = snap_nav_struct_detect(SNAP_NAV_DIR_RGT, v_start, v_nav_rgt, v_nav_rgt_up);
    snap_nav_struct_soundout(SNAP_NAV_DIR_RGT, objtype);
    //dprint("  r = ");dprint(ftos(objtype));dprint("\n");
};

/**
    Do a trace between two vectors and detect the type of obj/surface
    present.  It then returns a value indicating what it found.
       
    @param dir          direction we're scanning in relative to player
    @param v_start      origin of trace
    @param v_out        first vector projected from origin (just horizontal)
    @param v_out_up     2nd vector projected from origin (has upward component)
*/
float(float dir, vector v_start, vector v_out, vector v_out_up) snap_nav_struct_detect =
{
    local float Xout, Xoutup, Yout, Youtup;
    local float tracedown_half_out, tracedown_quarter_out, tracedown_nearplr_out;
    local vector v_test; // used to test if we're on a slope so we don't get stuff wrong.
   
    // calc v_out_up's endpos...
    // Do this trace from higher up than the next one, so that we can detect
    // SLOPE and ramps when they are very close to the player...
    traceline(v_start + '0 0 15', v_out_up, true, self.owner);
    //snap_misc_showpoint(trace_endpos, "progs/s_bubble.spr", 0.5);
    Xoutup = trace_endpos_x;
    Youtup = trace_endpos_y;

    // Did we find a door?
    if( trace_fraction != 1 )
    {
        if( trace_ent.classname == "door" )
        {
            self.volume = 1 - trace_fraction;
            return SNAP_NAV_STRUCT_DOOR;
        }
    }

    // If we already know we're touching a wall, don't do anything...
    // (The reason we waited to do this was so that if it was a door, we'd
    // keep saying it was.)
    if( self.owner.agrip_aux.ammo_nails & dir )
    {
        self.volume = 1 - trace_fraction;
        return SNAP_NAV_STRUCT_WALL;
    }

    // Calculate v_out_'s endpos...
    traceline(v_start, v_out, true, self.owner);
    //snap_misc_showpoint(trace_endpos, "progs/s_bubble.spr", 0.5);
    Xout = trace_endpos_x;
    Yout = trace_endpos_y;

    // Prepare the test for us being on a slope...
    /*v_test = v_out - v_start;
    v_test = normalize(v_test);
    v_test = v_start + 20*v_test - '0 0 5';*/
    // (We do 20*v_test to account for the player being on steps but over a gap.)
    /*local float test;
    test = pointcontents(v_test);
    dprint("pc: ");dprint(ftos(test));
    dprint("  so: ");dprint(vtos(self.owner.origin));
    dprint("  po: ");dprint(vtos(v_test));
    dprint("\n");*/
   
    // Set sound volume (this will be used for slopes and walls, but
    // overriden if the object is a downward slope)...
    self.volume = 1 - trace_fraction;
   
    // Two situations for an up slope:
    // the two x's are not the same OR the two y's are not the same...
    if(     (Xout != Xoutup && Yout == Youtup )
        ||  (Yout != Youtup && Xout == Xoutup ) )
    {
        return SNAP_NAV_STRUCT_SLOPE;   // one endpoint further back.
    }
    else if(    trace_fraction < 0.5
             && Xout == Xoutup && Yout == Youtup )
    {
        // It's a wall and it's within the wall sounding distance...
        return SNAP_NAV_STRUCT_WALL;
    }
    else
    // See if there is a downward slope...
    // We will do this by seeing if the trace_fraction is greater the further
    // away from the player we trace...
    {
        // Do a trace vertically down from (1/2)t_out...
        v_out = v_out - v_start;
        v_out = v_out * 0.5;
        v_out = v_start + v_out;
        traceline(v_out, v_out - '0 0 100', true, self);
        //snap_misc_showpoint(trace_endpos, "progs/s_bubble.spr", 0.5);
        tracedown_half_out = trace_fraction;

        // Do a trace vertically down from (1/4)t_out...
        v_out = v_out - v_start;
        v_out = v_out * 0.5;
        v_out = v_start + v_out;
        traceline(v_out, v_out - '0 0 100', true, self);
        //snap_misc_showpoint(trace_endpos, "progs/s_bubble.spr", 0.5);
        tracedown_quarter_out = trace_fraction;

        // It could be a drop...
        if( trace_fraction == 1 )
            return;

        // Do a trace vertically down from right near the player...
        v_out = normalize(v_out - v_start);
        v_out = v_start + 20*v_out;
        traceline(v_out, v_out - '0 0 100', true, self);
        //snap_misc_showpoint(trace_endpos, "progs/s_bubble.spr", 0.5);
        tracedown_nearplr_out = trace_fraction;

        // It could be a drop...
        if( trace_fraction == 1 )
            return;

        // If there is a downward slope,
        // tracedown_quarter_out will be < tracedown_half_out...
        // (We need some tolerance in there, though.)
       
        // Tolerance...
        // (the tolerance is 5 units)
        if( fabs(tracedown_half_out - tracedown_quarter_out) < 0.05 )
            tracedown_half_out = tracedown_quarter_out;
        if( fabs(tracedown_nearplr_out - tracedown_quarter_out) < 0.05 )
            tracedown_nearplr_out = tracedown_quarter_out;

        // Debug info
        /*if( dir = SNAP_NAV_DIR_FWD )
        {
            dprint("\nSLP: ");
            dprint(ftos(tracedown_nearplr_out));dprint(" ");
            dprint(ftos(tracedown_quarter_out));dprint(" ");
            dprint(ftos(tracedown_half_out));dprint(" ");
            dprint("\n");
        }*/
       
        // Work out if there is a slope...
        if(     (       (tracedown_nearplr_out < tracedown_quarter_out)
                    &&  (tracedown_quarter_out < tracedown_half_out) )
            ||  (       (tracedown_nearplr_out == tracedown_quarter_out)
                    &&  (tracedown_quarter_out < tracedown_half_out) )
            ||  (       (tracedown_nearplr_out < tracedown_quarter_out)
                    &&  (tracedown_quarter_out == tracedown_half_out) ) )
        {
            self.volume = 1 - ( vlen(trace_endpos - v_start) / self.frags );
            return SNAP_NAV_STRUCT_SLOPE_DOWN;
        }
    }
};

/**
    Sound out a detected object/surface.
   
    @param objtype      tells it the type of object that was detected
    @param direction    tells it which direction we're scanning in

    The property that controls the volume of the nav object is ``.ammo_rockets''.
    This operation knows which sounds we are allowed to make in certain
    directions (i.e. only play wall-hit sound behind the player.)
*/
void(float direction, float objtype) snap_nav_struct_soundout =
{
    local float actual_sound_level;

    // Set myself up in the right place to make the sound...
    setorigin(self, trace_endpos);

    // Debug info - front object...
    /*if( direction == SNAP_NAV_DIR_FWD )
    {
        dprint("Object in front is a: ");dprint(ftos(objtype));dprint("\n");
    }*/
   
    // Work out what sound to make...
    if( objtype == SNAP_NAV_STRUCT_WALL )
    {
        // It's a WALL...
        // Do we sound it out?
       
        // Have we just hit it?
        if( self.owner.agrip_aux.ammo_shells & direction )
        {
            // Yes -- make the wall-hit sound and unset the ``just hit this'' flag...
            actual_sound_level = 1;
            safe_soundtoclient(self.owner, self, CHAN_AUTO, "player/land.wav", actual_sound_level, ATTN_NORM);
            self.owner.agrip_aux.ammo_shells = self.owner.agrip_aux.ammo_shells - (self.owner.agrip_aux.ammo_shells & direction);
        }
        // Perhaps we're still touching it after hitting it a while back...
        else if( self.owner.agrip_aux.ammo_nails & direction )
        {
            // Make the wall touch sound?
            if( infokey(self.owner, "agv_t_nav_wall_touch_warnings") == "1" )
            {
                // Apply throttle for wall-touch sounds...
                actual_sound_level = 1 * self.ammo_shells;
                   
                // If the wall is NOT in front us, make it a bit quieter...
                if( direction != SNAP_NAV_DIR_FWD )
                    actual_sound_level = actual_sound_level * 0.5;
           
                // Make the wall-touch sound...
                // AG_FIXME: wall-touch sound
                safe_soundtoclient(self.owner, self, CHAN_AUTO, "misc/menu3.wav", actual_sound_level, ATTN_NORM);
            }
        }
        // OK, well maybe the wall is within our wall detection range...
        else if( trace_fraction < 0.5 )
        {
            // Sound volume should fall off as if the wall detection range was half
            // of what the other nav objects' detection range is...
            actual_sound_level = self.volume * self.ammo_rockets;
     
            // Sound out the wall?
            if(     infokey(self.owner, "agv_t_nav_wall_warnings") == "1"
                &&  direction != SNAP_NAV_DIR_BCK
                &&  (
                          infokey(self.owner, "agv_t_nav_side_wall_warnings") == "1"
                      ||  (    
                                direction != SNAP_NAV_DIR_LFT
                            &&  direction != SNAP_NAV_DIR_RGT
                          )
                    )
              )
                safe_soundtoclient(self.owner, self, CHAN_AUTO, "nav/wall.wav", actual_sound_level, ATTN_NORM);
        }
        // END of WALL sounding stuff.
    }
    else
    {
        // It's a SLOPE or DOOR...
        // Sound volume should fall off in direct proportion to the trace farction...
        // But:     Don't make a sound if we're only detecting what is behind us
        // Note:    ALWAYS detect slopes/doors at our sides, even if side wall
        //          warnings is off!
        if( direction != SNAP_NAV_DIR_BCK )
        {
            // Get sound volume...
            actual_sound_level = self.volume;
            // (The throttle is only for walls.)
           
            // Sound out ramps, SLOPE and doors...
            if( objtype == SNAP_NAV_STRUCT_SLOPE )
            {
                safe_soundtoclient(self.owner, self, CHAN_AUTO, "nav/slope.wav", actual_sound_level, ATTN_NORM);
            }
            else if( objtype == SNAP_NAV_STRUCT_SLOPE_DOWN )
            {
                safe_soundtoclient(self.owner, self, CHAN_AUTO, "nav/slope.wav", actual_sound_level, ATTN_NORM);
            }
            else if( objtype == SNAP_NAV_STRUCT_DOOR )
            {
                safe_soundtoclient(self.owner, self, CHAN_AUTO, "nav/door.wav", actual_sound_level, ATTN_NORM);
            }
        }
    }
};


// DROPS, WATER, SLIME, LAVA and JUMPS DETECTION FUNCTIONS

/**
    Work out the vectors involved in detecting drops, water, slime, lava
    and jumps around the player and call the functions that do the
    detection and ``sounding'' of such objects.
    This also stores the information returned by the detection function
    regarding what's in the drop pit and if the player can jump over the
    hazard in front of them.
   
    The following properties of the D5k are used to store information:
    * self.weapon       - stores the type of pit filling in front of the player.
    * self.takedamage   - stores the jump flag.
*/
void() snap_nav_haz_main =
{
    local vector    v_start;
    local float     haztype;

    // Get the correct starting point for the vectors...
    // (owner origin not appropriate as it is too high and thus confuses the detection)
    v_start = self.owner.origin - '0 0 25';

    // Now detect and sound stuff...
    // (For forward, left, right and back directions.)
   
    // Forward
    // Should the ESR be making the sound?
    if( infokey(self.owner, "agv_t_esr") == "2" )
        haztype = snap_nav_haz_detect(true, v_start, v_forward, false, false);
    else
        haztype = snap_nav_haz_detect(true, v_start, v_forward, false, true);

    // NB: self.aiment (the hazard marker) is only set up if we are detecting
    //     in front of the player.  If there was a hazard, it's origin will now
    //     be set and it will have it's state set to 1.
    //     The following calls do not interfere with this.
   
    // Do the other dirs if we've been told to...
    if( infokey(self.owner, "agv_t_nav_side_haz_warnings") == "1" )
    {
        // Left
        snap_nav_haz_detect(false, v_start, v_right, true, true);
        // Right
        snap_nav_haz_detect(false, v_start, v_right, false, true);
    }

    /** DROP DESCRIPTIONS
        The player can request a description of what is in the pit.
        The detect function above has told us (if the player was close enough to
        the drop).  However, we only want to tell the player about the drop in
        front of them (hence that is the only function we collect a haztype for).
    */
    self.weapon = haztype;
   
    /** JUMP DESCRIPTIONS
        We need to be able to say if the player could make the jump in front of
        them, in a similar way to drop types above.
    */
    if( self.aiment.state == 1 )
        self.takedamage = snap_misc_jumptest(self.aiment.origin, self.aiment.movedir);
    else
        self.takedamage = 0;
};
    
/**
    Detect ledges/drops near the player.  Make a sound based on how large
    the drop is and also work out what is contained within it (i.e. water,
    slime or lava).  The calling function can do whatever it wants with
    this information.  Read on for a detailed description of how this is all
    done.
   
    @param fwd          - are we doing this in the forward direction?
                          (because only in fwd direction do we care about
                          the hazard marker's position)
    @param v_start      - origin of trace
    @param v_dir        - direction vector projected from origin
                          (just horizontal)
    @param reverse      - flag that specifies if the direction vector is to
                          be used in reverse (for left/backwards scanning)
    @param snd          - make a sound?
    @return             - the type of hazard we detected (if any)
                          (used by the calling function to tell the player)
                          this is always negative (a CONTENT_ value)
                            - it returns 255 if there was no valid drop.
                            - it returns 10 if the drop wasn't big enough.
                            - it returns 0 if there was a drop but we aren't
                              close enough to examine the contents of it.
   
    GENERAL NOTES

    - self.skin contains the volume throttle for hazard sounds.
    - self.view_ofs contains the vector to place the hazard locator entity
      at _if_ there is a valid drop.
    - If the drop is not valid, the .state of self.aiment is set to 0.
*/
float(float fwd, vector v_start, vector v_dir, float reverse, float snd) snap_nav_haz_detect =
{
    local vector v_end;
    local float ledge_dist, drop_length, soundout_volume;
    local float retval;

    /** FINDING A POTENTIAL DROP

        We need to search out in front of us for a ledge.
        The hazard detection range is half of the nav detection range.
    */
   
    // Get owner's pointy vectors...
    makevectors(self.owner.angles);
  
    // Start off looking 10 units further away from the player in whatever
    // direction we are scanning for ledges in...
    v_end = v_start;
    ledge_dist = vlen(v_end - v_start);

    // Iteratively work out if there is a drop in front of our intrepid hero...
    while( ledge_dist < ((self.frags / 2) - 10) && pointcontents(v_end) == CONTENT_SOLID )
    {
        ledge_dist = vlen(v_end - v_start);

        // We need this hack becuase QC can't deal with passing in negative
        // numbers as parameters...
        if( ! reverse )
            v_end = v_end + 10 * v_dir;
        else
            v_end = v_end - 10 * v_dir;
    }

   
    /** CHECKING THE POTENTIAL DROP IS VISIBLE

        Check that we've not found a gap that is through the side of a corridor
        (by looking for a wall above it)...
        NB:  This behaviour means that low walls (such as those on bridges) don't
             obscure our sight of drops (wouldn't for sighteds) but we also have
             to be fair and not let AGRIP players know about drops they shouldn't
             be able to see yet.
    */
    traceline(self.owner.origin, (v_end + '0 0 40'), true, self.owner);
    if(    trace_fraction == 1
        // Check we're not under a raised floor such as a bridge, for example...
        && pointcontents(v_end + '0 0 10') != CONTENT_SOLID
      )
    {
        /// CHECKING IT IS A VALID DROP
      
        // Make sure it's not just a small gap (at a plat, for example)...
        traceline(v_end, v_end + 10 * v_dir, true, self.owner);
        /*dprint("test -- tf: ");dprint(ftos(trace_fraction));
        dprint("  as:");dprint(ftos(trace_allsolid));dprint("\n");*/
        if(     ! trace_allsolid
            ||  trace_fraction != 1 )
        {
            /** If it is a valid drop...
       
                There are drops that you would/wouldn't notice and drops that would
                hurt you -- we need to distinguish between them.
   
                - A drop of > 16 units has to be jumped over -- SMALL
                - A drop of > 39 units can't be jumped over -- BIG
                - A drop of > 275 units hurts you -- HUGE
               
                What we need to do:

                -# Trace down from the spot in front of us for, say, 400 units.
                -# See if the trace got interupted...
                     -# If it didn't, the drop is a HUGE drop.
                     -# If it did...
                         -# The end point is either empty, water, slime or lava.
                         -# Work out, based on the vlen from the trace, if the drop is
                            a SMALL, BIG or HUGE drop and sound accordingly.
                -# If the player pressed the ``drop description'' key, tell them
                  what lies in the pit.
            */
   
            // Prepare for Descent...
            traceline(v_end, (v_end - '0 0 800') , true, self.owner);
   
            // How big is the drop?
            drop_length = vlen(trace_endpos - v_end);
  
           
            /// SOUNDING OUT THE DROP
            /// or LETTING THE ESR DO IT
           
            if( snd )
            {
                // Get into the right place...
                setorigin(self, v_end);
               
                /// Work out how loud to make the sound that warns the player of the drop.
                /// The volume is based on how close the player is to the ledge.
               
                // Calculate ledge_dist as a percentage of the detection range...
                soundout_volume = ledge_dist / (self.frags / 2);
                // Invert and throttle down soundout_volume...
                soundout_volume = ( 1 - soundout_volume ) * self.skin;
                //dprint("soundout volume: ");dprint(ftos(soundout_volume));dprint("\n");

                // FIXME: Make it do a different version of each drop height sound if the player is on the edge!
               
                // Classify as SMALL, BIG or HUGE...
                if( drop_length > 275 )
                {
                    safe_soundtoclient(self.owner, self, CHAN_AUTO, "haz/drop-huge.wav", soundout_volume, ATTN_NORM);
                }
                else if( drop_length > 39 )
                {
                    safe_soundtoclient(self.owner, self, CHAN_AUTO, "haz/drop-big.wav", soundout_volume, ATTN_NORM);
                }
                else if( drop_length > 16 )
                {
                    safe_soundtoclient(self.owner, self, CHAN_AUTO, "haz/drop-small.wav", soundout_volume, ATTN_NORM);
                }
            }

            /** RETURNING DROP INFORMATION
           
                What lies beneath? :-)
                Return the contents of the pit, if the player is close enough to it.
                NB:  The calling funtion should sort out whether or not it makes this
                     information available to external objects/code.
            */
            if( drop_length > 16 )
            {
                if( ledge_dist < 150 )
                {
                    // Set to return drop contents...
                    retval = pointcontents(trace_endpos);
                }
                else
                {
                    // Too far away to ``see'' contents...
                    retval = 0;
                }
            }
            else
            {
                // Drop not big enough...
                retval = 10;
            }
        }
        else
        {
            //dprint("HAZ: drop not valid\n");
            retval = 255;
        }
    }
    else
    {
        //dprint("HAZ: not visible\n");
        retval = 255;
    }

    /// If we are returning some kind of success (0 or >0), we should let the
    /// nav object know where to put the hazard marker entity...
    if( fwd)
    if( retval < 20 )
    {
        setorigin( self.aiment, (v_end + '0 0 40') );
        self.aiment.state = 1;
    }
    else
    {
        self.aiment.state = 0;
    }

    return retval;
};


// Z DETECTION FUNCTION

/**
    Keep track of where the player is, Z-wise, and inform them when they
    are going up/down.
   
    The property that stores our owner's previous Z location is self.frame.
*/
float() snap_nav_z_main =
{
    local float z_changed;

    // Assume we have moved since the last time this was run...
    z_changed = true;
   
    /** How this works is that we see what height we were at last time the D5k
        ran and compare it to where we are now...
   
        Note: We have a tolerance of +/- 5 game units to avoid it being too
              verbose about Z changes.
    */

    if( infokey(self.owner, "agv_t_nav_z_warnings") == "1" )
    {
        // Compare previous Z location to current one and make an appropriate
        // sound...
        if( self.owner.origin_z > self.frame + 5 )
        {
            safe_soundtoclient(self.owner, self.owner, CHAN_AUTO, "nav/up.wav", 1, ATTN_NORM);
        }
        else if( self.owner.origin_z < self.frame - 5 )
        {
            safe_soundtoclient(self.owner, self.owner, CHAN_AUTO, "nav/down.wav", 1, ATTN_NORM);
        }
        else
            z_changed = false;

        // Set our owner's current Z location as the ``previous'' one...
        self.frame = self.owner.origin_z;
    }
    else
    {
        // Store our current Z location as ``prev Z location''...
        // (This avoids un-necessary blips at the on/off transitions)
        self.frame = self.owner.origin_z;
    }

    return z_changed;
};


// CORNER FINDING STUFF

/**
    Find corners in front of the player.  It will find left/right corners, and
    is designed with 90-degree angles in mind, but does also work for many of
    the other type of corner found in the game.
*/
void() snap_nav_corners_main =
{
    // Should we be here?
    if(     ! time > self.wait
        ||  ! infokey(self.owner, "agv_t_nav_corner_warnings") == "1" )
        return;

    local float corner_dist, found_left_corner, found_right_corner;
    local float corner_vol, midpoint_vol;
    local vector v_start, v_corner_fwd, v_corner_left, v_corner_right, v_iL, v_iR;
    local float passed_left_corner;
    passed_left_corner = false;

    /** Like searching for drops, we need to search for corners and lock onto them.

      Corners are searched for like this:
      -#  Project forward and out.
      -#  If we can, go left/right for, like, say, 400.
      -#  If we could do that, trace from player to that out-side point.
      -#  If that trace was blocked, there must have been a wall in the way -- corner!
    */
    // It really is as simple as that, people (what am I on?)!

    makevectors(self.owner.angles);
    v_start = self.owner.origin;
    v_corner_fwd = v_start;
    corner_dist = 0;
    found_left_corner = false;
    found_right_corner = false;
   
    // Iteratively work out if there is a gap for a corner in front of Quake guy...
    while(      corner_dist < ( self.frags - 10 )
           &&   (    pointcontents(v_corner_fwd) == CONTENT_EMPTY
                  || pointcontents(v_corner_fwd) == CONTENT_WATER )
         )
    {
        // Find a corner to the left...
        if( ! found_left_corner )
        {
            v_corner_left = v_corner_fwd - (self.frags/2) * v_right;
            found_left_corner = snap_nav_corners_check(v_corner_fwd, v_corner_left);
            v_iL = v_corner_fwd;
        }

        // Find a corner to the right...
        if( ! found_right_corner )
        {
            v_corner_right = v_corner_fwd + (self.frags/2) * v_right;
            found_right_corner = snap_nav_corners_check(v_corner_fwd, v_corner_right);
            v_iR = v_corner_fwd;
        }
   
        // Done, go to the next point...
        v_corner_fwd = v_corner_fwd + 10 * v_forward;
        corner_dist = vlen(v_corner_fwd - v_start);
    }

    /** When finished scanning...

    There are a number of outcomes:
     - No corners found
     - Left corner found
     - Right corner found
     - Both corners found

    The scheme for sounding out is this:
     -# Sound out the middle forward point, followed by the left corner.
     -# Same as above for right corner.
     -# If there was no left and no right corner, just sound out the middle.
    */

    if( found_left_corner )
    {
        // Debug info -- show how far it was...
        //snap_misc_showpoint(v_iL, "progs/s_explod.spr", 1.5);
        //snap_misc_showpoint(v_corner_left, "progs/s_light.spr", 10);
        //dprint("found left corner!  sv = ");

        // Sound it out...

        // Work out corner volume...
        corner_vol = 1 - (vlen(v_iL - self.owner.origin) / self.frags)*self.lip;
        if( corner_vol > 1 )
            corner_vol = 1;
        else if( corner_vol < 0 )
            corner_vol = 0;
        //dprint("left: ");dprint(ftos(corner_vol));dprint("\n");
      
        // Kick off the sounder...
        local entity sounderL;
        sounderL = spawn();
        sounderL.message = "weapons/tink1.wav";
        sounderL.dest1 = v_corner_fwd;
        sounderL.frags = corner_vol;
        sounderL.dest2 = v_corner_left;
        sounderL.health = corner_vol;
        sounderL.owner = self.owner;
        sounderL.think = snap_se_cornersound;
        sounderL.nextthink = time + 0.01;

        // Flag we found the corner...
        // NOT if we have immediately found a new one after losing the old,
        // one, though!
        if( self.count == true && self.pos1 != v_corner_left )
        {
            // Make sure that the distance between the two is big
            // enough to be significant...
            if( vlen(v_corner_left - self.pos1) > 20 )
                self.count = false;
        }
        else
        {
            self.count = true;
            self.pos1 = v_corner_left;
            self.finaldest = v_iL;
            self.dest1 = v_forward;
        }
    }

    if( found_right_corner )
    {
        // Debug info -- show how far it was...
        //snap_misc_showpoint(v_iR, "progs/s_explod.spr", 1.5);
        //snap_misc_showpoint(v_corner_right, "progs/s_light.spr", 10);
        //dprint("found right corner!  sv = ");

        // Sound it out...

        // Work out corner volume...
        corner_vol = 1 - (vlen(v_iR - self.owner.origin) / self.frags)*self.lip;
        if( corner_vol > 1 )
            corner_vol = 1;
        else if( corner_vol < 0 )
            corner_vol = 0;
        //dprint("right: ");dprint(ftos(corner_vol));dprint("\n");
      
        // Kick off the sounder...
        local entity sounderR;
        sounderR = spawn();
        sounderR.message = "weapons/tink1.wav";
        sounderR.dest1 = v_corner_fwd;
        sounderR.frags = corner_vol;
        sounderR.dest2 = v_corner_right;
        sounderR.health = corner_vol;
        sounderR.owner = self.owner;
        sounderR.think = snap_se_cornersound;
        if( found_left_corner )
            sounderR.nextthink = time + 0.5;
        else
            sounderR.nextthink = time + 0.01;

        // Flag we found the corner...
        // NOT if we have immediately found a new one after losing the old,
        // one, though!
        if( self.state == true && self.pos2 != v_corner_right )
        {
            // Make sure that the distance between the two is big
            // enough to be significant...
            if( vlen(v_corner_right - self.pos2) > 20 )
                self.state = false;
        }
        else
        {
            self.state = true;
            self.pos2 = v_corner_right;
            self.finalangle = v_iR;
            self.dest2 = v_forward;
        }
    }
   
    /// JUST PASSED A CORNER INDICATION
    /// May also need to be provided, so this function does that too.

    // Left corners...
    if( self.count != found_left_corner )
    if( self.dest1 == v_forward )
    {
        // Indicate we've just passed a corner on whichever side it was...
        local entity passed_corner_snder;
        local float sound_level;
        sound_level = 1 - (vlen(self.finaldest - self.owner.origin) / self.frags)*self.lip;
        if( sound_level > 0 )
        if( sound_level <= 1 )
        {
            passed_corner_snder = spawn();
            passed_corner_snder.message = "weapons/ric2.wav";
            passed_corner_snder.dest1 = self.finaldest;
            passed_corner_snder.frags = sound_level;
            passed_corner_snder.dest2 = self.pos1;
            passed_corner_snder.health = sound_level;
            passed_corner_snder.owner = self.owner;
            passed_corner_snder.think = snap_se_cornersound;
            passed_corner_snder.nextthink = time + 0.01;
        }
        self.count = false;

        // If we need to tell the player they've gone past a right corner too,
        // we set this flag to make sure the sounds don't occur at the same
        // time as each other (just like the corner sounding above)...
        passed_left_corner = true;
    }

    // Right corners...
    if( self.state != found_right_corner )
    if( self.dest2 == v_forward )
    {
        // Indicate we've just passed a corner on whichever side it was...
        local entity passed_corner_snder;
        local float sound_level;
        sound_level = 1 - (vlen(self.finalangle - self.owner.origin) / self.frags)*self.lip;
        if( sound_level > 0 )
        if( sound_level <= 1 )
        {
            passed_corner_snder = spawn();
            passed_corner_snder.message = "weapons/ric2.wav";
            passed_corner_snder.dest1 = self.finalangle;
            passed_corner_snder.frags = sound_level;
            passed_corner_snder.dest2 = self.pos2;
            passed_corner_snder.health = sound_level;
            passed_corner_snder.owner = self.owner;
            passed_corner_snder.think = snap_se_cornersound;
            if( passed_left_corner )
                passed_corner_snder.nextthink = time + 0.5;
            else
                passed_corner_snder.nextthink = time + 0.01;
        }
        self.state = false;
    }

    // Set prevoius run time...
    if( found_left_corner )
    if( found_right_corner )
        self.wait = time + 1;
    else
        self.wait = time + 0.5;
};

/**
    Find corners - check that a corner point really is one.

    We check that...

    - The corner point can be seen via a direct line-of-sight from the
      mid point.
    - The player could fit into the space detected at the corner point.
    - There is not a big drop under the player at the corner point.
       
    @param v_cmid   the corner point to be examined
    @param v_coff   the v_corner_fwd already found.
    @return         (true/false)
*/
float(vector v_cmid, vector v_coff) snap_nav_corners_check =
{
    local float retval, length;
    local vector v_cornerpoint, v_m2c_dir;

    // Check the mid-point can see the corner point...
    // NOTE:    We specify 1/2 for the trace fraction required so that sharper
    //          turns can be detected.
    traceline(v_cmid, v_coff, true, self);
    length = vlen(trace_endpos - v_cmid);
    v_cornerpoint = trace_endpos;
    if( length > 160 )  // Was (self.frags/4).  Changed to stop scaling affecting it badly.
    {
        // We need to ``move'' this point as it is probably up against a wall.
        // This should give it a _chance_ of passing the test for ``can you fit
        // the player in there?''...

        // Find out the direction the trace was in...
        v_m2c_dir = normalize(v_coff - v_cmid);
        // Subtract this a bit from the trace_endpos...
        v_cornerpoint = v_cornerpoint - 30 * v_m2c_dir;

        // Test if we can see the point from where we are
        // and if the player could fit there.
        traceline(self.owner.origin, v_cornerpoint, true, self);
        if(     trace_fraction != 1
            &&  (    pointcontents(v_cornerpoint + self.owner.mins) == CONTENT_EMPTY
                  || pointcontents(v_cornerpoint + self.owner.mins) == CONTENT_WATER )
            &&  (    pointcontents(v_cornerpoint + self.owner.maxs) == CONTENT_EMPTY
                  || pointcontents(v_cornerpoint + self.owner.maxs) == CONTENT_WATER )
          )
            //&&  trace_ent.classname != "door" )
        {
            // Make sure the player would be on the ground at the corner, or
            // that the drop would be small...
            traceline(v_cornerpoint, v_cornerpoint - '0 0 50', true, self);
            if( trace_fraction != 1 )
            {
                // Also test that the player could physically get there...
                traceline(v_cmid, v_cornerpoint + '0 0 20', true, self);
                if( trace_fraction == 1 )
                {
                    retval = true;
                    //snap_misc_showpoint(v_cornerpoint, "progs/s_explod.spr", 4);
                }
            }
        }
    }
    else
        retval = false;

    return retval;
};

/* $AGRIP-END */
