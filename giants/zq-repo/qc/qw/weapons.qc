/*
	weapons.qc

	weapon and weapon hit functions

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

// constants for the impulse command
const float  IMPULSE_WEAPON_FIRST             =   1;
const float  IMPULSE_AXE                      =   1;
const float  IMPULSE_SHOTGUN                  =   2;
const float  IMPULSE_SUPER_SHOTGUN            =   3;
const float  IMPULSE_NAILGUN                  =   4;
const float  IMPULSE_SUPER_NAILGUN            =   5;
const float  IMPULSE_GRENADE_LAUNCHER         =   6;
const float  IMPULSE_ROCKET_LAUNCHER          =   7;
const float  IMPULSE_LIGHTNING                =   8;
const float  IMPULSE_WEAPON_LAST              =   8;
const float  IMPULSE_CHEAT                    =   9;
const float  IMPULSE_WEAPONCYCLE_F            =  10;
const float  IMPULSE_CHEAT_SERVERFLAGS        =  11;
const float  IMPULSE_WEAPONCYCLE_R            =  12;

#ifdef FRIKBOT
const float  IMPULSE_ADDBOT                   = 100;
const float  IMPULSE_REMOVEBOT                = 101;
#endif

void T_Damage (entity targ, entity inflictor, entity attacker, float damage);
void player_run ();
void T_RadiusDamage (entity bomb, entity attacker, float rad, entity ignore, string dtype);
void SpawnBlood (vector org, float damage);
void SuperDamageSound ();


// called by worldspawn
void W_Precache ()
{
	precache_sound ("weapons/r_exp3.wav");		// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");		// player shotgun
	precache_sound ("weapons/ric1.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");		// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");		// super spikes
	precache_sound ("weapons/tink1.wav");		// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");		// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");		// super shotgun
}

float crandom ()
{
	return 2*(random() - 0.5);
}

/*
================
W_FireAxe
================
*/
void W_FireAxe ()
{
	vector	source;
	vector	org;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, false, self);
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
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);

		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_GUNSHOT);
		WriteByte (MSG_MULTICAST, 3);
		WriteCoord (MSG_MULTICAST, org_x);
		WriteCoord (MSG_MULTICAST, org_y);
		WriteCoord (MSG_MULTICAST, org_z);
		multicast (org, MULTICAST_PVS);
	}
}


//============================================================================


vector wall_velocity ()
{
	vector	vel;

	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	return vel;
}


/*
================
SpawnMeatSpray
================
*/
void SpawnMeatSpray (vector org, vector vel)
{
	entity	missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';

// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (missile, org);
}

/*
================
SpawnBlood
================
*/
void SpawnBlood (vector org, float damage)
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_BLOOD);
	WriteByte (MSG_MULTICAST, 1);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	multicast (org, MULTICAST_PVS);
}

/*
================
spawn_touchblood
================
*/
void spawn_touchblood (float damage)
{
	vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, damage);
}

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

vector	blood_org;
float	blood_count;

vector	puff_org;
float	puff_count;

void ClearMultiDamage ()
{
	multi_ent = world;
	multi_damage = 0;
	blood_count = 0;
	puff_count = 0;
}

void ApplyMultiDamage ()
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
}

void AddMultiDamage (entity hit, float damage)
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
}

