/*
	client.qc

	client functions

	Copyright (C) 1996-1997  Id Software, Inc.

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/

// prototypes
void W_WeaponFrame ();
void W_SetCurrentAmmo ();
void player_pain ();
void player_stand1 ();
void play_teleport (entity ent);
void spawn_tfog (vector org);
void spawn_tdeath (vector org, entity death_owner);
void ExitIntermission ();
string ObituaryForMonster (string attacker_class);

float   modelindex_eyes, modelindex_player;

// ILLEGALFPS[abortelect
.float fAverageFrameTime;
.float fFrameCount;
.float fDisplayIllegalFPS;
.float fLowestFrameTime;
.float fIllegalFPSWarnings;
// ILLEGALFPS]

// TEAM -->
void(float skip_log) EndMatch;
void() StuffAliases;
float() CountALLPlayers;
void() IdlebotCheck;
void() CheckAll;
void() CheckConnectRate;
void() PlayerStats;
void() StartDie;
void() ExitCaptain;
void() CheckFinishCaptain;
// <-- TEAM

void() CheckAll =
{
	local float player_rate,maxrate=0,minrate=0;
      local string tmp;
	local entity p;

	maxrate = stof(infokey(world, "k_maxrate"));
	minrate = stof(infokey(world, "k_minrate"));

	if(maxrate!=0  || minrate!=0)
	{
		p = find(world, classname, "player");
		while(p != world) 
		{
			if(p.netname != "") 
			{
				// This is used to check a players rate.  If above allowed setting then it sets it to max allowed.
				player_rate = stof(infokey(p, "rate"));
	      		if (player_rate > maxrate)
				{
					sprint(p, 2, "\nYour עבפו setting is too high for this server.\n");
					tmp=ftos(maxrate);
					sprint(p, 2, "Rate set to ");
					sprint(p, 3, tmp, "\n");
			
					stuffcmd(p, "rate ");
					stuffcmd(p, tmp);
					stuffcmd(p, "\n");
				}

	      		if (player_rate < minrate)
				{
					sprint(p, 2, "\nYour עבפו setting is too low for this server.\n");
					tmp=ftos(minrate);
					sprint(p, 2, "Rate set to ");
					sprint(p, 3, tmp, "\n");
			
					stuffcmd(p, "rate ");
					stuffcmd(p, tmp);
					stuffcmd(p, "\n");
				}
			}
			p = find(p, classname, "player");
		}
	}
};

void() CheckConnectRate=
{
        local float player_rate,maxrate=0,minrate=0;
        local string tmp;

	// This is used to check a players rate.  If above allowed setting then it kicks em off.
	player_rate = stof(infokey(self, "rate"));
	
	maxrate = stof(infokey(world, "k_maxrate"));
	minrate = stof(infokey(world, "k_minrate"));

	if(maxrate  || minrate)
	{
	      if (player_rate > maxrate)
		{
			sprint(self, 2, "\nYour עבפו setting is too high for this server.\n");
			tmp=ftos(maxrate);
			sprint(self, 2, "Rate set to ");
			sprint(self, 3, tmp, "\n");
	
			stuffcmd(self, "rate ");
			stuffcmd(self, tmp);
			stuffcmd(self, "\n");
		}

		if (player_rate < minrate)
		{
			sprint(self, 2, "\nYour עבפו setting is too low for this server.\n");
			tmp=ftos(minrate);
			sprint(self, 2, "Rate set to ");
			sprint(self, 3, tmp, "\n");
			
			stuffcmd(self, "rate ");
			stuffcmd(self, tmp);
			stuffcmd(self, "\n");
		}
	}
};

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

string nextmap;

float	ignore_changeparms;

float   intermission_running;
float   intermission_exittime;
entity	intermission_spot;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void info_intermission ()
{
	self.angles = self.mangle;      // so C can get at it
}


void SetChangeParms ()
{
// TEAM -->
	if(match_in_progress == 2) {
		parm1 = 1 | 4096;
		parm8 = 1;
		parm2 = 100;
		parm3 = 0;
		parm4 = 25;
		parm5 = 0;
		parm6 = 0;
		parm7 = 0;
	} else {
		parm1 = 4096 | 1 | 2 | 4 | 8 | 32 | 16 | 64;
		parm2 = 100;
		parm3 = 0;
		parm4 = 100;
		parm5 = 200;
		parm6 = 100;
		parm7 = 100;
		parm8 = 32;
	}
        parm9 = 0;
	parm11 = self.k_admin;
	parm12 = self.k_accepted;
	parm13 = self.k_stuff;
// <-- TEAM
};

void SetNewParms ()
{
//team
	if(match_in_progress == 2) {
		parm1 = 1 | 4096;
		parm8 = 1;
		parm2 = 100;
		parm3 = 0;
		parm4 = 25;
		parm5 = 0;
		parm6 = 0;
		parm7 = 0;
	} else {
		parm1 = 4096 | 1 | 2 | 4 | 8 | 32 | 16 | 64;
		parm2 = 100;
		parm3 = 0;
		parm4 = 100;
		parm5 = 200;
		parm6 = 100;
		parm7 = 100;
		parm8 = 32;
	}

	parm9 = 0;
	parm11 = 0;
	parm12 = 0;
	parm13 = 0;
//team
}

void DecodeLevelParms ()
{
//KTEAMS -->
/*
	if(serverflags) {
		if(world.model == "maps/start.bsp") SetNewParms ();         // take away all stuff on starting new episode
	}
*/
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
    self.armortype = parm9 * 0.01;
	self.k_admin = parm11;
	if(parm12) 
        self.k_accepted = parm12;
	self.k_stuff = parm13;
