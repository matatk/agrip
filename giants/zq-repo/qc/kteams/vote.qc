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
// vote.q: election functions by rc\sturm

float() CountPlayers;
float() CountRTeams;
void() AdminMatchStart;
void() AdminForcePause;
void() StopTimer;
void() NextLevel;
void() BeginPicking;

// AbortElect is used to terminate the voting
// Important if player to be elected disconnects or levelchange happens
void() AbortElect =
{
	local entity p;

// k_velect for election vote counter
	k_velect = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "") {
			p.k_vote2 = 0;
			if(p.k_admin == 1.5) p.k_admin = 0;
			if(p.k_captain > 10) {
				p.k_captain = 0;
				k_captains = floor(k_captains);
			}
		}
		p = find(p, classname, "player");
	}
	p = find(world, classname, "spectator");
	while(p != world)
	{
		if(p.netname != "" && p.k_admin == 1.5)	p.k_admin = 0;
		p = find(p, classname, "spectator");
	}

	p = find(world, classname, "electguard");
// Kill timeout checker entity
	if(p.classname == "electguard") remove(p);
};

void() ElectThink =
{
	bprint(2, "The voting has timed out.\nElection aborted\n");
	self.nextthink = -1;
	AbortElect();
};

void() VoteAdmin =
{
	local entity electguard;

// Check if voteadmin is allowed
	if(!stof(infokey(world, "k_allowvoteadmin"))) {
		sprint(self, 2, "Admin election is not allowed on this server.\n");
		return;
	}
// Can't allow election and code entering for the same person at the same time
	if(self.k_admin == 1) {
		sprint(self, 2, "Finish entering the code first\n");
		return;
	}
	if(self.k_admin == 2) {
		sprint(self, 2, "You are already an admin\n");
		return;
	}
	if(self.k_admin == 1.5) {
		bprint(2, self.netname, " aborts election!");
		bprint(3, "\n");
		AbortElect();
		return;
	}
// Only one election per server because otherwise we wouldn't know how to count
// "yes"s or "no"s
	if(k_velect) {
		sprint(self, 2, "An election is already in progress\n");
		return;
	}
	if(!stof(infokey(world, "k_admins"))) {
		sprint(self, 2, "NO ADMINS ON THIS SERVER!\n");
		return;
	}
	if(self.classname == "spectator" && match_in_progress)
		return;

	bprint(2, self.netname, " has requested admin rights!\nType ");
	bprint(3, "yes");
	bprint(2, " in console to approve\n");
	self.k_admin = 1.5;
	k_velect = 1;
	sprint(self, 2, "Type εμεγτ to abort election\n");
	electguard = spawn(); // Check the 1 minute timeout for election
	electguard.owner = world;
	electguard.classname = "electguard";
	electguard.think = ElectThink;
	electguard.nextthink = time + 60;
};

void() VoteYes =
{
	local float f1, f2;
	local string tmp;
	local entity p;

	if(!k_velect) return;
	if(self.k_admin == 1.5 || self.k_captain > 10) {
		sprint(self, 2, "You cannot vote for yourself\n");
		return;
	}
	if(self.k_vote2) {
		sprint(self, 2, "--- your vote is still good ---\n");
		return;
	}
// register the vote
	k_velect = k_velect + 1;
	bprint(2, self.netname, " gives ");
	if(infokey(self, "gender") == "f") bprint(2, "her");
		else bprint(2, "his");
	bprint(2, " vote\n");
	f1 = CountPlayers();
	f2 = (floor(f1 / 2)) + 1;
	if(k_velect >= f2) {
		p = find(world, classname, "player");
		while(p.k_admin != 1.5 && p.k_captain < 10) p = find(p, classname, "player");
		if(p.k_admin == 1.5) {
// s: election was admin election
			bprint(2, p.netname, " ηαιξσ αδνιξ στατυσ!");
			bprint(3, "\n");
			sprint(p, 2, "Please give up admin rights when you're done.\n");
			sprint(p, 2, "Type γονναξδσ for info\n");
			p.k_admin = 2;
		}
		if(p.k_captain > 10) {
// s: election was captain election
			p.k_captain = p.k_captain - 10;
			k_captains = floor(k_captains) + 1;
			bprint(2, p.netname, " becomes a ");
			bprint(3, "captain\n");

// s: if both captains are already elected, start choosing players
			if(k_captains == 2) BeginPicking();
			else bprint(2, "One more γαπταιξ should be elected\n");
		}
		AbortElect();
		return;
	}
// calculate how many more votes are needed
	self.k_vote2 = 1;
	f1 = f2 - k_velect;
	tmp = ftos(f1);
	bprint(2, "", tmp, "‘ more vote");
	if(f1 > 1) bprint(2, "s");
	bprint(2, " needed\n");
};

void() VoteNo =
{
	local float f1, f2;
	local string tmp;

// withdraw one's vote
	if(!k_velect || self.k_admin == 1.5 || !self.k_vote2) return;
	bprint(2, self.netname, " withdraws ");
	if(infokey(self, "gender") == "f") bprint(2, "her");
		else bprint(2, "his");
	bprint(2, " vote\n");
	self.k_vote2 = 0;
	k_velect = k_velect - 1;
	f1 = CountPlayers();
	f2 = (floor(f1 / 2)) + 1;
	f1 = f2 - k_velect;
	tmp = ftos(f1);
	bprint(2, "", tmp, "‘ more vote");
	if(f1 > 1) bprint(2, "s");
	bprint(2, " needed\n");
};
