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
/* EtherScan Radar Objet */


// CONSTANTS

float SNAP_ESR_LEVEL_LOWER = -1;
float SNAP_ESR_LEVEL_SAME = 0;
float SNAP_ESR_LEVEL_HIGHER = 1;

float SNAP_ESR_SPECIAL_EXPLOBOX = 10;
float SNAP_ESR_SPECIAL_DROP = 20;

float SNAP_ESR_BEEPTIME_DIVISOR = 1100;
float SNAP_ESR_BEEPTIME_OFFSET = 100;

float SNAP_ESR_NAME_RANGE = 500; /// sighteds can't identify by sight over greater distances than this

float SNAP_ESR_GAP_TIME = 0.2;


// PROTOTYPES

void()                  snap_esr_constructor;
void()                  snap_esr_main;
void()                  snap_esr_classic;
float(float entity_z)   snap_esr_classic_level;
void()                  snap_esr_hazard;


// IMPLEMENTATIONS

/**
    Set up the ESR object.

    - Like other constructors, this function is run as the player.
    - When this is called, the _current_ mode of operation is in the
      agv_t_esr cvar.
*/
void() snap_esr_constructor =
{
    local entity new_agesr;
    local entity s_monster, s_enemy, s_friend;

    new_agesr = spawn();
                                                                                          
    // Set up new esr object...
    new_agesr.movetype = MOVETYPE_NONE;
    new_agesr.solid = SOLID_NOT;
                                                                                          
    /*  Give it the preferences the user specified...
        To save memory, we're using existing (and empty for this entity)
        fields... */
   
    // Volume throttle for the sound this object will make...
    new_agesr.items = stof(infokey(self, "agv_esr_volume_throttle"));
    if( new_agesr.items > 1 || new_agesr.items < 0 )
        new_agesr.items = 1;

    // Level detection tolerance...
    new_agesr.cnt = stof(infokey(self, "agv_esr_ztolerance"));

    // This property stores a flag to say if we found any hazards at all
    // before loosing a lock on one.  It means that we can work out if
    // there never were any hazards (in which case the ESR should just turn off)
    // or if there was one but it was lost (in which case it should revert back
    // to enemy detection)...
    new_agesr.frags = -1;
    // The property is initially set to -1.  When the hazard ESR is started, it
    // looks for hazards.  If it finds one, it sets this to 1.
   
    // Connect the nav object and player...
    new_agesr.owner = self;
    self.agrip_esr = new_agesr;

    // Set up the actual sounder entities...
    // Monster Sounder...
    s_monster = spawn();
    s_monster.movetype = MOVETYPE_NONE;
    s_monster.solid = SOLID_NOT;
    s_monster.frags = self.agrip_esr.items;
    s_monster.think = snap_se_stickysound;
    s_monster.nextthink = 0;
    s_monster.owner = self;
    self.agrip_esr.aiment = s_monster;
    // Enemy (Player/Bot) Sounder...
    s_enemy = spawn();
    s_enemy.movetype = MOVETYPE_NONE;
    s_enemy.solid = SOLID_NOT;
    s_enemy.frags = self.agrip_esr.items;
    s_enemy.think = snap_se_stickysound;
    s_enemy.nextthink = 0;
    s_enemy.owner = self;
    self.agrip_esr.enemy = s_enemy;
    // friend Sounder...
    s_friend = spawn();
    s_friend.movetype = MOVETYPE_NONE;
    s_friend.solid = SOLID_NOT;
    s_friend.frags = self.agrip_esr.items;
    s_friend.think = snap_se_stickysound;
    s_friend.nextthink = 0;
    s_friend.owner = self;
    self.agrip_esr.goalentity = s_friend;

    // Set it going...
    new_agesr.think = snap_esr_main;
    new_agesr.nextthink = time + 0.1;
};

