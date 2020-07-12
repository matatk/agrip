/*
	defs.qc

	global definitions

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

/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

//
// system globals
//
entity		self;
entity		other;
entity		world;
float		time;
float		frametime;

entity		newmis; 			// if this is set, the entity that just
								// run created a new missile that should
								// be simulated immediately


float		force_retouch;		// force all entities to touch triggers
								// next frame.	this is needed because
								// non-moving things don't normally scan
								// for triggers, and when a trigger is
								// created (like a teleport trigger), it
								// needs to catch everything.
								// decremented each frame, so set to 2
								// to guarantee everything is touched
string		mapname;

float		serverflags;		// propagated from level to level, used to
								// keep track of completed episodes

float		total_secrets;
float		total_monsters;

float		found_secrets;		// number of secrets found
float		killed_monsters;	// number of monsters killed


// spawnparms are used to encode information about clients across server
// level changes
float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//
vector		v_forward, v_up, v_right;	// set by makevectors()

// set by traceline / tracebox
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector		trace_endpos;
vector		trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen;
float		trace_inwater;

entity		msg_entity;			// destination of single entity writes

//
// required prog functions
//
void		main ();			// only for testing

void		StartFrame ();

void		PlayerPreThink ();
void		PlayerPostThink ();

void		ClientKill ();
void		ClientConnect ();
void		PutClientInServer ();	// call after setting the parm1... parms
void		ClientDisconnect ();

void		SetNewParms ();		// called when a client first connects to
								// a server. sets parms so they can be
								// saved off for restarts

void		SetChangeParms (); 	// call to set parms for self so they can
								// be saved for a level transition


//================================================
void		end_sys_globals;		// flag for structure dumping
//================================================

/*
==============================================================================

	    SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float		modelindex;		// *** model index in the precached list
.vector 	absmin, absmax; // *** origin + mins / maxs

.float		ltime;			// local time for entity
.float		lastruntime;	// *** to allow entities to run out of sequence

.float		movetype;
.float		solid;

.vector 	origin; 		// ***
.vector 	oldorigin;		// ***
.vector 	velocity;
.vector 	angles;
.vector 	avelocity;

.string 	classname;		// spawn function
.string 	model;
.float		frame;
.float		skin;
.float		effects;

.vector 	mins, maxs;		// bounding box extents reletive to origin
.vector 	size;			// maxs - mins

.void() 	touch;
.void() 	use;
.void() 	think;
.void() 	blocked;		// for doors or plats, called when can't push other

.float		nextthink;
.entity 	groundentity;



// stats
.float		health;
.float		frags;
.float		weapon; 		// one of the IT_SHOTGUN, etc flags
.string 	weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;

.float		items;			// bit flags

.float		takedamage;
.entity 	chain;
.float		deadflag;

.vector 	view_ofs;		// add to origin to get eye point


.float		button0;		// fire
.float		button1;		// use
.float		button2;		// jump

.float		impulse;		// weapon changes

.float		fixangle;
.vector 	v_angle;		// view / targeting angle for players

.string 	netname;

.entity 	enemy;

.float		flags;

.float		colormap;
.float		team;

.float		max_health;		// player's maximum health is stored here

.float		teleport_time;	// don't back up

.float		armortype;		// save this fraction of incoming damage
.float		armorvalue;

.float		waterlevel;		// 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float		watertype;		// a contents value

.float		ideal_yaw;
.float		yaw_speed;

.entity 	aiment;

.entity 	goalentity;		// a movetarget or an enemy

.float		spawnflags;

.string 	target;
.string 	targetname;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float		dmg_take;
.float		dmg_save;
.entity 	dmg_inflictor;

.entity 	owner;			// who launched a missile
.vector 	movedir;		// mostly for doors, but also used for waterjump

.string 	message;		// trigger messages

.float		sounds; 		// either a cd track number or sound number

.string 	noise, noise1, noise2, noise3;	// contains names of wavs to play

//================================================
void		end_sys_fields; 		// flag for structure dumping
//================================================

/*
==============================================================================

		VARS NOT REFERENCED BY C CODE

==============================================================================
*/


//
// constants
//

const float false				= 0;
const float true				= 1;

// edict.flags
const float FL_FLY				= 1;
const float FL_SWIM 			= 2;
const float FL_CLIENT			= 8;	// set for all client edicts
const float FL_INWATER			= 16;	// for enter / leave water splash
const float FL_MONSTER			= 32;
const float FL_GODMODE			= 64;	// player cheat
const float FL_NOTARGET			= 128;	// player cheat
const float FL_ITEM 			= 256;	// extra wide size for bonus items
const float FL_ONGROUND			= 512;	// standing on something
const float FL_PARTIALGROUND	= 1024; // not all corners are valid
const float FL_WATERJUMP		= 2048; // player jumping out of water
const float FL_JUMPRELEASED 	= 4096; // for jump debouncing

