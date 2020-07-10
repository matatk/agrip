// AGRIP Notes:
//  * This tutor bot is basically the normal one plus some code from oldman
//    that makes it use the ZQ bot support.
//  * It has 3 skill levels:
//      + 0 -- stays in the same place during combat
//      + 1 -- chases player during combat (when sensible)
//      + 2 -- does bot_run_slide() during combat

// Extra defns...
.float ai_time;
void() bot_attack;
vector realorigin (entity ent)
{
        return (ent.absmin + ent.absmax) * 0.5;
}

// KickABotClientCheck
// Ensures clients can't kick bots below the padclients level...
// Returns 0 if the user is not allowed to kick the bot, 1 if they are.
float() KickABotClientCheck =
{
    local float pclients;

    pclients = stof(infokey(world, "bots_padclients"));
    
    if( infokey(world, "bots_clientcontrol") == "1" )
    {
        if( CountPlayers() > pclients )
            return 1;
        else
            sprint(self, PRINT_HIGH, "Can't remove bots that are there to pad player slots!\n");
    }
    else
        sprint(self, PRINT_HIGH, "Clients not allowed to add/kick bots on this server!\n");
    
    return 0;
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Kick A Bot (DM version)
Adapted from FrikBot version to support bot padding

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void KickABotDM(float clientcalled)
{
    if( clientcalled )
        if( !KickABotClientCheck )
            return 2;

	entity pkick;
	pkick = find(world, classname, "player");
	while( pkick != world )
	{
        if( infokey(pkick, "isbot") == "1" )
        {
			stuffcmd(pkick, "disconnect\n");
			pkick = world;
		}
		else
        {
			pkick = find(pkick, classname, "player");
        }
	}

    // FIXME all bots kicked -> deny.wav?
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Kick A Bot (Team version)
Adapted from FrikBot version to support bot padding

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float KickABotTeam(float bteam, float clientcalled)
{
    // Returns:
    //       2 for you're not allowed to kick
    //       1 for didn't kick (not found)
    //       0 for did kick
   
    // FIXME do loop in here, check for no bots left
    
    local string isbot;
    local string found_ent_team;
    local string bot_team, s_bot_team;
    local float retval;

    retval = 1;  // assume we don't find smt to kick

    if( clientcalled )
        if( !KickABotClientCheck() )
            return 2;

    // Look up real team name for passed in team number..
    bot_team = snap_misc_nameforteamnum(bteam);
    s_bot_team = strzone(bot_team);

	entity pkick;
	pkick = find(world, classname, "player");
	while( pkick != world )
	{
        found_ent_team = infokey(pkick, "team");
        isbot = infokey(pkick, "isbot");

        if( isbot == "1" && found_ent_team == s_bot_team )
        {
			stuffcmd(pkick, "disconnect\n");
			pkick = world;
            retval = 0;
		}
		else
        {
			pkick = find(pkick, classname, "player");
        }
	}

    strunzone(s_bot_team);
    return retval;

    // FIXME all bots kicked -> deny.wav?
}


/*
---------------------------------------------------------------------------

		T U T O R   B O T



		Author:		Darryl "Coffee" Atchison
					coffee@planetquake.com

		Website:		http://www.planetquake.com/minion/tutorial/main.htm
					http://www.planetquake.com

		Version:		1.0
					1.10.99
				



		I n s t r u c t i o n s

		Yes, you heard correctly, this one file acts as an almost-
	fully-functional bot. You can plug him into deathmatch patches and
	mods. Or you can read his tutorials and customize him.
		Here's what to do.


	1. Open up the PROGS.SRC file, and insert the words "tutor.qc"
		without quotes after the words "misc.qc" 


	2. Open up the file CLIENT.QC and scroll down to ClientObituary().
		You'll see an early line looking like this:		

		if (targ.classname == "player")

	Change it to this:

		if (targ.classname == "player" || targ.classname == "bot")
	
	About 20 lines down, you see this line:

		if (attacker.classname == "player")

	Change it to this:

		if (attacker.classname == "player" || attacker.classname == "bot")


	3. Open up WEAPONS.QC and add this line to the top of the file:

		void(float teem) create_bot;

	Then, down below, add these lines to ImpulseCommands():

		if (self.impulse == 100)
			create_bot(1);
		if (self.impulse == 101)
			create_bot(2);


	4. Compile as you normally would and enjoy.


---------------------------------------------------------------------------
*/



/*
==========================================================================
==========================================================================
==========================================================================

	Section 1: AI

	Don't let this part worry you. Basically it's just walking and
	running thoughts. He'll check around himself for items, use
	movetogoal() to navigation, then grab his goal when he's close
	enough. He always looks for enemy bots and players. In addition,
	he must manually check for water, lava, and gaps in front of him.
	Remember, though, he's made to be simple, not smart.

==========================================================================
==========================================================================
==========================================================================
*/


// declaring the routines before they are called
// AGRIP - remove these 2:
//void() bot_jump1;
//void() respawn_bot;
void() bot_check_ammo;




// ------------------------------------------------
void() bot_search_for_items =
// ------------------------------------------------
{
local entity item;

// he gives up on that item and marks it to avoid it for a while
	if (time > self.search_time && self.goalentity != world)
		{
		self.goalentity.search_time = time + 30;
		self.goalentity = world;
		}

	if (self.goalentity != world)
		return;

// checks a radius around him for items
	item = findradius(self.origin, 1500);

	while(item)
		{
		if ( (item.flags & FL_ITEM) && visible(item) && item.model != string_null && time > item.search_time)
			{
			self.search_time = time + 30;
			self.goalentity = item;
			}
		item = item.chain;
		}

};


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_grab_items =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{

// sees if he's close enough to pick that item up

	if (self.goalentity == world)
		return;

	if (vlen(self.origin - self.goalentity.origin) <= 70)
		{
		self.goalentity.search_time = time + 60;
		self.goalentity.solid = SOLID_NOT;
		self.goalentity.model = string_null;
		self.goalentity.nextthink = time + 20;
		self.goalentity.think = SUB_regen;
		if (self.goalentity.healamount)
			sound (self, CHAN_ITEM, "items/health1.wav", 1, ATTN_NORM);
		else if (self.goalentity.weapon)
			sound (self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
		self.goalentity = world;
		}

};








// -----------------------------------------
void() jump_forward =
// -----------------------------------------
{
// propels him into the air

	if (!(self.flags & FL_ONGROUND))
		return;

	self.flags = self.flags - (self.flags & FL_ONGROUND);
	makevectors(self.angles);
	self.velocity = self.velocity + (v_forward * 250);
	self.velocity_z = self.velocity_z + 250;

};


// ------------------------------------------------
void() check_for_water =
// ------------------------------------------------
{
local float p;

// bots don't see water like players do, so we check for it

	makevectors(self.angles);
	p = pointcontents(self.origin + v_forward*16);
	if (p != CONTENT_WATER && p != CONTENT_SLIME && p != CONTENT_LAVA)
		return;

	if (p == CONTENT_WATER && time > self.pain_finished)
		{
		T_Damage (self, world, world, 5);
		self.pain_finished = time + 2;
		sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		}
	if (p == CONTENT_SLIME && time > self.pain_finished)
		{
		T_Damage (self, world, world, 10);
		self.pain_finished = time + 1;
		sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		}
	if (p == CONTENT_LAVA && time > self.pain_finished)
		{
		T_Damage (self, world, world, 20);
		self.pain_finished = time + 0.5;
		sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		}

	self.flags = self.flags - (self.flags & FL_ONGROUND);

// he'll try to swim upward here
	self.velocity = self.velocity + (v_forward * 200);
	self.velocity_z = self.velocity_z + 200;
	if (random() < 0.4)
		self.velocity_x = self.velocity_x + 100;
	else if (random() > 0.8)
		self.velocity_y = self.velocity_y + 100;

};




// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() check_for_ledge =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
local vector spot;

// movetogoal() will never move over a legde, so we have to 
// check for a break in front of him and force him to jump

	if (random() < 0.80)
		return;

	if (!(self.flags & FL_ONGROUND))
		return;

    // ``old'' code a.a.t. new tutor bot in qc...
    self.flags = self.flags - (self.flags & FL_ONGROUND);
    makevectors(self.angles);
    self.velocity = self.velocity + (v_forward * 250);
    self.velocity_z = self.velocity_z + 250;
    
/*	makevectors (self.angles);
	spot = self.origin + (v_forward * 60);
	spot = spot - '0 0 35';
	if (pointcontents(spot) == CONTENT_EMPTY)
		bot_jump1();*/
};





// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
float() bot_look_for_players =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
	local entity	client;
	local float		r;

// this is just like id's FindTarget(), he's looking for clients

	client = checkclient ();
	if (!client)
		return false;

    if( coop )// && ( self.colormap == client.colormap || !client ) )
    {
        local entity favent;

        // Look for a monster instead...
        client = findradius(self.origin, 1000);
        while( client )
        {
            if(     client.flags & FL_MONSTER
                    &&  client.health > 0
                    &&  visible(client) )
                favent = client;

            client = client.chain;
        }

        client = favent;
    }
    /* $AGRIP-END */


    // AGRIP matatk no:
	/*if (teamplay)
		if (self.team == client.team)
			return false;*/
    if (teamplay)
    {
        local string myteam, theirteam;
        myteam = infokey(self, "team");
        theirteam = infokey(client, "team");
        if (myteam == theirteam && myteam != "")
            return false;
    }

	if (client.netname == "observer")
		return false;

	if (client == self.enemy)
		return false;

	if (client.flags & FL_NOTARGET)
		return false;
	if (client.items & IT_INVISIBILITY)
		return false;

	r = range (client);
	if (r == RANGE_FAR)
		return false;
		
	if (!visible (client))
		return false;

	if (r == RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront (client))
			return false;
	}
	else if (r == RANGE_MID)
	{
		if (!infront (client))
			return false;
	}
	
	self.enemy = client;
	
    // AGRIP: no
    self.goalentity = client;
	//FoundTarget ();

	return true;
};


