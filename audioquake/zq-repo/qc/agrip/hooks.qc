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
/* AGRIP Normal QuakeC Hook Functions */

/*\file
// NOTES
//
// These are called from the main QuakeC code.  They're separated out like this
// so as to keep the footprint on the main code as small as possible.
// 
// The functions are named using the following convention:
//
//      agh_<qc-file-name>_<function-name>
//
// This allows us to know:
//
//      * The function is a hook.
//      * The main QC file that the function is in.
//      * An at-a-glance description of what the function does.
//
*/


// PROTOTYPES

void() agh_world_checkstringext;
void() agh_world_precaches;
void() agh_world_padclients;
void() agh_client_startdevs;
void() agh_client_padclients_connect;
void() agh_client_padclients_disconnect;
void() agh_player_footsteps;
void() agh_player_dietidy;
void() agh_weapons_impulsecommands;


// IMPLEMENTATIONS

/**
    This makes sure we're running on a server with at least a half-sane
    QC VM on it :-)
*/
void() agh_world_checkstringext =
{
    // Check for string-handling magic from Frik and added by Tonik
    if( !cvar("pr_checkextension") )
        error("Can't check for required extension: ZQ_QC_STRINGS (no checkextension function)!\n");
    if( !checkextension("ZQ_QC_STRINGS") )
        error("Required extension ZQ_QC_STRINGS not present!\n");
}

/**
    Provide all of the precaches for an accessible game.
    
    A hook can be enabled in agrip_defs.qc to allow mods to
    do some precaching for themselves.
*/
void() agh_world_precaches =
{
    // Stuff to re-factor:
    precache_model("progs/s_light.spr");
    precache_sound("weapons/ric1.wav");
    precache_sound("player/land.wav");
    precache_sound("weapons/tink1.wav");

    // Welcome message
    precache_sound ("welcome.wav");

    // End of Level
    precache_sound ("endlevel.wav");

    // Drop Sounds
    precache_sound ("haz/drop-huge.wav");
    precache_sound ("haz/drop-big.wav");
    precache_sound ("haz/drop-small.wav");

    // EtherScan RADAR
    precache_sound ("esr/monster-higher.wav");
    precache_sound ("esr/monster-same.wav");
    precache_sound ("esr/monster-boc.wav");
    precache_sound ("esr/monster-lower.wav");
    precache_sound ("esr/enemy-higher.wav");
    precache_sound ("esr/enemy-same.wav");
    precache_sound ("esr/enemy-boc.wav");
    precache_sound ("esr/enemy-lower.wav");
    precache_sound ("esr/friend-higher.wav");
    precache_sound ("esr/friend-same.wav");
    precache_sound ("esr/friend-boc.wav");
    precache_sound ("esr/friend-lower.wav");
    precache_sound ("esr/haz.wav");

    // Navigation
    precache_sound ("nav/slope.wav");
    precache_sound ("nav/wall.wav");
    precache_sound ("nav/wall-scrape.wav");
    precache_sound ("nav/door.wav");
    precache_sound ("misc/menu3.wav");      // Need replacement wall-touch
    precache_sound ("nav/wind.wav");        // del?
    precache_sound ("ambience/windfly.wav");
    precache_sound ("misc/water2.wav");     // For the open space detection
    precache_sound ("nav/up.wav");
    precache_sound ("nav/down.wav");

    // Marker
    precache_sound ("nav/marker.wav");

    // Footsteps
    precache_sound ("footsteps/footstep_l.wav");
    precache_sound ("footsteps/footstep_r.wav");

    // D5K Entity Beeps
    precache_sound ("buttons/switch04.wav");        // Switch - AG_FIXME
    precache_sound ("doors/airdoor2.wav");          // Door - AG_FIXME
    precache_sound ("d5k/backpack.wav");
    precache_sound ("d5k/outside-fov.wav");

    // Toggles
    precache_sound ("toggles/on.wav");
    precache_sound ("toggles/off.wav");
    precache_sound ("toggles/mode.wav");

    // Ammo Out
    precache_sound ("ammo-out.wav");

    // Deny
    precache_sound ("deny.wav");

    /** mod hook stuff!!!! */
#ifdef AGRIP_MODHOOK_PRECACHE
    agrip_modhook_precache();
#endif
};

