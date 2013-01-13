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
// commands.qc

string GetMapName(float f2);
void SendMessage(string name);

void() ChangeOvertime =
{
	local float f1,f2;
        local string tmp;

	if(match_in_progress) return;

	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}

        f1 = stof(infokey(world, "k_overtime"));
        f2 = stof(infokey(world, "k_exttime"));

        if(!f1)
        {
		if(!f2) 
		{
			localcmd("localinfo k_exttime 1\n");
			f2 = 1;
		}

		bprint(2, "Οφεςτινε: time based\n");
		tmp = ftos(f2);
		bprint(2, "Οφεςτινε μεξητθ ισ ", tmp, " νιξυτε");
		if (f1 == 1) bprint(2, "\n");
		else bprint(2, "σ\n");
		localcmd("localinfo k_overtime 1\n");
        }
        else if(f1 == 1)
	{
		bprint(2, "Οφεςτινε: sudden death\n");
		localcmd("localinfo k_overtime 2\n");
	}
        else if(f1 == 2)
        {
		bprint(2, "Οφεςτινε: off\n");
		localcmd("localinfo k_overtime 0\n");
        }
};

void() ChangeOvertimeUp =
{
	local float f1;
	local string tmp;

	if(match_in_progress) return;

	if(stof(infokey(world, "k_master")) && self.k_admin < 2)
	{
		sprint(self, 3, "console: command is locked\n");
		return;
	}

	f1 = stof(infokey(world, "k_exttime"));

        if (f1==10){f1=1;}
        else{f1=f1+1;}

        tmp = ftos(f1);

        if (f1==1)
        {
               bprint(2, "Οφεςτινε μεξητθ σετ το ", tmp, " νιξυτε\n");
        }
	else
        {
               bprint(2, "Οφεςτινε μεξητθ σετ το ", tmp, " νιξυτεσ\n");
        }

	localcmd("localinfo k_exttime ");
	localcmd(tmp);
        localcmd("\n");
};

void() SetOfficial =
{
	if(match_in_progress) return;

	if(stof(infokey(world, "k_master")) && self.k_admin < 2)
	{
		sprint(self, 3, "console: command is locked\n");
		return;
	}

	if(stof(infokey(world, "k_duel"))) {
		sprint(self, 3, "console: duel mode disallows you to set league settings\n");
		return;
	}

	localcmd("fraglimit 0\ntimelimit 20\nteamplay 2\ndeathmatch 1\nlocalinfo dq 0\nlocalinfo dr 0\nlocalinfo k_spw 1\nlocalinfo k_dis 1\nlocalinfo k_bzk 0\nlocalinfo k_overtime 1\nlocalinfo k_exttime 5\n");
	bprint(2, "Μεαηυε σεττιξησ enabled\n");
};

void() ListWhoNot =
{
	local entity p;
	local string tmp;
	local float f1, f2;

	f1 = CountRPlayers();
	f2 = CountPlayers();
	if(f1 == f2) {
		sprint(self, 2, "All players ready\n");
		return;
	}
	if(!match_in_progress)
        {
		if(self.classname == "player" && !self.ready) 
		{
			sprint(self, 2, "Ready yourself first\n");
			return;
		}	

		if( (time < k_whonottime + 10) )
		{
                  sprint(self, 2, "Only one μιστ in 10 seconds\n");
			return;
		}
		k_whonottime = time;
		bprint(2, "Players ξοτ ready:\n");
		bprint(3, "\n");

		p = find(world, classname, "player");
		while(p != world) {
			if(p.netname != "" && !p.ready) {
				tmp = infokey(p, "team");
				if(p.k_admin == 2) bprint(2, " ");
				bprint(2, "", tmp, "‘ ");
				bprint(2, p.netname, " is not ready\n");
			}
			p = find(p, classname, "player");
		}
        } else
		sprint(self, 2, "Game in progress\n");
};

void() ShowCmds =
{
	if(self.k_admin == 2) {
		sprint(self, 2, "αδνιξ....... give up admin rights\nπςεχας...... playerfire before game\nμογλναπ..... (un)lock current map\nζοςγεσταςτ.. force match to start\nζοςγεβςεαλ.. force match to end\nζοςγεπαυσε.. toggle pausemode\nναστες...... toggle mastermode\nλιγλ........ toggle kick mode\nδεατθνση.... toggle new messages\nςπιγλυπ..... random team pickup\n");
	} else {
		sprint(self, 2, "αβουτ...... kombat teams info\nςυμεσ...... show game rules\nςεαδω...... when you feel ready\nβςεαλ...... unready / vote matchend\nοπτιοξσ.... match control commands\nριϊνο...... qizmo related commands\nνεσσαηεσ... fun message commands\nστατυσ..... show server settings\nστατυσ².... more server settings\nςεσετ...... set defaults\nζςεεϊε..... (un)freeze the map\nναπσ....... list custom maps\nχθο........ player teamlist\nχθοξοτ..... players not ready\nμιστ....... whonot to everyone\nχθοσλιξ.... player skinlist\nχθοφοτε.... info on received votes\nπιγλυπ..... vote for pickup game\nστατσ...... show playerstats\nοφεςτινε... toggle overtime mode\nοφεςτινευπ. change overtime length\nοζζιγιαμ... set league settings\nγαπταιξ.... toggle captain election\n");
		if(stof(infokey(world, "k_admins"))) {
			sprint(self, 2, "αδνιξ...... toggle admin-mode\n");
			sprint(self, 2, "εμεγτ...... toggle admin election\n");
		}
	}
};

void() ShowVersion =
{
        sprint(self, 3, "\nThis is Kombat Teams 2.21\nby kemiKal, Cenobite, Sturm and Fang.\n\nSource, soundbanks, configs etc. at:\nhttp://hosted.barrysworld.com/kteam\n");
};

void() SShowCmds =
{
	if(self.k_admin == 2) {
		sprint(self, 2, "αδνιξ....... give up admin rights\nπςεχας...... playerfire before game\nμογλναπ..... (un)lock current map\nζοςγεσταςτ.. force match to start\nζοςγεβςεαλ.. force match to end\nζοςγεπαυσε.. toggle pausemode\nναστες...... toggle mastermode\nλιγλ........ toggle kick mode\nδεατθνση.... toggle new messages\nςπιγλυπ..... random team pickup\n");
		sprint(self, 2, "οφεςτινε.... toggle overtime mode\nοφεςτινευπ.. change overtime length\nοζζιγιαμ.... set league settings\nyou may also use\nτπ  δν  ποχεςυπσ  σιμεξγε\nτινευπ  τινεδοχξ  σπαχξ\nρμαη    ρεξενω    ρποιξτ\nςεσετ   ναπσ\n");
	}
	else {
		sprint(self, 2, "στατυσ..... show match settings\nστατυσ².... more match settings\nγαν........ camera help text\nχθο........ player teamlist\nχθοξοτ..... players not ready\nχθοσλιξ.... player skinlist\nχθοφοτε.... info on received votes\nκοιξ....... joins game\nστατσ...... show playerstats\n");
		if(stof(infokey(world, "k_admins"))) {
			sprint(self, 2, "αδνιξ...... toggle admin-mode\n");
			sprint(self, 2, "εμεγτ...... toggle admin election\n");
		}
	}
};