/*
// ------------------------------------------------
void() bot_look_for_bots =
// ------------------------------------------------
{
local entity found, foe;

// bots aren't clients, so we have to check fo them manually
// we just see if any of the bots in the entity list are visible

	if (self.enemy)
		return;

	found = world;
	foe = find(world, classname, "bot");

	while(foe)
		{
		if (visible(foe) && foe != self && foe.health > 0) 
			found = foe;
		if (teamplay && found.team == self.team)
			found = world;
		foe = find(foe, classname, "bot");
		}

	if (found != world)
		{
		self.enemy = found;
		self.goalentity = found;
		self.th_run();
		}
};*/

/* AGRIP no:
// ----------------------
void() bot_face =
// ----------------------
{
// this turns him directly toward his enemy

	self.angles_y = vectoyaw(self.enemy.origin - self.origin);
};
*/

// ----------------------
void() bot_face =
// ----------------------
{
    if(self.enemy != world) {
        vector viewangles;

        // this turns him directly toward his enemy
        self.angles_y = vectoyaw(self.enemy.origin - self.origin);
        viewangles = vectoangles(self.enemy.origin - self.origin);
        self.v_angle_x = viewangles_x;
        self.v_angle_y = viewangles_y;
        
        if (self.v_angle_x > 180)
            self.v_angle_x = self.v_angle_x - 360; // corrects an ID mistake
        
        self.v_angle_x = self.v_angle_x * -1;  // corrects an ID mistake
        
        if (self.v_angle_x > 80)
            self.v_angle_x = 80;
        
        if (self.v_angle_x < -80)
            self.v_angle_x = -80;
    }
}
    
