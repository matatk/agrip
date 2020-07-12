/*
	commands.qc

	user commands

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


void Cmd_Give ()
{
	string item;
	float	am;

	if (!infokey(world, "*cheats")) {
		sprint (self, PRINT_HIGH, "Cheats are not allowed on this server\n");
		return;
	}

	if (argc() < 2)
		return;

	item = argv(1);
	if (argc() >= 3)
		am = stof(argv(2));
	else
		am = 100;

	if (item == "2")
		self.items = self.items | IT_SHOTGUN;
	else if (item == "3")
		self.items = self.items | IT_SUPER_SHOTGUN;
	else if (item == "4")
		self.items = self.items | IT_NAILGUN;
	else if (item == "5")
		self.items = self.items | IT_SUPER_NAILGUN;
	else if (item == "6")
		self.items = self.items | IT_GRENADE_LAUNCHER;
	else if (item == "7")
		self.items = self.items | IT_ROCKET_LAUNCHER;
	else if (item == "8")
		self.items = self.items | IT_LIGHTNING;
	else if (item == "s" || item == "shells")
		self.ammo_shells = am;
	else if (item == "n" || item == "nails")
		self.ammo_nails = am;
	else if (item == "r" || item == "rockets")
		self.ammo_rockets =am;
	else if (item == "c" || item == "cells")
		self.ammo_cells = am;
	else if (item == "h" || item == "health") {
		self.health = am;
	}
	else if (item == "ga") {
		self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
		if (am > 0) {
			self.items = self.items | IT_ARMOR1;
			self.armorvalue = am;
			self.armortype = 0.3;
		}
		else
			self.armorvalue = 0;
	}
	else if (item == "ya") {
		if (argc() < 3)
			am = 150;
		self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
		if (am > 0) {
			self.items = self.items | IT_ARMOR2;
			self.armorvalue = am;
			self.armortype = 0.6;
		}
		else
			self.armorvalue = 0;
	}
	else if (item == "ra") {
		if (argc() < 3)
			am = 200;
		self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
		if (am > 0) {
			self.items = self.items | IT_ARMOR3;
			self.armorvalue = am;
			self.armortype = 0.8;
		}
		else
			self.armorvalue = 0;
	}
	else if (item == "quad") {
		self.items = self.items | IT_QUAD;
		self.super_time = 0;
		self.super_damage_finished = time + 30;
	}
	else if (item == "key1")
		self.items = self.items | IT_KEY1;
	else if (item == "key2")
		self.items = self.items | IT_KEY2;
	else if (item == "rune")
		serverflags = (serverflags * 2 + 1) & 15;
	else if (item == "all") {
		self.items = self.items | IT_ALL_WEAPONS | IT_KEY1 | IT_KEY2;
		self.ammo_shells = 100;
		self.ammo_nails = 200;
		self.ammo_rockets = 100;
		self.ammo_cells = 100;
		if (self.health < 100)
			self.health = 100;
		self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + IT_ARMOR3;
		self.armortype = 0.8;
		self.armorvalue = 200;
	}
	else {
		sprint (self, PRINT_HIGH, "no such item: ", item, "\n");
	}
}


void Cmd_God ()
{
	if (infokey(world, "*cheats") == "") {
		sprint (self, PRINT_HIGH, "Cheats are not allowed on this server\n");
		return;
	}

	if (self.flags & FL_GODMODE)
	{
		self.flags = self.flags - FL_GODMODE;
		sprint (self, PRINT_HIGH, "godmode OFF\n");
	}
	else
	{
		self.flags = self.flags | FL_GODMODE;
		sprint (self, PRINT_HIGH, "godmode ON\n");
	}
}

void Cmd_Observe ()
{
	entity spot;

	if (infokey(self, "*spectator") != "")
		return;

	if (!deathmatch && !coop) {
		sprint (self, PRINT_HIGH, "This command is disabled in single player mode\n");
		return;
	}

	ClientDisconnect ();

	setinfo(self, "*spectator", "1");
	self.movetype = MOVETYPE_NOCLIP;
	self.view_ofs = '0 0 22';
	self.fixangle = true;
	spot = find (world, classname, "info_player_start");
	self.origin = spot.origin;
	self.angles = spot.angles;

	SpectatorConnect ();
}

void Cmd_Join ()
{
	if (infokey(self, "*spectator") == "")
		return;

	if (!deathmatch && !coop) {
		sprint (self, PRINT_HIGH, "This command is disabled in single player mode\n");
		return;
	}

	SpectatorDisconnect ();
	setinfo(self, "*spectator", "");
	ClientConnect ();
	PutClientInServer ();
}


/*
** ZQ_CLIENTCOMMAND extension
*/
void GE_ClientCommand (string cmd, string cmdline)
{
	if (cmd == "give")
		Cmd_Give ();
	else if (cmd == "god")
		Cmd_God ();
	else if (cmd == "join")
		Cmd_Join ();
	else if (cmd == "observe")
		Cmd_Observe ();
	else
		return false;

	return true;
}
