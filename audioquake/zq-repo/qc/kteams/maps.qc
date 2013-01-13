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
// maps.qc




float() CountPlayers;

void() StuffMapAliases =
{
	stuffcmd(self, "alias e1m1 impulse 200\n");
	stuffcmd(self, "alias e1m2 impulse 201\n");
	stuffcmd(self, "alias e1m3 impulse 202\n");
	stuffcmd(self, "alias e1m4 impulse 203\n");
	stuffcmd(self, "alias e1m5 impulse 204\n");
	stuffcmd(self, "alias e1m6 impulse 205\n");
	stuffcmd(self, "alias e1m7 impulse 206\n");
	stuffcmd(self, "alias e1m8 impulse 207\n");
	stuffcmd(self, "alias e2m1 impulse 208\n");
	stuffcmd(self, "alias e2m2 impulse 209\n");
	stuffcmd(self, "alias e2m3 impulse 210\n");
	stuffcmd(self, "alias e2m4 impulse 211\n");
	stuffcmd(self, "alias e2m5 impulse 212\n");
	stuffcmd(self, "alias e2m6 impulse 213\n");
	stuffcmd(self, "alias e2m7 impulse 214\n");
	stuffcmd(self, "alias e3m1 impulse 215\n");
	stuffcmd(self, "alias e3m2 impulse 216\n");
	stuffcmd(self, "alias e3m3 impulse 217\n");
	stuffcmd(self, "alias e3m4 impulse 218\n");
	stuffcmd(self, "alias e3m5 impulse 219\n");
	stuffcmd(self, "alias e3m6 impulse 220\n");
	stuffcmd(self, "alias e3m7 impulse 221\n");
	stuffcmd(self, "alias e4m1 impulse 222\n");
	stuffcmd(self, "alias e4m2 impulse 223\n");
	stuffcmd(self, "alias e4m3 impulse 224\n");
	stuffcmd(self, "alias e4m4 impulse 225\n");
	stuffcmd(self, "alias e4m5 impulse 226\n");
	stuffcmd(self, "alias e4m6 impulse 227\n");
	stuffcmd(self, "alias e4m7 impulse 228\n");
	stuffcmd(self, "alias e4m8 impulse 229\n");
	stuffcmd(self, "alias dm1 impulse 230\n");
	stuffcmd(self, "alias dm2 impulse 231\n");
	stuffcmd(self, "alias dm3 impulse 232\n");
	stuffcmd(self, "alias dm4 impulse 233\n");
	stuffcmd(self, "alias dm5 impulse 234\n");
	stuffcmd(self, "alias dm6 impulse 235\n");
	stuffcmd(self, "alias start impulse 236\n");
	stuffcmd(self, "alias end impulse 237\n");
};

void() StuffCustomMaps =
{
	local float f1, f2, f3;
	local string s1, s2;

	if(self.cnt == -1)
		self.cnt = 237 + 1;

	f1 = self.cnt;
	f3 = f1 + 10;
	f2 = 999 + self.cnt - 237;
	s1 = ftos(f2);
	s2 = infokey(world, s1);
	
	while(s2 != "" && (f1 <= f3)) {
		stuffcmd(self.owner, "\nalias ");
		f2 = f2 + 1;
		stuffcmd(self.owner, s2);
		s1 = ftos(f1);
		stuffcmd(self.owner, " impulse ");
		stuffcmd(self.owner, s1);
		f1 = f1 + 1;
		s1 = ftos(f2);
		s2 = infokey(world, s1);
	}

	if(s2 == "")
	{
		// decrease f1 by 1 so we know the last map impulse being used.
		f1 = f1 - 1;
		
		s1 = infokey(world, "999");
		
		if(s1 == "")
		{
			// store the last map impulse being used in localinfo 999.
			localcmd("localinfo 999 \"");
			s1 = ftos(f1);
			localcmd(s1);
			localcmd("\"\n");
		}

		stuffcmd(self.owner, "\necho Aliases downloaded...\n");

        // Tell the world we already have stuffed the map aliases.
		self.owner.k_stuff=1;

		// no more maps in localinfo so setup for removing entity and return.
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
		return;
	}

	// next time around we'll be starting from the f1 variable which is the next available impulse.
	self.cnt = f1;
	
	// 0.5 sec delay before next stuffing.
	self.nextthink = time + 0.5;
	
	return;
};

