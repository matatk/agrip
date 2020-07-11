/*
	hip_rotate.qc

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

// nothing really works here yet...


.float endtime;
.entity rot_chain;



//###EXT
float(float min, float value, float max) bound = #96;

const float STATE_CLOSED = 0;
const float STATE_OPEN = 1;
const float STATE_CLOSING = 2;
const float STATE_OPENING = 3;


// func_rotate_door fields:
// .dest2 is angles when fully open
// .dest is current desired angles (dest2 if opening, '0 0 0' if closing)
// .state is one of STATE_ constants

// point of rotation
void info_rotate ()
{
}

void movewall_blocked ()
{
}

void movewall_think ()
{
	self.nextthink = time + 0.1;
	self.blocked = movewall_blocked;
}

void func_movewall ()
{
	self.solid = SOLID_BSP;	// testing
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.model);

	self.think = movewall_think;
	self.nextthink = time + 0.1;
}


void rotate_object ()
{
//testing
//	setmodel (self, self.model);
	self.model = "";
}


void rotate_door_opened ()
{
	self.state = STATE_OPEN;
	self.think = SUB_Null;
}

void rotate_door_closed ()
{
	self.state = STATE_CLOSED;
	self.think = SUB_Null;
}

void rotate_door_think ()
{
	entity t;
	vector o;
	vector ang;
	vector wishorg, vel;

	if (time >= self.endtime)
		self.angles = self.dest;
	else
		self.angles = self.dest - self.rotate * (self.endtime - time);

	self.enemy.angles = self.angles;

	ang = self.angles;
	ang = -self.angles;
	makevectors (ang);

	t = self.rot_chain;
	while (t)
	{
if (time >= self.endtime)
t.velocity = '0 0 0';
else
{
		o_x = v_forward * t.oldorigin;
		o_y = -v_right * t.oldorigin;
		o_z = v_up * t.oldorigin;

		wishorg = o - t.oldorigin;

		vel = (wishorg - t.origin) * (1 / frametime);
		t.velocity = vel;
}
		t = t.rot_chain;
	}

	if (time >= self.endtime)
	{
		if (self.state == STATE_OPENING)
			rotate_door_opened ();
		else
			rotate_door_closed ();
	}
	else
		self.nextthink = time + 0.01;
}



void rotate_door_use ()
{
	if (self.state == STATE_OPENING || self.state == STATE_CLOSING)
		return;

	if (self.state == STATE_CLOSED) {
		self.state = STATE_OPENING;
		self.dest = self.dest2;
		self.rotate = self.dest2 * (1 / self.speed);
	}
	else {
		self.state = STATE_CLOSING;
		self.dest = '0 0 0';
		self.rotate = -self.dest2 * (1 / self.speed);
	}

	self.endtime = time + self.speed;

	self.think = rotate_door_think;
	self.nextthink = time + 0.1;


dprint ("speed: "); dprint (ftos(self.speed), "\n");
dprint ("rotate: "); dprint (vtos(self.rotate), "\n");
}


void link_rotate_door ()
{
	entity t;

// find rotate_object
	t = find (world, targetname, self.target);
	while (t != world && t.classname != "rotate_object")
	{
		t = find (t, targetname, self.target);
	}

	if (!t) {
		dprint ("******** door does not have rotate_object\n");
		return;
	}

	self.enemy = t;

// find info_rotate
	t = find (world, targetname, self.enemy.target);
	while (t != world && t.classname != "info_rotate")
	{
		t = find (t, targetname, self.enemy.target);
	}

	if (!t) {
		objerror ("******** door does not have info_rotate\n");
		return;
	}

	// save the rotation center
	self.origin = t.origin;

// find all func_movewall
	t = find (world, targetname, self.target);
	while (t != world)
	{
		if (t.classname == "func_movewall")
		{
			// calc relative origin
			t.oldorigin = (t.absmin + t.absmax) * 0.5 - self.origin;
			t.rot_chain = self.rot_chain;
			self.rot_chain = t;
		}
		t = find (t, targetname, self.target);
	};


	self.dest = '0 0 0';
	self.dest2 = self.angles;
	self.angles = '0 0 0';
	self.use = rotate_door_use;

	self.state = STATE_CLOSED;
}

/*QUAKED func_rotate_door
*/
void func_rotate_door ()
{
	self.think = link_rotate_door;
	self.nextthink = time + 0.1;

	if (!self.speed)
		self.speed = 2;
}







