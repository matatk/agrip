/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore, string dtype) T_RadiusDamage;
void(vector org, float damage) SpawnBlood;
void() SuperDamageSound;

// TEAM -->
void() TeamCommands;
void() StartTimer;
void() SelectMap;
void() ReportMe;
void() AdminImpBot;
float() CaptainImpulses;
void() CaptainPickPlayer;
// <-- TEAM

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");  // new rocket explosion
	precache_sound ("weapons/rocket1i.wav");        // spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav"); // player shotgun
	precache_sound ("weapons/ric1.wav");    // ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");    // ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");    // ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");  // super spikes
	precache_sound ("weapons/tink1.wav");   // spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav"); // grenade launcher
	precache_sound ("weapons/bounce.wav");          // grenade bounce
	precache_sound ("weapons/shotgn2.wav"); // super shotgun
};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local   vector  source;
	local   vector  org;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, 0, self);
	if (trace_fraction == 1.0)
		return;

	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		SpawnBlood (org, 20);
		if (deathmatch > 3)
			T_Damage (trace_ent, self, self, 75);
		else
        		T_Damage (trace_ent, self, self, 20);
	}
	else
	{       // hit wall
		sound (self, 1, "player/axhit2.wav", 1, 1);

		WriteByte (4, 23);
		WriteByte (4, 2);
		WriteByte (4, 3);
		WriteCoord (4, org_x);
		WriteCoord (4, org_y);
		WriteCoord (4, org_z);
		multicast (org, 2);
	}
};


//============================================================================


vector() wall_velocity =
{
	local vector    vel;

	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local   entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = 10;
	missile.solid = 0;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';

// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, float damage) SpawnBlood =
{
	WriteByte (4, 23);
	WriteByte (4, 12);
	WriteByte (4, 1);
	WriteCoord (4, org_x);
	WriteCoord (4, org_y);
	WriteCoord (4, org_z);
	multicast (org, 2);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector    vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, damage);
};


/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity  multi_ent;
float   multi_damage;

vector  blood_org;
float   blood_count;

vector  puff_org;
float   puff_count;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
	blood_count = 0;
	puff_count = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;

	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

void() Multi_Finish =
{
	if (puff_count)
	{
		WriteByte (4, 23);
		WriteByte (4, 2);
		WriteByte (4, puff_count);
		WriteCoord (4, puff_org_x);
		WriteCoord (4, puff_org_y);
		WriteCoord (4, puff_org_z);
		multicast (puff_org, 2);
	}

	if (blood_count)
	{
		WriteByte (4, 23);
		WriteByte (4, 12);
		WriteByte (4, blood_count);
		WriteCoord (4, blood_org_x);
		WriteCoord (4, blood_org_y);
		WriteCoord (4, blood_org_z);
		multicast (puff_org, 2);
	}
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local   vector  vel, org;

	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		blood_count = blood_count + 1;
		blood_org = org;
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		puff_count = puff_count + 1;
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	local   vector direction;
	local   vector  src;

	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	traceline (src, src + dir*2048, 0, self);
	puff_org = trace_endpos - dir*4;

	while (shotcount > 0)
	{

		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		traceline (src, src + direction*2048, 0, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
	Multi_Finish ();
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, 1, "weapons/guncock.wav", 1, 1);

	msg_entity = self;
	WriteByte (1, 34);

        if (match_in_progress == 2)  // TEAM
	if (deathmatch != 4 )
                self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	FireBullets (6, dir, '0.04 0.04 0');
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}

	sound (self ,1, "weapons/shotgn2.wav", 1, 1);

	msg_entity = self;
	WriteByte (1, 35);

	if (match_in_progress == 2) // TEAM
	if (deathmatch != 4 )
		self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 100000);
	FireBullets (14, dir, '0.14 0.08 0');
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

