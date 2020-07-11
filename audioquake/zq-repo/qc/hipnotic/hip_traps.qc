/*
	hip_traps.qc

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


// the way hipnotic uses QUAKED fields here is ridiculous
// so I use even more absurd field names in my routines...

void trap_lightning_start ();

void trap_lightning_fire ()
{
	entity t;

	if (time >= self.t_length)
	{
		self.think = trap_lightning_start;
		self.nextthink = self.t_width;
		return;
	}

	t = find (world, targetname, self.target);
	if (!t)
		objerror ("trap_lightning_switched without a target");

	if (time >= self.sounds)
	{
		if (!(self.spawnflags & 2))
			sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "weapons/lstart.wav", 1, ATTN_NORM);

		self.sounds = time + self.duration;
	}

	LightningDamage (self.origin, t.origin, world, self.dmg);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNING2);
	WriteEntity (MSG_MULTICAST, self);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	WriteCoord (MSG_MULTICAST, t.origin_x);
	WriteCoord (MSG_MULTICAST, t.origin_y);
	WriteCoord (MSG_MULTICAST, t.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	self.think = trap_lightning_fire;
	self.nextthink = time + 0.1;
}

void trap_lightning_start ()
{
	if (self.spawnflags & 1)
	{
		// random
		self.t_length = time + self.duration;
		self.t_width = self.t_length + self.wait * random ();
		self.sounds = time;
		trap_lightning_fire ();
		return;
	}

	// set next cycle time
	if (self.spawnflags & 1)
		self.t_width = time + self.wait * random ();
	else
		self.t_width = time + self.wait;

	// set effect duration
	self.t_length = time + self.delay;

	// play sound
	self.sounds = time;
	
	trap_lightning_fire ();
}

void trap_lightning_use ()
{
	if (self.state)
	{
		// switch off
		self.state = 0;
		self.nextthink = -1;
	}
	else
	{
		// switch on
		self.state = 1;

		if (self.spawnflags & 1)
		{
			// random
			self.nextthink = time + self.wait * random ();
			self.think = trap_lightning_start;
			return;
		}

		if (self.spawnflags & 2)
		{
			trap_lightning_start ();
		}
		else
		{
			self.think = trap_lightning_start;
			self.nextthink = time + 0.1;
		}
	}
}

/*QUAKED trap_lightning_switched
.wait
.nextthink
.dmg
.duration
.state

flags:
1 = random
2 = use lstart.wav instead of lhit.wav
*/
void trap_lightning_switched ()
{
	if (!self.duration)
		self.duration = 0.1;

	if (!self.wait)
		self.wait = 1;

	if (!self.dmg)
		self.dmg = 30;

	self.delay = self.nextthink;
	self.nextthink = -1;

	self.use = trap_lightning_use;

	if (self.state)
	{
		// start next frame
		self.state = 0;
		self.think = trap_lightning_use;
		self.nextthink = 0.1;
	}
}