// ----------------------
void() bot_stand =
// ----------------------
{

// his standing thoughts, pretty simple

    // AGRIP: no
	//bot_look_for_bots();
	bot_look_for_players();
	check_for_water();

	if (time > self.pausetime)
	{
		self.th_walk();
		return;
	}
	
// do a cute little turn
	if (random() < 0.1)
		self.angles_y = self.angles_y - 45;
	else if (random() > 0.9)
		self.angles_y = self.angles_y + 15;
};




// ******************************
void() coffee_move =
// ******************************
{

// this is the best subroutine i've ever written, and probably the
// most powerful bot roaming function. i hope you credit me if you use
// it. basically he strafes along a wall, then turns at a 45 or -45
// degree angle at the wall's corner. i have seen my bots do laps
// around entire levels with these three lines of code

	if (walkmove (self.angles_y, 20) == false)
		if (walkmove (self.angles_y + self.button1, 20) == false)
			self.angles_y = self.angles_y + (self.button1 / 2);

// every so often, he'll change his wall-hugging direction

	if (random() <= 0.02)
		if (self.button1 == 90)
			self.button1 = -90;
			else self.button1 = 90;

};


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_walk =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
	

// this is his main AI routine, where he will look for items and enemies

	if (!(self.flags & FL_ONGROUND))
		return;

	// AGRIP: no
    //bot_look_for_bots();
	bot_look_for_players();
	//bot_search_for_items();
	//bot_grab_items();

	check_for_ledge();
	check_for_water();

// of course movetogoal() is id's C function, it moves randomly
// toward what his self.goalentity is; don't let it worry you,
// this function takes a long time to get where its going
// the coffee_move is his cool running function

	if (self.goalentity != world)
		movetogoal(20);
		else coffee_move();



};





// --------------------------------
void() bot_run_slide =
// --------------------------------
{
	local float	ofs;
	
// this is a cool strafing routine

	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;

	if (walkmove (self.angles_y + ofs, 20))
		return;
		
	self.lefty = 1 - self.lefty;
	
	walkmove (self.angles_y - ofs, 20);
};




// ----------------------
void() bot_strafe =
// ----------------------
{
// this routine is called every frame during combat, 
// so he strafes and dodges even while shooting

	bot_check_ammo();

	if (!visible(self.enemy))
		{
		movetogoal(20);
		return;
		}

	bot_face();


// stepping backwards for a long distance shot
	if (self.weapon == IT_ROCKET_LAUNCHER)
		{
		if (walkmove (self.angles_y - 180, 20) == false)
			bot_run_slide();
		}

// chasing the player here
	else if (self.weapon == IT_SUPER_SHOTGUN)
		movetogoal(20);

// standing still while attacking
	else if (self.weapon == IT_LIGHTNING)
		return;
//	else bot_run_slide();   // AGRIP
    else
    {
        // AGRIP
        // Skill level 0 -- just stand there like an idiot.
        // Skill level 1 -- chase player
        // Skill level 2 -- bot_run_slide()
        local float skill;
        skill = stof(infokey(self, "bskill"));
        if (skill == 1)
        {
            if( self.weapon != IT_ROCKET_LAUNCHER )
            if( self.weapon != IT_GRENADE_LAUNCHER )
            {
                movetogoal(20);
            }
        }
        else if (skill == 2)
        {
            bot_run_slide();
        }
        // END AGRIP skillz stuff
    }
};


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_run =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{

// his fighting thoughts. after a short while, he'll give up 
// on his enemy, but if he can see him, he'll always attack

	if (!(self.flags & FL_ONGROUND))
		return;

	check_for_water();

	if (visible(self.enemy))
		self.search_time = time + 6;

	if (time > self.search_time || self.enemy.health <= 0)
		{
		self.goalentity = world;
		self.enemy = world;
		self.pausetime = time + 4;
        // AGRIP no:
		//self.th_stand();
		return;
		}

	bot_strafe();

    // AGRIP:
    bot_face();

	if (visible(self.enemy) && time > self.attack_finished)
		bot_attack();
		//self.th_missile(); AGRIP

};









/*
==========================================================================
==========================================================================
==========================================================================

	Section 2: Weapons

	This section is the simplest, basically dull stuff. It checks for
	his best weapon and sets the relevant ammo. It gives him a free
	weapon. And it does the actual firing of the weapons. The key
	difference between a player weapon routine and a bot weapon 
	routine is the aiming. In player routines, you'll see a line
	like this:

		dir = aim (self, 100000);

	If you want a bot to share that subroutine, basically all you need
	to do is change it to this:

		if (self.classname == "player")
			dir = aim (self, 100000);
			else dir = normalize(self.enemy.origin - self.origin);
			
	This allows the bot to aim directly at his enemy.


==========================================================================
==========================================================================
==========================================================================
*/

