/*
==============================================================================

Zeus Bot 2.0 beta

by Jonathan E. Wright
nelno@interpath.com
http://www.trailerpark.com/phase1/nelno/

Version 2.0 features an all new code base, based on the enforcer model,
with Quake C 1.06 source.

==============================================================================
*/

// compiler define for GL version
float   GL_QUAKE = 0;

/*
===================
constants
=============
*/
float   ZEUS_ACTIVATE           = 100;
float   ZEUS_DEACTIVATE         = 101;
float	ZEUS_TELEPORT           = 102;
float   ZEUS_LIGHT_TOGGLE       = 103;
float   ZEUS_GIVE_STATUS        = 104;
float   ZEUS_ATTACK_TOGGLE      = 105;
float   ZEUS_VIEW_TOGGLE        = 106;
float   ZEUS_STAY_TOGGLE        = 107;
float   ZEUS_FORCE_AXE          = 108;
float   ZEUS_COMMENT_TOGGLE     = 109;
float   ZEUS_ROAM_TOGGLE        = 110;
float   ZEUS_DROP_BACKPACK      = 111;
float   ZEUS_HUD_TOGGLE         = 112;
float	ZEUS_PATH_TOGGLE		= 113;

// Impulses for development and debugging
float   ZEUS_VERBOSE_TOGGLE     = 125;
float   ZEUS_KILL_ALL           = 126;
float   ZEUS_PLAYER_INVUL       = 127;
float   ZEUS_DEBUG_TOGGLE       = 128;
float   ZEUS_SHOW_UNREACHABLES  = 129;
float   ZEUS_SHOW_OPP_DIST      = 130;
float   ZEUS_OBSERVER_TOGGLE    = 131;
float   ZEUS_CHECK_TERRAIN      = 132;
float   ZEUS_TOGGLE_ROAM_GOAL   = 133;
float   ZEUS_TOGGLE_NODES       = 135;
float   ZEUS_SHOW_NODE_INFO     = 136;
float   ZEUS_SHOW_PATH          = 137;
float   ZEUS_GO_TO_ITEM         = 138;
float   ZEUS_SHOW_LINKS         = 139;

// deathmatch bot impulses
float   ZEUS_SPAWN_OPPONENT     = 150;
float   ZEUS_SHOW_SCORES        = 151;
float   ZEUS_SPAWN_MULTI        = 152;

// multiskin impulses
float   MULTISKIN_DOWN          = 200;
float   MULTISKIN_UP            = 201;
float   MULTISKIN_TOGGLE        = 202;
float   ZEUS_EXTRAS_TOGGLE      = 205;

// constants for tracking current frame type
float   FRAME_AXESTAND          = 0;
float   FRAME_AXEWATER          = 1;
float   FRAME_WATERSTAND        = 2;
float   FRAME_STAND             = 3;
float   FRAME_AXERUN            = 4;
float   FRAME_RUN               = 5;
float   FRAME_AXEFOLLOW         = 6;
float   FRAME_FOLLOW            = 7;
float   FRAME_AXEATTACKA        = 8;
float   FRAME_AXEATTACKB        = 9;
float   FRAME_AXEATTACKC        = 10;
float   FRAME_AXEATTACKD        = 11;
float   FRAME_NAILATTACK        = 12;
float   FRAME_ROCKETATTACK      = 13;
float   FRAME_THUNDERATTACK     = 14;
float   FRAME_SHOTGUNATTACK     = 15;
float   FRAME_PAIN              = 16;
float   FRAME_AXEPAIN           = 17;
float   FRAME_DEATHA            = 18;
float   FRAME_DEATHB            = 19;
float   FRAME_DEATHC            = 20;
float   FRAME_DEATHD            = 21;
float   FRAME_DEATHE            = 22;
float   FRAME_AXEDEATH          = 23;
float   FRAME_JUMP              = 24;

// distance ZEUS or an item has to move before he will try again to get/attack it
float   ZEUS_item_retry_dist    = 250;
float   ZEUS_optimal_goal_dist  = 108;
float   ZEUS_roam_goal_dist     = 32;
// float   ZEUS_teamplay           = true;

// type of bot for ZEUS_SetupBot
float   ZEUS_OPPONENT = 1;
float   ZEUS_HELPER = 0;

// server message constants
float SVC_SETVIEWPORT	= 5;
float SVC_SETVIEWANGLES	= 10;

// terrain types
float   TER_NONE      = 0;
float   TER_PARTIAL   = 1;
float   TER_GRADEUP   = 2;
float   TER_HIGH_OBS  = 3;
float   TER_WALL      = 4;
float   TER_GRADEDOWN = 5;

float   ZEUS_show_dist;
float   ZEUS_multiskin;
float   ZEUS_extras;

float teleport_dist = 1500;
float nextthinktime = 0.1;
float deathcam_thinktime = 0.025;

// type of liquid found in ZEUS_CheckWater
float water_type;

// stores lead firing position from CanHit so that bot only calculates
// leading / misses once
vector ZEUS_lead_pos;

// if true, yaw changes automatically to follow the bot
float deathcam_time;
vector death_loc;
/*
===================
global variables
===================
*/

vector  old_player_angles;
float   findtarget_skip;
float   ZEUS_verbose;
float   ZEUS_debug;

float   ZEUS_comments;
float   ZEUS_last_waterlevel;

vector  wall_pitch;
float   wall_yaw;
float   wall_dist;
float   wall_type;

vector  entity_org;

/*
===================
function prototypes
===================
*/

// external to zeus.qc

void () HUD_Init;
void (entity targ, entity viewer) HUD_TargetOn;

// internal to zeus.qc

void ()                           ZEUS_ai_stand;
void (float dist)                 ZEUS_ai_run;
void ()                           ZEUS_ai_face;
void ()                           ZEUS_fire;
void (float dist)                 ZEUS_ai_forward;
void (float dist)                 ZEUS_ai_back;
void ()                           ZEUS_ai_swim;
void (float dist)                 ZEUS_ai_follow;
void ()                           ZEUS_TeleportToOwner;
void (void () think_func)         ZEUS_CheckAttack;
void ()                           ZEUS_JumpTouch;
void (float dist)                 ZEUS_ai_run_and_shoot;
float (vector start, vector end)  ZEUS_CanHit;
float (entity ent)                ZEUS_WaterLevel;
void ()                           ZEUS_SelfDeactivate;
void ()                           ZEUS_SetPlayerView;
void ()                           ZEUS_ChooseWeapon;
void ()                           ZEUS_attack;
float (entity first_bot)          ZEUS_CountBots;
void ()                           ZEUS_RespawnBot;
float ()                          ZEUS_JumpAI;
float (float dist)                ZEUS_FindLedge;
float (float dist)                ZEUS_JumpObstructed;
void  (entity item, string caller)ZEUS_MakeUnreachable;
float (float dist)                ZEUS_CheckGap;
void  ()                          ZEUS_allstop;
void ()                           ZEUS_CheckWaterJump;
float (entity targ)               ZEUS_ChanceToHit;
void ()                           ZEUS_ResetGoalEntity;
void ()                           ZEUS_UpdateView;
void ()                           ZEUS_ChangeYaw;

$cd id1/models/player_4
$origin 0 -6 24
$base base
$skin skin

//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6

/*
======================
ZEUS_WaterMove

Determines if the bot should take damage from being in a liquid, ie. lava, slime or water
Damages the bot if need be and plays the appropriate damage sound

Input:   none
Output:  none
Changes: self.air_finished, self.dmg_time, self.health
======================
*/

void () ZEUS_WaterMove =
{
  if ((self.health > 0) && (self.deadflag == DEAD_NO))
  {
    if ((self.ZEUS_waterlevel != 3) && (ZEUS_last_waterlevel == 3))
    {
      if (self.air_finished < time)
        sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
      else if (self.air_finished < time + 9)
        sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
      self.air_finished = time + 12;
      self.dmg = 2;
    }
    else if ((self.air_finished < time) && (self.ZEUS_waterlevel > 2))
    {	// drown!
      if (self.dmgtime < time)
      {
         self.dmg = self.dmg + 2;
         if (self.dmg > 15)
           self.dmg = 10;
         T_Damage (self, world, world, self.dmg);
         self.dmgtime = time + 1;
      }
    }

    if (self.ZEUS_watertype == CONTENT_LAVA)
    {// do damage
      if (self.dmgtime < time)
      {
        if (self.radsuit_finished > time)
          self.dmgtime = time + 1;
        else
          self.dmgtime = time + 0.2;

        T_Damage (self, world, world, 10*self.ZEUS_waterlevel);

        if (random () < 0.5)
          sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
        else
          sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
      }
    }
    else if (self.ZEUS_watertype == CONTENT_SLIME)
    {  // do damage
      if (self.dmgtime < time && self.radsuit_finished < time)
      {
        self.dmgtime = time + 1;
        T_Damage (self, world, world, 4*self.ZEUS_waterlevel);
     }
   }
  }
};

/*
======================
ZEUS_FrameStart

Should be called at the beginning of each frame.  It's not called automatically, so
every possible frame starting function needs to have this at the top.  It does a few
important things:

Checks and sets the bots current water level in .ZEUS_waterlevel
Calls water move to determine if bot should take damage

Checks powerup status.

Can be very helpful for debugging, because it is designed to show
which procedure is being called during each frame

Input:   string caller - the name of the calling function, for debugging
Output:  none
Changes: none
======================
*/

void () CheckRules;

void (string caller) ZEUS_FrameStart =
{
  // get the bot's water level, and if he's under water, make him sink
  ZEUS_WaterLevel (self);
  if (self.ZEUS_waterlevel > 0)  ZEUS_WaterMove ();

  CheckPowerups ();
/*
  if (ZEUS_debug)
  {
    bprint (PRINT_HIGH, "FrameStart, ");
    bprint (PRINT_HIGH, caller);
    bprint (PRINT_HIGH, "\n");
  }
*/

  CheckRules ();

  if (intermission_running) 
    remove (self);
};

/*
======================
ZEUS_Cl_Msg

sprints the passed strings as long as bot_owner is a client

Input:   string str1 - string to print to console
Output:  none
Changes: none
======================
*/

void (string str1) ZEUS_Cl_Msg =
{
  if (!(self.bot_owner.flags & FL_CLIENT)) return;

  if (str1 != "")
    sprint (self.bot_owner, PRINT_HIGH, str1);
};

/*
======================
ZEUS_sprint

sprints the passed strings as long as ent is a client.  This is called
from other modules to keep from getting a "tried to sprint to non-client"
message when a bot's owner changes.

Input:   ent - entity to print to
         string str1 - string to print to console
Output:  none
Changes: none
======================
*/

void (entity ent, string str1) ZEUS_sprint =
{
  if (!(ent.flags & FL_CLIENT)) return;

  if (str1 != "")
    sprint (ent, PRINT_HIGH, str1);
};


/*
======================
ZEUS_Msg

bprints the passed strings, without a newline.  Generally used for viewing
a bot's thinking patterns

Input:   string str1 - string to print to console
Output:  none
Changes: none
======================
*/

void (string str1) ZEUS_Msg =
{
  if (ZEUS_verbose)
  {
    if (str1 != "")
      bprint (PRINT_HIGH, str1);
  }
};

/*
======================
ZEUS_Msgln

bprints the passed strings and a newline.  Generally used for viewing
a bot's thinking patterns

Input:   string str1 - string to print to console
Output:  none
Changes: none
======================
*/

void (string str1) ZEUS_Msgln =
{
  if (ZEUS_verbose)
  {
    if (str1 != "")
      bprint (PRINT_HIGH, str1);

    bprint (PRINT_HIGH, "\n");
  }
};

/*
======================
Debug_Msg

bprints the passed strings, without a newline.  Used specifically for
debugging, so messages only relay info about current code being
debugged.

Input:   string str1 - string to print to console
Output:  none
Changes: none
======================
*/

void (string str1) Debug_Msg =
{
  if (ZEUS_debug)
  {
    if (str1 != "")
      bprint (PRINT_HIGH, str1);
  }
};

/*
======================
Debug_Msgln

bprints the passed strings and a newline.  Used specifically for
debugging, so messages only relay info about current code being
debugged.

Input:   string str1 - string to print to console
Output:  none
Changes: none
======================
*/

void (string str1) Debug_Msgln =
{
  if (ZEUS_debug)
  {
    if (str1 != "")
      bprint (PRINT_HIGH, str1);

     bprint (PRINT_HIGH, "\n");
  }
};

/*
======================
ZEUS_SpawnMarker

creates an entity to mark a location.  For debugging purposes.  Used
to tell exactly what a bot is looking at, where exactly it is going,
etc.

Input:   vector org - location to place marker
         string mdl_name - model to use for marker
         float ent_time - time for marker to remain before being removed
Output:  none
Changes: none
======================
*/

void (vector org, string mdl_name, float ent_time) ZEUS_SpawnMarker =
{
  local   entity  marker;

  marker = spawn ();

  marker.solid = SOLID_NOT;
  marker.movetype = MOVETYPE_NONE;
  marker.think = SUB_Remove;
  marker.nextthink = time + ent_time;
  marker.takedamage = DAMAGE_NO;
  marker.classname = "debug_marker";

  setsize (marker, '0 0 0', '0 0 0');
  setorigin (marker, org);
  setmodel (marker, mdl_name);
};

/*
====================================
Zeus bot animation control functions
====================================
*/

/*
======================
ZEUS_TrackKiller

Turns the player's head to follow the bot that killed him.

Input:   none
Output:  none
Changes: none
======================
*/

void () ZEUS_TrackKiller =
{
  local   vector  dir;

  if (self.goalentity == self.bot_owner) return;

  if (self.goalentity.deadflag != DEAD_DEAD)
  {
    self.goalentity.oldorigin = self.goalentity.angles;
    return;
  }

  dir = normalize (self.origin + '0 0 16' - self.goalentity.origin);
  self.goalentity.angles = vectoangles (dir);

//  self.goalentity.v_angle = vectoangles (dir);
  self.goalentity.fixangle = true;
};

/*
======================
ZEUS_axestand

frames for standing idle with axe
======================
*/

void()	ZEUS_axestand1	=[	$axstnd1,	ZEUS_axestand2	]
{
  self.cnt = FRAME_AXESTAND;
  ZEUS_FrameStart ("axestand 1 ");
  ZEUS_ai_stand();
  self.pain_finished = time - 1;
};
void()	ZEUS_axestand2	=[	$axstnd2,	ZEUS_axestand3	]
{
  ZEUS_FrameStart ("axestand 2 ");
  ZEUS_ai_stand();

};
void()	ZEUS_axestand3	=[	$axstnd3,	ZEUS_axestand4	]
{
  ZEUS_FrameStart ("axestand 3 ");
  ZEUS_ai_stand();
};
void()	ZEUS_axestand4	=[	$axstnd4,	ZEUS_axestand5	]
{
  ZEUS_FrameStart ("axestand 4 ");
  ZEUS_ai_stand();
};
void()	ZEUS_axestand5	=[	$axstnd5,	ZEUS_axestand6	]
{
  ZEUS_FrameStart ("axestand 5 ");
  ZEUS_ai_stand();
};
void()	ZEUS_axestand6	=[	$axstnd6,	ZEUS_axestand7	]
{
  ZEUS_FrameStart ("axestand 6 ");
  ZEUS_ai_stand();
};
void()	ZEUS_axestand7	=[	$axstnd7,	ZEUS_axestand8	]
{
  ZEUS_FrameStart ("axestand 7 ");
  ZEUS_ai_stand();
};
void()	ZEUS_axestand8	=[	$axstnd8,	ZEUS_axestand9	]
{
  ZEUS_FrameStart ("axestand 8 ");
  ZEUS_ai_stand();
};
void()	ZEUS_axestand9	=[	$axstnd9,	ZEUS_axestand10 ]
{
  ZEUS_FrameStart ("axestand 9 ");
  ZEUS_ai_stand();
};
void()	ZEUS_axestand10 =[     $axstnd10,	ZEUS_axestand11 ]
{
  ZEUS_FrameStart ("axestand 10");
  ZEUS_ai_stand();
};
void()	ZEUS_axestand11 =[     $axstnd11,	ZEUS_axestand12 ]
{
  ZEUS_FrameStart ("axestand 11");
  ZEUS_ai_stand();
};
void()	ZEUS_axestand12 =[     $axstnd12,	ZEUS_axestand1	]
{
  ZEUS_FrameStart ("axestand 12");
  ZEUS_ai_stand();
};


/*
======================
ZEUS_axewater

frames for floating in water with axe.  These use the axe running frames
to make the bot look like it's floating by swimming.
======================
*/

void()	ZEUS_axewater1	=[	$axrun1  ,	ZEUS_axewater2	]
{
  self.cnt = FRAME_AXEWATER;
  ZEUS_FrameStart ("axewater 1");
  self.pain_finished = time - 1;
  ZEUS_ai_stand();
};
void()	ZEUS_axewater2	=[	$axrun2  ,	ZEUS_axewater3	]
{
  ZEUS_FrameStart ("axewater 2");
  ZEUS_ai_stand();
};
void()	ZEUS_axewater3	=[	$axrun3  ,	ZEUS_axewater4	]
{
  ZEUS_FrameStart ("axewater 3");
  ZEUS_ai_stand();
};
void()	ZEUS_axewater4	=[	$axrun4  ,	ZEUS_axewater5	]
{
  ZEUS_FrameStart ("axewater 4");
  ZEUS_ai_stand();
};
void()	ZEUS_axewater5	=[	$axrun5  ,	ZEUS_axewater6	]
{
  ZEUS_FrameStart ("axewater 5");
  ZEUS_ai_stand();
};
void()	ZEUS_axewater6	=[	$axrun6  ,	ZEUS_axewater1	]
{
  ZEUS_FrameStart ("axewater 6");
  ZEUS_ai_stand();
};


/*
======================
ZEUS_waterstand

frames functions for floating in water with a gun.  Uses the run frames
to make the bot appear as if it is floating by swimming.
======================
*/

void()	ZEUS_waterstand1	=[	$rockrun1  ,	ZEUS_waterstand2	]
{
  self.cnt = FRAME_WATERSTAND;
  ZEUS_FrameStart ("waterstand 1");
  self.pain_finished = time - 1;
  ZEUS_ai_stand();
};
void()	ZEUS_waterstand2	=[	$rockrun2  ,	ZEUS_waterstand3	]
{
  ZEUS_FrameStart ("waterstand 2");
  ZEUS_ai_stand();
};
void()	ZEUS_waterstand3	=[	$rockrun3  ,	ZEUS_waterstand4	]
{
  ZEUS_FrameStart ("waterstand 3");
  ZEUS_ai_stand();
};
void()	ZEUS_waterstand4	=[	$rockrun4  ,	ZEUS_waterstand5	]
{
  ZEUS_FrameStart ("waterstand 4");
  ZEUS_ai_stand();
};
void()	ZEUS_waterstand5	=[	$rockrun5  ,	ZEUS_waterstand6	]
{
  ZEUS_FrameStart ("waterstand 5");
  ZEUS_ai_stand();
};
void()	ZEUS_waterstand6	=[	$rockrun6  ,	ZEUS_waterstand1	]
{
  ZEUS_FrameStart ("waterstand 6");
  ZEUS_ai_stand();
};


/*
======================
ZEUS_stand

frame functions for standing idle with a weapon
======================
*/

void()	ZEUS_stand1	=[	$stand1,	ZEUS_stand2	]
{
  self.cnt = FRAME_STAND;
  ZEUS_FrameStart ("stand 1");
  ZEUS_ai_stand();
  self.pain_finished = time - 1;
};
void()	ZEUS_stand2	=[	$stand2,	ZEUS_stand3	]
{
  ZEUS_FrameStart ("stand 2");
  ZEUS_ai_stand();
};
void()	ZEUS_stand3	=[	$stand3,	ZEUS_stand4	]
{
  ZEUS_FrameStart ("stand 3");
  ZEUS_ai_stand();
};
void()	ZEUS_stand4	=[	$stand4,	ZEUS_stand5	]
{
  ZEUS_FrameStart ("stand 4");
  ZEUS_ai_stand();
};
void()	ZEUS_stand5	=[	$stand5,	ZEUS_stand1	]
{
  ZEUS_FrameStart ("stand 5");
  ZEUS_ai_stand();
};

/*
======================
ZEUS_WaterLevel

determines the current water level of the passed entity

input:   entity ent - entity to check the water level of
output:  float - current water level of entity
                 0 = no water
                 1 = feet in water
                 2 = waist/torso in water
                 3 = submerged in water
changes: self.ZEUS_waterlevel
======================
*/
float (entity ent) ZEUS_WaterLevel =
{
  local   float   pc, last_water;

  if (ent == world) return 0;

  ZEUS_last_waterlevel = ent.ZEUS_waterlevel;

  makevectors (ent.angles);
  // set watertype
  v_forward_z = 0;
  pc = pointcontents (ent.origin + v_forward * 16 - v_up * 23);
  if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
  {
    ent.ZEUS_watertype = pc;
    if (ZEUS_last_waterlevel == 0)
      ent.watertype = pc;
  }
  else ent.ZEUS_watertype = 0;

  if (ZEUS_last_waterlevel < 3)
    self.air_finished = time + 12;

  pc = pointcontents (ent.origin + v_forward * 16 + v_up * 28);
  // all the way under
  if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
  {
    ent.ZEUS_waterlevel = 3;
    if (ent.classname == "zeus_bot")
    {
      // did entity just enter water?
      if (ZEUS_last_waterlevel < 2)
        ent.velocity = ent.velocity * 0.5;

      if (self.deadflag == DEAD_NO)
        ent.movetype = MOVETYPE_FLY;
      if (ent.weapon == IT_AXE)
        ent.th_stand = ZEUS_axewater1;
      else
        ent.th_stand = ZEUS_waterstand1;
    }
    return 3;
  }

  // was v_up * 8
  pc = pointcontents (ent.origin + v_forward * 16 + v_up);
  // head out
  if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
  {
    ent.ZEUS_waterlevel = 2;
    if (ent.classname == "zeus_bot")
    {
      // did entity just enter water?
      if (ZEUS_last_waterlevel < 2)
        ent.velocity = ent.velocity * 0.5;

      if (self.deadflag == DEAD_NO)
        ent.movetype = MOVETYPE_FLY;
      if (ent.weapon == IT_AXE)
        ent.th_stand = ZEUS_axewater1;
      else
        ent.th_stand = ZEUS_waterstand1;
    }
    return 2;
  }

  // lower body and/or feet
  if ((ent.ZEUS_watertype == CONTENT_WATER) || (ent.ZEUS_watertype == CONTENT_SLIME) ||
      (ent.ZEUS_watertype == CONTENT_LAVA))
  {
    ent.ZEUS_waterlevel = 1;
    if (ent.classname == "zeus_bot")
    {
      if (ZEUS_last_waterlevel > 1)
        ent.movetype = MOVETYPE_STEP;
      if (ent.weapon == IT_AXE)
        ent.th_stand = ZEUS_axestand1;
      else
        ent.th_stand = ZEUS_stand1;
    }
    return 1;
  }

  if (ent.classname == "zeus_bot")
  {
    if (ZEUS_last_waterlevel > 1)
      ent.movetype = MOVETYPE_STEP;
    if (ent.weapon == IT_AXE)
      ent.th_stand = ZEUS_axestand1;
    else
      ent.th_stand = ZEUS_stand1;
  }
  ent.ZEUS_waterlevel = 0;
  ent.ZEUS_watertype = 0;
  return 0;
};

/*
======================
ZEUS_axerun

frame functions for running with the axe
======================
*/

void()	ZEUS_axerun1	=[	$axrun1  ,	ZEUS_axerun2	]
{
  self.cnt = FRAME_AXERUN;
  ZEUS_FrameStart ("axerun 1");
  ZEUS_ai_run(36);
};
void()	ZEUS_axerun2	=[	$axrun2  ,	ZEUS_axerun3	]
{
  ZEUS_FrameStart ("axerun 2");
  ZEUS_ai_run(28);
};
void()	ZEUS_axerun3	=[	$axrun3  ,	ZEUS_axerun4	]
{
  ZEUS_FrameStart ("axerun 3");
  ZEUS_ai_run(14);
};
void()	ZEUS_axerun4	=[	$axrun4  ,	ZEUS_axerun5	]
{
  ZEUS_FrameStart ("axerun 4");
  ZEUS_ai_run(24);
};
void()	ZEUS_axerun5	=[	$axrun5  ,	ZEUS_axerun6	]
{
  ZEUS_FrameStart ("axerun 5");
  ZEUS_ai_run(28);
};
void()	ZEUS_axerun6	=[	$axrun6  ,	ZEUS_axerun1	]
{
  ZEUS_FrameStart ("axerun 6");
  ZEUS_ai_run(28);
};

/*
======================
ZEUS_run

frame functions for running with a gun
======================
*/

void()	ZEUS_run1	=[	$rockrun1  ,	ZEUS_run2	]
{
  self.cnt = FRAME_RUN;
  ZEUS_FrameStart ("run 1");
  ZEUS_ai_run(36);
};
void()	ZEUS_run2	=[	$rockrun2  ,	ZEUS_run3	]
{
  ZEUS_FrameStart ("run 2");
  ZEUS_ai_run(28);
};
void()	ZEUS_run3	=[	$rockrun3  ,	ZEUS_run4	]
{
  ZEUS_FrameStart ("run 3");
  ZEUS_ai_run(14);
};
void()	ZEUS_run4	=[	$rockrun4  ,	ZEUS_run5	]
{
  ZEUS_FrameStart ("run 4");
  ZEUS_ai_run(24);
};
void()	ZEUS_run5	=[	$rockrun5  ,	ZEUS_run6	]
{
  ZEUS_FrameStart ("run 5");
  ZEUS_ai_run(28);
};
void()	ZEUS_run6	=[	$rockrun6  ,	ZEUS_run1	]
{
  ZEUS_FrameStart ("run 6");
  ZEUS_ai_run(28);
};

/*
======================
ZEUS_axefollow

frame functions for following with the axe
======================
*/

void()	ZEUS_axefollow1	=[	$axrun1  ,	ZEUS_axefollow2	]
{
  self.cnt = FRAME_AXEFOLLOW;
  ZEUS_FrameStart ("axefollow 1");
  ZEUS_ai_follow (0);
};
void()	ZEUS_axefollow2	=[	$axrun2  ,	ZEUS_axefollow3	]
{
  ZEUS_FrameStart ("axefollow 2");
  ZEUS_ai_follow (0);
};
void()	ZEUS_axefollow3	=[	$axrun3  ,	ZEUS_axefollow4	]
{
  ZEUS_FrameStart ("axefollow 3");
  ZEUS_ai_follow (0);
};
void()	ZEUS_axefollow4	=[	$axrun4  ,	ZEUS_axefollow5	]
{
  ZEUS_FrameStart ("axefollow 4");
  ZEUS_ai_follow (0);
};
void()	ZEUS_axefollow5	=[	$axrun5  ,	ZEUS_axefollow6	]
{
  ZEUS_FrameStart ("axefollow 5");
  ZEUS_ai_follow (0);
};
void()	ZEUS_axefollow6	=[	$axrun6  ,	ZEUS_axefollow1	]
{
  ZEUS_FrameStart ("axefollow 6");
  ZEUS_ai_follow (0);
};

/*
======================
ZEUS_follow

frame functions for following with a gun
======================
*/

void()	ZEUS_follow1	=[	$rockrun1  ,	ZEUS_follow2	]
{
  self.cnt = FRAME_FOLLOW;
  ZEUS_FrameStart ("follow 1 ");
  ZEUS_ai_follow(36);
};

void()	ZEUS_follow2	=[	$rockrun2  ,	ZEUS_follow3	]
{
  ZEUS_ai_follow(28);
  ZEUS_FrameStart ("follow 2 ");
};
void()	ZEUS_follow3	=[	$rockrun3  ,	ZEUS_follow4	]
{
  ZEUS_ai_follow(14);
  ZEUS_FrameStart ("follow 3 ");
};
void()	ZEUS_follow4	=[	$rockrun4  ,	ZEUS_follow5	]
{
  ZEUS_ai_follow(24);
  ZEUS_FrameStart ("follow 4 ");
};
void()	ZEUS_follow5	=[	$rockrun5  ,	ZEUS_follow6	]
{
  ZEUS_ai_follow(28);
  ZEUS_FrameStart ("follow 5 ");
};
void()	ZEUS_follow6	=[	$rockrun6  ,	ZEUS_follow1	]
{
  ZEUS_ai_follow(28);
  ZEUS_FrameStart ("follow 6 ");
};

/*
===============
ZEUS_axe

frame control functions for axe attacks
===============
*/

void()	ZEUS_axe1 =	[$axatt1, ZEUS_axe2	]
{
  self.cnt = FRAME_AXEATTACKA;
  ZEUS_ai_run_and_shoot (28);
};
void()	ZEUS_axe2 =	[$axatt2, ZEUS_axe3	] {ZEUS_ai_run_and_shoot (28);};
void()	ZEUS_axe3 =	[$axatt3, ZEUS_axe4	]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_fire ();
};
void()	ZEUS_axe4 =	[$axatt4, ZEUS_run1     ]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_CheckAttack (ZEUS_attack);
};

void()	ZEUS_axeb1 =	[$axattb1, ZEUS_axeb2	]
{
  self.cnt = FRAME_AXEATTACKB;
  ZEUS_ai_run_and_shoot (28);
};
void()	ZEUS_axeb2 =	[$axattb2, ZEUS_axeb3	] {ZEUS_ai_run_and_shoot (28);};
void()	ZEUS_axeb3 =	[$axattb3, ZEUS_axeb4	]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_fire ();
};
void()	ZEUS_axeb4 =	[$axattb4, ZEUS_run1	]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_CheckAttack (ZEUS_attack);
};

void()	ZEUS_axec1 =	[$axattc1, ZEUS_axec2	]
{
  self.cnt = FRAME_AXEATTACKC;
  ZEUS_ai_run_and_shoot (28);
};
void()	ZEUS_axec2 =	[$axattc2, ZEUS_axec3	] {ZEUS_ai_run_and_shoot (28);};
void()	ZEUS_axec3 =	[$axattc3, ZEUS_axec4	]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_fire ();
};
void()	ZEUS_axec4 =	[$axattc4, ZEUS_run1	]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_CheckAttack (ZEUS_attack);
};

void()	ZEUS_axed1 =	[$axattd1, ZEUS_axed2	]
{
  self.cnt = FRAME_AXEATTACKD;
  ZEUS_ai_run_and_shoot (28);
};
void()	ZEUS_axed2 =	[$axattd2, ZEUS_axed3	] {ZEUS_ai_run_and_shoot (28);};
void()	ZEUS_axed3 =	[$axattd3, ZEUS_axed4	]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_fire ();
};
void()	ZEUS_axed4 =	[$axattd4, ZEUS_run1	]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_CheckAttack (ZEUS_attack);
};

/*
===============
ZEUS_nail_atk

frame control functions for nailgun\plasma gun attacks
===============
*/

void () ZEUS_nail_atk1  =[  $nailatt1  ,        ZEUS_nail_atk2  ]
{
  self.cnt = FRAME_NAILATTACK;
  ZEUS_ai_run_and_shoot (28);
  ZEUS_fire ();
};
void () ZEUS_nail_atk2  =[  $nailatt2  ,        ZEUS_run1  ]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_CheckAttack (ZEUS_attack);
};

/*
===============
ZEUS_rock_atk

frame control functions for rocket\grenade attacks
===============
*/

void () ZEUS_rock_atk1  =[  $rockatt1  ,        ZEUS_rock_atk2  ]
{
  self.cnt = FRAME_ROCKETATTACK;
  ZEUS_ai_run_and_shoot (28);
  ZEUS_fire ();
};
void () ZEUS_rock_atk2  =[  $rockatt2  ,        ZEUS_rock_atk3  ] {ZEUS_ai_run_and_shoot (28);};
void () ZEUS_rock_atk3  =[  $rockatt3  ,        ZEUS_rock_atk4  ] {ZEUS_ai_run_and_shoot (28);};
void () ZEUS_rock_atk4  =[  $rockatt4  ,        ZEUS_rock_atk5  ] {ZEUS_ai_run_and_shoot (28);};
void () ZEUS_rock_atk5  =[  $rockatt5  ,        ZEUS_rock_atk6  ] {ZEUS_ai_run_and_shoot (28);};
void () ZEUS_rock_atk6  =[  $rockatt6  ,        ZEUS_run1       ]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_CheckAttack (ZEUS_attack);
};

/*
===============
ZEUS_lite_atk

frame control functions for lightning gun attacks
===============
*/

