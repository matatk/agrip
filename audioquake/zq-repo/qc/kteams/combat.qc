/*
	combat.qc

	damage, obit, etc related functions

	Copyright (C) 1996-1997  Id Software, Inc.

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

void ClientObituary (entity targ, entity attacker);
void T_RadiusDamage (entity inflictor, entity attacker, float damage, entity ignore, string dtype);
#ifdef KTEAMS
void EndMatch (float skip_log); // KTEAMS
#endif

#ifndef KTEAMS
void monster_death_use ();
void GetMadAtAttacker (entity attacker);
#endif

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float CanDamage (entity targ, entity inflictor)
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), true, self);
		if (trace_fraction == 1)
			return true;
		if (trace_ent == targ)
			return true;
		return false;
	}

	traceline(inflictor.origin, targ.origin, true, self);
	if (trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '15 15 0', true, self);
	if (trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', true, self);
	if (trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '-15 15 0', true, self);
	if (trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '15 -15 0', true, self);
	if (trace_fraction == 1)
		return true;

	return false;
}


/*
============
Killed
============
*/
void Killed (entity targ, entity attacker)
{
	entity	oself;

	oself = self;
	self = targ;

#ifdef KTEAMS
	if (self.classname == "player")
        self.dead_time = time;
#endif

	if (self.health < -99)
		self.health = -99;              // don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{       // doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = attacker;

// bump the monster counter
	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);

		// in coop, killing a monster gives you a frag
		if (coop)
		{
			if (attacker.classname == "player")
				attacker.frags = attacker.frags + 1;
		}
	}

	ClientObituary(self, attacker);

	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;
	self.effects = 0;

#ifndef KTEAMS
	monster_death_use();
#endif
    self.th_die ();

	self = oself;
}


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void T_Damage (entity targ, entity inflictor, entity attacker, float damage)
{
	vector	dir;
	entity	oldself;
	float	save;
	float	take;
	string	attackerteam, targteam;


	if (!targ.takedamage)
		return;

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;


// check for quad damage powerup on the attacker
	if (attacker.super_damage_finished > time && inflictor.classname != "door"
		&& targ.deathtype != "stomp")
	{
		if (deathmatch == 4)
			damage = damage * 8;
		else
			damage = damage * 4;
	}

// save damage based on the target's armor level

	save = ceil(targ.armortype*damage);
	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;     // lost all armor
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}

	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage-save);

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

	damage_inflictor = inflictor;       


// figure momentum add
	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir * damage * 8;
	}



// check for godmode or invincibility
	if (targ.flags & FL_GODMODE)
		return;
	if (targ.invincible_finished >= time)
	{
		if (targ.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			targ.invincible_sound = time + 2;
		}
		return;
	}

// team play damage avoidance
	if (teamplay == 1 || teamplay == 3)
	{
		attackerteam = infokey(attacker, "team");
		targteam = infokey(targ, "team");

		if ((targteam == attackerteam) && (attacker.classname == "player")
			&& (inflictor.classname != "door"))
		{
			if (teamplay == 1)
			{	// no damage from self or teammates
				if (attackerteam != "" || targ == attacker)
					return;
			}
			else
			{
				// teamplay 3 - no damage from teammates
				if (attackerteam != "" && targ != attacker)
					return;
			}
		}
	}
	
// do the damage
#ifdef KTEAMS
	if (match_in_progress == 2 || attacker.classname == "teledeath") // KTEAMS
#endif
        targ.health = targ.health - take;

	if (targ.health <= 0)
	{
		Killed (targ, attacker);
#ifdef KTEAMS
        // KTEAMS: check if sudden death is the case
        if (k_sudden_death && targ.classname == "player" )
            EndMatch(0);
#endif
		return;
	}

// react to the damage
	oldself = self;
	self = targ;

#ifndef KTEAMS
  	if (self.flags & FL_MONSTER)
  	{
  		if (attacker != world)
  			GetMadAtAttacker (attacker);
  	}
#endif

	if (self.th_pain)
	{
		self.th_pain (attacker, take);
	}

	self = oldself;
}

/*
============
T_RadiusDamage
============
*/
void T_RadiusDamage (entity inflictor, entity attacker, float damage, entity ignore, string dtype)
{
	float	points;
	entity	head;
	vector	org;

	head = findradius(inflictor.origin, damage+40);

	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
			
				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{
						head.deathtype = dtype;
						T_Damage (head, inflictor, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
}

/*
============
T_BeamDamage
============
*/
void T_BeamDamage (entity attacker, float damage)
{
	float	points;
	entity	head;

	head = findradius(attacker.origin, damage+40);

	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
					T_Damage (head, attacker, attacker, points);
			}
		}
		head = head.chain;
	}
}