void() T_MissileTouch =
{
	local float     damg;

	if (other == self.owner)
		return;         // don't explode on owner

        if (self.voided)
		return;

	self.voided = 1;

	if (pointcontents(self.origin) == -6)
	{
		remove(self);
		return;
	}

        damg = 100 + random()*20;

	if (other.health)
	{
		other.deathtype = "rocket";
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other, "rocket");

//      sound (self, 1, "weapons/r_exp3.wav", 1, 1);
	self.origin = self.origin - 8 * normalize(self.velocity);

	WriteByte (4, 23);
	WriteByte (4, 3);
	WriteCoord (4, self.origin_x);
	WriteCoord (4, self.origin_y);
	WriteCoord (4, self.origin_z);
	multicast (self.origin, 1);

	remove(self);
};



/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
        if (match_in_progress == 2) // TEAM
	if (deathmatch != 4 )
                self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound (self, 1, "weapons/sgun1.wav", 1, 1);

	msg_entity = self;
	WriteByte (1, 34);

	newmis = spawn ();
        newmis.classname = "rocket"; // TEAM
	newmis.owner = self;
	newmis.movetype = 9;
	newmis.solid = 2;

// set newmis speed

	makevectors (self.v_angle);
	newmis.velocity = aim(self, 1000);
	newmis.velocity = newmis.velocity * 1000;
	newmis.angles = vectoangles(newmis.velocity);
        newmis.voided = 0;

	newmis.touch = T_MissileTouch;

// set newmis duration
	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;

	setmodel (newmis, "progs/missile.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, self.origin + v_forward*8 + '0 0 16');
};
/*
===============================================================================

LIGHTNING

===============================================================================
*/