void() ShowOpts =
{
	sprint(self, 2, "τινεδοχξ±.. -1 mins match time\nτινευπ±.... +1 mins match time\nτινεδοχξ... -5 mins match time\nτινευπ..... +5 mins match time\nζςαησδοχξ.. -10 fraglimit\nζςαησυπ.... +10 fraglimit\nδν......... change deathmatch mode\nτπ......... change teamplay mode\nδςοπρυαδ... drop quad when killed\nδςοπςιξη... drop ring when killed\nδςοππαγλ... drop pack when killed\nμογλ....... change locking mode\nσπαχξ...... change spawntype\nσπεεδ...... toggle sv_maxspeed\nποχεςυπσ... quad, , ring & suit\nσπαχξ¶¶¶... 2 secs of  on respawn\nζαιςπαγλσ.. best/last weapon dropped\nδισγθαςηε.. underwater discharges\nσιμεξγε.... toggle spectator talk\nβεςϊεςλ.... toggle berzerk mode\n");
};

void() ShowQizmo =
{
	sprint(self, 2, "ρμαη....... lagsettings\nρεξενω..... enemy vicinity reporting\nρποιξτ..... point function\n");
};

// ShowMessages and SendMessage command implementations added
void() ShowMessages =
{
	sprint(self, 2, "λιμμες..... who killed you last\nφιγτιν..... who you last killed\nξεχγονες... last player joined\n");
};

void() SendKillerMsg =
{
	SendMessage(self.killer);
};

void() SendVictimMsg =
{
	SendMessage(self.victim);
};

void() SendNewcomerMsg =
{
	SendMessage(newcomer);
};

void(string name) SendMessage =
{
	local string s1, s2;
	local entity p;

	p = find(world, classname, "player");
	while((p != world && p.netname != name) || p == self)
		p = find(p, classname, "player");
	if(p != world) {
		s1 = infokey(self, "premsg");
		s2 = infokey(self, "postmsg");
		bprint(3, self.netname, ": ", s1);
		bprint(2, name);
		bprint(3, s2, "\n");
	} else
		stuffcmd(self, "echo No name to display\n");
};			

void() ShowMaps =
{
	local float f1;
	local string s1, s2;

	sprint(self, 2, "Vote for maps by typing the mapname,\nfor example \"δν΄\".\n");
	f1 = stof(infokey(world, "999"));
	if(f1 > 137) {
		sprint(self, 2, "\n---μιστ οζ γυστον ναπσ\n");
		f1 = 1000;
		s1 = ftos(f1);
		s2 = infokey(world, s1);
		while(s2 != "") {
			if(f1 & 1) {
				sprint(self, 2, s2, "\n");
			} else {
				sprint(self, 2, s2, "   ");
			}
			f1 = f1 + 1;
			s1 = ftos(f1);
			s2 = infokey(world, s1);
		}
		if(f1 & 1) sprint(self, 2, "\n");
		sprint(self, 2, "---εξδ οζ μιστ\n");
	}

};

void() StuffAliases =
{
// stuffing for numbers, hope no flooding out
	stuffcmd(self.owner, "alias 1 impulse 1\nalias 2 impulse 2\nalias 3 impulse 3\nalias 4 impulse 4\nalias 5 impulse 5\nalias 6 impulse 6\nalias 7 impulse 7\nalias 8 impulse 8\nalias 9 impulse 9\n");
	stuffcmd(self.owner, "alias 10 impulse 10\nalias 11 impulse 11\nalias 12 impulse 12\nalias 13 impulse 13\nalias 14 impulse 14\nalias 15 impulse 15\nalias 16 impulse 16\n");




 stuffcmd(self.owner, "alias ready impulse 20\n");
 stuffcmd(self.owner, "alias break impulse 21\n");
 stuffcmd(self.owner, "alias stats impulse 22\n");
 stuffcmd(self.owner, "alias status2 impulse 23\n");
 stuffcmd(self.owner, "alias status impulse 24\n");
 stuffcmd(self.owner, "alias powerups impulse 25\n");
 stuffcmd(self.owner, "alias dm impulse 26\n");
 stuffcmd(self.owner, "alias tp impulse 27\n");
 stuffcmd(self.owner, "alias timedown1 impulse 28\n");
 stuffcmd(self.owner, "alias timeup1 impulse 29\n");
 stuffcmd(self.owner, "alias timedown impulse 30\n");
 stuffcmd(self.owner, "alias timeup impulse 31\n");
 stuffcmd(self.owner, "alias fragsdown impulse 32\n");
 stuffcmd(self.owner, "alias fragsup impulse 33\n");
 stuffcmd(self.owner, "alias dropquad impulse 34\n");
 stuffcmd(self.owner, "alias dropring impulse 35\n");
 stuffcmd(self.owner, "alias discharge impulse 36\n");
 stuffcmd(self.owner, "alias options impulse 37\n");
 stuffcmd(self.owner, "alias silence impulse 38\n");
 stuffcmd(self.owner, "alias advanced impulse 39\n");
 stuffcmd(self.owner, "alias reset impulse 40\n");
 stuffcmd(self.owner, "alias rules impulse 41\n");
 stuffcmd(self.owner, "alias lock impulse 42\n");
 stuffcmd(self.owner, "alias spawn666 impulse 43\n");
 stuffcmd(self.owner, "alias berzerk impulse 44\n");
 stuffcmd(self.owner, "alias master impulse 45\n");
 stuffcmd(self.owner, "alias time5 impulse 46\n");
 stuffcmd(self.owner, "alias time10 impulse 47\n");
 stuffcmd(self.owner, "alias time15 impulse 48\n");
 stuffcmd(self.owner, "alias time20 impulse 49\n");
 stuffcmd(self.owner, "alias time25 impulse 50\n");
 stuffcmd(self.owner, "alias time30 impulse 51\n");
 stuffcmd(self.owner, "alias whovote impulse 52\n");
 stuffcmd(self.owner, "alias whoskin impulse 53\n");
 stuffcmd(self.owner, "alias whonot impulse 54\n");
 stuffcmd(self.owner, "alias who impulse 55\n");
 stuffcmd(self.owner, "alias droppack impulse 56\n");
 stuffcmd(self.owner, "alias fairpacks impulse 57\n");
 stuffcmd(self.owner, "alias speed impulse 58\n");
 stuffcmd(self.owner, "alias spawn impulse 59\n");
 stuffcmd(self.owner, "alias about impulse 60\n");
 stuffcmd(self.owner, "alias ksound1 impulse 61\n");
 stuffcmd(self.owner, "alias ksound2 impulse 62\n");
 stuffcmd(self.owner, "alias ksound3 impulse 63\n");
 stuffcmd(self.owner, "alias ksound4 impulse 64\n");
 stuffcmd(self.owner, "alias ksound5 impulse 65\n");
 stuffcmd(self.owner, "alias ksound6 impulse 66\n");
 stuffcmd(self.owner, "alias scores impulse 67\n");
 stuffcmd(self.owner, "alias qizmo impulse 68\n");
 stuffcmd(self.owner, "alias messages impulse 69\n");
 stuffcmd(self.owner, "alias killer impulse 70\n");
 stuffcmd(self.owner, "alias victim impulse 71\n");
 stuffcmd(self.owner, "alias newcomer impulse 72\n");
 stuffcmd(self.owner, "alias qlag impulse 73\n");
 stuffcmd(self.owner, "alias qenemy impulse 74\n");
 stuffcmd(self.owner, "alias forcepause impulse 75\n");
 stuffcmd(self.owner, "alias pickup impulse 76\n");
 stuffcmd(self.owner, "alias qpoint impulse 77\n");
 stuffcmd(self.owner, "alias maps impulse 78\n");
 stuffcmd(self.owner, "alias captain impulse 79\n");
 stuffcmd(self.owner, "alias freeze impulse 80\n");
 stuffcmd(self.owner, "alias admin impulse 81\n");
 stuffcmd(self.owner, "alias forcestart impulse 82\n");
 stuffcmd(self.owner, "alias forcebreak impulse 83\n");
 stuffcmd(self.owner, "alias prewar impulse 84\n");
 stuffcmd(self.owner, "alias lockmap impulse 85\n");
 stuffcmd(self.owner, "alias commands impulse 86\n");
 stuffcmd(self.owner, "alias kick impulse 87\n");
 stuffcmd(self.owner, "alias y impulse 88\n");
 stuffcmd(self.owner, "alias n impulse 89\n");
 stuffcmd(self.owner, "alias list impulse 90\n");
 stuffcmd(self.owner, "alias overtime impulse 91\n");
 stuffcmd(self.owner, "alias overtimeup impulse 92\n");
 stuffcmd(self.owner, "alias elect impulse 93\n");
 stuffcmd(self.owner, "alias yes impulse 94\n");
 stuffcmd(self.owner, "alias no impulse 95\n");
 stuffcmd(self.owner, "alias deathmsg impulse 96\n");
 stuffcmd(self.owner, "alias rpickup impulse 97\n");
 stuffcmd(self.owner, "alias official impulse 98\n");
#ifdef VWEP_TEST
 stuffcmd(self.owner, "alias vwep impulse 99\n");
#endif
 stuffcmd(self.owner, "alias report impulse 103\n");
 stuffcmd(self.owner, "alias notready break\n");
};

