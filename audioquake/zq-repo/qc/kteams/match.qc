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
// match.qc

void() NextLevel;
void() StopTimer;
void(float skip_log) EndMatch;

float() CountALLPlayers =
{
	local entity p;
	local float num;

	num = 0;
    p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "") num = num + 1;
		p = find(p, classname, "player");
	}
	return num;
};

float() CountPlayers =
{
	local entity p;
	local float num;

	num = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && p.k_accepted == 2) num = num + 1;
		p = find(p, classname, "player");
	}
	return num;
};

float() CountRPlayers =
{
	local entity p;
	local float num;

	num = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && p.k_accepted == 2 && p.ready) num = num + 1;
		p = find(p, classname, "player");
	}
	return num;
};

float() CountTeams =
{
	local entity p, p2;
	local float num;
	local string s1, s2;

	num = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && p.k_accepted == 2) p.k_flag = 0;
		p = find(p, classname, "player");
	}
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && !p.k_flag && p.k_accepted == 2) {
			p.k_flag = 1;
			s1 = infokey(p, "team");
			if(s1 != "") {
				num = num + 1;
				p2 = find(p, classname, "player");
				while(p2 != world) {
					s1 = infokey(p, "team");
					s2 = infokey(p2, "team");
					if(s1 == s2) p2.k_flag = 1;
					p2 = find(p2, classname, "player");
				}
			}
		}
		p = find(p, classname, "player");
	}
	return num;
};

float() CountRTeams =
{
	local entity p, p2;
	local float num;
	local string s1, s2;

	num = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && p.k_accepted == 2) p.k_flag = 0;
		p = find(p, classname, "player");
	}
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && !p.k_flag && p.ready && p.k_accepted == 2) {
			p.k_flag = 1;
			s1 = infokey(p, "team");
			if(s1 != "") {
				num = num + 1;
				p2 = find(p, classname, "player");
				while(p2 != world) {
					s1 = infokey(p, "team");
					s2 = infokey(p2, "team");
					if(s1 == s2) p2.k_flag = 1;
					p2 = find(p2, classname, "player");
				}
			}
		}
		p = find(p, classname, "player");
	}
	return num;
};

float(float memcnt) CheckMembers =
{
	local entity p, p2;
	local string s1, s2;
	local float f1;

	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && p.k_accepted == 2) p.k_flag = 0;
		p = find(p, classname, "player");
	}
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && !p.k_flag && p.ready && p.k_accepted == 2) {
			p.k_flag = 1;
			f1 = 1;
			s1 = infokey(p, "team");
			if(s1 != "") {
				p2 = find(p, classname, "player");
				while(p2 != world) {
					s1 = infokey(p, "team");
					s2 = infokey(p2, "team");
					if(s1 == s2) {
						p2.k_flag = 1;
						f1 = f1 + 1;
					}
					p2 = find(p2, classname, "player");
				}
			}
			if(f1 < memcnt) return 0;
		}
		p = find(p, classname, "player");
	}
	return 1;
};