//<-- KTEAMS
}

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity FindIntermission ()
{
	entity	spot;
	float	cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{       // pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (!spot)	
		objerror ("FindIntermission: no spot");

	return spot;
}


void GotoNextMap ()
{
    string newmap;

// KTEAMS: check at levelchange
	if(k_velect) AbortElect();

//ZOID: 12-13-96, samelevel is overloaded, only 1 works for same level

	if (!deathmatch)
		changelevel (nextmap);
	else if (cvar("samelevel") == 1)	// if samelevel is set, stay on same level
		changelevel (mapname);
	else {
		// configurable map lists, see if the current map exists as a
		// serverinfo/localinfo var
		newmap = infokey(world, mapname);
		if (newmap != "")
			changelevel (newmap);
		else
			changelevel (nextmap);
	}
}



/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void IntermissionThink ()
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	ExitIntermission ();
}

/*
============
execute_changelevel

The global "nextmap" has been set previously.
Take the players to the intermission spot
============
*/
void execute_changelevel ()
{
	intermission_running = 1;

// enforce a wait time before allowing changelevel
	intermission_exittime = time + 5;

	intermission_spot = FindIntermission ();

// play intermission music
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);

	WriteByte (MSG_ALL, SVC_INTERMISSION);
	WriteCoord (MSG_ALL, intermission_spot.origin_x);
	WriteCoord (MSG_ALL, intermission_spot.origin_y);
	WriteCoord (MSG_ALL, intermission_spot.origin_z);
	WriteAngle (MSG_ALL, intermission_spot.mangle_x);
	WriteAngle (MSG_ALL, intermission_spot.mangle_y);
	WriteAngle (MSG_ALL, intermission_spot.mangle_z);
	
	other = find (world, classname, "player");
	while (other != world)
	{
		other.takedamage = DAMAGE_NO;
		other.flags = other.flags | FL_NOTARGET;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		other.effects = 0;
		other.items = other.items - (other.items & (IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD));
		other.super_damage_finished = 0;
		other.radsuit_finished = 0;
		other.invisible_finished = 0;
		other.invincible_finished = 0;

// KTEAMS: make players invisible
        other.model = string_null;
		// take screenshot if requested
        if(stof(infokey(other, "k_flags")) & 2)
			stuffcmd(other, "wait; wait; wait; wait; wait; wait; screenshot\n");
        
        setorigin (other, intermission_spot.origin);
        other.velocity = '0 0 0';
		other = find (other, classname, "player");
	}

}

void() changelevel_touch =
{
	if (other.classname != "player")
		return;


// if "noexit" is set, blow up the player trying to leave
//ZOID, 12-13-96, noexit isn't supported in QW.  Overload samelevel
//      if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	if ((cvar("samelevel") == 2) || ((cvar("samelevel") == 3) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000);
		return;
	}

	bprint (2, other.netname);
	bprint (2," exited the level\n");

	nextmap = self.map;

	SUB_UseTargets ();

	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
}

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void trigger_changelevel ()
{
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");
	
	InitTrigger ();
	self.touch = changelevel_touch;
}


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void set_suicide_frame ();

// called by ClientKill and DeadThink
void respawn ()
{
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// set default spawn parms
		SetNewParms ();
		// respawn
		PutClientInServer ();
	}
	else
	{
		// let the stats stay as they were when the player
		// entered the level
		ignore_changeparms = true;
		// restart the entire server
		changelevel (mapname);
	}
}


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
    if (intermission_running)
        return;

// KTEAMS -->
	if(k_pause || k_standby) 
        return;
	if((time < self.suicide_time + 10) && stof(infokey(world, "k_kfp"))) {
		sprint(self, 2, "Only one suicide in 10 seconds\n");
		return;
	}
	self.suicide_time = time;
    k_nochange = 0;
// <-- KTEAM
    bprint (PRINT_MEDIUM, self.netname, " suicides\n");
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	logfrag (self, self);
	if(match_in_progress == 2)	// KTEAMS
		self.frags = self.frags - 2;    // extra penalty
	respawn ();
}

float CheckSpawnPoint (vector v)
{
	return 0;
}

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity SelectSpawnPoint ()
{
    entity  spot, thing;
	float   numspots, totalspots;
	float   pcount;
	entity spots;
	local	float	k_nspots;	// KTEAMS
	local	vector	v1;			// KTEAMS


	numspots = 0;
	totalspots = 0;

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

// choose a info_player_deathmatch point
// ok, find all spots that don't have players nearby

	spots = world;
	spot = find (world, classname, "info_player_deathmatch");       
	while (spot)
	{
		totalspots = totalspots + 1;

        thing = findradius(spot.origin, 84);
        pcount = 0;
		while(thing) 
        {
// KTEAMS
			if(thing.classname == "player") {
				if(!(stof(infokey(world, "k_spw")) == 2 && match_in_progress == 2 && !thing.k_1spawn) &&
					thing.health > 0) pcount = pcount + 1;
			}
// KTEAMS
			thing = thing.chain;
		}
// KTEAMS
		if(stof(infokey(world, "k_spw")) && match_in_progress == 2 && self.k_lastspawn == spot)
		 pcount = pcount + 1;
// KTEAMS
        if (pcount == 0) {
        	spot.goalentity = spots;
        	spots = spot;
        	numspots = numspots + 1;
		}
		// Get the next spot in the chain
		spot = find (spot, classname, "info_player_deathmatch");
	}

// KTEAMS
	if(match_in_progress == 2) self.k_1spawn = 200;
	k_nspots = totalspots;
// KTEAMS

totalspots = totalspots - 1;
	if (!numspots) {
		// ack, they are all full, just pick one at random
//		bprint (PRINT_HIGH, "Ackk! All spots are full. Selecting random spawn spot\n");
		totalspots = rint((random() * totalspots));
		spot = find (world, classname, "info_player_deathmatch");       
		while (totalspots > 0) {
			totalspots = totalspots - 1;
			spot = find (spot, classname, "info_player_deathmatch");
		}
// KTEAMS
		if(k_nspots > 2 && match_in_progress == 2) self.k_lastspawn = spot;
		pcount = stof(infokey(world, "k_spw"));
		if(!match_in_progress || (pcount > 0 && (!k_checkx || pcount == 1))) {
			makevectors(spot.angles);
			thing = findradius(spot.origin, 84);
			while(thing) {
				if(thing.classname == "player" && thing.health > 0) {
					v1 = thing.origin - (v_up * 15);
					traceline(v1, v1 + (v_forward * 160), 0, thing);
					v1 = trace_endpos;
					traceline(v1, v1 + (v_forward * 30), 0, thing);
					if(trace_fraction < 1) v1 = trace_endpos - (v_forward * 35);
					setorigin(thing, v1 + (v_up * 15));
				} else if(thing.classname == "teledeath") remove(thing);
				thing = thing.chain;
			}
		}
// KTEAMS
		return spot;
    }


// We now have the number of spots available on the map in numspots

    // Generate a random number between 1 and numspots

	numspots = numspots - 1;
	
	numspots = rint((random() * numspots ) );

	spot = spots;
	while (numspots > 0) {
		spot = spot.goalentity;
		numspots = numspots - 1;
	}
// KTEAMS
	if(k_nspots > 2 && match_in_progress == 2) 
        self.k_lastspawn = spot;
// KTEAMS
 	return spot;
}