void(string tog, string key) PrintToggle1 =
{
	local float f1;

	sprint(self, 2, tog);
	f1 = stof(infokey(world, key));
	if(!f1)	sprint(self, 2, "Off ");
	else {
		if(f1 == 1) sprint(self, 2, "On  ");
		else sprint(self, 2, "Jam ");
	}
};

void(string tog, string key) PrintToggle2 =
{
	sprint(self, 2, tog);
	if(stof(infokey(world, key)) != 0) sprint(self, 2, "On\n");
	else sprint(self, 2, "Off\n");
};

//Ceno
void(string tog, string key) PrintToggle3 =
{
	local float f1;

	sprint(self, 2, tog);
	f1 = stof(infokey(world, key));

	if(f1 == 0) sprint(self, 2, "Off ");
	else if(f1 == 1) sprint(self, 2, "On  ");
	else sprint(self, 2, "Lst ");

};

void() ModStatus =
{
	local entity p;
	local string tmp;

	tmp = ftos(k_maxspeed);
	sprint(self, 2, "Ναψσπεεδ       ", tmp, "\n");
	tmp = ftos(deathmatch);
	sprint(self, 2, "Δεατθνατγθ     ", tmp, "   ");
	tmp = ftos(teamplay);
	sprint(self, 2, "Τεανπμαω       ", tmp, "\n");
	tmp = ftos(timelimit);
	sprint(self, 2, "Τινεμινιτ      ", tmp, " ");
	if(timelimit < 10) sprint(self, 2, "  ");
	else if(timelimit < 100) sprint(self, 2, " ");
	tmp = ftos(fraglimit);
	sprint(self, 2, "Ζςαημινιτ      ", tmp, "\n");
	PrintToggle1("Ποχεςυπσ       ", "k_pow");
	PrintToggle2("Òεσπαχξ     ", "k_666");
	PrintToggle1("Δςοπ Ρυαδ      ", "dq");
	PrintToggle2("Δςοπ Òιξη      ", "dr");
	PrintToggle3("Ζαις Βαγλπαγλσ ", "k_frp");
	PrintToggle2("Δςοπ Βαγλπαγλσ ", "dp");
	PrintToggle1("Δισγθαςηε      ", "k_dis");
	PrintToggle2("Βεςϊεςλ νοδε   ", "k_bzk");

	if(match_in_progress == 1) {
		p = find(world, classname, "timer");
		tmp = ftos(p.cnt2);
		sprint(self, 2, "The match will start in ", tmp, " second");
		if(p.cnt2 != 1) sprint(self, 2, "s");
		sprint(self, 2, "\n");
		return;
	}
	if(k_velect) {
		tmp = ftos(k_velect);
		sprint(self, 2, "Election in progress\n", tmp, "‘ votes received\n");
	}
	if(k_captains == 2)
		sprint(self, 2, "Team picking in progress\n");
	if(k_captains >= 1 && k_captains < 2)
		sprint(self, 2, "1‘ captain present\n");
	if(match_in_progress == 2) {
		if(k_sudden_death)
			sprint(self, 2, "Sudden death οφεςτινε ιξ πςοηςεσσ\n");
		else {
			p = find(world, classname, "timer");
			tmp = ftos(p.cnt - 1);
			sprint(self, 2, "Match in progress\n", tmp, "‘ full minute");
			if(p.cnt != 1) sprint(self, 2, "s");
			sprint(self, 2, " left\n");
		}
	}
};

