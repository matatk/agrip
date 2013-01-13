/*
=========================================

Stuff mimicking cl_input.c code

=========================================
*/
float CL_KeyState (float key)
{
	return ((self.keys & key) > 0);
}

//
// CL_BaseMove + CL_AdjustAngles
//
void CL_KeyMove ()
{
	float	anglespeed;
	vector	view;

	if (self.keys != self.oldkeys)
	{
		self.forwardmove = self.sidemove = self.upmove = 0;
		self.sidemove = self.sidemove + (350 * CL_KeyState(KEY_MOVERIGHT));
		// 350 is the default cl_sidespeed
		self.sidemove = self.sidemove - (350 * CL_KeyState(KEY_MOVELEFT));
		// 350 is the default cl_sidespeed
		self.forwardmove = self.forwardmove + (200 * CL_KeyState(KEY_MOVEFORWARD));
		// 200 is the default cl_forwardspeed
		self.forwardmove = self.forwardmove - (200 * CL_KeyState(KEY_MOVEBACK));
		// 200 is the default cl_backspeed
		self.upmove = self.upmove + (200 * CL_KeyState(KEY_MOVEUP));
		// 200 is the default cl_upspeed
		self.upmove = self.upmove - (200 * CL_KeyState(KEY_MOVEDOWN));
		// 200 is the default cl_upspeed
		if (!self.b_aiflags & AI_PRECISION) {
			self.forwardmove = self.forwardmove * 2;
			self.sidemove = self.sidemove * 2;
			self.upmove = self.upmove * 2;
		}
		// 2 is the default cl_movespeedkey & bot always has +speed
	}
	self.oldkeys = self.keys;

	if (self.b_skill != 2) // use mouse emulation
	{
		anglespeed = 1.5 * frametime; 
		// 1.5 is the default cl_anglespeedkey & bot always has +speed
		self.v_angle_y = self.v_angle_y + anglespeed * CL_KeyState(KEY_LOOKLEFT) * 140; 
		// 140 is default cl_yawspeed
		self.v_angle_y = self.v_angle_y - anglespeed * CL_KeyState(KEY_LOOKRIGHT) * 140; 
		// 140 is default cl_yawspeed
		self.v_angle_x = self.v_angle_x - anglespeed * CL_KeyState(KEY_LOOKUP) * 150; 
		// 150 is default cl_pitchspeed
		self.v_angle_x = self.v_angle_x + anglespeed * CL_KeyState(KEY_LOOKDOWN) * 150; 
		// 150 is default cl_pitchspeed
	}
	else
	{
		view_x = angcomp(self.b_angle_x, self.v_angle_x);
		view_y = angcomp(self.b_angle_y, self.v_angle_y);
		if (vlen(view) > 30)
		{
			self.mouse_emu = self.mouse_emu + (view * 30);
			if (vlen(self.mouse_emu) > 180)
				self.mouse_emu = normalize(self.mouse_emu) * 180;
		}
		else 
			self.mouse_emu = view * (1 / frametime);
		self.v_angle = self.v_angle + self.mouse_emu * frametime;

		
	}
	if (self.v_angle_x > 80)
		self.v_angle_x = 80;
	else if (self.v_angle_x < -70)
		self.v_angle_x = -70;

	if (self.v_angle_z > 50)
		self.v_angle_z = 50;
	else if (self.v_angle_z < -50)
		self.v_angle_z = -50;
	self.v_angle_y = frik_anglemod(self.v_angle_y);

}

/*
=========================================

Stuff mimicking sv_phys.c

=========================================
*/

// Tonik -- commented everything out
// I'm not sure if anything here used to affect bot logic...


/*

float() SV_RunThink  =
{
	float	thinktime, bkuptime;

	thinktime = self.nextthink;
	bkuptime = time;
	if (thinktime <= 0 || thinktime > (time + real_frametime))
		return true;
	if (thinktime < time)
		thinktime = time;
	self.nextthink = 0;
	time = thinktime; 
	other = world;
	makevectors(self.v_angle); // hack
	self.think();
	time = bkuptime;
	return true;
}

// Thanks to Alan Kivlin for this function
// modified heavily by me
float(vector dir) botCheckForStep =
{
	vector	currentorigin, v;
	float	currentflags, yaw, stepdistance, movedistance; 

	currentorigin = self.origin;
	currentflags = self.flags; 
	self.flags = FL_ONGROUND | FL_PARTIALGROUND; 
	dir = normalize(dir);
	dir_z = 0;
	yaw = vectoyaw(dir); 
	if(walkmove(yaw, 3))
	{	
		if(droptofloor())
		{	
			stepdistance = self.origin_z - currentorigin_z;
			v = self.origin - currentorigin;
			v_z = 0;
			movedistance = vlen(v); 
			if((stepdistance > 0 && stepdistance <= 16) && movedistance != 0)
			{
				self.flags = currentflags | FL_PARTIALGROUND;
				return 1;
			}
		}
	}	
	self.flags = currentflags;
	setorigin(self, currentorigin);
	return 0;
} 
// this is merely here to fix a problem with e3m5
void BruteForceStep (vector dir)
{
	vector	currentorigin;
	float	currentflags, i, len;

	currentorigin = self.origin;
	currentflags = self.flags;
	len = vlen(dir);
	if (len > 16)
		dir = normalize(dir) * 16;

	setorigin(self, currentorigin + dir);

	while(i < 18 && !walkmove(0, 0))
	{
		self.origin_z = currentorigin_z + i;
		i = i + 2;
	}
	self.flags = currentflags;
	if (i >=18)
		setorigin(self, currentorigin);
}

void PostPhysics ()
{
	vector	obstr, org;
	float	back, dst,cflags;

	self = self.owner;

	self.velocity = self.velocity - self.phys_obj.dest1 + self.phys_obj.velocity;
	if (self.phys_obj.dest2 == self.origin)
	{
		setorigin(self, self.phys_obj.origin); 
		// might've been moved during other person's physics
		// (teleporters / plats)

		if (self.movetype == MOVETYPE_WALK)
		{

			if (self.phys_obj.dest1_x || self.phys_obj.dest1_y)
			{
				if ((self.flags & FL_ONGROUND) || (self.waterlevel <= 2))
				{
					obstr = self.phys_obj.movedir  - self.origin;
					obstr_z = 0;
					if (vlen(obstr) > 0.1)
					{
						dst = vlen(obstr);
						back = vectoyaw(obstr);
						cflags = self.flags;
						self.flags = self.flags | FL_PARTIALGROUND;
						if(walkmove(back, dst))
						{
							self.flags = cflags;
							self.phys_obj.dest1_z = 0;
							self.velocity = self.velocity + self.phys_obj.dest1 - self.phys_obj.velocity;
						}
						else
						{
							if (dst > 1)
								frik_obstructed(obstr, false); 

							org = self.origin;
							self.flags = cflags;
							obstr = self.phys_obj.dest1;
							obstr_x = 0;
							if (!botCheckForStep(obstr))
							{
								obstr = self.phys_obj.dest1;
								obstr_y = 0;
								if (!botCheckForStep(obstr))
								{
									// if no steps were found, bot is really obstucted
									BruteForceStep(self.phys_obj.dest1);
								}
							}	
						}
					}
				}
			}
		}
	}

	SV_CheckOnGround();

	PlayerPostThink();
	BotAI();
	self.dmg_take = self.dmg_save = 0;
}

*/