void Multi_Finish ()
{
	if (puff_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_GUNSHOT);
		WriteByte (MSG_MULTICAST, puff_count);
		WriteCoord (MSG_MULTICAST, puff_org_x);
		WriteCoord (MSG_MULTICAST, puff_org_y);
		WriteCoord (MSG_MULTICAST, puff_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}

	if (blood_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_BLOOD);
		WriteByte (MSG_MULTICAST, blood_count);
		WriteCoord (MSG_MULTICAST, blood_org_x);
		WriteCoord (MSG_MULTICAST, blood_org_y);
		WriteCoord (MSG_MULTICAST, blood_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}
}

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
void TraceAttack (float damage, vector dir)
{
	vector	vel, org;

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
}

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void FireBullets (float shotcount, vector dir, vector spread)
{
	vector	direction;
	vector	src;

	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	traceline (src, src + dir*2048, false, self);
	puff_org = trace_endpos - dir*4;

	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		traceline (src, src + direction*2048, false, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
	Multi_Finish ();
}

/*
================
W_FireShotgun
================
*/
void W_FireShotgun ()
{
	vector	dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	if (deathmatch != 4 )
		self.currentammo = self.ammo_shells = self.ammo_shells - 1;

	dir = aim (self, 100000);
	FireBullets (6, dir, '0.04 0.04 0');
}


/*
================
W_FireSuperShotgun
================
*/
void W_FireSuperShotgun ()
{
	vector	dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}

	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_BIGKICK);

	if (deathmatch != 4)
		self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 100000);
	FireBullets (14, dir, '0.14 0.08 0');
}


/*
==============================================================================

ROCKETS

==============================================================================
*/

void T_MissileTouch ()
{
	float	damg;

//	if (deathmatch == 4)
//	{
//	if ( ((other.weapon == 32) || (other.weapon == 16)))
//		{
//			if (random() < 0.1)
//			{
//				if (other != world)
//				{
//	//				bprint (PRINT_HIGH, "Got here\n");
//					other.deathtype = "blaze";
//					T_Damage (other, self, self.owner, 1000 );
//					T_RadiusDamage (self, self.owner, 1000, other);
//				}
//			}
//		}
//	}

	if (other == self.owner)
		return;         // don't explode on owner

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (pointcontents(self.origin) == CONTENT_SKY)
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

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8 * normalize(self.velocity);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove(self);
}



/*
================
W_FireRocket
================
*/
void W_FireRocket ()
{
	if (deathmatch != 4)
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

// set newmis speed

	makevectors (self.v_angle);
	newmis.velocity = aim(self, 1000);
	newmis.velocity = newmis.velocity * 1000;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = T_MissileTouch;
	newmis.voided = 0;

// set newmis duration
	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.classname = "rocket";

	setmodel (newmis, "progs/missile.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, self.origin + v_forward * 8 + '0 0 16');
}

/*
===============================================================================
LIGHTNING
===============================================================================
*/

void LightningHit (entity from, float damage)
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNINGBLOOD);
	WriteCoord (MSG_MULTICAST, trace_endpos_x);
	WriteCoord (MSG_MULTICAST, trace_endpos_y);
	WriteCoord (MSG_MULTICAST, trace_endpos_z);
	multicast (trace_endpos, MULTICAST_PVS);

	T_Damage (trace_ent, from, from, damage);
}

/*
=================
LightningDamage
=================
*/
void LightningDamage (vector p1, vector p2, entity from, float damage)
{
	entity	e1, e2;
	vector	f;

	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, false, self);

	if (trace_ent.takedamage)
	{
		e1 = trace_ent;
		LightningHit (from, damage);

		if (self.classname == "player")
		{
			// check DM6 platform bug-o-feature
			if (self.groundentity == e1)
				if (e1.classname == "door")
					e1.velocity_z = e1.velocity_z + 400;
		}
	}

	traceline (p1 + f, p2 + f, false, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		e2 = trace_ent;
		LightningHit (from, damage);
	}

	traceline (p1 - f, p2 - f, false, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		LightningHit (from, damage);
	}
}


void W_FireLightning ()
{
	vector	org;
	float	cells;

	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
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
				T_RadiusDamage (self, self, 35*cells, world, "");
				return;
			}
		}
		else
		{
			cells = self.ammo_cells;
			self.ammo_cells = 0;
			W_SetCurrentAmmo ();
			T_RadiusDamage (self, self, 35*cells, world, "");
			return;
		}
	}

	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	if (deathmatch != 4)
		self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	org = self.origin + '0 0 16';

	traceline (org, org + v_forward*600, true, self);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNING2);
	WriteEntity (MSG_MULTICAST, self);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	WriteCoord (MSG_MULTICAST, trace_endpos_x);
	WriteCoord (MSG_MULTICAST, trace_endpos_y);
	WriteCoord (MSG_MULTICAST, trace_endpos_z);
	multicast (org, MULTICAST_PHS);

	LightningDamage (self.origin, trace_endpos + v_forward*4, self, 30);
}


