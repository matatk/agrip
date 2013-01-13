/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotName

Sets bot's name and colors

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
string BotName (entity ent, float r) 
{
	self.b_num = r;
	if (r == 1)
	{	
		ent.b_pants = 11;
		ent.b_shirt = 0; 
		return "Vincent";
	}
	else if (r == 2)
	{
		ent.b_pants = 1;
		ent.b_shirt = 3;
		return "Bishop";
	}
	else if (r == 3)
	{	
		ent.b_pants = 13;
		ent.b_shirt = 2;
		return "Nomad";
	}
	else if (r == 4)
	{
		ent.b_pants = 7;
		ent.b_shirt = 6;
		return "Hudson";
	} 
	else if (r == 5)
	{
		ent.b_pants = 12;
		ent.b_shirt = 6;
		return "Lore";
	}
	else if (r == 6)
	{
		ent.b_pants = 4;
		ent.b_shirt = 4;
		return "Servo";
	}
	else if (r == 7)
	{
		ent.b_pants = 2;
		ent.b_shirt = 5;
		return "Gort";
	} 
	else if (r == 8)
	{	
		ent.b_pants = 10;
		ent.b_shirt = 3;
		return "Kryten";
	}
	else if (r == 9)
	{
		ent.b_pants = 9;
		ent.b_shirt = 4;
		return "Pimp Bot";
	}
	else if (r == 10)
	{
		ent.b_pants = 4;
		ent.b_shirt = 7;
		return "Max";
	}
	else if (r == 11)
	{
		ent.b_pants = 3;
		ent.b_shirt = 11;
		return "Marvin";
	} 
	else if (r == 12)
	{
		ent.b_pants = 13;
		ent.b_shirt = 12;
		return "Erwin";
	}
	else if (r == 13)
	{
		ent.b_pants = 11;
		ent.b_shirt = 2;
		return "FrikBot";
	}
	else if (r == 14)
	{
		ent.b_pants = 0;
		ent.b_shirt = 2;
		return "Krosis";
	}
	else if (r == 15)
	{
		ent.b_pants = 8;
		ent.b_shirt = 9;
		return "Gypsy";
	}

	// if (r == 16)
	{
		ent.b_pants = 5;
		ent.b_shirt = 10;
		return "Hal";
	}
}

string PickARandomName (entity ent)
{
	if (bot_count > 16)
		return "player";

	float	y, test;
	string	h;
	entity	t;
	y = true;
	while(y)
	{
		test = ceil(random() * 16);
		h = BotName(ent, test);
		t = find(world, netname, h);
		if (t == world)
			y = false;
	}
	return h;
}



// I didn't like the old code so this is very stripped down

entity b_originator;
float b_topic;
/* FBX Topics

b_originator == self
 1 - sign on
 2 - killed targ
 3 - team message "friendly eyes"
 4 - team message "on your back"
 5 - team message "need back up"
 6 - excuses
 ----
 7 - gameover
 ----
 8 - welcoming someone onto server
 9 - ridicule lost frag (killed self?)
 10 - ridicule lost frag (lava)
 11 - lag
b_originator == targ

 
*/
void bot_start_topic (float tpic)
{
	if (random() < 0.2)
	{
		b_topic = tpic;
		b_originator = self;
	}
	else
		b_topic = 0;
}

