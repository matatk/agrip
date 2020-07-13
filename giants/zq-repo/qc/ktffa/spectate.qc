/*
	spectate.qc

	spectator functions

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
// Added Aug11'97 by Zoid <zoid@idsoftware.com>
//
// These functions are called from the server if they exist.
// Note that Spectators only have one think since they movement code doesn't
// track them much.  Impulse commands work as usual, but don't call
// the regular ImpulseCommand handler in weapons.qc since Spectators don't
// have any weapons and things can explode.
//
//   --- Zoid.

/*
===========
SpectatorConnect

called when a spectator connects to a server
============
*/
void SpectatorConnect ()
{
	string s;

	bprint (PRINT_MEDIUM, "Spectator ", self.netname, " entered the game\n");

#ifdef KTFFA
	sprint(self, 2, "Welcome to ÀÔÌ‚·Ù ‘Â·ÌÛ ≤Æ≤ ∆∆¡ mod\nType „ÔÌÌ·Ó‰Û for help\n");

	stuffcmd(self, "alias join \"impulse ");
	s = ftos(KT_IMPULSE_VOTE_CHANGE);
	stuffcmd(self, s);
	stuffcmd(self.owner, "\"\nalias scores \"impulse ");
	s = ftos(KT_IMPULSE_PRINT_SCORES);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias commands \"impulse ");
	s = ftos(KT_IMPULSE_PRINT_CMDS);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias about \"impulse ");
	s = ftos(KT_IMPULSE_PRINT_VERSION);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\n");
#endif

	self.goalentity = world; // used for impulse IMPULSE_AXE below
}

/*
===========
SpectatorDisconnect

called when a spectator disconnects from a server
============
*/
void SpectatorDisconnect ()
{
	bprint (PRINT_MEDIUM, "Spectator ", self.netname, " left the game\n");
}

/*
================
SpectatorImpulseCommand

Called by SpectatorThink if the spectator entered an impulse
================
*/
void SpectatorImpulseCommand ()
{
	if (self.impulse == IMPULSE_AXE) {
		// teleport the spectator to the next spawn point
		// note that if the spectator is tracking, this doesn't do
		// much
		self.goalentity = find(self.goalentity, classname, "info_player_deathmatch");
		if (self.goalentity == world)
			self.goalentity = find(self.goalentity, classname, "info_player_deathmatch");
		if (self.goalentity != world) {
			setorigin(self, self.goalentity.origin);
			self.angles = self.goalentity.angles;
			self.fixangle = true;           // turn this way immediately
		}
	}
#ifdef KTFFA
	else if(self.impulse == KT_IMPULSE_VOTE_CHANGE) stuffcmd(self, "spectator 0; wait; wait; reconnect\n");
	else if(self.impulse == KT_IMPULSE_PRINT_SCORES) PrintScores();
	else if(self.impulse == KT_IMPULSE_PRINT_CMDS) PrintSCommands();
	else if(self.impulse == KT_IMPULSE_PRINT_VERSION) ShowVersion();
#endif
	self.impulse = IMPULSE_NONE;
}

/*
================
SpectatorThink

Called every frame after physics are run
================
*/
void SpectatorThink ()
{
	// self.origin, etc contains spectator position, so you could
	// do some neat stuff here

	if (self.impulse)
		SpectatorImpulseCommand();
}