//=============================================================================


void GrenadeExplode ()
{
	if (self.voided) {
		return;
	}
	self.voided = 1;

	T_RadiusDamage (self, self.owner, 120, world, "grenade");

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove (self);
}

void GrenadeTouch ()
{
	if (other == self.owner)
		return;			// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
}

/*
================
W_FireGrenade
================
*/
void W_FireGrenade ()
{
	vector	ang;

	if (deathmatch != 4)
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	newmis = spawn ();
	newmis.voided=0;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "grenade";

// set newmis speed

	if (self.v_angle_x)
	{
		ang = self.v_angle;
		// limit pitch in case the server allows pitch angles < -70,
		// so that grenades still go straight up and not behind
		if (ang_x < -70)
			ang_x = -70;
		makevectors (ang);

		newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	}
	else
	{	// assume the player is not using the mouse.	FIXME: remove?
		newmis.velocity = aim(self, 10000);
		newmis.velocity = newmis.velocity * 600;
		newmis.velocity_z = 200;
	}

	newmis.avelocity = '300 300 300';

	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = GrenadeTouch;

// set newmis duration
	newmis.nextthink = time + 2.5;

	if (deathmatch == 4)
	{
		self.attack_finished = time + 1.1;
		T_Damage (self, self, self.owner, 10 );
	}

	newmis.think = GrenadeExplode;

	setmodel (newmis, "progs/grenade.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, self.origin);
}


//=============================================================================

void spike_touch ();
void superspike_touch ();


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void launch_spike (vector org, vector dir)
{
	newmis = spawn ();
	newmis.voided=0;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);

	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
}


void W_FireSuperSpikes ()
{
	vector	dir;

	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	if (deathmatch != 4)
		self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);
}


void W_FireSpikes (float ox)
{
	vector	dir;

	makevectors (self.v_angle);

	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	if (deathmatch != 4)
		self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);
}


void spike_touch ()
{
	if (other == self.owner)
		return;

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (other.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
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
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		if (self.classname == "wizspike")
			WriteByte (MSG_MULTICAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_MULTICAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_MULTICAST, TE_SPIKE);
		WriteCoord (MSG_MULTICAST, self.origin_x);
		WriteCoord (MSG_MULTICAST, self.origin_y);
		WriteCoord (MSG_MULTICAST, self.origin_z);
		multicast (self.origin, MULTICAST_PHS);
	}

	remove(self);
}


void superspike_touch ()
{
	if (other == self.owner)
		return;

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (other.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
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
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_SUPERSPIKE);
		WriteCoord (MSG_MULTICAST, self.origin_x);
		WriteCoord (MSG_MULTICAST, self.origin_y);
		WriteCoord (MSG_MULTICAST, self.origin_z);
		multicast (self.origin, MULTICAST_PHS);
	}

	remove(self);
}


