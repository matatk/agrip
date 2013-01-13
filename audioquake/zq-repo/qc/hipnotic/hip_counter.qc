/*
	hip_counter.qc

	hipnotic func_counter and pals

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

//============================================================================

// FIXME: does this work?


void func_oncount_use ()
{
	SUB_UseTargets ();
}

/*QUAKEED func_oncount
*/
void func_oncount ()
{
	self.cnt = self.count;
	self.use = func_oncount_use;
}

//============================================================================

void func_counter_firetargets ()
{
	entity act;
	entity t;
	entity stemp, otemp;

//
// fire targets
//
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, targetname, self.target);
			if (!t)
			{
				return;
			}
			if (!t.cnt || t.cnt == self.cnt) {
				stemp = self;
				otemp = other;
				self = t;
				other = stemp;
				if (self.use != SUB_Null)
//				if (self.use)
				{
					if (self.use)
						self.use ();
				}
				self = stemp;
				other = otemp;
				activator = act;
			}
		} while ( 1 );
	}
}

void counter_think ()
{
	self.cnt = self.cnt + 1;
	if (self.cnt > self.count)
		self.cnt = 1;

	func_counter_firetargets ();

	self.nextthink = time + self.wait;
}

void counter_on_use ();

void counter_off_use ()
{
//dprint ("COUNTER_OFF_USE\n");

	self.think = counter_think;
	self.nextthink = time + self.wait;	// self.delay or what?

	self.use = counter_on_use;
}

void counter_on_use ()
{
//dprint ("COUNTER_ON_USE\n");
	self.think = SUB_Null;
	self.use = counter_off_use;
}

/*QUAKED func_counter

flags:
toggle
loop = 2
step
reset
random
finishcount
start_on = 64
*/
void func_counter ()
{
	if (!self.target)
		objerror ("no target");

	if (!self.wait)
		self.wait = 1;
	if (!self.count)
		self.count = 10;

	if (self.spawnflags & 64)
	{
		// START_ON
		self.think = counter_think;
		self.nextthink = time + self.wait;	// self.delay or what?

		self.use = counter_on_use;
	}
	else
		self.use = counter_off_use;

}