// edict.movetype values
const float MOVETYPE_NONE			= 0;	// never moves
//const float MOVETYPE_ANGLENOCLIP	= 1;
//const float MOVETYPE_ANGLECLIP	= 2;
const float MOVETYPE_WALK			= 3;	// players only
const float MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
const float MOVETYPE_FLY			= 5;
const float MOVETYPE_TOSS			= 6;	// gravity
const float MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
const float MOVETYPE_NOCLIP 		= 8;
const float MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
const float MOVETYPE_BOUNCE 		= 10;
const float MOVETYPE_BOUNCEMISSILE	= 11;	// bounce with extra size

// edict.solid values
const float SOLID_NOT				= 0;	// no interaction with other objects
const float SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
const float SOLID_BBOX				= 2;	// touch on edge, block
const float SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
const float SOLID_BSP				= 4;	// bsp clip, touch on edge, block

// range values
const float RANGE_MELEE				= 0;
const float RANGE_NEAR				= 1;
const float RANGE_MID				= 2;
const float RANGE_FAR				= 3;

// deadflag values
const float DEAD_NO 				= 0;
const float DEAD_DYING				= 1;
const float DEAD_DEAD				= 2;
const float DEAD_RESPAWNABLE		= 3;

// takedamage values
const float DAMAGE_NO				= 0;
const float DAMAGE_YES				= 1;
const float DAMAGE_AIM				= 2;


// items
const float IT_AXE					= 0x1000;
const float IT_SHOTGUN				= 0x0001;
const float IT_SUPER_SHOTGUN		= 0x0002;
const float IT_NAILGUN				= 0x0004;
const float IT_SUPER_NAILGUN		= 0x0008;
const float IT_GRENADE_LAUNCHER		= 0x0010;
const float IT_ROCKET_LAUNCHER		= 0x0020;
const float IT_LIGHTNING			= 0x0040;
//const float IT_EXTRA_WEAPON		= 0x0080;
const float IT_ALL_WEAPONS			= 0x107f;
const float IT_DROPPABLE_WEAPONS	= 0x007e; // minus axe and shotgun

const float IT_SHELLS				= 0x0100;
const float IT_NAILS				= 0x0200;
const float IT_ROCKETS				= 0x0400;
const float IT_CELLS				= 0x0800;

const float IT_ARMOR1				= 0x2000;
const float IT_ARMOR2				= 0x4000;
const float IT_ARMOR3				= 0x8000;
const float IT_SUPERHEALTH			= 0x010000;

const float IT_KEY1 				= 0x020000;
const float IT_KEY2 				= 0x040000;

const float IT_INVISIBILITY 		= 0x080000;
const float IT_INVULNERABILITY		= 0x100000;
const float IT_SUIT 				= 0x200000;
const float IT_QUAD 				= 0x400000;


// point content values
const float CONTENT_EMPTY			= -1;
const float CONTENT_SOLID			= -2;
const float CONTENT_WATER			= -3;
const float CONTENT_SLIME			= -4;
const float CONTENT_LAVA			= -5;
const float CONTENT_SKY				= -6;

const float STATE_TOP		= 0;
const float STATE_BOTTOM	= 1;
const float STATE_UP		= 2;
const float STATE_DOWN		= 3;

const vector VEC_ORIGIN		= '0 0 0';
// player hull
const vector VEC_HULL_MIN	= '-16 -16 -24';
const vector VEC_HULL_MAX	= '16 16 32';
// shambler hull
const vector VEC_HULL2_MIN	= '-32 -32 -24';
const vector VEC_HULL2_MAX	= '32 32 64';

// protocol bytes
const float SVC_TEMPENTITY		= 23;
const float SVC_KILLEDMONSTER	= 27;
const float SVC_FOUNDSECRET 	= 28;
const float SVC_INTERMISSION	= 30;
const float SVC_FINALE			= 31;
const float SVC_CDTRACK			= 32;
const float SVC_SELLSCREEN		= 33;
const float SVC_SMALLKICK		= 34;
const float SVC_BIGKICK			= 35;
const float SVC_MUZZLEFLASH 	= 39;

// temp entities
const float TE_SPIKE			= 0;
const float TE_SUPERSPIKE		= 1;
const float TE_GUNSHOT			= 2;
const float TE_EXPLOSION		= 3;
const float TE_TAREXPLOSION		= 4;
const float TE_LIGHTNING1		= 5;
const float TE_LIGHTNING2		= 6;
const float TE_WIZSPIKE			= 7;
const float TE_KNIGHTSPIKE		= 8;
const float TE_LIGHTNING3		= 9;
const float TE_LAVASPLASH		= 10;
const float TE_TELEPORT			= 11;
const float TE_BLOOD			= 12;
const float TE_LIGHTNINGBLOOD	= 13;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) always override a playing sound on that channel
const float CHAN_AUTO		= 0;
const float CHAN_WEAPON		= 1;
const float CHAN_VOICE		= 2;
const float CHAN_ITEM		= 3;
const float CHAN_BODY		= 4;
const float CHAN_NO_PHS_ADD = 8;	// ie: CHAN_BODY+CHAN_NO_PHS_ADD