/*
// only works correctly for client entities!
float(entity ent) EntityNum =
{
	float num = 0;
	entity e;

	e = world;
	do {
		e = nextent(e);
		num = num + 1;
	} while (e != ent);

	return num;
}

void() W_FireRailgun =
{
	float entnum;
	vector org, pos, end;
	vector dir;
	entity ignore, old_ignore;

	makevectors(self.v_angle);

	dir = v_forward;

	org = self.origin + v_forward * 10 + '0 0 16';
	pos = org;
	end = org + v_forward*2048;

	ignore = old_ignore = self;

	do
	{
		traceline (pos, end, false, ignore);
		pos = trace_endpos;

		if (trace_ent == old_ignore || trace_ent == self) {
			// may happen if the entities are touching.
			// we don't want to apply damage twice or kill ourselves,
			// so move forward a little bit and retry
			pos = pos + dir;
		}
		else
		{
			// go right through all players and monsters,
			// but not through explosive boxes etc which are SOLID_BBOX
			if (trace_ent.solid == SOLID_SLIDEBOX) {
				old_ignore = ignore;
				ignore = trace_ent;
			}
			else
				ignore = world;

			if (trace_ent.takedamage) {
				T_Damage (trace_ent, self, self, 100);
			}
		}
	} while (ignore);

//	sound (self, CHAN_WEAPON, "weapons/railgun.wav", 1, ATTN_NORM);
	sound (self, CHAN_WEAPON, "weapons/lstart.wav", 1, ATTN_NORM);

	float color;
	color = floor(stof(infokey(self, "railcolor")));
	if (color < 1 || color > 7)
		color = 1;

	entnum = EntityNum(self);
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNING1);
	WriteShort (MSG_MULTICAST, -512 + (entnum - 1) * 8 + color);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	WriteCoord (MSG_MULTICAST, pos_x);
	WriteCoord (MSG_MULTICAST, pos_y);
	WriteCoord (MSG_MULTICAST, pos_z);
	multicast (org, MULTICAST_PHS);
}
*/


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void W_SetCurrentAmmo ()
{
	player_run ();		// get out of any weapon firing states

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );

	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
		self.weaponframe = 0;
#ifdef VWEP_TEST
        if(vw_available > 0)
            self.vw_index = 1;
#endif
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
#ifdef VWEP_TEST
        if(vw_available > 0)
            self.vw_index = 2;
#endif
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
#ifdef VWEP_TEST
        if(vw_available > 0)
            self.vw_index = 3;
#endif
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
#ifdef VWEP_TEST
        if(vw_available > 0)
            self.vw_index = 4;
#endif
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
#ifdef VWEP_TEST
        if(vw_available > 0)
            self.vw_index = 5;
#endif
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
#ifdef VWEP_TEST
        if(vw_available > 0)
            self.vw_index = 6;
#endif
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
#ifdef VWEP_TEST
        if(vw_available > 0)
            self.vw_index = 7;
#endif
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
#ifdef VWEP_TEST
        if(vw_available > 0)
            self.vw_index = 8;
#endif
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
}

float W_BestWeapon ()
{
	float	it;

	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
		return IT_LIGHTNING;
	else if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	else if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	else if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;
	else if(self.ammo_shells >= 1 && (it & IT_SHOTGUN)  )
		return IT_SHOTGUN;

/*
	if(self.ammo_rockets >= 1 && (it & IT_ROCKET_LAUNCHER) )
		return IT_ROCKET_LAUNCHER;
	else if(self.ammo_rockets >= 1 && (it & IT_GRENADE_LAUNCHER) )
		return IT_GRENADE_LAUNCHER;

*/

	return IT_AXE;
}

float W_CheckNoAmmo ()
{
	if (self.currentammo > 0)
		return true;

	if (self.weapon == IT_AXE)
		return true;

	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();

// drop the weapon down
	return false;
}

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void player_axe1 ();
void player_axeb1 ();
void player_axec1 ();
void player_axed1 ();
void player_shot1 ();
void player_nail1 ();
void player_light1 ();
void player_rocket1 ();