void () ZEUS_lite_atk1  =[    $light1  ,        ZEUS_lite_atk2  ]
{
  self.cnt = FRAME_THUNDERATTACK;
  ZEUS_ai_run_and_shoot (28);
  ZEUS_fire ();
};
void () ZEUS_lite_atk2  =[    $light2  ,        ZEUS_run1       ]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_CheckAttack (ZEUS_attack);
};

/*
===============
ZEUS_shot_atk

frame control functions for shotgun attacks
===============
*/

void () ZEUS_shot_atk1  =[  $shotatt1  ,        ZEUS_shot_atk2  ]
{
  self.cnt = FRAME_SHOTGUNATTACK;
  ZEUS_ai_run_and_shoot (28);
};
void () ZEUS_shot_atk2  =[  $shotatt2  ,        ZEUS_shot_atk3  ]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_fire ();
};
void () ZEUS_shot_atk3  =[  $shotatt3  ,        ZEUS_shot_atk4  ] {ZEUS_ai_run_and_shoot (28);};
void () ZEUS_shot_atk4  =[  $shotatt4  ,        ZEUS_shot_atk5  ] {ZEUS_ai_run_and_shoot (28);};
void () ZEUS_shot_atk5  =[  $shotatt5  ,        ZEUS_shot_atk6  ] {ZEUS_ai_run_and_shoot (28);};
void () ZEUS_shot_atk6  =[  $shotatt6  ,        ZEUS_run1       ]
{
  ZEUS_ai_run_and_shoot (28);
  ZEUS_CheckAttack (ZEUS_attack);
};

/*
===============
ZEUS_attack

calls the appropriate attack function based on the bots current weapon

Input:   none
Output:  none
Changes: none
===============
*/

void () ZEUS_attack =
{
  local   float   r;

  ZEUS_ChooseWeapon ();

  if (self.weapon == IT_LIGHTNING)
    ZEUS_lite_atk1 ();
  else if (self.weapon == IT_ROCKET_LAUNCHER)
    ZEUS_rock_atk1 ();
  else if (self.weapon == IT_GRENADE_LAUNCHER)
    ZEUS_rock_atk1 ();
  else if (self.weapon == IT_SUPER_NAILGUN)
    ZEUS_nail_atk1 ();
  else if (self.weapon == IT_NAILGUN)
    ZEUS_nail_atk1 ();
  else if (self.weapon == IT_AXE)
  {
    r = random ();
    if (r < 0.25)
      ZEUS_Cl_Msg ("hack... ");
    else if (r < 0.5)
      ZEUS_Cl_Msg ("whack... ");
    else if (r < 0.75)
      ZEUS_Cl_Msg ("chop... ");
    else
      ZEUS_Cl_Msg ("lop... ");

    if (r < 0.25)
      ZEUS_axe1 ();
    else if (r < 0.5)
      ZEUS_axeb1 ();
    else if (r < 0.75)
      ZEUS_axec1 ();
    else
      ZEUS_axed1 ();
  }
  else if (self.weapon == IT_SHOTGUN)
    ZEUS_shot_atk1 ();
  else if (self.weapon == IT_SUPER_SHOTGUN)
    ZEUS_shot_atk1 ();
};

/*
===============
ZEUS_pain

frame control functions for pain
===============
*/

void()	ZEUS_pain1 =	[	$pain1,	ZEUS_pain2	]
{
  self.cnt = FRAME_PAIN;
  ZEUS_FrameStart ("ZEUS_pain1");
};
void()	ZEUS_pain2 =	[	$pain2,	ZEUS_pain3	] {ZEUS_FrameStart ("ZEUS_pain2");};
void()	ZEUS_pain3 =	[	$pain3,	ZEUS_pain4	] {ZEUS_FrameStart ("ZEUS_pain3");};
void()	ZEUS_pain4 =	[	$pain4,	ZEUS_pain5	] {ZEUS_FrameStart ("ZEUS_pain4");};
void()	ZEUS_pain5 =	[	$pain5,	ZEUS_pain6	] {ZEUS_FrameStart ("ZEUS_pain5");};
void()	ZEUS_pain6 =	[	$pain6,	ZEUS_stand1     ] {ZEUS_FrameStart ("ZEUS_pain6");};

void () ZEUS_axpain1 =	[	$axpain1,	ZEUS_axpain2	]
{
  self.cnt = FRAME_AXEPAIN;
  ZEUS_FrameStart ("ZEUS_axpain1");
};
void () ZEUS_axpain2 =	[	$axpain2,	ZEUS_axpain3	] {ZEUS_FrameStart ("ZEUS_axpain2");};
void () ZEUS_axpain3 =	[	$axpain3,	ZEUS_axpain4	] {ZEUS_FrameStart ("ZEUS_axpain3");};
void () ZEUS_axpain4 =	[	$axpain4,	ZEUS_axpain5	] {ZEUS_FrameStart ("ZEUS_axpain4");};
void () ZEUS_axpain5 =	[	$axpain5,	ZEUS_axpain6	] {ZEUS_FrameStart ("ZEUS_axpain5");};
void () ZEUS_axpain6 =	[	$axpain6,	ZEUS_axestand1  ] {ZEUS_FrameStart ("ZEUS_axpain6");};

/*
===============
ZEUS_PainSound

Plays the appropriate sound based on the type of attacker

Input:   none
Output:  none
Changes: none
===============
*/

void() ZEUS_PainSound =
{
  local   float   rs;

  if (self.health < 0)
    return;

  if (damage_attacker.classname == "teledeath")
  {
    sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
    return;
  }

  // water pain sounds
  if ((self.ZEUS_watertype == CONTENT_WATER) &&
      (self.ZEUS_waterlevel == 3))
  {
    DeathBubbles(1);
    if (random() > 0.5)
      sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
    else
      sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
    return;
  }

  // slime pain sounds
  if (self.ZEUS_watertype == CONTENT_SLIME)
  {
    if (random() > 0.5)
      sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
    else
      sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
    return;
  }

  if (self.ZEUS_watertype == CONTENT_LAVA)
  {
    if (random() > 0.5)
      sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
    else
      sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
    return;
  }

  if (self.pain_finished > time)
  {
    self.axhitme = 0;
    return;
  }

  self.pain_finished = time + 0.5;
  // don't make multiple pain sounds right after each other
  // ax pain sound
  if (self.axhitme == 1)
  {
    self.axhitme = 0;
    sound (self, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM);
    return;
  }

  rs = rint((random() * 5) + 1);

  self.noise = "";
  if (rs == 1)
    self.noise = "player/pain1.wav";
  else if (rs == 2)
    self.noise = "player/pain2.wav";
  else if (rs == 3)
    self.noise = "player/pain3.wav";
  else if (rs == 4)
    self.noise = "player/pain4.wav";
  else if (rs == 5)
    self.noise = "player/pain5.wav";
  else
    self.noise = "player/pain6.wav";

  sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
  return;
};


/*
===============
ZEUS_pain

Plays sound for pain and starts appropriate pain sequence based
on gun or axe

Input:   none
Output:  none
Changes: none
===============
*/

void (entity attacker, float damage) ZEUS_pain =
{
local float r;

//  if (self.weaponframe)
//   return;

  ZEUS_PainSound ();

  if ((self.pain_finished > time) || (self.deadflag != DEAD_NO))
    return;

  if ((self.air_finished < time) && (self.ZEUS_waterlevel > 2))
    self.pain_finished = time + 1;
  else
    self.pain_finished = time + 10;

  if (self.weapon == IT_AXE)
    ZEUS_axpain1 ();
  else
    ZEUS_pain1 ();
};

/*
===============
ZEUS_DropBackpack

Used when owner commands bot to drop backpack.  Always drops the most
powerful weapon, rather than the current one.  Only drops 25 of each
ammo, or max amount bot has decrements bot's ammo appropriately.

Input:   none
Output:  none
Changes: self.items, self.ammo_xxxx
===============
*/
void () ZEUS_DropBackpack =
{
  local   entity  item;
  local   float   dist;
  local   vector  ang;

  if ((!(self.items & IT_LIGHTNING)) && (!(self.items & IT_ROCKET_LAUNCHER))  &&
      (!(self.items & IT_SUPER_NAILGUN)) && (!(self.items & IT_GRENADE_LAUNCHER)) &&
      (!(self.items & IT_SUPER_SHOTGUN)) && (!(self.items & IT_NAILGUN)))
  {
    if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
    {
      if (random () < 0.9)
        ZEUS_sprint (self.bot_owner, "Zeusbot: There's nothing left in my pack.\n");
      else
        ZEUS_sprint (self.bot_owner, "Zeusbot: You CANNOT have my axe!\n");
      return;	// nothing in it
    }
  }

  item = spawn();

  if (self.items & IT_LIGHTNING)
  {
    item.items = IT_LIGHTNING;
    self.items = self.items - IT_LIGHTNING;
  }
  else if (self.items & IT_ROCKET_LAUNCHER)
  {
    item.items = IT_ROCKET_LAUNCHER;
    self.items = self.items - IT_ROCKET_LAUNCHER;
  }
  else if (self.items & IT_SUPER_NAILGUN)
  {
    item.items = IT_SUPER_NAILGUN;
    self.items = self.items - IT_SUPER_NAILGUN;
  }
  else if (self.items & IT_GRENADE_LAUNCHER)
  {
    item.items = IT_GRENADE_LAUNCHER;
    self.items = self.items - IT_GRENADE_LAUNCHER;
  }
  else if (self.items & IT_SUPER_SHOTGUN)
  {
    item.items = IT_SUPER_SHOTGUN;
    self.items = self.items - IT_SUPER_SHOTGUN;
  }
  else if (self.items & IT_NAILGUN)
  {
    item.items = IT_NAILGUN;
    self.items = self.items - IT_NAILGUN;
  }

  if (item.items == IT_SUPER_SHOTGUN)
    item.netname = "Double-barrelled Shotgun";
  else if (item.items == IT_NAILGUN)
    item.netname = "Nailgun";
  else if (item.items == IT_SUPER_NAILGUN)
    item.netname = "Super Nailgun";
  else if (item.items == IT_GRENADE_LAUNCHER)
    item.netname = "Grenade Launcher";
  else if (item.items == IT_ROCKET_LAUNCHER)
    item.netname = "Rocket Launcher";
  else if (item.items == IT_LIGHTNING)
    item.netname = "Thunderbolt";
  else
    item.netname = "backpack";

  if (self.ammo_shells > 25)
  {
    item.ammo_shells = 25;
    self.ammo_shells = self.ammo_shells - 25;
  }
  else
  {
    item.ammo_shells = self.ammo_shells;
    self.ammo_shells = 0;
  }
  if (self.ammo_nails > 25)
  {
    item.ammo_nails = 25;
    self.ammo_nails = self.ammo_nails - 25;
  }
  else
  {
    item.ammo_nails = self.ammo_nails;
    self.ammo_nails = 0;
  }
  if (self.ammo_rockets > 25)
  {
    item.ammo_rockets = 25;
    self.ammo_rockets = self.ammo_rockets - 25;
  }
  else
  {
    item.ammo_rockets = self.ammo_rockets;
    self.ammo_rockets = 0;
  }
  if (self.ammo_cells > 25)
  {
    item.ammo_cells = 25;
    self.ammo_cells = self.ammo_cells - 25;
  }
  else
  {
    item.ammo_cells = self.ammo_cells;
    self.ammo_cells = 0;
  }

//  item.velocity_z = 300;
//  item.velocity_x = -100 + (random() * 200);
//  item.velocity_y = -100 + (random() * 200);

  dist = vlen (self.origin - self.bot.origin);
  item.velocity = normalize (self.bot_owner.origin - self.origin);
  item.classname = "backpack";

  ang = vectoangles (item.velocity);
  makevectors (ang);
  item.origin = self.origin + v_forward * 24;

  if (dist > 400)
    item.velocity = item.velocity * 200;
  else
    item.velocity = item.velocity * dist * 0.5;

  item.velocity_z = 200;

  item.flags = FL_ITEM;
  item.solid = SOLID_TRIGGER;
  item.movetype = MOVETYPE_TOSS;
  setmodel (item, "progs/backpack.mdl");
  setsize (item, '-16 -16 0', '16 16 56');
  item.touch = BackpackTouch;

  item.nextthink = time + 120;	// remove after 2 minutes
  item.think = SUB_Remove;

  // if it's a bot, make the item unreachable so owner can get
  // it -- bots only drop backpacks when dying (so it won't matter
  // if they flag it unreachable) or when owner commands
  ZEUS_MakeUnreachable (item, "ZEUS_DropBackpack");
};

/*
===============
ZEUS_deathend

This "flattens out" a bot that was spinning when it was killed, so that
it doesn't end up with it's head in the floor.  It continues being called
at frame start until until all the bots angles are equal to 0
===============
*/
void () ZEUS_deathend =
{
  local   float   temp, temp;

  self.angles_x =0;
  self.movetype = MOVETYPE_TOSS;
  ZEUS_SelfDeactivate ();
};

/*
===============
ZEUS_die

death frame functions
===============
*/

void()	ZEUS_diea1 =    [       $deatha1,	ZEUS_diea2	]
{
  self.cnt = FRAME_DEATHA;
  ZEUS_FrameStart ("ZEUS_diea1");
};
void()	ZEUS_diea2 =	[	$deatha2,	ZEUS_diea3	] {ZEUS_FrameStart ("ZEUS_diea2");};
void()	ZEUS_diea3 =	[	$deatha3,	ZEUS_diea4	] {ZEUS_FrameStart ("ZEUS_diea3");};
void()	ZEUS_diea4 =	[	$deatha4,	ZEUS_diea5	] {ZEUS_FrameStart ("ZEUS_diea4");};
void()	ZEUS_diea5 =	[	$deatha5,	ZEUS_diea6	] {ZEUS_FrameStart ("ZEUS_diea5");};
void()	ZEUS_diea6 =	[	$deatha6,	ZEUS_diea7	] {ZEUS_FrameStart ("ZEUS_diea6");};
void()	ZEUS_diea7 =	[	$deatha7,	ZEUS_diea8	] {ZEUS_FrameStart ("ZEUS_diea7");};
void()	ZEUS_diea8 =	[	$deatha8,	ZEUS_diea9	] {ZEUS_FrameStart ("ZEUS_diea8");};
void()	ZEUS_diea9 =	[	$deatha9,	ZEUS_diea10	] {ZEUS_FrameStart ("ZEUS_diea9");};
void()	ZEUS_diea10=	[	$deatha10,	ZEUS_diea11	] {ZEUS_FrameStart ("ZEUS_diea10");};
void()	ZEUS_diea11=	[	$deatha11,	ZEUS_deathend   ]
{
  ZEUS_FrameStart ("ZEUS_diea11");
//  ZEUS_SelfDeactivate ();
};

void()	ZEUS_dieb1 =	[	$deathb1,	ZEUS_dieb2	]
{
  self.cnt = FRAME_DEATHB;
  ZEUS_FrameStart ("ZEUS_dieb1");
};
void()	ZEUS_dieb2 =	[	$deathb2,	ZEUS_dieb3	] {ZEUS_FrameStart ("ZEUS_dieb2");};
void()	ZEUS_dieb3 =	[	$deathb3,	ZEUS_dieb4	] {ZEUS_FrameStart ("ZEUS_dieb3");};
void()	ZEUS_dieb4 =	[	$deathb4,	ZEUS_dieb5	] {ZEUS_FrameStart ("ZEUS_dieb4");};
void()	ZEUS_dieb5 =	[	$deathb5,	ZEUS_dieb6	] {ZEUS_FrameStart ("ZEUS_dieb5");};
void()	ZEUS_dieb6 =	[	$deathb6,	ZEUS_dieb7	] {ZEUS_FrameStart ("ZEUS_dieb6");};
void()	ZEUS_dieb7 =	[	$deathb7,	ZEUS_dieb8	] {ZEUS_FrameStart ("ZEUS_dieb7");};
void()	ZEUS_dieb8 =	[	$deathb8,	ZEUS_dieb9	] {ZEUS_FrameStart ("ZEUS_dieb8");};
void()	ZEUS_dieb9 =	[	$deathb9,	ZEUS_deathend   ]
{
  ZEUS_FrameStart ("ZEUS_dieb9");
//  ZEUS_SelfDeactivate ();
};

void()	ZEUS_diec1 =	[	$deathc1,	ZEUS_diec2	]
{
  self.cnt = FRAME_DEATHC;
  ZEUS_FrameStart ("ZEUS_diec1");
};
void()	ZEUS_diec2 =	[	$deathc2,	ZEUS_diec3	] {ZEUS_FrameStart ("ZEUS_diec2");};
void()	ZEUS_diec3 =	[	$deathc3,	ZEUS_diec4	] {ZEUS_FrameStart ("ZEUS_diec3");};
void()	ZEUS_diec4 =	[	$deathc4,	ZEUS_diec5	] {ZEUS_FrameStart ("ZEUS_diec4");};
void()	ZEUS_diec5 =	[	$deathc5,	ZEUS_diec6	] {ZEUS_FrameStart ("ZEUS_diec5");};
void()	ZEUS_diec6 =	[	$deathc6,	ZEUS_diec7	] {ZEUS_FrameStart ("ZEUS_diec6");};
void()	ZEUS_diec7 =	[	$deathc7,	ZEUS_diec8	] {ZEUS_FrameStart ("ZEUS_diec7");};
void()	ZEUS_diec8 =	[	$deathc8,	ZEUS_diec9	] {ZEUS_FrameStart ("ZEUS_diec8");};
void()	ZEUS_diec9 =	[	$deathc9,	ZEUS_diec10	] {ZEUS_FrameStart ("ZEUS_diec9");};
void()	ZEUS_diec10=	[	$deathc10,	ZEUS_diec11	] {ZEUS_FrameStart ("ZEUS_diec10");};
void()	ZEUS_diec11=	[	$deathc11,	ZEUS_diec12	] {ZEUS_FrameStart ("ZEUS_diec11");};
void()	ZEUS_diec12=	[	$deathc12,	ZEUS_diec13	] {ZEUS_FrameStart ("ZEUS_diec12");};
void()	ZEUS_diec13=	[	$deathc13,	ZEUS_diec14	] {ZEUS_FrameStart ("ZEUS_diec13");};
void()	ZEUS_diec14=	[	$deathc14,	ZEUS_diec15	] {ZEUS_FrameStart ("ZEUS_diec14");};
void()	ZEUS_diec15=	[	$deathc15,	ZEUS_deathend   ]
{
  ZEUS_FrameStart ("ZEUS_diec15");
//  ZEUS_SelfDeactivate ();
};

void()	ZEUS_died1 =	[	$deathd1,	ZEUS_died2	]
{
  self.cnt = FRAME_DEATHD;
  ZEUS_FrameStart ("ZEUS_died1");
};
void()	ZEUS_died2 =	[	$deathd2,	ZEUS_died3	] {ZEUS_FrameStart ("ZEUS_died2");};
void()	ZEUS_died3 =	[	$deathd3,	ZEUS_died4	] {ZEUS_FrameStart ("ZEUS_died3");};
void()	ZEUS_died4 =	[	$deathd4,	ZEUS_died5	] {ZEUS_FrameStart ("ZEUS_died4");};
void()	ZEUS_died5 =	[	$deathd5,	ZEUS_died6	] {ZEUS_FrameStart ("ZEUS_died5");};
void()	ZEUS_died6 =	[	$deathd6,	ZEUS_died7	] {ZEUS_FrameStart ("ZEUS_died6");};
void()	ZEUS_died7 =	[	$deathd7,	ZEUS_died8	] {ZEUS_FrameStart ("ZEUS_died7");};
void()	ZEUS_died8 =	[	$deathd8,	ZEUS_died9	] {ZEUS_FrameStart ("ZEUS_died8");};
void()	ZEUS_died9 =	[	$deathd9,	ZEUS_deathend   ]
{
  ZEUS_FrameStart ("ZEUS_died9");
//  ZEUS_SelfDeactivate ();
};

void()	ZEUS_diee1 =	[	$deathe1,	ZEUS_diee2	]
{
  self.cnt = FRAME_DEATHE;
  ZEUS_FrameStart ("ZEUS_diee1");
};
void()	ZEUS_diee2 =	[	$deathe2,	ZEUS_diee3	] {ZEUS_FrameStart ("ZEUS_diee2");};
void()	ZEUS_diee3 =	[	$deathe3,	ZEUS_diee4	] {ZEUS_FrameStart ("ZEUS_diee3");};
void()	ZEUS_diee4 =	[	$deathe4,	ZEUS_diee5	] {ZEUS_FrameStart ("ZEUS_diee4");};
void()	ZEUS_diee5 =	[	$deathe5,	ZEUS_diee6	] {ZEUS_FrameStart ("ZEUS_diee5");};
void()	ZEUS_diee6 =	[	$deathe6,	ZEUS_diee7	] {ZEUS_FrameStart ("ZEUS_diee6");};
void()	ZEUS_diee7 =	[	$deathe7,	ZEUS_diee8	] {ZEUS_FrameStart ("ZEUS_diee7");};
void()	ZEUS_diee8 =	[	$deathe8,	ZEUS_diee9	] {ZEUS_FrameStart ("ZEUS_diee8");};
void()	ZEUS_diee9 =	[	$deathe9,	ZEUS_deathend   ]
{
  ZEUS_FrameStart ("ZEUS_diee9");
//  ZEUS_SelfDeactivate ();
};

void()	ZEUS_die_ax1	= [	$axdeth1,	ZEUS_die_ax2	]
{
  self.cnt = FRAME_AXEDEATH;
  ZEUS_FrameStart ("ZEUS_die_ax1");
};
void()	ZEUS_die_ax2	= [	$axdeth2,	ZEUS_die_ax3	] {ZEUS_FrameStart ("ZEUS_die_ax2");};
void()	ZEUS_die_ax3	= [	$axdeth3,	ZEUS_die_ax4	] {ZEUS_FrameStart ("ZEUS_die_ax3");};
void()	ZEUS_die_ax4	= [	$axdeth4,	ZEUS_die_ax5	] {ZEUS_FrameStart ("ZEUS_die_ax4");};
void()	ZEUS_die_ax5	= [	$axdeth5,	ZEUS_die_ax6	] {ZEUS_FrameStart ("ZEUS_die_ax5");};
void()	ZEUS_die_ax6	= [	$axdeth6,	ZEUS_die_ax7	] {ZEUS_FrameStart ("ZEUS_die_ax6");};
void()	ZEUS_die_ax7	= [	$axdeth7,	ZEUS_die_ax8	] {ZEUS_FrameStart ("ZEUS_die_ax7");};
void()	ZEUS_die_ax8	= [	$axdeth8,	ZEUS_die_ax9	] {ZEUS_FrameStart ("ZEUS_die_ax8");};
void()	ZEUS_die_ax9	= [	$axdeth9,	ZEUS_deathend	]
{
  ZEUS_FrameStart ("ZEUS_die_ax9");
//  ZEUS_SelfDeactivate ();
};

/*
===============
ZEUS_die

Called when the bot is killed.  Handles death cam if if bot view for this
bot.  Drops backpack.  Imparts velocity to body.  Plays appropriate death
sound.  Determines whether to just die or gib and calls appropriate death
frame.

Input:   none
Output:  none
Changes: self.items, self.velocity, self.deadflag, self.takedamage,
         self.solid, self.flags, self.avelocity, self.movetype,
         self.angles, self.view_ofs
===============
*/

void() ZEUS_die =
{
  local   float   i;
  local   vector  dir;

  ZEUS_FrameStart ("ZEUS_die");

  if ((self.bot_owner.classname == "bot_viewer") && (self.bot_owner.bot == self))
  {
    centerprint (self.bot_owner, "ZEUSbot Death-cam\n");
    self.solid = SOLID_NOT;
    deathcam_time = time + 2;
    setsize (self.bot_owner, '16 16 16', '16 16 16');
    self.bot_owner.movetype = MOVETYPE_FLY;
    self.bot_owner.solid = SOLID_NOT;
  }

  self.items = self.items - (self.items & IT_INVISIBILITY);
  self.invisible_finished = 0;	// don't die as eyes
  self.invincible_finished = 0;
  self.super_damage_finished = 0;
  self.radsuit_finished = 0;
  self.modelindex = modelindex_player;	// don't use eyes

  DropBackpack ();

  self.view_ofs = '0 0 -8';
  self.deadflag = DEAD_DYING;
  self.takedamage = DAMAGE_NO;
  self.solid = SOLID_NOT;
/*
  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;
  self.movetype = MOVETYPE_BOUNCE;
  self.avelocity_y = 100 + random () * 600;
*/
  if (self.health < -40)
  {
    sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
    ThrowHead ("progs/h_player.mdl", self.health);
    ThrowGib ("progs/gib1.mdl", self.health);
    ThrowGib ("progs/gib2.mdl", self.health);
    ThrowGib ("progs/gib3.mdl", self.health);

    ZEUS_SelfDeactivate ();
    return;
  }

  DeathSound();

  self.angles_x = 0;
  self.angles_z = 0;

  if (self.weapon == IT_AXE)
  {
    ZEUS_die_ax1 ();
    return;
  }

  i = cvar("temp1");
  if (!i)
    i = 1 + floor(random()*6);

  if (i == 1)
    ZEUS_diea1();
  else if (i == 2)
    ZEUS_dieb1();
  else if (i == 3)
    ZEUS_diec1();
  else if (i == 4)
    ZEUS_died1();
  else
    ZEUS_diee1();

};

/*
======================
ZEUS_SetThink

Simply prevents a new frame sequence being started when the bot
is already in a death sequence.  This is the only way the bot's
think function should be changed.

Input:   void () thinkfunc - the function to set the think to
Output:  none
Changes: self.think, self.nextthink
======================
*/
void (void () thinkfunc) ZEUS_SetThink =
{
  if (self.deadflag == DEAD_NO)
  {
    self.nextthink = time + 0.1;
    if ((thinkfunc == ZEUS_follow1) && (self.cnt == FRAME_FOLLOW))
      return;
    else if ((thinkfunc == ZEUS_axefollow1) && (self.cnt == FRAME_AXEFOLLOW))
      return;
    else if ((thinkfunc == ZEUS_run1) && (self.cnt == FRAME_RUN))
      return;
    else if ((thinkfunc == ZEUS_axerun1) && (self.cnt == FRAME_AXERUN))
      return;
    self.think = thinkfunc;
  }
};

/*
======================
ZEUS_jump

frame functions for bot jumping
======================
*/

void() ZEUS_jump1	=[	$rockrun2,      ZEUS_jump2	]
{
  ZEUS_FrameStart ("ZEUS_jump1");

  self.cnt = FRAME_JUMP;

  self.ZEUS_stuck = false;
  ZEUS_ai_face();
  self.touch = ZEUS_JumpTouch;

  makevectors (self.angles);

  setorigin (self, self.origin + '0 0 1');
  self.velocity = v_forward * self.forward_jump_vel + v_up * self.upward_jump_vel;

  sound (self, CHAN_VOICE, "player/plyrjmp8.wav", 1, ATTN_NORM);

  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;
};

void() ZEUS_jump2	=[	$rockrun3,	ZEUS_jump3	] {ZEUS_FrameStart ("ZEUS_jump2");};
void() ZEUS_jump3	=[	$rockrun4,	ZEUS_jump3	]
{
  ZEUS_FrameStart ("ZEUS_jump3");
  if (self.ZEUS_waterlevel > 1)
  {
    self.touch = SUB_Null;
    ZEUS_SetThink (self.th_follow);
  }
};
void() ZEUS_jump4	=[	$rockrun4,	ZEUS_jump5	] {ZEUS_FrameStart ("ZEUS_jump4");};
void() ZEUS_jump5	=[	$rockrun4,	ZEUS_jump6	] {ZEUS_FrameStart ("ZEUS_jump5");};
void() ZEUS_jump6	=[	$rockrun4,	ZEUS_jump7	] {ZEUS_FrameStart ("ZEUS_jump6");};
void() ZEUS_jump7	=[	$rockrun4,	ZEUS_jump8	] {ZEUS_FrameStart ("ZEUS_jump7");};
void() ZEUS_jump8	=[	$rockrun4,	ZEUS_jump9	] {ZEUS_FrameStart ("ZEUS_jump8");};
void() ZEUS_jump9	=[	$rockrun4,	ZEUS_jump9	] {ZEUS_FrameStart ("ZEUS_jump9");};

/*
=============
ZEUS_StaticOrigin

returns the origins of a static (non-moving) entity such as a
map object (wall, floor, button, door, etc) by finding the middle
of the object according to the min and max extents of the object.
This is necessary because static objects do not normally have
self.origin set.

Input:   entity ent - entity to find the origin of
Output:  vector - the computed origin of the entity
Changes: none
=============
*/
vector (entity ent) ZEUS_StaticOrigin =
{
  return ent.absmin + ((ent.absmax - ent.absmin) * 0.5);
};

/*
=============
ZEUS_EntityOrigin

returns the origin of the entity.  First determines if the entity
is a static or normal entity and returns the appropriate origin. Also
sets global variable entity_org to the origin of ent.

Input:   entity ent - entity to find the origin of
Output:  vector - location of the entity
Changes: entity_org
=============
*/

vector (entity ent) ZEUS_EntityOrigin =
{
/*
  if ((ent.classname == "trigger_once") || (ent.classname == "door") ||
      (ent.classname == "func_button") || (ent.classname == "trigger_secret") ||
      (ent.classname == "trigger_once") || (ent.classname == "trigger_teleport") ||
      (ent.classname == "plat") || (ent.classname == "worldspawn"))
*/
 if (ent.netname == "se_ZEUS_se")
 {
   entity_org = ZEUS_StaticOrigin (ent);
   return entity_org;
 }
 else
 {
   entity_org = ent.origin;
   return ent.origin;
 }
};

/*
=============
ZEUS_StaticVisible

returns 1 if the entity is visible to self, even if not infront ()
for static entities.  Not currently being used, since ZEUS_visible
checks for static vs. dynamic entities

Input:   entity targ - entity to determine visiblity from self
Output:  float - true if visible from self, false if not
Changes: none
=============
*/
float (entity targ) ZEUS_StaticVisible =
{
  local vector	spot1, spot2;

  spot1 = self.origin + self.view_ofs;
  spot2 = ZEUS_StaticOrigin (targ); //targ.absmin + ((targ.absmax - targ.absmin) * 0.5);

  traceline (spot1, spot2, true, self);	// see through other monsters

  if (trace_inopen && trace_inwater)
    return false;			// sight line crossed contents

  if ((trace_fraction == 1) || (trace_ent == targ))
  {
//    ZEUS_SpawnMarker (spot2, "progs/grenade.mdl", 0.1);
    return true;
  }
  return false;
};

/*
=============
ZEUS_visible

returns 1 if the entity is visible to self, even if not infront ()
for now it's the same as the normal visible function

Input:   entity targ - entity to determine visiblity from self
Output:  float - true if visible from self, false if not
Changes: none
=============
*/
float (entity targ) ZEUS_visible =
{
  local   vector  spot1, spot2;
  local   float   adj_yaw, ang_y;

  ZEUS_EntityOrigin (targ);
  spot1 = self.origin + self.view_ofs;

  if (targ.netname == "se_ZEUS_se")
    spot2 = ZEUS_StaticOrigin (targ);
  else
    spot2 = targ.origin + targ.view_ofs;
  traceline (spot1, spot2, true, self);	// see through other monsters

  if ((trace_inopen && trace_inwater) && (targ.classname == "player"))
    return false;			// sight line crossed contents
  if ((trace_fraction == 1) || (trace_ent == targ))
  {
    //now check to see if target is in front

    ang_y = vectoyaw (spot2 - spot1);

    adj_yaw = self.angles_y - ang_y;

    if (self.angles_y > ang_y)
    {
      if (adj_yaw > 180)
        adj_yaw = adj_yaw - 360;
    }
    else
    {
      if (adj_yaw < -180)
        adj_yaw = adj_yaw + 360;
    }

    if ((self.ZEUS_skill == 0) && (adj_yaw <= 120))
      return true;
    else if ((self.ZEUS_skill == 1) && (adj_yaw <= 150))
      return true;
    else if ((self.ZEUS_skill == 2) && (adj_yaw <= 215))
      return true;
    else if ((self.ZEUS_skill == 3) && (adj_yaw <= 270))
      return true;

    return false;
  }


  return false;
};

/*
===============
ZEUS_allstop

sets the bots velocity to 0

Input:   none
Output:  none
Changes: self.velocity

===============
*/

void () ZEUS_allstop =
{
  if ((self.flags & FL_ONGROUND) || (self.ZEUS_waterlevel > 1))
    self.velocity = '0 0 0';
};