void(entity from, float damage) LightningHit =
{
	WriteByte (4, 23);
	WriteByte (4, 13);
	WriteCoord (4, trace_endpos_x);
	WriteCoord (4, trace_endpos_y);
	WriteCoord (4, trace_endpos_z);
	multicast (trace_endpos, 2);

	T_Damage (trace_ent, from, from, damage);
};

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity            e1, e2;
	local vector            f;

	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, 0, self);
	if (trace_ent.takedamage)
	{
		LightningHit (from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, 0, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		LightningHit (from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, 0, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		LightningHit (from, damage);
	}
};


void() W_FireLightning =
{
	local   vector          org;
	local   float           cells;

	if (self.ammo_cells < 1 || match_in_progress == 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1 && match_in_progress == 2)	//team
	{
		if (deathmatch > 3)
		{
			if (random() <= 0.5)
			{
				self.deathtype = "selfwater";
				T_Damage (self, self, self.owner, 4000 );
			}
			else
                        {
                		cells = self.ammo_cells;
                                self.ammo_cells = 0;
                                W_SetCurrentAmmo ();
                                if (!stof(infokey(world, "k_dis"))) return; // TEAM
                                T_RadiusDamage (self, self, 35*cells, world, "");
                		return;
                        }
		}
		else
		{
			cells = self.ammo_cells;
			self.ammo_cells = 0;
			W_SetCurrentAmmo ();
                        if (!stof(infokey(world, "k_dis"))) return; // TEAM
			T_RadiusDamage (self, self, 35*cells, world, "");
			return;
		}
	}

	if (self.t_width < time)
	{
		sound (self, 1, "weapons/lhit.wav", 1, 1);
		self.t_width = time + 0.6;
	}
	msg_entity = self;
	WriteByte (1, 34);

	if (match_in_progress == 2) // TEAM
	if (deathmatch != 4 )
		self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	org = self.origin + '0 0 16';

	traceline (org, org + v_forward*600, 1, self);

	WriteByte (4, 23);
	WriteByte (4, 6);
	WriteEntity (4, self);
	WriteCoord (4, org_x);
	WriteCoord (4, org_y);
	WriteCoord (4, org_z);
	WriteCoord (4, trace_endpos_x);
	WriteCoord (4, trace_endpos_y);
	WriteCoord (4, trace_endpos_z);
	multicast (org, 1);

	LightningDamage (self.origin, trace_endpos + v_forward*4, self, 30);
};


//=============================================================================


void() GrenadeExplode =
{
        if (self.voided)
                return;

        self.voided = 1;

	T_RadiusDamage (self, self.owner, 120, world, "grenade");

	WriteByte (4, 23);
	WriteByte (4, 3);
	WriteCoord (4, self.origin_x);
	WriteCoord (4, self.origin_y);
	WriteCoord (4, self.origin_z);
	multicast (self.origin, 1);

	remove (self);
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return;         // don't explode on owner
	if (other.takedamage == 2)
	{
		GrenadeExplode();
		return;
	}
	sound (self, 1, "weapons/bounce.wav", 1, 1);  // bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
        if (match_in_progress == 2) // TEAM
	if (deathmatch != 4)
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound (self, 1, "weapons/grenade.wav", 1, 1);

	msg_entity = self;
	WriteByte (1, 34);

	newmis = spawn ();
        newmis.voided = 0;
	newmis.owner = self;
	newmis.movetype = 10;
	newmis.solid = 2;
	newmis.classname = "grenade";

// set newmis speed

	makevectors (self.v_angle);

	if (self.v_angle_x)
		newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		newmis.velocity = aim(self, 10000);
		newmis.velocity = newmis.velocity * 600;
		newmis.velocity_z = 200;
	}

	newmis.avelocity = '300 300 300';

	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = GrenadeTouch;

// set newmis duration
	if (deathmatch == 4)
	{
		newmis.nextthink = time + 2.5;
		self.attack_finished = time + 1.1;
//		self.health = self.health - 1;
		T_Damage (self, self, self.owner, 10 );
	}
	else
        	newmis.nextthink = time + 2.5;
	newmis.think = GrenadeExplode;

	setmodel (newmis, "progs/grenade.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, self.origin);
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
        newmis.voided = 0;
	newmis.owner = self;
	newmis.movetype = 9;
	newmis.solid = 2;

	newmis.angles = vectoangles(dir);

	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	local vector    dir;

	sound (self, 1, "weapons/spike2.wav", 1, 1);
	self.attack_finished = time + 0.2;
	if (match_in_progress == 2) // TEAM
	if (deathmatch != 4)
		self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	msg_entity = self;
	WriteByte (1, 34);
};

void(float ox) W_FireSpikes =
{
	local vector    dir;

	makevectors (self.v_angle);

	if (self.ammo_nails >= 2 && self.weapon == 8 && match_in_progress != 1)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1 || match_in_progress == 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	sound (self, 1, "weapons/rocket1i.wav", 1, 1);
	self.attack_finished = time + 0.2;
	if (match_in_progress == 2) // TEAM
	if (deathmatch != 4)
		self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	dir = aim (self, 1000);
 	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);
	msg_entity = self;
	WriteByte (1, 34);
};

void() spike_touch =
{
	if (other == self.owner)
		return;

        if (self.voided)
                return;

        self.voided = 1;

	if (other.solid == 1)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == -6)
	{
		remove(self);
		return;
	}

// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		other.deathtype = "nail";
		T_Damage (other, self, self.owner, 9);
	}
	else
	{
		WriteByte (4, 23);
		if (self.classname == "wizspike")
			WriteByte (4, 7);
		else if (self.classname == "knightspike")
			WriteByte (4, 8);
		else
			WriteByte (4, 0);
		WriteCoord (4, self.origin_x);
		WriteCoord (4, self.origin_y);
		WriteCoord (4, self.origin_z);
		multicast (self.origin, 1);
	}

	remove(self);

};

void() superspike_touch =
{
	if (other == self.owner)
		return;

        if (self.voided)
                return;

        self.voided = 1;

	if (other.solid == 1)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == -6)
	{
		remove(self);
		return;
	}

// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		other.deathtype = "supernail";
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (4, 23);
		WriteByte (4, 1);
		WriteCoord (4, self.origin_x);
		WriteCoord (4, self.origin_y);
		WriteCoord (4, self.origin_z);
		multicast (self.origin, 1);
	}

	remove(self);

};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	player_run ();          // get out of any weapon firing states

	self.items = self.items - ( self.items & (256 | 512 | 1024 | 2048) );

	if (self.weapon == 4096)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
		self.weaponframe = 0;
        self.vw_index = 1;
	}
	else if (self.weapon == 1)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.weaponframe = 0;
		self.items = self.items | 256;
        self.vw_index = 2;
    }
	else if (self.weapon == 2)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | 256;
        self.vw_index = 3;
	}
	else if (self.weapon == 4)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
		self.weaponframe = 0;
		self.items = self.items | 512;
        self.vw_index = 4;
	}
	else if (self.weapon == 8)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.weaponframe = 0;
		self.items = self.items | 512;
        self.vw_index = 5;
	}
	else if (self.weapon == 16)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;
		self.items = self.items | 1024;
        self.vw_index = 6;
	}
	else if (self.weapon == 32)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | 1024;
        self.vw_index = 7;
	}
	else if (self.weapon == 64)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | 2048;
        self.vw_index = 8;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
};

float() W_BestWeapon =
{
	local   float   it;

	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & 64) )
		return 64;
	else if(self.ammo_nails >= 2 && (it & 8) )
		return 8;
	else if(self.ammo_shells >= 2 && (it & 2) )
		return 2;
	else if(self.ammo_nails >= 1 && (it & 4) )
		return 4;
	else if(self.ammo_shells >= 1 && (it & 1)  )
		return 1;

/*
	if(self.ammo_rockets >= 1 && (it & 32) )
		return 32;
	else if(self.ammo_rockets >= 1 && (it & 16) )
		return 16;

*/

	return 4096;
};

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return 1;

	if (self.weapon == 4096)
		return 1;

	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();

// drop the weapon down
	return 0;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()  player_axe1;
void()  player_axeb1;
void()  player_axec1;
void()  player_axed1;
void()  player_shot1;
void()  player_nail1;
void()  player_light1;
void()  player_rocket1;

//void (vector org, entity death_owner) spawn_tdeath;	//team

