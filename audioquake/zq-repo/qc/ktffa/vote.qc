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
// vote.q: mapchange voting functions

void NextLevel ();

float CountPlayers ()
{
	entity p;
	float num;

	num = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "") num = num + 1;
		p = find(p, classname, "player");
	}
	return num;
}

void VoteThink ()
{
	entity p;

	bprint(2, "The voting has timed out.\n");
	self.nextthink = -1;
	k_vote = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "") p.k_voted = 0;
		p = find(p, classname, "player");
	}
	remove(self);
}

void VoteChange ()
{
	float f1;
	string tmp;
	entity voteguard;

	if(k_vote) return;

	f1 = CountPlayers();
	if(f1 == 1) {
		bprint(2, self.netname);
		bprint(2, " changes map\n");
		NextLevel();
		return;	// in case we get back here
	}

	bprint(2, self.netname);
	bprint(2, " votes for mapchange\n");
	tmp = ftos(floor(f1 / 2));
	bprint(2, "", tmp, "‘ total vote");
	if(tmp != "1") bprint(2, "s");
	bprint(2, " needed\nType ");
	bprint(3, "yes");
	bprint(2, " in console to approve\n");

	k_vote = 1;
	self.k_voted = 1;
	voteguard = spawn(); // Check the 1 minute timeout for voting
	voteguard.owner = world;
	voteguard.classname = "voteguard";
	voteguard.think = VoteThink;
	voteguard.nextthink = time + 30;
}

void VoteYes ()
{
	float f1, f2;
	string tmp;
	entity p;

	if(!k_vote) return;

	if(self.k_voted) {
		sprint(self, 2, "--- your vote is still good ---\n");
		return;
	}

// register the vote
	k_vote = k_vote + 1;
	bprint(2, self.netname);
	bprint(2, " votes for mapchange\n");
	f1 = CountPlayers();
	f2 = (floor(f1 / 2)) + 1;
	if(k_vote >= f2) {
		bprint(3, "Map changed by majority vote\n");
		k_vote = 0;
		p = find(world, classname, "player");
		while(p != world) {
			if(p.netname != "") p.k_voted = 0;
			p = find(p, classname, "player");
		}
		p = find(world, classname, "voteguard");
		if(p != world) {
			p.classname = "";
			remove(p);
		}
		NextLevel();
		return;
	}

// calculate how many more votes are needed
	self.k_voted = 1;
	f1 = f2 - k_vote;
	tmp = ftos(f1);
	bprint(2, "", tmp, "‘ more vote");
	if(f1 > 1) bprint(2, "s");
	bprint(2, " needed\n");
}

void VoteNo()
{
	entity p;
	float f1, f2;
	string tmp;

// withdraw one's vote
	if(!k_vote || !self.k_voted) return;

	bprint(2, self.netname);
	bprint(2, " would rather play this map\n");
	self.k_voted = 0;
	k_vote = k_vote - 1;
	if(!k_vote) {
		bprint(3, "Voting is closed\n");
		p = find(world, classname, "voteguard");
		if(p != world) {
			p.classname = "";
			remove(p);
		}
		return;
	}
	f1 = CountPlayers();
	f2 = (floor(f1 / 2)) + 1;
	f1 = f2 - k_vote;
	tmp = ftos(f1);
	bprint(2, "");
	bprint(2, tmp);
	bprint(2, "‘ more vote");
	if(f1 > 1) bprint(2, "s");
	bprint(2, " needed\n");
}