string(float f2) GetMapName =
{
	local float f1;
	local string s1, s2;

	
	 if (f2 == 200)
		return "e1m1";
	 else if (f2 == 201)
		return "e1m2";
	 else if (f2 == 202)
		return "e1m3";
	 else if (f2 == 203)
		return "e1m4";
	 else if (f2 == 204)
		return "e1m5";
	 else if (f2 == 205)
		return "e1m6";
	 else if (f2 == 206)
		return "e1m7";
	 else if (f2 == 207)
		return "e1m8";
	 else if (f2 == 208)
		return "e2m1";
	 else if (f2 == 209)
		return "e2m2";
	 else if (f2 == 210)
		return "e2m3";
	 else if (f2 == 211)
		return "e2m4";
	 else if (f2 == 212)
		return "e2m5";
	 else if (f2 == 213)
		return "e2m6";
	 else if (f2 == 214)
		return "e2m7";
	 else if (f2 == 215)
		return "e3m1";
	 else if (f2 == 216)
		return "e3m2";
	 else if (f2 == 217)
		return "e3m3";
	 else if (f2 == 218)
		return "e3m4";
	 else if (f2 == 219)
		return "e3m5";
	 else if (f2 == 220)
		return "e3m6";
	 else if (f2 == 221)
		return "e3m7";
	 else if (f2 == 222)
		return "e4m1";
	 else if (f2 == 223)
		return "e4m2";
	 else if (f2 == 224)
		return "e4m3";
	 else if (f2 == 225)
		return "e4m4";
	 else if (f2 == 226)
		return "e4m5";
	 else if (f2 == 227)
		return "e4m6";
	 else if (f2 == 228)
		return "e4m7";
	 else if (f2 == 229)
		return "e4m8";
	 else if (f2 == 230)
		return "dm1";
	 else if (f2 == 231)
		return "dm2";
	 else if (f2 == 232)
		return "dm3";
	 else if (f2 == 233)
		return "dm4";
	 else if (f2 == 234)
		return "dm5";
	 else if (f2 == 235)
		return "dm6";
	 else if (f2 == 236)
		return "start";
	 else if (f2 == 237)
		return "end";
	 else {
		f1 = f2 + 999 - 237;
		s1 = ftos(f1);
		s2 = infokey(world, s1);
		return s2;
	}
};

void() SelectMap =
{
	local float f1, f2, f3;
	local string s2;
	local entity p;

	f1 = stof(infokey(world, "999"));
	if(self.impulse > f1) return;
	if((stof(infokey(world, "k_lockmap")) || stof(infokey(world, "k_master"))) && self.k_admin < 2) {
		sprint(self, 2, "MAP IS LOCKED!\nYou are NOT allowed to change!\n");
		return;
	}
	f3 = 0;
	if(!k_vbreak) {
		bprint(3, self.netname, " suggests map ");
		k_vbreak = self.impulse;
		self.k_vote = self.impulse;
	} else {
		if(k_vbreak == self.impulse) {
			if(self.k_vote != self.impulse) {
				f1 = CountPlayers();

			if(f1 < 3) bprint(3, self.netname, " agrees to map ");
				else bprint(3, self.netname, " agrees on map ");
				self.k_vote = self.impulse;
			} else {
				sprint(self, 2, "--- your vote is still good ---\n");
				f3 = 1;
			}
		} else {
			p = find(world, classname, "player");
			while(p != world) {
				p.k_vote = 0;
				p = find(p, classname, "player");
			}
			bprint(3, self.netname, " would rather play on ");
			k_vbreak = self.impulse;
			self.k_vote = self.impulse;
		}
	}
	if(!f3) {
		s2 = GetMapName(self.impulse);
		bprint(2, s2, "\n");
	}
	f1 = CountPlayers();
	f2 = (floor(f1 / 2)) + 1;
	f1 = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && p.k_vote == k_vbreak) f1 = f1 + 1;
		p = find(p, classname, "player");
	}
	if(f1 < f2 && self.k_admin != 2) return;
	if(self.k_admin == 2) {
		bprint(2, "Admin veto\n");
	} else {
		bprint(2, "Majority votes for mapchange.\n");
	}
	s2 = GetMapName(self.impulse);
	localcmd("map ");
	localcmd(s2);
	localcmd("\n");
};