void(float skip_log) EndMatch =
{
	local entity p, p2;

	local string tmp, tmp2, s1;
	local float f1, f2, sumfrags, maxfrags, maxdeaths, maxfriend, maxeffi;

	if(match_over) return;
// s: zero the flag
	k_sudden_death = 0;
	tmp = infokey(world, "k_host");
	if(tmp != "") cvar_set("hostname", tmp);
	match_over = 1;
	k_berzerk = 0;
	lightstyle(0, "m");
	f1 = stof(infokey(world, "fpd"));
	f1 = f1 - (f1 & 64);
	localcmd("serverinfo fpd ");
	tmp = ftos(f1);
	localcmd(tmp);
	localcmd("\nsv_spectalk 1\n");
	bprint(2, "The match is over\n");
	dprint("RESULT");

	if(skip_log) dprint("%stopped\n");
	else {
		p = find(world, classname, "player");
		while(p != world) 
		{
			if(p.netname != "" && p.k_accepted == 2) 
			{
				dprint("%", p.netname);
				tmp = infokey(p, "team");
				dprint("%t%", tmp);
				tmp = ftos(p.frags);
				dprint("%fr%", tmp);
				p.ready = 0;
// take away powerups so scoreboard looks normal
				p.items = p.items - (p.items & 7864320);
				p.effects = p.effects - (p.effects & 200);
				p.invisible_finished = 0;
				p.invincible_finished = 0;
				p.super_damage_finished = 0;
				p.radsuit_finished = 0;
//
			}
			p = find(p, classname, "player");
		}
		tmp = ftos(fraglimit);
		dprint("%fl%", tmp);
		tmp = ftos(timelimit);
		dprint("%tl%", tmp);
		dprint("%map%", mapname);
		dprint("\n");

                if(!stof(infokey(world, "k_duel")) && teamplay) {
// Summing up the frags to calculate team percentages
			p = find(world, classname, "player");
			while(p != world) {
				if(p.netname != "" && (infokey(p, "team") != "" && p.k_accepted == 2))
					sumfrags = sumfrags + p.frags;
				p = find(p, classname, "player");
			}
			p = find(world, classname, "ghost");
			while(p != world) {
				sumfrags = sumfrags + p.frags;
				p = find(p, classname, "ghost");
			}
// End of summing
			bprint(2, "\n‘Â·Ì Û„ÔÚÂÛ: ÊÚ·ÁÛ è ÂÚ„ÂÓÙ·ÁÂ\nùûûûûûûûûûûûûûûûûûûûûûûûûûûûûûü\n");
			p = find(world, classname, "player");
			while(p != world) {
				if(p.netname != "" && !p.ready && (infokey(p, "team") != "" && p.k_accepted == 2)) {
					p2 = p;
					f1 = 0;
					tmp = infokey(p, "team");
					bprint(2, "ê", tmp, "ë: ");
					while (p2 != world) {
						tmp = infokey(p, "team");
						tmp2 = infokey(p2, "team");
						if(tmp == tmp2) {
							f1 = f1 + p2.frags;
							p2.ready = 1;
						}
						p2 = find(p2, classname, "player");
					}
					f2 = 0;
					p2 = find(world, classname, "ghost");
					while(p2 != world) {
						if(!p2.ready) {
							s1 = ftos(p2.k_teamnum);
							tmp2 = infokey(world, s1);
							tmp = infokey(p, "team");
							if(tmp == tmp2) {
								f2 = f2 + p2.frags;
								p2.ready = 1;
							}
						}
						p2 = find(p2, classname, "ghost");
					}
					tmp = ftos(f1);
					bprint(2, tmp);
					if(f2) {
						bprint(2, " + (");
						tmp = ftos(f2);
						bprint(2, tmp, ") = ");
						tmp = ftos(f1 + f2);
						bprint(2, tmp);
					}
					if(sumfrags > 0)
						tmp = ftos((f1 + f2)/sumfrags * 100);
					else
						tmp = "0";
					bprint(2, " è", tmp, "%\n");
				}
				p = find(p, classname, "player");
			}
		}
		bprint(2, "\n");

		p = find(world, classname, "player");
		while(p != world) {
			p.ready = 1;
			p = find(p, classname, "player");
		}

// Player statistics printout here

// Probably low enough for a start value :)
		maxfrags = -99999;

		maxdeaths = 0;
		maxfriend = 0;
		maxeffi = 0;

		f1 = CountTeams();
		bprint(2, "–Ï·˘ÂÚ ÛÙ·ÙÈÛÙÈ„Û:\n∆Ú·ÁÛ (Ú·ÓÎ) ");
                if(!stof(infokey(world, "k_duel")) && f1 && teamplay)
			bprint(2, "ÊÚÈÂÓ‰ÎÈÏÏÛ ");
		bprint(2, "è ÂÊÊÈ„ÈÂÓ„˘\nùûûûûûûûûûûûûûûûûûûûûûûû");
                if(!stof(infokey(world, "k_duel")) && f1 && teamplay)
			bprint(2, "ûûûûûûûûûûûû");
		bprint(2, "ü\n");
		p = find(world, classname, "player");
		while(p != world) {
			if(p.netname != "" && p.k_accepted == 2 && p.ready) {
				p2 = p;
				while (p2 != world) {
					tmp = infokey(p, "team");
					tmp2 = infokey(p2, "team");
					if(tmp == tmp2) {
						bprint(2, "ê", tmp2, "ë ");
						bprint(2, p2.netname, ": ");
						tmp = ftos(p2.frags);
						bprint(2, tmp, " (");
						tmp = ftos(p2.frags - p2.deaths);
						bprint(2, tmp, ") ");
                                                if(!stof(infokey(world, "k_duel")) && f1 && teamplay) {
							tmp = ftos(p2.friendly);
							bprint(2, tmp, " ");
						}
						if(p2.frags < 1)
							p2.efficiency = 0;
						else
							p2.efficiency = p2.frags / (p2.frags + p2.deaths) * 100;
						tmp = ftos(p2.efficiency);
						if(floor(p2.efficiency) == p2.efficiency) bprint(2, "è ");
						else bprint(2, "è");
						bprint(2, tmp, "%\n");
						if (maxfrags < p2.frags) maxfrags = p2.frags;
						if (maxdeaths < p2.deaths) maxdeaths = p2.deaths;
						if (maxfriend < p2.friendly) maxfriend = p2.friendly;
						if (maxeffi < p2.efficiency) maxeffi = p2.efficiency;
						p2.ready = 0;
					}
					p2 = find(p2, classname, "player");
				}
			}
			p = find(p, classname, "player");
		}

                if(!stof(infokey(world, "k_duel"))) {
// Print the high score table
			bprint(2, "\n", mapname, " ÙÔ Û„ÔÚÂÚÛ:\nFrags      : ");
			tmp = ftos(maxfrags);
			f1 = 0;
			p = find(world, classname, "player");
			while(p != world) {
				if(p.netname != "" && p.k_accepted == 2)
					if(p.frags == maxfrags) {
						if(f1) bprint(2, "             ");
						f1 = 1;
						bprint(2, p.netname, " ê", tmp, "ë\n");
					}
				p = find(p, classname, "player");
			}
			f1 = 0;
			bprint(2, "Deaths     : ");
			tmp = ftos(maxdeaths);
			p = find(world, classname, "player");
			while(p != world) {
				if(p.netname != "" && p.k_accepted == 2)
					if(p.deaths == maxdeaths) {
						if(f1) bprint(2, "             ");
						f1 = 1;
						bprint(2, p.netname, " ê", tmp, "ë\n");
					}
				p = find(p, classname, "player");
			}
			if(maxfriend) {
				f1 = 0;
				bprint(2, "Friendkills: ");
				tmp = ftos(maxfriend);
				p = find(world, classname, "player");
				while(p != world) {
					if(p.netname != "" && p.k_accepted == 2)
						if(p.friendly == maxfriend) {
							if(f1) bprint(2, "             ");
							f1 = 1;
							bprint(2, p.netname, " ê", tmp, "ë\n");
						}
					p = find(p, classname, "player");
				}
			}
			f1 = 0;
			bprint(2, "Efficiency : ");
			tmp = ftos(maxeffi);
			p = find(world, classname, "player");
			while(p != world) {
				if(p.netname != "" && p.k_accepted == 2)
					if(p.efficiency == maxeffi) {
						if(f1) bprint(2, "             ");
						f1 = 1;
						bprint(2, p.netname, " ê", tmp, "%ë\n");
					}
				p = find(p, classname, "player");
			}
		}
		bprint(2, "\n");
	}

	p = find(world, classname, "ghost");
	while(p != world) {
		remove(p);
		p = find(p, classname, "ghost");
	}
	StopTimer();
	f1 = 666;
	while(k_teamid >= f1) {
		tmp = ftos(f1);
		localcmd("localinfo ");
		localcmd(tmp);
		localcmd(" \"\"\n");
		f1 = f1 + 1;
	}
	f1 = 1;
	while(k_userid >= f1) {
		tmp = ftos(f1);
		localcmd("localinfo ");
		localcmd(tmp);
		localcmd(" \"\"\n");
		f1 = f1 + 1;
	}
	NextLevel();
};