//============================================================================

void rotate_entity_think ()
{
	self.angles = self.angles + self.rotate * (time - self.ltime);
	self.ltime = time;

	self.enemy.angles = self.angles;

	self.nextthink = time + 0.01;
}


void link_rotate_entity ()
{
	entity t;
	vector v;

	t = find (world, targetname, self.target);
	while (t != world && t.classname != "rotate_object")
	{
		t = find (t, targetname, self.target);
	}

	if (!t) {
	// actually it's ok....
		dprint ("******** func_rotate_entity does not have rotate_object\n");
		remove (self);
		return;
	}

	self.enemy = t;

   	self.think = rotate_entity_think;
   	self.ltime = time;
	self.nextthink = time + 0.01;
}

//
// QUAKED func_rotate_entity
//
// TOGGLE = 1;	// (?)
// START_ON = 2;
// .speed - how fast to accelerate/decelerate (TODO)
void func_rotate_entity ()
{
	if (!(self.spawnflags & 2))
		return;	// only start_on are currently supported


	// .speed is not supported

	self.think = link_rotate_entity;
	self.nextthink = time + 0.1;
}

//============================================================================

//============================================================================

/*QUAKED path_rotate
*/
void path_rotate ()
{
}

void rotate_train_next ();

void rotate_train_think ()
{
	vector dir;

	if (time >= self.endtime)
	{
		self.origin = self.goalentity.origin;
	}
	else {
		dir = self.goalentity.origin - self.origin;
		dir = normalize (dir);
		self.origin = self.goalentity.origin - dir * (self.endtime - time) * self.speed;
	}

	setorigin (self.enemy, self.origin - self.enemy.dest);


	if (time >= self.endtime)
	{
		rotate_train_next ();
		return;
	}

	self.nextthink = time + 0.01;	// FIXME
}

void rotate_train_next ()
{
	entity	targ;
	float oldspd;

oldspd = self.goalentity.speed;

	targ = find (world, targetname, self.goalentity.target);
	self.goalentity = targ;

	if (!self.goalentity)
		objerror ("rotate_train_next: no next target");

if (oldspd == -1)
{
self.origin = targ.origin;
self.think = rotate_train_next;
self.nextthink = time + 0.01;
return;
}

	if (targ.wait)
		self.wait = targ.wait;
	else
		self.wait = 0;

	self.endtime = time + vlen(targ.origin - self.origin) * (1 / self.speed);

	self.think = rotate_train_think;
	self.nextthink = time + 0.01;
}


void rotate_train_find ()
{
	entity t;

	t = find (world, targetname, self.target);
	if (!t)
		objerror ("func_rotate_train without a target");

	self.enemy = t;


	t = find (world, targetname, self.path);
	if (!t)
		objerror ("func_rotate_train without a path");

	self.goalentity = t;

self.enemy.dest = self.origin;

	self.origin = t.origin;

//	self.enemy.dest = t.origin /*- (self.enemy.absmin + self.enemy.absmax) * 0.5*/;

	setorigin (self.enemy, t.origin - self.enemy.dest);

	rotate_train_next ();
}


/*QUAKED func_rotate_train
*/
void func_rotate_train ()
{
	if (!self.speed)
		self.speed = 100;

	if (!self.target)
		objerror ("func_rotate_train without a target");

	self.think = rotate_train_find;
	self.nextthink = time + 0.1;
}