// sound attenuation
const float ATTN_NONE		= 0;
const float ATTN_NORM		= 1;
const float ATTN_IDLE		= 2;
const float ATTN_STATIC		= 3;

// entity effects
//const float EF_BRIGHTFIELD	= 1;
//const float EF_MUZZLEFLASH	= 2;
const float EF_BRIGHTLIGHT		= 4;
const float EF_DIMLIGHT			= 8;
const float EF_FLAG1			= 16;
const float EF_FLAG2			= 32;
const float EF_BLUE				= 64;	// Blue Globe effect for Quad
const float EF_RED				= 128;	// Red Globe effect for Pentagram

// messages
const float MSG_BROADCAST		= 0;	// unreliable to all
const float MSG_ONE 			= 1;	// reliable to one (msg_entity)
const float MSG_ALL		 		= 2;	// reliable to all
const float MSG_INIT			= 3;	// write to the init string
const float MSG_MULTICAST		= 4;	// for multicast() call

// message levels
const float PRINT_LOW		= 0;		// pickup messages
const float PRINT_MEDIUM	= 1;	    // death messages
const float PRINT_HIGH		= 2;		// critical messages
const float PRINT_CHAT		= 3;		// also goes to chat console

// multicast sets
const float MULTICAST_ALL	= 0;		// every client
const float MULTICAST_PHS	= 1;		// within hearing
const float MULTICAST_PVS	= 2;		// within sight
const float MULTICAST_ALL_R	= 3;		// every client, reliable
const float MULTICAST_PHS_R	= 4;		// within hearing, reliable
const float MULTICAST_PVS_R	= 5;		// within sight, reliable




//================================================

//
// globals
//
const string  string_null = "";    // null string, nothing should be held here

entity	activator;		// the entity that activated a trigger or brush

entity	damage_attacker;	// set by T_Damage
entity	damage_inflictor;
float	framecount;

//
// cvars checked each frame
//
float		teamplay;
float		timelimit;
float		fraglimit;

//
// checked in worldspawn() and not changing for the whole game
//
float		deathmatch;
float		skill;
float		coop;

//================================================

//
// world fields (FIXME: make globals)
//
.string 	wad;
.string 	map;
.float		worldtype;	// 0=medieval 1=metal 2=base

//================================================

.string 	killtarget;

//
// quakeed fields
//
.float		light_lev;		// not used by game, but parsed by light util
.float		style;


//
// monster ai & used in mp
//
.void(entity attacker, float damage)		th_pain;
.void() 	th_die;

.float		speed;

//
// player only fields
//
.float		voided;
.float		walkframe;

// Zoid Additions
.float	    gravity;	    // Gravity Multiplier (0 to 1.0)



.float		attack_finished;
.float		pain_finished;

.float		invincible_finished;
.float		invisible_finished;
.float		super_damage_finished;
.float		radsuit_finished;

.float		invincible_time, invincible_sound;
.float		invisible_time, invisible_sound;
.float		super_time, super_sound;
.float		rad_time;
.float		fly_sound;

.float		axhitme;

.float		show_hostile;	// set to time+0.2 whenever a client fires a
							// weapon or takes damage.	Used to alert
							// monsters that otherwise would let the player go
.float		jump_flag;		// player jump flag
.float		swim_flag;		// player swimming sound flag
.float		air_finished;	// when time > air_finished, start drowning
.float		bubble_count;	// keeps track of the number of bubbles
.string 	deathtype;		// keeps track of how the player died

//
// object stuff
//
.string 	mdl;
.vector 	mangle; 		// angle at start

.vector 	oldorigin;		// only used by secret door

.float		t_length, t_width;


//
// doors, etc
//
.vector 	dest1, dest2;
.float		wait;			// time from firing to restarting
.float		delay;			// time from activation to firing
.entity 	trigger_field;	// door's trigger entity
.string 	noise4;

//
// monsters in qwsp & teleporters in qw
//
.float		pausetime; // paustime is also set by teleporters to keep the player from moving a while


//
// doors
//
.float		aflag;
.float		dmg;			// damage done by door when hit

//
// misc
//
.float		cnt;			// misc flag

//
// subs
//
.void() 	think1;
.vector 	finaldest, finalangle;

//
// triggers
//
.float		count;			// for counting triggers