void() TimerThink =
// Called every second during a match. cnt = minutes, cnt2 = seconds left.
// Tells the time every now and then.
{
	local string tmp, tmp2;
	local entity p;
	local float f1, f2, f3, f4, k_overtime , k_exttime, player1scores,player2scores, player1found;

	f1 = 0;

	// moved out the score checking every second to every minute only.  And if someone
	// types scores it recalculates it for them.

	if(k_sudden_death) return;      

	if(k_pause) {
		self.nextthink = time + 1;
		return;
	}
	if(self.k_teamnum < time && !k_checkx) {
		k_checkx = 1;
	}
	if(!f1) f1 = CountPlayers();
	if(!f1) {
		EndMatch(1);
		return;
	}
	self.cnt2 = self.cnt2 - 1;

      if(k_berzerkenabled){
                f1 = k_berzerkenabled;
		f2 = floor(f1 / 60);
		f1 = f1 - (f2 * 60);
		f2 = f2 + 1;
		if(self.cnt2 == f1 && self.cnt == f2) {
			bprint(2, "BERZERK!!!!\n");
			lightstyle(0, "ob");
			k_berzerk = 1;
			p = find(world, classname, "player");

		while(p != world) {
				if(p.netname != "" && p.health > 0) {
					p.items = p.items | (4194304 | 1048576);
					p.super_time = 1;
					p.super_damage_finished = time + 3600;
					p.invincible_time = 1;
					p.invincible_finished = time + 2;
					p.k_666 = 1;
				}
				p = find(p, classname, "player");
			}
		}
	}

	if(!self.cnt2) 
	{
		self.cnt2 = 60;
		self.cnt = self.cnt - 1;
		localcmd("serverinfo status \"");
		tmp = ftos(self.cnt);
		localcmd(tmp);
		localcmd(" min left\"\n");

		if( (k_showscores) && k_nochange == 0)
		{
			// Calculate the Scores every 60 seconds.
			k_scores1 = 0;
			k_scores2 = 0;

			p = find(world, classname, "player");
			while(p != world) 
			{
				if(p.netname != "" && p.k_accepted == 2) 
				{
					f1 = f1 + 1;
					tmp = infokey(world, "k_team1");
					tmp2 = infokey(p, "team");
					if(tmp == tmp2) k_scores1 = k_scores1 + p.frags;
					else k_scores2 = k_scores2 + p.frags;
				}
				p = find(p, classname, "player");
			}

			p = find(world, classname, "ghost");
			while(p != world) 
			{
				tmp = ftos(p.k_teamnum);
				tmp2 = infokey(world, tmp);
				tmp = infokey(world, "k_team1");
				if(tmp == tmp2) k_scores1 = k_scores1 + p.frags;
				else k_scores2 = k_scores2 + p.frags;
				p = find(p, classname, "ghost");
			}

		}
		if(!self.cnt)
		{
			k_overtime = stof(infokey(world, "k_overtime"));
			
			// If 0 no overtime, 1 time, 2 sudden death
			// And if its neither then well we exit
			if(k_overtime)
			{
				f3 = CountTeams();
				f4 = CountPlayers();
				k_exttime = stof(infokey(world, "k_exttime"));
				
                // Overtime.
				// Ok we have now decided that the game is ending so decide overtime wise here what to do.
				// Check to see if duel first
				if(f4 == 2)
				if(f4 < 3)
				{
					p = find(world, classname, "player");
					while(p != world) 
					{
						if(p.netname != "" && player1found==0) 
						{
                                          player1scores = p.frags;
							player1found = 1;					
						}
						else
						{
                                          player2scores = p.frags;
						}

						p = find(p, classname, "player");
					}
					
					// In player1scores and player2scores we have scores(lol?)
					if(player1scores == player2scores)
					{
						bprint(3, "Time over, the game is a draw\n");
						if(k_overtime == 1) {
							// Ok its increase time
							self.cnt = k_exttime;
							self.cnt2 = 60;
							tmp = ftos(k_exttime);
							bprint(2, "ê", tmp, "ë minute");
							if(k_exttime != 1) bprint(2, "'s");
							bprint(2, " overtime follows\n");
							self.nextthink = time + 1;
							return;	
						} else {
							bprint(2, "Sudden death ÔˆÂÚÙÈÌÂ ‚ÂÁÈÓÛ\n");
						// added timer removal at sudden death beginning
							k_sudden_death = 1;
							p = find(world, classname, "timer");
							while(p != world) {
								p.nextthink = time + 0.1;
								p.think = SUB_Remove;
								p = find(p, classname, "timer");
							}
							return;
						}
					}
				}
				// Or it can be a team game.
				// Handle a 2v2 or above team game
				else if(f3 == 2 && f4 > 2 && k_scores1 == k_scores2)
				{
					bprint(3, "Time over, the game is a draw\n");
					if(k_overtime == 1)
					{
						// Ok its increase time
						self.cnt = k_exttime;
						self.cnt2 = 60;
						tmp = ftos(k_exttime);
						bprint(2, "ê", tmp, "ë minute");
						if(k_exttime != 1) bprint(2, "'s");
						bprint(2, " overtime follows\n");
						self.nextthink = time + 1;
						return;	
					} else {
						bprint(2, "Sudden death ÔˆÂÚÙÈÌÂ ‚ÂÁÈÓÛ\n");
					// added timer removal at sudden death beginning
						k_sudden_death = 1;
						p = find(world, classname, "timer");
						while(p != world) {
							p.nextthink = time + 0.1;
							p.think = SUB_Remove;
							p = find(p, classname, "timer");
						}
						return;
					}
				}
			}
			EndMatch(0);
			return;
		}

		tmp = ftos(self.cnt);
		bprint(2, "ê", tmp, "ë minute");
		if(self.cnt != 1) bprint(2, "s");
		bprint(2, " remaining\n");
		self.nextthink = time + 1;
		if(k_showscores) {
			if(k_scores1 == k_scores2) {
				bprint(2, "The game is currently a tie\n");
			} else if(k_scores1 > k_scores2) {
				f1 = k_scores1 - k_scores2;
				tmp = infokey(world, "k_team1");
				bprint(2, "‘Â·Ì ê", tmp, "ë leads by ");
				tmp = ftos(f1);
				bprint(2, tmp, " frag");
// changed output to plural only if necessary :) (no (s))
                                if(f1 == 1) bprint(2, "\n");
				else bprint(2, "s\n");
			} else {
				tmp = infokey(world, "k_team2");
				bprint(2, "‘Â·Ì ê", tmp, "ë leads by ");
				f1 = k_scores2 - k_scores1;
				tmp = ftos(f1);
				bprint(2, tmp, " frag");
// changed output to plural only if necessary :) (no (s))
                                if(f1 == 1) bprint(2, "\n");
				else bprint(2, "s\n");
			}
		}
		return;
	}

	if(self.cnt2 == 20 || self.cnt2 == 40)
	{
		CheckAll();
	}

	if((self.cnt == 1) && (self.cnt2 == 30 || self.cnt2 == 15 || self.cnt2 <= 10)) {

/*
// tick sound if remaining time < 6 seconds
		if(self.cnt2 < 6) {
			p = find(world, classname, "player");
			while(p != world) {
			if(p.netname != "")
				stuffcmd (p, "play buttons/switch04.wav\n");
			p = find(p, classname, "player");
                        }
		}
*/
		tmp = ftos(self.cnt2);
		bprint(2, "ê", tmp, "ë second");
		if(self.cnt2 != 1) bprint(2, "s");
		bprint(2, "\n");
	}
	self.nextthink = time + 1;
};