/**
    Work out what mode we're in and execute it.
*/
void() snap_esr_main =
{
    // What mode are we in?
    if( infokey(self.owner, "agv_t_esr") == "1" )
    {
        snap_esr_classic();
    }
    else if( infokey(self.owner, "agv_t_esr") == "2" )
    {
        snap_esr_hazard();
    }
    else //if( infokey(self.owner, "agv_t_esr") == "0" )
    {
        // The user pressed the ESR key again when it was in mode 2...
        // (i.e. They wanted to kill it.)

        // Kill child objects...
        remove(self.aiment);
        remove(self.enemy);
        remove(self.goalentity);
        
        // Destruct the ESR...
        safe_soundtoclient(self.owner, self.owner, CHAN_AUTO, "toggles/off.wav", 1, ATTN_NORM);
        remove(self);
    }
    /*else
    {
        local string mode;
        mode = infokey(self.owner, "agv_t_esr");
        objerror("ESR: ", self.owner.netname, "'s requested ESR mode '", mode, "' is invalid\nPlease report this bug to the developers.  Thank you.\n");
    }*/
};

/**
	Detect enemies and determine what level they are on with respect to
    the player.  Then call the sounder function to produce the sound (the
    sound produced is dependant on if the enemy is within the FOV of the
    ESR, which is customisable by the user).
   
    - This is based on code from example 13.6 of the ``QuakeC Manual 1.0''
      by Ferrara Francesco (frank@aerre.it) and Olivier Montanuy.  I am not
      sure who the original RADAR code was written by, unfortunately; it may
      have come from the Quake-C Patch Archives.  It is Public Domain,
      anyway, so is fully GPL-compatible.
      NOTE: Pretty much everything has now been re-written.

	- Z Tolerance comes from the ESR object's ``.frags'' property.
*/
void() snap_esr_classic =
{
    local entity potential_hit, nearest_m, nearest_e, nearest_f;
    local float mindist, dist, level;
    local float tmptime;
    local string mt, pht; // for comparing teams
   
    // Monster level variables...
    local float mdist, m_same_dist, m_lower_dist, m_higher_dist, pm_lev;
    local entity m_same, m_lower, m_higher;

    // Enemy level variables...
    local float edist, e_same_dist, e_lower_dist, e_higher_dist, pe_lev;
    local entity e_same, e_lower, e_higher;
   
    // Friend level variables...
    local float fdist, f_same_dist, f_lower_dist, f_higher_dist, pf_lev;
    local entity f_same, f_lower, f_higher;

    // Set up variables...
    m_lower_dist = m_higher_dist = m_same_dist = 2000;
    e_lower_dist = e_higher_dist = e_same_dist = 2000;
    f_lower_dist = f_higher_dist = f_same_dist = 2000;

    // Set up entity variables...
    nearest_m = world;
    m_lower = m_higher = m_same = world;
    nearest_e = world;
    e_lower = e_higher = e_same = world;
    nearest_f = world;
    f_lower = f_higher = f_same = world;
 

    // DETECTING POTENTIAL THREATS
   
    // Find nearby entities...
    potential_hit = findradius(self.owner.origin, 1000);

    // Work out which (if any) are the closest threats...
    // NOTE: Threats on all levels are computed, later the one with the highest
    //       priority is chosen.
    while( potential_hit )
    {
        // Don't detect things that shouldn't be detected...
        if( snap_misc_ownervisible(potential_hit.origin) )
        if( potential_hit.health > 1 )
        if( potential_hit != self.owner )
        if( potential_hit != world  )
        if( potential_hit.classname != "worldspwan" )
        if( potential_hit.classname != "door" )
        if( potential_hit.classname != "agrip_marker" )
        {
            // Get distance to the entity...
            dist = vlen(self.owner.origin - potential_hit.origin);

            // Work out if it is a monster, enemy or friend...

            // Monster...
            if( potential_hit.flags & FL_MONSTER )
            {
                //dprint("monster?\n");
                pm_lev = snap_esr_classic_level(potential_hit.origin_z);
                if( pm_lev == SNAP_ESR_LEVEL_SAME && m_same_dist > dist)
                {
                    m_same = potential_hit;
                    m_same_dist = dist;
                }
                else if( pm_lev == SNAP_ESR_LEVEL_HIGHER && m_higher_dist > dist )
                {
                    m_higher = potential_hit;
                    m_higher_dist = dist;
                }
                else if( pm_lev == SNAP_ESR_LEVEL_LOWER && m_lower_dist > dist )
                {
                    m_lower = potential_hit;
                    m_lower_dist = dist;
                }
            }
            // Potential team-mate...
            else if( teamplay )
            {
                // On the same team?
                mt = infokey(self.owner, "team");
                pht = infokey(potential_hit, "team");
                if( mt != "" && mt == pht )
                {
                    pf_lev = snap_esr_classic_level(potential_hit.origin_z);
                    if( pf_lev == SNAP_ESR_LEVEL_SAME && f_same_dist > dist)
                    {
                        f_same = potential_hit;
                        f_same_dist = dist;
                    }
                    else if( pf_lev == SNAP_ESR_LEVEL_HIGHER && f_higher_dist > dist )
                    {
                        f_higher = potential_hit;
                        f_higher_dist = dist;
                    }
                    else if( pf_lev == SNAP_ESR_LEVEL_LOWER && f_lower_dist > dist )
                    {
                        f_lower = potential_hit;
                        f_lower_dist = dist;
                    }
                }
                // Potential enemy...
                else //if( ! potential_hit.flags & FL_MONSTER )
                {
                    //dprint("enemy?\n");
                    pe_lev = snap_esr_classic_level(potential_hit.origin_z);
                    if( pe_lev == SNAP_ESR_LEVEL_SAME && e_same_dist > dist)
                    {
                        e_same = potential_hit;
                        e_same_dist = dist;
                    }
                    else if( pe_lev == SNAP_ESR_LEVEL_HIGHER && e_higher_dist > dist )
                    {
                        e_higher = potential_hit;
                        e_higher_dist = dist;
                    }
                    else if( pe_lev == SNAP_ESR_LEVEL_LOWER && e_lower_dist > dist )
                    {
                        e_lower = potential_hit;
                        e_lower_dist = dist;
                    }
                }
            }
            // No teamplay -- most likely an enemy, then...
            else //if( ! potential_hit.flags & FL_MONSTER )
            {
                pe_lev = snap_esr_classic_level(potential_hit.origin_z);
                if( pe_lev == SNAP_ESR_LEVEL_SAME && e_same_dist > dist)
                {
                    e_same = potential_hit;
                    e_same_dist = dist;
                }
                else if( pe_lev == SNAP_ESR_LEVEL_HIGHER && e_higher_dist > dist )
                {
                    e_higher = potential_hit;
                    e_higher_dist = dist;
                }
                else if( pe_lev == SNAP_ESR_LEVEL_LOWER && e_lower_dist > dist )
                {
                    e_lower = potential_hit;
                    e_lower_dist = dist;
                }
	        }
        }

        // Get the next entity...
        potential_hit = potential_hit.chain;
    }


    // LEVEL PRIORITIES

    // Here the nearest creature is chosen.  Creatures on the same level always
    // take priority over those above or below.  After this, whichever is the
    // closest (above or below the player) is chosen.
   
    // Monster Level Priority...
    //dprint("ESR--monster-scan-------\n");
    if( m_same != world )
    {
        // Same level is the highest priority...
        nearest_m = m_same;
        //dprint("ESR: monster -- same\n");
    }
    else if( m_higher != world )
    {
        if( m_lower != world )
        {
            // Chose based on who's closer...
            if( m_lower_dist < m_higher_dist )
            {
                nearest_m = m_lower;
                //dprint("ESR: monster -- lower [interp]\n");
            }
            else
            {
                nearest_m = m_higher;
                //dprint("ESR: monster -- higher [interp]\n");
            }
        }
        else
        {
            // There is no lower monster so the higher one is chosen...
            nearest_m = m_higher;
            //dprint("ESR: monster -- higher [default]\n");
        }
    }
    else if( m_lower != world )
    {
        // There is no higher monster so the lower one is chosen...
        nearest_m = m_lower;
        //dprint("ESR: monster -- lower [default]\n");
    }

    // Friend Level Priority...
    //dprint("ESR--friend-scan-------\n");
    if( f_same != world )
    {
        // Same level is the highest priority...
        nearest_f = f_same;
        //dprint("ESR: friend -- same\n");
    }
    else if( f_higher != world )
    {
        if( f_lower != world )
        {
            // Chose based on who's closer...
            if( f_lower_dist < f_higher_dist )
            {
                nearest_f = f_lower;
                //dprint("ESR: friend -- lower [interp]\n");
            }
            else
            {
                nearest_f = f_higher;
                //dprint("ESR: friend -- higher [interp]\n");
            }
        }
        else
        {
            // There is no lower friend so the higher one is chosen...
            nearest_f = f_higher;
            //dprint("ESR: friend -- higher [default]\n");
        }
    }
    else if( f_lower != world )
    {
        // There is no higher friend so the lower one is chosen...
        nearest_f = f_lower;
        //dprint("ESR: friend -- lower [default]\n");
    }

    // Enemy Level Priority...
    //dprint("ESR--enemy-scan-------\n");
    if( e_same != world )
    {
        // Same level is the highest priority...
        nearest_e = e_same;
        //dprint("ESR: enemy -- same\n");
    }
    else if( e_higher != world )
    {
        if( e_lower != world )
        {
            // Chose based on who's closer...
            if( e_lower_dist < e_higher_dist )
            {
                nearest_e = e_lower;
                //dprint("ESR: enemy -- lower [interp]\n");
            }
            else
            {
                nearest_e = e_higher;
                //dprint("ESR: enemy -- higher [interp]\n");
            }
        }
        else
        {
            // There is no lower enemy so the higher one is chosen...
            nearest_e = e_higher;
            //dprint("ESR: enemy -- higher [default]\n");
        }
    }
    else if( e_lower != world )
    {
        // There is no higher enemy so the lower one is chosen...
        nearest_e = e_lower;
        //dprint("ESR: enemy -- lower [default]\n");
    }


    // SOUNDING THE CREATURES OUT
   
    // Now make sound based on where potential_hit is in relation to player...

    // Do line-of-sight/beep-on-centre test...
    makevectors(self.owner.angles);
    tracebox(self.owner.origin, VEC_HULL_MIN, VEC_HULL_MAX, self.owner.origin+(v_forward*SNAP_ESR_NAME_RANGE), false, self.owner);
   
    // Monsters...
    if( nearest_m != world )
    {
        if( infokey(self.owner, "agv_t_esr_monster_warnings") == "1" )
        {
            //dprint("sounding monster.\n");
            if( trace_ent == nearest_m )
            {
                // Beep-on-Centre Sounding...
                self.aiment.message = "esr/monster-boc.wav";

                // L-O-S...
                // only print message if we've got a lock
                if( self.aiment.state == false )
                {
                    self.aiment.state = true;
                }
            }
            else  // not in l-o-s
            {
                // Normal Sounding...
                level = snap_esr_classic_level(nearest_m.origin_z);
                mdist = vlen(self.owner.origin - nearest_m.origin);
                if( level == SNAP_ESR_LEVEL_LOWER )
                    self.aiment.message = "esr/monster-lower.wav";
                else if( level == SNAP_ESR_LEVEL_SAME )
                    self.aiment.message = "esr/monster-same.wav";
                else
                    self.aiment.message = "esr/monster-higher.wav";

                // L-O-S...
                // lost a lock (entity still in FOV) or never had one
                // only play lost lock sound if we did lose a lock...
                if( self.aiment.state == true )
                {
                    safe_soundtoclient(self.owner, nearest_m, CHAN_AUTO, "weapons/ric2.wav", 1, ATTN_NORM);
                }
                self.aiment.state = false;
            }
   
            // Prepare to make the sound...
            setorigin(self.aiment, nearest_m.origin);
            tmptime = (mdist + SNAP_ESR_BEEPTIME_OFFSET) / SNAP_ESR_BEEPTIME_DIVISOR;
            if( tmptime < SNAP_ESR_GAP_TIME )
                self.aiment.nextthink = time + SNAP_ESR_GAP_TIME;
            else
                self.aiment.nextthink = time + tmptime;
        }
    }
    else  // no nearest_m
    {
        // L-O-S...
        // lost a lock (entity moved out of FOV) or never had one
        // only play lost lock sound if we did lose a lock...
        if( self.aiment.state == true )
        {
            safe_soundtoclient(self.owner, self.aiment, CHAN_AUTO, "weapons/ric2.wav", 1, ATTN_NORM);
            // Note: have to use ESR sounder as closest approx. of actual
            //       position of the entity we were tracking.
        }
        self.aiment.state = false;
    }

    // Friends...
    if( nearest_f != world )
    {
        if( infokey(self.owner, "agv_t_esr_friend_warnings") == "1" )
        {
            //dprint("sounding friend.\n");
            if( trace_ent == nearest_f )
            {
                // Beep-on-Centre Sounding...
                self.goalentity.message = "esr/friend-boc.wav";

                // L-O-S...
                // only print message if we've got a lock
                if( self.goalentity.state == false )
                {
                    if( infokey(self.owner, "agv_t_esr_names") == "1" )
                    {
                        pht = infokey(nearest_f, "team");
                        sprint(self.owner, PRINT_HIGH, "!", pht, " ", nearest_f.netname, "\n");
                    }
                    self.goalentity.state = true;
                }
            }
            else  // not in l-o-s
            {
                // Normal Sounding...
                level = snap_esr_classic_level(nearest_f.origin_z);
                fdist = vlen(self.owner.origin - nearest_f.origin);
                if( level == SNAP_ESR_LEVEL_LOWER )
                    self.goalentity.message = "esr/friend-lower.wav";
                else if( level == SNAP_ESR_LEVEL_SAME )
                    self.goalentity.message = "esr/friend-same.wav";
                else
                    self.goalentity.message = "esr/friend-higher.wav";

                // L-O-S...
                // lost a lock (entity still in FOV) or never had one
                // only play lost lock sound if we did lose a lock...
                if( self.goalentity.state == true )
                {
                    safe_soundtoclient(self.owner, nearest_f, CHAN_AUTO, "weapons/ric2.wav", 1, ATTN_NORM);
                }
                self.goalentity.state = false;
            }
   
            // Prepare to make the sound...
            setorigin(self.goalentity, nearest_f.origin);
            tmptime = (fdist + SNAP_ESR_BEEPTIME_OFFSET) / SNAP_ESR_BEEPTIME_DIVISOR;
            if( tmptime < SNAP_ESR_GAP_TIME )
                self.goalentity.nextthink = time + SNAP_ESR_GAP_TIME;
            else
                self.goalentity.nextthink = time + tmptime;
        }
    }
    else  // no nearest_f
    {
        // L-O-S...
        // lost a lock (entity moved out of FOV) or never had one
        // only play lost lock sound if we did lose a lock...
        if( self.goalentity.state == true )
        {
            safe_soundtoclient(self.owner, self.goalentity, CHAN_AUTO, "weapons/ric2.wav", 1, ATTN_NORM);
            // Note: have to use ESR sounder as closest approx. of actual
            //       position of the entity we were tracking.
        }
        self.goalentity.state = false;
    }

    // Enemies...
    if( nearest_e != world )
    {
        if( infokey(self.owner, "agv_t_esr_enemy_warnings") == "1" )
        {
            //dprint("sounding enemy.\n");
            if( trace_ent == nearest_e )
            {
                // Beep-on-Centre Sounding...
                self.enemy.message = "esr/enemy-boc.wav";

                // L-O-S...
                // only print message if we've got a lock
                if( self.enemy.state == false )
                {
                    if( infokey(self.owner, "agv_t_esr_names") == "1" )
                    {
                        // If in teamplay, print their team too...
                        if( teamplay )
                        {
                            pht = infokey(nearest_f, "team");
                            sprint(self.owner, PRINT_HIGH, "!", pht, " ", nearest_e.netname, "\n");
                        }
                        else
                        {
                            sprint(self.owner, PRINT_HIGH, "!", nearest_e.netname, "\n");
                        }
                    }
                    self.enemy.state = true;
                }
            }
            else  // not in l-o-s
            {
                // Normal Sounding...
                level = snap_esr_classic_level(nearest_e.origin_z);
                edist = vlen(self.owner.origin - nearest_e.origin);
                if( level == SNAP_ESR_LEVEL_LOWER )
                    self.enemy.message = "esr/enemy-lower.wav";
                else if( level == SNAP_ESR_LEVEL_SAME )
                    self.enemy.message = "esr/enemy-same.wav";
                else
                    self.enemy.message = "esr/enemy-higher.wav";

                // L-O-S...
                // lost a lock (entity still in FOV) or never had one
                // only play lost lock sound if we did lose a lock...
                if( self.enemy.state == true )
                {
                    safe_soundtoclient(self.owner, nearest_e, CHAN_AUTO, "weapons/ric2.wav", 1, ATTN_NORM);
                }
                self.enemy.state = false;
            }
           
            // Prepare to make the sound...
            setorigin(self.enemy, nearest_e.origin);
            tmptime = (edist + SNAP_ESR_BEEPTIME_OFFSET) / SNAP_ESR_BEEPTIME_DIVISOR;
            if( tmptime < SNAP_ESR_GAP_TIME )
                self.enemy.nextthink = time + SNAP_ESR_GAP_TIME;
            else
                self.enemy.nextthink = time + tmptime;
        }
    }
    else  // no nearest_e
    {
        // lost a lock (entity moved out of FOV) or never had one
        // only play lost lock sound if we did lose a lock...
        if( self.enemy.state == true )
        {
            safe_soundtoclient(self.owner, self.enemy, CHAN_AUTO, "weapons/ric2.wav", 1, ATTN_NORM);
            // Note: have to use ESR sounder as closest approx. of actual
            //       position of the entity we were tracking.
        }
        self.enemy.state = false;
    }
  
    // Finished ESR scan...
    self.nextthink = time + SNAP_ESR_GAP_TIME + 0.1;
};

