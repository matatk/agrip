void bot_jump ()
{
	// TODO check for precision, etc.
	self.button2 = true;
}

float bot_can_rj (entity e)
{
	// this returns true of the bot can rocket/superjump/hook
	// if your mod doesn't have an RL you can just return false all the time
	// if it has a hook or some other means for the bot to get to high places
	// you can check here for that capability

	// am I dumb?
	if (e.b_skill == 0)
		return false;

	// quad = bad
	if (e.items & 4194304)
		return false;

	// do I have rockets & RL?
	if (!((e.items & 32) && (e.ammo_rockets > 0)))
		return false;

	// do I have pent?
	if (e.items & 1048576)
		return true;

	if (e.health > 50)
		return true;
	else
		return false;
}

float frik_recognize_plat (float flag)
{
	if ((self.classname != "waypoint") && !(self.flags & FL_ONGROUND))
		return false;
	traceline(self.origin, self.origin - '0 0 64', true, self);
	if (trace_ent != world)
	{
		if (flag) // afect bot movement too
		{
			if (self.keys & KEY_MOVEUP)
			{
				if (trace_ent.velocity_z > 0)
					self.keys = self.keys & 960; // 960 is all view keys
			}
			else if (self.keys & KEY_MOVEDOWN)
			{
				if (trace_ent.velocity_z < 0)
					self.keys = self.keys & 960;
			}
		}
		return true;
	}
	else
		return false;
}

float frik_KeysForDir (vector sdir)
{

	vector	keydir;
	float	outkeys, tang;
	outkeys = 0;
	if (sdir_x || sdir_y)
	{
		// Everything is tested against 60 degrees,
		// this allows the bot to overlap the keys
		// 30 degrees on each diagonal  45 degrees
		// might look more realistic

 		keydir = vectoangles(sdir);
		tang = angcomp(keydir_y, self.v_angle_y);
		if ((tang <= 150) && (tang >= 30))
			outkeys = outkeys + KEY_MOVELEFT;
		else if ((tang >= -150) && (tang <= -30))
			outkeys = outkeys + KEY_MOVERIGHT;
		if (fabs(tang) <= 60)
			outkeys = outkeys + KEY_MOVEFORWARD;
		else if (fabs(tang) >= 120)
			outkeys = outkeys + KEY_MOVEBACK;
	}
	if (sdir_z > 0.7)
		outkeys = outkeys + KEY_MOVEUP;
	else if (sdir_z < 0.7)
		outkeys = outkeys + KEY_MOVEDOWN;
	return outkeys;

}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

frik_obstructed