void bot_chat ()
{
	float	r;
	if (b_options & OPT_NOCHAT)
		return;
	r = ceil (random() * 6);
	
	if (self.b_chattime > time)
	{
		if (self.b_skill < 2)
			self.keys = self.button0 = self.button2 = 0;
		return;
	}
	else if (self.b_chattime)
	{
		if (b_topic == 1)
		{
			if (b_originator == self)
			{
				if (r == 1)
				{
					BotSay(": lo all\n");
					bot_start_topic(8);
				}
				else if (r == 2)
				{
					BotSay(": hey everyone\n");
					bot_start_topic(8);
				}
				else if (r == 3)
				{
					BotSay(": prepare to be fragged!\n");
					bot_start_topic(0);
				}
				else if (r == 4)
				{
					BotSay(": boy this is laggy\n");
					bot_start_topic(11);
				}
				else if (r == 5)
				{
					BotSay(": #mm getting some lag here\n");
					bot_start_topic(11);
				}
				else
				{
					BotSay(": hi everyone\n");
					bot_start_topic(8);
				}
			}
		}
		else if (b_topic == 2)
		{
			if (b_originator == self)
			{
				if (r == 1)
					BotSay(": take that\n");
				else if (r == 2)
					BotSay(": yehaww!\n");
				else if (r == 3)
					BotSay(": wh00p\n");
				else if (r == 4)
					BotSay(": j00_sawk();\n");
				else if (r == 5)
					BotSay(": i rule\n");
				else
					BotSay(": eat that\n");
				bot_start_topic(0);
			}
		}
		else if (b_topic == 3)
		{
			if (b_originator == self)
			{
				if (r < 3)
					BotSayTeam(": friendly eyes\n");
				else
					BotSayTeam(": team eyes\n");
				bot_start_topic(0);
			}
		}
		else if (b_topic == 4)
		{
			if (b_originator == self)
			{
				if (r < 3)
					BotSayTeam(": on your back\n");
				else
					BotSayTeam(": I'm with you\n");
				bot_start_topic(0);
			}
		}
		else if (b_topic == 5)
		{
			if (b_originator == self)
			{
				if (r < 3)
					BotSayTeam(": I need help\n");
				else
					BotSayTeam(": need backup\n");
				bot_start_topic(0);
			}
		}
		else if (b_topic == 6)
		{
			if (b_originator == self)
			{
				if (r == 1)
				{
					BotSay(": sun got in my eyes\n");
					bot_start_topic(0);
				}
				else if (r == 2)
				{
					BotSay(": mouse needs cleaning\n");
					bot_start_topic(0);
				}
				else if (r == 3)
				{
					BotSay(": i meant to do that\n");
					bot_start_topic(0);
				}
				else if (r == 4)
				{
					BotSay(": lag\n");
					bot_start_topic(11);
				}
				else if (r == 5)
				{
					BotSay(": killer lag\n");
					bot_start_topic(11);
				}
				else
				{
					BotSay(": 100% lag\n");
					bot_start_topic(11);
				}
			}
		}
		else if (b_topic == 7)
		{
			if (r == 1)
				BotSay(": gg\n");
			else if (r == 2)
				BotSay(": gg all\n");
			else if (r == 3)
				BotSay(": that was fun\n");
			else if (r == 4)
				BotSay(": good game\n");
			else if (r == 5)
				BotSay(": pah\n");
			else
				BotSay(": hrm\n");
			bot_start_topic(0);
		}
		else if (b_topic == 8)
		{
			if (b_originator != self)
			{
				if (r == 1)
				{
					BotSay(": heya\n");
					bot_start_topic(0);
				}
				else if (r == 2)
				{
					BotSay(": welcome\n");
					bot_start_topic(0);
				}
				else if (r == 3)
				{
					BotSayInit();
					BotSay2(": hi ");
					BotSay2(b_originator.netname);
					BotSay2("\n");
					bot_start_topic(0);
				}
				else if (r == 4)
				{
					BotSayInit();
					BotSay2(": hey ");
					BotSay2(b_originator.netname);
					BotSay2("\n");
					bot_start_topic(0);
				}
				else if (r == 5)
				{
					BotSay(": howdy\n");
					bot_start_topic(0);
				}
				else
				{
					BotSay(": lo\n");
					bot_start_topic(0);	
				}
			}
		}

		else if (b_topic == 9)
		{
			if (b_originator != self)
			{
				if (r == 1)
					BotSay(": hah\n");
				else if (r == 2)
					BotSay(": heheh\n");
				else if (r == 3)
				{
					BotSayInit();
					BotSay2(": good work ");
					BotSay2(b_originator.netname);
					BotSay2("\n");
				}
				else if (r == 4)
				{
					BotSayInit();
					BotSay2(": nice1 ");
					BotSay2(b_originator.netname);
					BotSay2("\n");
				}
				else if (r == 5)
					BotSay(": lol\n");
				else
					BotSay(": :)\n");
				b_topic = 6;
			}
		}
		else if (b_topic == 10)
		{
			if (b_originator != self)
			{
				if (r == 1)
					BotSay(": have a nice dip?\n");
				else if (r == 2)
					BotSay(": bah I hate levels with lava\n");
				else if (r == 3)
				{
					BotSayInit();
					BotSay2(": good job ");
					BotSay2(b_originator.netname);
					BotSay2("\n");
				}
				else if (r == 4)
				{
					BotSayInit();
					BotSay2(": nice backflip ");
					BotSay2(b_originator.netname);
					BotSay2("\n");
				}
				else if (r == 5)
					BotSay(": watch your step\n");
				else
					BotSay(": hehe\n");
				b_topic = 6;
			}
		}

		else if (b_topic == 11)
		{
			if (b_originator != self)
			{
				if (r == 1)
				{
					BotSayInit();
					BotSay2(": yeah right ");
					BotSay2(b_originator.netname);
					BotSay2("\n");
					bot_start_topic(0);
				}
				else if (r == 2)
				{
					BotSay(": ping\n");
					bot_start_topic(0);
				}
				else if (r == 3)
				{
					BotSay(": shuddup, you're an lpb\n");
					bot_start_topic(0);
				}
				else if (r == 4)
				{
					BotSay(": lag my eye\n");
					bot_start_topic(0);
				}
				else if (r == 5)
				{
					BotSay(": yeah\n");
					bot_start_topic(11);
				}
				else
				{
					BotSay(": totally\n");
					bot_start_topic(11);
				}
			}
		}
		self.b_chattime = 0;
	}
	else if (b_topic)
	{
		if (random() < 0.5)
		{
			if (self == b_originator)
			{
				if (b_topic <= 7)
					self.b_chattime = time + 2;
			}
			else
			{
				if (b_topic >= 7)
					self.b_chattime = time + 2;
			}
		}
	}
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Kick A Bot. 

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void KickABot ()
{
	entity	ty;
	ty = find(world, classname, "player");
	while (ty != world)
	{
		if (!ty.ishuman) {
			
			stuffcmd (ty, "disconnect\n");
			ty = world;
		}
		else
			ty = find(ty, classname, "player");
	}

}


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Simplified origin checking. 

God, I wish I had inline

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

vector realorigin (entity ent)
{
// even more simplified...
	return (ent.absmin + ent.absmax) * 0.5;
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

fisible

a version of visible that checks for corners
of the bounding boxes

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float fisible (entity targ)
{
	vector	spot1, org;
	float	thruwater, pc1, pc2;
	
	org = realorigin(targ);
	spot1 = self.origin + self.view_ofs;
	
	if (targ.solid == SOLID_BSP)
	{
		traceline (spot1, org, true, self);
		if (trace_ent == targ)
			return true;
		else if (trace_fraction == 1)
			return true;
		return false;
	}
	else
	{
		pc1 = pointcontents(org);
		pc2 = pointcontents(spot1);
		if (targ.classname == "player")
			thruwater = false;
		else if (pc1 == CONTENT_LAVA)
			return false;
		else	
			thruwater = true;
	}
	
	if (pc1 < -1) // targ's origin is in water or other liquid
	{
		if (pc2 != pc1)
		{
			// look for their head
			traceline (spot1, org + targ.mins, true, self);
			// cross the water check
			if (trace_inopen)
				if (trace_inwater)
					if (!thruwater)
						return false;
			if (trace_ent == targ)
				return true;
			else if (trace_fraction == 1)
				return true;
			return false;
		}
	}
	else
	{
		if (pc2 != pc1)
		{
			traceline (spot1, org + targ.maxs, true, self);
			if (trace_inopen)
				if (trace_inwater)
					if (!thruwater)
						return false;
			if (trace_ent == targ)
				return true;
			else if (trace_fraction == 1)
				return true;
			return false;
		}
	}
	traceline (spot1, org, true, self);
	if (trace_ent == targ)
		return true;
	else if (trace_fraction == 1)
		return true;
	traceline (spot1, org + targ.maxs, true, self);
	if (trace_ent == targ)
		return true;
	else if (trace_fraction == 1)
		return true;
	traceline (spot1, org + targ.mins, true, self);
	if (trace_ent == targ)
		return true;
	else if (trace_fraction == 1)
		return true;
	return false;
}


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Wisible 

goes through movable brushes/entities, used
for waypoints

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

// this is used for waypoint stuff....
float wisible (entity targ1, entity targ2)
{
	vector	spot1, spot2;
	entity	ignore;

	spot1 = targ1.origin;
	spot2 = realorigin(targ2);
	
	ignore = self;
	do
	{
		traceline (spot1, spot2, true, ignore);
		spot1 = realorigin(trace_ent);
                ignore = trace_ent;
	} while ((trace_ent != world) && (trace_fraction != 1));
	if (trace_endpos == spot2)
		return true;
	else 
		return false;
}


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

sisible

Now this is getting ridiculous. Simple visible,
used when we need just a simple traceline nothing else

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float sisible (entity targ)
{
	traceline (self.origin, targ.origin, true, self);
	if (trace_ent == targ)
		return true;
	else if (trace_fraction == 1)
		return true;
}
/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

angcomp

subtracts one angle from another

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
float angcomp (float y1, float y2)
{
	y1 = frik_anglemod(y1);
	y2 = frik_anglemod(y2);

	local float answer;
	answer = y1 - y2;
	if (answer > 180)
		answer = (360 - answer) * -1;
	else if (answer < -180)
		answer = answer + 360;
	return answer;
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

fov

is the entity in the bot's field of view

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
float fov (entity targ)
{
	vector	yawn;
	float	g;
	yawn = realorigin(targ);
	yawn = (yawn + targ.view_ofs) - (self.origin + self.view_ofs);
	yawn = normalize(yawn);
	yawn = vectoangles(yawn);
	g = angcomp(self.v_angle_x, yawn_x);
	if (fabs(g) > 45)
		return false;
	g = angcomp(self.v_angle_y, yawn_y);
	if (fabs(g) > 60)
		return false;
 
	return true;
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

frik_anglemod

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
float frik_anglemod (float v)
{
	return v - floor(v/360) * 360;
}