void() StartMatch =
// Reset player frags and start the timer.
{
	local entity p, old, old2;
	local string tmp, s1;
	local float f1, f2;

	k_standby = 0;
	k_checkx = 0;
	k_userid = 1;
	k_teamid = 666;
	k_nochange = 0;	
	localcmd("localinfo 1 \"\"\n");
	localcmd("localinfo 666 \"\"\n");
	f1 = stof(infokey(world, "k_pow"));
	f2 = stof(infokey(world, "k_dm2mod"));
	p = findradius('0 0 0', 999999);


    // Check to see if berzerk is set.
    if(stof(infokey(world, "k_bzk"))) {
        k_berzerkenabled = stof(infokey(world, "k_btime"));
    } else {
            k_berzerkenabled = 0;
    }

	while(p) {
		old = p.chain;
//going for the if content record..
		if(deathmatch > 3) {
			if(p.classname == "rocket" || p.classname == "grenade" || p.classname == "trigger_changelevel"
				|| p.classname == "weapon_nailgun" || p.classname == "weapon_supernailgun"
				|| p.classname == "weapon_supershotgun" || p.classname == "weapon_rocketlauncher"
				|| p.classname == "weapon_grenadelauncher" || p.classname == "weapon_lightning"
				|| (!f1 && (p.classname == "item_artifact_invulnerability"
				|| p.classname == "item_artifact_super_damage"
				|| p.classname == "item_artifact_envirosuit"
				|| p.classname == "item_artifact_invisibility"))) remove(p);
		} else {
			if(p.classname == "rocket" || p.classname == "grenade" || p.classname == "trigger_changelevel"
				|| ((deathmatch == 2 && f2) &&
				(p.classname == "item_armor1" || p.classname == "item_armor2" || p.classname == "item_armorInv"))
				|| (!f1 && (p.classname == "item_artifact_invulnerability"
				|| p.classname == "item_artifact_super_damage"
				|| p.classname == "item_artifact_envirosuit"
				|| p.classname == "item_artifact_invisibility"))) remove(p);
		}
		p = old;
	}
	dprint("MATCH STARTED");
	p = find(world, classname, "player");
	match_in_progress = 2;
	while(p != world) {
		if(p.netname != "") {
		tmp = infokey(p, "team");
			dprint("%", p.netname);
			dprint("%t%", tmp);
			p.k_teamnum = 0;
			if(tmp != "") {
				f1 = 665;
				while(k_teamid > f1 && !p.k_teamnum) {
					f1 = f1 + 1;
					s1 = ftos(f1);
					s1 = infokey(world, s1);
					tmp = infokey(p, "team");
					if(tmp == s1) p.k_teamnum = f1;
				}
				if(!p.k_teamnum) {
					f1 = f1 + 1;
					s1 = ftos(f1);
					localcmd("localinfo ");
					localcmd(s1);
					localcmd(" \"");
					tmp = infokey(p, "team");
					localcmd(tmp);
					localcmd("\"\n");
					k_teamid = f1;
					p.k_teamnum = f1;
				}
			} else p.k_teamnum = 666;
			p.frags = 0;
			p.deaths = 0;
			p.friendly = 0;
			old = self;
			self = p;
			SetChangeParms();
			PutClientInServer();
			self = old;
		}
		p = find(p, classname, "player");
	}
	dprint("\n");

	bprint(2, "The match has begun!\n");
	tmp = infokey(world, "k_spectalk");
	localcmd("sv_spectalk ");
	localcmd(tmp);
	localcmd("\n");
	f2 = stof(tmp);
	f1 = stof(infokey(world, "fpd"));
	f1 = f1 - (f1 & 64) + (f2 * 64);
	localcmd("serverinfo fpd ");
	tmp = ftos(f1);
	localcmd(tmp);
	k_vbreak = 0;
	k_berzerk = 0;
	k_showscores = 0;

	self.k_teamnum = time + 3;  //dirty i know, but why waste space?
	self.cnt = timelimit / 60;  //oldman: add a stupid divide by 60 here to fix kteams?
	self.cnt2 = 60;
	localcmd("\nserverinfo status \"");
	tmp = ftos(timelimit);
	localcmd(tmp);
	localcmd(" min left\"\n");
	self.think = TimerThink;
	self.nextthink = time + 1;
	tmp = infokey(world, "hostname");
	localcmd("localinfo k_host \"");
	localcmd(tmp);
	localcmd("\"\n");
	f1 = CountRTeams();
	f2 = CountPlayers();

        if(f1 == 2 && f2 > 2)
        {
		k_showscores = 1;
		f2 = 0;
		old = world;
		p = find(world, classname, "player");
		while(p != world && !f2) {
			if(p.netname != "")
                        {
				tmp = infokey(p, "team");
				localcmd("localinfo k_team1 \"");
				localcmd(tmp);
				localcmd("\"\n");
				f2 = 1;
				old = p;
			}
			p = find(p, classname, "player");


	}
		while(p != world && f2)
                {
			if(p.netname != "") {
				tmp = infokey(p, "team");
				s1 = infokey(old, "team");
				if(tmp != s1) {
					localcmd("localinfo k_team2 \"");
					localcmd(tmp);

					localcmd("\"\n");
					old2 = p;
					f2 = 0;
				}
			}
			p = find(p, classname, "player");
		}
		tmp = infokey(world, "hostname");
		localcmd("serverinfo hostname \"");
		localcmd(tmp);
		localcmd(" (");
		tmp = infokey(old, "team");
		localcmd(tmp);
		localcmd(" vs. ");
		tmp = infokey(old2, "team");
		localcmd(tmp);
		localcmd(")\"\n");
	}
};

