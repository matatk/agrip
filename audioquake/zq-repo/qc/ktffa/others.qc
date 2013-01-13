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
// Most of the stuff done by rc\sturm is here

void CheckAll ();

void TimerThink ()
{
    float f1;
    string tmp;
    entity p;

	mytime = mytime + 1;
// s: minutes
	f1 = (timelimit - mytime) / 60;
	if(floor(f1) == f1 && f1) {
		bprint(2, "");
		tmp = ftos(f1);
		bprint(2, tmp);
		if(f1 == 1)
			bprint(2, "‘ minute remaining\n");
		else 
			bprint(2, "‘ minutes remaining\n");
	}
// s: seconds
	f1 = timelimit - mytime;
	if((f1 == 30 || f1 == 15 || f1 <= 10) && f1 > 0) {
		bprint(2, "");
		tmp = ftos(f1);
		bprint(2, tmp);
		if(f1 == 1)
			bprint(2, "‘ second\n");
		else
			bprint(2, "‘ seconds\n");
		if(f1 < 6) {
			p = find(world, classname, "player");
			while(p != world) {
				if(p.netname != "")
					stuffcmd(p, "play buttons/switch04.wav\n");
				p = find(p, classname, "player");
			}
		}
	}
	self.nextthink = time + 1;
// check rate every 20 seconds
	if (floor(f1/20) == f1/20) CheckAll();
}

void PrintScores ()
{
    float f1, f2;
    string tmp;
    entity p;

	if(timelimit) {
		f1 = timelimit - mytime;
		f2 = floor(f1 / 60);
		tmp = ftos(f2);
		sprint(self, 2, "");
		sprint(self, 2, tmp);
		f1 = f1 - f2 * 60;
		sprint(self, 2, ":");
		tmp = ftos(f1);
		sprint(self, 2, tmp);
		sprint(self, 2, "‘ remaining\n");
	}
	if(fraglimit) {

// s: probably low enough for a start value :)
		f1 = -99999;

		p = find(world, classname, "player");
		if(p == world) f1 = 0;
		while(p != world) {
			if(p.netname != "")
				if(p.frags > f1) f1 = p.frags;
			p = find(p, classname, "player");
		}
		tmp = ftos(fraglimit - f1);
		sprint(self, 2, "");
		sprint(self, 2, tmp);
		if(fraglimit - f1 == 1)
			sprint(self, 2, "‘ frag to go\n");
		else
			sprint(self, 2, "‘ frags to go\n");
	}
}

void SendMessage (string name)
{
    string s1, s2;
    entity p;

	p = find(world, classname, "player");
	while((p != world && p.netname != name) || p == self)
		p = find(p, classname, "player");
	if(p != world) {
		s1 = infokey(self, "premsg");
		s2 = infokey(self, "postmsg");
		bprint(3, self.netname);
		bprint(3, ": ");
		bprint(3, s1);
		bprint(2, name);
		bprint(3, s2);
		bprint(3, "\n");
	} else
		stuffcmd(self, "echo No name to display\n");
}

void PrintCommands ()
{
	sprint(self, 2, "φοτε....... vote for mapchange\nωεσ........ give a vote\nξο......... withdraw a vote\nσγοςεσ..... print game info\nαβουτ...... kombat teams FFA info\nλιμμες..... who killed you last\nφιγτιν..... who you last killed\nξεχγονες... last player joined\n");
}

void PrintSCommands ()
{
	sprint(self, 2, "κοιξ....... join the game\nσγοςεσ..... print game info\nαβουτ...... kombat teams FFA info\n");
}

void ShowVersion ()
{
        sprint(self, 3, "\nThis is Kombat Teams 2.22 FFA\nby Cenobite and Sturm.\n\nSource, configs etc. at:\nhttp://kteam.co.uk\n");
}

void StuffThink ()
{
	string	s;

	sprint(self.owner, 2, "Welcome to Λονβατ Τεανσ ²®²² ΖΖΑ mod\nType γονναξδσ for help\n");

	stuffcmd(self.owner, "alias vote \"impulse ");
	s = ftos(KT_IMPULSE_VOTE_CHANGE);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias yes \"impulse ");
	s = ftos(KT_IMPULSE_VOTE_YES);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias no \"impulse ");
	s = ftos(KT_IMPULSE_VOTE_NO);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias scores \"impulse ");
	s = ftos(KT_IMPULSE_PRINT_SCORES);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias commands \"impulse ");
	s = ftos(KT_IMPULSE_PRINT_CMDS);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias killer \"impulse ");
	s = ftos(KT_IMPULSE_MSG_KILLER);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias victim \"impulse ");
	s = ftos(KT_IMPULSE_MSG_VICTIM);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias newcomer \"impulse ");
	s = ftos(KT_IMPULSE_MSG_NEWCOMER);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\nalias about \"impulse ");
	s = ftos(KT_IMPULSE_PRINT_VERSION);
	stuffcmd(self.owner, s);
	stuffcmd(self.owner, "\"\n");

	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
}

