/*
	hip_particles.qc

	hipnotic particle fields

	Copyright (C) 2004  Anton 'Tonik' Gavrilov

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/

// start a particle effect
//void(vector o, vector d, float color, float count,
//		float replacement_te, float replacement_count) particle = #48;


float STEP = 16;

void particlefield_XZ ()
{
	vector v;
	float repl_te, repl_te_base;

	repl_te_base = TE_BLOOD;

	v_x = self.absmin_x;
	v_y = (self.absmin_y + self.absmax_y) * 0.5;

	while (v_x < self.absmax_x)
	{
		repl_te = repl_te_base;
		repl_te_base = TE_BLOOD - repl_te_base;

		v_z = self.absmin_z;
		while (v_z < self.absmax_z)
		{
			particle (v, '0 0 0', self.color, self.count, repl_te, 1);
			v_z = v_z + STEP;
			repl_te = TE_BLOOD - repl_te;
		}
		v_x = v_x + STEP;
	}
}

void particlefield_YZ ()
{
	vector v;
	float repl_te, repl_te_base;

	repl_te_base = TE_BLOOD;

	v_x = (self.absmin_x + self.absmax_x) * 0.5;
	v_y = self.absmin_y;

	while (v_y < self.absmax_y)
	{
		repl_te = repl_te_base;
		repl_te_base = TE_BLOOD - repl_te_base;

		v_z = self.absmin_z;
		while (v_z < self.absmax_z)
		{
			particle (v, '0 0 0', self.color, self.count, repl_te, 1);
			v_z = v_z + STEP;
			repl_te = TE_BLOOD - repl_te;
		}
		v_y = v_y + STEP;
	}
}

void particlefield_XY ()
{
	vector v;
	float repl_te, repl_te_base;

	repl_te_base = TE_BLOOD;

	v_x = self.absmin_x;
	v_z = (self.absmin_z + self.absmax_z) * 0.5;

	while (v_x < self.absmax_x)
	{
		repl_te = repl_te_base;
		repl_te_base = TE_BLOOD - repl_te_base;

		v_y = self.absmin_y;
		while (v_y < self.absmax_y)
		{
			particle (v, '0 0 0', self.color, self.count, repl_te, 1);
			v_y = v_y + STEP;
			repl_te = TE_BLOOD - repl_te;
		}
		v_x = v_x + STEP;
	}
}

void particlefield_touch ()
{
	if (self.dmg)
	{
		// hurt other
	}
}

/*QUAKED func_particlefield

.color (default 192)
.count density
.dmg	when touched (TODO)
.noise (FIXME?)
.cnt
*/
float USE_COUNT = 1;
void func_particlefield ()
{
	vector size, org;

	self.classname = "particlefield";

	setmodel (self, self.model);
	self.modelindex = 0;

	size = self.absmax - self.absmin;

	if (size_x < size_y) {
		if (size_x <= size_z)
			self.use = particlefield_YZ;
		else
			self.use = particlefield_XY;
	} else {
		if (size_y < size_z)
			self.use = particlefield_XZ;
		else
			self.use = particlefield_XY;
	}

	if (!self.color)
		self.color = 192;

	if (!self.count)
		self.count = 2;
}



void togglewall_use ()
{
	if (self.solid)
		self.solid = SOLID_NOT;
	else
		self.solid = SOLID_BBOX;

	// link into world
	setmodel (self, self.model);
	self.modelindex = 0;
}

void togglewall_touch ()
{
	// damage other
}


/*QUAKED func_particlefield
.dmg	when touched
*/
//float START_OFF = 1;
void func_togglewall ()
{
	if (!(self.spawnflags & 1))
		self.solid = SOLID_BBOX;

	setmodel (self, self.model);
	self.modelindex = 0;

	self.use = togglewall_use;
	if (self.dmg)
		self.touch = togglewall_touch;
}
