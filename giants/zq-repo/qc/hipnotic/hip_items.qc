/*
	hip_items.qc

	hipnotic-specific items

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

/*QUAKED weapon_laser_gun
*/
void test_touch ()
{
}

void weapon_laser_gun ()
{
	if (deathmatch > 3) {
		remove (self);
		return;
	}

	precache_model ("progs/v_laserg.mdl");
	precache_model ("progs/g_laserg.mdl");
	precache_model ("progs/lasrspik.mdl");
	precache_sound ("hipweap/laserg.wav");
	precache_sound ("hipweap/laserric.wav");
        precache_sound ("enforcer/enfstop.wav");

	setmodel (self, "progs/g_laserg.mdl");
	self.weapon = 3;	// mmm
	self.netname = "Laser cannon";
//	self.touch = weapon_touch;
	self.touch = test_touch;
	setsize (self, '-16 -16 0', '16 16 56');

	StartItem ();
}

void weapon_proximity_gun ()
{
	if (deathmatch > 3) {
		remove (self);
		return;
	}

	precache_model ("progs/v_prox.mdl");
	precache_model ("progs/proxbomb.mdl");

	precache_model ("progs/g_prox.mdl");
	setmodel (self, "progs/g_prox.mdl");
	self.weapon = 3;	// mmm
	self.netname = "Proximity gun";
//	self.touch = weapon_touch;
	self.touch = test_touch;
	setsize (self, '-16 -16 0', '16 16 56');

	StartItem ();
}

void weapon_mjolnir ()
{
	if (deathmatch > 3) {
		remove (self);
		return;
	}

	precache_model ("progs/v_hammer.mdl");

	precache_model ("progs/g_hammer.mdl");
	setmodel (self, "progs/g_hammer.mdl");
	self.weapon = 3;	// mmm
	self.netname = "Mjolnir";
//	self.touch = weapon_touch;
	self.touch = test_touch;
	setsize (self, '-16 -16 0', '16 16 56');

	StartItem ();
}



void item_artifact_wetsuit ()
{
	if (deathmatch > 3) {
		remove (self);
		return;
	}

	precache_model ("progs/wetsuit.mdl");
	setmodel (self, "progs/wetsuit.mdl");

	StartItem ();
}


void item_artifact_empathy_shields ()
{
	if (deathmatch > 3) {
		remove (self);
		return;
	}

	precache_model ("progs/empathy.mdl");
	setmodel (self, "progs/empathy.mdl");

	StartItem ();
}