void W_Attack ()
{
	float	r;

	if (!W_CheckNoAmmo ())
		return;

	makevectors (self.v_angle);		// calculate forward angle for velocity
	self.show_hostile = time + 1;   // wake monsters up

	if (self.weapon == IT_AXE)
	{
		self.attack_finished = time + 0.5;
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
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
	else if (self.weapon == IT_SHOTGUN)
	{
		player_shot1 ();
		self.attack_finished = time + 0.5;
		W_FireShotgun ();
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1 ();
		self.attack_finished = time + 0.7;
		W_FireSuperShotgun ();
	}
	else if (self.weapon == IT_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		self.attack_finished = time + 0.6;
		W_FireGrenade();
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
		self.attack_finished = time + 0.8;
		W_FireRocket();
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.attack_finished = time + 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		player_light1();
/*
		player_shot1 ();
		self.attack_finished = time + 1.5;	// tune this!
		W_FireRailgun ();
*/
	}
}

/*
============
W_ChangeWeapon

============
*/
void W_ChangeWeapon ()
{
	float	it, am, fl;

	it = self.items;
	am = 0;

	if (self.impulse == IMPULSE_AXE)
	{
		fl = IT_AXE;
	}
	else if (self.impulse == IMPULSE_SHOTGUN)
	{
		fl = IT_SHOTGUN;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (self.impulse == IMPULSE_SUPER_SHOTGUN)
	{
		fl = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			am = 1;
	}
	else if (self.impulse == IMPULSE_NAILGUN)
	{
		fl = IT_NAILGUN;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == IMPULSE_SUPER_NAILGUN)
	{
		fl = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == IMPULSE_GRENADE_LAUNCHER)
	{
		fl = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == IMPULSE_ROCKET_LAUNCHER)
	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == IMPULSE_LIGHTNING)
	{
		fl = IT_LIGHTNING;
		if (self.ammo_cells < 1)
			am = 1;
	}

	self.impulse = 0;

	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
#ifndef AGRIP
		sprint (self, PRINT_HIGH, "no weapon.\n");
#else
		soundtoclient (self, self, CHAN_WEAPON, "deny.wav", 1, ATTN_NORM);
#endif
		return;
	}

	if (am)
	{	// don't have the ammo
#ifndef AGRIP
		sprint (self, PRINT_HIGH, "not enough ammo.\n");
#else
		soundtoclient (self, self, CHAN_WEAPON, "ammo-out.wav", 1, ATTN_NORM);
#endif
		return;
	}

//
// set weapon, set ammo
//
	self.weapon = fl;
	W_SetCurrentAmmo ();

#ifdef AGRIP
	snap_misc_weaponswitch();
#endif
}

/*
============
CheatCommand
============
*/
void CheatCommand ()
{
	if (!infokey(world, "*cheats"))
		return;

	self.ammo_shells = 100;
	self.ammo_nails = 200;
	self.ammo_rockets = 100;
	self.ammo_cells = 100;
	self.items = self.items |
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_LIGHTNING |
		IT_KEY1 | IT_KEY2;

	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
}

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void CycleWeaponCommand ()
{
	float	it, am;

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}

		if ( (self.items & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
#ifdef AGRIP
			snap_misc_weaponswitch();
#endif
			return;
		}
	}

}


/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void CycleWeaponReverseCommand ()
{
	float	it, am;

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}

		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
#ifdef AGRIP
			snap_misc_weaponswitch();
#endif
			return;
		}
	}
}


/*
============
ServerflagsCommand

Just for development
============
*/
void ServerflagsCommand ()
{
	if (!infokey(world, "*cheats"))
		return;

	serverflags = serverflags * 2 + 1;
}


/*
============
ImpulseCommands

============
*/
void ImpulseCommands ()
{
	if (self.impulse >= IMPULSE_WEAPON_FIRST && self.impulse <= IMPULSE_WEAPON_LAST)
		W_ChangeWeapon ();
	else if (self.impulse == IMPULSE_CHEAT)
		CheatCommand ();
	else if (self.impulse == IMPULSE_WEAPONCYCLE_F)
		CycleWeaponCommand ();
	else if (self.impulse == IMPULSE_CHEAT_SERVERFLAGS)
		ServerflagsCommand ();
	else if (self.impulse == IMPULSE_WEAPONCYCLE_R)
		CycleWeaponReverseCommand ();
#ifdef FRIKBOT
    else if (self.impulse == IMPULSE_ADDBOT)
        Cmd_AddBot("testbot", "2");
    else if (self.impulse == IMPULSE_REMOVEBOT)
        KickABot();
#endif

#ifdef AGRIP
	else
		agh_weapons_impulsecommands();
#endif

	self.impulse = 0;
}

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void W_WeaponFrame ()
{
	if (time < self.attack_finished)
		return;

	if (self.impulse)
		ImpulseCommands ();

// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
	}
}

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void SuperDamageSound ()
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
}