/**
    Spawn bots (if enabled) to fill out player spots until clients
    connect to the game.

    * Works off the following serverinfo variables:
        + bots_padclients     - number of clients to pad
                              bots_padclients % ag_numteams should == 0
        + ag_numteams         - number of teams to use
        + ag_team[1234]name   - names of teams
    * Having numteams 0 means we want to use classic Quake TeamDM.
        + FIXME can we make bot padding work here?
          Current behaviour is to add them to team "bots".
    * Having numteams 2-4 means we want to use AGRIP TeamDM
    * Numteams being 1 is a mistake (why not just use DM?)
*/
void() agh_world_padclients =
{
    local float numteams;
    local float padclients;
    local float botsperteam;
    local float i;
    local string tteam;

    // Should we be here?
    if( infokey(world, "deathmatch") == "0" )
        return;
    if( infokey(world, "bots_padclients") == "0" )
        return;
    if( infokey(world, "ag_numteams") == "0" )
        return;  // classic Quake TeamDM

    // How many bots to spawn?
    if( teamplay )
    {
        numteams = stof(infokey(world, "ag_numteams"));
        if( numteams < 2 || numteams > 4 )
        {
            error("Server misconfigured: ag_numteams isn't between 2 and 4!\n");
        }
    }
    else
    {
        numteams = 1;
    }
    padclients = stof(infokey(world, "bots_padclients"));
    botsperteam = rint(padclients / numteams);

    // Sanity check...
    if( botsperteam * numteams != padclients )
        error("Server misconfigured: bots_padclients doesn't (integer) divide into ag_numteams!\n");

    // Spawn the little fraggers...
    /*dprint("need to spawn: ");
    dprint(ftos(botsperteam));
    dprint(" [bpt] * ");
    dprint(ftos(numteams));
    dprint(" [teams] = ");
    dprint(ftos(padclients));
    dprint("\n");*/

    // As we cannot do this in for (while) loops because there are no arrays,
    // we have to explicitly say ``spawn a bot with team 2''.  There is a
    // short way to do this; just test if ag_numteams is greater than 0/1/2/3
    // and if it is, spawn botsperteam with the currently-being-tested team's
    // colours and name (done in a for (while) loop).

    // Also we have to wait before spawning the members on each team so that
    // we don't overflow the server.  For this reason, we set up an entity to
    // do the actual spawning.
    
    // FIXME disable team command / make it switch your colours too?
    
    entity spawner;
    spawner = spawn();
    spawner.items = numteams;
    spawner.frags = botsperteam;
    spawner.state = 0;  // not spawned any teams yet
    spawner.lip = 0;    // not spawned any members of teams yet
    spawner.think = snap_misc_botspawner;
    spawner.nextthink = time + 2;
}

/**
    Starts the appropriate helper devices when a client joins the server.
*/
void() agh_client_startdevs =
{
    // Work out which devices are meant to be active...

    // Note that we have to reverse the value of the cvar as it is meant
    // to signify that the devices are on if it is 1 -- but we know that
    // as we've just connected they aren't.

    // AUX
    snap_aux_constructor();

    // Set message lock to un-prioritise the following message...
    self.agrip_aux.state = true;
   
    // Instead of blurting out lots for each dev...
    snap_misc_m2m("Starting devices...\n");
    safe_soundtoclient(self, self, CHAN_AUTO, "toggles/on.wav", 1, ATTN_NORM);
    
    // Unset message lock...
    self.agrip_aux.state = false;

    // NAV
    if( infokey(self, "agv_t_nav") == "1" )
        snap_nav_constructor();

    // D5k
    if( infokey(self, "agv_t_d5k") == "1" )
        snap_d5k_constructor();

    // ESR
    if( infokey(self, "agv_t_esr") == "1" )
        snap_esr_constructor();

    // Compass Offset...
    SNAP_MISC_NORMYAW_OFFSET = 90;
    /*if( SNAP_MISC_NORMYAW_OFFSET == 270 )
        SNAP_MISC_NORMYAW_OFFSET = -90;*/
};