void() TimerStartThink =
// Called every second during the countdown.
{
	local entity p;
	local float num, f1, f2, f3;

	self.cnt2 = self.cnt2 - 1;
	if(self.cnt2 == 1)
        {
		k_standby = 1;
		p = find(world, classname, "player");
		while(p != world) {
			if(p.netname != "")
                  {
				//set to ghost 1 second before matchstart
				p.takedamage = 0;
				p.solid = 0;
				p.movetype = 0;
				p.modelindex = 0;
				p.model = string_null;
			}
			p = find(p, classname, "player");
		}
	}
        else if(!self.cnt2)
        {
		WriteByte(2, 26);
		WriteString(2, "");
		f2 = stof(infokey(world, "k_lockmin"));
		f3 = stof(infokey(world, "k_lockmax"));
		f1 = CountRTeams();
		num = stof(infokey(world, "k_membercount"));
		if(!num) num = 1;
		else num = CheckMembers(num);
		if(f1 < f2 || f1 > f3 || !num) {
			bprint(2, "Illegal number of teams or players\naborting...\n");
			self.nextthink = time + 0.1;
			self.think = SUB_Remove;
			match_in_progress = 0;

			// Stops the bug where players are set to ghosts 1 second to go and countdown aborts.
			// standby flag needs clearing (sturm)
			k_standby = 0;
			p = find(world, classname, "player");
			while(p != world) 
			{
				if(p.netname != "")
				{
					p.takedamage = 2;
					p.solid = 3;
					p.movetype = 3;
				}
				p = find(p, classname, "player");
			}
			localcmd("serverinfo status Standby\n");
			return;
		}
		StartMatch();
		return;
	}

	num = floor(self.cnt2 / 10);
	WriteByte(2, 26);
	WriteShort(2, 49930);   // \nC
	WriteShort(2, 62959);   // ou
	WriteShort(2, 62702);   // nt
	WriteShort(2, 61412);   // do
	WriteShort(2, 61175);   // wn
	WriteShort(2, 8250);    // :
	if(num) WriteByte(2, num + 146);
	num = self.cnt2 - num * 10;
	WriteByte(2, num + 146);
	WriteShort(2, 2570); // 0x0A0A = \n\n
	WriteByte(2, 10);
//deathmatch  x
	WriteShort(2, 25924);
	WriteShort(2, 29793);
	WriteShort(2, 28008);
	WriteShort(2, 29793);
	WriteShort(2, 26723);
	WriteShort(2, 8224);
	WriteByte(2, deathmatch + 146);
//(teamplay    x)
	if(teamplay) {
		WriteByte(2, 10);
		WriteShort(2, 25940);
		WriteShort(2, 28001);
		WriteShort(2, 27760);
		WriteShort(2, 31073);
		WriteShort(2, 8224);
		WriteShort(2, 8224);
		WriteByte(2, teamplay + 146);
	}
//(timelimit  xx)
	if(timelimit) {
		WriteShort(2, 21514);
		WriteShort(2, 28009);
		WriteShort(2, 27749);
		WriteShort(2, 28009);
		WriteShort(2, 29801);
		WriteShort(2, 8224);
		f1 = timelimit;
		num = floor(f1 / 10);
		f1 = f1 - (num * 10);
		if(num) WriteByte(2, num + 146);
		else WriteByte(2, 32);
		WriteByte(2, f1 + 146);
	}
//(fraglimit xxx)
	if(fraglimit) {
		WriteShort(2, 17930);
		WriteShort(2, 24946);
		WriteShort(2, 27751);
		WriteShort(2, 28009);
		WriteShort(2, 29801);
		WriteByte(2, 32);
		f1 = fraglimit;
		num = floor(f1 / 100);
		f1 = f1 - (num * 100);
		if(num) WriteByte(2, num + 146);
		else WriteByte(2, 32);
		num = floor(f1 / 10);
		f1 = f1 - (num * 10);
		WriteByte(2, num + 146);
		WriteByte(2, f1 + 146);
	}
// overtime printout, supports sudden death display
// overtime xx
	f1 = stof(infokey(world, "k_overtime"));
	if(f1) {
		WriteShort(2, 20234);
		WriteShort(2, 25974);
		WriteShort(2, 29810);
		WriteShort(2, 28009);
		WriteShort(2, 8293);
		WriteShort(2, 8224);
		if(f1 == 1) {
			f1 = stof(infokey(world, "k_exttime"));
			num = floor(f1 / 10);
			f1 = f1 - (num * 10);
			if(num) WriteByte(2, num + 146);
			else WriteByte(2, 32);
			WriteByte(2, f1 + 146);
		} else
			WriteShort(2, 58611);
	}
	WriteByte(2, 10);
	f1 = stof(infokey(world, "k_pow"));
	if(f1)
	{
		WriteShort(2, 59895);
		WriteShort(2, 59636);
	}
	else    WriteShort(2, 61422);
	if(f1 == 2) WriteString(2, " powerups (jammed)");
	else WriteString(2, " powerups");

// countdown printouts end here

	if(self.cnt2 < 6)
	{
		p = find (world, classname, "player");
		while(p != world)
		{
			if(p.netname != "") 
			stuffcmd (p, "play buttons/switch04.wav\n");
			p = find (p, classname, "player");
		}
	}


	self.nextthink = time + 1;
};

