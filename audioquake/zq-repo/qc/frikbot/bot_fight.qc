.entity avoid;

float bot_size_player (entity e)
{
	float	sz;

	sz = e.health + e.armorvalue * e.armortype;
	if (e.weapon == IT_LIGHTNING)
		sz = sz + 60;
	else if (e.weapon == IT_ROCKET_LAUNCHER)
		sz = sz + 60;
	else if (e.weapon == IT_GRENADE_LAUNCHER)
		sz = sz + 50;
	else if (e.weapon == IT_SUPER_NAILGUN)
		sz = sz + 50;
	else if (e.weapon == IT_NAILGUN)
		sz = sz + 40;
	else if (e.weapon == IT_SUPER_SHOTGUN)
		sz = sz + 40;
	else if (e.weapon == IT_SHOTGUN)
		sz = sz + 10;
	else if (e.weapon == IT_AXE)
		sz = sz - 50;
	if (e.items & IT_QUAD)
		sz = sz + 200;
	if (e.items & IT_INVULNERABILITY)
		sz = sz + 300;
	if (e.items & IT_INVISIBILITY)
		sz = sz + 250;
	return sz;
}

void bot_dodge_stuff ()
{
	entity	foe;
	float	foedist, avdist, foesz, flen, tsz;
	vector	v;
    string foe_team, self_team;

	if (waypoint_mode > WM_LOADED)
		return;

	self.avoid = world;


	if (self.enemy)
	{
		v = self.origin - realorigin(self.enemy);
		foedist = vlen(v);
		foesz = bot_size_player(self.enemy);
	}
	else 
	{
		foedist = 3000;
		foesz = 9999999;
	}
	avdist = 256;

	foe = find(world, classname, "grenade");
	while(foe)
	{
		flen = vlen(foe.origin - self.origin);
		if (flen < avdist)
		{
			avdist = flen;
			self.avoid = foe;
		}
		foe = find(foe, classname, "grenade");
	}
	if (!self.avoid)
	{
		foe = find(world, classname, "missile");
		while(foe)
		{
			if (foe.owner != self)
			{
				flen = vlen(foe.origin - self.origin);
				if (flen < avdist)
				{
					avdist = flen;
					self.avoid = foe;
				}
			}
			foe = find(foe, classname, "missile");
		}
		if (!self.avoid)
		{
			foe = find(world, classname, "spike");
			while(foe)
			{
				if (foe.owner != self)
				{
					flen = vlen(foe.origin - self.origin);
					if (flen < avdist)
					{
						avdist = flen;
						self.avoid = foe;
					}
				}
				foe = find(foe, classname, "spike");
			}
		}
	}
	if (coop)
	{
		if (!self.enemy)
		{
			foe = findradius(self.origin, foedist);
			while(foe)
			{
				if(foe.flags & FL_MONSTER)
				{
					if(foe.health > 0)
					{
						flen = vlen(foe.origin - self.origin);
						if (flen < foedist)
						{
							tsz = bot_size_player(foe);
							if (tsz < foesz)
							{
								if (fisible(foe))
								{
									self.enemy = foe;
									foedist = flen;
									foesz = tsz;
								}
							}
						}
					}
				}
				foe = foe.chain;
			}
		}		
	}
	else
	{
		foe = player_head;
		while(foe)
		{
			if(foe != self)
			{
				if (foe.modelindex != 0)
				{
					if (foe.health > 0)
					{
                        self_team = infokey (self, "team");
                        foe_team = infokey (foe, "team");
						if (!(teamplay && self_team == foe_team))
						{
							flen = vlen(foe.origin - self.origin);
							if (flen < foedist)
							{
								tsz = bot_size_player(foe);
								if (tsz < foesz)
								{
									if (fov(foe) || foe.b_sound > time || self.b_skill == 3)
									{
										if (fisible(foe))
										{
											self.enemy = foe;
											foedist = vlen(foe.origin - self.origin);
										}
									}
								}
							}
						}
					}
				}
			}
			foe = foe._next;
		}
	}
}




/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

weapon_range

_x "sweet spot range" - try to maintain this range if possible
_y minimum range bot can be to be effective (rl/gl) (move away)
_z maximum range bot can be to be effective (lg/axe) (move in)
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

vector weapon_range (float wep)
{
	if (wep == IT_AXE)
		return '48 0 64';
	else if (wep == IT_SHOTGUN)
		return '128 0 99999';
	else if (wep == IT_SUPER_SHOTGUN)
		return '128 0 99999';
	else if (wep == IT_NAILGUN)
		return '180 0 3000';
	else if (wep == IT_SUPER_NAILGUN)
		return '180 0 3000';
	else if (wep == IT_GRENADE_LAUNCHER)
		return '180 48 3000';
	else if (wep == IT_ROCKET_LAUNCHER)
		return '180 48 3000';
	else if (wep == IT_LIGHTNING)
		return '350 0 512';
}
/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