void DecodeLevelParms ();
void PlayerDie ();

/*
===========
PutClientInServer

called each time a player enters a new level
============
*/
void PutClientInServer ()
{
	entity	spot;

	self.classname = "player";
	self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;                   // initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;

// KTEAMS
    self.brokenankle = 0;

// the spawn falling damage bug workaround
	self.jump_flag = 0;
	self.swim_flag = 0;

	if(stof(infokey(world, "k_sready")) && !match_in_progress && !self.ready)
		self.effects = 64;
	else 
        self.effects = 0;

// KTEAMS
	self.invincible_time = 0;

	DecodeLevelParms ();

	W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;

	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;

	spot = SelectSpawnPoint ();

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = true;           // turn this way immediately
	self.jump_flag = 0;

// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

// Mod - Xian (May.20.97)
// Bug where player would have velocity from their last kill

	self.velocity = '0 0 0';

	player_stand1 ();

//team
	if(!self.k_accepted && match_in_progress == 2) {
		self.takedamage = 0;
		self.solid = 0;
		self.movetype = 0;
		self.modelindex = 0;
		self.model = string_null;
	} else {
		self.k_accepted = 2;
		self.takedamage = 2;
		self.solid = 3;
		self.movetype = 3;
		setmodel (self, "progs/player.mdl");
		modelindex_player = self.modelindex;
		player_stand1 ();
		makevectors(self.angles);
		play_teleport (self);
		spawn_tfog (self.origin + v_forward*20);
		spawn_tdeath (self.origin, self);
//berzerk will not affect players that logs in during berzerk
//spawn666 will not affect the first spawn of players connecting to a game in progress
		if(match_in_progress == 2) {
			if(stof(infokey(world, "k_bzk")) && k_berzerk) {
				self.items = self.items | 4194304;
				self.super_time = 1;
				self.super_damage_finished = time + 3600;
			}
			if(stof(infokey(world, "k_666"))) {
				stuffcmd (self, "bf\n");
				self.invincible_time = 1;
				self.invincible_finished = time + 2;
				self.k_666 = 1;
				self.items = self.items | 1048576;
			}
		}
	}
//team

	if (deathmatch == 4 && match_in_progress == 2)	//team
	{
		self.ammo_shells = 0;
		if (stof(infokey(world, "axe")) == 0)
		{
			self.ammo_nails = 255;
			self.ammo_shells = 255;
			self.ammo_rockets = 255;
			self.ammo_cells = 255;
			self.items = self.items | IT_NAILGUN;
			self.items = self.items | IT_SUPER_NAILGUN;
			self.items = self.items | IT_SUPER_SHOTGUN;
			self.items = self.items | IT_ROCKET_LAUNCHER;
//		self.items = self.items | IT_GRENADE_LAUNCHER;
			self.items = self.items | IT_LIGHTNING;
		}
		self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + IT_ARMOR3;
		self.armorvalue = 200;
		self.armortype = 0.8;
		self.health = 250;
		self.items = self.items | IT_INVULNERABILITY;
		self.invincible_time = 1;
		self.invincible_finished = time + 3;
	}

	if (deathmatch == 5 && match_in_progress == 2)	//team
	{
		self.ammo_nails = 80;
		self.ammo_shells = 30;
		self.ammo_rockets = 10;
		self.ammo_cells = 30;
		self.items = self.items | IT_NAILGUN;
		self.items = self.items | IT_SUPER_NAILGUN;
		self.items = self.items | IT_SUPER_SHOTGUN;
		self.items = self.items | IT_ROCKET_LAUNCHER;
		self.items = self.items | IT_GRENADE_LAUNCHER;
		self.items = self.items | IT_LIGHTNING;
		self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + IT_ARMOR3;
		self.armorvalue = 200;
		self.armortype = 0.8;
		self.health = 200;
		self.items = self.items | IT_INVULNERABILITY;
		self.invincible_time = 1;
		self.invincible_finished = time + 3;
	}


}


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void info_player_start ()
{
}


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void info_player_start2 ()
{
}

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void info_player_deathmatch ()
{
}

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void info_player_coop ()
{
}

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
*/
void NextLevel ()
{
	entity	o;

	if (nextmap != "")
		return; // already done

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}
 
		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");
		if (!o || mapname == "start")
		{       // go back to same map if no trigger_changelevel
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;

	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
}

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void CheckRules ()
{
// TEAM -->
	if(fraglimit && self.frags >= fraglimit) 
        EndMatch(0);
// <-- TEAM
}

//============================================================================

void PlayerDeathThink ()
{
    float             forward;

	if(k_standby)   // KTEAMS
        return;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else    
			self.velocity = forward * normalize(self.velocity);
	}