void() W_Attack =
{
	local   float   r;

//team
	if (self.k_accepted != 2) {
		if(time > (self.k_msgcount + 2)) {
			self.classname = "";
			stuffcmd(self, "disconnect\n");
			self.k_msgcount = time;
		}
		return;
	}
//team
	if (!W_CheckNoAmmo ())
		return;

	self.lastwepfired = self.weapon;
//team
	if (self.k_666 && !(self.weapon == 4096 || self.weapon == 1)) {
		self.items = self.items - (self.items & 1048576);
		self.invincible_time = 0;
		self.invincible_finished = 0;
		self.k_666 = 0;
	}
//team

	makevectors     (self.v_angle);                 // calculate forward angle for velocity
	self.show_hostile = time + 1;   // wake monsters up

	if (self.weapon == 4096)
	{
		self.attack_finished = time + 0.5;
		sound (self, 1, "weapons/ax1.wav", 1, 1);
		r = random();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();
	}
	else if (self.weapon == 1)
	{
		player_shot1 ();
		self.attack_finished = time + 0.5;
		W_FireShotgun ();

	}
	else if (self.weapon == 2)
	{
		player_shot1 ();
		self.attack_finished = time + 0.7;
		W_FireSuperShotgun ();

	}
	else if (self.weapon == 4)
	{
		player_nail1 ();
	}
	else if (self.weapon == 8)
	{
		player_nail1 ();
	}
	else if (self.weapon == 16)
	{
		player_rocket1();
		self.attack_finished = time + 0.6;
		W_FireGrenade();
	}
	else if (self.weapon == 32)
	{
		player_rocket1();
		self.attack_finished = time + 0.8;
		W_FireRocket();
	}
	else if (self.weapon == 64)
	{
		self.attack_finished = time + 0.1;
		sound (self, 0, "weapons/lstart.wav", 1, 1);
		player_light1();
	}
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local   float   it, am, fl;

	it = self.items;
	am = 0;

	if (self.impulse == 1)
	{
		fl = 4096;
	}
	else if (self.impulse == 2)
	{
		fl = 1;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (self.impulse == 3)
	{
		fl = 2;
		if (self.ammo_shells < 2)
			am = 1;
	}
	else if (self.impulse == 4)
	{
		fl = 4;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == 5)
	{
		fl = 8;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == 6)
	{
		fl = 16;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 7)
	{
		fl = 32;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 8)
	{
		fl = 64;
		if (self.ammo_cells < 1)
			am = 1;
	}

	self.impulse = 0;

	if (!(self.items & fl))
	{       // don't have the weapon or the ammo
		sprint (self, 2, "no weapon.\n");
		return;
	}

	if (am)
	{       // don't have the ammo
		sprint (self, 2, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	self.weapon = fl;
	W_SetCurrentAmmo ();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
//      if (deathmatch || coop)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.items = self.items |
		4096 |
		1 |
		2 |
		4 |
		8 |
		16 |
		32 |
		131072 | 262144;

	self.ammo_cells = 200;
	self.items = self.items | 64;

	self.weapon = 32;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local   float   it, am;

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == 64)
		{
			self.weapon = 4096;
		}
		else if (self.weapon == 4096)
		{
			self.weapon = 1;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == 1)
		{
			self.weapon = 2;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (self.weapon == 2)
		{
			self.weapon = 4;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == 4)
		{
			self.weapon = 8;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == 8)
		{
			self.weapon = 16;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == 16)
		{
			self.weapon = 32;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == 32)
		{
			self.weapon = 64;
			if (self.ammo_cells < 1)
				am = 1;
		}

		if ( (self.items & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};


/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local   float   it, am;

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == 64)
		{
			self.weapon = 32;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == 32)
		{
			self.weapon = 16;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == 16)
		{
			self.weapon = 8;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == 8)
		{
			self.weapon = 4;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == 4)
		{
			self.weapon = 2;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (self.weapon == 2)
		{
			self.weapon = 1;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == 1)
		{
			self.weapon = 4096;
		}
		else if (self.weapon == 4096)
		{
			self.weapon = 64;
			if (self.ammo_cells < 1)
				am = 1;
		}

		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};


/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};

/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	local float f1;

// TEAM -->
        if (!self.impulse) return;

	f1 = CaptainImpulses();
	if(!f1) {
		self.impulse = 0;
		return;
	}
	if(f1 == 1) {
		CaptainPickPlayer();
		self.impulse = 0;
		return;
	}

        if (self.impulse >= 200 && !match_in_progress)
                SelectMap();
        else if (self.impulse == 103) ReportMe();

	else if(self.k_admin == 1 && self.impulse >= 1 && self.impulse <= 9) {
		AdminImpBot();
		self.impulse = 0;
		return;
	}
// <-- TEAM
	else if (self.impulse >= 1 && self.impulse <= 8)
                W_ChangeWeapon ();

	else if (self.impulse == 10)
		CycleWeaponCommand ();
	else if (self.impulse == 12)
		CycleWeaponReverseCommand ();
    else if (self.impulse == 100)
        Cmd_AddBot("heh", "3");
    else if (self.impulse == 101)
        Cmd_AddBot("heh2", "1");
    else if (self.impulse == 102)
        KickABot();

// TEAM -->
        else
		TeamCommands();
// <-- TEAM

	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
		return;

    if (self.impulse)
        ImpulseCommands();

// check for attack
	if (self.button0 && !intermission_running)
	{
		if((!stof(infokey(world, "k_prewar")) && match_in_progress != 2)
			|| match_in_progress == 1 || k_captains == 2) {
			stuffcmd(self, "bf\n");
			if(time > (self.k_msgcount + 2)) {
				sprint(self, 3, "console: you are not allowed to fire\n");
				self.k_msgcount = time;
			}
			return;
		}
		SuperDamageSound ();
		W_Attack ();
	}

};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, 4, "items/damage3.wav", 1, 1);
		}
	}
	return;
};
