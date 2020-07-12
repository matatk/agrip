//================================================
#define QWSP

//
// globals
//
float	movedist;

//
// monster ai
//
.void() 	th_stand;
.void() 	th_walk;
.void() 	th_run;
.void() 	th_missile;
.void() 	th_melee;

.entity 	oldenemy;		// mad at this player before taking damage

.float	lefty;

.float	search_time;
.float	attack_state;

const float	AS_STRAIGHT		= 1;
const float	AS_SLIDING		= 2;
const float	AS_MELEE		= 3;
const float	AS_MISSILE		= 4;

//
// monsters
//
.entity 	movetarget;

//
// sounds
//
.float		waitmin;
