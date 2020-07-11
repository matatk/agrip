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
/* AGRIP Misc Functions */

// CONSTANTS

// for misc...
float SNAP_MISC_NORMYAW_OFFSET = 0;

// for nav...
float SNAP_NAV_STRUCT_WALL = 40;
float SNAP_NAV_STRUCT_SLOPE = 41;
float SNAP_NAV_STRUCT_SLOPE_DOWN = 41.5;
float SNAP_NAV_STRUCT_DOOR = 42;

float SNAP_NAV_DIR_FWD = 1;
float SNAP_NAV_DIR_BCK = 2;
float SNAP_NAV_DIR_LFT = 4;
float SNAP_NAV_DIR_RGT = 8;
float SNAP_NAV_DIR_UP = 16;
float SNAP_NAV_DIR_DN = 32;

float SNAP_NAV_JMP_NRM = 1;
float SNAP_NAV_JMP_RUN = 2;


// PROTOTYPES

// OBJECT UTILITY FUNCTIONS
float   (vector targ_origin)                        snap_misc_ownervisible;
void    (string msg_string)                         snap_misc_m2o;

// PLAYER UTILITY FUNCTIONS
void    ()                                          snap_misc_weaponswitch;
void    ()                                          snap_misc_blockedtest;
void    (float direction)                           snap_misc_blockedtest_propchg;
void    (string msg_string)                         snap_misc_m2m;

// GENERIC UTILITY FUNCTIONS
float   (float init_yaw)                            snap_misc_normalyaw;
void    (vector point, string sprite, float ttl)    snap_misc_showpoint;
float   (vector jump_origin, vector move_dir)       snap_misc_jumptest;

// BOT UTILITY FUNCTIONS
void    ()                                          snap_misc_botspawner;

// TEAM MANAGEMENT UTILITY FUNCTIONS
float   ()                                          CountPlayers; // from kteams
float   (string team)                               CountPlayersTeam;
float   (float notmyteam)                           snap_misc_pickrndteam;
string  (float teamnum)                             snap_misc_nameforteamnum;
float   (string teamname)                           snap_misc_numforteamname;
float   (float teamnum)                             snap_misc_bottomforteamnum;
float   (float teamnum)                             snap_misc_topforteamnum;


// IMPLEMENTATIONS