void() StartTimer =
// Spawns the timer and starts the countdown.
{
	local entity timer;
	local float f1;

	k_force = 0;
	timer = find(world, classname, "idlebot");
	if(timer != world) remove(timer);
	timer = find(world, classname, "timer");
	while(timer != world) {
		remove(timer);
		timer = find(timer, classname, "timer");
	}

	bprint(2, "Spawnmodel: ");
	f1 = stof(infokey(world, "k_spw"));
	if(f1 == 2) bprint(2, "ÀÔÌ‚·Ù ‘Â·ÌÛ ÚÂÛ·˜ÓÛ\n");
	else if(f1 == 1) bprint(2, "À‘ ”·˜Ó”·ÊÂÙ˘\n");
	else bprint(2, "ŒÔÚÌ·Ï —◊ ÚÂÛ·˜ÓÛ\n");

// changed to print only if other than default

	f1 = stof(infokey(world, "k_frp"));
	if(f1) {
// Output the Fairpack setting here
		bprint(2, "Fairpacks setting: ");
		if(f1 == 1) bprint(2, "‚ÂÛÙ ˜Â·ÔÓ\n");
		else bprint(2, "Ï·ÛÙ ˜Â·ÔÓ ÊÈÚÂ‰\n");
	}

// print qizmo settings
	f1 = stof(infokey(world, "fpd"));
	if(f1 & 170) {
		bprint(2, "QiZmo:");
		if(f1 & 2) bprint(2, " ÙÈÌÂÚ");
		if(f1 & 8) bprint(2, " Ï·Á");
		if(f1 & 32) bprint(2, " ÂÓÂÌ˘");
		if(f1 & 128) bprint(2, " ÔÈÓÙ");
		bprint(2, " disabled\n");
	}

	timer = find(world, classname, "player");
	while(timer != world) {
		if(timer.netname != "") stuffcmd(timer, "play items/protect2.wav\n");
		timer = find(timer, classname, "player");
	}
	timer = spawn();
	timer.owner = world;
	timer.classname = "timer";
	timer.cnt = 0;
	if(stof(infokey(world, "k_count")))
        timer.cnt2 = stof(infokey(world, "k_count"));
    else
        timer.cnt2 = 3; // at the least we want a 3 second countdown
	timer.cnt2 = timer.cnt2 + 1;
    timer.nextthink = time + 0.1;
	timer.think = TimerStartThink;
	match_in_progress = 1;
	localcmd("serverinfo status Countdown\n");
};