/**
    Attempt to replace a connected bot with a connecting client
    if bot padding is on.
    If teamplay is on, set appropriate colours for connecting client.
*/
void() agh_client_padclients_connect =
{
    local float teamnum, numteams, numpad, numplrs, botsperteam;
    local string conplrteam, sconplrteam;
    local string tmp;
    local string stmp;
    local string cmd;
    local string scmd;
    local string fullcmd;

    // Should we be here?
    if( infokey(world, "deathmatch") == "0" )
        return;
    if( infokey(world, "bots_padclients") == "0" )
        return;
    if( infokey(world, "ag_numteams") == "0" )
        return;  // classic Quake TeamDM

    // Ugly hack until MAUTH is finished...
    /*if( infokey(self, "isbot") != "1" )
    if( stof(infokey(self, "fortytwo")) != 42 )
    {
        sprint(self, PRINT_HIGH, "This is an AudioQuake server, not a standard QuakeWorld server.\nPlease only connect here if you're using AGRIP AudioQuake.\n");
        stuffcmd(self, "wait;disconnect\n");
        return;
    }*/

    if( teamplay )// || coop )
    {
        // Check number of teams vs our team...
        numteams = stof(infokey(world, "ag_numteams"));
        conplrteam = infokey(self, "team");
        sconplrteam = strzone(conplrteam);
        teamnum = snap_misc_numforteamname(conplrteam);

        // Valid team number?
        if( teamnum == 0 || teamnum > numteams )
        {
            sprint(self, PRINT_HIGH, "You have not set yourself to be in one of the teams on this server.\nPlease use the team command to do so and reconnect.\n");
            stuffcmd(self, "wait;disconnect\n");
            strunzone(sconplrteam);
            return;
        }
        else
        {
            // Set colours
            // (by working out the colours and sending a console command)...
            // bottom...
            tmp = ftos(snap_misc_bottomforteamnum(teamnum));
            stmp = strzone(tmp);
            cmd = stradd("bottomcolor ", stmp);
            scmd = strzone(cmd);
            fullcmd = stradd(scmd, "\n");
            stuffcmd(self, fullcmd);
            strunzone(scmd);
            strunzone(stmp);
            // Top...
            tmp = ftos(snap_misc_topforteamnum(teamnum));
            stmp = strzone(tmp);
            cmd = stradd("topcolor ", stmp);
            scmd = strzone(cmd);
            fullcmd = stradd(scmd, "\n");
            stuffcmd(self, fullcmd);
            strunzone(scmd);
            strunzone(stmp);
        }
    }
    else
    {
        // FIXME DM
        // ACTUALLY, don't need to do anything here
    }

    // Now we've added the player, should we remove a bot?
    /*FIXME old debug code
    dprint("PAD____CON: players: ");
    dprint(ftos(numplrs));
    dprint("  padclients: ");
    dprint(ftos(numpad));
    dprint("\n");*/
    if( infokey(self, "cab") != "1" )
    {
        // Kick a bot if a player connects
        // and we're over the padding limit...
        if( teamplay )
        {
            // FIXME check that there is not a bot here that should be
            // replaced by me -- even though we may not have gone over
            // the global padding limit, we could have gone over the limit
            // for players in this team.
            numpad = stof(infokey(world, "bots_padclients"));
            numplrs = CountPlayersTeam(sconplrteam);
            botsperteam = numpad / numteams;
            /*dprint("PAD____CON:");
            dprint("  padc's: ");
            dprint(ftos(numpad));
            dprint("  bots/team: ");
            dprint(ftos(botsperteam));
            dprint("  team plrs: ");
            dprint(ftos(numplrs));
            dprint("  team: ");
            dprint(sconplrteam);*/
            strunzone(sconplrteam);
            if( numplrs > botsperteam )
            {
                //dprint("  KICK");
                KickABotTeam(teamnum, 0);
            }
            else
            {
                //dprint("  NO KICK");
            }
            //dprint("\n");
        }
        else
        {
            numpad = stof(infokey(world, "bots_padclients"));
            numplrs = CountPlayers();
            if( numplrs > numpad )
                KickABotDM(0);
        }
    }
    //else
    //{
        // Kick a connecting bot if we need to leave a gap
        // for a player to connect...
        // FIXME
        // couldn't doing this begin a recursive loop?  should check before spawning?
    //}
}