Bot has hit a ledge or wall that he should
manuever around.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void frik_obstructed (vector whichway, float danger)
{
	float	dist;
	vector	disway, org;

// TODO: something
	if (self.b_aiflags & AI_BLIND)
		return;
	org = realorigin(self.target1);

	if (danger)
	{
		self.b_aiflags = self.b_aiflags | AI_DANGER;
		self.keys = frik_KeysForDir('0 0 0' - whichway);
	}
	if (self.b_aiflags & AI_PRECISION)
		return;


	if (self.target1)
	{
		if (self.b_aiflags & AI_OBSTRUCTED)
		{
			if (!(self.b_aiflags & AI_DANGER))
			{
				self.b_aiflags = self.b_aiflags - AI_OBSTRUCTED;
				return;
			}
			else if (!danger)
				return;
		}
		self.obs_dir = whichway;
		disway_x = whichway_y * -1;
		disway_y = whichway_x;
		dist = vlen(org - (self.origin + disway));
		disway_x = whichway_y;
		disway_y = whichway_x * -1;
		self.wallhug = vlen(org - (self.origin + disway)) > dist;
		self.b_aiflags = self.b_aiflags | AI_OBSTRUCTED;
	
	}
	else
	{
		disway_x = whichway_y * -1;
		disway_y = whichway_x;
		dist = vlen(disway - self.obs_dir);
		disway_x = whichway_y;
		disway_y = whichway_x * -1;
		self.wallhug = vlen(disway - self.obs_dir) < dist;
		self.obs_dir = whichway;

		self.b_aiflags = self.b_aiflags | AI_OBSTRUCTED;
	}
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

frik_obstacles

Detects small bumps the bot needs to jump over
or ledges the bot should avoid falling in.

Also responsible for jumping gaps.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void frik_obstacles ()
{
	vector	start, stop, ang;
	float	test, conts, dist, hgt;

	if (!(self.flags & FL_ONGROUND))
		return;
	if (self.b_aiflags & AI_BLIND)
		return;

	ang = normalize(self.velocity);
	ang_z = 0;
	start = self.origin + ang * 32; // ahem
	start_z = self.origin_z + self.maxs_z;
	stop = start;
	stop_z = self.origin_z + self.mins_z;
	traceline(start, stop - '0 0 256', true, self);
	if (trace_allsolid || trace_startsolid)
		return;
	hgt = trace_endpos_z - stop_z;

	if (hgt > 18)
	{
		bot_jump();
		return;
	}
	if (hgt >= 0)
		return;

	conts = pointcontents(trace_endpos + '0 0 4');
	start = stop - '0 0 8';
	stop = start + ang *  256;
	traceline(start, stop, true, self);
	test = vlen(trace_endpos - start);
	if (test <= 20)
		return; // it's a walkable gap, do nothing
	ang_x = self.velocity_y * -1;
	ang_y = self.velocity_x;
	ang = normalize(ang);
	traceline(start - (ang * 10), start + (ang * 10), true, self);
	if ((trace_fraction != 1) || trace_startsolid)
		return; // gap is only 20 wide, walkable
	ang = self.velocity;
	ang_z = 0;
	dist = ((540 / world.gravity) * vlen(ang))/* + 32*/;
	if (test > dist) // I can't make it
	{
		if (conts < -3) // bad stuff down dare
		{
			frik_obstructed(ang, true);
			return;
		}
		else
		{
			if (self.target1)
			{
				stop = realorigin(self.target1);
				if ((stop_z - self.origin_z) < -32)
					return; // safe to fall
			}
			frik_obstructed(ang, false);
			return;
		}
	}
	else
	{
		ang = normalize(ang);
		//look for a ledge
		traceline(self.origin, self.origin + (ang * (test + 20)), true, self);
		if (trace_fraction != 1)
		{
			if (conts < -3) // bad stuff down dare
			{
				frik_obstructed(ang, true);
				return;
			}
			else
			{
				if (self.target1)
				{
					stop = realorigin(self.target1);
					if ((stop_z - self.origin_z) < -32)
						return; // safe to fall
				}
				frik_obstructed(ang, false);
				return;
			}
		}

		if (self.target1)
		{
			// getting furter away from my target?
			test = vlen(self.target1.origin - (ang + self.origin));
			if (test > vlen(self.target1.origin - self.origin))
			{
				if (conts < -3) // bad stuff down dare
				{
					frik_obstructed(ang, true);
					return;
				}
				else
				{
					frik_obstructed(ang, false);
					return;
				}
			}
		}
	}
	if (hgt < -18)
	{
		if (self.target1)
		{
			stop = realorigin(self.target1);
			if ((stop_z - self.origin_z) < -32)
				return; // safe to fall
		}
		bot_jump();
	}
	// go for it

}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

After frik_obstructed, the bot uses the
following funtion to move "around" the obstacle

I have no idea how well it will work

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void frik_dodge_obstruction ()
{
	vector	way, org;
	float	oflags, yaw;

	if (!(self.b_aiflags & AI_OBSTRUCTED))
		return;
	if ((self.b_aiflags & (AI_BLIND | AI_PRECISION)) || !(self.flags & FL_ONGROUND))
	{
		self.b_aiflags = self.b_aiflags - AI_OBSTRUCTED;
		return;
	}

	// perform a walkmove check to see if the obs_dir is still obstructed
	// walkmove is less forgiving than frik_obstacles, so I dunno
	// how well this will work

	oflags = self.flags;
	org = self.origin;

	yaw = vectoyaw(self.obs_dir);
	if (walkmove(yaw, 32))
		self.b_aiflags = self.b_aiflags - AI_OBSTRUCTED;
	else
	{
		if (self.b_aiflags & AI_DANGER)
		{
			way = '0 0 0' - self.obs_dir;
		}
		else if (self.wallhug)
		{
			way_x = self.obs_dir_y * -1;
			way_y = self.obs_dir_x;
		}
		else
		{
			way_x = self.obs_dir_y;
			way_y = self.obs_dir_x * -1;
		}
		self.keys = self.keys & 960 + frik_KeysForDir(way);
	}

	// fix the bot

	setorigin (self, org);
	self.flags = oflags;
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

movetogoal and walkmove replacements

blah

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
void frik_movetogoal ()
{
	vector	way;
	float	g;

	if (self.target1 == world)
	{
		makevectors(self.v_angle);
		frik_walkmove(v_forward);
		return;
	}
	way = realorigin(self.target1) - self.origin;
	if (vlen(way) < 25)
	{
		self.keys = self.keys & 960;
		return;
	}

	way = normalize(way);
	self.keys = self.keys & 960 + frik_KeysForDir(way);

	frik_dodge_obstruction();
	frik_recognize_plat(true);

	if (self.b_aiflags & AI_PRECISION)
	{
		g = angcomp(self.v_angle_x, self.b_angle_x);
		if (fabs(g) > 10)
			self.keys = self.keys & 960;
		g = angcomp(self.v_angle_y, self.b_angle_y);
		if (fabs(g) > 10)
			self.keys = self.keys & 960;
	}
}

float frik_walkmove (vector weird)
{
	// okay so it's not walkmove
	// sue me
 	self.keys = self.keys & 960 + frik_KeysForDir(weird);

	frik_dodge_obstruction();
	frik_recognize_plat(true);
	if (self.b_aiflags & AI_OBSTRUCTED)
		return false;
	else
		return true;
}


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

The "hook" method of navigation. This nav
system is copyrighted 1999 by Ryan "Frika C"
Smith, keep that in mind when you steal it.

I brought this back because normal roaming
won't work - the bot gets distracted by it's
own waypoints.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
void frik_bot_roam ()
{
	vector	org, ang, org1;
	float	loopcount, flag, dist;

	loopcount = 26;
	flag = false;
	while((loopcount > 0) && !flag)
	{
		loopcount = loopcount - 1;
		org = self.origin + self.view_ofs;
		ang = self.angles;
		ang_y = frik_anglemod(ang_y - 90 + (random() * 180));
		ang_x = 0; // avoid upward sloping
		makevectors(ang);
		traceline(org, org + v_forward * 2300, true, self);
		if (trace_fraction != 1)
		{
			org1 = trace_endpos;
			ang = normalize(trace_plane_normal);
			ang_z = 0; // avoid upward sloping
			traceline(org1, org1 + (ang * 2300), true, self);
			if ((trace_fraction != 1) && (vlen(trace_endpos - org1) >= 64))
			{
				org = trace_endpos;
				traceline(org, self.origin + self.view_ofs, true, self);
				if (trace_fraction != 1)
				{
					dist = vlen(org1 - org) /2;
					org = org1 + (ang * dist);
					traceline(org, org - '0 0 48', true, self);
					if (trace_fraction != 1)
					{
						SpawnTempWaypoint(org);
						flag = true;
					}
				}
			}
		}
	}
	self.b_angle_y = self.v_angle_y + 10;
}