void() StopTimer =
// Whenever a countdown or match stops, remove the timer and reset everything.

{
	local entity t;

	k_force = 0;
	match_in_progress = 0;
	t = find(world, classname, "timer");
	while(t != world) {
		t.nextthink = time + 0.1;
		t.think = SUB_Remove;
		t = find(t, classname, "timer");
	}
	localcmd("serverinfo status Standby\n");
};

void() IdlebotThink =
{
	local entity p;
	local string s1;
	local float f1, f2, f3;

	self.attack_finished = self.attack_finished - 1;
	f1 = CountPlayers();
	f2 = CountRPlayers();
	f3 = f1 / 2;
	if(f3 > f2 || f1 < 2) {
		bprint(3, "console: bah! chickening out?\n");
		bprint(2, "server disables the idle bot\n");
		remove(self);
		return;
	}
	if(self.attack_finished < 1) {
		BotForceStart();
		remove(self);
		return;
	} else {
		f1 = floor(self.attack_finished / 5);
		if(self.attack_finished < 5 || (f1 * 5) == self.attack_finished) {
			if(self.attack_finished == 1) {
				p = find(world, classname, "player");
				while(p != world) {
					if(p.netname != "" && !p.ready) sprint(p, 3, "console: 1 second to go ready\n");
					p = find(p, classname, "player");
				}
			} else {
				s1 = ftos(self.attack_finished);
				p = find(world, classname, "player");
				while(p != world) {
					if(p.netname != "" && !p.ready) sprint(p, 3, "console: ", s1, " seconds to go ready\n");
					p = find(p, classname, "player");
				}
			}
		}
	}
	self.nextthink = time + 1;
};

void() IdlebotCheck =
{
	local entity p;
	local float f1, f2, f3;
	local string s1;

	if(match_in_progress) return;
	f1 = CountPlayers();
	f2 = CountRPlayers();
	f3 = f1 / 2;
	if(f2 >= f3 && f1 > 1) {
//50% or more of the players are ready! go-go-go
		p = find(world, classname, "idlebot");
		if(p != world) return;
		else {
			p = spawn();
			p.classname = "idlebot";
			p.think = IdlebotThink;
			p.nextthink = time + 1;
			s1 = infokey(world, "k_idletime");
			f1 = stof(s1);
			p.attack_finished = f1;
			bprint(2, "\nserver activates the idle bot\n");
			p = find(world, classname, "player");
			while(p != world) {
				if(p.netname != "" && !p.ready) sprint(p, 3, "console: ", s1, " seconds to go ready\n");
				p = find(p, classname, "player");
			}
		}
	} else {

		p = find(world, classname, "idlebot");
		if(p != world) {
			bprint(3, "console: bah! chickening out?\n");
			bprint(2, "server disables the idle bot\n");
			remove(p);
		}
	}
};