void() ModStatus2 =
{
	local string tmp;
	local float f1;

	f1 = stof(infokey(world, "k_spw"));
	if(f1 == 2) sprint(self, 2, "Λονβατ Τεανσ ςεσπαχξσ\n");
	else if(f1 == 1) sprint(self, 2, "ΛΤ ΣπαχξΣαζετω\n");
	else sprint(self, 2, "Ξοςναμ ΡΧ ςεσπαχξσ\n");

	if(stof(infokey(world, "k_duel")))
		sprint(self, 2, "Σεςφες νοδε: duel\n");
	else {
		sprint(self, 2, "Σεςφες νοδε: team\n");
		sprint(self, 2, "Σεςφες μογλιξη: ");
		if(lock == 0) sprint(self, 2, "off\n");
		else if(lock == 2) sprint(self, 2, "all\n");
		else if(lock == 1) sprint(self, 2, "team\n");
	}
	if(!match_in_progress) {
		f1 = CountRTeams();
		tmp = ftos(f1);
		sprint(self, 2, "Τεανιξζο (γυς: ", tmp);
		tmp = infokey(world, "k_lockmin");
		sprint(self, 2, " νιξ: ", tmp);
		tmp = infokey(world, "k_lockmax");
		sprint(self, 2, " ναψ: ", tmp, ")\n");
	}
	sprint(self, 2, "Σπεγταμλ: ");
      if(!stof(infokey(world, "k_spectalk"))) sprint(self, 2, "off\n");
	else sprint(self, 2, "on\n");

	sprint(self, 2, "Οφεςτινε: ");

	f1 = stof(infokey(world, "k_overtime"));
	if(!f1)
		sprint(self, 2, "off");
	else if(f1 == 1) {
		f1 = stof(infokey(world, "k_exttime"));
		tmp = infokey(world, "k_exttime");
		sprint(self, 2, tmp, " minute");
		if(f1 != 1) sprint(self, 2, "s");
	} else
		sprint(self, 2, "sudden death");

	f1 = stof(infokey(world, "fpd"));
	sprint(self, 2, "\n", "ΡιΪνο μαη: ");
	if(f1 & 8) sprint(self, 2, "off");
	else sprint(self, 2, "on");
	sprint(self, 2, "\n", "ΡιΪνο τινεςσ: ");
	if(f1 & 2) sprint(self, 2, "off");
	else sprint(self, 2, "on");
	sprint(self, 2, "\n", "ΡιΪνο εξενω ςεποςτιξη: ");
	if(f1 & 32) sprint(self, 2, "off");
	else sprint(self, 2, "on");
	sprint(self, 2, "\n", "ΡιΪνο ποιξτιξη: ");
	if(f1 & 128) sprint(self, 2, "off\n");
	else sprint(self, 2, "on\n");

	f1 = stof(infokey(world, "k_deathmsg"));
	sprint(self, 2, "Γυστον δεατθνεσσαηεσ: ");
	if(!f1){
		sprint(self, 2, "off\n");
	}
	else{
		sprint(self, 2, "on\n");
	}

	f1 = stof(infokey(world, "k_allowvoteadmin"));
	sprint(self, 2, "Αδνιξ εμεγτιοξ: ");
	if(!f1){
		sprint(self, 2, "disallowed\n");
	}
	else
	{
		sprint(self, 2, "allowed\n");
	}

	sprint(self, 2, "Γθεγλ ζςανετινεσ: ");
	if(framechecks)
		sprint(self, 2, "enabled\n");
	else
		sprint(self, 2, "disabled\n");
};

void() ModStatusVote =
{
	local entity p;
	local string s1;
	local float f1, f2;

	if(match_in_progress == 2) {
		s1 = ftos(k_vbreak);
		sprint(self, 2, s1, " φοτε(σ) ζος στοππιξη\n");
	} else {
		f1 = 0;
		f2 = 0;
		p = find(world, classname, "player");
		while(p != world) {
			if(p.netname != "") {
			 	if(p.k_pickup) f1 = f1 + 1;
				if(p.k_vote == k_vbreak) f2 = f2 + 1;
			}
			p = find(p, classname, "player");
		}
		s1 = ftos(f1);
		sprint(self, 2, s1, " φοτε(σ) ζος α πιγλυπ ηανε\n");
		if(k_vbreak) {
			s1 = ftos(f2);
			sprint(self, 2, s1, " φοτε(σ) ζος ναπ ");
			s1 = GetMapName(k_vbreak);
			sprint(self, 2, s1, "\n");
		} 
		if(k_velect) {
			s1 = ftos(k_velect);
			sprint(self, 2, s1, " φοτε(σ) ζος εμεγτιοξ\n");
		}
	}
	sprint(self, 2, "--------------\n");
};

void() PlayerStatus =
{
	local entity p;
	local string tmp;

	if(!match_in_progress) {
		p = find(world, classname, "player");
		while(p != world) {
			if(p.netname != "") {
				if(p.k_admin == 2) sprint(self, 2, "* ");
				sprint(self, 2, p.netname);
				if(p.ready) {
					tmp = infokey(p, "team");
					if(tmp == "") sprint(self, 2, " is ready\n");
					else sprint(self, 2, " is in team ", tmp, "‘\n");
				} else sprint(self, 3, " is not ready\n");
			}
			p = find(p, classname, "player");
		}
		sprint(self, 2, "--------------\n");
	} else sprint(self, 2, "Game in progress\n");
};

void() PlayerStatusS =
{

	local entity p;
	local string tmp;

	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "") {
			sprint(self, 2, "");

			tmp = infokey(p, "skin");
			sprint(self, 2, tmp, "‘ ");
			sprint(self, 2, p.netname, "\n");
		}
		p = find(p, classname, "player");
	}
	sprint(self, 2, "--------------\n");
};


void() PlayerStatusN =
{
	local entity p;
	local float f1, f2;

	f1 = CountRPlayers();
	f2 = CountPlayers();
	if(f1 == f2) {
		sprint(self, 2, "All players ready\n");
		return;
	}
	if(match_in_progress) sprint(self, 2, "Game in progress\n");
	else {
		sprint(self, 2, "Players ξοτ ready:\n\n");
		p = find(world, classname, "player");
		while(p != world) {
			if(p.netname != "" && !p.ready) {
				if(p.k_admin == 2) sprint(self, 2, " ");
				sprint(self, 2, p.netname, " is not ready\n");
			}
			p = find(p, classname, "player");
		}
	}
};

void() ResetOptions =
{
	local string s1;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	s1 = infokey(self, "team");
	if(self.k_admin != 2 || s1 == "") {
		localcmd("exec configs/reset.cfg\n");
	} else {
		localcmd("exec configs/");
		localcmd(s1);
		localcmd(".cfg\n");
		bprint(2, "*** \"", s1, "\" server setup by ", self.netname, "\n");
	}
};

void() VotePickup =
{
	local entity p;
	local float f1, f2;

	if(match_in_progress) return;
	if(k_captains) {
		sprint(self, 2, "No pickup when captain stuffing\n");
		return;
	}
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	self.k_pickup = 1 - self.k_pickup;
	if(self.k_pickup) bprint(2, self.netname, " σαωσ pickup!!\n");
	else bprint(2, self.netname, " σαωσ no pickup\n");
	f1 = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && p.k_pickup) f1 = f1 + 1;
		p = find(p, classname, "player");
	}
	f2 = CountPlayers();
	f2 = (floor(f2 / 2)) + 1;
	if(self.k_admin < 2) {
		if(f1 < f2) return;
		bprint(3, "console: a pickup game it is then\n");
	} else bprint(3, "console: admin veto for pickup\n");
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "") {
			stuffcmd(p, "break\ncolor 0\nteam \"\"\nskin base\n");
			p.k_pickup = 0;
		}
		p = find(p, classname, "player");
	}
};