// AGRIP no:
//void() bot_run1;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_drop_pack =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
	if (random () < 0.5)
		DropBackpack();
};


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void(entity targ) give_random_weapon =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
local float it;

	it = floor(random() * 6);

	if (it == 0)
		{
		targ.items = targ.items | IT_SUPER_SHOTGUN;
		targ.currentammo = targ.ammo_shells = targ.ammo_shells + 25;
		targ.weapon = IT_SUPER_SHOTGUN;
		}
	else if (it == 1)
		{
		targ.items = targ.items | IT_NAILGUN;
		targ.currentammo = targ.ammo_nails = targ.ammo_nails + 50;
		targ.weapon = IT_NAILGUN;
		}
	else if (it == 2)
		{
		targ.items = targ.items | IT_LIGHTNING;
		targ.currentammo = targ.ammo_cells = targ.ammo_cells + 50;
		targ.weapon = IT_LIGHTNING;
		}
	else if (it == 3)
		{
		targ.items = targ.items | IT_GRENADE_LAUNCHER;
		targ.currentammo = targ.ammo_rockets = targ.ammo_rockets + 5;
		targ.weapon = IT_GRENADE_LAUNCHER;
		}
	else if (it == 4)
		{
		targ.items = targ.items | IT_ROCKET_LAUNCHER;
		targ.currentammo = targ.ammo_rockets = targ.ammo_rockets + 5;
		targ.weapon = IT_ROCKET_LAUNCHER;
		}
	else
		{
		targ.items = targ.items | IT_SUPER_NAILGUN;
		targ.currentammo = targ.ammo_nails = targ.ammo_nails + 50;
		targ.weapon = IT_SUPER_NAILGUN;
		}

};





// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
float() bot_bestweapon =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
	local	float	it;
	
	it = self.items;

	if (self.ammo_rockets >= 1 && (it & IT_ROCKET_LAUNCHER) )
		return IT_ROCKET_LAUNCHER;
	else if (self.ammo_cells >= 2 && (it & IT_LIGHTNING) )
		return IT_LIGHTNING;
	else if (self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	else if (self.ammo_rockets >= 1 && (it & IT_GRENADE_LAUNCHER) )
		return IT_GRENADE_LAUNCHER;
	else if (self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	else if (self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;

		return IT_SHOTGUN;

};



// --------------------------------
void() bot_set_currentammo =
// --------------------------------
{
	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
      if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
};


// -------------------------
void() bot_check_ammo =
// -------------------------
{
local float chance;

	if (self.currentammo > 0)
		return;

	if (self.weapon == IT_SHOTGUN)
		return;

	self.weapon = bot_bestweapon();

	bot_set_currentammo();
	
    // AGRIP no:
	//bot_run1();
};



// -------------------------------------
vector() bot_aim_at_enemy =
// -------------------------------------
{

	return normalize(self.enemy.origin - self.origin);

};


// -------------------------------------
void() bot_fire_supershotgun =
// -------------------------------------
{
local vector dir;

	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	bot_face();
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	
	//self.effects = self.effects | EF_MUZZLEFLASH;
	dir = bot_aim_at_enemy();
	FireBullets (18, dir, '0.14 0.1 0');
};



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_fire_shotgun =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
local vector dir;
	
	if (self.weapon == IT_SUPER_SHOTGUN)
		{
		bot_fire_supershotgun();
		return;
		}

	bot_face();

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	
	//self.effects = self.effects | EF_MUZZLEFLASH;

	dir = bot_aim_at_enemy();
	FireBullets (6, dir, '0.04 0.04 0');

};




// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_fire_supernailgun =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
local vector dir;

	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);

	dir = bot_aim_at_enemy();
	launch_spike (self.origin + '0 6 16', dir);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
};


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_fire_nailgun =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
local vector dir;

	if (self.weapon == IT_SUPER_NAILGUN)
		{
		bot_fire_supernailgun();
		return;
		}

	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	makevectors (self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

	dir = bot_aim_at_enemy();
	launch_spike (self.origin + '0 6 16', dir);

};


// """"""""""""""""""""""""""""
void() bot_fire_grenade =
// ----------------------------
{
	local	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	//self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
		
// set missile speed	
	makevectors (self.v_angle);

	missile.velocity = bot_aim_at_enemy();
	missile.velocity = missile.velocity * 500;
	missile.velocity_z = 300;

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = GrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin);

};



// =============================
void() bot_fire_rocket = 
// -----------------------------
{
local entity missile;

	if (self.weapon == IT_GRENADE_LAUNCHER)
		{
		bot_fire_grenade();
		return;
		}

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";

	missile.velocity = bot_aim_at_enemy() * 1000;

	missile.angles = vectoangles(missile.velocity);
	missile.touch = T_MissileTouch;
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '-1 -1 -1', '1 1 1');
	setorigin (missile, self.origin + v_forward*8 + '0 0 16');
};






// ==============================
void() bot_lightning =
// ------------------------------
{
	local	vector	org, dir;
	
	//self.effects = self.effects | EF_MUZZLEFLASH;

	bot_face();


	makevectors(self.angles);
	org = self.origin + '0 0 8' + (v_forward * 8);

	dir = bot_aim_at_enemy();

	traceline (org, self.origin + dir*600, true, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING1);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	LightningDamage (org, trace_endpos, self, 10);

	sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
};