/**
    Attempt to replace a disconnected client with a bot
    if bot padding is on.
*/
void() agh_client_padclients_disconnect =
{
    // Should we be here?
    if( infokey(world, "deathmatch") == "0" )
        return;
    if( infokey(world, "bots_padclients") == "0" )
        return;
    if( infokey(world, "ag_numteams") == "0" )
        return;  // classic Quake TeamDM

    //dprint("PAD_DISCON: <START>\n");
    if( teamplay )// || coop )
    {
        local float teamnum;
        local float numteams;
        local float numpad, numplrs;
        local string tmp;
   
        // Check number of teams vs our team...
        numteams = stof(infokey(world, "ag_numteams"));
        tmp = infokey(self, "team");
        teamnum = snap_misc_numforteamname(tmp);
    }

    // Now we've added the player, should we remove a bot?
    numpad = stof(infokey(world, "bots_padclients"));
    numplrs = CountPlayers();
    /*dprint("PAD_DISCON:  players: ");
    dprint(ftos(numplrs));
    dprint("  padclients: ");
    dprint(ftos(numpad));
    dprint("\n");*/
    if( infokey(self, "isbot") != "1" )
    {
        // Add a bot if a player connects
        // and we're under the padding limit...
        if( numplrs == numpad )
        // (Test for == because this client is just about to disappear
        // and when they finally do, we'll be just below the level.)
        {
            //dprint("PAD_DISCON: ADD A BOT!\n");
            if( teamplay == 1 )
            {
                local float bot, top;
                bot = stof(infokey(self, "bottom"));
                top = stof(infokey(self, "top"));
                create_bot(bot, top, infokey(self, "team"), 0); 
            }
            else
            {
                create_bot(0, 0, "bots", 0);
            }
        }
    }
}