/*
===============
ZEUS_slowdown

halves the bot's velocity. used to make him less likely to fall off edges before jumping

Input:   none
Output:  none
Changes: self.velocity
===============
*/
void () ZEUS_slowdown =
{
  self.velocity = self.velocity * 0.5;
};

/*
===============
ZEUS_CheckGap

determines if there is an unwalkable gap directly in front of the bot
checking begins at dist units in front of the bot

Input:   float dist - distance from self to begin checking for a gap
Output:  float - true if a gap was found, false if not
Changes: none
===============
*/
float (float dist) ZEUS_CheckGap =
{
  local   float   grade, out_dist, down_dist, solid_count;
  local   float   i, trace_dist, fwd_inc, tf_min, tf_max, pc;
  local   vector  org, end;
  local   float   all_lava, lava_run;

// call makevectors before calling CheckGap!!!!!!!!!
  org = self.origin;

  // check 64 units in front, foot level
  traceline (org, org - '0 0 24' + v_forward * (dist), true, self);
  if (trace_fraction != 1.0)
    return false;

  // check 64 units in front, waist level
  traceline (org, org + v_forward * (dist), true, self);
  if (trace_fraction != 1.0)
  return false;

  // check 64 units in front, eye level
  traceline (org, org + '0 0 16' + v_forward * (dist), true, self);
  if (trace_fraction != 1.0)
  return false;

  // no wall detected, so continue looking for gap
  trace_dist = 1000;
  fwd_inc = 8;
  // begin dist units in front of bot at waist level
  org = self.origin + v_forward * dist;
  // end trace_dist units below that
  end = org;
  end_z = end_z - trace_dist;
  solid_count = out_dist = down_dist = 0;

  tf_min = trace_dist;
  tf_max = 0;
  all_lava = lava_run = 0;

  i = 0;
  // continue tracing 8 times, going further out each time
  while (i < 4)
  {
    // trace second line down, add height to down_dist, increment out_dist
    org = org + v_forward * fwd_inc;
    end = end + v_forward * fwd_inc;
    traceline (org, end, true, self);

    // if first trace, set tf_min
    down_dist = trace_fraction * trace_dist;
    if (i == 0)
      tf_min = down_dist;
    else if (i == 3)
      tf_max = down_dist;

    // is their a solid object here < 24 units below bot's feet?
    if (trace_fraction * trace_dist < 48)
      solid_count = solid_count + 1;
    out_dist = out_dist + fwd_inc;

    pc = pointcontents (trace_endpos);
    if ((pc == CONTENT_LAVA) || (pc == CONTENT_SLIME))
    {
      lava_run = lava_run + 1;
      water_type = pc;
    }
    else
    {
      if (lava_run > 3)
        all_lava = true;
      lava_run = 0;
    }

    i = i + 1;
  }

  if (lava_run > 3) all_lava = true;

//  if ((all_lava) && (water_type == CONTENT_WATER))
//    return false;

  down_dist = tf_max - tf_min;
  grade = down_dist / out_dist;

  // are both max and min almost equal, but still far below?
  // if so, grade will be close to 0, but there is still a
  // dropoff
  if ((tf_max > (dist + 16)) && (tf_min > (dist + 16)) && (grade < 0.25))
    return true;

  if (((grade > 1.75) && (solid_count < 1)) || (all_lava))
    return true;
  else
    return false;

};

/*
===============
ZEUS_CheckWater

determines if there is an unwalkable water body directly in front of the bot
checking begins at dist units in front of the bot

Input:   float dist - distance from self to begin checking for water
Output:  float - true if water was found, false if not
Changes: none
===============
*/
float (float dist) ZEUS_CheckWater =
{
  local   float   grade, out_dist, down_dist, water_count;
  local   float   i, trace_dist, fwd_inc, tf_min, tf_max, pc;
  local   vector  org, end;

// call makevectors before calling CheckWater!!!!!!!!!
//  makevectors (self.angles);

  org = self.origin;

  // check 64 units in front, foot level
  traceline (org, org - '0 0 24' + v_forward * (dist), true, self);
  if (trace_fraction != 1.0)
  {
    // check 64 units in front, waist level
    traceline (org, org + v_forward * (dist), true, self);
    if (trace_fraction != 1.0)
    {
      // check 64 units in front, eye level
      traceline (org, org + '0 0 16' + v_forward * (dist), true, self);
      if (trace_fraction != 1.0)
        return false;
    }
  }
  // no wall detected, so continue looking for water
  trace_dist = 1000;
  fwd_inc = 8;
  // begin dist units in front of bot at waist level
  org = self.origin + v_forward * dist;
  // end trace_dist units below that
  end = org;
  end_z = end_z - trace_dist;
  water_count = 0;
  water_type = CONTENT_EMPTY;

  i = 0;
  // continue tracing 4 times, going further out each time
  while (i < 4)
  {
    // trace second line down, add height to down_dist, increment out_dist
    org = org + v_forward * fwd_inc;
    end = end + v_forward * fwd_inc;
    traceline (org, end, true, self);

    if (trace_inwater)
    {
      water_count = water_count + 1;
      pc = pointcontents (trace_endpos);
      if ((pc == CONTENT_WATER) || (pc == CONTENT_LAVA) || (pc == CONTENT_SLIME))
        water_type = pc;
    }

    i = i + 1;
  }

  if (water_count >= 3)
    return true;
  else
    return false;
};

/*
======================
ZEUS_TerrainType

Attempts to determine the type of terrain in direction dir from self.
Determines the pitch and yaw of the face of any walls encountered

Input:   vector dir - direction in which to check terrain
         float dist - maximum distance away to check terrain
Output:  true if a passable terrian type, false if impassable
Changes: wall_dist, wall_pitch, wall_type, wall_yaw
======================
*/

float (vector dir, vector dir_right, float dist) ZEUS_TerrainType =
{
  local   vector  org, mod;
  local   vector  end1, end2, end3, end4, end5, end6;
  local   float   d1, d2, d3, d4, d5, d6;
  local   float   left_grade, right_grade;
  local   float   farthest_left, farthest_right;
  local   float   closest_left, closest_right;
  local   float   left_blocked, right_blocked;
  local   float   temp;

  org = self.origin;
  closest_right = closest_left = dist;
  farthest_right = farthest_left = 0;
  left_blocked = right_blocked = false;

  // upper left corner
  mod = org + v_up * 34 - dir_right * 14;
  traceline (mod, mod + dir * dist, true, self);
  d1 = trace_fraction * dist;
  if (d1 < closest_left) closest_left = d1;
  if (d1 > farthest_left) farthest_left = d1;
  if (trace_fraction < 1.0) left_blocked = true;
  end1 = trace_endpos;
  if (self.classname == "player")
    ZEUS_SpawnMarker (trace_endpos, "progs/grenade.mdl", 0.5);

  // upper right corner
  mod = org + v_up * 34 + dir_right * 14;
  traceline (mod, mod + dir * dist, true, self);
  d2 = trace_fraction * dist;
  if (d2 < closest_right) closest_right = d2;
  if (d2 > farthest_right) farthest_right = d2;
  if (trace_fraction < 1.0) right_blocked = true;
  end2 = trace_endpos;
  if (self.classname == "player")
    ZEUS_SpawnMarker (trace_endpos, "progs/grenade.mdl", 0.5);

  // center left
  mod = org - dir_right * 14  - v_up * 4;
  traceline (mod, mod + dir * dist, true, self);
  d3 = trace_fraction * dist;
  if (d3 < closest_left) closest_left = d3;
  if (d3 > farthest_left) farthest_left = d3;
  if (trace_fraction < 1.0) left_blocked = true;
  end3 = trace_endpos;
  if (self.classname == "player")
    ZEUS_SpawnMarker (trace_endpos, "progs/grenade.mdl", 0.5);

  // center right
  mod = org + dir_right * 14 - v_up * 4;
  traceline (mod, mod + dir * dist, true, self);
  d4 = trace_fraction * dist;
  if (d4 < closest_right) closest_right = d4;
  if (d4 > farthest_right) farthest_right = d4;
  if (trace_fraction < 1.0) right_blocked = true;
  end4 = trace_endpos;
  if (self.classname == "player")
    ZEUS_SpawnMarker (trace_endpos, "progs/grenade.mdl", 0.5);

  // lower left
  mod = org - v_up * 16 - dir_right * 14;
  traceline (mod, mod + dir * dist, true, self);
  d5 = trace_fraction * dist;
  if (d5 < closest_left) closest_left = d5;
  if (d5 > farthest_left) farthest_left = d5;
  if (trace_fraction < 1.0) left_blocked = true;
  end5 = trace_endpos;
  if (self.classname == "player")
    ZEUS_SpawnMarker (trace_endpos, "progs/grenade.mdl", 0.5);

  // lower right
  mod = org - v_up * 16 + dir_right * 14;
  traceline (mod, mod + dir * dist, true, self);
  d6 = trace_fraction * dist;
  if (d6 < closest_right) closest_right = d6;
  if (d6 > farthest_right) farthest_right = d6;
  if (trace_fraction < 1.0) right_blocked = true;
  end6 = trace_endpos;
  if (self.classname == "player")
    ZEUS_SpawnMarker (trace_endpos, "progs/grenade.mdl", 0.5);

  left_grade = 52 / (d1 - d5);
  right_grade = 52 / (d2 - d6);
  wall_dist = dist;
  wall_pitch = '0 0 0';

  if (left_blocked)
  {
    wall_pitch = end1 - end5;
    wall_type = TER_PARTIAL;
    if (d1 < d5)
      wall_dist = d1;
    else
      wall_dist = d5;
  }
  if (right_blocked)
  {
    wall_pitch = end2 - end6;
    wall_type = TER_PARTIAL;
    if (d2 < d6)
      temp = d2;
    else
      temp = d6;

    if (temp < wall_dist) wall_dist = temp;
  }

  // possible slope up/stairs
  if (((d3 < d1) && (d5 < d3)) && ((d4 < d2) && (d6 < d4)) &&
      ((left_grade < 1.2) && (right_grade < 1.2)))
  {
//    bprint (PRINT_HIGH, "grade up\n");
    wall_dist = dist;
    wall_type = TER_GRADEUP;
    return true;
  }
  else if (((d3 < d1) && (d5 < d3)) || ((d4 < d2) && (d6 < d4)) &&
      ((left_grade < 2.0) || (right_grade < 2.0)) && (wall_dist <= 64))
  {
//    bprint (PRINT_HIGH, "partial grade up\n");
    wall_type = TER_PARTIAL;
    return false;
  }
  else if ((left_grade > 2.0) && (right_grade > 2.0) &&
           (right_blocked) && (left_blocked) && (wall_dist <= 64))
  {
//   bprint (PRINT_HIGH, "wall\n");
    wall_yaw = vectoyaw (end1 - end2);
    wall_type = TER_WALL;
    return true;
  }
  else if ((left_grade > 2.0) || (right_grade > 2.0) &&
           ((right_blocked) || (left_blocked)) && (wall_dist <= 32))
  {
//    bprint (PRINT_HIGH, "partial wall or high slope\n");
    wall_type = TER_PARTIAL;
    return false;
  }
  else if ((left_grade < 0) && (right_grade < 0) && (wall_dist <= 48))
  {
//    bprint (PRINT_HIGH, "high obstruction or sloping ceiling\n");
    wall_type = TER_HIGH_OBS;
    return false;
  }
  else if ((left_grade < 0) || (right_grade < 0))
  {
//    bprint (PRINT_HIGH, "partial high obstruction or sloping ceiling\n");
    wall_type = TER_PARTIAL;
    return false;
  }
  else if ((left_grade > 2.0) && (right_grade > 2.0) &&
           (right_blocked) && (left_blocked) && (wall_dist > 32))
  {
//    bprint (PRINT_HIGH, "far wall\n");
    wall_type = TER_WALL;
    return true;
  }
  else if ((fabs(d3 - d5) < 4) || (fabs (d4 - d6) < 4) && (wall_dist < 64))
  {
//    bprint (PRINT_HIGH, "low obstruction\n");
    wall_type = TER_PARTIAL;
    wall_yaw = vectoyaw (end3 - end4);
    return false;
  }
  else
  {
//    bprint (PRINT_HIGH, "clear\n");
    wall_dist = dist;
    wall_type = TER_NONE;
    return true;
  }
};

/*
===============
ZEUS_movetogoal

moves the bot forward using his velocity vectors, rather than discretely.
This is the most intricately balanced function in the entire bot
code, so be VERY careful about changing any of the values herein,
or the bot's movement may be adversely affected

Input:   none
Output:  none
Changes: self.ZEUS_stuck, self.ZEUS_stuck_dir, self.origin,
         self.velocity, self.flags
===============
*/

void () ZEUS_movetogoal =
{
  local   vector  dir, org;
  local   float   i, pc, gap, dist;
  local   float   tf1, tf2, tf3, grade;
  local   entity  temp;

  if ((self.touch == ZEUS_JumpTouch) || (!(self.flags & FL_ONGROUND) && !(self.flags & FL_WATERJUMP)))
    return;

  makevectors (self.angles);

  if (vlen (self.velocity) > 0)
    dist = 64;
  else
    dist = 32;

  gap = ZEUS_CheckGap (dist);

  // first, find out if bot moved significantly since last call to
  // ZEUS_movetogoal or if there is a wall obstructing

  grade = ZEUS_TerrainType (v_forward, v_right, dist * 2);

  if ((vlen (self.ZEUS_own_lastorg - self.origin) < 8) || gap ||
      (!grade))
  {
    ZEUS_allstop ();

    if (gap)
    {
      if (ZEUS_JumpAI ()) return;
      i = ZEUS_FindLedge (dist);

      if ((!ZEUS_JumpObstructed (i)) && (i > 0))
      {
        if ((self.deadflag == DEAD_NO) && (self.flags & FL_ONGROUND))
          ZEUS_jump1 ();
        return;
      }
    }

    if (!self.ZEUS_stuck)
    {
      traceline (self.origin, self.origin + v_forward * 50 + v_right * 50, true, self);
      tf1 = trace_fraction;
      traceline (self.origin, self.origin + v_forward * 50 - v_right * 50, true, self);

      if ((tf1 < trace_fraction) || (random () < 0.5))
        self.ZEUS_stuck_dir = 45;
      else
        self.ZEUS_stuck_dir = -45;

      if (gap) self.ZEUS_stuck_dir = self.ZEUS_stuck_dir / 2;
    }
    else
    {
      ZEUS_ResetGoalEntity ();
      self.search_time = time;
    }

    self.angles_y = self.angles_y + self.ZEUS_stuck_dir;
    self.ZEUS_stuck = true;
  }
  else
  {
    self.ZEUS_stuck = false;
    self.ZEUS_stuck_dir = 0;
  }

  ZEUS_EntityOrigin (self.goalentity);
  dir = entity_org - self.origin;
  normalize (dir);
  dir_z = 0;

  // if not on ground, then exit cause we're either swimming or jumping!
  if (!(self.flags & FL_ONGROUND) && !(self.flags & FL_WATERJUMP)) return;

  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;
  if (self.flags & FL_PARTIALGROUND)
    self.flags = self.flags - FL_PARTIALGROUND;

  ZEUS_ai_face ();
  self.origin_z = self.origin_z + 2;

  self.velocity_x = 0;
  self.velocity_y = 0;
  if (!gap)
  {
    if (self.flags & FL_WATERJUMP)
    {
      self.flags = self.flags - FL_WATERJUMP;
      self.velocity = self.velocity + 160 * v_forward;
    }
    else
      self.velocity = self.velocity + 440 * v_forward;

    self.velocity_z = 0;
  }

  // get out of here now or we'll start climbing walls!
  if (gap) return;

  // use trace_line to find obstacles on floor
  org = self.origin + v_forward * 16;
//  traceline (org, org - '0 0 27', true, self);
  traceline (org - v_right * 14, org - '0 0 27' - v_right * 14, true, self);
  tf1 = trace_fraction;
  traceline (org + v_right * 14, org - '0 0 27' + v_right * 14, true, self);
  tf2 = trace_fraction;
  traceline (org, org - '0 0 27', true, self);

  if (tf1 < trace_fraction) trace_fraction = tf1;
  if (tf2 < trace_fraction) trace_fraction = tf2;
  pc = trace_fraction;

  org = self.origin + v_forward * 32;
  traceline (org - v_right * 14, org - '0 0 27' - v_right * 14, true, self);
  tf1 = trace_fraction;
  traceline (org + v_right * 14, org - '0 0 27' + v_right * 14, true, self);
  tf2 = trace_fraction;

  trace_fraction = pc;

  if (tf1 < trace_fraction) trace_fraction = tf1;
  if (tf2 < trace_fraction) trace_fraction = tf2;

  // add that much altitude to the bot
  if ((trace_fraction <= 0.9))// && (pc == CONTENT_EMPTY))
  {
    // what a whacked out equation this is...
    // but it is necessary because bot's don't always spawn with the exact same
    // org_z even though they are on the same floor.  A margin of error must be
    // taken into account
    i = ceil (27 * (1.0 - trace_fraction));
    if (wall_type == TER_NONE) i = i + 1;
    if (i > 20) i = 0;

    // check for low obstructions above bot's head
    org = self.origin + v_forward * 14;
    traceline (org + '0 0 30' + v_right * 14, org + '0 0 60' + v_right * 14, true, self);
    tf1 = trace_fraction;
    traceline (org + '0 0 30' - v_right * 14, org + '0 0 60' - v_right * 14, true, self);
    tf2 = trace_fraction;
    org = self.origin - v_forward * 16;
    traceline (org + '0 0 30' + v_right * 14, org + '0 0 60' + v_right * 14, true, self);
    tf3 = trace_fraction;
    traceline (org + '0 0 30' - v_right * 14, org + '0 0 60' - v_right * 14, true, self);

    if (tf1 < trace_fraction) trace_fraction = tf1;
    if (tf2 < trace_fraction) trace_fraction = tf2;
    if (tf3 < trace_fraction) trace_fraction = tf3;

    if (trace_fraction * 30 < i)
      i = trace_fraction * 30;
    org = self.origin;
    org_z = org_z + i;
    setorigin (self, org);
  }

  // make map nodes
  ZEUS_PlaceNode (LINK_TWO_WAY);

  // save this location so we can tell if ZEUS manages to move forward
  self.ZEUS_own_lastorg = self.origin;
};

/*
===============
ZEUS_movefromgoal

moves the bot backwards using velocity vectors, rather than discretely.
This is the most intricately balanced function in the entire bot
code, so be VERY careful about changing any of the values herein,
or the bot's movement may be adversely affected

Input:   none
Output:  none
Changes: self.ZEUS_stuck, self.ZEUS_stuck_dir, self.origin,
         self.velocity, self.flags
===============
*/

void () ZEUS_movefromgoal =
{
  local   vector  dir, org;
  local   float   i, pc, gap, dist;
  local   float   tf1, tf2, tf3, grade;
  local   entity  temp;

  if ((self.touch == ZEUS_JumpTouch) || (!(self.flags & FL_ONGROUND) && !(self.flags & FL_WATERJUMP)))
    return;

  makevectors (self.angles);
  // we're going backwards, so flip the direction vectors
  v_forward = v_forward * -1;
  v_right = v_right * -1;

  if (vlen (self.velocity) > 0)
    dist = 64;
  else
    dist = 32;
  gap = ZEUS_CheckGap (dist);

  // first, find out if bot moved significantly since last call to
  // ZEUS_movetogoal or if there is a wall obstructing

  grade = ZEUS_TerrainType (v_forward, v_right, dist * 2);

  if ((vlen (self.ZEUS_own_lastorg - self.origin) < 8) || gap ||
      (!grade))
  {
    ZEUS_allstop ();

    if (gap)
    {
      if (ZEUS_JumpAI ()) return;
      i = ZEUS_FindLedge (dist);

      if ((!ZEUS_JumpObstructed (i)) && (i > 0))
      {
        if ((self.deadflag == DEAD_NO) && (self.flags & FL_ONGROUND))
          ZEUS_jump1 ();
        return;
      }
    }

    if (!self.ZEUS_stuck)
    {
      traceline (self.origin, self.origin + v_forward * 50 + v_right * 50, true, self);
      tf1 = trace_fraction;
      traceline (self.origin, self.origin + v_forward * 50 - v_right * 50, true, self);

      if ((tf1 < trace_fraction) || (random () < 0.5))
        self.ZEUS_stuck_dir = 45;
      else
        self.ZEUS_stuck_dir = -45;

      if (gap) self.ZEUS_stuck_dir = self.ZEUS_stuck_dir / 2;
    }
    else
    {
      ZEUS_ResetGoalEntity ();
      self.search_time = time;
    }

    self.angles_y = self.angles_y + self.ZEUS_stuck_dir;
    self.ZEUS_stuck = true;
  }
  else
  {
    self.ZEUS_stuck = false;
    self.ZEUS_stuck_dir = 0;
  }

  ZEUS_EntityOrigin (self.goalentity);
  dir = entity_org - self.origin;
  normalize (dir);
  dir_z = 0;

  // if not on ground, then exit cause we're either swimming or jumping!
  if (!(self.flags & FL_ONGROUND) && !(self.flags & FL_WATERJUMP)) return;

  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;
  if (self.flags & FL_PARTIALGROUND)
    self.flags = self.flags - FL_PARTIALGROUND;

  ZEUS_ai_face ();
  self.origin_z = self.origin_z + 1;

  self.velocity_x = 0;
  self.velocity_y = 0;
  if (!gap)
  {
    if (self.flags & FL_WATERJUMP)
    {
      self.flags = self.flags - FL_WATERJUMP;
      self.velocity = self.velocity + 160 * v_forward;
    }
    else
      self.velocity = self.velocity + 440 * v_forward;

    self.velocity_z = 0;
  }

  // get out of here now or we'll start climbing walls!
  if (gap) return;

  // use trace_line to find obstacles on floor
  org = self.origin + v_forward * 16;
//  traceline (org, org - '0 0 27', true, self);
  traceline (org - v_right * 14, org - '0 0 27' - v_right * 14, true, self);
  tf1 = trace_fraction;
  traceline (org + v_right * 14, org - '0 0 27' + v_right * 14, true, self);
  tf2 = trace_fraction;
  traceline (org, org - '0 0 27', true, self);

  if (tf1 < trace_fraction) trace_fraction = tf1;
  if (tf2 < trace_fraction) trace_fraction = tf2;
  pc = trace_fraction;

  org = self.origin + v_forward * 32;
  traceline (org - v_right * 14, org - '0 0 27' - v_right * 14, true, self);
  tf1 = trace_fraction;
  traceline (org + v_right * 14, org - '0 0 27' + v_right * 14, true, self);
  tf2 = trace_fraction;

  trace_fraction = pc;

  if (tf1 < trace_fraction) trace_fraction = tf1;
  if (tf2 < trace_fraction) trace_fraction = tf2;

  // add that much altitude to the bot
  if ((trace_fraction <= 0.9))// && (pc == CONTENT_EMPTY))
  {
    // what a whacked out equation this is...
    // but it is necessary because bot's don't always spawn with the exact same
    // org_z even though they are on the same floor.  A margin of error must be
    // taken into account
    i = ceil (27 * (1.0 - trace_fraction));
    if (wall_type == TER_NONE) i = i + 1;
    if (i > 20) i = 0;

    // check for low obstructions above bot's head
    org = self.origin + v_forward * 14;
    traceline (org + '0 0 30' + v_right * 14, org + '0 0 60' + v_right * 14, true, self);
    tf1 = trace_fraction;
    traceline (org + '0 0 30' - v_right * 14, org + '0 0 60' - v_right * 14, true, self);
    tf2 = trace_fraction;
    org = self.origin - v_forward * 16;
    traceline (org + '0 0 30' + v_right * 14, org + '0 0 60' + v_right * 14, true, self);
    tf3 = trace_fraction;
    traceline (org + '0 0 30' - v_right * 14, org + '0 0 60' - v_right * 14, true, self);

    if (tf1 < trace_fraction) trace_fraction = tf1;
    if (tf2 < trace_fraction) trace_fraction = tf2;
    if (tf3 < trace_fraction) trace_fraction = tf3;

    if (trace_fraction * 30 < i)
      i = trace_fraction * 30;
    org = self.origin;
    org_z = org_z + i;
    setorigin (self, org);
  }

  // make map nodes
  ZEUS_PlaceNode (LINK_TWO_WAY);

  // save this location so we can tell if ZEUS manages to move forward
  self.ZEUS_own_lastorg = self.origin;
};
/*
  if (vlen (self.velocity) > 0)
    dist = 64;
  else
    dist = 32;
  gap = ZEUS_CheckGap (dist);

  // first, find out if bot moved significantly since last call to
  // ZEUS_movetogoal or if there is a wall obstructing

  grade = ZEUS_TerrainType (v_forward, v_right, dist * 2);

  if ((vlen (self.ZEUS_own_lastorg - self.origin) < 8) || gap ||
      (!grade))
  {
    ZEUS_allstop ();

    if (gap)
    {
      i = ZEUS_FindLedge (dist);

      if ((!ZEUS_JumpObstructed (i)) && (i > 0))
      {
        if ((self.deadflag == DEAD_NO) && (self.flags & FL_ONGROUND))
          ZEUS_jump1 ();
        return;
      }
    }
    else if (self.goalentity == self.movetarget)
    {
      ZEUS_ResetGoalEntity;
      self.search_time = time;
    }
    if (!self.ZEUS_stuck)
    {
      traceline (self.origin, self.origin + v_forward * 50 + v_right * 50, true, self);
      tf1 = trace_fraction;
      traceline (self.origin, self.origin + v_forward * 50 - v_right * 50, true, self);

      if ((tf1 < trace_fraction) || (random () < 0.5))
        self.ZEUS_stuck_dir = 45;
      else
        self.ZEUS_stuck_dir = -45;

      if (gap) self.ZEUS_stuck_dir = self.ZEUS_stuck_dir / 2;
    }

    self.angles_y = self.angles_y + self.ZEUS_stuck_dir;
    self.ZEUS_stuck = true;
  }
  else
  {
    self.ZEUS_stuck = false;
    self.ZEUS_stuck_dir = 0;
  }

  ZEUS_EntityOrigin (self.goalentity);
  dir = entity_org - self.origin;
  normalize (dir);
  dir_z = 0;

  // if not on ground, then exit cause we're either swimming or jumping!
  if (!(self.flags & FL_ONGROUND) && !(self.flags & FL_WATERJUMP)) return;

  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;
  if (self.flags & FL_PARTIALGROUND)
    self.flags = self.flags - FL_PARTIALGROUND;

  if (!self.ZEUS_stuck)
  {
    ZEUS_ai_face ();
    self.origin_z = self.origin_z + 1;
  }

  self.velocity_x = 0;
  self.velocity_y = 0;

  if (self.flags & FL_WATERJUMP)
  {
    self.flags = self.flags - FL_WATERJUMP;
    self.velocity = self.velocity + 140 * v_forward;
  }
  else
    self.velocity = self.velocity + 420 * v_forward;

  self.velocity_z = 0;

  // use trace_line to find obstacles on floor
  org = self.origin + v_forward * 16;
  traceline (org - v_right * 14, org - '0 0 27' - v_right * 14, true, self);
  tf1 = trace_fraction;
  traceline (org + v_right * 14, org - '0 0 27' + v_right * 14, true, self);
  tf2 = trace_fraction;
  traceline (org, org - '0 0 27', true, self);

  if (tf1 < trace_fraction) trace_fraction = tf1;
  if (tf2 < trace_fraction) trace_fraction = tf2;
  pc = trace_fraction;

  org = self.origin + v_forward * 32;
  traceline (org - v_right * 14, org - '0 0 27' - v_right * 14, true, self);
  tf1 = trace_fraction;
  traceline (org + v_right * 14, org - '0 0 27' + v_right * 14, true, self);
  tf2 = trace_fraction;

  trace_fraction = pc;

  if (tf1 < trace_fraction) trace_fraction = tf1;
  if (tf2 < trace_fraction) trace_fraction = tf2;

  // add that much altitude to the bot
  if ((trace_fraction <= 0.9))// && (pc == CONTENT_EMPTY))
  {
    // what a whacked out equation this is...
    // but it is necessary because bot's don't always spawn with the exact same
    // org_z even though they are on the same floor.  A margin of error must be
    // taken into account
    i = ceil (27 * (1.0 - trace_fraction));
    if (i > 20) i = 0;

    // check for low obstructions above bot's head
    org = self.origin + v_forward * 14;
    traceline (org + '0 0 30' + v_right * 14, org + '0 0 60' + v_right * 14, true, self);
    tf1 = trace_fraction;
    traceline (org + '0 0 30' - v_right * 14, org + '0 0 60' - v_right * 14, true, self);
    tf2 = trace_fraction;
    org = self.origin - v_forward * 14;
    traceline (org + '0 0 30' + v_right * 14, org + '0 0 60' + v_right * 14, true, self);
    tf3 = trace_fraction;
    traceline (org + '0 0 30' - v_right * 14, org + '0 0 60' - v_right * 14, true, self);

    if (tf1 < trace_fraction) trace_fraction = tf1;
    if (tf2 < trace_fraction) trace_fraction = tf2;
    if (tf3 < trace_fraction) trace_fraction = tf3;

    if (trace_fraction * 30 < i)
      i = trace_fraction * 30;
    org = self.origin;
    org_z = org_z + i;
    setorigin (self, org);
  }

  // make map nodes
  ZEUS_PlaceNode (LINK_TWO_WAY);

  // save this location so we can tell if ZEUS manages to move forward
  self.ZEUS_own_lastorg = self.origin;
};
*/
/*
===============
ZEUS_strafetogoal

moves the bot towards ent using his velocity vectors, rather
than discretely. This is the most intricately balanced function in the
entire bot code, so be VERY careful about changing any of the values herein,
or the bot's movement may be adversely affected

Bot does NOT turn to face the direction of travel, but continues facing
self.goalentity.

Input:   none
Output:  none
Changes: self.ZEUS_stuck, self.ZEUS_stuck_dir, self.origin,
         self.velocity, self.flags
===============
*/