void() ReportMe =
{
	local entity p;
	local string t1, t2, h, at, av, wt, wa, pa1, pa2;
	local float f1, flag;

	flag = 0;
	if(infokey(self, "k_nick") != "") flag = 1;
	pa1 = "¨";
	pa2 = "): ";
	if(self.items & 8192) at = "ga:";
	if(self.items & 16384) at = "ya:";
	if(self.items & 32768) at = "ra:";
	wt = "axe:";
	f1 = 0;
	if(self.items & 1) {
		wt = "sg:";
		f1 = self.ammo_shells;
	}
	if(self.items & 4) {
		wt = "ng:";
		f1 = self.ammo_nails;
	}
	if(self.items & 2) {
		wt = "ssg:";
		f1 = self.ammo_shells;
	}
	if(self.items & 8) {
		wt = "sng:";
		f1 = self.ammo_nails;
	}
	if(self.items & 16) {
		wt = "gl:";
		f1 = self.ammo_rockets;
	}
	if(self.items & 64) {
		wt = "lg:";
		f1 = self.ammo_cells;
	}
	if(self.items & 32) {
		wt = "rl:";
		f1 = self.ammo_rockets;
	}
    p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "") {
			t1 = infokey(self, "team");
			t2 = infokey(p, "team");
			if(t1 == t2) {
				if(flag) {
					t1 = infokey(self, "k_nick");
					sprint(p, 3, t1, "  ");
				} else sprint(p, 3, pa1, self.netname, pa2);
				if(self.armorvalue != 0) {
					av = ftos(self.armorvalue);
					sprint(p, 3, at, av);
				} else sprint(p, 3, "a:0");
				h = ftos(self.health);
				sprint(p, 3, "  h:", h, "  ", wt);
				wa = ftos(f1);
				sprint(p, 3, wa);
				if(self.items & 524288) sprint(p, 3, "  …εωεσ…‘");
				if(self.items & 1048576) sprint(p, 3, "  ……‘");
				if(self.items & 4194304) sprint(p, 3, "  …ρυαδ‘");
				sprint(p, 3, "\n");
			}
		}
		p = find(p, classname, "player");
	}
};

void() ToggleRespawns =
{
	local float tmp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	tmp = stof(infokey(world, "k_spw"));
	if(tmp == 2) {
		bprint(2, "Normal QW respawns (avoid spawnfrags)\n");
		localcmd("localinfo k_spw 0\n");
	} else if(tmp == 0) {
		bprint(2, "KT SpawnSafety\n");
		localcmd("localinfo k_spw 1\n");
	} else {
		bprint(2, "Kombat Teams respawns\n");
		localcmd("localinfo k_spw 2\n");
	}
};

void() ToggleRespawn666 =
{
	local float tmp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	tmp = stof(infokey(world, "k_666"));
	bprint(2, "Òεσπαχξ  ");
	if(tmp != 0) {
		bprint(2, "disabled\n");
		localcmd("localinfo k_666 0\n");
	} else {
		bprint(2, "enabled\n");
		localcmd("localinfo k_666 1\n");
	}
};

void() TogglePowerups =
{
	local float tmp;
	local entity p, old;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	tmp = stof(infokey(world, "k_pow"));
	bprint(2, "Ποχεςυπσ ");
	if(tmp == 2) {
		bprint(2, "disabled\n");
		localcmd("localinfo k_pow 0\n");
	    p = findradius('0 0 0', 999999);
		while(p) {
			old = p.chain;
			if(p.classname == "item_artifact_invulnerability") p.effects = p.effects - (p.effects & 128);
			if(p.classname == "item_artifact_super_damage") p.effects = p.effects - (p.effects & 64);
			p = old;
		}
	} else if(!tmp) {
		bprint(2, "enabled\n");
		localcmd("localinfo k_pow 1\n");
		p = findradius('0 0 0', 999999);
		while(p) {
			old = p.chain;
			if(p.classname == "item_artifact_invulnerability") p.effects = p.effects | 128;
			if(p.classname == "item_artifact_super_damage") p.effects = p.effects | 64;
			p = old;
		}
	} else {
		bprint(2, "enabled (timer jammer)\n");
		localcmd("localinfo k_pow 2\n");
	}
};

void() ToggleDischarge =
{
	local float tmp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	tmp = stof(infokey(world, "k_dis"));
	bprint(2, "Δισγθαςηεσ ");
	if(tmp != 0) {
		bprint(2, "disabled\n");
		localcmd("localinfo k_dis 0\n");
	} else {
		bprint(2, "enabled\n");
		localcmd("localinfo k_dis 1\n");
	}
};

void() ChangeDM =
{
	local string tmp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	deathmatch = deathmatch + 1;
	if(deathmatch == 6) deathmatch = 1;
	tmp = ftos(deathmatch);
	cvar_set("deathmatch", tmp);
	if(deathmatch == 1) tmp = "“";
	else if(deathmatch == 2) tmp = "”";
	else if(deathmatch == 3) tmp = "•";
	else if(deathmatch == 4) tmp = "–";
	else tmp = "—";
	bprint(2, "Deathmatch ", tmp, "\n");
};

void() ChangeTP =
{
	local string tmp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}

	if(stof(infokey(world, "k_duel"))) {
		sprint(self, 3, "console: duel mode disallows you to change teamplay setting\n");
		return;
	}

	teamplay = teamplay + 1;
	if(teamplay == 4) teamplay = 0;
	tmp = ftos(teamplay);
	cvar_set("teamplay", tmp);
	if(teamplay == 0) tmp = "’";
	else if(teamplay == 1) tmp = "“";
	else if(teamplay == 2) tmp = "”";
	else tmp = "•";
	bprint(2, "Teamplay ", tmp, "\n");
};

void(float t) TimeDown =
{
	local string tmp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	timelimit = timelimit - t;
	if(timelimit < 5) timelimit = 5;
	tmp = ftos(timelimit);
	bprint(2, "Νατγθ μεξητθ σετ το ", tmp, " νιξυτεσ\n");
	cvar_set("timelimit", tmp);
};

void(float t) TimeUp =
{
	local string tmp;
	local float top;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	timelimit = timelimit + t;
	top = stof(infokey(world, "k_timetop"));
	if(timelimit > top) timelimit = top;
	tmp = ftos(timelimit);
	bprint(2, "Νατγθ μεξητθ σετ το ", tmp, " νιξυτεσ\n");
	cvar_set("timelimit", tmp);
};

void(float t) TimeSet =
{
	local string tmp;


	local float top;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	timelimit = t;
	top = stof(infokey(world, "k_timetop"));

	if(timelimit > top) timelimit = top;
	tmp = ftos(timelimit);
	bprint(2, "Νατγθ μεξητθ σετ το ", tmp, " νιξυτεσ\n");
	cvar_set("timelimit", tmp);
};