void() PlayerReady =
// Called by a player to inform that (s)he is ready for a match.
{
	local entity p;
	local float nready, f1, k_lockmin, k_lockmax;
	local string tmp, s1, s2;

	if(intermission_running || match_in_progress == 2) return;
	if(self.ready) {
		sprint(self, 2, "Type break to unready yourself\n");
		return;
	}
	k_lockmin = stof(infokey(world, "k_lockmin"));
	k_lockmax = stof(infokey(world, "k_lockmax"));
        if(k_force && !stof(infokey(world, "k_duel"))) {
		nready = 0;
		p = find(world, classname, "player");
		while(p != world) {
			if(p.netname != "" && p.ready) {
				s1 = infokey(self, "team");
				s2 = infokey(p, "team");
				if(s1 == s2 && s1 != "") nready = 1;
			}
			p = find(p, classname, "player");
		}
		if(!nready) {
			sprint(self, 2, "Join an existing team!\n");
			return;
		}
	}
	self.ready = 1;
	self.k_vote = 0;
	self.effects = self.effects - (self.effects & 64);
	self.k_teamnum = 0;
	bprint(2, self.netname, " is ready ê");
	tmp = infokey(self, "team");
	bprint(2, tmp, "ë\n");
	nready = 0;
	p = find(world, classname, "player");
	while(p != world) {
		if(p.netname != "" && p.ready) nready = nready + 1;
		p = find(p, classname, "player");
	}

	f1 = CountRTeams();
	if(f1 < k_lockmin) {
		tmp = ftos(k_lockmin - f1);
		bprint(2, tmp);
		bprint(2, " ÌÔÚÂ ÙÂ·Ì");
		if((k_lockmin - f1) != 1) bprint(2, "Û");
		bprint(2, " ÚÂÒıÈÚÂ‰\n");

		return;
	}
	if(f1 > k_lockmax) {
		bprint(2, "«ÂÙ ÚÈ‰ ÔÊ ");
		tmp = ftos(f1 - k_lockmax);
		bprint(2, tmp);
		bprint(2, " ÙÂ·Ì");
		if((f1 - k_lockmax) != 1) bprint(2, "Û");
		bprint(2, "!\n");
		return;
	}
	k_attendees = CountPlayers();
	f1 = stof(infokey(world, "k_membercount"));
	if(CheckMembers(f1)) {
		if(nready == k_attendees && nready >= 2 && !k_force) {
			bprint(2, "All players ready\nTimer started\n");

			StartTimer();
			if(stof(infokey(world, "k_idletime"))) {
				p = find(world, classname, "idlebot");
				if(p != world) remove(p);
			}
			return;
		}
	} else if(nready == k_attendees && nready >=2 && !k_force) {
		s1 = infokey(world, "k_membercount");
		bprint(2, "”ÂÚˆÂÚ ˜·ÓÙÛ ·Ù ÏÂ·ÛÙ ", s1, " Ï·˘ÂÚÛ ÈÓ Â·„Ë ÙÂ·Ì\nWaiting...\n");
		return;
	}
	if(stof(infokey(world, "k_idletime")) && !k_force) IdlebotCheck();
};

void() PlayerBreak =
{
	local entity p;
	local float f1, f2;

	if(!self.ready) return;
	if(!match_in_progress) {
		self.ready = 0;
		bprint(2, self.netname, " is not ready\n");
		if(stof(infokey(world, "k_sready"))) self.effects = self.effects + 64;
		return;
	}
	if(match_in_progress == 1) {
		p = find(world, classname, "timer");
		if(p.cnt2 > 1) {
			self.ready = 0;
			bprint(2, self.netname, " stops the countdown\n");
			if(stof(infokey(world, "k_sready"))) self.effects = self.effects + 64;

			StopTimer();
		}
		return;
	}
	if(self.k_vote) {
		bprint(2, self.netname, " ˜ÈÙË‰Ú·˜Û ");
		if(infokey(self, "gender") == "f") bprint(2, "ËÂÚ ");
		else bprint(2, "ËÈÛ ");
		bprint(3, "vote\n");
		self.k_vote = 0;
		k_vbreak = k_vbreak - 1;
		return;
	}
	bprint(3, self.netname, " votes for stopping the match\n");
	self.k_vote = 1;
	k_vbreak = k_vbreak + 1;
	f1 = CountPlayers();
	f2 = (floor(f1 / 2)) + 1;
	if(k_vbreak >= f2) {
		bprint(2, "Match stopped by majority vote\n");
		EndMatch(1);
		return;
	}
};