void (entity ent) ZEUS_strafetogoal =
{
  local   vector  dir, org;
  local   float   i, pc, gap, dist;
  local   float   tf1, tf2, tf3, grade;
  local   entity  temp;

  if ((self.touch == ZEUS_JumpTouch) || (!(self.flags & FL_ONGROUND) && !(self.flags & FL_WATERJUMP)))
    return;

  // get v_forward in direction of travel
  ZEUS_EntityOrigin (ent);
  dir = normalize (entity_org - self.origin);
  org = vectoangles (dir);
  makevectors (org);

  if (vlen (self.velocity) > 0)
    dist = 64;
  else
    dist = 32;
  gap = ZEUS_CheckGap (dist);

  // first, find out if bot moved significantly since last call to
  // ZEUS_movetogoal or if there is a wall obstructing

  grade = ZEUS_TerrainType (v_forward, v_right, dist * 2);

  if ((vlen (self.ZEUS_own_lastorg - self.origin) < 8) || gap ||
      (!grade))
  {
    ZEUS_allstop ();

    if (gap)
    {
      i = ZEUS_FindLedge (dist);

      if ((!ZEUS_JumpObstructed (i)) && (i > 0))
      {
        if ((self.deadflag == DEAD_NO) && (self.flags & FL_ONGROUND))
          ZEUS_jump1 ();
        return;
      }
    }
    else if (self.goalentity == self.movetarget)
    {
      ZEUS_ResetGoalEntity;
      self.search_time = time;
    }
    if (!self.ZEUS_stuck)
    {
      traceline (self.origin, self.origin + v_forward * 50 + v_right * 50, true, self);
      tf1 = trace_fraction;
      traceline (self.origin, self.origin + v_forward * 50 - v_right * 50, true, self);

      if ((tf1 < trace_fraction) || (random () < 0.5))
        self.ZEUS_stuck_dir = 45;
      else
        self.ZEUS_stuck_dir = -45;

      if (gap) self.ZEUS_stuck_dir = self.ZEUS_stuck_dir / 2;
    }

    self.angles_y = self.angles_y + self.ZEUS_stuck_dir;
    self.ZEUS_stuck = true;
  }
  else
  {
    self.ZEUS_stuck = false;
    self.ZEUS_stuck_dir = 0;
  }

  ZEUS_EntityOrigin (self.goalentity);
  dir = entity_org - self.origin;
  normalize (dir);
  dir_z = 0;

  // if not on ground, then exit cause we're either swimming or jumping!
  if (!(self.flags & FL_ONGROUND) && !(self.flags & FL_WATERJUMP)) return;

  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;
  if (self.flags & FL_PARTIALGROUND)
    self.flags = self.flags - FL_PARTIALGROUND;

  ZEUS_ai_face ();
  self.origin_z = self.origin_z + 1;

  self.velocity_x = 0;
  self.velocity_y = 0;
  if (!gap)
  {
    if (self.flags & FL_WATERJUMP)
    {
      self.flags = self.flags - FL_WATERJUMP;
      self.velocity = self.velocity + 140 * v_forward;
    }
    else
      self.velocity = self.velocity + 360 * v_forward;

    self.velocity_z = 0;
  }

  // get out of here now or we'll start climbing walls!
  if (gap) return;

  // use trace_line to find obstacles on floor
  org = self.origin + v_forward * 16;
//  traceline (org, org - '0 0 27', true, self);
  traceline (org - v_right * 14, org - '0 0 27' - v_right * 14, true, self);
  tf1 = trace_fraction;
  traceline (org + v_right * 14, org - '0 0 27' + v_right * 14, true, self);
  tf2 = trace_fraction;
  traceline (org, org - '0 0 27', true, self);

  if (tf1 < trace_fraction) trace_fraction = tf1;
  if (tf2 < trace_fraction) trace_fraction = tf2;
  pc = trace_fraction;

  org = self.origin + v_forward * 32;
  traceline (org - v_right * 14, org - '0 0 27' - v_right * 14, true, self);
  tf1 = trace_fraction;
  traceline (org + v_right * 14, org - '0 0 27' + v_right * 14, true, self);
  tf2 = trace_fraction;

  trace_fraction = pc;

  if (tf1 < trace_fraction) trace_fraction = tf1;
  if (tf2 < trace_fraction) trace_fraction = tf2;

  // add that much altitude to the bot
  if ((trace_fraction <= 0.9))// && (pc == CONTENT_EMPTY))
  {
    // what a whacked out equation this is...
    // but it is necessary because bot's don't always spawn with the exact same
    // org_z even though they are on the same floor.  A margin of error must be
    // taken into account
    i = ceil (27 * (1.0 - trace_fraction));
    if (wall_type == TER_NONE) i = i + 1;
    if (i > 20) i = 0;

    // check for low obstructions above bot's head
    org = self.origin + v_forward * 14;
    traceline (org + '0 0 30' + v_right * 14, org + '0 0 60' + v_right * 14, true, self);
    tf1 = trace_fraction;
    traceline (org + '0 0 30' - v_right * 14, org + '0 0 60' - v_right * 14, true, self);
    tf2 = trace_fraction;
    org = self.origin - v_forward * 16;
    traceline (org + '0 0 30' + v_right * 14, org + '0 0 60' + v_right * 14, true, self);
    tf3 = trace_fraction;
    traceline (org + '0 0 30' - v_right * 14, org + '0 0 60' - v_right * 14, true, self);

    if (tf1 < trace_fraction) trace_fraction = tf1;
    if (tf2 < trace_fraction) trace_fraction = tf2;
    if (tf3 < trace_fraction) trace_fraction = tf3;

    if (trace_fraction * 30 < i)
      i = trace_fraction * 30;
    org = self.origin;
    org_z = org_z + i;
    setorigin (self, org);
  }

  // make map nodes
  ZEUS_PlaceNode (LINK_TWO_WAY);

  // save this location so we can tell if ZEUS manages to move forward
  self.ZEUS_own_lastorg = self.origin;
};

/*
======================
ZEUS_JumpTouch

called when the bot is in the air and touches any object

Input:   none
Output:  none
Changes: self.velocity, self.deathtype, self.touch
======================
*/

void()	ZEUS_JumpTouch =
{
  local	float	ldmg;

//  if (self.velocity_z < -10.0 || self.velocity_z > 10.0) return;

  self.touch = SUB_Null;
  ZEUS_SetThink (self.th_follow);

  if (self.velocity_z < -650)
  {
    T_Damage (self, world, world, 5);
    sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
    self.deathtype = "falling";
  }
  else if (self.velocity_z < -300)
    sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
};

/*
======================
ZEUS_PrintStatus

prints the status of the players Zeus bots, ie. available or
not

Input:   none
Output:  none
Changes: none
======================
*/

void () ZEUS_PrintStatus =

{
  if (!deathmatch)
    sprint (self, PRINT_HIGH, "There is no Zeus bot here.\n");
  else
  {
    if (self.bot_avail)
      sprint (self, PRINT_HIGH, "No Zeus bot is present.\n");
    else
      sprint (self, PRINT_HIGH, "No Zeus bot is available.\n");
  }
};

/*
======================
ZEUS_DistClear

throw out vectors from center and corners of bot's bounding box
and make sure there is a hole big enough for the bot to fit through

Input:   entity item - item to check path to
Output:  float - distance of the shortest trace alog a vector to item
Changes: none
======================
*/

float (entity item) ZEUS_DistClear =
{
  local   vector  org, end, vec, ang;
  local   float   dist, shortest_trace;
  local   vector  shortest_endpos;

  org = self.origin;
  end = ZEUS_EntityOrigin (item);
  vec = end - org;    // vector pointing to item from bot
  dist = vlen (vec);  // distance to item from bot

  vec = normalize (vec);
  ang = vectoangles (vec);
  makevectors (ang);    // get v_forward, v_right, and v_up in dir of item

//  traceline (org, end, true, self);
//  return (trace_fraction * dist);

  // trace from upper right corner of bot's bounding box
  vec = '16 0 32';
  traceline (org + vec, end + vec, true, self);
  shortest_trace = trace_fraction;
  shortest_endpos = trace_endpos;

  //upper left of bounding box
  vec = '-16 0 32';
  traceline (org + vec, end + vec, true, self);
  if (trace_fraction < shortest_trace)
  {
    shortest_trace = trace_fraction;
    shortest_endpos = trace_endpos;
  }

  // trace from lower right corner
  vec = '16 0 -12';
  traceline (org + vec, end + vec, true, self);
  if (trace_fraction < shortest_trace)
  {
    shortest_trace = trace_fraction;
    shortest_endpos = trace_endpos;
  }

  // trace from lower right corner
  vec = '-16 0 -12';
  traceline (org + vec, end + vec, true, self);
  if (trace_fraction < shortest_trace)
  {
    shortest_trace = trace_fraction;
    shortest_endpos = trace_endpos;
  }

//  setorigin (self.movetarget, shortest_endpos);

  return (shortest_trace * dist);
};

/*
======================
ZEUS_GoToTarget

Called when a func_button is pressed.
Set's the bot's move goal to the location of the button's target if
the target is a platform

Input:   string targ_name - the name of the button's target
Output:  none
Changes: self.goalentity, self.movetarget.origin
======================
*/

void (string targ_name) ZEUS_GoToTarget =
{
};

/*
======================
ZEUS_ChooseNode

Determines what the bot needs most, then locates a node in the node list
with that item or the best substitute and computes the shortest path, storing
that path in self.ZEUS_path
======================
*/
void (entity cur_node) ZEUS_ChooseNode =
{
  local   entity  goal_node;

  goal_node = world;

  // is bot in desperate need of health?
  if (self.health < 50)
    goal_node = ZEUS_FindItem ("item_health");

  // does bot need armor?
  if ((self.armorvalue * self.armortype < 30) && (!goal_node))
    goal_node = ZEUS_FindItem ("item_armor1");
  else if ((self.armorvalue * self.armortype < 90) && (!goal_node))
    goal_node = ZEUS_FindItem ("item_armor2");
  else if ((self.armorvalue * self.armortype < 160) && (!goal_node))
    goal_node = ZEUS_FindItem ("item_armorInv");

  // does bot need a better weapon?
  if ((!goal_node) && (!(self.items & IT_ROCKET_LAUNCHER)))
    goal_node = ZEUS_FindItem ("weapon_rocketlauncher");
  if ((!goal_node) && (!(self.items & IT_QUAD)))
    goal_node = ZEUS_FindItem ("item_artifact_super_damage");
  if ((!goal_node) && (!(self.items & IT_LIGHTNING)))
    goal_node = ZEUS_FindItem ("weapon_lightning");
  if ((!goal_node) && (!(self.items & IT_GRENADE_LAUNCHER)))
    goal_node = ZEUS_FindItem ("weapon_grenadelauncher");
  if ((!goal_node) && (!(self.items & IT_SUPER_NAILGUN)))
    goal_node = ZEUS_FindItem ("weapon_supernailgun");
  if ((!goal_node) && (!(self.items & IT_SUPER_SHOTGUN)))
    goal_node = ZEUS_FindItem ("weapon_supershotgun");
  if ((!goal_node) && (!(self.items & IT_NAILGUN)))
    goal_node = ZEUS_FindItem ("weapon_nailgun");

  // check for Quad and Protection powerups
  if ((!goal_node) && (!(self.items & IT_INVULNERABILITY)))
    goal_node = ZEUS_FindItem ("item_artifact_invulnerability");

  // check for ammo
  if ((!goal_node) && (self.ammo_rockets < 10))
    goal_node = ZEUS_FindItem ("item_rockets");
  if ((!goal_node) && (self.ammo_cells < 10))
    goal_node = ZEUS_FindItem ("item_cells");

  // check for ring of shadows
  if ((!goal_node) && (!(self.items & IT_INVULNERABILITY)))
    goal_node = ZEUS_FindItem ("item_artifact_invisibility");

  if (goal_node)
    ZEUS_ShortestPath (cur_node, goal_node);
};


/*
======================
ZEUS_ChooseGoal

Chooses the bots next movement goal

Input:   none
Output:  float - true if a useable path was found, false if no
         suitable path was found
Changes: self.goalentity, self.ZEUS_last_roam_org, self.search_time
         wall_yaw
======================
*/

float () ZEUS_ChooseGoal =
{
  local   float   i, found, yaw_add, dist, f_dist, gap;
  local   vector  dir, dir_r, yaw;
  local   entity  cur_node, roam_node;

  cur_node = ZEUS_CurrentNode (self);
  roam_node = world;

  if (self.ZEUS_path)
  {
    if (self.search_time <= time)
    {
      Debug_Msgln ("Path reset, time expired.\n");
      ZEUS_EmptyPath ();
    }
    else if ((cur_node.origin == self.ZEUS_path.origin) && (vlen (self.origin - cur_node.origin) < 32))
    {
      ZEUS_RemovePathNode (cur_node);
      ZEUS_allstop ();
    }
  }
  else if (self.ZEUS_findtarget_skip == 1)
    ZEUS_ChooseNode (cur_node);

  if (self.ZEUS_path)
    roam_node = self.ZEUS_path;
  else
    roam_node = ZEUS_ChooseRandomNode (cur_node);

  if (roam_node)
  {
//    bprint ("going to visible roam node\n");
//    self.ZEUS_last_map_node = cur_node;
    setorigin (self.movetarget, roam_node.origin);
    self.search_time = time + vlen (self.origin - roam_node.origin) / 380 + 2;
    return true;
  }

  makevectors (self.angles);

  dist = random () * 128 + 96;
  dir = v_forward;
  dir_r = v_right;

/*
  if (random () < 0.05)
  {
    dir = v_right;
    v_right = -1 * v_forward;
    v_forward = dir;
  }
*/
  traceline (self.origin, self.origin + v_right * dist, true, self);
  i = trace_fraction;
  traceline (self.origin, self.origin - v_right * dist, true, self);
  if (trace_fraction > i)
    yaw_add = 22.5;
  else
    yaw_add = -22.5;

  if (random () < 0.10) yaw_add = yaw_add * -1;

  i = 0;

  while ((i <= 16) && (!found))
  {
    gap = ZEUS_CheckGap (dist);
    if (!gap) gap = ZEUS_CheckWater (dist);
    if ((ZEUS_TerrainType (v_forward, v_right, dist)) && (!gap))
      found = true;
    else
    {
      yaw = vectoangles (v_forward);
      yaw_y = yaw_y + yaw_add;
      makevectors (yaw);
    }

    i = i + 1;
  }

  if (found)
  {
    // turn parallel to the wall

    if (wall_type == TER_WALL)
    {
      if ((yaw_add < 0) && (wall_yaw > self.angles_y))
      {
        wall_yaw = wall_yaw + 180;
        if (wall_yaw > 360)
          wall_yaw = wall_yaw - 360;
      }
      else if ((yaw_add > 0) && (wall_yaw < self.angles_y))
      {
        wall_yaw = wall_yaw - 180;
        if (wall_yaw < 0)
          wall_yaw = wall_yaw + 360;
      }

      self.ideal_yaw = wall_yaw;
      ZEUS_ChangeYaw ();
      makevectors (self.angles);
    }

    // if under water, roam up and down, too
    if (self.ZEUS_waterlevel > 1)
    {
      if (random () < 0.5)
      {
        if ((random () < 0.5) || (self.ZEUS_waterlevel < 3))
          yaw_add = -1;
        else
          yaw_add = 1;

         i = random ();
        dir = self.origin + v_forward * wall_dist + v_up * ((100 + i * wall_dist * 2) * yaw_add);
        traceline (self.origin, dir, true, self);
        dir = self.origin + v_forward * trace_fraction + v_up * ((100 + i * trace_fraction * 2) * yaw_add);

        setorigin (self.movetarget, dir);
      }
      else
        setorigin (self.movetarget, self.origin + v_forward * wall_dist);
    }
    else
      setorigin (self.movetarget, self.origin + v_forward * wall_dist);

    self.goalentity = self.movetarget;
    self.ZEUS_last_roam_org = self.movetarget.origin;
    self.search_time = time + wall_dist / 420;

    return true;
  }
  else
  {
    return false;
  }
};

/*
======================
ZEUS_SetFollowGoal

sets the correct follow goal based on the bot's current owner, roaming
status

Input:   none
Output:  none
Changes: self.goalentity
======================
*/

void () ZEUS_SetFollowGoal =
{
  if ((self.bot_owner.classname == "player") && !(self.ZEUS_roam))
    self.goalentity = self.bot_owner;
  else if ((self.bot_owner.classname == "bot_viewer")
      && !(self.ZEUS_roam))
    self.goalentity = self.bot_owner.movetarget;
  else
    self.goalentity = self.movetarget;
};

/*
======================
ZEUS_ResetGoalEntity

Resets the bot's goalentity based on roam status, current goal,
and distance to current goal

Input:   none
Output:  none
Changes: self.goalentity, self.angles_y
======================
*/

void () ZEUS_ResetGoalEntity =

{
  self.oldenemy = self.enemy;
  self.enemy = world;

  ZEUS_EntityOrigin (self.goalentity);

  if ((self.ZEUS_roam) && ((self.goalentity != self.movetarget) ||
      (vlen (entity_org - self.origin) < ZEUS_roam_goal_dist) ||
      (self.search_time < time)))
  {
    if (ZEUS_ChooseGoal ())
    {
      self.goalentity = self.movetarget;
      return;
    }
    else
    {
      ZEUS_SetFollowGoal ();
      // turn 15 degrees so next goal check will not be in the same dir
      self.angles_y = self.angles_y + 15;
    }
  }
  else
    ZEUS_SetFollowGoal ();
};

/*
======================
ZEUS_ChangeYaw

Changes the bot's facing direction to match self.ideal_yaw

Input:   none
Output:  none
Changes: self.angles_y
======================
*/

void () ZEUS_ChangeYaw =
{
  local float		ideal, move;

  self.angles_y = self.ideal_yaw;
};

/*
======================
ZEUS_SightSound
======================
*/

void () ZEUS_SightSound =
{
  local   float   r;

  if (ZEUS_comments) return;
  if (self.bot_owner == self.movetarget) return;

  r = random ();

  if (r < 0.25)
    sound (self, CHAN_VOICE, "enforcer/sight1.wav", 1, ATTN_NORM);
  else if (r < 0.5)
    sound (self, CHAN_VOICE, "enforcer/sight2.wav", 1, ATTN_NORM);
  else if (r < 0.75)
    sound (self, CHAN_VOICE, "enforcer/sight3.wav", 1, ATTN_NORM);
  else
    sound (self, CHAN_VOICE, "enforcer/sight4.wav", 1, ATTN_NORM);
};

/*
======================
ZEUS_SightComment
======================
*/

void () ZEUS_SightComment =
{
  local   string  newname;
  local   float   r;

  // no comments for opponent bots right now -- that would be WAY too much text
  // 75% chance bot says nothing at all
  if (self.bot_owner == self.movetarget) return;

  if ((self.enemy.classname == "player") || (random () < 0.75) || (ZEUS_comments))
    return;

  // choose a name for the targetted enemy

  r = random () * 10;

  newname = "jerk";
  if(self.enemy.classname == "monster_army")
    {
    if (r < 2.5)
      newname = "jarhead";
    else if (r < 5.0)
      newname = "kiddie";
    else if (r < 7.5)
      newname = "you enforcer wanna-be";
    else
      newname = "fodder-boy";
  }
  else if (self.enemy.classname == "monster_demon1")
  {
    if (r < 2.5)
      newname = "you mutant frog";
    else if (r < 5.0)
      newname = "you hopping vomit-bag";
    else if (r < 7.5)
      newname = "demon";
    else
      newname = "horn-face";
  }
  else if (self.enemy.classname == "monster_dog")
  {
    if (r < 2.5)
      newname = "Lassie";
    else if (r < 5.0)
      newname = "Benji";
    else if (r < 7.5)
      newname = "Old-yeller";
    else
      newname = "Cujo";
  }
  else if (self.enemy.classname == "monster_enforcer")
  {
    if (r < 2.5)
      newname = "girly-man";
    else if (r < 5.0)
      newname = "jerk";
    else if (r < 7.5)
      newname = "scum-face";
    else
      newname = "butthead";
  }
  else if (self.enemy.classname == "monster_fish")
  {
    if (r < 2.5)
      newname = "bottom-dwelling scum sucker";
    else if (r < 5.0)
      newname = "pirahna boy";
    else if (r < 7.5)
      newname = "fish";
    else
      newname = "fish-bait";
  }
  else if (self.enemy.classname == "monster_hell_knight")
  {
    if (r < 2.5)
      newname = "you metal-freak";
    else if (r < 5.0)
      newname = "sardine boy";
    else if (r < 7.5)
      newname = "canhead";
    else
      newname = "tin man";
  }
  else if (self.enemy.classname == "monster_knight")
  {
    if (r < 2.5)
      newname = "tin man";
    else if (r < 5.0)
      newname = "lamer";
    else if (r < 7.5)
      newname = "dork";
    else
      newname = "sword wielding weenie";
  }
  else if (self.enemy.classname == "monster_ogre")
  {
    if (r < 2.5)
      newname = "you hairy brute";
    else if (r < 5.0)
      newname = "baldo";
    else if (r < 7.5)
      newname = "hunch-back";
    else
      newname = "you mutant lumberjack";
  }
  else if (self.enemy.classname == "monster_shalrath")
  {
    if (r < 2.5)
      newname = "Cinderella";
    else if (r < 5.0)
      newname = "four-footed cornhole";
    else if (r < 7.5)
      newname = "ugly SOB";
    else
      newname = "freak";
  }
  else if (self.enemy.classname == "monster_shambler")
  {
    if (r < 2.5)
      newname = "you mutant toddler";
    else if (r < 5.0)
      newname = "you big white wuss";
    else if (r < 7.5)
      newname = "static boy";
    else
      newname = "big boy";
  }
  else if (self.enemy.classname == "monster_tarbaby")
  {
    if (r < 2.5)
      newname = "tarbaby";
    else if (r < 5.0)
      newname = "slimey scum-sack";
    else if (r < 7.5)
      newname = "gooey sack of vomit";
    else
      newname = "puss-bag";
  }
  else if (self.enemy.classname == "monster_wizard")
  {
    if (r < 2.5)
      newname = "you floating puss-bag";
    else if (r < 5.0)
      newname = "fly-boy";
    else if (r < 7.5)
      newname = "slug-face";
    else
      newname = "wizzie";
  }
  else if (self.enemy.classname == "monster_zombie")
  {
    if (r < 2.5)
      newname = "Frakenstein";
    else if (r < 5.0)
      newname = "undead-boy";
    else if (r < 7.5)
      newname = "you rotting sack of excrement";
    else
      newname = "gib fodder";
  }
  else if (self.enemy.classname == "player")
  {
    if (r < 0.75)
      newname = self.enemy.netname;
    else
    {
      if (r < 0.80)
        newname = "cornhole";
      else if (r < 0.85)
        newname = "human";
      else if (r < 0.90)
        newname = "scum-wad";
      else if (r < 0.95)
        newname = "jerk";
      else
        newname = "butthead";
    }
  }

  r = random () * 10;

  // 50% chance that ZEUS bases his comment on the weapon he's carrying
  if ((random () < 0.5) && (self.weapon == IT_LIGHTNING || self.weapon == IT_AXE ||
       self.weapon == IT_ROCKET_LAUNCHER))
  {
    if (self.weapon == IT_AXE)
    {
      if (r < 5.0)
      {
        bprint (PRINT_HIGH, "Zeusbot: Sharpen this for me, ");
        bprint (PRINT_HIGH, newname);
        bprint (PRINT_HIGH, "!\n");
      }
      else
      {
        bprint (PRINT_HIGH, "Zeusbot: Eat cold steel, ");
        bprint (PRINT_HIGH, newname);
        bprint (PRINT_HIGH, "!\n");
      }
    }
    else if (self.weapon == IT_LIGHTNING)
    {
      if (r < 2.5)
      {
        bprint (PRINT_HIGH, "Zeusbot: Taste my shaft, ");
        bprint (PRINT_HIGH, newname);
        bprint (PRINT_HIGH, "!\n");
      }
      else if (r < 5.0)
      {
        bprint (PRINT_HIGH, "Zeusbot: Eat light, ");
        bprint (PRINT_HIGH, newname);
        bprint (PRINT_HIGH, "!\n");
      }
      else if (r < 7.5)
      {
        bprint (PRINT_HIGH, "Zeusbot: Suck on my thunderbolt, ");
        bprint (PRINT_HIGH, newname);
        bprint (PRINT_HIGH, "!\n");
      }
      else if (r < 10.0)
      {
        bprint (PRINT_HIGH, "Zeusbot: Say hello the god of lightning");
        bprint (PRINT_HIGH, newname);
        bprint (PRINT_HIGH, "!\n");
      }
    }
    else if (self.weapon == IT_ROCKET_LAUNCHER)
    {
     if (r < 5.0)
       {
        bprint (PRINT_HIGH, "Zeusbot: Ride my rocket, ");
        bprint (PRINT_HIGH, newname);
        bprint (PRINT_HIGH, "!\n");
      }
      else
      {
        bprint (PRINT_HIGH, "Zeusbot: Eat red hot rocket, ");
        bprint (PRINT_HIGH, newname);
       bprint (PRINT_HIGH, "!\n");
       }
    }
  }
  // general, non-weapon based insult
  if (r < 1)
  {
    bprint (PRINT_HIGH, "Zeusbot: Die, ");
    bprint (PRINT_HIGH, newname);
    bprint (PRINT_HIGH, "!\n");
  }
  else if (r < 2)
  {
    bprint (PRINT_HIGH, "Zeusbot: Eat me, ");
    bprint (PRINT_HIGH, newname);
    bprint (PRINT_HIGH, "!\n");
  }
  else if (r < 3)
  {
    bprint (PRINT_HIGH, "Zeusbot: Look master, fresh meat!\n");
  }
  else if (r < 4)
  {
    bprint (PRINT_HIGH, "Zeusbot: You want some of me, ");
    bprint (PRINT_HIGH, newname);
    bprint (PRINT_HIGH, "?!?\n");
  }
  else if (r < 5)
  {
    bprint (PRINT_HIGH, "Zeusbot: Have some of this, ");
    bprint (PRINT_HIGH, newname);
    bprint (PRINT_HIGH, "!\n");
  }
  else if (r < 6)
  {
    bprint (PRINT_HIGH, "Zeusbot: Not in my game, ");
    bprint (PRINT_HIGH, newname);
    bprint (PRINT_HIGH, "!\n");
  }
  else if (r < 7)
  {
    bprint (PRINT_HIGH, "Zeusbot: Think again, ");
    bprint (PRINT_HIGH, newname);
    bprint (PRINT_HIGH, "!\n");
  }
  else if (r < 8)
  {
    bprint (PRINT_HIGH, "Zeusbot: Wait right there, ");
    bprint (PRINT_HIGH, newname);
    bprint (PRINT_HIGH, "!\n");
  }
  else if (r < 9)
  {
    bprint (PRINT_HIGH, "Zeusbot: Tell me how this tastes, ");
    bprint (PRINT_HIGH, newname);
    bprint (PRINT_HIGH, "!\n");
  }
  else
  {
    bprint (PRINT_HIGH, "Zeusbot: Oh?  You want some too, ");
    bprint (PRINT_HIGH, newname);
    bprint (PRINT_HIGH, "!?!\n");
  }
};

/*
======================
ZEUS_ReactionTime
======================
*/
float (entity ent) ZEUS_ReactionTime =
{
  local   float   r_time;

  // skill 0, 0.4 - 0.9 second reaction time
  if (self.ZEUS_skill == 0)
    r_time = random () * 0.5 + 0.4;
  // skill 1, 0.3 - 0.6 second reaction time
  if (self.ZEUS_skill == 1)
    r_time = random () * 0.3 + 0.3;
  // skill 2, 0.2 - 0.4 second reaction time
  if (self.ZEUS_skill == 2)
    r_time = random () * 0.2 + 0.2;
  // skill 3, 0.0 - 0.2 second reaction time
  if (self.ZEUS_skill == 1)
    r_time = random () * 0.2;

  if (self.oldenemy == ent)
  {
    if ((self.search_time > time) && (self.movetarget.origin == self.ZEUS_last_enemy_loc))
    {
      r_time = 0;
    }
    else
      r_time = r_time * 0.75;
  }
  return r_time;
};

/*
======================
ZEUS_FoundTarget
======================
*/

void() ZEUS_FoundTarget =
{
  local float   f_dist;
  local string  s_dist;
  local float   r;

  ZEUS_EntityOrigin (self.goalentity);
  f_dist = vlen (entity_org - self.origin);
  s_dist = ftos (f_dist);

  self.show_hostile = time + 1;		// wake up other monsters

  r = random ();

  ZEUS_SightComment ();
  ZEUS_SightSound ();

  ZEUS_SetThink (self.th_run);

  ZEUS_EntityOrigin (self.goalentity);
  self.ideal_yaw = vectoyaw (entity_org - self.origin);
};

/*
======================
ZEUS_UR_oldest_ent

returns self's oldest unreachable entity, based on ZEUS_UR_oldest
======================
*/

entity () ZEUS_UR_oldest_ent =
{
  if ((self.ZEUS_UR_oldest == 1) || (self.ZEUS_UR_oldest == 0))
    return self.ZEUS_UR_item_1;
  else if (self.ZEUS_UR_oldest == 2)
    return self.ZEUS_UR_item_2;
  else if (self.ZEUS_UR_oldest == 3)
    return self.ZEUS_UR_item_3;
  else
    ZEUS_Msg ("ERROR: ZEUS_UR_oldest > 3!\n");
};

/*
======================
ZEUS_GetOldest

returns self's oldest unreachable entity, based on ZEUS_UR_oldest
======================
*/

entity () ZEUS_GetOldest =
{
  if ((self.ZEUS_UR_oldest == 1) || (self.ZEUS_UR_oldest == 0))
    return self.ZEUS_UR_item_1;
  else if (self.ZEUS_UR_oldest == 2)
    return self.ZEUS_UR_item_2;
  else if (self.ZEUS_UR_oldest == 3)
    return self.ZEUS_UR_item_3;
  else
    ZEUS_Msg ("ERROR: ZEUS_UR_oldest > 3!\n");
};

/*
======================
ZEUS_GetOldestYaw

returns self's oldest unreachable entity, based on ZEUS_UR_oldest
======================
*/

float () ZEUS_GetOldestYaw =
{
  if ((self.ZEUS_UR_oldest == 1) || (self.ZEUS_UR_oldest == 0))
    return self.ZEUS_UR_yaw_1;
  else if (self.ZEUS_UR_oldest == 2)
    return self.ZEUS_UR_yaw_2;
  else if (self.ZEUS_UR_oldest == 3)
    return self.ZEUS_UR_yaw_3;
  else
    ZEUS_Msg ("ERROR: ZEUS_UR_oldest > 3!\n");
};

/*
======================
ZEUS_GetOldestLoc

returns self's oldest unreachable entity's Loc
======================
*/

vector () ZEUS_GetOldestLoc =
{
  if ((self.ZEUS_UR_oldest == 1) || (self.ZEUS_UR_oldest == 0))
    return self.ZEUS_UR_loc_1;
  else if (self.ZEUS_UR_oldest == 2)
    return self.ZEUS_UR_loc_2;
  else if (self.ZEUS_UR_oldest == 3)
    return self.ZEUS_UR_loc_3;
  else
    ZEUS_Msg ("ERROR: ZEUS_UR_oldest > 3!\n");
};

/*
======================
ZEUS_SetOldest

returns self's oldest unreachable entity, based on ZEUS_UR_oldest
======================
*/

void (entity ent) ZEUS_SetOldest =
{
  if ((self.ZEUS_UR_oldest == 1) || (self.ZEUS_UR_oldest == 0))
    self.ZEUS_UR_item_1 = ent;
  else if (self.ZEUS_UR_oldest == 2)
    self.ZEUS_UR_item_2 = ent;
  else if (self.ZEUS_UR_oldest == 3)
    self.ZEUS_UR_item_3 = ent;
  else
    ZEUS_Msg ("ERROR: ZEUS_UR_oldest > 3!\n");

  self.ZEUS_UR_oldest = self.ZEUS_UR_oldest + 1;
  if (self.ZEUS_UR_oldest > 3) self.ZEUS_UR_oldest = 1;
};

/*
======================
ZEUS_GetURYaw

returns the last yaw to UR_item matching ent to world
======================
*/

float (entity ent) ZEUS_GetURYaw =
{
  if (ent == self.ZEUS_UR_item_1)
    return self.ZEUS_UR_yaw_1;
  else if (ent == self.ZEUS_UR_item_2)
    return self.ZEUS_UR_yaw_2;
  else if (ent == self.ZEUS_UR_item_3)
    return self.ZEUS_UR_yaw_3;
  else
    ZEUS_Msgln ("ERROR: no matching UR_item!");
};

/*
======================
ZEUS_GetURLoc

returns the last location of the UR_item matching ent to world
======================
*/

vector (entity ent) ZEUS_GetURLoc =
{
  if (ent == self.ZEUS_UR_item_1)
    return self.ZEUS_UR_loc_1;
  else if (ent == self.ZEUS_UR_item_2)
    return self.ZEUS_UR_loc_2;
  else if (ent == self.ZEUS_UR_item_3)
    return self.ZEUS_UR_loc_3;
  else
    ZEUS_Msgln ("ERROR: no matching UR_item!");
};

/*
======================
ZEUS_SetURYaw

sets the last yaw to UR_item matching ent to world
======================
*/

void (entity ent, float yaw) ZEUS_SetURYaw =
{
  if (ent == self.ZEUS_UR_item_1)
    self.ZEUS_UR_yaw_1 = yaw;
  else if (ent == self.ZEUS_UR_item_2)
    self.ZEUS_UR_yaw_2 = yaw;
  else if (ent == self.ZEUS_UR_item_3)
    self.ZEUS_UR_yaw_3 = yaw;
  else
    ZEUS_Msgln ("ERROR: no matching UR_item!");
};

/*
======================
ZEUS_SetURLoc

sets the last location of the UR_item matching ent to world
======================
*/

void (entity ent, vector loc) ZEUS_SetURLoc =
{
  if (ent == self.ZEUS_UR_item_1)
    self.ZEUS_UR_loc_1 = loc;
  else if (ent == self.ZEUS_UR_item_2)
    self.ZEUS_UR_loc_2 = loc;
  else if (ent == self.ZEUS_UR_item_3)
    self.ZEUS_UR_loc_3 = loc;
  else
    ZEUS_Msgln ("ERROR: no matching UR_item!");
};

/*
======================
ZEUS_IsURItem

returns false if the item is in the bot's list of unreachable items, true if it is
======================
*/

float (entity ent) ZEUS_IsURItem =
{
  if ((ent != self.ZEUS_UR_item_1) && (ent != self.ZEUS_UR_item_2) && (ent != self.ZEUS_UR_item_3))
  {
    return false;
  }
  else
    return true;
};

/*
======================
ZEUS_ResetURitem

resets the UR_item matching ent to world
======================
*/