/**
    Determines if and how to play footsteps.
*/
void() agh_player_footsteps =
{
    // Play footsteps if the user has asked for it and they're not stuck...
    //
    // Please read snap_misc_blockedtest() for an explanation of the stuck
    // detection algorithm.
    //
    // If footsteps are disabled and we are stuck, a sound _is_ played so
    // that the player knows they're stuck.
    //
    // This also works out if the player is scraping along a wall.

    // Get out?
    // (It is faster to calculate the negative, as it uses ORs instead of ANDs.)
    if( ! (self.walkframe == 1 || self.walkframe == 4) )
        return;

    // Check we're not stuck...

    // Test if we are moving...
    if( self.origin != self.oldorigin )
    {
        // Are we scraping against a wall?
        // (This would show up as two walls; one front/back and one at the side.)
        if( self.agrip_aux.ammo_rockets > 1 )
        if( self.origin_z == self.oldorigin_z )
        {
            safe_soundtoclient(self, self, CHAN_AUTO, "nav/wall-scrape.wav", 0.5, ATTN_NORM);

            // Go on to play a footstep too, as we _are_ moving, but make sure
            // we only play it at 1/2 the perceived ``speed''...
            if( self.walkframe != 1 )
                return;
            // Yes, we _should_ set self.oldorigin, but don't need to here
            // anyway -- phew!
        }

        // We're walking normally...
        // But we need to check that footsteps are turned on...
        if( infokey(self, "agv_t_footsteps") == "1" )
        {
            // Adjust speed according to if we're running or not...
            if( fabs(self.velocity_x + self.velocity_y) > 200 || self.walkframe == 1 )
            {
                // We may be in water...
                if( self.waterlevel > 1 )
                {
                    safe_soundtoclient(self, self, CHAN_AUTO, "misc/outwater.wav", 0.5, ATTN_NORM);
                }
                else if( checkbottom(self) )
                {
                    // Generate the footstep sound a bit randomly...
                    local float r;
                    r = random(); 
                    if( r < 0.5 )
                    {
                        safe_soundtoclient(self, self, CHAN_AUTO, "footsteps/footstep_l.wav", 0.5, ATTN_NORM);
                    }
                    else
                    {
                        safe_soundtoclient(self, self, CHAN_AUTO, "footsteps/footstep_r.wav", 0.5, ATTN_NORM);
                    }
                }
            }
        }
    }
    // We aren't moving.
    // If we are stuck, or footsteps are OFF, we'll just continue making
    // the ``oomph'' sound...
    else //if( infokey(self, "agv_t_footsteps") == 0 )
    {
        // Need to make sure that we haven't just started moving
        // or we'll get spurious oomphs...
        if( self.agrip_aux.ammo_rockets > 0 )
        if( self.walkframe == 1 )
            safe_soundtoclient(self, self, CHAN_AUTO, "player/land.wav", 0.5, ATTN_NORM);
    }

    // Store our origin...
    self.oldorigin = self.origin;
};

/**
    Kills all of the player's helper objects when they die.
*/
void() agh_player_dietidy =
{
    // Set the message lock to un-prioritise the following messages...
    self.agrip_aux.state = true;

    // Disable NAV, ESR, D5k...
    snap_misc_m2m("Stopping devices...\n");
    safe_soundtoclient(self, self, CHAN_AUTO, "toggles/off.wav", 1, ATTN_NORM);

    // NAV
    if( infokey(self, "agv_t_nav") == "1" )
    {
        remove(self.agrip_nav.aiment);
        remove(self.agrip_nav);
    }

    // D5k
    if( infokey(self, "agv_t_d5k") == "1" )
    {
        remove(self.agrip_d5k);
    }

    // ESR
    if( infokey(self, "agv_t_esr") == "1" )
    {
        remove(self.agrip_esr.aiment);
        remove(self.agrip_esr.enemy);
        remove(self.agrip_esr.goalentity);
        remove(self.agrip_esr);
    }

    // Remove all waypoints...
    if( self.agrip_aux.health > 0 )
        snap_misc_m2m("Removing markers...\n");
    // FIXME this is an NP-complete ugly hack!!!
    while( floor(self.agrip_aux.health) > 0 )
    {
        // debug info...
        /*dprint(self.netname);
        dprint(" call m_d with a-aux.h = ");
        dprint(ftos(self.agrip_aux.health));
        dprint("\n");*/
        // Call it *QUIETLY*...
        snap_marker_destructor(1);
    }

    // AUX
    remove(self.agrip_aux);
};