void() FragsDown =
{
	local string tmp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	fraglimit = fraglimit - 10;
	if(fraglimit < 0) fraglimit = 0;
	tmp = ftos(fraglimit);
	bprint(2, "Ζςαημινιτ σετ το ", tmp, "\n");
	cvar_set("fraglimit", tmp);
};

void() FragsUp =
{
	local string tmp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	fraglimit = fraglimit + 10;
	if(fraglimit > 100) fraglimit = 100;
	tmp = ftos(fraglimit);
	bprint(2, "Ζςαημινιτ σετ το ", tmp, "\n");
	cvar_set("fraglimit", tmp);
};

void() ToggleDropQuad =
{
	local float dq;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	dq = stof(infokey(world, "dq"));
	if(dq != 0) {
		localcmd("localinfo dq 0\n");
		bprint(2, "ΔςοπΡυαδ off\n");
		return;
	}
	localcmd("localinfo dq 1\n");
	bprint(2, "ΔςοπΡυαδ on\n");
};

void() ToggleDropRing =
{
	local float dr;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	dr = stof(infokey(world, "dr"));
	if(dr != 0) {
		localcmd("localinfo dr 0\n");
		bprint(2, "ΔςοπÒιξη off\n");
		return;
	}
	localcmd("localinfo dr 1\n");
	bprint(2, "ΔςοπÒιξη on\n");
};

void() ToggleDropPack =
{
	local float dp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	dp = stof(infokey(world, "dp"));
	if(dp != 0) {
		localcmd("localinfo dp 0\n");
		bprint(2, "ΔςοπΠαγλσ off\n");
		return;
	}
	localcmd("localinfo dp 1\n");
	bprint(2, "ΔςοπΠαγλσ on\n");
};

void() ToggleFairPacks =
{
	local float f1;

    if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	f1 = stof(infokey(world, "k_frp"));
	if(f1==0)
	{
		localcmd("localinfo k_frp 1\n");
		bprint(2, "Ζαιςπαγλσ enabled - drop best weapon.\n");
		return;
	}
	else if(f1==1)
	{
		localcmd("localinfo k_frp 2\n");
		bprint(2, "Ζαιςπαγλσ enabled - drop last fired weapon.\n");
		return;
	}
	else if(f1==2)

{
		localcmd("localinfo k_frp 0\n");
		bprint(2, "Ζαιςπαγλσ disabled\n");
		return;
	}
};

void() ToggleSpeed =
{
	local string s1;
	local entity p;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	if(k_maxspeed != 320) k_maxspeed = 320;
	else k_maxspeed = stof(infokey(world, "k_highspeed"));
	s1 = ftos(k_maxspeed);
	bprint(2, "Ναψσπεεδ σετ το ");
	bprint(2, s1);
	bprint(2, "\n");
	cvar_set("sv_maxspeed", s1);
	p = find(world, classname, "player");
	while(p != world) {
		p.maxspeed = k_maxspeed;
		p = find(p, classname, "player");
	}
};

void() ToggleBerzerk =
{
	local float tmp;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	tmp = stof(infokey(world, "k_bzk"));
	if(tmp != 0) {
		localcmd("localinfo k_bzk 0\n");
		bprint(2, "ΒεςΪεςλ νοδε off\n");
		return;
	}
	localcmd("localinfo k_bzk 1\n");
	bprint(2, "ΒεςΪεςλ νοδε on\n");
}

#ifdef VWEP_TEST
void ToggleVwep ()
{
    float tmp;

    if(match_in_progress)
        return;
    if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
        sprint(self, 3, "console: command is locked\n");
        return;
    }
    tmp = stof(infokey(world, "vwep"));
    if(tmp != 0) {
        localcmd("localinfo vwep 0\n");
        bprint(2, "vwep νοδε off\nrequires map restart\n");   //TODO: change vwep for red text version
        return;
    }
    localcmd("localinfo vwep 1\n");
    bprint(2, "vwep νοδε on\nrequires map restart\n");
}
#endif

void() ToggleSpecTalk =
{
	local float tmp, tmp2;
	local string s1;

	if(match_in_progress && self.k_admin < 2) return;
	tmp2 = stof(infokey(world, "fpd"));

	tmp2 = tmp2 - (tmp2 & 64);
	if(match_in_progress == 2) {
		tmp = stof(infokey(world, "k_spectalk"));
		bprint(2, "Spectalk ");
		if(tmp != 0) {
			localcmd("sv_spectalk 0\nserverinfo fpd ");
			tmp2 = tmp2 + 64;
			s1 = ftos(tmp2);
			localcmd(s1);
			localcmd("\nlocalinfo k_spectalk 0\n");
			bprint(2, "off: πμαωεςσ γαξ ξο μοξηες θεας σπεγτατοςσ\n");
			return;
		}
		localcmd("sv_spectalk 1\nserverinfo fpd ");
		s1 = ftos(tmp2);
		localcmd(s1);
		localcmd("\nlocalinfo k_spectalk 1\n");
		bprint(2, "on: πμαωεςσ γαξ ξοχ θεας σπεγτατοςσ\n");
		return;
	} else {
		if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
			sprint(self, 3, "console: command is locked\n");
			return;
		}
		tmp = stof(infokey(world, "k_spectalk"));
		bprint(2, "Spectalk ");
		if(tmp != 0) {
			localcmd("localinfo k_spectalk 0\n");
			bprint(2, "off: πμαωεςσ γαξξοτ θεας σπεγτατοςσ δυςιξη ηανε\n");
			return;
		}
		localcmd("localinfo k_spectalk 1\n");
		bprint(2, "on: πμαωεςσ γαξ θεας σπεγτατοςσ δυςιξη ηανε\n");
	}
};

void() ShowRules =
{
	local string s1;

	if(stof(infokey(world, "k_duel"))) sprint(self, 2, "Server is in duelmode.\n");
	else sprint(self, 2, "Bind ςεποςτ to a key.\nPressing that key will send\nyour status to your teammates.\nTyping σγοςεσ during game\nwill print time left and teamscores.\nAlso available during game\nare στατσ and εζζιγιεξγω.\n\nRemember that telefragging a teammate\ndoes not result in frags.\n");
	if(stof(infokey(world, "k_bzk")) != 0) {
		s1 = infokey(world, "k_btime");
		sprint(self, 2, "\nBERZERK mode is activated!\nThis means that when only ", s1, " seconds\nremains of the game, all players\ngets QUAD/OCTA powered.\n");
	}
	sprint(self, 2, "\n");
};

void() ChangeLock =
{
	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	lock = lock + 1;
    if(lock > 2) lock = 0;
	if(lock == 0) bprint(2, "Σεςφες μογλιξη off\n");
	else if(lock == 2) bprint(2, "Σεςφες μογλεδ - players cannot connect during game\n");
	else if(lock == 1) bprint(2, "Τεανμογλ οξ - only players in existing teams can connect during game\n");
};