// OBJECT UTILITY FUNCTIONS
/// \defgroup obj_util Object Utility Functions
/**
    This function is used by ESR and D5k to determine if the
    player that owns it can ``see'' an object.
    PLEASE NOTE that this INCLUDES a check for if the object is
    within the player's FOV (90 degrees).
   
    @param targ_origin  the entity we're trying to assess for visibility.
    @return             true or false
    \ingroup obj_util
*/
float (vector targ_origin) snap_misc_ownervisible =
{
    traceline(self.owner.origin, targ_origin, true, self);

    if( trace_fraction == 1 )
    {
        local float obj_orig_yaw, player_normal_yaw;
        local float min_fov_yaw, max_fov_yaw;
   
        // Get yaw of targ's origin relative to player...
        obj_orig_yaw = vectoyaw(targ_origin - self.owner.origin);
        obj_orig_yaw = snap_misc_normalyaw(obj_orig_yaw);
   
        // Get yaw of player...
        player_normal_yaw = snap_misc_normalyaw(self.owner.angles_y);
   
        // Work out the bounds that will be used to test if the object is within
        // the player's FOV...
       
        // For min...
        min_fov_yaw = player_normal_yaw - 45;
        /*if( min_fov_yaw > 360 )
            min_fov_yaw = min_fov_yaw - 360;
        else if(min_fov_yaw < 0 )
            min_fov_yaw = min_fov_yaw + 360;*/
   
        // For max...
        max_fov_yaw = player_normal_yaw + 45;
        /*if( max_fov_yaw > 360 )
            max_fov_yaw = max_fov_yaw - 360;
        else if(max_fov_yaw < 0 )
            max_fov_yaw = max_fov_yaw + 360;*/
       
        // Is it within our FOV?
        if( min_fov_yaw <= obj_orig_yaw && max_fov_yaw >= obj_orig_yaw )
        {
            return true;
        }
        else
        {
            // Could be that annoying 360 bug...
            obj_orig_yaw = obj_orig_yaw - 360;
            if( min_fov_yaw <= obj_orig_yaw && max_fov_yaw >= obj_orig_yaw )
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
    else
    {
        return false;
    }
};

/**
    Print a message to the owner of self with high importance.
   
    @param msg_string  the message
   
    Is used by all keypress events because they should happen in real time.
    \ingroup obj_util
*/
void (string msg_string) snap_misc_m2o =
{
    if( ! self.owner.agrip_aux.state )
        sprint(self.owner, PRINT_MEDIUM, "!", msg_string);
    else
        sprint(self.owner, PRINT_MEDIUM, msg_string);
};


// PLAYER UTILITY FUNCTIONS
/// \defgroup plr_util Player Utility Functions
/**
    When the player's weapon is changed (by number keys or `/') this
    works out which weapon is now being used and makes a sound to tell
    the player which weapon they've got.
    \ingroup plr_util
*/
void () snap_misc_weaponswitch =
{
    if( self.weapon == IT_AXE )
        snap_misc_m2m("Axe.\n");
    else if( self.weapon == IT_SHOTGUN )
        snap_misc_m2m("Shotgun.\n");
    else if( self.weapon == IT_SUPER_SHOTGUN )
        snap_misc_m2m("Double-Barrelled Shotgun.\n");
    else if (self.weapon == IT_NAILGUN )
        snap_misc_m2m("Nailgun.\n");
    else if (self.weapon == IT_SUPER_NAILGUN )
        snap_misc_m2m("Super Nailgun.\n");
    else if (self.weapon == IT_GRENADE_LAUNCHER )
        snap_misc_m2m("Grenade Launcher.\n");
    else if (self.weapon == IT_ROCKET_LAUNCHER )
        snap_misc_m2m("Rocket Launcher.\n");
    else if (self.weapon == IT_LIGHTNING )
        snap_misc_m2m("Lightning Gun.\n");
};

/**
    Called by PlayerPostThink() every tick.  Detect if the player has
    collided with, or is stuck on, anything in all six drections.
 
    - When we detect that the player is stuck, we set the ``just hit this''
      agrip-aux bitfield property to include the direction we've just hit in.
    - We also set the ``sustained touch'' bitfiled to include the direction.
      The nav object un-sets the ``just hit'' when it has noticed and made a
      wall-hit sound for that direction.
    - The footsteps code is capable of detecting scraping against walls.
    - Please read the agrip-aux.qc code for more information.
    - Because the setting/unsetting of the properties only varies with the
      direction, it is in a separate function that is called by this one.
    \ingroup plr_util
*/
void () snap_misc_blockedtest =
{
    // Get our velocity vectors...
    makevectors(self.angles);

    // Tracebox and store the results in the bitfields.
    // BTW, Ada really loves bitfields _and_ makes them easy to use!

    // agrip_aux properties:
    //  * .ammo_shells  - ``just hit this''
    //  * .ammo_nails   - ``sustained touch''
    //  * .ammo_rockets - count of walls we're touching

    // Forward
    tracebox(self.origin, VEC_HULL_MIN, VEC_HULL_MAX, (self.origin + ( v_forward * 10 ) ), true, self);
    snap_misc_blockedtest_propchg(SNAP_NAV_DIR_FWD);

    // Backwards
    tracebox(self.origin, VEC_HULL_MIN, VEC_HULL_MAX, (self.origin - ( v_forward * 10 ) ), true, self);
    snap_misc_blockedtest_propchg(SNAP_NAV_DIR_BCK);

    // Left
    tracebox(self.origin, VEC_HULL_MIN, VEC_HULL_MAX, (self.origin - ( v_right * 10 ) ), true, self);
    snap_misc_blockedtest_propchg(SNAP_NAV_DIR_LFT);

    // Right
    tracebox(self.origin, VEC_HULL_MIN, VEC_HULL_MAX, (self.origin + ( v_right * 10 ) ), true, self);
    snap_misc_blockedtest_propchg(SNAP_NAV_DIR_RGT);

    // If we're in water...
    // AG_FIXME - clear the up/down flags if we're not in water.
    if( 0 )
    {
        // Up
        tracebox(self.origin, VEC_HULL_MIN, VEC_HULL_MAX, (self.origin + ( v_up * 10 ) ), true, self);
        snap_misc_blockedtest_propchg(SNAP_NAV_DIR_UP);
   
        // Down
        tracebox(self.origin, VEC_HULL_MIN, VEC_HULL_MAX, (self.origin - ( v_up * 10 ) ), true, self);
        snap_misc_blockedtest_propchg(SNAP_NAV_DIR_DN);
    }
};

/*
    This function is called by the one that tests if we are blocked in any
    direction and sets the properties of the agrip_aux object accordingly.
   
    @param direction    the direction we're currently processing
    \ingroup plr_util
*/
void (float direction) snap_misc_blockedtest_propchg =
{
    /*if( direction == SNAP_NAV_DIR_FWD )
    {
        dprint("tracebox fraction: ");
        dprint(ftos(trace_fraction));
        dprint("\n");
    }*/

    // If we're touching a wall in this direction...
    if( trace_fraction == 0 )
    {
        // If the nav object has noticed we've hit the wall, it will have
        // cleared the ``just hit this'' flag and left the ``sustained touch''
        // one set.  We shouldn't set the ``just hit this'' if the other one
        // is still set...
        if( ! (self.agrip_aux.ammo_nails & direction) )
        {
            // Set both the ``just hit this'' and ``sustained hit'' flags...
            self.agrip_aux.ammo_shells = self.agrip_aux.ammo_shells + direction;
            self.agrip_aux.ammo_nails = self.agrip_aux.ammo_nails + direction;

            // Add this wall we're touching to the counter...
            self.agrip_aux.ammo_rockets = self.agrip_aux.ammo_rockets + 1;
        }
    }
    else
    {
        // If either of the flags are set...
        if(     (self.agrip_aux.ammo_nails & direction)
            ||  (self.agrip_aux.ammo_shells & direction) )
        {
            // Clear both flags...
            self.agrip_aux.ammo_shells = self.agrip_aux.ammo_shells - ( self.agrip_aux.ammo_shells & direction );
            self.agrip_aux.ammo_nails = self.agrip_aux.ammo_nails - ( self.agrip_aux.ammo_nails & direction );

            // Decrement the wall-touch counter...
            self.agrip_aux.ammo_rockets = self.agrip_aux.ammo_rockets - 1;
        }
    }
};

/**
    Print a message to the player with high importance.
   
    @param msg_string      the message
   
    Is used by all keypress events because they should happen in real time.
    \ingroup plr_util
*/
void (string msg_string) snap_misc_m2m =
{
    if( ! self.agrip_aux.state )
        sprint(self, PRINT_MEDIUM, "!", msg_string);
    else
        sprint(self, PRINT_MEDIUM, msg_string);
};


// GENERIC UTILITY FUNCTIONS
/// \defgroup gen_util Generic Utility Functions
/**
    This normalises the yaw sent in.
   
    @param init_yaw     the Quake yaw.
    @return             the normalised yaw.
   
    The global variable ``SNAP_MISC_NORMYAW_OFFSET'' set in the function
    ``PutClientInServer'' in client.qc is used as an offset.
    This is because the player could spawn at any angle in a map -- we need
    to make sure that ``North'' is always considered to be the way they are
    facing when they spawn.
    \ingroup gen_util
*/
float (float init_yaw) snap_misc_normalyaw =
{
    local float normal_yaw;

    // Normalise the incoming yaw...
    // There are 3 common situations in Quake 1 maps:
    //  1. Offset is   0
    //  2. Offset is  90
    //  3. Offest is -90

    // Apply our offset...
    // 1, 2 & 3
    normal_yaw = init_yaw - SNAP_MISC_NORMYAW_OFFSET;

    // Correct out-of-range...
    if( normal_yaw <= 0 )
        normal_yaw = normal_yaw + 360;
    else if( normal_yaw > 360 )
        normal_yaw = normal_yaw - 360;

    // Flip-Reverse it, lol...
    normal_yaw = 360 - normal_yaw;
 
    // Some debug info...
    /*dprint("NORMALYAW():\n");
    dprint("init yaw: ");dprint(ftos(init_yaw));dprint("\n");
    dprint("norm yaw: ");dprint(ftos(normal_yaw));dprint("\n");
    dprint("\n");*/

    // Return the normalised yaw...
    return normal_yaw;
};

/**
    _Where's_ the point?
   
    @param point    Where the point is
    @param sprite   The model to use
    @param ttl      How long to show it for
    \ingroup gen_util
*/
void (vector point, string sprite, float ttl) snap_misc_showpoint =
{
    local entity temp_point_ent;
    temp_point_ent = spawn();
    setorigin(temp_point_ent, point);
    setmodel(temp_point_ent, sprite);
    //makestatic(temp_point_ent);
    temp_point_ent.think = SUB_Remove;
    temp_point_ent.nextthink = time + ttl;
};

/**
    We've found a drop -- can the player jump it?
    Routine adapted for bots too.
       
    @param jump_origin  .
    @param move_dir     .
    @return             either SNAP_NAV_JMP_RUN or SNAP_NAV_JMP_NRM
    \ingroup gen_util
*/
float(vector jump_origin, vector move_dir) snap_misc_jumptest =
{
    local float retval;
    local vector jumptestpoint;
    // Not strictly needed but keeps things readable!
   
    // To find out if the player can make a jump.  We need to:
    //  * Look in front of the drop horizontally.
    //  * See if there is a floor to land on within a reasonable distance.
    //  * See if there is space above to provide room for the jump.
    //  * Work out if a running jump is needed.

    // Where's the point we need to test?
    // For a running jump...
    jumptestpoint = jump_origin + move_dir * 240;
    //snap_misc_showpoint(jumptestpoint, "progs/s_light.spr", 3);
   
    // Could we make a running jump?
    traceline(jumptestpoint, jumptestpoint - '0 0 100', true, self);
    //snap_misc_showpoint(trace_endpos, "progs/s_light.spr", 3);
    if( trace_fraction != 1 )
    {
        // We can make the running jump...
        retval = SNAP_NAV_JMP_RUN;
    }

    // Where's the point we need to test?
    // For a normal jump...
    jumptestpoint = jump_origin + move_dir * 110;
    //snap_misc_showpoint(jumptestpoint, "progs/s_bubble.spr", 3);
   
    // Could we make a normal jump?
    traceline(jumptestpoint, jumptestpoint - '0 0 100', true, self);
    //snap_misc_showpoint(trace_endpos, "progs/s_bubble.spr", 3);
    if( trace_fraction != 1 )
    {
        // We can make the normal jump...
        retval = SNAP_NAV_JMP_NRM;
    }

    return retval;
};


// BOT UTILITY FUNCTIONS
/// \defgroup bot_util Bot Utility Functions
/**
    Spawn those bots!

    self.items   is the number of teams to spawn
    self.frags   is the number of players per team
   
    - THIS IS RUN AS AN ENTITY'S .think FUNCTION.
    - As we cannot do this in for (while) loops because there are no arrays,
      we have to explicitly say ``spawn a bot with team 2''.  There is a
      short way to do this; just test if ag_numteams is greater than 0/1/2/3
      and if it is, spawn botsperteam with the currently-being-tested team's
      colours and name (done in a for (while) loop).
    - Also we have to wait before spawning the members on each team so that
      we don't overflow the server.  For this reason, we set up an entity to
      do the actual spawning.
    - Keeps track of how many teams it has spawned with self.state.
      This isn't an exact count of how many teams we've spawned, because
      we need to remove ourself when we get to the end (hence going all
      the way to state 4 even when we only spawn 2 teams).
    - We add players gradually, too.  self.lip keeps track of how many
      we've added for each team.
    \ingroup bot_util
*/
void() snap_misc_botspawner =
{
    local string tteam;
    local float tbot, ttop;

    if( self.state == 0 )
    {
        if( self.items > 0 )  // at least 1 team
        {
            //dprint("spawning team 1...\n");
            if( self.lip < self.frags )
            {
                //dprint("    team 1 member.\n");
                if( teamplay )
                {
                    // in teamplay we must get the right name for the team...
                    tteam = infokey(world, "ag_team1name");
                    tbot = snap_misc_bottomforteamnum(1);
                    ttop = snap_misc_topforteamnum(1);
                    create_bot(tbot, ttop, tteam, false);
                }
                else
                {
                    // in DM we don't need teams...
                    // (we only need this test in team 1 as there is only
                    // one ``team'' of bots as far as we are concerned in DM)
                    tteam = "n/a";
                    create_bot(0, 12, tteam, false);
                }
                self.lip = self.lip + 1;
            }
            else
            {
                self.lip = 0;  // reset for next team
                self.state = 1;
            }
        }
        else
        {
            self.state = 1;
        }
        self.nextthink = time + 1;
    }
    else if( self.state == 1 )
    {
        if( self.items > 1 )  // at least 2 teams
        {
            //dprint("spawning team 2...\n");
            if( self.lip < self.frags )
            {
                //dprint("    team 2 member.\n");
                tteam = infokey(world, "ag_team2name");
                tbot = snap_misc_bottomforteamnum(2);
                ttop = snap_misc_topforteamnum(2);
                create_bot(tbot, ttop, tteam, false);
                self.lip = self.lip + 1;
            }
            else
            {
                self.lip = 0;  // reset for next team
                self.state = 2;
            }
        }
        else
        {
            self.state = 2;
        }
        self.nextthink = time + 1;
    }
    else if( self.state == 2 )
    {
        if( self.items > 2 )  // at least 3 teams
        {
            //dprint("spawning team 3...\n");
            if( self.lip < self.frags )
            {
                //dprint("    team 3 member.\n");
                tteam = infokey(world, "ag_team3name");
                tbot = snap_misc_bottomforteamnum(3);
                ttop = snap_misc_topforteamnum(3);
                create_bot(tbot, ttop, tteam, false);
                self.lip = self.lip + 1;
            }
            else
            {
                self.lip = 0;  // reset for next team
                self.state = 3;
            }
        }
        else
        {
            self.state = 3;
        }
        self.nextthink = time + 1;
    }
    else if( self.state == 3 )
    {
        if( self.items > 3 )  // ooh, four teams!
        {
            //dprint("spawning team 4...\n");
            if( self.lip < self.frags )
            {
                //dprint("    team 4 member.\n");
                tteam = infokey(world, "ag_team4name");
                tbot = snap_misc_bottomforteamnum(4);
                ttop = snap_misc_topforteamnum(4);
                create_bot(tbot, ttop, tteam, false);
                self.lip = self.lip + 1;
            }
            else
            {
                // no need to reset for next team
                self.state = 4;
            }
        }
        else
        {
            self.state = 4;
        }
        self.nextthink = time + 1;
    }
    else
    {
        // Reached state 4 -- remove...
        //dprint("About to remove botspawner...\n");
        remove(self);
    }
}


// TEAM MANAGEMENT UTILITY FUNCTIONS
/// \defgroup team_util Team Management Utility Functions
/***
    \ingroup team_util
*/
float() CountPlayers =
{
    local entity plr;
    local float count;

    plr = find(world, classname, "player");
    while( plr != world )
    {
        if( plr.netname != "" )
            count = count + 1;

        plr = find(plr, classname, "player");
    }

    return count;
}

/***
    \ingroup team_util
*/
float(string team) CountPlayersTeam =
{
    local entity plr;
    local float count;

    plr = find(world, classname, "player");
    while( plr != world )
    {
        if( plr.netname != "" )
        if( infokey(plr, "team") == team )
            count = count + 1;

        plr = find(plr, classname, "player");
    }

    return count;
}

/**
    Returns a float that is the number of a random team.
    If notmyteam is true, it picks from the remaining teams.
    (That MUST be called by a player.)
       
    @param notmyteam    set if player only
    @return             (random team number)
   
    This is used when kicking bots and adding bots (by clients).
    \ingroup team_util
*/
float (float notmyteam) snap_misc_pickrndteam =
{
    local float numteams;
    local float rnd;
    local float okteam;  // allows us to loop if we picked a team
                         // that is same as calling client's team
                         // when they didn't want us to.

    numteams = stof(infokey(world, "ag_numteams"));

    if( notmyteam )
    {
        local float myteam;
        myteam = snap_misc_numforteamname(infokey(self, "team"));
        /*dprint("PRNDT: my team is ");
        dprint(ftos(myteam));
        dprint("\n");*/
    }
   
    okteam = 0;
    while( !okteam )
    {
        rnd = 1 + ( random() * ( numteams - 1 ) );
        rnd = rint(rnd);
        /*dprint("PRNDT: rnd team is ");
        dprint(ftos(rnd));
        dprint("\n");*/

        if( notmyteam )
        {
            if( rnd == myteam )
            {
                //dprint("PRNDT: Not my team!\n");
                okteam = 0;
            }
            else
            {
                //dprint("PRNDT: found a good team.\n");
                okteam = 1;
            }
        }
        else
        {
            //dprint("PRNDT: keep first team num.\n");
            okteam = 1;
        }
    }

    return rnd;
}

/**
    Returns a string that is the name of the given team number.
   
    @param teamnum
    @return string teamname
    \ingroup team_util
*/
string (float teamnum) snap_misc_nameforteamnum =
{
    if( teamnum == 1 )
        return infokey(world, "ag_team1name");
    else if( teamnum == 2 )
        return infokey(world, "ag_team2name");
    else if( teamnum == 3 )
        return infokey(world, "ag_team3name");
    else if( teamnum == 4 )
        return infokey(world, "ag_team4name");
    else
    {
        dprint("ERROR: Invalid team number ", ftos(teamnum), "!\n");
        error("snap_misc_nameforteamnum called with invalid team number!\n");
    }
}

/**
    Returns a float that is the number of the given team name.
    Returns 0 if there was no match.
   
    @param string teamname
    @return float (teamnum or 0)
   
    Can be used for error-checking client has set the right name.
    \ingroup team_util
*/
float (string teamname) snap_misc_numforteamname =
{
    local string s_teamname;
    local float retval;

    // catch passed-in teamname...
    s_teamname = strzone(teamname);

    // compare team...
    if ( s_teamname == infokey(world, "ag_team1name") )
        retval = 1;
    else if ( s_teamname == infokey(world, "ag_team2name") )
        retval = 2;
    else if ( s_teamname == infokey(world, "ag_team3name") )
        retval = 3;
    else if ( s_teamname == infokey(world, "ag_team4name") )
        retval = 4;
    else
        retval = 0;

    // be tidy now
    strunzone(s_teamname);
   
    return retval;
}

/**
    Returns the bottom colour for given team.
   
    @param float teamnum
    @return float (bottom)
    \ingroup team_util
*/
float (float teamnum) snap_misc_bottomforteamnum =
{
    if( teamnum == 1 )
        return 4;
    else if( teamnum == 2 )
        return 13;
    else if( teamnum == 3 )
        return 12;
    else if (teamnum == 4 )
        return 3;
    else
    {
        dprint("ERROR: Invalid team number ", ftos(teamnum), "!\n");
        error("snap_misc_bottomforteamnum called with invalid team number!\n");
    }
}

/**
    Returns the top colour for given team.
   
    @param float teamnum
    @return float (top)
    \ingroup team_util
*/
float (float teamnum) snap_misc_topforteamnum =
{
    if( teamnum == 1 )
        return 0;
    else if( teamnum == 2 )
        return 0;
    else if( teamnum == 3 )
        return 0;
    else if( teamnum == 4 )
        return 0;
    else
    {
        dprint("ERROR: Invalid team number ", ftos(teamnum), "!\n");
        error("snap_misc_bottomforteamnum called with invalid team number!\n");
    }
}

/* $AGRIP-END */