/**
    Carries out the accessibility-related impulse commands...
*/
void() agh_weapons_impulsecommands =
{
    // TUTOR BOT STUFF

    // Impulse  49  Kicks a bot
    //          50  Adds a bot on our team
    //          51  Adds an enemy bot
    //          52  Sets and un-sets the call flag

    // Note:    Only if we are in teamplay mode will the bot's team be
    //          taken into consideration; otherwise it'll always be an
    //          opponent to us.

    if( self.impulse == 49 )
    {
        // Can kick any old bot in DM; not so in team games...
        if( teamplay || coop )
        {
            local float myteam;
            myteam = snap_misc_numforteamname(infokey(self, "team"));
            KickABotTeam(myteam, true);
            // (The true at the end means a client called the function -- so
            // some checks need to be done to ensure this is allowed.)
        }
        else  // FIXME must be DM?
        {
            KickABotDM(true);  // client called
        }
    }
    
    if( self.impulse == 50 )
    {
        // Add a friend
        create_bot(stof(infokey(self, "bottomcolor")), stof(infokey(self, "topcolor")), infokey(self, "team"), true);
    }
                   
    if( self.impulse == 51 )
    {
        // Add an enemy (to a random team not including my own)...
        local float random_enemy_team, mybot, mytop;
        local string enemy_teamname;

        // Choose a team that isn't mine to add the top to...
        random_enemy_team = snap_misc_pickrndteam(true);
        enemy_teamname = snap_misc_nameforteamnum(random_enemy_team);
        mybot = snap_misc_bottomforteamnum(random_enemy_team);
        mytop = snap_misc_topforteamnum(random_enemy_team);
        create_bot(mybot, mytop, enemy_teamname, true);
    }
    
    if( self.impulse == 52 )
    {
        if( ! self.agrip_aux.ammo_cells )
        {
            self.agrip_aux.ammo_cells = true;
            snap_misc_m2m("Call for help\n");
        }
        else
        {
            self.agrip_aux.ammo_cells = false;
            snap_misc_m2m("Cancel call for help\n");
        }
     }

     
    // HELPER OBJECTS
	
    // Impulse  100 toggles nav
    //          101         nav/wall warnings
    //          102         nav/side wall warnings
    //          103         nav/wall hit warnings
    //          104         nav/z warnings
    //          105         nav/haz warnings
    //          106         nav/side haz warnings
    //          108         nav/corner warnings
    //	        110         d5k
    //	        120	        esr
    //	        121         esr/monster warnings
    //	        122         esr/enemy warnings
    //	        123         esr/friend warnings
    //	        130         footsteps
	
    // Navigation Helper -- ``nav''
    if( self.impulse == 100 )
    {
        if( infokey(self, "agv_t_nav") == "0" )
        {
            // Create a new object...
            snap_nav_constructor();
            stuffcmd(self, "setinfo agv_t_nav 1\n");
            snap_misc_m2m("NAV: Enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
        else
        {
            // Remove the object, as it exists now...
            remove(self.agrip_nav.aiment);
            remove(self.agrip_nav);
            stuffcmd(self, "setinfo agv_t_nav 0\n");
            snap_misc_m2m("NAV: Disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
    }

    // nav_wall_warnings
    if( self.impulse == 101 )
    {
        if( infokey(self, "agv_t_nav_wall_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_nav_wall_warnings 0\n");
            snap_misc_m2m("NAV: Wall warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_nav_wall_warnings 1\n");
            snap_misc_m2m("NAV: Wall warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }

    // nav_side_wall_warnings
    if( self.impulse == 102 )
    {
        if( infokey(self, "agv_t_nav_side_wall_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_nav_side_wall_warnings 0\n");
            snap_misc_m2m("NAV: Side wall warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_nav_side_wall_warnings 1\n");
            snap_misc_m2m("NAV: Side wall warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }

    // nav_wall_touch_warnings
    if( self.impulse == 103 )
    {
        if( infokey(self, "agv_t_nav_wall_touch_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_nav_wall_touch_warnings 0\n");
            snap_misc_m2m("NAV: Wall touch warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_nav_wall_touch_warnings 1\n");
            snap_misc_m2m("NAV: Wall touch warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }

    // nav_z_warnings
    if( self.impulse == 104 )
    {
        if( infokey(self, "agv_t_nav_z_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_nav_z_warnings 0\n");
            snap_misc_m2m("NAV: Z warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_nav_z_warnings 1\n");
            snap_misc_m2m("NAV: Z warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }

    // nav_haz_warnings
    if( self.impulse == 105 )
    {
        if( infokey(self, "agv_t_nav_haz_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_nav_haz_warnings 0\n");
            snap_misc_m2m("NAV: Hazard warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_nav_haz_warnings 1\n");
            snap_misc_m2m("NAV: Hazard warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }

    // nav_side_haz_warnings
    if( self.impulse == 106 )
    {
        if( infokey(self, "agv_t_nav_side_haz_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_nav_side_haz_warnings 0\n");
            snap_misc_m2m("NAV: Side hazard warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_nav_side_haz_warnings 1\n");
            snap_misc_m2m("NAV: Side hazard warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }

    // nav_space_warnings
    if( self.impulse == 107 )
    {
        if( infokey(self, "agv_t_nav_space_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_nav_space_warnings 0\n");
            snap_misc_m2m("NAV: Open space warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_nav_space_warnings 1\n");
            snap_misc_m2m("NAV: Open space warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }

    // nav_corner_warnings
    if( self.impulse == 108 )
    {
        if( infokey(self, "agv_t_nav_corner_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_nav_corner_warnings 0\n");
            snap_misc_m2m("NAV: Corner warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_nav_corner_warnings 1\n");
            snap_misc_m2m("NAV: Corner warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }
    
    // Detector 5000 -- ``D5k''
    if( self.impulse == 110 )
    {
        if( infokey(self, "agv_t_d5k") == "0" )
        {
            // Create a new object...
            snap_d5k_constructor();
            stuffcmd(self, "setinfo agv_t_d5k 1\n");
            snap_misc_m2m("D5k: Enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
        else
        {
            // Remove the object, as it exists now...
            remove(self.agrip_d5k);
            stuffcmd(self, "setinfo agv_t_d5k 0\n");
            snap_misc_m2m("D5k: Disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
    }	

    // EtherScan RADAR -- ``ESR''
     
    // This has 3 modes: off, on (classic) and on (hazard)
    // It detects nothing / enemies / drops.
   
    if( self.impulse == 120 )
    {
        // Re-enabling the ESR...
        if( infokey(self, "agv_t_esr") == "0" )
        {
            stuffcmd(self, "setinfo agv_t_esr 1\n");
            snap_esr_constructor();
            safe_soundtoclient(self, self, CHAN_AUTO, "toggles/on.wav", 1, ATTN_NORM);
            snap_misc_m2m("ESR: Set to mode 1.\n");
        }
        // Switching Modes...
        else if( infokey(self, "agv_t_esr") == "1" )
        {
            // If in mode 1, go to 2...
            stuffcmd(self, "setinfo agv_t_esr 2\n");

            // If we're in the middle of detecting a far-off enemy, the
            // player would have to wait a long time -- so we are going to
            // remove this wait...
            self.agrip_esr.nextthink = time + 0.01;
        }
        else if( infokey(self, "agv_t_esr") == "2" )
        {
            // The user wants to turn the ESR off...
            snap_misc_m2m("ESR: Disabled.\n");
            stuffcmd(self, "setinfo agv_t_esr 0\n");
        }
    }

    // ESR Monster Warnings...
    if( self.impulse == 121 )
    {
        if( infokey(self, "agv_t_esr_monster_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_esr_monster_warnings 0\n");
            snap_misc_m2m("ESR: Monster warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_esr_monster_warnings 1\n");
            snap_misc_m2m("ESR: Monster warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }
	
    // ESR Enemy Warnings...
    if( self.impulse == 122 )
    {
        if( infokey(self, "agv_t_esr_enemy_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_esr_enemy_warnings 0\n");
            snap_misc_m2m("ESR: Enemy warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_esr_enemy_warnings 1\n");
            snap_misc_m2m("ESR: Enemy warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }

    // ESR Friend Warnings...
    if( self.impulse == 123 )
    {
        if( infokey(self, "agv_t_esr_friend_warnings") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_esr_friend_warnings 0\n");
            snap_misc_m2m("ESR: Friend warnings disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_esr_friend_warnings 1\n");
            snap_misc_m2m("ESR: Friend warnings enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }
    
    // Footsteps...
    if( self.impulse == 130 )
    {
        if( infokey(self, "agv_t_footsteps") == "1" )
        {
            stuffcmd(self, "setinfo agv_t_footsteps 0\n");
            snap_misc_m2m("Footsteps disabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/off.wav", 1, ATTN_NORM);
        }
        else
        {
            stuffcmd(self, "setinfo agv_t_footsteps 1\n");
            snap_misc_m2m("Footsteps enabled.\n");
            safe_soundtoclient(self, self, CHAN_VOICE, "toggles/on.wav", 1, ATTN_NORM);
        }
    }


    // IMMEDIATE USE ITEMS...
    
    // Impulse  140 activates   compass
    //          141             open space sweep
    //          150             drop describer
    //          160             jump describer
    //          170             adds a marker
    //          171             deletes last marker
     
    // Compass...
    if( self.impulse == 140 )
        snap_extnav_compass();

    // Spawn a sweep object...
    if( self.impulse == 141 )
    {
        local entity sweep;
        sweep = spawn();
        self.groundentity = sweep;
        sweep.owner = self;
        sweep.health = stof(infokey(self, "agv_nav_detrange"));
        sweep.think = snap_extnav_osd;
        sweep.nextthink = time;
        // it will remove itself when completed.
    }
            
    // Drop description...
    if( self.impulse == 150 )
    if( infokey(self, "agv_t_nav") == "1" )
    {
        // The NAV device will tell us what lies in the drop.
        // The property we examine is set every time it thinks.
        if( self.agrip_nav.weapon == CONTENT_EMPTY )
            snap_misc_m2m("Ground.\n");
        else if( self.agrip_nav.weapon == CONTENT_WATER )
            snap_misc_m2m("Water.\n");
        else if( self.agrip_nav.weapon == CONTENT_SLIME )
            snap_misc_m2m("Slime.\n");
        else if( self.agrip_nav.weapon == CONTENT_LAVA )
            snap_misc_m2m("Lava.\n");
        else
            safe_soundtoclient(self, self, CHAN_AUTO, "deny.wav", 1, ATTN_NORM);
    }
   
    // Jump description...
    if( self.impulse == 160 )
    {
        // The NAV device will tell us if we can make the jump.
        // The property we examine is set every time it thinks.
        if( self.agrip_nav.takedamage == SNAP_NAV_JMP_RUN )
        {
            snap_misc_m2m("Running Jump.\n");
        }
        else if( self.agrip_nav.takedamage == SNAP_NAV_JMP_NRM )
        {
            snap_misc_m2m("Normal Jump.\n");
        }
        else
        {
            safe_soundtoclient(self, self, CHAN_AUTO, "deny.wav", 1, ATTN_NORM);
        }
    }

    // Marker: Add
    if( self.impulse == 170 )
    {
        snap_marker_constructor();
    }

    // Marker: Delete last
    if( self.impulse == 171 )
    {
        snap_marker_destructor(0);
    }

    
   // STATUS INDICATORS...
    
   // Impulse   90	gives	Health and Armour levels
   //	        91		Ammo Overview
    
    if( self.impulse == 90 )
    {
        local string varval;
        varval = ftos(self.health);
        snap_misc_m2m(varval);
        sprint(self, 1, " health, ");
        varval = ftos(self.armorvalue);
        sprint(self, 1, varval);
        sprint(self, 1, " armour at factor ");
        varval = ftos(self.armortype);
        sprint(self, 1, varval);
        sprint(self, 1, ".\n");
    }

    if( self.impulse == 91 )
    {
        local string varval;
        varval = ftos(self.ammo_shells);
        snap_misc_m2m(varval);
        sprint(self, 1, " shells, ");
        varval = ftos(self.ammo_nails);
        sprint(self, 1, varval);
        sprint(self, 1, " nails, ");
        varval = ftos(self.ammo_rockets);
        sprint(self, 1, varval);
        sprint(self, 1, " rockets, ");
        varval = ftos(self.ammo_cells);
        sprint(self, 1, varval);
        sprint(self, 1, " cells.\n");
    }
};

/* $AGRIP-END */