void(string sndname) TeamSay =
{
	local entity p;
	local string t1, t2;

    p = find(world, classname, "player");
	while(p != world) {
		if(p != self && teamplay && p.netname != "" && ((stof(infokey(p, "k_flags"))) & 1)) {
			t1 = infokey(self, "team");
			t2 = infokey(p, "team");
			if(t1 == t2) {
				stuffcmd(p, "play ");
				t1 = infokey(p, "k_sdir");
				if(t1) {
					stuffcmd(p, t1);
					stuffcmd(p, "/");
				}
				stuffcmd(p, sndname);
				stuffcmd(p, "\n");
			}
		}
		p = find(p, classname, "player");
	}
};

void() PrintScores =
{
	local string tmp, tmp2;
	local entity p;
	local float f1, f2;

	if(match_in_progress != 2) {
		sprint(self, 2, "no game - no scores.\n");
		return;
	}
	
	// Check to see if scores changed from last time you hit scores command.
	// DO this by checking if k_nochange is 0. 
	// which is set in ClientObituary in client.qc
	if( (k_showscores) && k_nochange == 0)
        {
		k_scores1 = 0;
		k_scores2 = 0;
		p = find(world, classname, "player");
		while(p != world) {
			if(p.netname != "" && p.k_accepted == 2) {
				f1 = f1 + 1;
				tmp = infokey(world, "k_team1");
				tmp2 = infokey(p, "team");
				if(tmp == tmp2) k_scores1 = k_scores1 + p.frags;
				else k_scores2 = k_scores2 + p.frags;
			}
			p = find(p, classname, "player");
		}
		p = find(world, classname, "ghost");
		while(p != world) {
			tmp = ftos(p.k_teamnum);
			tmp2 = infokey(world, tmp);
			tmp = infokey(world, "k_team1");
			if(tmp == tmp2) k_scores1 = k_scores1 + p.frags;
			else k_scores2 = k_scores2 + p.frags;
			p = find(p, classname, "ghost");
		}
		k_nochange = 1;
	}
	if(k_sudden_death) sprint(self, 2, "Sudden death οφεςτινε ιξ πςοηςεσσ\n");
	p = find(world, classname, "timer");
	if(p != world) {
		f1 = p.cnt;
		f2 = p.cnt2;
		if(f2 == 60) f2 = 0;
		else f1 = f1 - 1;

		if(f1) {
			tmp = ftos(f1);
			sprint(self, 2, "", tmp, "‘ full minute");
			if(f1 > 1)
			sprint(self, 2, "s");
		}
		else {
		tmp = ftos(f2);
		sprint(self, 2, "", tmp, "‘ second");
		if(f2 > 1)
			sprint(self, 2, "s");
		}
		sprint(self, 2, " left\n");

	}
	if(k_showscores) {
		if(k_scores1 > k_scores2) {
			tmp = infokey(world, "k_team1");
			sprint(self, 2, "Τεαν ", tmp, "‘ = ");
			tmp = ftos(k_scores1);
			sprint(self, 2, tmp, "\n");
			tmp = infokey(world, "k_team2");
			sprint(self, 2, "Τεαν ", tmp, "‘ = ");
			tmp = ftos(k_scores2);
			sprint(self, 2, tmp, "\n");
		} else {
			tmp = infokey(world, "k_team2");
			sprint(self, 2, "Τεαν ", tmp, "‘ = ");
			tmp = ftos(k_scores2);
			sprint(self, 2, tmp, "\n");
			tmp = infokey(world, "k_team1");
			sprint(self, 2, "Τεαν ", tmp, "‘ = ");
			tmp = ftos(k_scores1);
			sprint(self, 2, tmp, "\n");
		}
	}
};


void() PlayerStats =
{
	local float f1;
	local entity p, p2;
	local string tmp, tmp2;

	if(match_in_progress != 2) {
		sprint(self, 2, "no game - no statistics.\n");
		return;
	}

	f1 = CountTeams();
	sprint(self, 2, "Πμαωες στατιστιγσ:\nΖςαησ (ςαξλ) ");
	if(!stof(infokey(world, "k_duel")) && f1 && teamplay)
		sprint(self, 2, "ζςιεξδλιμμσ ");
	sprint(self, 2, " εζζιγιεξγω\n");
	if(!stof(infokey(world, "k_duel")) && f1 && teamplay)
		sprint(self, 2, "");
	sprint(self, 2, "\n");
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && p.k_accepted == 2 && p.ready) {
			p2 = p;
			while (p2 != world) {
				tmp = infokey(p, "team");
				tmp2 = infokey(p2, "team");
				if(tmp == tmp2) {
					sprint(self, 2, "", tmp2, "‘ ");
					sprint(self, 2, p2.netname, ": ");
					tmp = ftos(p2.frags);
					sprint(self, 2, tmp, " (");
					tmp = ftos(p2.frags - p2.deaths);
					sprint(self, 2, tmp, ") ");
					if(!stof(infokey(world, "k_duel")) && f1 && teamplay) {
						tmp = ftos(p2.friendly);
						sprint(self, 2, tmp, " ");
					}
					if(p2.frags < 1)
						p2.efficiency = 0;
					else
						p2.efficiency = p2.frags / (p2.frags + p2.deaths) * 100;
					tmp = ftos(p2.efficiency);
					if(floor(p2.efficiency) == p2.efficiency) sprint(self, 2, " ");
					else sprint(self, 2, "");
					sprint(self, 2, tmp, "%\n");
					p2.ready = 0;
				}
				p2 = find(p2, classname, "player");
			}
		}
		p = find(p, classname, "player");
	}
	p = find(world, classname, "player");
	while(p != world) {
		p.ready = 1;
		p = find(p, classname, "player");
	}
};

/*
void() ToggleQTimer =
{
	local float f1, f2;
	local string s1;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	f1 = stof(infokey(world, "fpd"));
	f2 = f1 - (f1 & 2);
	if(f1 & 2) {
		localcmd("serverinfo fpd ");
		s1 = ftos(f2);
		localcmd(s1);
		localcmd("\n");
		bprint(2, "ΡιΪνο τινεςσ allowed\n");
		return;
	} else {
		localcmd("serverinfo fpd ");
		f2 = f2 + 2;
		s1 = ftos(f2);
		localcmd(s1);
		localcmd("\n");
		bprint(2, "ΡιΪνο τινεςσ disallowed\n");
	}
};
*/

void() ToggleQLag =
{
	local float f1, f2;
	local string s1;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	f1 = stof(infokey(world, "fpd"));
	f2 = f1 - (f1 & 8);
	if(f1 & 8) {
		localcmd("serverinfo fpd ");
		s1 = ftos(f2);
		localcmd(s1);
		localcmd("\n");
		bprint(2, "ΡιΪνο μαη σεττιξησ in effect\n");

		return;
	} else {
		localcmd("serverinfo fpd ");
		f2 = f2 + 8;
		s1 = ftos(f2);
		localcmd(s1);
		localcmd("\n");
		bprint(2, "ΡιΪνο μαη σεττιξησ not in effect\n");
	}
};

