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
// motd.qc

void() StuffAliases;
void() StuffCustomMaps;
void() StuffMapAliases;
float() CountPlayers;

void() MOTDThink =
{
	local string s1, s2;

	if(self.attack_finished < time || match_in_progress) {
		remove(self);
		return;
	}
	s1 = infokey(world, "k_motd1");
	s2 = infokey(world, "k_motd2");
	centerprint(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n€‚\n\nRunning Ëïíâáô Ôåáíó ²®²±\nby kemiKal, Cenobite, Sturm and Fang\nType \"ãïííáîäó\" for help");
	self.nextthink = time + 0.7;
};

void() SMOTDThink =
{
	local string s1, s2;

	if(self.attack_finished < time) {
		remove(self);
		return;
	}
	s1 = infokey(world, "k_motd1");
	s2 = infokey(world, "k_motd2");
	centerprint(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n€‚\n\nRunning Ëïíâáô Ôåáíó ²®²±\nby kemiKal, Cenobite, Sturm and Fang\nType \"ãïííáîäó\" for help");
	self.nextthink = time + 0.7;
};

void() MOTDThinkX2 =
{
	self.cnt = -1;
      self.think = StuffCustomMaps;
      self.nextthink = time + 1.5;
};

void() MOTDThinkX =
{
	local entity p;

// Kl33n3X check against Llamas
	stuffcmd(self.owner, "say -d\n");

	if(!self.owner.k_stuff) 
	{
		StuffAliases();
		p = self;
		self = self.owner;
		StuffMapAliases();
		self = p;
		p = spawn();
		p.classname = "motdX";
		p.owner = self.owner;
		p.think = MOTDThinkX2;
		p.nextthink = time + 2.7;
	}
	self.think = MOTDThink;
	self.nextthink = time + 0.3;
};

void() MOTDStuff =
{
	local entity p;
	local string t, t2, tmp, s1;
	local float kick, f1, f2, f3;

	self.owner.k_teamnum = 0;
	self.owner.k_msgcount = time;
	self.owner.k_lastspawn = world;

	if(self.owner.k_accepted != 2) self.owner.k_accepted = 1;

	// If the game is running already then . . .
	if(match_in_progress)
	{
		kick = 0;
		self.owner.ready = 1;
		self.owner.k_666 = 0;
		self.owner.k_vote = 0;
		self.owner.deaths = 0;
		self.owner.friendly = 0;
		if(lock == 2) kick = 1;

		else if(lock == 1) 
		{
			kick = 1;
			p = find(world, classname, "player");
			while(p != world && kick ==1) 
			{
				t = infokey(self.owner, "team");
				if(p != self.owner && p.netname != "" && infokey(p, "team") == t) 
				{
					kick = 0;
				}
				else
				{
				p = find(p, classname, "player");
				}
			}

			if(kick) 
			{
				p = find(world, classname, "ghost");
				while(p != world && kick ==1) 
				{
					t = ftos(p.k_teamnum);
					t2 = infokey(world, t);
					t = infokey(self.owner, "team");
					if(t == t2) 
					{
						kick = 0;
					}
					else
					{
						p = find(p, classname, "ghost");
					}
				}
			}
		}

		if(lock == 1 && kick == 1) sprint(self.owner, 2, "Set your team before connecting\n");

		else 
		{
			f2 = CountPlayers();
			if(f2 >= k_attendees && stof(infokey(world, "k_exclusive"))) 
			{
				sprint(self.owner, 2, "Sorry, all teams are full\n");
				kick = 1;
			}
		}

		if(kick) 
		{
			self.owner.k_accepted = 0;
			if(lock == 2) sprint(self.owner, 2, "Match in progress, server locked\n");
			self.owner.classname = "";
                        stuffcmd(self.owner, "wait;wait;wait;wait;wait;wait;wait;disconnect\n");
			remove(self);
			return;
		}
	}

	if(match_in_progress == 2) 
	{
		f2 = 1;
		f3 = 0;
		while(f2 < k_userid && !f3)
		{
			t2 = ftos(f2);
			t = infokey(world, t2);
			if(t == self.owner.netname) f3 = 1;
			else f2 = f2 + 1;
		}
		if(f2 == k_userid) 
		{
			t2 = infokey(self.owner, "team");
			bprint(2, self.owner.netname, " arrives late ", t2, "‘\n");
		} 
		else 
		{
			p = find(world, classname, "ghost");
			while(p != world && f3) 
			{
				if(p.cnt2 == f2) f3 = 0;
				else p = find(p, classname, "ghost");
			}

			if(p != world) 
			{
				t = ftos(p.k_teamnum);
				t2 = infokey(world, t);
				t = infokey(self.owner, "team");
				if(t != t2) 
				{
					self.owner.k_accepted = 0;
					sprint(self.owner, 2, "Please join your old team and reconnect\n");
					self.owner.classname = "";
                                        stuffcmd(self.owner, "wait;wait;wait;wait;wait;wait;wait;disconnect\n");
					remove(self);
					return;
				}
				t2 = ftos(f2);
				localcmd("localinfo ");
				localcmd(t2);
				localcmd(" \"\"\n");
				t2 = infokey(self.owner, "team");
				bprint(2, self.owner.netname, " rejoins the game ", t2, "‘\n");
				self.owner.fraggie = p.frags;
				self.owner.deaths = p.deaths;
				self.owner.friendly = p.friendly;
				self.owner.k_teamnum = p.k_teamnum;
				remove(p);
			} 
			else 
			{
				t2 = ftos(f2);
				localcmd("localinfo ");
				localcmd(t2);
				localcmd(" \"\"\n");
				bprint(2, self.owner.netname);
				bprint(2, " reenters the game without stats\n");
			}
		}

		tmp = infokey(self.owner, "team");
		if(tmp != "") 
		{
			f1 = 665;
			while(k_teamid > f1 && !self.owner.k_teamnum) 
			{
				f1 = f1 + 1;
				t = ftos(f1);
				s1 = infokey(world, t);
				tmp = infokey(self.owner, "team");
				if(tmp == s1) self.owner.k_teamnum = f1;
			}
			if(!self.owner.k_teamnum) 
			{
				f1 = f1 + 1;
				s1 = ftos(f1);
				localcmd("localinfo ");
				localcmd(s1);
				localcmd(" \"");
				tmp = infokey(self.owner, "team");
				localcmd(tmp);
				localcmd("\"\n");
				k_teamid = f1;
				self.owner.k_teamnum = f1;
			}
		} else self.owner.k_teamnum = 666;
	} 
	else 
	{
		bprint(2, self.owner.netname);
		bprint(2, " entered the game\n");

// take away admin status, terminate elect and kick modes
		self.owner.k_admin = 0;
		self.owner.k_kicking = 0;
		self.owner.k_vote2 = 0;
		self.owner.k_captain = 0;
	}

	self.owner.frags = self.owner.fraggie;
	newcomer = self.owner.netname;
	self.think = MOTDThinkX;
	self.nextthink = time + 0.3;
};

void() MakeMOTD =
{
	local entity motd;



	motd = spawn();
	motd.classname = "motd";
	motd.owner = self;
	motd.think = MOTDStuff;
	motd.nextthink = time + 0.1;
	motd.attack_finished = time + 7;
};

void() SMakeMOTD =
{
	local entity motd;


	motd = spawn();
	motd.classname = "smotd";
	motd.owner = self;
	motd.think = SMOTDThink;
	motd.nextthink = time + 0.5;
	motd.attack_finished = time + 7;
};