void (entity ent) ZEUS_ResetURitem =
{
  if (ent == self.ZEUS_UR_item_1)
  {
    self.ZEUS_UR_item_1 = world;
    self.ZEUS_UR_oldest = 1;
  }
  else if (ent == self.ZEUS_UR_item_2)
  {
    self.ZEUS_UR_item_2 = world;
    self.ZEUS_UR_oldest = 2;
  }
  else if (ent == self.ZEUS_UR_item_3)
  {
    self.ZEUS_UR_item_3 = world;
    self.ZEUS_UR_oldest = 3;
  }
  else
    ZEUS_Msg ("ERROR: No matching UR_item!\n");
};

/*
======================
ZEUS_SetOldestYaw

returns self's oldest unreachable entity, based on ZEUS_UR_oldest
======================
*/

void (float yaw) ZEUS_SetOldestYaw =
{
  if ((self.ZEUS_UR_oldest == 1) || (self.ZEUS_UR_oldest == 0))
    self.ZEUS_UR_yaw_1 = yaw;
  else if (self.ZEUS_UR_oldest == 2)
    self.ZEUS_UR_yaw_2 = yaw;
  else if (self.ZEUS_UR_oldest == 3)
    self.ZEUS_UR_yaw_3 = yaw;
  else
    ZEUS_Msg ("ERROR: ZEUS_UR_oldest > 3!\n");
};

/*
======================
ZEUS_SetOldestLoc

returns self's oldest unreachable entity, based on ZEUS_UR_oldest
======================
*/

void (vector loc) ZEUS_SetOldestLoc =
{
  if ((self.ZEUS_UR_oldest == 1) || (self.ZEUS_UR_oldest == 0))
    self.ZEUS_UR_loc_1 = loc;
  else if (self.ZEUS_UR_oldest == 2)
    self.ZEUS_UR_loc_2 = loc;
  else if (self.ZEUS_UR_oldest == 3)
    self.ZEUS_UR_loc_3 = loc;
  else
    ZEUS_Msg ("ERROR: ZEUS_UR_oldest > 3!\n");
};

/*
======================
ZEUS_MakeUnreachable
======================
*/

void (entity item, string caller) ZEUS_MakeUnreachable =
{
  local   vector  ang, vec;

  // movetarget is always left reachable, since it moves

  if (item == self.movetarget)
    return;

  ZEUS_EntityOrigin (item);
  vec = normalize (entity_org - self.origin);
  ang = vectoangles (vec);

  // if not already in list, then add
  if (!ZEUS_IsURItem (item))
  {
    ZEUS_SetOldest (item);
    ZEUS_SetOldestLoc (self.origin);
    ZEUS_SetOldestYaw (ang_y);
  }
  else
  {
    ZEUS_SetURLoc (item, self.origin);
    ZEUS_SetURYaw (item, ang_y);
  }

/*
  bprint (PRINT_HIGH, caller);
  bprint (PRINT_HIGH, ": Item ");
  bprint (PRINT_HIGH, item.classname);
  bprint (PRINT_HIGH, " unreachable.\n");
*/
};

/*
======================
ZEUS_PathClear

throw out vectors from center and corners of bots bounding box
and make sure there is a hole big enough for the bot to fit through
======================
*/

float (entity item) ZEUS_PathClear =
{
  local   vector  org, end, vec, ang;
  local   float   dist, blocked_count;

  if (item == self)
    return true;

  org = self.origin;
  ZEUS_EntityOrigin (item);
  end = entity_org;
  vec = end - org;    // vector pointing to item from bot
  dist = vlen (vec);  // distance to item from bot

  ang = vectoangles (vec);
  makevectors (ang);    // get v_forward, v_right, and v_up in dir of item

  blocked_count = 0;

  // trace from upper right corner of bot's bounding box
  vec = '16 0 32'; //v_up * 24 + v_right * 8;
  traceline (org + vec, end + vec, true, self);
  if (trace_fraction < 1.0)
    blocked_count = blocked_count + 1;

  //upper left of bounding box
  vec = '-16 0 32'; v_up * 24 - v_right * 8;
  traceline (org + vec, end + vec, true, self);
  if (trace_fraction < 1.0)
    blocked_count = blocked_count + 1;

  // trace from lower right corner
  vec = '16 0 -24'; v_right * 8 + v_up * 12;
  traceline (org + vec, end + vec, true, self);
  if (trace_fraction < 1.0)
    blocked_count = blocked_count + 1;

  // trace from lower right corner
  vec = '-16 0 -24'; v_right * -8 - v_up * 12;
  traceline (org + vec, end + vec, true, self);
  if (trace_fraction < 1.0)
    blocked_count = blocked_count + 1;

  if (blocked_count > 2)
  {
    ZEUS_MakeUnreachable (item, "PathClear");

    return false;
  }
  else
    return true;
};

/*
======================
ZEUS_CheckPitch

returns false if the pitch to object is > 45 or < 315 degrees
======================
*/

float (entity item) ZEUS_CheckPitch=
{
  local   vector  vec, ang;
  local   float   dist;

  if ((item == self) || (item.classname == "trigger_teleport") ||
      (item.classname == "func_button") || (item.classname == "plat"))
    return true;

  // if the angle to the item is >45 degrees or > 315 degrees, exclude it
  // because it is probably unreachable from current position
  ZEUS_EntityOrigin (item);
  vec = vectoangles (entity_org - self.origin);
  dist = vlen (entity_org - self.origin);
  if (((vec_x < 315) && (vec_x > 45)) || ((vec_x < 340) && (vec_x > 20) && (dist > 400)))
  {
    // set flags so Zeusbot will not go after item again from this spot
    if (item != self.movetarget)
    {
      ZEUS_MakeUnreachable (item, "CheckPitch");
    }

    return false;
  }

  return true;
};

/*
======================
ZEUS_ShowURs
======================
*/

void () ZEUS_ShowURs =
{
  bprint (PRINT_HIGH, "UR_1 = ");
  bprint (PRINT_HIGH, self.ZEUS_UR_item_1.classname);
  bprint (PRINT_HIGH, ", yaw = ");
  temp_text = ftos (self.ZEUS_UR_yaw_1);
  bprint (PRINT_HIGH, temp_text);
  bprint (PRINT_HIGH, "\n");
  bprint (PRINT_HIGH, "UR_2 = ");
  bprint (PRINT_HIGH, self.ZEUS_UR_item_2.classname);
  bprint (PRINT_HIGH, ", yaw = ");
  temp_text = ftos (self.ZEUS_UR_yaw_2);
  bprint (PRINT_HIGH, temp_text);
  bprint (PRINT_HIGH, "\n");
  bprint (PRINT_HIGH, "UR_3 = ");
  bprint (PRINT_HIGH, self.ZEUS_UR_item_3.classname);
  bprint (PRINT_HIGH, ", yaw = ");
  temp_text = ftos (self.ZEUS_UR_yaw_3);
  bprint (PRINT_HIGH, temp_text);
  bprint (PRINT_HIGH, "\n");
};

/*
======================
ZEUS_IsReachable

called to determine if an item is still unreachable -- never used to initially set an item
as unreachable
======================
*/

float (entity item) ZEUS_IsReachable =
{
  local   vector  dir, ang, lastloc;
  local   float   yaw_diff, adj_yaw, dist, lastangle;
  local   entity  temp;

  if (item == self) return true;

  // check to see if item is one of those marked unreachable
  if (!ZEUS_IsURItem (item))
    return;

  ZEUS_EntityOrigin (item);
  dir = entity_org - self.origin;
  ang = vectoangles (dir);

  lastangle = ZEUS_GetURYaw (item);
  lastloc = ZEUS_GetURLoc (item);
  dist = vlen (lastloc - self.origin);

  adj_yaw = lastangle - ang_y;

  if (lastangle > ang_y)
  {
    if (adj_yaw > 180)
      adj_yaw = adj_yaw - 360;
  }
  else
  {
    if (adj_yaw < -180)
      adj_yaw = adj_yaw + 360;
  }

  if (((adj_yaw > 90) || (dist > ZEUS_item_retry_dist)) &&
      ((ZEUS_DistClear (item)) && (ZEUS_CheckPitch (item))))
  {
    if (adj_yaw > 90)
    {
      ZEUS_Msg ("Item1 ");
      ZEUS_Msg (item.classname);
      ZEUS_Msg (" now reachable - yaw.\n");
    }
    else
    {
      ZEUS_Msg ("Item1 ");
      ZEUS_Msg (item.classname);
      ZEUS_Msg (" now reachable - dist.\n");
    }

    ZEUS_ResetURitem (item);
  }
  else
  {
    ZEUS_Msg ("Item ");
    ZEUS_Msg (item.classname);
    ZEUS_Msg (" still unreachable.\n");
  }
};

/*
======================
ZEUS_NeedItem
======================
*/

float (entity item) ZEUS_NeedItem =
{
  local   vector  org, end;
  local   float   need_it;

  if (item == world) return false;

  if (fabs (item.origin_z - self.origin_z) > 24)
    return false;

  need_it = false;

  if (item.classname == "backpack")
  {
    need_it = true;
  }
  else if (item.classname == "item_health")
  {
	if ((item.spawnflags & H_MEGA) && (self.health < 250))
	  need_it = true;
	else if (self.health < 90)
      need_it = true;
    else
      return false;
  }
    else if (item.classname == "item_shells")
  {
    if (self.ammo_shells <= 80)
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "item_spikes")
  {
    if (self.ammo_nails <= 175)
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "item_rockets")
  {
    if (self.ammo_rockets <= 95)
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "item_armor1")
  {
    if (self.armortype * self.armorvalue >= 30)
      return false;
    else
      need_it = true;
  }
  else if (item.classname == "item_armor2")
  {
    if (self.armortype * self.armorvalue >= 90)
      return false;
    else
      need_it = true;
  }
  else if (item.classname == "item_armorInv")
  {
    if (self.armortype * self.armorvalue >= 160)
      return false;
    else
      need_it = true;
  }
  else if (item.classname == "weapon_nailgun")
  {
    if (!(self.items & IT_NAILGUN) && (self.ammo_nails <= 170))
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "weapon_supernailgun")
  {
    if (!(self.items & IT_SUPER_NAILGUN) && (self.ammo_nails <= 170))
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "weapon_supershotgun")
  {
    if (!(self.items & IT_SUPER_SHOTGUN) && (self.ammo_shells <= 95))
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "weapon_rocketlauncher")
  {
    if (!(self.items & IT_ROCKET_LAUNCHER) && (self.ammo_rockets <= 95))
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "weapon_grenadelauncher")
  {
    if (!(self.items & IT_GRENADE_LAUNCHER) && (self.ammo_rockets <= 95))
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "weapon_lightning")
  {
    if (!(self.items & IT_LIGHTNING) && (self.ammo_cells <= 85))
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "item_cells")
  {
    if (self.ammo_cells <= 94)
      need_it = true;
    else
      return false;
  }
  else if ((item.classname == "func_button") || (item.classname == "door"))
  {
    if ((item.health <= 0) && (self.ZEUS_roam) && (random () < 0.025) && (self.pausetime <= time))
      need_it = true;
    else if ((self.goalentity == item) && ((item.state == STATE_BOTTOM) || (item.state == STATE_DOWN)))
      need_it = true;
    else
      return false;
  }
  else if ((item.classname == "trigger_teleport") && (self.ZEUS_path == world))
  {
    if (((self.goalentity.teleport_time >= time - 5) && (!ZEUS_visible (self.goalentity))) ||
       ((self.ZEUS_roam) && ((random () < 0.05) || (self.goalentity == item))))
      need_it = true;
    else
      return false;
  }
  else if (item.classname == "plat")
  {
    if ((item.state == STATE_BOTTOM))
    {
      if ((self.goalentity == item) ||
          (vlen (self.bot_owner.origin - self.origin) > 24) ||
          ((self.ZEUS_roam) && (random () < 0.05)))
        need_it = true;
      else
        return false;
    }
  }
  else if (item.classname == "item_artifact_super_damage")
  {
    if (self.items & IT_QUAD)
      return false;
    else
      need_it = true;
  }
  else if (item.classname == "item_artifact_invulnerability")
  {
    if (self.items & IT_INVULNERABILITY)
      return false;
    else
      need_it = true;
  }
  else if (item.classname == "item_artifact_invisibility")
  {
    if (self.items & IT_INVISIBILITY)
      return false;
    else
      need_it = true;
  }
  else
    return false;

  if ((need_it) && (ZEUS_visible (item)) && (ZEUS_PathClear (item)))
      return true;

  return false;
};

/*
======================
ZEUS_WeaponWeight
======================
*/

float (float weap) ZEUS_WeaponWeight =
{
  local   float  weight;

  if (weap == IT_LIGHTNING)
    weight = 900;
  else if (weap == IT_ROCKET_LAUNCHER)
    weight = 1000;
  else if (weap == IT_GRENADE_LAUNCHER)
    weight = 800;
  else if (weap == IT_SUPER_NAILGUN)
    weight = 700;
  else if (weap == IT_NAILGUN)
    weight = 400;
  else if (weap == IT_AXE)
    weight = 75;
  else if (weap == IT_SHOTGUN)
    weight = 300;
  else if (weap == IT_SUPER_SHOTGUN)
    weight = 500;

  return weight;
};

/*
======================
ZEUS_WeaponCompare

Determines if the bot has a weapon good enough to confront and enemy
======================
*/



/*
======================
ZEUS_FindTarget
======================
*/

float () ZEUS_FindTarget =
{
  local entity   head, selected, tele;
  local entity   item;
  local float    dist, lastd, selected_item, selected_enemy, is_enemy;
  local float    item_dist, item_lastd, temp, pc;

//  Debug_Msg ("goal = ");
//  Debug_Msgln (self.goalentity.classname);

  self.ZEUS_findtarget_skip = self.ZEUS_findtarget_skip + 1;
  if (self.ZEUS_findtarget_skip < 2)
    return false;

  self.ZEUS_findtarget_skip = 0;

  dist = 750;
  item_dist = 750;
  selected = world;
  item = world;
  selected_item = false;
  selected_enemy = false;

  head = findradius(self.origin, dist);

  while(head)
  {
    if (head.netname == "" && head.classname != "backpack")
      head = head.chain;
    else
    {
    is_enemy = false;

    ZEUS_EntityOrigin (head);

    pc = pointcontents (head.origin);
    if ((pc && CONTENT_LAVA) && (pc != CONTENT_SLIME))
    {
    // search for enemy, any enemy found will override any trigger found
    if ((head.bot_owner != self.bot_owner) && (head != self.bot_owner) &&
       !(head.flags & FL_NOTARGET))
    {
      if (((teamplay) &&  (head.team != self.bot_owner.team)) || (!teamplay))
      {
        if ((head.health > 0) && (head != self) && (head.classname != "trigger_once"))
        {
          if ((head.modelindex != modelindex_eyes) || ((head.modelindex == modelindex_eyes) &&
             (self.dmg_inflictor == head)))
          {
            is_enemy = true;

            if ((ZEUS_visible (head)))
            {
              lastd = vlen (self.origin - entity_org);
              if (lastd < dist)
              {
                if (head.classname == "monster_zombie")
                {
                  if ((self.items & IT_GRENADE_LAUNCHER) || (self.items & IT_ROCKET_LAUNCHER))
                  {
                    selected_enemy = true;
                    selected = head;
                    dist = lastd;
                  }
                }
                else if ((head.classname == "door") || (head.classname == "func_button"))
                {
                  if (random () < 0.1)
                  {
                    selected_enemy = true;
                    selected = head;
                    dist = lastd;
                  }
                }
                else
                {
                  selected_enemy = true;
                  selected = head;
                  dist = lastd;
                }
              }
            }
          }
        }
      }
    }
    // search for item

    // if not an enemy, check to see if it's reachability should be reset
    if (!is_enemy) ZEUS_IsReachable (head);

    // if already found enemy, skip item search
    if ((!selected_enemy) && (!ZEUS_IsURItem (head)) && (!is_enemy))
    {
      if (ZEUS_NeedItem (head) && (vlen (head.origin - entity_org) < 220))
      {
        item_lastd = vlen (self.origin - entity_org);
        if (item_lastd < item_dist)
        // for efficiency's sake, go after the closest item that is needed
        {
          selected_item = true;
          item = head;
          item_dist = item_lastd;
        }
      }
    }
    }
    head = head.chain;
    }
  }

  if ((selected_enemy) && (self.goalentity != selected))
  {
    selected_item = false;
    HUD_TargetOn (selected, self.bot_owner);
    Debug_Msg ("Selected enemy ");
    Debug_Msgln (selected.classname);
  }

  if ((selected_item) && (self.goalentity != item))
  {
    Debug_Msg ("Selected item ");
    Debug_Msgln (item.classname);
  }

  // go after item if no enemies are present
  if (selected_item)
  {
    self.goalentity = item;
    self.enemy = world;
    // search for a max of 2 seconds
    if ((item.classname == "trigger_teleport") ||
        (item.classname == "func_button") ||
        (item.classname == "plat"))
      self.search_time = time + item_dist / 200 + 2;
    else
      self.search_time = time + 2;

    // return false so that we will go into follow routine
    return false;
  }
  else if (selected_enemy) // an enemy target has been sighted
  {
    if (self.bot_attack)
    {
      // if Zeus is waiting, make him attack!
      self.bot_stay = false;

      // Get the bots reaction time based on skill level
      if (self.enemy != selected)
        self.search_time = time + ZEUS_ReactionTime (selected);

      self.goalentity = selected;
      self.enemy = selected;

      ZEUS_FoundTarget();

      // return true so that we will go into attack during nextframe (think was set my ZEUS_Foundtarget)
      return true;
    }
  }
  else
  {
    ZEUS_ResetGoalEntity ();

    return false;
  }
};

/*
======================
ZEUS_TeleportToOwner
======================
*/

void () ZEUS_TeleportToOwner =
{
  ZEUS_allstop ();
};

/*
======================
ZEUS_SetLastKnown

determines the best path to the last known location of the enemy
======================
*/
void () ZEUS_SetLastKnown =
{
  local   float   dist;
  local   vector  dir, ang, loc;
  local   entity  use_ent, enemy_node, cur_node;

  // first, try to go to the node the enemy is in
  enemy_node = ZEUS_CurrentNode (self.enemy);
  cur_node = ZEUS_CurrentNode (self);

  seek_string = self.enemy.netname;
  ZEUS_ShortestPath (cur_node, enemy_node);

  // a shortest path was found, so ZEUS_path contains it.  At this point, simply go to
  // the last known location of the enemy.  When that is reached, ChooseGoal will take
  // over and set the goal to the first path location to commence following

/*
  if (self.ZEUS_path)
  {
    setorigin (self.movetarget, self.ZEUS_path.origin);
    self.search_time = time + vlen (self.origin - enemy_node.origin) / 380 + 2;
    return;
  }
*/
  traceline (self.origin, self.ZEUS_last_enemy_loc, true, self);
  if (trace_fraction == 1.0)
  {
    // make the last known enemy location the target
    self.oldenemy = self.goalentity;
    self.goalentity = self.movetarget;
    self.search_time = time + vlen (self.origin - self.ZEUS_last_enemy_loc) / 380;
    setorigin (self.movetarget, self.ZEUS_last_enemy_loc);
//    bprint (PRINT_HIGH, "seeking last known loc.\n");

    return;
  }

  // trace 45 degrees to left, then from there to last enemy location
  dir = (self.ZEUS_last_enemy_loc - self.origin);
  dist = vlen (dir);
  dir = normalize (dir);
  ang = vectoangles (dir);

  makevectors (ang);
  // trace 22.5 degrees to the left
  loc = self.origin + v_forward * (dist - 50) - v_right * ((dist - 50) / 2);
  traceline (self.origin, loc, true, self);
  traceline (trace_endpos, self.ZEUS_last_enemy_loc, true, self);
  if (trace_fraction == 1.0)
  {
    // make the last known enemy location the target
    self.goalentity = self.movetarget;
    self.search_time = time + vlen (self.origin - self.ZEUS_last_enemy_loc) / 380;
    setorigin (self.movetarget, loc);
//    bprint (PRINT_HIGH, "seeking last known loc 22.5 left.\n");
    return;
  }

  // trace 45 degrees to the left
  loc = self.origin + v_forward * (dist - 50) - v_right * (dist - 50);
  traceline (self.origin, loc, true, self);
  traceline (trace_endpos, self.ZEUS_last_enemy_loc, true, self);
  if (trace_fraction == 1.0)
  {
    // make the last known enemy location the target
    self.goalentity = self.movetarget;
    self.search_time = time + vlen (self.origin - self.ZEUS_last_enemy_loc) / 380;
    setorigin (self.movetarget, loc);
//    bprint (PRINT_HIGH, "seeking last known loc 45 left.\n");
    return;
  }

  // trace 22.5 degrees to the right
  loc = self.origin + v_forward * (dist - 50) + v_right * ((dist - 50) / 2);
  traceline (self.origin, loc, true, self);
  traceline (trace_endpos, self.ZEUS_last_enemy_loc, true, self);
  if (trace_fraction == 1.0)
  {
    // make the last known enemy location the target
    self.goalentity = self.movetarget;
    self.search_time = time + vlen (self.origin - self.ZEUS_last_enemy_loc) / 380;
    setorigin (self.movetarget, loc);
//    bprint (PRINT_HIGH, "seeking last known loc 22.5 right.\n");
    return;
  }

  // trace 45 degrees to the right
  loc = self.origin + v_forward * (dist - 50) + v_right * (dist - 50);
  traceline (self.origin, loc, true, self);
  traceline (trace_endpos, self.ZEUS_last_enemy_loc, true, self);
  if (trace_fraction == 1.0)
  {
    // make the last known enemy location the target
    self.goalentity = self.movetarget;
    self.search_time = time + vlen (self.origin - self.ZEUS_last_enemy_loc) / 380;
//    bprint (PRINT_HIGH, "seeking last known loc 45 right.\n");
    return;
  }

};

/*
======================
ZEUS_CheckAttack
======================
*/

void (void () think_func) ZEUS_CheckAttack =
{
  ZEUS_EntityOrigin (self.goalentity);

  if (!ZEUS_visible (self.enemy) || (self.enemy.health <= 0) ||
     ((self.enemy.classname != "player") && (self.enemy.takedamage == DAMAGE_NO)))
  {
    if ((vlen (entity_org - self.origin) < 150) &&
        (self.weapon == IT_ROCKET_LAUNCHER) || (self.weapon == IT_GRENADE_LAUNCHER))
    {
      ZEUS_SetThink (think_func);
      self.ZEUS_last_enemy_loc = ZEUS_EntityOrigin (self.enemy);

      return;
    }
    else if (self.enemy.health <= 0)
    {
        ZEUS_SetThink (self.th_stand);

        ZEUS_ResetGoalEntity ();
    }
    else if (!ZEUS_CanHit (self.origin + '0 0 16', entity_org + '0 0 16'))
    {
      // make the last known enemy location the target
      ZEUS_SetLastKnown ();
      ZEUS_SetThink (self.th_follow);
    }
    else  // enemy has moved out of view
    {
      // make the last known enemy location the target
      ZEUS_SetLastKnown ();
      ZEUS_SetThink (self.th_follow);
    }

    return;
  }
  else if (vlen (entity_org - self.origin) > self.ZEUS_weapon_range)
  {
    // out of range, stop firing and run towards
    ZEUS_SetThink (self.th_run);
  }

  ZEUS_SetThink (think_func);

  // update the last known location of the enemy
  self.ZEUS_last_enemy_loc = ZEUS_EntityOrigin (self.enemy);
};

/*
=========================================================================

AI movement routines -- these routines control the bots action while in
a particular frame sequence

In most of these procedures the bot decides what it must do:
  Attack a visible enemy
  follow its owner
  jump across or down
  teleport to its owner

=========================================================================
*/

/*
==================
ZEUS_JumpVel

sets the correct forward velocity need to jump distxy units forward and
land distz units below current position
==================
*/

void (float distxy, float distz) ZEUS_JumpVel =
{
  local  float t, end_z, z, g;

  self.upward_jump_vel = 270;

  g = 760 / 2;
  z = self.origin_z + 72 - distz;
  t = 0.1;
  do
  {
    t = t + 0.05;
    end_z = self.origin_z + 24 + 270.0 * t - g * t * t;
  } while (end_z > z);

  self.forward_jump_vel = distxy * 1.1/t;
};

/*
======================
ZEUS_FindLedge
======================
*/

float (float start_dist) ZEUS_FindLedge =

{
  local   float   i;
  local   vector  org, end, above_org;
  local   float   highest, pc, t, z, end_z;
  local   float   found_ledge, ledge_height;
 // local   vector  end1, end2, end3;
  local   vector  old_f, old_r, old_u;

  if (start_dist > 220)
    return 0;

// MAKEVECTORS MUST BE CALLED BEFORE CALLING THIS ROUTINE!!!!!!!!!!
//  makevectors (self.angles);

  old_f = v_forward;
  old_r = v_right;
  old_u = v_up;
  v_forward_z = 0.0;
  v_right_z = 0.0;
  v_up = '0 0 1.0';

  // start origin is 48 units above Cujo's origin
  above_org = self.origin;// + (v_up * 48);

  ledge_height = 0.512;
  found_ledge = false;
  i = start_dist + 30;

  while ((i <= 220) && (!found_ledge))
  {
    // check the four corners of a 30x30 unit square i units in front of cujo
    // upper right corner
    org = above_org + (v_forward * (i + 15)) + (v_right * 7);
    end = org - (v_up * 1000);
    traceline (org, end, true, self);
    highest = trace_fraction;
    pc = pointcontents (trace_endpos);

    // upper left corner
    if ((trace_fraction <= ledge_height) && ((pc != CONTENT_LAVA) && (pc != CONTENT_SLIME)))
    {
//      end1 = trace_endpos;
      org = above_org + (v_forward * (i + 15)) - (v_right * 7);
      end = org - (v_up * 1000);
      traceline (org, end, true, self);
      if (trace_fraction < highest) highest = trace_fraction;
      pc = pointcontents (trace_endpos);

      if ((trace_fraction <= ledge_height) && ((pc != CONTENT_LAVA) && (pc != CONTENT_SLIME)))
      {
//        end2 = trace_endpos;
        // lower right corner
        org = above_org + (v_forward * i) + (v_right * 7);
        end = org - (v_up * 1000);
        traceline (org, end, true, self);
        if (trace_fraction < highest) highest = trace_fraction;
        pc = pointcontents (trace_endpos);

        if ((trace_fraction <= ledge_height) && ((pc != CONTENT_LAVA) && (pc != CONTENT_SLIME)))
        {
//          end3 = trace_endpos;
          // lower corner
          org = above_org + (v_forward * i) - (v_right * 7);
          end = org - (v_up * 1000);
          traceline (org, end, true, self);
          if (trace_fraction < highest) highest = trace_fraction;
          pc = pointcontents (trace_endpos);

          if ((trace_fraction <= ledge_height) && ((pc != CONTENT_LAVA) && (pc != CONTENT_SLIME)))
          {
//            end3 = trace_endpos;
            found_ledge = true;
/*
            ZEUS_SpawnMarker (end1, "progs/grenade.mdl", 0.2);
            ZEUS_SpawnMarker (end2, "progs/grenade.mdl", 0.2);
            ZEUS_SpawnMarker (end3, "progs/grenade.mdl", 0.2);
            ZEUS_SpawnMarker (trace_endpos, "progs/grenade.mdl", 0.2);
*/
          }
        }
      }
    }
    i = i + 30;
  }

  v_forward = old_f;
  v_right = old_r;
  v_up = old_u;

  if ((found_ledge) && (i < 220))
  {
    //FIXME: predict velocities based on server gravity

    highest = highest * 1000;
    // is ledge above Cujo's origin?
    if (highest < 48)
    {
      self.upward_jump_vel = 270;
      self.forward_jump_vel = i * 1.4 + 50;
    }
    else
      ZEUS_JumpVel (i, highest);

    return i;
  }
  else
  {
    self.upward_jump_vel = 0;
    self.forward_jump_vel = 420;
    
    return 0;
  }
};

/*
======================
ZEUS_JumpObstructed
======================
*/

float (float dist) ZEUS_JumpObstructed =

{
  local   vector  org, end;
  local   float   pc, clear;

  // CALL MAKEVECTORS BEFORE CALLING THIS ROUTINE!!!!
//  makevectors (self.angles);
  org = self.origin;
  end = self.origin + (v_forward * dist);

  clear = true;

  traceline (org + v_up * 32 - v_right * 16, end + v_up * 32 - v_right * 16, true, self);
  if (trace_fraction < 1.0)
     clear = false;
  traceline (org + v_up * 32 + v_right * 16, end + v_up * 32 + v_right * 16, true, self);
  if (trace_fraction < 1.0)
     clear = false;
  traceline (org - v_up * 24 - v_right * 16, end - v_up * 24 - v_right * 16, true, self);
  if (trace_fraction < 1.0)
     clear = false;
  traceline (org - v_up * 24 + v_right * 16, end - v_up * 24 + v_right * 16, true, self);
  if (trace_fraction < 1.0)
     clear = false;

  if (!clear)
  {
    ZEUS_allstop ();
    return true;
  }
  else
  {
    pc = pointcontents (trace_endpos);
    if ((pc == CONTENT_LAVA) || (pc == CONTENT_SLIME))
      return true;

    org = end;
    end = end -v_up * 256;

    traceline (org, end, true, self);
    if (trace_fraction == 1.0)
      return true;

    pc = pointcontents (trace_endpos);
    if ((pc == CONTENT_LAVA) || (pc == CONTENT_SLIME))
      return true;
    else
      return false;
  }
};

/*
======================
ZEUS_CheckJumpUp
======================
*/

void() ZEUS_CheckJumpUp =
{
  local   vector  start, end;
  local   vector  dir, org;
  local   float   pc, pc2;

  // use trace_line to find obstacles on floor
  org = self.origin + v_forward * 32 + v_up * 32;
  pc = pointcontents (org);
  traceline (org, org - '0 0 64', true, self);
  pc2 = pointcontents (trace_endpos);

  // was 0.8
  if ((trace_fraction < 1.0) && (pc == CONTENT_EMPTY) && (pc2 == CONTENT_SOLID))
  {
    self.velocity_z = 150 + (1.0 - trace_fraction) * 300;
    if (self.flags & FL_ONGROUND) setorigin (self, self.origin + '0 0 1');
    self.flags = self.flags | FL_WATERJUMP;
  }
};

/*
======================
ZEUS_JumpAI
======================
*/

float () ZEUS_JumpAI =
{
  local   vector  dir, org, end;
  local   float   dist, pc, i, pct;

//  return;

  if (!(self.flags & FL_ONGROUND) || (self.ZEUS_waterlevel > 1)) return false;

  // get vectors!
  makevectors (self.angles);

  // check to make sure there's no wall in front, or we could be
  // tracing for a jump outside the map!
  traceline (self.origin, self.origin + v_forward * 32, true, self);
  if (trace_fraction != 1.0)
    return false;

  // make sure there's not a small barrier at the feet preventing a jump from going
  // forward
  org = self.origin - v_forward * 32 - v_up;
  traceline (org, org - '0 0 24', true, self);
  if (trace_fraction != 1.0) return false;

  org = self.origin;
  end = ZEUS_EntityOrigin (self.goalentity);

  if (org_z - end_z > 24)
  {
    dist = ZEUS_CheckWater (32);
    if (!dist)
      dist = ZEUS_CheckGap (32);

    pc = water_type;
    if ((pc != CONTENT_LAVA) && (pc != CONTENT_SLIME))
      pc = pointcontents (entity_org);
    pc = CONTENT_SOLID;

    if ((dist) && (pc != CONTENT_LAVA) && (pc != CONTENT_SLIME))
    {
      self.upward_jump_vel = 270;
      end = entity_org - self.origin;
      end_z = 0;
      dist = vlen (end);
      if (dist > 300) dist = 300;
      self.forward_jump_vel = dist * 1.4 + 50;

      ZEUS_JumpVel (dist, org_z - end_z);

      if (self.deadflag == DEAD_NO) ZEUS_jump1 ();

      return true;
    }
    else
      return false;
  }
/*
  else
  {
    // turn ZEUS to _exactly_ the direction of his goal entity
    dir = entity_org - self.origin;
    dir = normalize (dir);

    dist = ZEUS_CheckWater (64);

    if (dist <= 0)
        dist = ZEUS_CheckGap (64);

    if ((dist > 0) && (dist < 150) && (vlen (entity_org - self.origin) >= dist))
    {
      dist = ZEUS_FindLedge (64);

      if ((!ZEUS_JumpObstructed (dist + 32)) && (dist > 0) && (dist < 240))
      {
        if (self.deadflag == DEAD_NO) ZEUS_jump1 ();

        return true;
      }
    }
  }
*/
  else if ((self.ZEUS_roam) && (random () > 0.25))
  {
    dist = ZEUS_CheckWater (32);

    pc = water_type;
    if ((pc != CONTENT_LAVA) && (pc != CONTENT_SLIME))
      pc = pointcontents (entity_org);

    if ((dist) && (pc != CONTENT_SLIME) && (pc != CONTENT_LAVA))
    {
      self.upward_jump_vel = 270;
      end = entity_org - self.origin;
      end_z = 0;
      dist = vlen (end);
      if (dist > 300) dist = 300;
      self.forward_jump_vel = dist * 1.4 + 50;

      ZEUS_JumpVel (dist, 0);

      if (self.deadflag == DEAD_NO) ZEUS_jump1 ();

      return true;
    }
    else
      return false;
  }

  return false;
};