/*
==========================================================================
==========================================================================
==========================================================================

	Section 3: Animation

	This is a bunch of ugly stuff, and you don't really need to
	understand all of it. It merely defines his animation frames and
	sequences. After that you have his pain, death, and attack routines.
	Lastly, we have his spawn/respawn subroutine.

==========================================================================
==========================================================================
==========================================================================
*/


/*
// Frame macros

$cd /raid/quake/id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


// movement animation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void() bot_stand1		=[	$stand1,	bot_stand2	] {bot_stand();};
void() bot_stand2		=[	$stand2,	bot_stand3	] {bot_stand();};
void() bot_stand3		=[	$stand3,	bot_stand4	] {bot_stand();};
void() bot_stand4		=[	$stand4,	bot_stand5	] {bot_stand();};
void() bot_stand5		=[	$stand5,	bot_stand1	] {bot_stand();};

	
void()  bot_walk1		=[	$rockrun1,	bot_walk2	] {bot_walk();};
void()  bot_walk2		=[	$rockrun2,	bot_walk3	] {bot_walk();};
void()  bot_walk3		=[	$rockrun3,	bot_walk4	] {bot_walk();};
void()  bot_walk4		=[	$rockrun4,	bot_walk5	] {bot_walk();};
void()  bot_walk5		=[	$rockrun5,	bot_walk6	] {bot_walk();};
void()  bot_walk6		=[	$rockrun6,	bot_walk1	] {bot_walk();};

void()  bot_run1		=[	$rockrun1,	bot_run2	] {bot_run();};
void()  bot_run2		=[	$rockrun2,	bot_run3	] {bot_run();};
void()  bot_run3		=[	$rockrun3,	bot_run4	] {bot_run();};
void()  bot_run4		=[	$rockrun4,	bot_run5	] {bot_run();};
void()  bot_run5		=[	$rockrun5,	bot_run6	] {bot_run();};
void()  bot_run6		=[	$rockrun6,	bot_run1	] {bot_run();};


void()  bot_jump1		=[	$rockrun1,	bot_jump2	] {jump_forward();};
void()  bot_jump2		=[	$rockrun1,	bot_jump3	] {};
void()  bot_jump3		=[	$rockrun1,	bot_jump4	] {};
void()  bot_jump4		=[	$rockrun1,	bot_jump5	] {};
void()  bot_jump5		=[	$rockrun1,	bot_walk1	] {};


// attack animation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void()  bot_rock1		=[	$rockatt1,	bot_rock2	] {bot_strafe(); bot_fire_rocket();};
void()  bot_rock2		=[	$rockatt2,	bot_rock3	] {bot_strafe();};
void()  bot_rock3		=[	$rockatt3,	bot_rock4	] {bot_strafe();};
void()  bot_rock4		=[	$rockatt4,	bot_rock5	] {bot_strafe();};
void()  bot_rock5		=[	$rockatt5,	bot_rock6	] {bot_strafe();};
void()  bot_rock6		=[	$rockatt6,	bot_run1	] {bot_strafe();};

void()  bot_shot1		=[	$shotatt1,	bot_shot2	] {bot_strafe(); bot_fire_shotgun();};
void()  bot_shot2		=[	$shotatt2,	bot_shot3	] {bot_strafe();};
void()  bot_shot3		=[	$shotatt3,	bot_shot4	] {bot_strafe();};
void()  bot_shot4		=[	$shotatt4,	bot_shot5	] {bot_strafe();};
void()  bot_shot5		=[	$shotatt5,	bot_shot6	] {bot_strafe();};
void()  bot_shot6		=[	$shotatt6,	bot_run1	] {bot_strafe();};

void()  bot_nail1		=[	$nailatt1,	bot_nail2	] {bot_strafe(); bot_fire_nailgun();};
void()  bot_nail2		=[	$nailatt2,	bot_nail3	] {bot_strafe();};
void()  bot_nail3		=[	$nailatt1,	bot_nail4	] {bot_strafe(); bot_fire_nailgun();};
void()  bot_nail4		=[	$nailatt2,	bot_nail5	] {bot_strafe();};
void()  bot_nail5		=[	$nailatt1,	bot_nail6	] {bot_strafe(); bot_fire_nailgun();};
void()  bot_nail6		=[	$nailatt2,	bot_run1	] {bot_strafe(); if (visible(self.enemy) && self.ammo_nails > 0 && self.enemy.health > 0)	bot_nail1(); else bot_run1(); };

void()  bot_light1	=[	$light1,	bot_light2	] {bot_strafe(); bot_lightning();};
void()  bot_light2	=[	$light2,	bot_light3	] {bot_strafe(); bot_lightning();};
void()  bot_light3	=[	$light1,	bot_light4	] {bot_strafe(); bot_lightning();};
void()  bot_light4	=[	$light2,	bot_light5	] {bot_strafe(); bot_lightning();};
void()  bot_light5	=[	$light1,	bot_light6	] {bot_strafe(); bot_lightning();};
void()  bot_light6	=[	$light2,	bot_run1	] {bot_strafe(); bot_lightning(); if (visible(self.enemy) && self.ammo_cells > 0 && self.enemy.health > 0) bot_light1(); else bot_run1(); };





void() th_respawn =
{
	self.think = respawn_bot;
	self.nextthink = time + 1;
};

void()  bot_pain1		=[	$pain1,	bot_pain2	] {};
void()  bot_pain2		=[	$pain2,	bot_pain3	] {};
void()  bot_pain3		=[	$pain4,	bot_pain4	] {};
void()  bot_pain4		=[	$pain3,	bot_pain5	] {};
void()  bot_pain5		=[	$pain4,	bot_pain6	] {};
void()  bot_pain6		=[	$pain6,	bot_run1	] {};

void()  bot_die1		=[	$deatha1,	bot_die2	] {};
void()  bot_die2		=[	$deatha2,	bot_die3	] {};
void()  bot_die3		=[	$deatha3,	bot_die4	] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_die4		=[	$deatha4,	bot_die5	] {};
void()  bot_die5		=[	$deatha5,	bot_die6	] {};
void()  bot_die6		=[	$deatha6,	bot_die7	] {};
void()  bot_die7		=[	$deatha7,	bot_die8	] {};
void()  bot_die8		=[	$deatha8,	bot_die9	] {};
void()  bot_die9		=[	$deatha9,	bot_die10	] {};
void()  bot_die10		=[	$deatha10,	bot_die11	] {};
void()  bot_die11		=[	$deatha11,	th_respawn	] {};

void()  bot_dieb1		=[	$deathb1,	bot_dieb2	 ] {};
void()  bot_dieb2		=[	$deathb2,	bot_dieb3	 ] {};
void()  bot_dieb3		=[	$deathb3,	bot_dieb4	 ] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_dieb4		=[	$deathb4,	bot_dieb5	 ] {};
void()  bot_dieb5		=[	$deathb5,	bot_dieb6	 ] {};
void()  bot_dieb6		=[	$deathb6,	bot_dieb7	 ] {};
void()  bot_dieb7		=[	$deathb7,	bot_dieb8	 ] {};
void()  bot_dieb8		=[	$deathb8,	bot_dieb9	 ] {};
void()  bot_dieb9		=[	$deathb9,	th_respawn	 ] {};

void()  bot_diec1		=[	$deathc1,	bot_diec2	 ] {};
void()  bot_diec2		=[	$deathc2,	bot_diec3	 ] {};
void()  bot_diec3		=[	$deathc3,	bot_diec4	 ] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_diec4		=[	$deathc4,	bot_diec5	 ] {};
void()  bot_diec5		=[	$deathc5,	bot_diec6	 ] {};
void()  bot_diec6		=[	$deathc6,	bot_diec7	 ] {};
void()  bot_diec7		=[	$deathc7,	bot_diec8	 ] {};
void()  bot_diec8		=[	$deathc8,	bot_diec9	 ] {};
void()  bot_diec9		=[	$deathc9,	bot_diec10	 ] {};
void()  bot_diec10	=[	$deathc10,	bot_diec11	 ] {};
void()  bot_diec11	=[	$deathc11,	bot_diec12	 ] {};
void()  bot_diec12	=[	$deathc12,	bot_diec13	 ] {};
void()  bot_diec13	=[	$deathc13,	bot_diec14	 ] {};
void()  bot_diec14	=[	$deathc14,	bot_diec15	 ] {};
void()  bot_diec15	=[	$deathc15,	th_respawn	 ] {};

void()  bot_died1		=[	$deathd1,	bot_died2	 ] {};
void()  bot_died2		=[	$deathd2,	bot_died3	 ] {};
void()  bot_died3		=[	$deathd3,	bot_died4	 ] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_died4		=[	$deathd4,	bot_died5	 ] {};
void()  bot_died5		=[	$deathd5,	bot_died6	 ] {};
void()  bot_died6		=[	$deathd6,	bot_died7	 ] {};
void()  bot_died7		=[	$deathd7,	bot_died8	 ] {};
void()  bot_died8		=[	$deathd8,	bot_died9	 ] {};
void()  bot_died9		=[	$deathd9,	th_respawn	 ] {};

void()  bot_diee1		=[	$deathe1,	bot_diee2	 ] {};
void()  bot_diee2		=[	$deathe2,	bot_diee3	 ] {};
void()  bot_diee3		=[	$deathe3,	bot_diee4	 ] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_diee4		=[	$deathe4,	bot_diee5	 ] {};
void()  bot_diee5		=[	$deathe5,	bot_diee6	 ] {};
void()  bot_diee6		=[	$deathe6,	bot_diee7	 ] {};
void()  bot_diee7		=[	$deathe7,	bot_diee8	 ] {};
void()  bot_diee8		=[	$deathe8,	bot_diee9	 ] {};
void()  bot_diee9		=[	$deathe9,	th_respawn	 ] {};



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void(entity attacker, float damage)	bot_pain =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{

// get mad at attacker if he's just walking
	if (attacker != self.enemy && attacker != world && self.enemy.classname != "player")
		{
		self.enemy = attacker;
		FoundTarget();
		}

	if (self.pain_finished > time)
		return;

	if (random() < 0.25)
		return;
	
	PainSound();

	if (random() > 0.75)
		return;
	
	self.pain_finished = time + 1;
	bot_pain1();

};



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() gib_bot =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
	ThrowGib ("progs/h_player.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	setmodel (self, "progs/gib3.mdl");
	setsize (self, '0 0 0', '0 0 0');

	self.deadflag = DEAD_DEAD;
	self.think = th_respawn;
	self.nextthink = time + 1;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
		
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);

};




// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_die =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
local float i;

// we're turning the bot off here and playing his death scene

	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	if (self.health < -40)
		{
		gib_bot();
		return;
		}
	
	DeathSound();

	i = floor(random() * 5);

	if (i == 0)
		bot_die1();
	else if (i == 1)
		bot_dieb1();
	else if (i == 2)
		bot_diec1();
	else if (i == 3)
		bot_died1();
	else
		bot_diee1();
	
};



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_attack =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
// this routine decides which animation sequence to play

	if (time < self.attack_finished)
		return;

	bot_check_ammo();

	if (self.weapon == IT_SHOTGUN)
		{
		self.attack_finished = time + 0.5;
		bot_shot1();
		}
	else if (self.weapon == IT_SUPER_SHOTGUN)
		{
		self.attack_finished = time + 0.7;
		bot_shot1();
		}
	else if (self.weapon == IT_NAILGUN)
		{
		self.attack_finished = time + 0.2;
		bot_nail1();
		}
	else if (self.weapon == IT_SUPER_NAILGUN)
		{
		self.attack_finished = time + 0.2;
		bot_nail1();
		}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
		self.attack_finished = time + 0.8;
		bot_rock1();
		}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
		self.attack_finished = time + 1;
		bot_rock1();
		}
	else if (self.weapon == IT_LIGHTNING)
		{
		self.attack_finished = time + 0.1;
		bot_light1();
		}


};
*/


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
weapon_range

