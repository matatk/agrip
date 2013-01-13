/*
	hip_misc.qc

	spawn functions for misc entities - ambient sounds etc

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

/*QUAKED ambient_humming
*/
void ambient_humming ()
{
	if (!self.volume)
		self.volume = 1;
	precache_sound ("ambient/humming.wav");
	ambientsound (self.origin, "ambient/humming.wav", self.volume, ATTN_STATIC);
	remove (self);
}


/*QUAKED ambient_rushing
*/
void ambient_rushing ()
{
	if (!self.volume)
		self.volume = 1;
	precache_sound ("ambient/rushing.wav");
	ambientsound (self.origin, "ambient/rushing.wav", self.volume, ATTN_STATIC);
	remove (self);
}

/*QUAKED ambient_fan_blowing
*/
void ambient_fan_blowing ()
{
	if (!self.volume)
		self.volume = 1;
	precache_sound ("ambient/fanblow.wav");
	ambientsound (self.origin, "ambient/fanblow.wav", self.volume, ATTN_STATIC);
	remove (self);
}

/*QUAKED ambient_running_water
*/
void ambient_running_water ()
{
	if (!self.volume)
		self.volume = 1;
	precache_sound ("ambient/runwater.wav");
	ambientsound (self.origin, "ambient/runwater.wav", self.volume, ATTN_STATIC);
	remove (self);
}

/*QUAKED ambient_waterfall
*/
void ambient_waterfall ()
{
	if (!self.volume)
		self.volume = 1;
	precache_sound ("ambient/waterfal.wav");
	ambientsound (self.origin, "ambient/waterfal.wav", self.volume, ATTN_STATIC);
	remove (self);
}

/*QUAKED ambient_riftpower
*/
void ambient_riftpower ()
{
	if (!self.volume)
		self.volume = 1;
	precache_sound ("ambient/riftpowr.wav");
	ambientsound (self.origin, "ambient/riftpowr.wav", self.volume, ATTN_STATIC);
	remove (self);
}

//============================================================================

void play_sound_think ()
{
	sound (self, self.impulse, self.noise, self.volume, self.speed);
	self.nextthink = self.delay + random() * self.wait;
}

/*QUAKED play_sound
.noise
.volume
.impulse (channel)
.speed (attenuation)
.wait
.delay

Not really used on hipnotic maps at all...
*/
void play_sound ()
{
	if (!self.volume)
		self.volume = 1;
	if (!self.speed)
		self.speed = ATTN_NORM;
	if (!self.wait)
		self.wait = 20;
	if (!self.delay)
		self.delay = 2;

	precache_sound (self.noise);

	self.think = play_sound_think;
	self.nextthink = self.delay + random() * self.wait;
}


//============================================================================

void play_sound_use ();

void play_sound_on_use ()
{
	sound (self, self.impulse, self.noise, 0, self.speed);
	self.use = play_sound_use;
}

void play_sound_use ()
{
	sound (self, self.impulse, self.noise, self.volume, self.speed);

	if (self.spawnflags & 1)
		self.use = play_sound_on_use;
}


/*QUAKED play_sound_triggered
.noise
.volume
.impulse (channel)
.speed (attenuation)
.wait
.delay

TOGGLE == 1 - TODO
*/
void play_sound_triggered ()
{
	if (!self.volume)
		self.volume = 1;
	if (!self.speed)
		self.speed = ATTN_NORM;
	else if (self.speed == -1)
		self.speed = ATTN_NONE;

	precache_sound (self.noise);

	self.use = play_sound_use;

	if (!self.impulse)
		self.impulse = 7;
}

//============================================================================

/*QUAKED random_thunder
Not used on hipnotic maps
*/
void random_thunder ()
{
	self.noise = "ambience/thunder1.wav";
	play_sound ();
}

/*QUAKED random_thunder_triggered
*/
void random_thunder_triggered ()
{
	self.noise = "ambience/thunder1.wav";
	play_sound_triggered ();
}

//============================================================================