bot_weapon_switch

Pick a weapon based on range / ammo

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void bot_weapon_switch (float brange)
{
	float	it, flag, pulse;
	vector	v;

	it = self.items & 127;

	while(it)
	{
		if ((self.ammo_rockets >= 1) && (it & IT_ROCKET_LAUNCHER))
		{
			flag = IT_ROCKET_LAUNCHER;
			pulse = 7;
		}
		else if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING))
		{
			flag = IT_LIGHTNING;
			pulse = 8;
		}
		else if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN))
		{
			flag = IT_SUPER_NAILGUN;
			pulse = 5;
		}
		else if ((self.ammo_rockets >= 1) && (it & IT_GRENADE_LAUNCHER))
		{
			flag = IT_GRENADE_LAUNCHER;
			pulse = 6;
		}
		else if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN))
		{
			flag = IT_SUPER_SHOTGUN;
			pulse = 3;
		}
		else if(self.ammo_nails >= 1 && (it & IT_NAILGUN))
		{
			flag = IT_NAILGUN;
			pulse = 4;
		}
		else if(self.ammo_shells >= 1 && (it & IT_SHOTGUN))
		{
			flag = IT_SHOTGUN;
			pulse = 2;
		}
		else
		{
			if (pulse)
				self.impulse = pulse;
			return;
		}

		if (brange == -1)
		{
			if (pulse)
				self.impulse = pulse;
			return;
		}

		v = weapon_range(flag);
		if (brange < v_y || brange > v_z)
			it = it - flag;
		else
		{
			if (pulse)
				self.impulse = pulse;
			return;
		}
	}
}

void bot_shoot ()
{
	// quick little function to stop making him shoot the wrong way ! Argh
	float	g;
	g = angcomp(self.v_angle_x, self.b_angle_x);
	if (fabs(g) > 30)
		return; // argh, too far away
	g = angcomp(self.v_angle_y, self.b_angle_y);
	if (fabs(g) > 30)
		return; // not again!
	self.button0 = true;
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Bot_fight_style

This is the core of the bot's thinking when
attacking an enemy. 

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void bot_fight_style ()
{
	vector	v, v1, v2, org;
	float	foedist, mysz, foesz;
    string trace_ent_team, self_team;

	if (self.enemy.health <= 0)
	{
		self.enemy = world;
		return;
	}
	else if (!self.enemy.takedamage)
	{
		self.enemy = world;
		return;
	}
	else if (!fisible(self.enemy))
	{
		self.enemy = world;
		return;
	}

	org = realorigin(self.enemy);
	makevectors(self.v_angle);

	// decide if I should shoot

	foedist = vlen(org - self.origin);
	v = weapon_range(self.weapon);
	if (foedist > v_y && foedist < v_z)
	{
		traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * v_z, false, self);
		if (vlen(trace_endpos - (self.origin + self.view_ofs)) >= v_y)
		{
			// try to avoid shooting teammates
			if (trace_ent.classname == "player")
            {
                trace_ent_team = infokey (trace_ent, "team");
                self_team = infokey (self, "team");
				if ((trace_ent_team == self_team && teamplay) || (coop))
					return;
            }
			bot_shoot();
		}
	}
	else
		bot_weapon_switch(foedist);

	if (!(self.b_aiflags & (AI_PRECISION | AI_BLIND | AI_OBSTRUCTED)))
	{
		foesz = bot_size_player(self.enemy);
		mysz = bot_size_player(self) + 5;

		if (foesz > mysz)
		{
			if (teamplay)
			{
				if (random() < 0.02)
				{
					bot_start_topic(5);
					self.b_chattime = 1;
				}
			}
			
			return;
		}
		else if (mysz < 140)
			return;
		else if (self.avoid)
		{
			if (self.avoid.velocity)
				v = self.avoid.velocity;
			else
				v = normalize(self.avoid.origin - self.origin);
			v1_x = v_y;
			v1_y = v_y * -1;
			v2_x = v_y;
			v2_y = v_y * -1;
			foedist = vlen(self.avoid.origin - (self.origin + v1));
			if (foedist < vlen(self.avoid.origin - (self.origin + v2)))
				frik_walkmove(v2);
			else
				frik_walkmove(v1);
		}
		else if (!self.enemy.flags & FL_MONSTER)
		{
			if (foedist + 32 <  v_x)
				frik_walkmove(self.origin - org);
			else if (foedist - 32 >  v_x)
				frik_walkmove(org - self.origin);
			else if (self.wallhug)
				frik_walkmove(v_right);
			else
				frik_walkmove(v_right * -1);
		}
	}
	else
	{
		foesz = bot_size_player(self.enemy);
		mysz = bot_size_player(self) + 5;

		if (foesz > mysz)
			return;
		else if (mysz < 140)
			return;
		self.keys = self.keys & 960;
	}
}