_x "sweet spot range" - try to maintain this range if possible
_y minimum range bot can be to be effective (rl/gl) (move away)
_z maximum range bot can be to be effective (lg/axe) (move in)
 -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
vector weapon_range (float wep)
{
    if (wep == IT_AXE)
        return '48 0 64';
    else if (wep == IT_SHOTGUN)
        return '128 0 99999';
    else if (wep == IT_SUPER_SHOTGUN)
        return '128 0 99999';
    else if (wep == IT_NAILGUN)
        return '180 0 3000';
    else if (wep == IT_SUPER_NAILGUN)
        return '180 0 3000';
    else if (wep == IT_GRENADE_LAUNCHER)
        return '180 48 3000';
    else if (wep == IT_ROCKET_LAUNCHER)
        return '180 48 3000';
    else if (wep == IT_LIGHTNING)
        return '350 0 512';
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_attack =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
    vector dir, org, range;
    float foedist;

    bot_check_ammo();
    /* dir = vectoangles(bot_aim_at_enemy()); */
    /* self.v_angle_x = dir_x; */
    /* self.v_angle_y = dir_y; */
    org = realorigin(self.enemy);
    makevectors(self.v_angle);
    foedist = vlen(org - self.origin);
    range = weapon_range(self.weapon);
    traceline (self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * range_z, false, self);

    if (vlen(trace_endpos - (self.origin + self.view_ofs)) >= range_y)
        self.button0 = true;
}


