/*
	hip_water.qc

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

// zq extension, FIXME
float(float x) sin = #60;


void bobbingwater_think ()
{
	// 0.4 should've been 0.5; it's just to keep GL Z fights at bay
	self.origin_z = (sin(time * self.speed)) * self.size_z * 0.4;
	self.nextthink = time + 0.01;
}


/*QUAKEED func_bobbingwater
.speed - period in seconds (defaults to 2, I suppose)
*/
void func_bobbingwater ()
{
	setmodel (self, self.model);
	self.think = bobbingwater_think;
	self.nextthink = time + 0.1;

	if (!self.speed)
		self.speed = 2;

	self.speed = 3.1415 / self.speed;

	if (self.origin) {
	// just to see if its origin is set on any map
		dprint ("******* BOBBGINGWATER ORIGIN *******:");
		dprint (vtos(self.origin), "\n");
		error ("");
	}
}