void() ToggleQEnemy =
{
	local float f1, f2;
	local string s1;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	f1 = stof(infokey(world, "fpd"));
	f2 = f1 - (f1 & 32);
	if(f1 & 32) {
		localcmd("serverinfo fpd ");
		s1 = ftos(f2);
		localcmd(s1);
		localcmd("\n");
		bprint(2, "ΡιΪνο εξενω ςεποςτιξη allowed\n");
		return;
	} else {
		localcmd("serverinfo fpd ");
		f2 = f2 + 32;
		s1 = ftos(f2);
		localcmd(s1);

		localcmd("\n");
		bprint(2, "ΡιΪνο εξενω ςεποςτιξη disallowed\n");
	}
};

void() ToggleQPoint =
{
	local float f1, f2;
	local string s1;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin < 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	f1 = stof(infokey(world, "fpd"));
	f2 = f1 - (f1 & 128);
	if(f1 & 128) {
		localcmd("serverinfo fpd ");
		s1 = ftos(f2);
		localcmd(s1);
		localcmd("\n");
		bprint(2, "ΡιΪνο ποιξτιξη enabled\n");
		return;
	} else {
		localcmd("serverinfo fpd ");
		f2 = f2 + 128;
		s1 = ftos(f2);
		localcmd(s1);
		localcmd("\n");
		bprint(2, "ΡιΪνο ποιξτιξη disabled\n");
	}
};

void() ToggleFreeze =
{
	local float f1;

	if(match_in_progress) return;
	if(stof(infokey(world, "k_master")) && self.k_admin != 2) {
		sprint(self, 3, "console: command is locked\n");
		return;
	}
	f1 = stof(infokey(world, "k_freeze"));
	if(f1) {
		localcmd("localinfo k_freeze 0\n");
		bprint(2, self.netname, " unfreezes map\n");
	} else {
		localcmd("localinfo k_freeze 1\n");
		bprint(2, self.netname, " freezes map\n");
	}
};

float() CaptainImpulses =
{
// s: return 0 if captain mode is set and no captain things were entered
	if(k_captains == 2 && self.impulse != 79) {
		if(self.impulse > 16 || !self.k_captain) return 0;
// s: return 1 if it's a player picker impulse
		return 1;
	}
// s: return 2 if nothing interesting
	return 2;
};

void() TeamCommands =
{
	if(self.impulse < 20 || self.impulse > 99) return;
	if(self.impulse == 86) ShowCmds();
	else if(self.impulse == 67) PrintScores();
	else if(self.impulse == 22) PlayerStats();
	else if(self.impulse == 37) ShowOpts();
	else if(self.impulse == 20) PlayerReady();
	else if(self.impulse == 21) PlayerBreak();
	else if(self.impulse == 24) ModStatus();
	else if(self.impulse == 23) ModStatus2();
	else if(self.impulse == 55) PlayerStatus();
	else if(self.impulse == 53) PlayerStatusS();
	else if(self.impulse == 54) PlayerStatusN();
	else if(self.impulse == 52) ModStatusVote();
	else if(self.impulse == 59) ToggleRespawns();
	else if(self.impulse == 25) TogglePowerups();
	else if(self.impulse == 36) ToggleDischarge();
	else if(self.impulse == 26) ChangeDM();
	else if(self.impulse == 27) ChangeTP();
	else if(self.impulse == 28) TimeDown(1);
	else if(self.impulse == 29) TimeUp(1);
	else if(self.impulse == 30) TimeDown(5);
	else if(self.impulse == 31) TimeUp(5);
	else if(self.impulse == 32) FragsDown();
	else if(self.impulse == 33) FragsUp();
	else if(self.impulse == 34) ToggleDropQuad();
	else if(self.impulse == 35) ToggleDropRing();
	else if(self.impulse == 56) ToggleDropPack();

    else if(self.impulse == 38) ToggleSpecTalk();
	else if(self.impulse == 40) ResetOptions();
	else if(self.impulse == 41) ShowRules();
	else if(self.impulse == 42) ChangeLock();
	else if(self.impulse == 78) ShowMaps();
	else if(self.impulse == 43) ToggleRespawn666();
	else if(self.impulse == 81) ReqAdmin();
	else if(self.impulse == 82) AdminForceStart();
	else if(self.impulse == 83) AdminForceBreak();
	else if(self.impulse == 75) AdminForcePause();
	else if(self.impulse == 76) VotePickup();
	else if(self.impulse == 84) TogglePreWar();
	else if(self.impulse == 85) ToggleMapLock();
	else if(self.impulse == 45) ToggleMaster();
	else if(self.impulse == 58) ToggleSpeed();
	else if(self.impulse == 57) ToggleFairPacks();
	else if(self.impulse == 60) ShowVersion();
	else if(self.impulse == 46) TimeSet(5);
	else if(self.impulse == 47) TimeSet(10);
	else if(self.impulse == 48) TimeSet(15);
	else if(self.impulse == 49) TimeSet(20);
	else if(self.impulse == 50) TimeSet(25);
	else if(self.impulse == 51) TimeSet(30);
	else if(self.impulse == 44) ToggleBerzerk();
	else if(self.impulse == 61) TeamSay("ktsound1.wav");
	else if(self.impulse == 62) TeamSay("ktsound2.wav");
	else if(self.impulse == 63) TeamSay("ktsound3.wav");
	else if(self.impulse == 64) TeamSay("ktsound4.wav");
	else if(self.impulse == 65) TeamSay("ktsound5.wav");
	else if(self.impulse == 66) TeamSay("ktsound6.wav");
	else if(self.impulse == 68) ShowQizmo();
	
	else if(self.impulse == 69) ShowMessages();
	else if(self.impulse == 70) SendKillerMsg();
	else if(self.impulse == 71) SendVictimMsg();
	else if(self.impulse == 72) SendNewcomerMsg();

//	else if(self.impulse == CMD_qtimer) ToggleQTimer();
	else if(self.impulse == 73) ToggleQLag();
	else if(self.impulse == 74) ToggleQEnemy();
	else if(self.impulse == 77) ToggleQPoint();

    else if(self.impulse == 87) AdminKick();
    else if(self.impulse == 88) YesKick();
    else if(self.impulse == 89) DontKick();
    else if(self.impulse == 90) ListWhoNot();
    else if(self.impulse == 91) ChangeOvertime();
    else if(self.impulse == 92) ChangeOvertimeUp();
    else if(self.impulse == 93) VoteAdmin();
    else if(self.impulse == 94) VoteYes();
    else if(self.impulse == 95) VoteNo();
    else if(self.impulse == 79) BecomeCaptain();
    else if(self.impulse == 80) ToggleFreeze();
	else if(self.impulse == 96) Deathmsg();
    else if(self.impulse == 97) RandomPickup();
    else if(self.impulse == 98) SetOfficial();
#ifdef VWEP_TEST
    else if(self.impulse == 99) ToggleVwep();
#endif
}