// ------------------------------------------------
string() bot_name =
// ------------------------------------------------
{
    local float n;
	n = floor(random() * 16);
	if (n == 0)	return "Obliterator";
	else if (n == 1) return "Obelisk";
	else if (n == 2) return "Obscure";
	else if (n == 3) return "Obtuse";
	else if (n == 4) return "Obe";
	else if (n == 5) return "Obsidian";
	else if (n == 6) return "Obstructor";
	else if (n == 7) return "Obi";
	else if (n == 8) return "Obstinate";
	else if (n == 9) return "Objector";
    else if (n ==10) return "Oberon";
    else if (n ==11) return "Obveela";
    else if (n ==12) return "Obate";
    else if (n ==13) return "Obruge";
    else if (n ==14) return "Obete";
	else return "Oblivion";
	/*if (n == 0)	return "[B] Frog";
	else if (n == 1) return "[B] Reaper";
	else if (n == 2) return "[B] Omicron";
	else if (n == 3) return "[B] Estep";
	else if (n == 4) return "[B] Zeus";
	else if (n == 5) return "[B] Cujo";
	else if (n == 6) return "[B] Gyro";
	else if (n == 7) return "[B] Oak";
	else if (n == 8) return "[B] Eliminator";
	else if (n == 9) return "[B] Eraser";
	else return "[B] BG";*/
};



/*
// ------------------------------------------------
void() respawn_bot =
// ------------------------------------------------
{

local entity spot;

// putting him back in game
	spot = SelectSpawnPoint();
	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = true;	
	spawn_tfog (self.origin);
	spawn_tdeath (self.origin, self);
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	makevectors(self.angles);
	self.velocity = self.velocity + v_forward*20;

// making him normal again
	setmodel(self, "progs/player.mdl");
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.deadflag = DEAD_NO;
	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = self.angles * '0 1 0';
	self.yaw_speed = 120;
	self.view_ofs = '0 0 22';
	self.frame = $stand1;
	self.button1 = 90;

// finishing his characteristics
	self.items = IT_SHOTGUN;
	self.currentammo = self.ammo_shells = self.ammo_shells + 25;
	self.weapon = IT_SHOTGUN;
	give_random_weapon(self);
	self.health = 100;
	self.classname = "bot";
	self.enemy = world;
	self.goalentity = world;
	self.search_time = 0;

// making him stand for a bit
	self.pausetime = time + 5;
	self.nextthink = time + 0.1 + random();
	self.think = self.th_stand;
};
*/