/*
======================
ZEUS_ai_forward
======================
*/

void (float dist) ZEUS_ai_forward =
{
  walkmove (self.angles_y, dist);
};

/*
======================
ZEUS_ai_back
======================
*/

void (float dist) ZEUS_ai_back =
{
  walkmove ( (self.angles_y + 180), dist);
};

/*
======================
ZEUS_ai_face
======================
*/

void () ZEUS_ai_face =
{
  // if not roaming, keep the movetarget with the bot
  if (!self.ZEUS_roam) setorigin (self.movetarget, self.origin);

  if ((self.ZEUS_stuck) && ((self.cnt != FRAME_NAILATTACK) &&
     (self.cnt != FRAME_ROCKETATTACK) && (self.cnt != FRAME_THUNDERATTACK) &&
     (self.cnt != FRAME_SHOTGUNATTACK)))
  {
    self.ideal_yaw = self.ideal_yaw + self.ZEUS_stuck_dir;
  }
  else
  {
    ZEUS_EntityOrigin (self.goalentity);
    self.ideal_yaw = vectoyaw (entity_org - self.origin);
  }
  ZEUS_ChangeYaw ();
};

/*
======================
ZEUS_ai_stand
======================
*/

void () ZEUS_ai_stand =
{
  local   float   dist;

  // stop his ass!
  ZEUS_allstop ();

  // next_think will be set to th_run if an enemy is sighted, so a return
  // will exit and allow the run to begin at next frame
  if (ZEUS_FindTarget ()) return;

  if (self.pausetime > time) return;

  ZEUS_EntityOrigin (self.goalentity);
  dist = vlen (self.origin - entity_org);

  // needs air?
  if ((self.ZEUS_waterlevel == 3) && (self.air_finished < time + 3))
    ZEUS_ai_swim ();
  // if goal is movetarget and target is not optimal range away, go to it
  else if ((self.goalentity == self.movetarget) &&
       ((dist > ZEUS_roam_goal_dist) &&  (self.bot_stay == false)))
  {
    ZEUS_SetThink (self.th_follow);
    return;
  }
  // goal is > ZEUS_optimal_goal_dist units and bot is not staying
  else if (((self.goalentity == self.bot_owner) || (self.goalentity == self.bot_owner.movetarget))
       && (self.bot_owner != self.movetarget) &&
       ((dist > ZEUS_optimal_goal_dist) || ((dist < 65)) &&  (self.bot_stay == false)))
  {
    ZEUS_SetThink (self.th_follow);
    return;
  }
  // goal is not owner or movetarget (must be item) and bot is not staying
  else if (((self.goalentity != self.bot_owner) && (self.goalentity != self.bot_owner.movetarget))
           && (self.goalentity != self.movetarget) &&
           (self.bot_stay == false))
  {
    // A goal other than movetarget or owner is active, so go to goal
    ZEUS_SetThink (self.th_follow);
    //self.th_follow ();
    return;
  }
  else if ((vlen (self.origin - self.bot_owner.origin) > teleport_dist) && (!self.bot_stay))
  {
    ZEUS_TeleportToOwner ();
  }
};

/*
======================
ZEUS_ordinance_search
======================
*/

entity () ZEUS_ordinance_search =
{
  local   entity  ord, head;
  local   float   dist, last_dist;

  if (self.ZEUS_skill == 0)
    return world;

  if (self.ZEUS_skill == 3)
    dist = 400;
  else
    dist = 200;
  ord = world;
  head = findradius(self.origin, dist);

  while(head)
  {
    if ((head.classname == "missile") || (head.classname == "grenade"))
    {
      ZEUS_EntityOrigin (head);
      last_dist = vlen (self.origin - entity_org);
      if (last_dist < dist)
      {
        ord = head;
        dist = last_dist;
      }
    }

    head = head.chain;
  }

  return ord;
};

/*
======================
ZEUS_avoid_ordinance
======================
*/

void (entity ord) ZEUS_avoid_ordinance =
{
  local   vector  dir, impact_point;
  local   float   time_to_impact, dist, proj_speed;

  // if it's a stationary grenade, move away from it
  if (vlen (ord.velocity) == 0)
  {
    dir = normalize (self.origin - ord.origin);
    dir_z = 0;
    setorigin (self.movetarget, self.origin + dir * 200);

    ZEUS_strafetogoal (self.movetarget);
  }
  // target is moving, move perpendicular to its velocity vector
  else if (self.ZEUS_skill > 1)
  {
    dist = vlen (self.origin - ord.origin);
    proj_speed = vlen (ord.velocity);
    time_to_impact = dist / proj_speed;
    impact_point = ord.origin + (ord.velocity * time_to_impact);

    // move away from impact point
    dir = normalize (self.origin - impact_point);
    setorigin (self.movetarget, self.origin + dir * 200);

    ZEUS_strafetogoal (self.movetarget);
  }
};

/*
======================
ZEUS_combat_search
======================
*/

entity () ZEUS_combat_search =
{
  local   entity  item, head;
  local   float   dist, last_dist;

  dist = 400;
  item = world;
  head = findradius(self.origin, dist);

  while(head)
  {
    if (head.netname == "")
      head = head.chain;
    else
    {
      if ((!ZEUS_IsURItem (head)) && (ZEUS_NeedItem (head)))
      {
        ZEUS_EntityOrigin (head);
        last_dist = vlen (self.origin - entity_org);
        if (last_dist < dist)
        // for efficiency's sake, go after the closest item that is needed
        // though this requires us to search the enitre list, doh!
        {
          item = head;
          dist = last_dist;
        }
      }

      head = head.chain;
    }
  }

  return item;
};

/*
======================
ZEUS_ai_run
======================
*/

void (float dist) ZEUS_ai_run =
{
  local   string  str_temp;
  local   entity  item, ord;

  ZEUS_FrameStart ("ai_run");

  ord = ZEUS_ordinance_search ();
  item = ZEUS_combat_search ();

  // reset so for no pain sequences while running/firing run
  self.pain_finished = time + 999;

  if ((self.enemy == self.bot_owner) || (self.enemy == world) || (self.enemy.health <= 0))
  {
    ZEUS_SetThink (self.th_stand);
    ZEUS_ResetGoalEntity ();
    return;
  }

  ZEUS_ai_face ();

  if ((self.enemy.health > 0) && (ZEUS_visible (self.goalentity)) &&
      (self.search_time <= time))
  {
    //enemy is visible and alive, so save location
    ZEUS_EntityOrigin (self.goalentity);
    self.ZEUS_last_enemy_loc = entity_org;

    ZEUS_ChooseWeapon ();

    if ((vlen (entity_org - self.origin) < self.ZEUS_weapon_range) &&
        (ZEUS_CanHit (self.origin + '0 0 16', entity_org + '0 0 16')))
    {
      if (self.deadflag == DEAD_NO)
        self.th_missile ();
    }
  }
  else if ((self.goalentity.health <= 0))
  {
    ZEUS_ResetGoalEntity ();
    return;
  }
  else if (!ZEUS_visible (self.goalentity))// enemy is alive, but not visible
  {
    // make the last known enemy location the target
    ZEUS_SetLastKnown ();

    ZEUS_SetThink (self.th_follow);
  }

  if (self.ZEUS_waterlevel > 1)
    ZEUS_ai_swim ();
  else
  {
//    if (ZEUS_JumpAI ()) return;           // needs to jump to goal

    if (ord)
      ZEUS_avoid_ordinance (ord);
    else if (item)
    {
      setorigin (self.movetarget, item.origin + '0 0 24');
      ZEUS_strafetogoal (self.movetarget);
    }
    else
    ZEUS_movetogoal ();		// done in C code...
  }
};

/*
======================
ZEUS_circle_strafe
======================
*/

void () ZEUS_circle_strafe =
{
  local   vector  temp_right;
  local   float   gap, i;

  if (!(self.flags & FL_ONGROUND)) return;

  // if time expired or strafe blocked, choose a dir randomly
  // FIX ME: make this check for optimal strafe direction based on obstacles
  if ((self.search_time < time) || (!ZEUS_PathClear (self.movetarget)))
  {
    if (random () < 0.5)
      self.attack_state = AS_STRAFE_RIGHT;
    else
      self.attack_state = AS_STRAFE_LEFT;

    // strafe time of up to 1.5 seconds before opportunity to change dir
    self.search_time = time + random () * 1.0 + 1.0;
  }

  // turn towards enemy
//  ZEUS_ai_face ();

  makevectors (self.angles);

  // make CheckGap check in strafe direction, instead of out front
  temp_right = v_right;
  if (self.attack_state == AS_STRAFE_RIGHT)
  {
    v_right = v_forward * -1;
    v_forward = temp_right;
  }
  else
  {
    v_right = v_forward;
    v_forward = temp_right * -1;
  }
/*
  gap = ZEUS_CheckGap (64);
  if (gap)
  {
    // v_forward should be equal to strafe direction, not really forward
    i = ZEUS_FindLedge (64);

    if ((!ZEUS_JumpObstructed (i)) && (i > 0))
    {
      if (self.deadflag == DEAD_NO) ZEUS_jump1 ();
      return;
    }

    ZEUS_allstop ();
    self.search_time = time - 1;
    return;
  }
*/
  v_right = temp_right;

  // set to the left or right of the bot
//  if (self.flags & FL_ONGROUND)
//    self.flags = self.flags - FL_ONGROUND;

  if ((self.attack_state == AS_STRAFE_LEFT))
  {
//    self.velocity = -1 * v_right * 440;
    setorigin (self.movetarget, self.origin - v_right * 240);
  }
  else
  {
//    self.velocity = v_right * 440;
    setorigin (self.movetarget, self.origin + v_right * 240);
  }

  ZEUS_strafetogoal (self.movetarget);
};

/*
======================
ZEUS_ai_run_and_shoot
======================
*/

void (float dist) ZEUS_ai_run_and_shoot =
{
  local   entity  item, ord;

  ZEUS_FrameStart ("ai_run_and_shoot");

  ord = ZEUS_ordinance_search ();
  item = ZEUS_combat_search ();

  // reset so for no pain sequences while running/firing run
  self.pain_finished = time + 999;

  ZEUS_ai_face ();

//  if (ZEUS_JumpAI ()) return;           // needs to jump to goal

  ZEUS_EntityOrigin (self.goalentity);
  dist = vlen (entity_org - self.origin);

  // keep moving while firing

  if (self.ZEUS_waterlevel > 1)
    ZEUS_ai_swim ();
  else if (ord)
    ZEUS_avoid_ordinance (ord);
  else if (item)
  {
    setorigin (self.movetarget, item.origin + '0 0 24');
    ZEUS_strafetogoal (self.movetarget);
  }
  else if (dist > self.ZEUS_weapon_range)
    ZEUS_movetogoal ();
  else if (dist < self.ZEUS_minimum_range)
  {
    makevectors (self.angles);
    traceline (self.origin, self.origin + v_forward * -256, true, self);
    if (trace_fraction < 0.5)
      ZEUS_movetogoal ();
    else if (trace_fraction < 1.0)
      ZEUS_circle_strafe ();
    else
      ZEUS_movefromgoal ();
  }
  else
  {
    // set so bot will move towards movetarget for strafe
    ZEUS_circle_strafe ();
  }
};

/*
======================
ZEUS_ai_follow
======================
*/

void (float dist) ZEUS_ai_follow =
{
  local   float   go_to_stand, distance;
  local   entity  item, ord;

  go_to_stand = false;

  // reset so for no pain sequences while running/firing run
  self.pain_finished = time + 999;

  if (ZEUS_FindTarget ()) return;

  ord = ZEUS_ordinance_search ();

  // check for platform, if on a moving platform, wait till it stops to move again
  traceline (self.origin, self.origin - v_up * 32, true, self);
  if ((trace_ent.classname == "plat") && (vlen (trace_ent.velocity) > 0))
  {
    self.pausetime = time + 1;
    ZEUS_SetThink (self.th_stand);
//    bprint (PRINT_HIGH, "waiting for platform to stop.\n");
    return;
  }

  ZEUS_EntityOrigin (self.goalentity);
  distance = vlen (self.origin - entity_org);

  // is time to search for goal over? or is path blocked
  if (((self.goalentity != self.bot_owner) && (self.goalentity != self.bot_owner.movetarget) &&
       (self.goalentity != self.movetarget)) &&
      ((self.search_time <= time) || !(ZEUS_PathClear (self.goalentity)) ||
      !(ZEUS_CheckPitch (self.goalentity))))
  {
    ZEUS_MakeUnreachable (self.goalentity, "ai_follow");

    ZEUS_ResetGoalEntity ();
    return;
  }
  // has the goal (non-owner) been reached?
  else if ((self.goalentity == self.movetarget) &&
       ((distance < ZEUS_roam_goal_dist) || (self.search_time < time) || (self.bot_stay)))
  {
    // has the movetarget been reached?  if so, it must be reset so a new
    // one can be chosen
    ZEUS_ResetGoalEntity ();
    return;
  }
  // has the owner goal been reached?
  else if ((((self.goalentity == self.bot_owner) || (self.goalentity == self.bot_owner.movetarget))
       && (self.goalentity != self.movetarget) &&
       (distance < ZEUS_optimal_goal_dist) && (distance > 65)) ||  (self.bot_stay))
    go_to_stand = true;

  // save owner's last known location
  ZEUS_EntityOrigin (self.goalentity);
  if (((self.goalentity == self.bot_owner) || (self.goalentity == self.bot_owner.movetarget))
    && (self.goalentity != self.movetarget))
    self.ZEUS_last_enemy_loc = entity_org;

  if (go_to_stand)
  {
    self.pausetime = time;
    ZEUS_SetThink (self.th_stand);

    return;
  }

  // should the bot teleport to his owner?
  if ((vlen (self.origin - self.bot_owner.origin) > teleport_dist) &&
           (!intermission_running) && (!self.bot_stay))
  {
    ZEUS_TeleportToOwner ();
  }

  if ((self.ZEUS_waterlevel > 1) && (!(self.flags & FL_ONGROUND))) // && ((distance > ZEUS_optimal_goal_dist) || (distance < 65)))
    ZEUS_ai_swim ();
  else if (ord)
    ZEUS_avoid_ordinance (ord);
  else
  {
    if (ZEUS_JumpAI ())
      return;

    if (((self.goalentity == self.bot_owner) || (self.goalentity == self.bot_owner.movetarget))&&
        (self.bot_owner != self.movetarget) && (distance < 65))
      ZEUS_movefromgoal ();
    else
      ZEUS_movetogoal ();
  }
};

/*
======================
ZEUS_CheckWaterJump

Total hack, I'm tired
======================
*/

void() ZEUS_CheckWaterJump =
{
  local   vector  start, end;
  local   vector  dir, org;
  local   float   pc;

//  ZEUS_ai_face ();
//  makevectors (self.angles);

  //determine if there is an open space at head height
  org = self.origin + v_up * 56;
  traceline (org, org + v_forward * 32, true, self);
  if (trace_fraction < 1.0)
    return;

  // use trace_line to find obstacles on floor
  org = self.origin + v_forward * 32 + v_up * 32;
  traceline (org, org - v_up * 32, true, self);

  // was 0.8
  if ((trace_fraction < 1.0))
  {
    self.velocity_z = 150 + (1.0 - trace_fraction) * 300;
    if (self.flags & FL_ONGROUND) setorigin (self, self.origin + '0 0 1');
    self.flags = self.flags | FL_WATERJUMP;
  }
};

/*
======================
ZEUS_ai_swim
======================
*/

void () ZEUS_ai_swim =
{
  local   vector  org, end, dir, ang;
  local   float   dist, tf1, tf2, tf3, tf4, tf5;
  local   float   go_for_air;

  self.ZEUS_stuck = false;
//  ZEUS_ai_face ();

  makevectors (self.angles);
  org = self.origin;
  go_for_air = false;

  ZEUS_EntityOrigin (self.goalentity);

  // check to see if air is almost up... less than 3 seconds to go
  traceline (self.origin, self.origin + '0 0 1000', true, self);

  if (self.air_finished < time + 3)
  {
    bprint (PRINT_HIGH, "going for air\n");
    traceline (self.origin, self.origin + '0 0 1000', true, self);

	if ((vlen (self.ZEUS_own_lastorg - self.origin) > 2) && ((trace_inopen) && (trace_inwater)))
	{
	  go_for_air = true;
	  dir = v_up;
	}
    else
    {
	  traceline (self.origin, self.origin + v_forward * 32, true, self);
	  if (trace_fraction == 1.0)
	    dir = v_forward;
	  else
	  {
		  traceline (self.origin, self.origin - v_forward * 32, true, self);
		  if (trace_fraction == 1.0)
	        dir = -1.0 * v_forward;
		  else
		  {
			traceline (self.origin, self.origin - v_right * 32, true, self);
			if (trace_fraction == 1.0)
  	          dir = -1.0 * v_right;
			else
			{
			  traceline (self.origin, self.origin - v_forward * 32, true, self);
			  if (trace_fraction == 1.0)
	            dir = v_right;
			}
		  }
	  }
	}
  }
  else
  {
    end = entity_org;
    dir = (end - org);
    dist = vlen (dir);
    dir = normalize (dir);

	ZEUS_ai_face ();
  }

  self.velocity = dir * 200;

  if (self.flags & FL_ONGROUND)
  {
    if (self.velocity_z < 60)
      self.velocity_z = 60;
    self.flags = self.flags - FL_ONGROUND;
  }

  ZEUS_CheckWaterJump ();

  self.ZEUS_own_lastorg = self.origin;
};

/*
======================
ZEUS_WeaponRange

Returns the maximum range for the passed entities current weapon
Used by the bot to determine what weapon to use, and what the maximum
and effective ranges of his opponents weapon is
======================
*/

float (float weap) ZEUS_WeaponRange =
{
  local   float  rng;

  if (weap == IT_LIGHTNING)
    rng = 600;
  else if (weap == IT_ROCKET_LAUNCHER)
    rng = 1000;
  else if (weap == IT_GRENADE_LAUNCHER)
    rng = 600;
  else if (weap == IT_SUPER_NAILGUN)
    rng = 1000;
  else if (weap == IT_NAILGUN)
    rng = 1000;
  else if (weap == IT_AXE)
    rng = 75;
  else if (weap == IT_SHOTGUN)
    rng = 1000;
  else if (weap == IT_SUPER_SHOTGUN)
    rng = 700;

  return rng;
};

/*
======================
ZEUS_ChooseWeapon
======================
*/

void () ZEUS_ChooseWeapon =
{
  local   float   dist;

  ZEUS_EntityOrigin (self.enemy);
  dist = vlen ((entity_org + '0 0 16')- (self.origin + '0 0 16'));

  if ((self.items & IT_GRENADE_LAUNCHER) && (self.ammo_rockets > 0) && (teamplay == 1) &&
           (dist < ZEUS_WeaponRange (IT_GRENADE_LAUNCHER)))
  {
    self.weapon = IT_GRENADE_LAUNCHER;
    self.currentammo = self.ammo_rockets;
  }
  else if ((self.items & IT_LIGHTNING) && (self.ammo_cells > 0) && (self.ZEUS_waterlevel < 2) &&
      (dist < ZEUS_WeaponRange (IT_LIGHTNING)))
  {
    self.weapon = IT_LIGHTNING;
    self.currentammo = self.ammo_cells;
  }
  else if ((self.items & IT_ROCKET_LAUNCHER) && (self.ammo_rockets > 0) &&
           (dist < ZEUS_WeaponRange (IT_ROCKET_LAUNCHER)))
  {
    self.weapon = IT_ROCKET_LAUNCHER;
    self.currentammo = self.ammo_rockets;
  }
  else if ((self.items & IT_SUPER_NAILGUN) && (self.ammo_nails > 0) &&
           (dist < ZEUS_WeaponRange (IT_SUPER_NAILGUN)))
  {
    self.weapon = IT_SUPER_NAILGUN;
    self.currentammo = self.ammo_nails;
  }
  else if ((self.items & IT_GRENADE_LAUNCHER) && (self.ammo_rockets > 0) && (dist > 100) &&
           (dist < ZEUS_WeaponRange (IT_GRENADE_LAUNCHER)))
  {
    self.weapon = IT_GRENADE_LAUNCHER;
    self.currentammo = self.ammo_rockets;
  }
  else if ((self.items & IT_SUPER_SHOTGUN) && (self.ammo_shells > 0) &&
           (dist < ZEUS_WeaponRange (IT_SUPER_SHOTGUN)))
  {
    self.weapon = IT_SUPER_SHOTGUN;
    self.currentammo = self.ammo_shells;
  }
  else if ((self.items & IT_NAILGUN) && (self.ammo_nails > 0) &&
           (dist < ZEUS_WeaponRange (IT_NAILGUN)))
  {
    self.weapon = IT_NAILGUN;
    self.currentammo = self.ammo_nails;
  }
  else if ((self.items & IT_SHOTGUN) && (self.ammo_shells > 0) &&
           (dist < ZEUS_WeaponRange (IT_SHOTGUN)))
  {
    self.weapon = IT_SHOTGUN;
    self.currentammo = self.ammo_shells;
  }
  else
  {
    self.weapon = IT_AXE;
    self.currentammo = 0;
  }

  if (self.enemy.classname == "monster_zombie")
  {
    if ((self.items & IT_GRENADE_LAUNCHER) && (self.ammo_rockets > 0) &&
             (entity_org_z - self.origin_z < 64))
    {
      self.weapon = IT_GRENADE_LAUNCHER;
      self.currentammo = self.ammo_rockets;
    }
    else if ((self.items & IT_ROCKET_LAUNCHER) && (self.ammo_rockets > 0))
    {
      self.weapon = IT_ROCKET_LAUNCHER;
      self.currentammo = self.ammo_rockets;
    }
  }
  else if (self.enemy.classname == "monster_shambler")
  {
    if ((self.items & IT_LIGHTNING) && (self.ammo_cells > 0))
    {
      self.weapon = IT_LIGHTNING;
      self.currentammo = self.ammo_cells;
    }

    if ((self.items & IT_SUPER_NAILGUN) && (self.ammo_nails > 1))
    {
      self.weapon = IT_SUPER_NAILGUN;
      self.currentammo = self.ammo_nails;
    }
    else if ((self.items & IT_NAILGUN) && (self.ammo_nails > 0))
    {
      self.weapon = IT_NAILGUN;
      self.currentammo = self.ammo_rockets;
    }
  }

  // choose appropriate weapon to shoot triggers and doors
  if ((self.enemy.classname == "door") ||
      (self.enemy.classname == "func_button"))
  {
    if (self.ammo_shells > 0)
    {
      self.weapon = IT_SHOTGUN;
      self.currentammo = self.ammo_shells;
    }
    else if ((self.ammo_nails > 0) &&
             ((self.items & IT_NAILGUN) || (self.items & IT_SUPER_NAILGUN)))
    {
      if (self.items & IT_NAILGUN)
        self.weapon = IT_NAILGUN;
      else
        self.weapon = IT_SUPER_NAILGUN;
      self.currentammo = self.ammo_nails;
    }
    else if ((self.ammo_cells > 0) && ((self.items & IT_LIGHTNING) ||
            (self.items & IT_SUPER_NAILGUN)))
    {
      self.weapon = IT_LIGHTNING;
      self.currentammo = self.ammo_cells;
    }
    else if ((self.ammo_rockets > 0) && (self.items & IT_ROCKET_LAUNCHER))
    {
      self.weapon = IT_ROCKET_LAUNCHER;
      self.currentammo = self.ammo_rockets;
    }
    else
    {
      self.weapon = IT_AXE;
      self.currentammo = 0;
    }
  }

  if (self.ZEUS_only_axe)
  {
    // hack'em, dude!
    self.weapon = IT_AXE;
    self.currentammo = 0;
  }

  if (self.weapon == IT_AXE)
  {
    self.th_run = ZEUS_axerun1;
    self.th_stand = ZEUS_axestand1;
    self.th_follow = ZEUS_axefollow1;
  }
  else
  {
    self.th_run = ZEUS_run1;
    self.th_stand = ZEUS_stand1;
    self.th_follow = ZEUS_follow1;
  }

  if (self.weapon == IT_LIGHTNING)
    self.ZEUS_optimal_range = 450;
  else if (self.weapon == IT_ROCKET_LAUNCHER)
    self.ZEUS_optimal_range = 450;
  else if (self.weapon == IT_GRENADE_LAUNCHER)
    self.ZEUS_optimal_range = 300;
  else if (self.weapon == IT_SUPER_NAILGUN)
    self.ZEUS_optimal_range = 400;
  else if (self.weapon == IT_NAILGUN)
    self.ZEUS_optimal_range = 450;
  else if (self.weapon == IT_AXE)
    self.ZEUS_optimal_range = 65;
  else if (self.weapon == IT_SHOTGUN)
    self.ZEUS_optimal_range = 600;
  else if (self.weapon == IT_SUPER_SHOTGUN)
    self.ZEUS_optimal_range = 300;

  if (self.weapon == IT_LIGHTNING)
    self.ZEUS_minimum_range = 250;
  else if (self.weapon == IT_ROCKET_LAUNCHER)
    self.ZEUS_minimum_range = 150;
  else if (self.weapon == IT_GRENADE_LAUNCHER)
    self.ZEUS_minimum_range = 150;
  else if (self.weapon == IT_SUPER_NAILGUN)
    self.ZEUS_minimum_range = 100;
  else if (self.weapon == IT_NAILGUN)
    self.ZEUS_minimum_range = 100;
  else if (self.weapon == IT_AXE)
    self.ZEUS_minimum_range = 0;
  else if (self.weapon == IT_SHOTGUN)
    self.ZEUS_minimum_range = 200;
  else if (self.weapon == IT_SUPER_SHOTGUN)
    self.ZEUS_minimum_range = 100;

 self.ZEUS_weapon_range = ZEUS_WeaponRange (self.weapon);
};

/*
======================
ZEUS_LeadTarget

calculates the correct angle to fire a weapon based on the targets current velocity
and the speed of the weapon being fired
returns the normalized vector to the target at predicted impact time
======================
*/

vector (entity targ, float prj_speed) ZEUS_LeadTarget =
{
  local   float   dist, time_to_target, err_factor;
  local   vector  lead_pos, dir;

  ZEUS_EntityOrigin (targ);

  if (vlen (self.enemy.velocity) == 0)
    return entity_org;

  // if skill 0, no target leading
  if (self.ZEUS_skill == 0)
  {
    // skill 1 = 0.1 to 1.9 error factor
    err_factor = (0.9 - random () * 1.8) + 1.0;
  }
  else if (self.ZEUS_skill == 1)
  {
    // skill 1 = 0.2 to 1.8 error factor
    err_factor = (0.8 - random () * 1.6) + 1.0;
  }
  else if (self.ZEUS_skill == 2)
  {
    // skill 2 = 0.5 to 1.50 error factor
    err_factor = (0.5 - random () * 1.0) + 1.0;
  }
  else
  {
    // skill 3 = error factor of 0.8, or no error factor
    // skill 2 = 0.75 to 1.25 error factor
    err_factor = (0.25 - random () * 0.5) + 1.0;

//    err_factor = 0.8;
  }

  // calculate distance to target
  dist = vlen ((entity_org + '0 0 16') - (self.origin + '0 0 16'));

  // find time to target's current position at prj_speed
  time_to_target = (dist / prj_speed) * err_factor;

  // find targest position at time + time_to_target
  lead_pos = entity_org + (targ.velocity * time_to_target);

  dir = normalize ((lead_pos + '0 0 16') - (self.origin + '0 0 16'));

  ZEUS_lead_pos = lead_pos;
  return dir;
};

/*
======================
ZEUS_ChanceToHit

determines the bot's likely-hood to miss when firing a weapon with
instantaneous damage (ie. shotgun, super-shotgun and lightning).

based on the skill level of the bot and the velocity of the target.
Targets moving directly away from, or directly towards the bot are
much easier to hit, while targets moving perpendicular to the bot's view
are hardest to hit (ie. strafing makes a difference)

Currently, varying the Z velocity of the target (jumping) has no
effect on the chance to hit

returns the chance to hit -- 0.8 is 80% chance, 0.9 is 90% chance, etc.
======================
*/
float (entity targ) ZEUS_ChanceToHit =
{
  local   vector  temp;
  local   float   bot_yaw_vel, targ_yaw_vel, yaw_factor, chance;

  if (targ == world) return 0;

  // get the angular velocities of the
  temp = vectoangles (self.angles);
  bot_yaw_vel = temp_y;
  temp = vectoangles (targ.velocity);
  targ_yaw_vel = temp_y;
  // if not moving, give maximum chance to hit for skill
  if (vlen (targ.velocity) < 100) targ_yaw_vel = bot_yaw_vel;

  yaw_factor = bot_yaw_vel - targ_yaw_vel;
  // keep yaw_factor between 0 and 360 degrees
  if (bot_yaw_vel > targ_yaw_vel)
  {
    if (yaw_factor > 360)
      yaw_factor = yaw_factor - 360;
  }
  else
  {
    if (yaw_factor < 0)
      yaw_factor = yaw_factor + 360;
  }

//  bprint (PRINT_HIGH, "yaw = ");
//  temp_text = ftos (yaw_factor);
//  bprint (PRINT_HIGH, temp_text);

  // get yaw factor to between 0 and 90, if > 90
  if (yaw_factor > 180) yaw_factor = yaw_factor - 180;
  if (yaw_factor > 90) yaw_factor = yaw_factor - 90;
  // flip yaw factor around
  yaw_factor = 90 - yaw_factor;

//  bprint (PRINT_HIGH, ", yaw = ");
//  temp_text = ftos (yaw_factor);
//  bprint (PRINT_HIGH, temp_text);

  // get the base yaw_factor between 0.5 and 1.0
  yaw_factor = ((yaw_factor / 2) + 45) / 90;

//  bprint (PRINT_HIGH, "yaw_factor = ");
//  temp_text = ftos (yaw_factor);
//  bprint (PRINT_HIGH, temp_text);
//  bprint (PRINT_HIGH, "\n");

  if (self.ZEUS_skill == 0)
  {
    // skill 1 = maximum 20% chance to hit the target
    //           minimum 10% chance to hit the target
    chance = yaw_factor * 0.20;
  }
  else if (self.ZEUS_skill == 1)
  {
    // skill 2 = maximum 40 % chance to hit, minimum 20% chance
    chance = yaw_factor * 0.40;
  }
  else if (self.ZEUS_skill == 2)
  {
    // skill 3 = maximum 60% chance to hit, minimum 30% chance
    chance = yaw_factor * 0.60;
  }
  else
  {
    // skill 3 = maximum 75% chance to hit, minimum 32.5% chance
    chance = yaw_factor;
  }

//  bprint (PRINT_HIGH, "chance = ");
//  temp_text = ftos (chance);
//  bprint (PRINT_HIGH, temp_text);
//  bprint (PRINT_HIGH, "\n");

  return chance;
};

/*
======================
ZEUS_MissTarget

chooses a firing location which will miss the bot's target
called when a bot fails on a chance to hit.

makevectors should be called before this routine executes!
======================
*/
vector (entity targ) ZEUS_MissTarget =
{
  local   vector  org;
  local   float   r;

  // makevectors should have already been
  org = ZEUS_EntityOrigin (targ);

  // find units to one side + 24 to clear bounding box
  r = (128 - random () * 256) + 24;
  // determine negative or positive
  if (random () < 0.5)
    r = r * -1.0;
  org = org + v_right * r;

  return org;
};

/*
======================
ZEUS_CanHit
======================
*/

