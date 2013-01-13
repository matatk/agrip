/*
	hip_triggers.qc

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

void setgravity_touch ()
{
	if (other.classname != "player")
		return;

	other.gravity = self.gravity;
}

/*QUAKED trigger_setgravity
*/
void trigger_setgravity ()
{
	InitTrigger ();

	if (!self.gravity)
		self.gravity = 1;
	else
		self.gravity = (self.gravity - 1) / 100;

	self.touch = setgravity_touch;
}

//============================================================================


void usekey_touch ()
{
	if (other.classname != "player")
		return;

	if (time < self.attack_finished)
		return;

	self.attack_finished = time + 2;

	if (!(other.items & self.items)) {
		centerprint (other, self.message);
		sound (other, CHAN_VOICE, "doors/medtry.wav", 1, ATTN_NORM);
		return;
	}

	self.touch = SUB_Null;
	self.message = "";

	// hipnotic steals your key when you use it
	other.items = other.items - self.items;

	SUB_UseTargets ();
}

/*QUAKED trigger_usekey
**
** use_gold_key = 1
** .health -- what's it for?
*/
void trigger_usekey ()
{
	precache_sound ("doors/medtry.wav");

	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);
	self.modelindex = 0;

	self.touch = usekey_touch;

	if (self.spawnflags & 1)
		self.items = IT_KEY2;
	else
		self.items = IT_KEY1;
}


//============================================================================

/*QUAKED trigger_waterfall
*/
void trigger_waterfall ()
{
	// it simply doesn't work as intended (to prevent the player from
	// swimming up a waterfall), not even in NetQuake
	remove (self);
}


//============================================================================
