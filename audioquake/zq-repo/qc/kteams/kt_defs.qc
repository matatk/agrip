/*
	kt_defs.qc

	global definitions for kteams

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

#define KTEAMS

float framechecks;	    // if timedemo/uptime bugs are tolerated
float k_attendees;      // stores number of players on server - used in 'ready' checking
float k_berzerk;        // boolean - whether or not the game is currently in berzerk time
float k_berzerkenabled; // actually stores the amount of berzerk time at the end of match
float k_captains;	    // number of captains
float k_captainturn;	// which captain comes in line to pick
float k_checkx = 0;
float k_force;          // used in forcing matchstart
float k_maxspeed;       // used to store server maxspeed to allow switching by admins
float k_nochange = 0;   // used to indicate if scores changed since last time 'scores' command was called
float k_oldmaxspeed;    // used to store old value of maxspeed prior to freezing the map
float k_pause = 0;
float k_pausetime;      // stores time at which server was paused
float k_scores1;        // stores team1 combined score
float k_scores2;        // stores team2 combined score
float k_showscores;     // whether or not should print the scores or not
float k_standby;        // if server is in standy mode
float k_sudden_death;	// to mark if sudden death overtime is currently the case
float k_teamid = 0;
float k_userid = 0;
float k_vbreak;         // break vote counter
float k_velect;         // election vote counter
float k_whonottime;     // NOT_SURE: 
float lock = 0;         // stores whether players can join when a game is already in progress
float match_in_progress = 0;    // if a match has begun
float match_over;       // boolean - whether or not the match stats have been printed at end of game
string newcomer;        // stores name of last player who joined

.float cnt2;            // NOT_SURE: cnt2 = seconds left?
.float dead_time;       // time at which player last died - used in autorespawn
.float deaths;          // number of times player died
.float efficiency;      // stores player efficiency rating
.float fraggie;         // NOT_SURE: used to return frags to rejoining players?
.float friendly;        // number of times player killed teammates
.float ready;           // if a player is ready or not
.string killer;         // name of player who last killed player
.string victim;         // name of player last killed

.entity k_lastspawn;    // NOT_SURE: spot at which player last spawned?
.entity k_playertokick; // player selected to be kicked
.float k_1spawn;        // NOT_SURE: used in kteams respawn code...
.float k_666;           // if player has 666 respawn protection
.float k_accepted;      // NOT_SURE:
.float k_added;         // NOT_SURE: stores the entered admin code?
.float k_adminc;        // number of digits of admin code still to enter
.float k_admin;         // if player is an admin
.float k_captain;       // if player is team captain
.float k_domapstuff;    // NOT_SURE: if spec has 'done' map stuff?
.float k_flag;          // flagvalue to customise settings such as sounds/autoscreenshot
.float k_kicking;       // if player is in kick mode
.float k_msgcount;      // NOT_SURE: last time mod printed a message to client?
.float k_picked;        // NOT_SURE: 
.float k_pickup;        // NOT_SURE: if player wants pickup game or not?
.float k_ptime;         // stores player nexttime value when server is paused
.float k_stuff;         // if player has received stuffed aliases
.float k_teamnumber;    // team the player is a member of, 1 = team1, 2 = team2
.float k_teamnum;       // NOT_SURE:
.float k_track;         // NOT_SURE: something to do with spectator tracking code
.float k_vote2;         // stores player election vote decision
.float k_vote;          // stores player map vote decision
.string kick_ctype;     // if selected player to kick is player or spectator

float intermission_running;
float intermission_exittime;

// Zibbo's frametime checking code
.float real_time;
.float uptimebugpolicy;
.float lastwepfired;

// k_oldspeed is commented out in main code so could probably be deleted
// from both
// .vector k_oldspeed;

.float maxspeed;       // Used to set Maxspeed on a player moved from old qw defs.qc
float server_is_2_3x;	// if true, fix the jump bug via QC
float current_maxfps;	// current value of serverinfo maxfps