/*
// ------------------------------------------------
void(float teem) create_bot =
// ------------------------------------------------
{
local entity bot, spot, plr;

// initializing the entity
	bot = spawn();
	spot = SelectSpawnPoint();
	bot.origin = spot.origin + '0 0 1';
	bot.angles = spot.angles;
	bot.fixangle = true;	
	spawn_tfog (bot.origin);
	spawn_tdeath (bot.origin, bot);
	bot.solid = SOLID_SLIDEBOX;
	bot.movetype = MOVETYPE_STEP;

// defining his animation
	setmodel(bot, "progs/player.mdl");
	bot.frame = $stand1;
	bot.th_stand = bot_stand1;
	bot.th_walk = bot_walk1;
	bot.th_run = bot_run1;
	bot.th_pain = bot_pain;
	bot.th_die = bot_die;
	bot.th_missile = bot_attack;

// arming and naming him
	bot.items = bot.items | IT_SHOTGUN;
	bot.currentammo = bot.ammo_shells = bot.ammo_shells + 25;
	bot.weapon = IT_SHOTGUN;
	give_random_weapon(bot);
	bot.health = 100;
	bot.classname = "bot";

	if (teamplay)
		{
		plr = find(world, classname, "player");
		plr.team = 1;
		bot.team = teem;
		if (teem == plr.team)
			bot.colormap = plr.colormap;
		}

	bot.netname = bot_name();
	bprint(bot.netname);
	bprint(" enters the game\n");

// polishing him up
	setsize (bot, VEC_HULL_MIN, VEC_HULL_MAX);
	bot.ideal_yaw = bot.angles * '0 1 0';
	bot.yaw_speed = 120;
	bot.view_ofs = '0 0 22';
	bot.takedamage = DAMAGE_AIM;
	bot.attack_state = 0;
	bot.button1 = 90;
	bot.nextthink = time + 0.1 + random();
	bot.think = bot.th_walk;
};
*/

// ------------------------------------------------
void(float bottom, float top, string bteam, float clientcalled) create_bot =
// ------------------------------------------------
{
    entity bot;
    local string s_bteam;
    local string skill, tmp;

    s_bteam = strzone(bteam);
    
    /*dprint("CREATE_BOT! bot: ");
    dprint(ftos(bottom));dprint("  top: ");
    dprint(ftos(top));dprint("  s_bteam: ");
    dprint(s_bteam);dprint("  cc: ");
    dprint(ftos(clientcalled));dprint("\n");*/

    // AGRIP - don't spawn a bot if it's not allowed...
    if( clientcalled )  // i.e. only check if we're a client
    if (!stof(infokey(world, "bots_clientcontrol")))
    {
        sprint(self, PRINT_HIGH, "Clients not allowed to add/kick bots on this server!\n");
        strunzone(s_bteam);
        // FIXME deny.wav!
        return;
    }

    // AGRIP - check bot skill setting...
    skill = infokey(world, "bots_skill");
    if( !skill || stof(skill) < 0 || stof(skill) > 2 )
    {
        sprint(self, PRINT_HIGH, "Can't add a bot - server admin has not set bots_skill to 0, 1 or 2!\n");
        strunzone(s_bteam);
        return;
    }

    // initializing the entity
    bot = testbot("tutorbot"); // use ZQuake server bot support
    if (!bot)
    {
        sprint(self, PRINT_HIGH, "Can't connect any more bots - server is full!\n");
        strunzone(s_bteam);
        return;
    }

    // Team name...
    setinfo (bot, "team", s_bteam);
    // NOTE: this is always set to text passed to testbot() whatever we do
    //       and doesn't work at all if it's not done right here... :-S
    strunzone(s_bteam);

    // Colours...
    tmp = ftos(bottom);
    setinfo (bot, "bottomcolor", tmp);
    tmp = ftos(top);
    setinfo (bot, "topcolor", tmp);
    
    // Ugly hack...
    //setinfo (bot, "fortytwo", "42");

    /* bot.speed = cvar("sv_maxspeed"); */
    bot.speed = 320;

    // Name...
    bot.netname = bot_name();
    setinfo (bot, "name", bot.netname);

    // initialise button1 to 90 degrees
    //self.button1 = 90;
    //self.failedmove = 0;
    bot.button1 = 90;
    //bot.failedmove = 0;

    // AGRIP skillz stuff...
    setinfo(bot, "isbot", "1");
    if( clientcalled )
        setinfo(bot, "cab", "1");
    setinfo(bot, "bskill", skill);  // variable by server admin
}

// called by the engine instead of ClientConnect for bots
void BotConnect ()
{
	ClientConnect ();
}

// called by the engine instead of ClientDisconnect for bots
void BotDisconnect ()
{
	ClientDisconnect ();
}

// called by the engine instead of PlayerPreThink for bots
void BotPreThink ()
{
	// am I dead? fire randomly until I respawn
	if (self.health < 1)
	{
		self.button0 = false;
		self.button2 = floor(random() * 2);
        self.enemy = self.goalentity = world;
        if (self.deadflag == DEAD_DEAD)
        {
            self.deadflag = DEAD_RESPAWNABLE;
            respawn();
        }
        return;
    }

    if (self.ai_time > time) {
        // do nothing
    } else {
        self.ai_time = time + 0.1;
        if(self.enemy == world || self.enemy == self) {
            self.button0 = false;
            /* if (!(self.flags & FL_ONGROUND)) */
                /* self.button2 = false; */
            if (time > self.pausetime) {
                bot_walk();
            } else {
                bot_stand();
            }
        } else if (self.health > 0) {
            bot_run();
        }
    }

    PlayerPreThink ();
}

// called by the engine instead of PlayerPostThink for bots
void BotPostThink ()
{
	PlayerPostThink ();		// just call the default function
}

// vi:foldenable