//
// plats / doors / buttons
//
.float		lip;
.float		state;
.vector 	pos1, pos2;		// top and bottom positions
.float		height;




//===========================================================================


//
// builtin functions
//

void(vector ang)	makevectors		= #1;		// sets v_forward, etc globals
void(entity e, vector o) setorigin	= #2;
void(entity e, string m) setmodel	= #3;		// set movetype and solid first
void(entity e, vector min, vector max) setsize = #4;
// #5 was removed
void() debugbreak					= #6;		// drop to debugger
float() random						= #7;		// returns 0 - 1
#ifndef FRIKBOT
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
#endif
vector(vector v) normalize			= #9;
void(string e, ...) error			= #10;
void(string e, ...) objerror 		= #11;
float(vector v) vlen				= #12;
float(vector v) vectoyaw			= #13;
entity() spawn						= #14;
void(entity e) remove				= #15;

// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of world is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;

entity() checkclient				= #17;	// returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound 	= #19;
string(string s) precache_model 	= #20;
void(entity client, string s)stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(float level, string s, ...) bprint				= #23;
void(entity client, float level, string s, ...) sprint = #24;
void(string s, ...) dprint			= #25;
string(float f) ftos				= #26;
string(vector v) vtos				= #27;
void() coredump 					= #28;		// prints all edicts
void() traceon						= #29;		// turns statment trace on
void() traceoff 					= #30;
void(entity e) eprint				= #31;		// prints an entire edict
float(float yaw, float dist) walkmove	= #32;	// returns true or false
// #33 was removed
float() droptofloor = #34;						// true if landed on floor
void(float style, string value) lightstyle = #35;
float(float v) rint					= #36;		// round to nearest int
float(float v) floor				= #37;		// largest integer <= v
float(float v) ceil					= #38;		// smallest integer >= v
// #39 was removed
float(entity e) checkbottom			= #40;		// true if self is on ground
float(vector v) pointcontents		= #41;		// returns a CONTENT_*
// #42 was removed
float(float f) fabs = #43;
#ifndef FRIKBOT
vector(entity e, float speed) aim = #44;		// returns the shooting vector
#endif
float(string s) cvar = #45;						// return cvar.value
void(string s) localcmd = #46;					// put string into local que
entity(entity e) nextent = #47; 				// for looping through all ents
// #48 was removed
void() ChangeYaw = #49; 						// turn towards self.ideal_yaw
					    // at self.yaw_speed
// #50 was removed
vector(vector v) vectoangles			= #51;

//
// direct client message generation
//
void(float to, float f) WriteByte		= #52;
void(float to, float f) WriteChar		= #53;
void(float to, float f) WriteShort		= #54;
void(float to, float f) WriteLong		= #55;
void(float to, float f) WriteCoord		= #56;
void(float to, float f) WriteAngle		= #57;
void(float to, string s) WriteString	= #58;
void(float to, entity s) WriteEntity	= #59;

// several removed

void(float step) movetogoal				= #67;

string(string s) precache_file		= #68;	// no effect except for -copy
void(entity e) makestatic		= #69;
void(string s) changelevel = #70;

//#71 was removed

void(string var, string val) cvar_set = #72;	// sets cvar.value

void(entity client, string s, ...) centerprint = #73;	// sprint, but in middle

void(vector pos, string samp, float vol, float atten) ambientsound = #74;

string(string s) precache_model2	= #75;		// registered version only
string(string s) precache_sound2	= #76;		// registered version only
string(string s) precache_file2 	= #77;		// registered version only

void(entity e) setspawnparms		= #78;		// set parm1... to the
												// values at level start
												// for coop respawn

void(entity killer, entity killee) logfrag = #79;	// add to stats

string(entity e, string key) infokey	= #80;	// get a key value (world = serverinfo)
float(string s) stof				= #81;		// convert string to float
void(vector where, float set) multicast = #82;	// sends the temp message to a set
						// of clients, possibly in PVS or PHS


//============================================================================

//
// forward declarations
//

// subs.qc
void SUB_CalcMove (vector tdest, float tspeed, void() func);
void SUB_CalcMoveEnt (entity ent, vector tdest, float tspeed, void() func);
void SUB_CalcAngleMove (vector destangle, float tspeed, void() func);
void SUB_CalcMoveDone ();
void SUB_CalcAngleMoveDone ();
void SUB_Null ();
void SUB_UseTargets ();
void SUB_Remove ();

// combat.qc
void T_Damage (entity targ, entity inflictor, entity attacker, float damage);
float CanDamage (entity targ, entity inflictor);

// items.qc
float T_Heal (entity e, float heal_amount, float ignore); // health function


//============================================================================

//
// ZQuake additions
//

.float suicide_time;	// can't suicide sooner than this