//team   autospawn
	if((time - self.dead_time) > 5 && match_in_progress) {
		self.deadflag = 3;
		self.button0 = 0;
		self.button1 = 0;
		self.button2 = 0;
		respawn();
		return;
	}
//team

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
}


void PlayerJump ()
{
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
// play swiming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;         // don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);       
	self.button2 = 0;

// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);

		if (server_is_2_3x) {
			// if and only if running on a 2.30 or 2.33 server,
			// fix the jump bug via QC
			// newer servers should have an engine-side fix
			if (self.velocity_z < 0)
				self.velocity_z = 0;
		}
}


/*
===========
WaterMove

============
*/
.float  dmgtime;

void WaterMove ()
{
//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{       // drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{       
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{       // do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{       // do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}
	
	if ( !(self.flags & FL_INWATER) )
	{       

// player enter water sound

		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
}

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, 1, self);
	if (trace_fraction < 1)
	{       // solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, 1, self);
		if (trace_fraction == 1)
		{       // open at eye level

		self.flags = self.flags | 2048;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & 4096);
			self.teleport_time = time + 2;  // safety net
			return;
		}
	}
};

/*


================
PlayerPreThink

Called every frame before physics are run
================
*/
void PlayerPreThink ()
{
	local   float   r;
	local string tmp;

// ILLEGALFPS[

	self.fAverageFrameTime = self.fAverageFrameTime + frametime;
	self.fFrameCount = self.fFrameCount + 1;

	if( frametime < self.fLowestFrameTime )
		self.fLowestFrameTime = frametime;
	
	if( self.fDisplayIllegalFPS < time && framechecks)
	{

// client uptime check
// code by Zibbo
		r = self.fAverageFrameTime * 100 / (time - self.real_time);
		tmp = ftos(r);
		self.real_time = time;
		if(r > 103 && !match_in_progress) {
			sprint(self, PRINT_HIGH, "WARNING: QW clients up to 2.30 have a timer related bug which is caused by too long uptime. Either reboot your machine or upgrade to QWCL 2.33.\n");
			dprint(self.netname, "%speed%", tmp, "\n");
			if(r > 105)
				self.uptimebugpolicy = self.uptimebugpolicy + 1;
		}
		if(self.uptimebugpolicy > 3) {
			bprint(PRINT_HIGH, "\n", self.netname, " gets kicked for too long uptime\n");
			sprint(self, PRINT_HIGH, "Reboot your machine to get rid of this bug\n");
			self.classname = "";
			stuffcmd(self, "disconnect\n");
		}
// ends here

// delay on checking/displaying illegal FPS.
// s: changed to 15 for more accurate calculation (lag screws it up)
		self.fDisplayIllegalFPS = time + 15;
		
		local float fps;
		
		fps = floor( 72 * 13 / ( self.fAverageFrameTime / self.fFrameCount * 1000 ) );
		
		if( fps > current_maxfps )
		{
			bprint( PRINT_HIGH, "\nWARNING: ", self.netname, " is using the timedemo bug and has abnormally high frame rates, " );

			local float peak;
			local string str;
							
			peak = floor( 72 * 13 / ( self.fLowestFrameTime * 1000 ) );
			str = ftos( peak );
			
			bprint( PRINT_HIGH, "highest FPS = ", str, " (frametime was ");
		
			str = ftos( self.fLowestFrameTime * 1000 );
			
			bprint( PRINT_HIGH, str, "), " );
				
			str = ftos( fps );
			
			bprint( PRINT_HIGH, "average FPS = ", str, "!\n");
			
			self.fIllegalFPSWarnings = self.fIllegalFPSWarnings + 1;
			
                        if( self.fIllegalFPSWarnings > 3 )
			{
				// kick the player from server!
				// s: changed the text a bit :)
                                bprint(PRINT_HIGH, self.netname, " gets kicked for timedemo cheating\n");
                                self.classname = "";
                                stuffcmd(self, "disconnect\n");
                        }
		}
		
		// zero these so the average/highest FPS is calculated for each delay period.
		self.fAverageFrameTime = 0;
		self.fFrameCount = 0;
		self.fLowestFrameTime = 0.013;
	}
// ILLEGALFPS]

	if (intermission_running)
	{
		IntermissionThink ();   // otherwise a button could be missed between
		return;                                 // the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;         // intermission or finale

	if(!self.k_accepted || k_pause) return;	//team

	makevectors (self.v_angle);             // is this still used

    self.deathtype = "";

	CheckRules ();
    WaterMove ();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}

	if (self.deadflag == DEAD_DYING) 
    {
// Sometimes (rarely) the death animation functions in player.qc aren't
// invoked on death for some reason (couldn't figure out why). This leads to a
// state when the player stands still after dying and can't respawn or even
// suicide and has to reconnect. This is checked and fixed here
                if((self.dead_time + 0.1) < time
                        && self.frame < 41 || self.frame > 102)
                                StartDie();
		return; // dying, so do nothing
	}

	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

// teleporters can force a non-moving pause time        
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	if(time > self.attack_finished && self.currentammo == 0 && self.weapon != IT_AXE)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
	}
}
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void CheckPowerups ()
{
	if (self.health <= 0)
		return;

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, PRINT_HIGH, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{       // just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
	// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else
		self.modelindex = modelindex_player;    // don't use eyes

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if(self.invincible_finished < time + 3 && !self.k_666)		//team
		{
			if (self.invincible_time == 1)
			{
				sprint (self, PRINT_HIGH, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{       // just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
			self.k_666 = 0;		//team
		}
		if(self.invincible_finished > time && !self.k_666) // KTeAMS
        {
			self.effects = self.effects | EF_DIMLIGHT;
			self.effects = self.effects | EF_RED;
        }
		else 
        {
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
			self.effects = self.effects - (self.effects & EF_RED);
        }
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if(self.super_damage_finished < time + 3 && !k_berzerk)	//team
		{
			if (self.super_time == 1)
			{
				if (deathmatch == 4)
					sprint (self, PRINT_HIGH, "OctaPower is wearing off\n");
				else
					sprint (self, PRINT_HIGH, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}         
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if(self.super_damage_finished < time && !k_berzerk)	//team
		{       // just stopped
			self.items = self.items - IT_QUAD;
			if (deathmatch == 4)
			{
				self.ammo_cells = 255;
				self.armorvalue = 1;
				self.armortype = 0.8;
				self.health = 100;
			}
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
		{
			self.effects = self.effects | EF_DIMLIGHT;
			self.effects = self.effects | EF_BLUE;
		}
		else
		{
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
			self.effects = self.effects - (self.effects & EF_BLUE);
		}
	}       

// suit 
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;          // don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, PRINT_HIGH, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{       // just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}       

}


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void PlayerPostThink ()
{
	local string s1, s2;	//team
	local float f1, f2;	//team
	local entity ghost;	//team

// update vwep frame
    if(stof(infokey(world, "vwep")))
    {
        if (self.health <= 0)
        {
            self.vw_index = 0;
            self.vw_frame = 0;
        }
        else
            self.vw_frame = self.frame;
    }

//team
// check if player tried to change team
	if(k_captains == 2 && self.k_msgcount < time) {
// get the strings to compare
		s1 = infokey(self, "team");
		if(self.k_captain == 1 || self.k_picked == 1)
			s2 = infokey(world, "captteam1");
		else if(self.k_captain == 2 || self.k_picked == 2)
			s2 = infokey(world, "captteam2");
		else	s2 = "";

		if(s1 != s2) {
			sprint(self, 2, "You may מןפ change team\n");
			stuffcmd(self, "team \"");
			stuffcmd(self, s2);
			stuffcmd(self, "\"\n");
		}
		self.k_msgcount = time + 1;
	}

	if(match_in_progress == 2 && self.k_accepted == 2 && self.k_teamnum && k_checkx) 
	{
		s1 = ftos(self.k_teamnum);
		s2 = infokey(world, s1);
		s1 = infokey(self, "team");
		if(s1 != s2)
		{
			bprint(2, self.netname, " gets kicked for changing team\n");
			self.k_accepted = 0;
			f1 = 1;
			f2 = 0;
			while(f1 < k_userid && !f2) 
			{
				s1 = ftos(f1);
				s1 = infokey(world, s1);
				if(s1 == "") f2 = 1;
				else f1 = f1 + 1;
			}
			if(!f2) k_userid = k_userid + 1;
			ghost = spawn();
			ghost.owner = world;
			ghost.classname = "ghost";
			ghost.cnt2 = f1;
			ghost.k_teamnum = self.k_teamnum;
			ghost.frags = self.frags;
			ghost.deaths = self.deaths;
			ghost.friendly = self.friendly;
			ghost.ready = 0;
			s1 = ftos(f1);
			localcmd("localinfo ");
			localcmd(s1);
			localcmd(" \"");
			localcmd(self.netname);
			localcmd("\"\n");
			self.classname = "";
			stuffcmd(self, "disconnect\n");
			return;
		}
	}
	if(self.k_accepted == 1) {
		self.k_accepted = 2;

		self.takedamage = 2;
		self.solid = 3;
		self.movetype = 3;
		setmodel (self, "progs/player.mdl");
		modelindex_player = self.modelindex;
		player_stand1 ();
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
		play_teleport(self);
		spawn_tdeath (self.origin, self);
	}
	if(k_pause) {
		ImpulseCommands();
		return;
	}
//team

	if (self.view_ofs == '0 0 0')
		return;         // intermission or finale
	if (self.deadflag)
		return;

//team
	if(!self.k_accepted && match_in_progress == 2) return;
	if(self.k_1spawn) self.k_1spawn = self.k_1spawn - 1;
//team

// WaterMove function call moved here from PlayerPreThink to avoid
// occurrence of the spawn lavaburn bug and to fix the problem on spawning
// and playing the leave water sound if the player died underwater.

        WaterMove ();

// clear the flag if we landed
	if(self.flags & 512) self.brokenankle = 0;

// check to see if player landed and play landing sound
	if ((self.jump_flag < -300) && (self.flags & 512) )
	{
// Falling often results in 5-5 points of damage through 2 frames.
// This fixes the bug
                self.velocity_z = 0;

		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			self.deathtype = "falling";
			T_Damage (self, world, world, 5); 
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);

			if (self.groundentity.takedamage == DAMAGE_AIM)
			{
				// we landed on someone's head, hurt him
				self.groundentity.deathtype = "stomp";
				T_Damage (self.groundentity, self, self, 10);
			}
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
	}

	self.jump_flag = self.velocity_z;

	CheckPowerups ();

	W_WeaponFrame ();
}


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void ClientConnect ()
{
	local float f1 = 0;
	local entity p;
	local string tmp;

	ClientConnected(); // FrikBot

// ILLEGALFPS[
	// delay on checking/displaying illegal FPS.
	self.fAverageFrameTime = 0;
	self.fFrameCount = 0;
	self.fDisplayIllegalFPS = time + 10 + random() * 5;
	self.fLowestFrameTime = 0.013;
	self.fIllegalFPSWarnings = 0;
// ILLEGALFPS]

	// TEAM -->

	self.fraggie = 0;
	MakeMOTD();
	CheckConnectRate();

	// a client connecting during an intermission can cause problems
	if(intermission_running)
		GotoNextMap();

	if(k_captains == 2) {
// in case of team picking, pick player if there's a captain with his/her team
		p = find(world, classname, "player");
		while(p != world && !f1) {
			while(!p.k_captain && p != world) p = find(p, classname, "player");
			if(p.k_captain) {
				tmp = infokey(p, "team");
				if(tmp == infokey(self, "team")) {
					sprint(self, 2, "Team picking in progress\n");
					bprint(2, self.netname, " is set to team ", tmp, "‘\n");
					tmp = infokey(p, "topcolor");
					stuffcmd(self, "color ");
					stuffcmd(self, tmp);
					stuffcmd(self, " ");
					tmp = infokey(p, "bottomcolor");
					stuffcmd(self, tmp);
					stuffcmd(self, "\n");
					f1 = 1;
				} else	p = find(p, classname, "player");
			}
		}
// in case of team picking, check if there is a free spot for player number 1-16
		if(!f1) {
			p = self;
			while(p != world && f1 < 16) {
				f1 = f1 + 1;
				p = find(world, classname, "player");
				while(p != world && p.frags != f1)
					p = find(p, classname, "player");
			}
			// if we found a spot, set the player into it
			if(p == world) {
				stuffcmd(self, "color 0\nteam \"\"\nskin \"\"\n");
				self.fraggie = f1;
			}
		}
	}
// <-- TEAM
};

/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void ClientDisconnect ()
{
//kombat teams gained control over this
	local entity ghost;
	local float f1, f2;
	local string s1;

    ClientDisconnected(); // FrikBot

    if(self.k_accepted == 2) {
		set_suicide_frame();
		if(match_in_progress == 2 && self.ready) 
		{
			s1 = ftos(self.frags);

			bprint(2, self.netname, " left the game with ", s1, " frags\n");
			sound(self, 4, "player/tornoff2.wav", 1, 0);
			f1 = 1;
			f2 = 0;
			while(f1 < k_userid && !f2) {
				s1 = ftos(f1);
				s1 = infokey(world, s1);
				if(s1 == "") f2 = 1;
				else f1 = f1 + 1;
			}
			if(!f2) k_userid = k_userid + 1;
			ghost = spawn();
			ghost.owner = world;
			ghost.classname = "ghost";
			ghost.cnt2 = f1;
			ghost.k_teamnum = self.k_teamnum;
			ghost.frags = self.frags;
			ghost.deaths = self.deaths;
			ghost.friendly = self.friendly;
			ghost.ready = 0;
			s1 = ftos(f1);
			localcmd("localinfo ");
			localcmd(s1);

			localcmd(" \"");
			localcmd(self.netname);
			localcmd("\"\n");
		}
	} else if(match_in_progress == 2 && !self.k_accepted) {
		self.takedamage = 0;
		self.solid = 0;

		self.movetype = 0;
		self.modelindex = 0;
		self.model = string_null;
	}
	else if(!self.k_accepted)
	{
		self.takedamage = 0;
		self.solid = 0;

		self.movetype = 0;
		self.modelindex = 0;
		self.model = string_null;
	}

// s: added conditional function call here
	if(self.k_admin == 1.5 || self.k_captain > 10) {
		bprint(2, "Election aborted\n");
		AbortElect();
	}
	self.ready = 0;
	self.classname = "";

// s: added conditional function call here
	if(self.k_kicking) ExitKick(self);
	if(self.k_captain) {
		bprint(2, "A דבנפבימ has left");
		bprint(3, "\n");
		ExitCaptain();
	}
	if(k_captains == 2) CheckFinishCaptain();

	if(stof(infokey(world, "k_idletime")) && !k_force && !match_in_progress) IdlebotCheck();
	f1 = CountALLPlayers();
	if(!f1 && !stof(infokey(world, "k_master")) && !stof(infokey(world, "k_lockmap"))) {

	// Check if issued to execute reset.cfg (sturm)
        if(stof(infokey(world, "k_autoreset")))
        localcmd("exec configs/reset.cfg\n");

        s1 = infokey(world, "k_defmap");
        if(s1 != "" && s1 != mapname) {

                if(match_in_progress) EndMatch(1);
                localcmd("map ");
                localcmd(s1);
                localcmd("\n");
		}
	}
//team
};

/*
===========
ClientObituary

called when a player dies
============
*/
void ClientObituary (entity targ, entity attacker)
{
	float rnum;
	string deathstring, deathstring2;
	string attackerteam, targteam;
	local string attackerteam2;	//team

	// Set it so it should update scores at next attempt.
	k_nochange = 0;

	rnum = random();
	//ZOID 12-13-96: self.team doesn't work in QW.  Use keys
	attackerteam = infokey(attacker, "team");
	targteam = infokey(targ, "team");

	if (targ.classname == "player")
	{

		if (deathmatch > 3)
		{
			if (targ.deathtype == "selfwater")
			{
				bprint (1, targ.netname);
///team
				if(infokey(targ,"gender") == "f") bprint(1," electrocutes herself.\n");
				else bprint(1," electrocutes himself.\n");
///team
				targ.frags = targ.frags - 1;
				return;
			}
		}

		if (attacker.classname == "teledeath")
		{
// team --> no points for telefragging teammate
			if(match_in_progress != 2) {
				bprint(1,targ.netname, " was telefragged\n");
				return;
			}
			attackerteam2 = infokey(attacker.owner, "team");
			if(teamplay && targteam == attackerteam2 && attackerteam2 != "" && targ != attacker.owner)
			{
				bprint(1,targ.netname);
				if(infokey(targ,"gender") == "f") bprint (1," was telefragged by her teammate\n");
				else bprint(1," was telefragged by his teammate\n");
				targ.deaths = targ.deaths + 1;
				return;
			}
			bprint(1,targ.netname);
			bprint(1," was telefragged by ");

			bprint(1,attacker.owner.netname);
			bprint(1,"\n");


			attacker.owner.frags = attacker.owner.frags + 1;
			targ.deaths = targ.deaths + 1;
			attacker.owner.victim = targ.netname;
			targ.killer = attacker.owner.netname;
			logfrag (attacker.owner, targ);
// <-- team
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint (1,"Satan's power deflects ");
			bprint (1,targ.netname);
			bprint (1,"'s telefrag\n");

	            targ.frags = targ.frags - 1;
			logfrag (targ, targ);
			return;
		}

		// double 666 telefrag (can happen often in deathmatch 4)
		if (attacker.classname == "teledeath3")
		{
			bprint (1,targ.netname);
			bprint (1," was telefragged by ");
			bprint (1,attacker.owner.netname);
			bprint (1, "'s Satan's power\n");
			targ.frags = targ.frags - 1;
			logfrag (targ, targ);
			return;
		}


		if (targ.deathtype == "squish")
		{
			if (teamplay && targteam == attackerteam && attackerteam != "" && targ != attacker)
			{
				logfrag (attacker, attacker);
				attacker.frags = attacker.frags - 1;
				attacker.friendly = attacker.friendly + 1;		//team
				bprint (1,attacker.netname);
				bprint (1," squished a teammate\n");
				return;
			}
			else if (attacker.classname == "player" && attacker != targ)
			{
				bprint (1, attacker.netname);
				bprint (1," squishes ");
				bprint (1,targ.netname);
				bprint (1,"\n");
				logfrag (attacker, targ);
				attacker.frags = attacker.frags + 1;
				targ.deaths = targ.deaths + 1;	// team
				attacker.victim = targ.netname;
				targ.killer = attacker.netname;
				return;
			}
			else
			{
				logfrag (targ, targ);
				targ.frags = targ.frags - 1;            // killed self
				bprint (1,targ.netname);
				bprint (1," was squished\n");
				return;
			}
		}

		if (attacker.classname == "player") {

// included big part starts to handle optional new death messages :p

			if(stof(infokey(world, "k_deathmsg"))) {
				if (targ == attacker)
				{
					// killed self
					logfrag (attacker, attacker);
						attacker.frags = attacker.frags - 1;
					bprint (1,targ.netname);

					if (targ.deathtype == "grenade")
						bprint (1, " tries to put the pin back in\n");
					else if (targ.deathtype == "rocket")
					{
						if (rnum < 0.50)
							bprint (1, " becomes bored with life\n");
						else
							bprint (1, " discovers blast radius\n");
					}
					else if (targ.weapon == 64 && targ.waterlevel > 1)
					{
						if (targ.watertype == -4)
							bprint (1," discharges into the slime\n");
						else if (targ.watertype == -5)
							bprint (1," discharges into the lava\n");
						else if (random() < 0.5)
							bprint (1," discharges into the water.\n");
						else
							bprint (1," heats up the water\n");
						return;
					}
					else
						bprint (1," becomes bored with life\n");
				}
				else if ( (teamplay == 2) && (targteam == attackerteam) && (attackerteam != "") )
				{
///team
					if(rnum < 0.25) deathstring = " mows down a teammate\n";
					else if(rnum < 0.50) if(infokey(attacker.owner, "gender") == "f") deathstring = " checks her glasses\n";
						else deathstring = " checks his glasses\n";
					else if (rnum < 0.75)
						deathstring = " gets a frag for the other team\n";
///team
					else
						deathstring = " loses another friend\n";
					bprint (1, attacker.netname);
					bprint (1, deathstring);
					attacker.frags = attacker.frags - 1;
					attacker.friendly = attacker.friendly + 1;
					//ZOID 12-13-96:  killing a teammate logs as suicide
					logfrag (attacker, attacker);
					return;
				}
				else
				{
					logfrag (attacker, targ);
					attacker.frags = attacker.frags + 1;
					targ.deaths = targ.deaths + 1;          //team
					attacker.victim = targ.netname;
					targ.killer = attacker.netname;
					rnum = attacker.weapon;
					if (targ.deathtype == "nail")
					{
						if (random() < 0.50)
							deathstring = " was body pierced by ";
						else
							deathstring = " was nailed by ";
						deathstring2 = "\n";
					}
					if (targ.deathtype == "supernail")
					{
						rnum=random();
						if (targ.health < -40)
							deathstring = " was straw-cuttered by ";
						else if (rnum < 0.33)
							deathstring = " was punctured by ";
						else if (rnum < 0.66)
							deathstring = " was perforated by ";
						else deathstring = " was ventilated by ";
						deathstring2 = "\n";
					}
					else if (targ.deathtype == "grenade")
					{
						deathstring = " eats ";
						deathstring2 = "'s pineapple\n";
						if (targ.health < -40)
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s grenade\n";
						}
					}
					else if (targ.deathtype == "rocket")
					{
						if (attacker.super_damage_finished > 0 && targ.health < -40)
						{
							rnum = random();
							if (rnum < 0.33)
								deathstring = " was brutalized by ";
							else if (rnum < 0.66)
								deathstring = " was smeared by ";
							else
							{
								bprint (1, attacker.netname);
								bprint (1, " rips ");
								bprint (1, targ.netname);
								bprint (1, " a new one\n");
								return;
							}
							deathstring2 = "'s quad rocket\n";
						}
						else
						{
							if (targ.health < -40)
								deathstring = " was gibbed by ";
							else
								deathstring = " rides ";
							deathstring2 = "'s rocket\n";
						}
					}
					else if (rnum == 4096)
					{
						deathstring = " was ax-murdered by ";
						deathstring2 = "\n";
					}
					else if (rnum == 1)
					{
						if (targ.health < -40)
						{
							deathstring = " was lead poisoned by ";
							deathstring2 = "\n";
						}
						else
						{
							deathstring = " chewed on ";
							deathstring2 = "'s boomstick\n";
						}
					}
					else if (rnum == 2)
					{
						if (attacker.super_damage_finished > 0 )
							deathstring = " ate 8 loads of ";
						else
							deathstring = " ate 2 loads of ";
						deathstring2 = "'s buckshot\n";
					}
					else if (rnum == 64)
					{
						deathstring = " accepts ";
						if (attacker.waterlevel > 1)
							if (random() < 0.5)
							{
								deathstring = " drains ";
								deathstring2 = "'s batteries\n";
							}
							else deathstring2 = "'s discharge\n";
						else
						if (targ.health < -40)
						{
							deathstring = " gets a natural disaster from ";
							deathstring2 = "\n";
						}
						else
							deathstring2 = "'s shaft\n";
					}
					bprint (1,targ.netname);
					bprint (1,deathstring);
					bprint (1,attacker.netname);
					bprint (1,deathstring2);
				}
				return;
// included big part ends

			} else {
				if (targ == attacker)
				{
					// killed self
					logfrag (attacker, attacker);
					attacker.frags = attacker.frags - 1;
					bprint (1,targ.netname);

					if (targ.deathtype == "grenade")
						bprint (1," tries to put the pin back in\n");
					else if (targ.deathtype == "rocket")
						bprint (1," becomes bored with life\n");
					else if (targ.weapon == 64 && targ.waterlevel > 1)

					{
						if (targ.watertype == -4)
							bprint (1," discharges into the slime\n");
						else if (targ.watertype == -5)
							bprint (1," discharges into the lava\n");
						else
	        					bprint (1," discharges into the water.\n");
						return;
					}
	                                else
						bprint (1," becomes bored with life\n");
	                        }
				else if ( (teamplay == 2) && (targteam == attackerteam) && (attackerteam != "") )
				{
///team
//0.25 changed to 0.33 and 0.50 changed to 0.66 for kombat teams
					if(rnum < 0.33) deathstring = " mows down a teammate\n";
//				else if(rnum < 0.66) if(infokey(attacker.owner,"gender") == "f") deathstring = " checks her glasses\n";
					else if(rnum < 0.66) if(infokey(attacker, "gender") == "f") deathstring = " checks her glasses\n";
					else deathstring = " checks his glasses\n";
// shite message - removed by kombat teams
//                                else if (rnum < 0.75)
//					deathstring = " gets a frag for the other team\n";
// removed by kombat teams
///team
					else deathstring = " loses another friend\n";
					bprint (1, attacker.netname);
					bprint (1, deathstring);
					attacker.frags = attacker.frags - 1;
					attacker.friendly = attacker.friendly + 1;		//team
					//ZOID 12-13-96:  killing a teammate logs as suicide
					logfrag (attacker, attacker);
					return;
				}
				else
				{
					logfrag (attacker, targ);
					attacker.frags = attacker.frags + 1;
					targ.deaths = targ.deaths + 1;		//team
					attacker.victim = targ.netname;
					targ.killer = attacker.netname;
	   				rnum = attacker.weapon;
					if (targ.deathtype == "nail")
					{
						deathstring = " was nailed by ";
						deathstring2 = "\n";
					}
					if (targ.deathtype == "supernail")
					{
						deathstring = " was punctured by ";
						deathstring2 = "\n";
					}
					else if (targ.deathtype == "grenade")
					{
						deathstring = " eats ";

						deathstring2 = "'s pineapple\n";
						if (targ.health < -40)
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s grenade\n";
						}
					}
					else if (targ.deathtype == "rocket")
					{
						if (attacker.super_damage_finished > 0 && targ.health < -40)
						{
							rnum = random();
							if (rnum < 0.3)
								deathstring = " was brutalized by ";
							else if (rnum < 0.6)
								deathstring = " was smeared by ";
							else
							{
								bprint (1, attacker.netname);
								bprint (1, " rips ");
								bprint (1, targ.netname);
								bprint (1, " a new one\n");
								return;
							}

	       						deathstring2 = "'s quad rocket\n";
						}
						else
	                                        {
							deathstring = " rides ";
							deathstring2 = "'s rocket\n";
	
							if (targ.health < -40)
	                                                {
								deathstring = " was gibbed by ";
								deathstring2 = "'s rocket\n" ;
							}
						}
					}
					else if (rnum == 4096)
					{
						deathstring = " was ax-murdered by ";
						deathstring2 = "\n";
					}
					else if (rnum == 1)
					{
						deathstring = " chewed on ";
						deathstring2 = "'s boomstick\n";
					}
					else if (rnum == 2)
					{
						deathstring = " ate 2 loads of ";
						deathstring2 = "'s buckshot\n";
					}
					else if (rnum == 64)
					{
						deathstring = " accepts ";
						if (attacker.waterlevel > 1)
							deathstring2 = "'s discharge\n";
						else
							deathstring2 = "'s shaft\n";
					}
					bprint (1,targ.netname);
					bprint (1,deathstring);
					bprint (1,attacker.netname);
					bprint (1,deathstring2);
				}
				return;
			}
		}
		else
		{
			logfrag (targ, targ);
                                targ.frags = targ.frags - 1;            // killed self
			rnum = targ.watertype;

			bprint (1,targ.netname);
			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint (1," sleeps with the fishes\n");
				else
					bprint (1," sucks it down\n");
				return;
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint (1," gulped a load of slime\n");
				else
					bprint (1," can't exist on slime alone\n");
				return;
			}
			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					bprint (1," burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint (1," turned into hot slag\n");
				else
					bprint (1," visits the Volcano God\n");
				return;
			}
			if (attacker.classname == "explo_box")
			{
				bprint (1," blew up\n");
				return;
			}
			if (targ.deathtype == "falling")
			{
				rnum = stof(infokey(world, "k_deathmsg"));
				if(random() < 0.5 && rnum)
					bprint(1, " cratered\n");
				else {
					if(infokey(targ,"gender") == "f") bprint(1," fell to her death\n");
					else bprint(1," fell to his death\n");
				}
				return;
			}
			if (targ.deathtype == "nail" || targ.deathtype == "supernail")
			{
				bprint (1," was spiked\n");
				return;
			}
			if (targ.deathtype == "laser")
 			{
				bprint (1," was zapped\n");
 				return;
 			}
			if (attacker.classname == "fireball")
			{
				bprint (1," ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint (1," tried to leave\n");
				return;
			}

			bprint (1," died\n");
		}
	}
}