/**
    Work out what level an ESR target is on compared to the player.
   
    @param entity_z the entity's origin's Z component
    @return the entity is on relative to the player.
*/
float(float entity_z) snap_esr_classic_level =
{
    // potential_hit is higher than player Z + tolerance...
    if( entity_z > ( self.owner.origin_z + self.cnt ) )
        return SNAP_ESR_LEVEL_HIGHER;
    // potential_hit is on a similar level
    // (within +/-TOLERANCE of player)...
    else if( entity_z > ( self.owner.origin_z - self.cnt ) )
        return SNAP_ESR_LEVEL_SAME;
    // Must be lower (than player Z - tolerance), then...
    else
        return SNAP_ESR_LEVEL_LOWER;
};

/**
    In hazard mode, the ESR detects drops in a similar way that it detects
    enemies in classic mode.  The purpose is to allow the player to make
    running jumps to ensure that they get across drops detected by the nav
    object.
   
    - This is based on the classic ESR function above.

    - It will only sound out hazards in front of the player
      (because the nav object will only put pointer entities in front of the player).
*/
void() snap_esr_hazard =
{
    local float dist_to_hazard;
    local entity local_hazard, find_start_ent;
    local float exitflag, foundflag;
   
    // Find nearby hazard entities...
    exitflag = false;
    foundflag = false;
    find_start_ent = world;

    while( ! exitflag )
    {
        local_hazard = find(find_start_ent, classname, "agrip_hazard");

        // Check hazard is owned by the right player...
        if( local_hazard.owner == self.owner.agrip_nav )
        {
            foundflag = true;
            exitflag = true;
        }
        else if( local_hazard == world )
        {
            // Exhausted search...
            exitflag = true;
        }
   
        find_start_ent = local_hazard;
    }
   
    // Now work out if we got a lock...
    if( foundflag )
    {
        if( self.frags == -1 ) // Tells us we've never had a lock.
        {
            snap_misc_m2o("ESR: Set to mode 2.\n");
            safe_soundtoclient(self.owner, self.owner, CHAN_AUTO, "toggles/mode.wav", 1, ATTN_NORM);
            self.frags = 1;
        }
        safe_soundtoclient(self.owner, local_hazard, CHAN_AUTO, "esr/haz.wav", self.items, ATTN_NORM);
        dist_to_hazard = vlen(local_hazard.origin - self.owner.origin);
        self.nextthink = time + ( (dist_to_hazard - 20) / SNAP_ESR_BEEPTIME_DIVISOR );
        //dprint(ftos(self.nextthink - time));
        //dprint("\n");
        if( self.nextthink < time + 0.1 )
            self.nextthink = time + 0.1;
    }
    else
    {
        // Have we _lost_ a lock or did we never _have_ one?
        if( self.frags == -1 )
        {
            // Never had one...
            snap_misc_m2o("ESR: Disabled (no hazard in front).\n");  
            stuffcmd(self.owner, "setinfo agv_t_esr 0\n");
            self.nextthink = time + 0.1;
        }
        else
        {
            // Lost it.
            // We must reset self.frags as this hazard deteciton session is over...
            self.frags = -1;
            snap_misc_m2o("ESR: Lost hazard lock - reverting to mode 1.\n");
            safe_soundtoclient(self.owner, self.owner, CHAN_AUTO, "toggles/mode.wav", 1, ATTN_NORM);
            stuffcmd(self.owner, "setinfo agv_t_esr 1\n");
            self.nextthink = time + 0.1;
        }
    }
};

/* $AGRIP-END */