float (vector start, vector end) ZEUS_CanHit =
{
  local   vector  dir;
  local   float   temp;

  if ((self.weapon == IT_ROCKET_LAUNCHER) ||
      (self.weapon == IT_SUPER_NAILGUN) ||
      (self.weapon == IT_NAILGUN))
  {
    ZEUS_LeadTarget (self.enemy, 1000);
    entity_org = ZEUS_lead_pos;
  }
  else if (self.weapon == IT_GRENADE_LAUNCHER)
  {
    ZEUS_LeadTarget (self.enemy, 600);
    entity_org = ZEUS_lead_pos;
  }
  else
   ZEUS_EntityOrigin (self.enemy);

  temp = true;

  traceline (self.origin + '0 0 16', entity_org + '0 0 16', false, self);
  if (trace_fraction != 1.0)
  {
    if ((trace_ent == self.bot_owner) || (trace_ent.bot_owner == self.bot_owner) ||
        ((teamplay) && (trace_ent.team == self.bot_owner.team)) || (trace_ent.classname == "worldspawn"))
      temp = false;

  }

  if (temp == true)
  {
    dir = normalize (entity_org - self.origin);
    dir = vectoangles (dir);
    makevectors (dir);

    traceline (self.origin + v_up * 16 + v_right * 8, entity_org + v_up * 16 + v_right * 8, false, self);
    if (trace_fraction != 1.0)
    {
      if ((trace_ent == self.bot_owner) || (trace_ent.bot_owner == self.bot_owner) ||
          ((teamplay) && (trace_ent.team == self.bot_owner.team)) || (trace_ent.classname == "worldspawn"))
        temp = false;
    }
    else
    {
      traceline (self.origin + v_up * 16 - v_right * 8, entity_org + v_up * 16 - v_right * 8, false, self);
      if (trace_fraction != 1.0)
      {
        if ((trace_ent == self.bot_owner) || (trace_ent.bot_owner == self.bot_owner) ||
           ((teamplay) && (trace_ent.team == self.bot_owner.team)) || (trace_ent.classname == "worldspawn"))
          temp = false;
      }
    }
  }

  if (temp == false)
    Debug_Msgln ("Can't hit.");

  return temp;
};

/*
================
ZEUS_AxeHack
================
*/
void() ZEUS_AxeHack =
{
  local   vector  source;
  local   vector  org;

  makevectors (self.angles);
  source = self.origin + '0 0 16';
  traceline (source, source + v_forward*64, false, self);
  if (trace_fraction == 1.0)
    return;

  org = trace_endpos - v_forward*4;

  if (trace_ent.takedamage)
  {
    trace_ent.axhitme = 1;
    SpawnBlood (org, 20);
    T_Damage (trace_ent, self, self, 20);
  }
  else
  {	// hit wall
    sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, TE_GUNSHOT);
    WriteCoord (MSG_BROADCAST, org_x);
    WriteCoord (MSG_BROADCAST, org_y);
    WriteCoord (MSG_BROADCAST, org_z);
  }
};

/*
======================
ZEUS_CastLightning
======================
*/

void () ZEUS_CastLightning =
{
  local   vector  org, dir;
  local   float   miss, chance;

  if (self.ammo_cells <= 0)
    return;

// explode if under water
  if (self.ZEUS_waterlevel > 1)
    {
      T_RadiusDamage (self, self, 35*self.ammo_cells, world, "");
      self.ammo_cells = 0;
      self.currentammo = 0;
      return;
  }

  self.currentammo = self.ammo_cells = self.ammo_cells - 1;

  // remove muzzle flash effect oldman: not in qw
  // self.effects = self.effects | EF_MUZZLEFLASH; 

  ZEUS_EntityOrigin (self.enemy);

  miss = false;

  chance = ZEUS_ChanceToHit (self.enemy);
  if (random () > chance)
  {
    // make bot miss target
    dir = ZEUS_MissTarget (self.enemy);
    miss = true;
  }

  makevectors (self.angles);
  org = self.origin + v_forward * 8 + v_right * 16 + v_up * 16;

  // dir for Shambler's lightning

  if (miss)
    dir = (dir - org);
  else
    dir = (entity_org + '0 0 16') - org;
  dir = normalize (dir);

  traceline (org, self.origin + dir * 600, true, self);

  WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
  WriteByte (MSG_BROADCAST, TE_LIGHTNING1);
  WriteEntity (MSG_BROADCAST, self);
  WriteCoord (MSG_BROADCAST, org_x);
  WriteCoord (MSG_BROADCAST, org_y);
  WriteCoord (MSG_BROADCAST, org_z);
  WriteCoord (MSG_BROADCAST, trace_endpos_x);
  WriteCoord (MSG_BROADCAST, trace_endpos_y);
  WriteCoord (MSG_BROADCAST, trace_endpos_z);

  LightningDamage (org, trace_endpos, self, 30);

  SuperDamageSound ();
  if (self.attack_finished < time)
  {
    sound (self, CHAN_WEAPON, "weapons/lstart.wav", 1, ATTN_NORM);
    self.attack_finished = time + 0.1;
  }
  else if (self.t_width < time)
  {
    sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
    self.t_width = time + 0.6;
  }
};

/*
======================
ZEUS_fire_rocket
======================
*/

void () ZEUS_fire_rocket =
{
  local   entity  missile, mpuff;
  local   vector  dir;

  if (self.ammo_rockets <= 0)
    return;

  self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

  SuperDamageSound ();
  sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  /* self.punchangle_x = -2; */

  missile = spawn ();
  missile.owner = self;
  missile.movetype = MOVETYPE_FLYMISSILE;
  missile.solid = SOLID_BBOX;

// set missile speed

  if (!ZEUS_visible (self.enemy))
    dir = normalize (self.ZEUS_last_enemy_loc - self.origin);
  else
    dir = ZEUS_LeadTarget (self.enemy, 1000);

  missile.velocity = dir * 1000;
  missile.angles = vectoangles(missile.velocity);

  missile.touch = T_MissileTouch;

  // set missile duration
  missile.nextthink = time + 5;
  missile.think = SUB_Remove;

  setmodel (missile, "progs/missile.mdl");
  setsize (missile, '0 0 0', '0 0 0');
  setorigin (missile, self.origin + v_forward*8 + '0 0 16');

  self.attack_finished = time + 0.8;
};

/*
======================
ZEUS_fire_superspike
======================
*/

void () ZEUS_fire_superspike =
{
  local   vector  dir;

  if (self.ammo_nails < 2)
    return;

  self.currentammo = self.ammo_nails = self.ammo_nails - 2;

  SuperDamageSound ();
  sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);

  newmis = spawn ();
  newmis.owner = self;
  newmis.movetype = MOVETYPE_FLYMISSILE;
  newmis.solid = SOLID_BBOX;

  dir = ZEUS_LeadTarget (self.enemy, 1000);

  newmis.angles = vectoangles(dir);

  newmis.touch = superspike_touch;
  newmis.classname = "spike";
  newmis.think = SUB_Remove;
  newmis.nextthink = time + 6;
  setmodel (newmis, "progs/s_spike.mdl");
  setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
  setorigin (newmis, self.origin + '0 0 16');

  newmis.velocity = dir * 1000;

  self.attack_finished = time + 0.1;
};

/*
======================
ZEUS_fire_spike
======================
*/

void () ZEUS_fire_spike =
{
  local   vector  dir;

  if (self.ammo_nails < 1)
    return;

  self.currentammo = self.ammo_nails = self.ammo_nails - 1;

  SuperDamageSound ();
  sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

  newmis = spawn ();
  newmis.owner = self;
  newmis.movetype = MOVETYPE_FLYMISSILE;
  newmis.solid = SOLID_BBOX;

  dir = ZEUS_LeadTarget (self.enemy, 1000);

  newmis.angles = vectoangles(dir);

  newmis.touch = spike_touch;
  newmis.classname = "spike";
  newmis.think = SUB_Remove;
  newmis.nextthink = time + 6;
  setmodel (newmis, "progs/spike.mdl");
  setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
  setorigin (newmis, self.origin + '0 0 16');

  newmis.velocity = dir * 1000;

  self.attack_finished = time + 0.1;
};

/*
================
ZEUS_fire_shotgun
================
*/

void() ZEUS_fire_shotgun =
{
  local   vector  dir, org;
  local   float   chance;

  if (self.ammo_shells < 1)
    return;

  SuperDamageSound ();
  sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);

  self.currentammo = self.ammo_shells = self.ammo_shells - 1;

  chance = ZEUS_ChanceToHit (self.enemy);
  if (random () > chance)
  {
    // make bot miss target
    org = ZEUS_MissTarget (self.enemy);
//    bprint (PRINT_HIGH, "missing target\n");
  }
  else
    org =   ZEUS_EntityOrigin (self.enemy) + '0 0 16';

  dir = (org) - (self.origin + '0 0 16');
  dir = normalize (dir);

  FireBullets (6, dir, '0.04 0.04 0');

  self.attack_finished = time + 0.5;
};

/*
================
ZEUS_fire_supershotgun
================
*/
void() ZEUS_fire_supershotgun =
{
  local vector dir, org;

  if (self.ammo_shells < 1)
    return;

  if (self.currentammo == 1)
  {
    ZEUS_fire_shotgun();
    return;
  }

  SuperDamageSound ();
  sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);

  /* self.punchangle_x = -4; */

  self.currentammo = self.ammo_shells = self.ammo_shells - 2;

  // determine chance to hit with weapon
  if (random () > ZEUS_ChanceToHit (self.enemy))
  {
    // make bot miss target
    org = ZEUS_MissTarget (self.enemy);
  }
  else org =   ZEUS_EntityOrigin (self.enemy) + '0 0 16';

  dir = (org) - (self.origin + '0 0 16');
  dir = normalize (dir);

  FireBullets (14, dir, '0.14 0.08 0');

  self.attack_finished = time + 0.7;
};

/*
================
ZEUS_fire_grenade
================
*/
void() ZEUS_fire_grenade =
{
  local   entity  missile, mpuff;
  local   vector  dir;

  if (self.ammo_rockets < 1)
    return;

  self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

  SuperDamageSound ();
  sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

  /* self.punchangle_x = -2; */

  missile = spawn ();
  missile.owner = self;
  missile.movetype = MOVETYPE_BOUNCE;
  missile.solid = SOLID_BBOX;
  missile.classname = "grenade";

// set missile speed

//  makevectors (self.v_angle);
//  dir = (ZEUS_EntityOrigin (self.enemy) + '0 0 16') - (self.origin + '0 0 16');
//  dir = normalize (dir);

  if (!ZEUS_visible (self.enemy))
    dir = normalize (self.ZEUS_last_enemy_loc - self.origin);
  else
    dir = ZEUS_LeadTarget (self.enemy, 600);

  missile.velocity = dir * 600;
  missile.velocity_z = 200;

//  missile.avelocity = '300 300 300';

  missile.angles = vectoangles(missile.velocity);

  missile.touch = GrenadeTouch;

  // set missile duration
  missile.nextthink = time + 2.5;
  missile.think = GrenadeExplode;

  setmodel (missile, "progs/grenade.mdl");
  setsize (missile, '0 0 0', '0 0 0');
  setorigin (missile, self.origin);

  self.attack_finished = time + 0.6;
};

/*
======================
ZEUS_fire
======================
*/

void () ZEUS_fire =
{
  if ((self.enemy.health <= 0) || (self.enemy == self.bot_owner))
    return;

  if (self.aflag) ZEUS_sprint (self.enemy, "I hate you! ");

  ZEUS_ai_face ();

  if (self.weapon == IT_LIGHTNING)
    ZEUS_CastLightning ();
  else if (self.weapon == IT_ROCKET_LAUNCHER)
    ZEUS_fire_rocket ();
  else if (self.weapon == IT_GRENADE_LAUNCHER)
    ZEUS_fire_grenade ();
  else if (self.weapon == IT_SUPER_NAILGUN)
    ZEUS_fire_superspike ();
  else if (self.weapon == IT_NAILGUN)
    ZEUS_fire_spike ();
  else if (self.weapon == IT_SUPER_SHOTGUN)
    ZEUS_fire_supershotgun ();
  else if (self.weapon == IT_SHOTGUN)
    ZEUS_fire_shotgun ();
  else
    ZEUS_AxeHack ();
};

/*
======================
ZEUS_EnemyWeapon

sets ZEUS_enemy_weapon equal to self.weapon for all bots whose enemy is self
======================
*/

void () ZEUS_EnemyWeapon =
{
  local   entity  head;

  head = nextent (world);

  while (head != world)
  {
    if (head.enemy == self)
        head.ZEUS_enemy_weapon = self.weapon;
    head = find (head, classname, "zeus_bot");
  }
};

/*
======================
ZEUS_RemoveBot

removes a helper bot from its owner's list, and also deletes the entity
if remove_ent is true
======================
*/
void (entity gone, float remove_ent) ZEUS_RemoveBot =
{
  local   entity  prev_bot;

  if (gone == world)
    return;

  if ((gone.bot_owner.classname != "player") && (gone.bot_owner.classname != "bot_viewer"))
    return;

  gone.bot_owner.bot_flag = gone.bot_owner.bot_flag - 1;

  if (gone.bot_owner.bot == gone)
  // first in list, easy to remove
    gone.bot_owner.bot = gone.next_bot;
  else
  {
    // go to the first bot
    prev_bot = gone.bot_owner.bot;

    // traverse till next_bot == gone
    while (prev_bot.next_bot != gone)
      prev_bot = prev_bot.next_bot;

    // set the previous bot's next_bot to the dead bot's next_bot
    prev_bot.next_bot = gone.next_bot;
  }

  if (remove_ent)
  {
    // delete this one for good
    remove (gone.movetarget);
    remove (gone);
  }
};

/*
======================
ZEUS_SelfDeactivate
======================
*/

void () ZEUS_SelfDeactivate =
{
  local   string  deathstr, tempstr;

  if ((self.enemy == self.bot_owner) && (!deathmatch))
  {
    if (self.health < -35)
    {
      if (random () < 0.5)
        ZEUS_Cl_Msg ("Zeusbot: Dumba...\n");
      else
        ZEUS_Cl_Msg ("Zeusbot: You fra...\n");
    }
    else
    {
      ZEUS_Cl_Msg ("Zeusbot: In the future, please use my off switch.\n");
    }
  }
  else if ((self.enemy.classname == "player") && (!deathmatch))
  {
    deathstr = self.enemy.netname;
    if (self.health < -35)
    {
      tempstr = " just chunked your Zeusbot.\n";
    }
    else
    {
      if (random () < 0.5)
      {
        tempstr = " broke your bot.\n";
      }
      else
      {
        tempstr = " punctured your inflatable doll.\n";
      }
    }

    ZEUS_Cl_Msg (deathstr);
    ZEUS_Cl_Msg (tempstr);
  }
  else if (!deathmatch)
  {
    if (self.health < -35)
    {
      ZEUS_Cl_Msg ("Zeusbot: Oh sh...!\n");
    }
    else
    {
      ZEUS_Cl_Msg ("Zeusbot: Shutting down...\n");
    }
  }

  // set the HUD to the next bot if this is the first bot
  if (self.bot_owner.bot == self)
  {
    if (self.bot_owner.bot_flag > 1)
      HUD_StatusOn (self.next_bot, self.bot_owner);
    else
    // set hud to player
      HUD_StatusOn (self.bot_owner, self.bot_owner);
  }

  // if the bot is owned by the player, remove it from the list before
  // disposing of the entity
  if ((self.bot_owner.classname == "player") && (!deathmatch))
  {
    CopyToBodyQue (self);
    ZEUS_RemoveBot (self, true);
  }
  else
  // set up bot to respawn
  {
    self.think = ZEUS_RespawnBot;
    if (deathcam_time > time)
      self.nextthink = deathcam_time + 0.1;
    else
      self.nextthink = deathcam_time + random () * 3;
  }
};

/*
=========================================================================

functions called from outside of ZEUS.QC, self != zeus bot

=========================================================================
*/

/*
=============
ZEUS_precache

Called in world.qc
=============
*/

void() ZEUS_precache =
{
  precache_model2 ("progs/player.mdl");
  precache_model2 ("progs/h_player.mdl");
  precache_model2 ("progs/v_light.mdl");

  // for debugging
  precache_model2 ("progs/flame2.mdl");
  precache_model2 ("progs/shambler.mdl");

  precache_sound2 ("weapons/lstart.wav");
  precache_sound2 ("weapons/lhit.wav");
  precache_sound2 ("player/sucker.wav");

  precache_sound2 ("enforcer/death1.wav");
  precache_sound2 ("enforcer/idle1.wav");
  precache_sound2 ("enforcer/pain1.wav");
  precache_sound2 ("enforcer/pain2.wav");
  precache_sound2 ("enforcer/sight1.wav");
  precache_sound2 ("enforcer/sight2.wav");
  precache_sound2 ("enforcer/sight3.wav");
  precache_sound2 ("enforcer/sight4.wav");

  HUD_Precache ();
};

/*
======================
ZEUS_CheckSpawnPos
======================
*/

float (vector dir) ZEUS_CheckSpawnPos =
{
  local   float   tf1, tf2, pc;
  traceline (self.origin, self.origin + dir * 84, false, self);
  tf1 = trace_fraction;
  traceline (self.origin + '0 0 48', self.origin + dir * 84 + '0 0 48', false, self);
  tf2 = trace_fraction;
  traceline (self.origin - '0 0 22', self.origin + dir * 84 - '0 0 22', false, self);
  pc = pointcontents (self.origin + dir * 36);

  if (((tf1 == 1.0) && (tf2 == 1.0) && (trace_fraction == 1.0)) &&
     ((pc == CONTENT_EMPTY) || (pc == CONTENT_WATER)))
    return true;
  else
    return false;
};

/*
======================
ZEUS_SpawnPos
======================
*/

vector () ZEUS_SpawnPos =
{
  makevectors (self.angles);

  if (ZEUS_CheckSpawnPos (v_right))
    return (self.origin + v_right * 50);
  else if (ZEUS_CheckSpawnPos (-1 * v_right))
    return (self.origin + v_right * -50);
  else if (ZEUS_CheckSpawnPos (-1 * v_forward))
    return (self.origin + v_forward * -50);
  else if (ZEUS_CheckSpawnPos (v_forward))
    return (self.origin + v_forward * 50);
  else return '0 0 0';
};

/*
======================
ZEUS_SetupBot
======================
*/

float (entity o, entity zeusbot, float bot_type, float show_msg) ZEUS_SetupBot =
{
  local   vector  org;
  local   entity  spot;

  if (bot_type == ZEUS_OPPONENT)
  {
    spot = SelectSpawnPoint ();
    org = spot.origin;
  }
  else
  {
    org = ZEUS_SpawnPos ();
    if (org == '0 0 0')
    {
      if (show_msg)
        sprint (self, PRINT_HIGH, "There is no room for a Zeusbot here.\n");
      return false;
    }
  }

  zeusbot.solid = SOLID_SLIDEBOX;
//  zeusbot.flags = 0;
  zeusbot.movetype = MOVETYPE_STEP;
  zeusbot.angles = '0 0 0';

  zeusbot.classname = "zeus_bot";

  zeusbot.bot_owner = o;
  zeusbot.owner = world;
//  zeusbot.next_bot = world;
//  zeusbot.bot = world;

  if (bot_type == ZEUS_OPPONENT)
    zeusbot.ZEUS_roam = true;
  else
    zeusbot.ZEUS_roam = false;

  zeusbot.bot_attack = true;
  zeusbot.bot_stay = false;

  zeusbot.takedamage = DAMAGE_AIM;
  zeusbot.goalentity = self.bot_owner;
  zeusbot.pausetime = 0;
  zeusbot.ideal_yaw = zeusbot.angles * '0 1 0';
  zeusbot.yaw_speed = 90;
  zeusbot.ZEUS_waterlevel = 0;
  zeusbot.ZEUS_watertype = 0;
  zeusbot.effects = 0;

  zeusbot.view_ofs = '0 0 25';

  zeusbot.health = 100;
  zeusbot.max_health = 100;
//  bit = IT_ARMOR3;
  zeusbot.armortype = 0;
  zeusbot.armorvalue = 0;
//  zeusbot.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;

  zeusbot.th_stand = ZEUS_stand1;
  zeusbot.th_run = ZEUS_run1;
  zeusbot.th_pain = ZEUS_pain;
  zeusbot.th_die = ZEUS_die;
  zeusbot.th_missile = ZEUS_attack;
  zeusbot.th_follow = ZEUS_follow1;
  zeusbot.team = o.team;
  zeusbot.deadflag = DEAD_NO;
  zeusbot.ZEUS_pain_delay = 3;

  zeusbot.ZEUS_UR_item_1 = zeusbot;
  zeusbot.ZEUS_UR_item_2 = zeusbot;

  org = org + '0 0 1';
  setmodel (zeusbot, "progs/player.mdl");
  setsize (zeusbot, '-16 -16 -24', '16 16 30');
  setorigin(zeusbot, org);

  spawn_tfog (zeusbot.origin);

  zeusbot.nextthink = time + nextthinktime;
  zeusbot.think = zeusbot.th_stand;

  zeusbot.ZEUS_UR_oldest = 1;

  // give ammo and weapons
  zeusbot.ammo_rockets = 0;
  zeusbot.ammo_nails = 0;
  zeusbot.ammo_shells = 25;
  zeusbot.ammo_cells = 0;
  zeusbot.items = 0;

// normal start
  zeusbot.items = zeusbot.items | IT_AXE | IT_SHOTGUN;
  zeusbot.ammo_cells = 25;

// dynamic mapping stuff

  spot = self;
  self = zeusbot;
  ZEUS_SpawnMapNode ();
  self = spot;

  return true;
};

/*
======================
ZEUS_RespawnBot
======================
*/

void () ZEUS_RespawnBot =
{
  local   entity  zeusbot, spot;
  local   vector  org;
  local   float   bit;

  // respawn this ZEUSbot

  CopyToBodyQue (self);
  if ((self.bot_owner.classname == "player") || (self.bot_owner.classname == "bot_viewer"))
    ZEUS_SetupBot (self.bot_owner, self, ZEUS_OPPONENT, false);
  else
    ZEUS_SetupBot (self.movetarget, self, ZEUS_OPPONENT, false);

  spawn_tdeath (self.origin, self);
};

/*
======================
ZEUS_AddBot

adds a bot to the player's list
======================
*/
void (entity zeusbot) ZEUS_AddBot =
{
  local   entity  lastbot;

  // insert the new zeus bot in the list of this player's bots
  if (self.bot == world)
  {
    self.bot = zeusbot;
    zeusbot.next_bot = world;
  }
  else
  {
    lastbot = self.bot;
    self.bot = zeusbot;
    zeusbot.next_bot = lastbot;
  }

  zeusbot.bot_flag = ZEUS_CountBots (self.bot);
  self.bot_flag = self.bot_flag + 1;
};

/*
======================
ZEUS_CountBots

returns the number of bots connected to this player
======================
*/

float (entity first_bot) ZEUS_CountBots =
{
  local   entity  temp;
  local   float   i;

  if (first_bot == world)
  {
    return 0;
  }

  i = 1;
  temp = first_bot;

  while (temp.next_bot != world)
  {
    temp = temp.next_bot;
    i = i + 1;
  }

  return i;
};

/*
======================
ZEUS_Activate
======================
*/

void (float show_msg) ZEUS_Activate =
{
  local   entity  zeusbot;
  local   vector  org;

  if (!(self.flags & FL_ONGROUND))
  {
    if (show_msg)
      sprint (self, PRINT_HIGH, "There is no room for a Zeusbot here.\n");
    return;
  }

  // Spawn a new ZEUSbot

  zeusbot = spawn();

  if (!ZEUS_SetupBot (self, zeusbot, ZEUS_HELPER, show_msg))
  {
    remove (zeusbot);
    return;
  }

  zeusbot.health = 100;
  zeusbot.max_health = 100;

  if (!deathmatch)
  {
    // bot has 200 red armor & 200 health
    zeusbot.armortype = 0.8;
    zeusbot.armorvalue = 200;
    zeusbot.items = zeusbot.items | IT_ARMOR3;
    zeusbot.ZEUS_skill = 3;
  }
  else
    zeusbot.ZEUS_skill = skill;


// skin equal to current player skin

  if (!GL_QUAKE)
  {
    if (self.skin == 0)
      zeusbot.skin = 1;
    else if (self.skin == 1)
     zeusbot.skin = 0;
    else
      zeusbot.skin = self.skin;
  }

  ZEUS_AddBot (zeusbot);

  // set up flags for owner pissing Zeus off
  zeusbot.aflag = 0;
  zeusbot.count = 0;
  zeusbot.dmg = 6 + random () * 8;

  if (show_msg)
  {
    sprint (self, PRINT_HIGH, "ZEUSbot #");
    temp_text = ftos (zeusbot.bot_flag);
    sprint (self, PRINT_HIGH, temp_text);
    sprint (self, PRINT_HIGH, " activated.\n");
  }

  if (zeusbot.bot_flag == 1)
    zeusbot.netname = "Zeusbot #1";
  else if (zeusbot.bot_flag == 2)
    zeusbot.netname = "Zeusbot #2";
  else if (zeusbot.bot_flag == 3)
    zeusbot.netname = "Zeusbot #3";
  else if (zeusbot.bot_flag == 4)
    zeusbot.netname = "Zeusbot #4";
  else if (zeusbot.bot_flag == 5)
    zeusbot.netname = "Zeusbot #5";
  else if (zeusbot.bot_flag == 6)
    zeusbot.netname = "Zeusbot #6";
  else if (zeusbot.bot_flag == 7)
    zeusbot.netname = "Zeusbot #7";
  else if (zeusbot.bot_flag == 8)
    zeusbot.netname = "Zeusbot #8";
  else if (zeusbot.bot_flag == 9)
    zeusbot.netname = "Zeusbot #9";
  else if (zeusbot.bot_flag == 10)
    zeusbot.netname = "Zeusbot #10";
  else if (zeusbot.bot_flag == 11)
    zeusbot.netname = "Zeusbot #11";
  else if (zeusbot.bot_flag == 12)
    zeusbot.netname = "Zeusbot #12";
  else if (zeusbot.bot_flag == 13)
    zeusbot.netname = "Zeusbot #13";
  else if (zeusbot.bot_flag == 14)
    zeusbot.netname = "Zeusbot #14";
  else if (zeusbot.bot_flag == 15)
    zeusbot.netname = "Zeusbot #15";

  // in deathmatch, remove powerup status from player
  if (deathmatch) self.bot_avail = 0;

  // set up the entity for his move target -- this is placed in front of him,
  // like a carrot in front of a horse, and is normally invisible -- used for
  // roaming unfamiliar territory

  zeusbot.movetarget = spawn ();
  zeusbot.movetarget.solid = SOLID_NOT;
  zeusbot.movetarget.flags = 0;
  zeusbot.movetarget.movetype = MOVETYPE_NONE;
  zeusbot.movetarget.angles = self.angles;
  zeusbot.movetarget.classname = "roam_target";
  setmodel (zeusbot.movetarget, "");
  setsize (zeusbot.movetarget, '0 0 0 ', '0 0 0');
  setorigin (zeusbot.movetarget, org);

  HUD_StatusOn (self.bot, self);
};

/*
======================
ZEUS_Deactivate
======================
*/

void () ZEUS_Deactivate =
{
  spawn_tfog (self.bot.origin);

  if (self.bot_view) ZEUS_SetPlayerView ();

  // prevents fire from continuing on the next cujo spawned if he
  // was burning but not dead when he was deactivated
//  blaze_extinguishentity (self.bot);

  sprint (self, PRINT_HIGH, "ZEUSbot #");
  temp_text = ftos (self.bot.bot_flag);
  sprint (self, PRINT_HIGH, temp_text);
  sprint (self, PRINT_HIGH, " deactivated.\n");

  if (self.bot_flag > 1)
    HUD_StatusOn (self.bot.next_bot, self);
  else
  // set hud to player
    HUD_StatusOn (self, self);

/*
  self.bot.nextthink = time + nextthinktime;
  self.bot.think = SUB_Remove;
  self.bot_flag = false;
*/

  ZEUS_RemoveBot (self.bot, true);
};

/*
======================
ZEUS_TeleportHome
======================
*/

void () ZEUS_TeleportHome =
{
  local   vector  org;
  local   entity  temp;

  if (self.bot_flag < 1)
  {
    ZEUS_PrintStatus ();

    return;
  }
  if (self.bot.deadflag == DEAD_DYING) return;

  temp = self;
  if (self.classname == "bot_viewer")
    self = self.movetarget;

  org = ZEUS_SpawnPos ();

  self = temp;

  if (org == '0 0 0')
  {
    sprint (self, PRINT_HIGH, "There is no room for a Zeusbot here.\n");
    return;
  }

  spawn_tfog (self.bot.origin);
  self.bot.ideal_yaw = self.angles * '0 1 0';
  self.bot.pausetime = time + 0.2;

  setorigin(self.bot, org + '0 0 1');

  spawn_tfog (self.bot.origin);
  self.bot.nextthink = time + nextthinktime;
  self.bot.think = self.bot.th_stand;
  ZEUS_SetFollowGoal ();
  ZEUS_allstop ();
/*
  if (self.bot.ZEUS_roam == true)
  {
    sprint (self, PRINT_HIGH, "ZEUSbot: roaming off.\n");
    self.bot.ZEUS_roam = false;
  }
*/
  return;
};

/*
======================
ZEUS_LightToggle
======================
*/

void () ZEUS_LightToggle =
{
  local   float   effect;
  local   float   bitmask;

  if (self.bot_flag > 0)
  {
    effect = EF_DIMLIGHT;

    bitmask = (effect) & self.bot.effects;

    if (bitmask == 0)
    {
      self.bot.effects = self.bot.effects | effect;
    }
    else
    {
      bitmask = !(bitmask);
      self.bot.effects = (self.bot.effects) & bitmask;
    }
  }
  else
    ZEUS_PrintStatus ();

  return;
};

/*
======================
ZEUS_AttackToggle
======================
*/

void () ZEUS_AttackToggle =
{
  local   entity  temp;

  if (self.bot_flag < 1)
  {
    ZEUS_PrintStatus ();

    return;
  }

  if (self.bot.bot_attack == true)
  {
    self.bot.bot_attack = false;
    sprint (self, PRINT_HIGH, "Zeusbot: I will refrain from devastation.\n");

    // reset Zeus's enemy so he doesn't whine even when the enemy goes
    // out of view.

    temp = self;
    self = self.bot;

    ZEUS_ResetGoalEntity ();

    ZEUS_SetThink (self.th_stand);

    self = temp;
  }
  else
  {
    self.bot.bot_attack = true;
    sprint (self, PRINT_HIGH, "Zeusbot: I am prepared to kick ass.\n");
  }

  return;
};

void()	clone_pain1 =	[	$pain1,	clone_pain2	]
{
  local   entity  temp;

  temp = self;
  self = self.owner;
  PainSound ();
  self = temp;

  self.weaponframe = 0;
  ZEUS_UpdateView ();
};
void()	clone_pain2 =	[	$pain2,	clone_pain3	]
{
  ZEUS_UpdateView ();
};
void()	clone_pain3 =	[	$pain3,	clone_pain4	]
{
  ZEUS_UpdateView ();
};
void()	clone_pain4 =	[	$pain4,	clone_pain5	]
{
  ZEUS_UpdateView ();
};
void()	clone_pain5 =	[	$pain5,	clone_pain6	]
{
  ZEUS_UpdateView ();
};
void()	clone_pain6 =	[	$pain6,	ZEUS_UpdateView]
{
  ZEUS_UpdateView ();
  self.nextthink = time + deathcam_thinktime;
  self.think = ZEUS_UpdateView;
};

/*
======================
ZEUS_ClonePain
======================
*/

void () ZEUS_ClonePain =
{
  T_Damage (self.owner, self, self,0);
  self.owner.dmg_take = self.dmg_take;
  self.owner.dmg_save = self.dmg_save;
  self.owner.dmg_inflictor = self.dmg_inflictor;
  self.owner.health = self.health;
  self.owner.armorvalue = self.armorvalue;
  self.owner.armortype = self.armortype;

  clone_pain1 ();
};

void () ZEUS_RemoveClone;

/*
======================
ZEUS_CloneDie
======================
*/

void () ZEUS_CloneDie =
{
  T_Damage (self.owner, self, self,0);
  self.owner.dmg_take = self.dmg_take;
  self.owner.dmg_save = self.dmg_save;
  self.owner.dmg_inflictor = self.dmg_inflictor;
  self.owner.health = self.health;
  self.owner.armorvalue = self.armorvalue;
  self.owner.armortype = self.armortype;

  self = self.owner;
  ZEUS_SetPlayerView ();

  PlayerDie ();
};

