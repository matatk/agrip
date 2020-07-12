/*
	hip_breakwall.qc

	breakable (self-removing) walls

	Copyright (C) 2004  Anton 'Tonik' Gavrilov

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

//============================================================================

/*QUAKED func_breakawaywall
*/
void func_breakawaywall ()
{
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.model);
	self.use = SUB_Remove;
}

//============================================================================

void damagethreshold_die ()
{
	SUB_UseTargets ();
	remove (self);
}

/*QUAKED trigger_damagethreshold
1 multi_use	(TODO)
2 invisible
*/
void trigger_damagethreshold ()
{
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.model);

	if (self.spawnflags & 2)
		self.model = "";

	self.takedamage = DAMAGE_YES;
	self.th_die = damagethreshold_die;
}

//============================================================================

void rubble_touch ()
{
	self.movetype = MOVETYPE_TOSS;	// FIXME, don't bother?
}

void rubble_use ()
{
	float i, rnum;
	entity e;

	sound (self, CHAN_AUTO, "misc/shortexp.wav", 1, ATTN_NORM);

	i = 0;
	do
	{
		e = spawn ();

		e.origin = self.origin;

		if (self.classname == "rubble1")
			e.model = "progs/rubble1.mdl";
		else if (self.classname == "rubble2")
			e.model = "progs/rubble2.mdl";
		else if (self.classname == "rubble3")
			e.model = "progs/rubble3.mdl";
		else
		{
			rnum = random() * 3;
			if (rnum < 1)
				e.model = "progs/rubble1.mdl";
			else if (rnum < 2)
				e.model = "progs/rubble2.mdl";
			else
				e.model = "progs/rubble3.mdl";
		}

		e.velocity_x = crandom() * 100;
		e.velocity_y = crandom() * 100;
		e.velocity_z = random() * 150;
		e.avelocity_x = crandom() * 500;
		e.avelocity_y = crandom() * 500;
		e.avelocity_z = crandom() * 500;

		e.movetype = MOVETYPE_BOUNCE;
		e.touch = rubble_touch;

		self.think = SUB_Remove;
		self.nextthink = time + 30 + crandom() * 30;

		setmodel (e, e.model);
		setorigin (e, e.origin);

		i = i + 1;
	} while (i < self.count);
}

void func_rubble ()
{
	self.classname = "rubble";
	precache_model ("progs/rubble1.mdl");
	precache_model ("progs/rubble2.mdl");
	precache_model ("progs/rubble3.mdl");
	precache_sound ("misc/shortexp.wav");
	self.use = rubble_use;
}

void func_rubble1 ()
{
	self.classname = "rubble1";
	precache_model ("progs/rubble1.mdl");
	precache_sound ("misc/shortexp.wav");
	self.use = rubble_use;
}

void func_rubble2 ()
{
	self.classname = "rubble2";
	precache_model ("progs/rubble2.mdl");
	precache_sound ("misc/shortexp.wav");
	self.use = rubble_use;
}

void func_rubble3 ()
{
	self.classname = "rubble3";
	precache_model ("progs/rubble3.mdl");
	precache_sound ("misc/shortexp.wav");
	self.use = rubble_use;
}

//============================================================================

void exploder_fire ()
{
	T_RadiusDamage (self, world, self.dmg, world, "exploder");

	/// FIXME, draw sprite without particles unless requested by spawnflags

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", self.volume, self.speed);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	SUB_UseTargets ();

	remove (self);
}

void exploder_delayed_use ()
{
	self.think = exploder_fire;
	self.nextthink = time + self.delay;
}

/*QUAKEED func_exploder
dmg			default 120
volume		1
speed		attenuation, default 1
delay
spawnflags	& particles (1?)
*/
void func_exploder ()
{
	if (!self.dmg)
		self.dmg = 120;
	if (!self.volume)
		self.volume = 1;
	if (!self.speed)
		self.speed = ATTN_NORM;

	if (self.delay)
		self.use = exploder_delayed_use;
	else
		self.use = exploder_fire;
}


//============================================================================

