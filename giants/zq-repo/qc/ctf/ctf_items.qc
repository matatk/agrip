/*
	ctf_items.qc

	ctf item functions

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

void flag_touch ()
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	//TODO: modify checks only allowed to capture on team flag if its at the
	//base (not in the field)
	if ((other.items & IT_KEY1) | (other.items & IT_KEY2))
	{
// CAPTURE FLAG -->
		sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
		stuffcmd (other, "bf\n");
		other.items = other.items - (other.items & (IT_KEY1 | IT_KEY2));
		bprint (PRINT_LOW, other.netname, " captured ", self.netname, "!\n");
		//TODO: add 10 to team score
		self.nextthink = time + 0.2;
		self.think = SUB_regen;
// <-- CAPTURE FLAG
	}
	else if (other.enemy_flag & self.items)
	{
// PICKUP FLAG -->
		self.mdl = self.model;

		sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
		stuffcmd (other, "bf\n");
		self.solid = SOLID_NOT;
		other.items = other.items | self.items;
		self.model = "";
	
		bprint (PRINT_LOW, other.netname, " took ", self.netname, "!\n");
		sprint (other, PRINT_LOW, "You got the enemy flag!\nTake it back to your capture point!`\n");

		activator = other;
		SUB_UseTargets();                               // fire all targets / killtargets
// <-- PICKUP_FLAG
	}

}

void flag_drop ()
{
	entity	item;

	item = spawn();
	item.origin = self.origin;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);

	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/flag.mdl");
	setsize (item, '-16 -16 -24', '16 16 64');
	item.cnt = time + 30;
	item.touch = flag_touch;
	item.nextthink = time + 30;    // remove it if not touched for 30 secs
	item.think = SUB_Remove;
}

void flag_return ()
{

}

void flag_respawn ()
{

}

/*QUAKED item_flag_team1
*/
void item_flag_team1 ()
{
	precache_model ("progs/flag.mdl");
	setmodel (self, "progs/flag.mdl");

	setsize(self, '-16 -16 -24', '16 16 64');
	StartItem ();

	self.effects = self.effects | EF_RED;
	self.items = IT_KEY2;
	self.netname = "red's flag";
	precache_sound2 ("misc/basekey.wav");
	self.noise = "misc/basekey.wav";
	self.touch = flag_touch;
	self.skin = 0;
}

/*QUAKED item_flag_team2
*/
void item_flag_team2 ()
{
	precache_model ("progs/flag.mdl");
	setmodel (self, "progs/flag.mdl");

	setsize(self, '-16 -16 -24', '16 16 64');
	StartItem();

	self.effects = self.effects | EF_BLUE;
	self.items = IT_KEY1;
	self.netname = "blue's flag";
	precache_sound2 ("misc/basekey.wav");
	self.noise = "misc/basekey.wav";
	self.touch = flag_touch;
	self.skin = 1;
}

/*QUAKED item_player_team1
*/
void info_player_team1 ()
{

}

/*QUAKED item_player_team2
*/
void info_player_team2 ()
{

}