/*
======================
ZEUS_UpdateView
======================
*/

void () ZEUS_UpdateView =
{
  local   entity  temp;
  local   float   dist;
  local   vector  dir;

  self.nextthink = time + deathcam_thinktime;
  self.think = ZEUS_UpdateView;

  self.frame = self.frame + 0.25;
  if (self.frame > 16) self.frame = 12;

  temp = self;
  self = self.owner;

  if (self.bot.health > 0) deathcam_time = time + 1;

  if ((deathcam_time < time) && (!deathmatch))
  {
    ZEUS_SetPlayerView ();
    return;
  }

  // update the player's view angle
  makevectors (self.bot.angles);

  if ((self.bot.health > 0) && (self.bot.deadflag == DEAD_NO))
  {
    setorigin (self, self.bot.origin + v_up * 25);
    self.velocity = self.bot.velocity;
  }
    if (self.bot.health <= 0)
    {
      if (ZEUS_visible (self.bot) || deathmatch)
      {
        dir = (self.bot.origin - self.origin);
        dist = vlen (dir);
        dir = normalize (dir);

        self.angles = vectoangles (dir);
        // prevent view from going down towards floor
        if (self.angles_x > 0)
          self.angles_x = 0 - self.angles_x;
        else
          self.angles_x = 360 - self.angles_x;

        makevectors (self.angles);

        if (dist < 100)
          self.velocity = v_forward * -200 + v_right * 200;
        else
          self.velocity = v_right * 200;
      }
      else
      {
        self.bot.nextthink = time + 0.1;
        deathcam_time = time;
        ZEUS_SetPlayerView ();
        return;
      }
    }
    else
    {
      if (self.bot.goalentity.classname == "roam_goal")
        self.angles = self.bot.angles;
      else
      {
        ZEUS_EntityOrigin (self.bot.goalentity);
        dir = normalize (entity_org - self.bot.origin);
        self.angles = vectoangles (dir);
        if (self.angles_x > 0)
          self.angles_x = 0 - self.angles_x;
        else
          self.angles_x = 360 - self.angles_x;
      }
    }
    self.fixangle = true;

  ZEUS_CheckImpulses ();
  self.impulse = 0;

  self = temp;

  self.nextthink = time + deathcam_thinktime;
  self.think = ZEUS_UpdateView;
};

/*
======================
ZEUS_ClonePlayer
======================
*/

void () ZEUS_ClonePlayer =
{
  local   entity  ent;

  self.movetarget = spawn ();
  ent = self.movetarget;

  // make the bot's owner the clone
//  self.bot.bot_owner = ent;

  // make the clone's owner the player
  ent.bot_owner = self;
  ent.owner = self;

  ent.armorvalue = self.armorvalue;
  ent.armortype = self.armortype;
  ent.health = self.health;
  ent.origin = self.origin;
  ent.angles = self.angles;
  ent.v_angle = self.v_angle;
  ent.view_ofs = self.view_ofs;
  self.ZEUS_UR_loc_1 = self.angles;
  self.ZEUS_UR_loc_2 = self.v_angle;

  ent.frame = self.frame;
  ent.takedamage = self.takedamage;
  ent.max_health = self.max_health;
  ent.solid = SOLID_SLIDEBOX;
  ent.weaponmodel = self.weaponmodel;
  ent.colormap = self.colormap;
  ent.skin = self.skin;
  ent.weapon = self.weapon;
  ent.movetype = MOVETYPE_STEP;
  ent.velocity = self.velocity;
  ent.effects = self.effects;
  ent.flags = self.flags;
  ent.waterlevel = self.waterlevel;
  ent.watertype = self.watertype;
  ent.invisible_time = self.invisible_time;
  ent.invisible_finished = self.invisible_finished;
  ent.invincible_time = self.invincible_time;
  ent.invincible_finished = self.invincible_finished;
  ent.super_time = self.super_time;
  ent.super_damage_finished = self.super_damage_finished;
  ent.rad_time = self.rad_time;
  ent.radsuit_finished = self.radsuit_finished;

  ent.th_pain = ZEUS_ClonePain;
  ent.th_die = ZEUS_CloneDie;

  ent.classname = "player_clone";
  ent.netname = self.netname;

  setmodel (ent, self.model);
  setsize (ent, '-16 -16 -24', '16 16 32');
  setorigin (ent, self.origin);

  // make player invisible to monsters
  self.flags = (self.flags | FL_NOTARGET);
  // take the player off of the ground
  self.flags = self.flags - (self.flags & FL_ONGROUND);
  setmodel (self, "");
  setsize (self, '0 0 0', '0 0 0');
  self.weaponmodel = "";
  self.classname = "bot_viewer";

  self.movetype = MOVETYPE_FLY;
  self.solid = SOLID_NOT;
  self.view_ofs = '0 0 0';
  self.takedamage = DAMAGE_NO;

  makevectors (self.bot.angles);
  setorigin (self, self.bot.origin + '0 0 25');
  if (self.bot.cnt != FRAME_JUMP)
  {
    self.bot.velocity_x = 0;
    self.bot.velocity_y = 0;
  }
  self.velocity = self.bot.velocity;
  self.angles = self.bot.angles + v_forward * 16 - v_up * 16;

  self.bot.yaw_speed = 30;
  self.bot.view_ofs = '0 0 25';

  // set up the think to change camera angles
  // synchronize it with bot thinks
  ent.nextthink = self.nextthink;
  ent.think = ZEUS_UpdateView;
};

/*
======================
ZEUS_RemoveClone
======================
*/

void () ZEUS_RemoveClone =
{
  local   entity  ent;

  ent = self.movetarget;

//  self.bot.bot_owner = self;
  setmodel (self, ent.model);
  setsize (self, '-16 -16 -24', '16 16 32');
  setorigin (self, ent.origin);

  self.velocity = ent.velocity;
  self.classname = "player";
  self.angles = self.ZEUS_UR_loc_1;
  self.v_angle = self.ZEUS_UR_loc_2;
  self.movetype = MOVETYPE_WALK;
  self.solid = SOLID_SLIDEBOX;
  self.view_ofs = ent.view_ofs;
  self.takedamage = ent.takedamage;

  self.weaponmodel = ent.weaponmodel;
  self.flags = self.flags - (self.flags & FL_NOTARGET);

  self.bot.yaw_speed = 90;

  remove (ent);
};

/*
======================
ZEUS_SetBotView
======================
*/

void () ZEUS_SetBotView =
{
  if (self.bot_flag > 0)
  {
    ZEUS_ClonePlayer ();

    self.bot_view = true;
//    HUD_StatusOn (self.bot, self.bot);
  }
  else
    ZEUS_PrintStatus ();

  return;

};

/*
======================
ZEUS_SetPlayerView
======================
*/

void () ZEUS_SetPlayerView =
{
  if (self.bot_flag > 0)
  {
    ZEUS_RemoveClone ();

    self.bot_view = false;
//    HUD_StatusOn (self.bot, self);
  }
  else
    ZEUS_PrintStatus ();

  return;
};

/*
======================
ZEUS_Stay
======================
*/

void () ZEUS_Stay =
{
  if (self.bot_flag > 0)
  {
    // toggle ZEUS's stay flag
    if (self.bot.bot_stay == false)
    {
      self.bot.bot_stay = true;
      sprint (self, PRINT_HIGH, "Zeusbot: I will wait here.\n");
    }
    else
    {
      self.bot.bot_stay = false;
      sprint (self, PRINT_HIGH, "Zeusbot: I will follow you.\n");
    }

  }
  else
    ZEUS_PrintStatus ();

  return;
};

/*
======================
ZEUS_GiveStatus
======================
*/

void () ZEUS_GiveStatus =
{
  local   entity  temp;
  local   string  str_temp;
  local   float   ftemp, vis;

  if (self.bot_flag > 0)
  {
    // FIX: umm... doesn't work right now
    if (self.bot.enemy != world)
    {
      temp = self;
      self = self.bot;
      vis = ZEUS_visible (self.bot.enemy);
      self = temp;
    }
    else vis = false;

    if (vis)
    {
      if (random () < 0.5)
        sprint (self, PRINT_HIGH, "Zeusbot: Ask me again when I'm not kicking ass.\n");
      else
        sprint (self, PRINT_HIGH, "Zeusbot: Ummm... I'm killing stuff right now...\n");
    }
    else
    {
      if (self.bot.health < 25)
        sprint (self, PRINT_HIGH, "Zeusbot: I am about to have my ass handed to me.\n");
      else
      {
        sprint (self, PRINT_HIGH, "Zeusbot: my health is ");

        ftemp = self.bot.health;

        str_temp = ftos (ftemp);
        sprint (self, PRINT_HIGH, str_temp);
        sprint (self, PRINT_HIGH, "%.\n");
      }

      if (self.bot.health > 100)
        sprint (self, PRINT_HIGH, "Zeusbot: I feel good enough to take you out...\n");
      else
      {
        sprint (self, PRINT_HIGH, "         my armor is ");

        ftemp = self.bot.armorvalue;

        str_temp = ftos (ftemp);
        sprint (self, PRINT_HIGH, str_temp);
        sprint (self, PRINT_HIGH, ".\n");
      }
    }
  }
  else
    ZEUS_PrintStatus ();

  return;
};

/*
======================
ZEUS_KillAllMonsters
======================
*/

void () ZEUS_KillAllMonsters =
{
  local   entity  head;
  local   float   gibcount;

  gibcount = 0;
  head = nextent (world);

  while (head)
  {
    if ((head.classname == "monster_army")
    || (head.classname == "monster_demon1")
    || (head.classname == "monster_dog")
    || (head.classname == "monster_dragon")
    || (head.classname == "monster_enforcer")
    || (head.classname == "monster_fish")
    || (head.classname == "monster_hell_knight")
    || (head.classname == "monster_knight")
    || (head.classname == "monster_ogre")
    || (head.classname == "monster_oldone")
    || (head.classname == "monster_shalrath")
    || (head.classname == "monster_shambler")
    || (head.classname == "monster_tarbaby")
    || (head.classname == "monster_vomit")
    || (head.classname == "monster_wizard"))
    {
      if ((random () < 0.2) && (gibcount < 4))
      {
        T_Damage (head, self, self, head.health + 100);
        gibcount = gibcount + 1;
      }
      else
        T_Damage (head, self, self, head.health + 1);
      ZEUS_Msg ("kill ");
    }
    else if (head.classname == "monster_zombie")
      if (random () < 0.5)
        T_Damage (head, self, self, head.health + 50);

    head = nextent (head);
   }
   ZEUS_Msgln ("Everything is dead.");
};

/*
======================
ZEUS_SpawnOpponent
======================
*/

void (float name_number, float new_name) ZEUS_SpawnOpponent =
{
  local   entity  zeusbot, name_ent;
  local   float   r, free_name, cmap;
  local   string  net_name, talkname;

  // Spawn a new ZEUSbot

  zeusbot = spawn();

  // add to list of opponent bots
  if (ZEUS_first_opponent == world)
    ZEUS_first_opponent = zeusbot;
  else
    ZEUS_last_opponent.bot = zeusbot;

  ZEUS_last_opponent = zeusbot;
  zeusbot.movetarget = spawn ();
  zeusbot.movetarget.solid = SOLID_NOT;
  zeusbot.movetarget.flags = 0;
  zeusbot.movetarget.movetype = MOVETYPE_NONE;
  zeusbot.movetarget.angles = self.angles;
  zeusbot.movetarget.classname = "roam_target";
  setmodel (zeusbot.movetarget, "");
//  setmodel (zeusbot.movetarget, "progs/flame2.mdl");
  setsize (zeusbot.movetarget, '0 0 0 ', '0 0 0');
  setorigin (zeusbot.movetarget, zeusbot.origin);

  ZEUS_SetupBot (zeusbot.movetarget, zeusbot, ZEUS_OPPONENT, false);

  ZEUS_opponent_bots = ZEUS_opponent_bots + 1;
  zeusbot.bot_flag = ZEUS_opponent_bots;

  // set skill of bot
  zeusbot.ZEUS_skill = skill;

  // skin equal to current player skin
  zeusbot.skin = self.skin;

  free_name = false;

  while (!free_name)
  {
    if ((!new_name) && (name_number < 17))
      r = name_number;
    else
      r = random () * 17;

    if (r < 1)
    {
      talkname = "Úåõó";
      net_name = "Zeus";
      cmap = 1;
      name_number = 1;
    }
    else if (r < 2)
    {
      talkname = "Òéðìåù";
      net_name = "Ripley";
      cmap = 2;
      name_number = 2;
    }
    else if (r < 3)
    {
      talkname = "Ôèå Áöáôáò";
      net_name = "The Avatar";
      cmap = 3;
      name_number = 3;
    }
    else if (r < 4)
    {
      talkname = "Ôèå Äáòë Ïîå";
      net_name = "The Dark One";
      cmap = 4;
      name_number = 4;
    }
    else if (r < 5)
    {
      talkname = "Íïòéäéî";
      net_name = "Moridin";
      cmap = 5;
      name_number = 5;
    }
    else if (r < 6)
    {
      talkname = "Óèáéäáò Èáòáî";
      net_name = "Shaidar Haran";
      cmap = 6;
      name_number = 6;
    }
    else if (r < 7)
    {
      talkname = "Áíïåâá Çïä";
      net_name = "Amoeba God";
      cmap = 7;
      name_number = 7;
    }
    else if (r < 8)
    {
      talkname = "Ìïòä Âòõôéóè";
      net_name = "Lord Brutish";
      cmap = 8;
      name_number = 8;
    }
    else if (r < 9)
    {
      talkname = "Ãåîôòéæõçå";
      net_name = "Centrifuge";
      cmap = 9;
      name_number = 9;
    }
    else if (r < 10)
    {
      talkname = "Ãáðôáéî Ëáîçáòïï";
      net_name = "Captain Kangaroo";
      cmap = 10;
      name_number = 10;
    }
    else if (r < 11)
    {
      talkname = "×áîîáâå";
      net_name = "Wannabe";
      cmap = 11;
      name_number = 11;
    }
    else if (r < 12)
    {
      talkname = "Íò® Âéìì";
      net_name = "Mr. Bill";
      cmap = 12;
      name_number = 12;
    }
    else if (r < 13)
    {
      talkname = "Ëéììòïù";
      net_name = "Killroy";
      cmap = 13;
      name_number = 13;
    }
    else if (r < 14)
    {
      talkname = "Ôèå Òåáðåò";
      net_name = "The Reaper";
      cmap = 14;
      name_number = 14;
    }
    else if (r < 15)
    {
      talkname = "Ãïòîèïìéï";
      net_name = "Cornholio";
      cmap = 15;
      name_number = 15;
    }
    else if (r < 16)
    {
      talkname = "ôèå Ñ Ãïîôéîõõí";
      net_name = "the Q Continuum";
      cmap = 16;
      name_number = 16;
    }
    else if (r < 17)
    {
      talkname = "Öåèåíåîô";
      net_name = "Vehement";
      cmap = 15;
      name_number = 17;
    }

    // search list for Zeusbots with matching names
    name_ent = nextent (world);
    while ((name_ent != world) && (net_name != name_ent.netname))
      name_ent = find (name_ent, classname, "zeus_bot");

    // if no matches, search for matching players
    if (name_ent == world)
    {
      name_ent = nextent (world);
      while ((name_ent != world) && (net_name != name_ent.netname))
        name_ent = find (name_ent, classname, "player");

      if (name_ent == world)
      {
        zeusbot.netname = net_name;
        zeusbot.message = talkname;
        free_name = true;
      }
    }
  }

  if (GL_QUAKE)
    zeusbot.skin = 0;
  else
  {
	if (ZEUS_multiskin)
	    zeusbot.skin = self.skin;
	else
	    zeusbot.skin = cmap - 1;
  }

  // store name number;
  zeusbot.state = name_number;

  bprint (PRINT_HIGH, net_name);
  bprint (PRINT_HIGH, ", skill ");
  temp_text = ftos (zeusbot.ZEUS_skill);
  bprint (PRINT_HIGH, temp_text);
  bprint (PRINT_HIGH, ", entered the game.\n");

  temp_text = ftos (ZEUS_opponent_bots);
  bprint (PRINT_HIGH, temp_text);
  bprint (PRINT_HIGH, " opponents active.\n");
};

/*
======================
ZEUS_ChooseRogueName

======================
*/

void (entity ent) ZEUS_ChooseRogueName =
{
  local   float   free_name, r;
  local   entity  name_ent;
  local   string  net_name;

  free_name = false;

  while (!free_name)
  {
    r = random () * 16;

    if (r < 1)
    {
      net_name = "Deadly Harry";
    }
    else if (r < 2)
    {
      net_name = "Mandragoran";
    }
    else if (r < 3)
    {
      net_name = "Lizzy Borden";
    }
    else if (r < 4)
    {
      net_name = "Paul Bunyon";
    }
    else if (r < 5)
    {
      net_name = "Mad God";
    }
    else if (r < 6)
    {
      net_name = "Trolloc Boy";
    }
    else if (r < 7)
    {
      net_name = "Leather Face";
    }
    else if (r < 8)
    {
      net_name = "Conan";
    }
    else if (r < 9)
    {
      net_name = "Molly Hatchet";
    }
    else if (r < 10)
    {
      net_name = "Colonel Pissed";
    }
    else if (r < 11)
    {
      net_name = "Dr. Nowyudi";
    }
    else if (r < 12)
    {
      net_name = "Perrin Goldeneyes";
    }
    else if (r < 13)
    {
      net_name = "General Axtodahed";
    }
    else if (r < 14)
    {
      net_name = "Nelno";
    }
    else if (r < 15)
    {
      net_name = "Corrupt";
    }
    else if (r < 16)
    {
      net_name = "Church Lady";
    }

    // search list for Zeusbots with matching names
    name_ent = nextent (world);
    while ((name_ent != world) && (net_name != name_ent.netname))
      name_ent = find (name_ent, classname, "zeus_bot");

    if (name_ent == world)
      free_name = true;
  }

  self.netname = net_name;
};

/*
======================
ZEUS_delayedSpawn
======================
*/
void () ZEUS_DelayedSpawn =
{
  skill = self.ZEUS_skill;
  ZEUS_SpawnOpponent (self.state, self.cnt);

  ZEUS_last_opponent.ammo_cells = self.ammo_cells;
  ZEUS_last_opponent.ammo_rockets = self.ammo_rockets;
  ZEUS_last_opponent.ammo_nails = self.ammo_nails;
  ZEUS_last_opponent.ammo_shells = self.ammo_shells;

  ZEUS_last_opponent.items = self.items;
  ZEUS_last_opponent.armorvalue = self.armorvalue;
  ZEUS_last_opponent.armortype = self.armortype;
  remove (self);
};

/*
======================
ZEUS_LevelRespawn
======================
*/
void (float name_number, float new_name) ZEUS_LevelRespawn =
{
  local   entity   temp;

  temp = spawn ();
  temp.nextthink = time + random () * 8;
  temp.think = ZEUS_DelayedSpawn;
  temp.enemy = self;
  temp.state = name_number;
  temp.cnt = new_name;
  temp.ZEUS_skill = skill;
  ZEUS_spawn_temp = temp;
};

/*
======================
ZEUS_ShowScores
======================
*/
void () ZEUS_ShowScores =
{
  local   entity  head;

  head = nextent (world);
  while (head != world)
  {
     while ((head.classname != "player") && (head.classname != "zeus_bot") && (head != world))
     {
       head = nextent (head);
     }

     if (head != world)
     {
       sprint (self, PRINT_HIGH, head.netname);
       if (head.classname == "zeus_bot")
       {
         sprint (self, PRINT_HIGH, ", skill ");
         temp_text = ftos (head.ZEUS_skill);
         sprint (self, PRINT_HIGH, temp_text);
         sprint (self, PRINT_HIGH, ", has ");
       }
       else sprint (self, PRINT_HIGH, " has ");

       temp_text = ftos (head.frags);
       sprint (self, PRINT_HIGH, temp_text);
       if (head.frags == 1)
         sprint (self, PRINT_HIGH, " frag.\n");
       else
         sprint (self, PRINT_HIGH, " frags.\n");

       head = nextent (head);
     }
  }
};

/*
======================
ZEUS_ShowSkin
======================
*/

void () ZEUS_ShowSkin =
{
  sprint (self, PRINT_HIGH, "Skin #");
  temp_text = ftos (self.skin);
  sprint (self, PRINT_HIGH, temp_text);
  sprint (self, PRINT_HIGH, " selected.\n");
};

/*
======================
ZEUS_SkinUp
======================
*/
void () ZEUS_SkinUp =
{
  self.skin = self.skin + 1;
  if (self.skin > 15)
    self.skin = 0;

  ZEUS_ShowSkin ();
};

/*
======================
ZEUS_SkinDown
======================
*/
void () ZEUS_SkinDown =
{
  self.skin = self.skin - 1;
  if (self.skin < 0)
    self.skin = 15;

  ZEUS_ShowSkin ();
};

/*
======================
ZEUS_CheckImpulses
======================
*/

void () ZEUS_CheckImpulses =
{
  local   float   bitmask;
  local   entity  save, start, end;

  if (ZEUS_show_dist)
  {
    bitmask = vlen (self.origin - ZEUS_last_opponent.origin);
    temp_text = ftos (bitmask);
    sprint (self, PRINT_HIGH, temp_text);
    sprint (self, PRINT_HIGH, "\n");
  }
  else if (self.impulse == ZEUS_ACTIVATE)
  {
    if (self.bot_flag + ZEUS_opponent_bots + 1 > 15)
      sprint (self, PRINT_HIGH, "Maximum of 15 bots allowed!\n");
    else
      ZEUS_Activate (true);
  }
  else if ((self.impulse == ZEUS_DEACTIVATE) && (self.bot_flag > 0))
    ZEUS_Deactivate ();
  else if ((self.impulse == ZEUS_TELEPORT) && (self.bot_flag > 0))
  {
    ZEUS_TeleportHome();
  }
  else if ((self.impulse == ZEUS_LIGHT_TOGGLE) && (self.bot_flag > 0))
  {
    ZEUS_LightToggle ();
  }
  else if ((self.impulse == ZEUS_ATTACK_TOGGLE) && (self.bot_flag > 0))
  {
    ZEUS_AttackToggle ();
  }
  else if ((self.impulse == ZEUS_VIEW_TOGGLE) && (self.bot_flag > 0))
  {
    if (self.bot_view == false)
    {
      ZEUS_SetBotView ();
    }
    else
    {
      ZEUS_SetPlayerView ();
    }
  }
  else if ((self.impulse == ZEUS_STAY_TOGGLE) && (self.bot_flag > 0))
  {
    ZEUS_Stay ();
  }
  else if (self.impulse == ZEUS_SPAWN_OPPONENT)
  {
    if (self.bot_flag + ZEUS_opponent_bots + 1 > 15)
      sprint (self, PRINT_HIGH, "Maximum of 15 bots allowed!\n");
    else
      ZEUS_SpawnOpponent (0, true);
  }
  else if ((self.impulse == ZEUS_GIVE_STATUS) && (self.bot_flag > 0))
  {
    ZEUS_GiveStatus ();
  }

  // debugging impulse
  else if (self.impulse == ZEUS_KILL_ALL)
  {
    ZEUS_KillAllMonsters ();
  }
  else if ((self.impulse == ZEUS_FORCE_AXE) && (self.bot_flag > 0))
  {
    self.bot.ZEUS_only_axe = !self.bot.ZEUS_only_axe;

    if (self.bot.ZEUS_only_axe)
      sprint (self, PRINT_HIGH, "Zeusbot: I love a bloody hatchet!\n");
    else
      sprint (self, PRINT_HIGH, "Zeusbot: [sigh...] If you insist.\n");
  }
  else if (self.impulse == ZEUS_VERBOSE_TOGGLE)
  {
    ZEUS_verbose = !ZEUS_verbose;

    if (ZEUS_verbose)
      sprint (self, PRINT_HIGH, "VERBOSE ON.\n");
    else
      sprint (self, PRINT_HIGH, "VERBOSE OFF.\n");
  }
  else if (self.impulse == ZEUS_DEBUG_TOGGLE)
  {
    ZEUS_debug = !ZEUS_debug;

    if (ZEUS_debug)
      sprint (self, PRINT_HIGH, "DEBUG ON.\n");
    else
      sprint (self, PRINT_HIGH, "DEBUG OFF.\n");
  }
  else if ((self.impulse == ZEUS_ROAM_TOGGLE) && (self.bot_flag > 0))
  {
    self.bot.ZEUS_roam = !self.bot.ZEUS_roam;

    if (self.bot.ZEUS_roam)
      sprint (self, PRINT_HIGH, "Zeusbot: ROAMING ENABLED.\n");
    else
    {
      sprint (self, PRINT_HIGH, "Zeusbot: ROAMING DISABLED.\n");
    }
  }
  else if ((self.impulse == ZEUS_COMMENT_TOGGLE))
  {
    ZEUS_comments = !ZEUS_comments;

    if (ZEUS_comments)
      sprint (self, PRINT_HIGH, "Zeusbot: COMMENTS DISABLED.\n");
    else
    {
      sprint (self, PRINT_HIGH, "Zeusbot: COMMENTS ENABLED.\n");
    }
  }
  else if ((self.impulse == ZEUS_PLAYER_INVUL))
  {
    if (self.takedamage == DAMAGE_AIM)
    {
      self.takedamage = DAMAGE_NO;
      sprint (self, PRINT_HIGH, "DAMAGE DISABLED.\n");
    }
    else
    {
      self.takedamage = DAMAGE_AIM;
      sprint (self, PRINT_HIGH, "DAMAGE ENABLED.\n");
    }
  }
  else if (self.impulse == ZEUS_SHOW_SCORES)
  {
    ZEUS_ShowScores ();
  }
  else if (self.impulse == ZEUS_SHOW_UNREACHABLES)
  {
    sprint (self, PRINT_HIGH, "UR_1 = ");
    sprint (self, PRINT_HIGH, self.bot.ZEUS_UR_item_1.classname);
    sprint (self, PRINT_HIGH, ", yaw = ");
    temp_text = ftos (self.bot.ZEUS_UR_yaw_1);
    sprint (self, PRINT_HIGH, temp_text);
    sprint (self, PRINT_HIGH, "\n");
    sprint (self, PRINT_HIGH, "UR_2 = ");
    sprint (self, PRINT_HIGH, self.bot.ZEUS_UR_item_2.classname);
    sprint (self, PRINT_HIGH, ", yaw = ");
    temp_text = ftos (self.bot.ZEUS_UR_yaw_2);
    sprint (self, PRINT_HIGH, temp_text);
    sprint (self, PRINT_HIGH, "\n");
    sprint (self, PRINT_HIGH, "UR_3 = ");
    sprint (self, PRINT_HIGH, self.bot.ZEUS_UR_item_3.classname);
    sprint (self, PRINT_HIGH, ", yaw = ");
    temp_text = ftos (self.bot.ZEUS_UR_yaw_3);
    sprint (self, PRINT_HIGH, temp_text);
    sprint (self, PRINT_HIGH, "\n");
  }
  else if (self.impulse == ZEUS_DROP_BACKPACK)
  {
    local   entity  temp;

    temp = self;
    self = self.bot;

    ZEUS_DropBackpack ();

    self = temp;
  }
  else if ((self.impulse == ZEUS_SHOW_OPP_DIST))
  {
    ZEUS_show_dist = !ZEUS_show_dist;
    if (ZEUS_show_dist)
      sprint (self, PRINT_HIGH, "DISTANCE ON.\n");
    else
      sprint (self, PRINT_HIGH, "DISTANCE OFF.\n");
  }
  else if ((self.impulse == ZEUS_OBSERVER_TOGGLE))
  {
    if (self.flags & FL_NOTARGET)
    {
      self.flags = self.flags - FL_NOTARGET;
      sprint (self, PRINT_HIGH, "OBSERVER MODE OFF.\n");
    }
    else
    {
      self.flags = self.flags | FL_NOTARGET;
      sprint (self, PRINT_HIGH, "OBSERVER MODE ON.\n");
    }
  }
  else if ((self.impulse == ZEUS_HUD_TOGGLE) && (!deathmatch))
  {
    HUD_active = !HUD_active;
    if (HUD_active)
    {
      sprint (self, PRINT_HIGH, "Holo-HUD activated.\n");
      if (self.bot_flag > 0)
        HUD_StatusOn (self.bot, self);
      else
        HUD_StatusOn (self, self);
    }
    else
    {
      sprint (self, PRINT_HIGH, "Holo-HUD deactivated.\n");
      HUD_StatusOff ();
    }
  }
  else if (self.impulse == MULTISKIN_UP)
    ZEUS_SkinUp ();
  else if (self.impulse == MULTISKIN_DOWN)
    ZEUS_SkinDown ();
  else if (self.impulse == ZEUS_SPAWN_MULTI)
  {
    skill = 0;
    ZEUS_SpawnOpponent (0, true);
    skill = 1;
    ZEUS_SpawnOpponent (0, true);
    skill = 2;
    ZEUS_SpawnOpponent (0, true);
    skill = 3;
    ZEUS_SpawnOpponent (0, true);
  }
  else if (self.impulse == ZEUS_CHECK_TERRAIN)
  {
/*
    makevectors (self.v_angle);
    ZEUS_TerrainType (v_forward, v_right, 256);
*/
    if (ZEUS_CheckGap (64))
      bprint (PRINT_HIGH, "gap found\n");
    else
      bprint (PRINT_HIGH, "no gap\n");
  }
  else if ((self.impulse == ZEUS_TOGGLE_ROAM_GOAL) && (self.bot_flag > 0))
  {
    if (self.bot.movetarget.model == "")
    {
      sprint (self, PRINT_HIGH, "ROAM GOAL VISIBLE.\n");
      setmodel (self.bot.movetarget, "progs/shambler.mdl");
    }
    else
    {
      sprint (self, PRINT_HIGH, "ROAM GOAL NOT VISIBLE.\n");
      setmodel (self.bot.movetarget, "");
    }
  }
  else if ((self.impulse == MULTISKIN_TOGGLE))
  {
    ZEUS_multiskin = !ZEUS_multiskin;

    if (ZEUS_multiskin)
      sprint (self, PRINT_HIGH, "MULTISKIN ON.\n");
    else
    {
      sprint (self, PRINT_HIGH, "MULTISKIN OFF.\n");
    }
  }
  else if (self.impulse == ZEUS_TOGGLE_NODES)
    ZEUS_ToggleNodesVis ();
  else if (self.impulse == ZEUS_EXTRAS_TOGGLE)
  {
    if (ZEUS_extras)
    {
      ZEUS_extras = false;
      bprint (PRINT_HIGH, "EXTRAS OFF.\n");
    }
    else
    {
      ZEUS_extras = true;
      bprint (PRINT_HIGH, "EXTRAS ON.\n");
    }
  }
  else if (self.impulse == ZEUS_SHOW_NODE_INFO)
  {
    ZEUS_ShowItemsInNode (self.ZEUS_cur_map_node);
  }
  else if (self.impulse == ZEUS_SHOW_PATH)
  {
    start = ZEUS_CurrentNode (self);
    if (random () < 0.5)
      end = ZEUS_FindItem ("weapon_rocketlauncher");
    else
      end = ZEUS_FindItem ("item_armorInv");

    if (end)
      ZEUS_ShortestPath (start, end);
  }
  else if (self.impulse == ZEUS_GO_TO_ITEM)
  {
    save = self;
    self = self.bot;
    if (self)
    {
      start = ZEUS_CurrentNode (self);
      end = ZEUS_FindItem ("weapon_grenadelauncher");

      if (end)
        ZEUS_ShortestPath (start, end);
    }
    self = save;
  }
  else if (self.impulse == ZEUS_SHOW_LINKS)
  {
    bitmask = random () * 1000;
    stuffcmd (self, "sv_gravity ");
    temp_text = ftos (bitmask);
    stuffcmd (self, temp_text);
    stuffcmd (self, "\n");
    stuffcmd (self, "sv_gravity ");
    stuffcmd (self, temp_text);
    stuffcmd (self, "\n");

//    ZEUS_ShowLinks ();
  }
   else if (self.impulse == ZEUS_PATH_TOGGLE)
  {
    if (ZEUS_pathing)
	{
		ZEUS_pathing = 0;
		sprint (self, PRINT_HIGH, "Pathing off.\n");
	}
    else
	{
	    ZEUS_pathing = 1;
		sprint (self, PRINT_HIGH, "Pathing on.\n");
	}
  }
  else if (self.impulse == 250)
  {
    makevectors (self.angles);
    ZEUS_FindLedge (64);
  }

  HUD_Init ();
};

