/*
	ktffa_defs.qc

	ktffa global definitions

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

#define KTFFA

float intermission_exittime;
float intermission_getting_closer;
float intermission_running;
float k_vote;
float mytime;
string newcomer;

.entity k_lastspawn;
.float dead_time;
.float deaths;
.float efficiency;
.float k_1spawn;
.float k_stuff;
.float k_voted;
.float real_time;
.float uptimebugpolicy;
.string killer;
.string victim;

float server_is_2_3x;	// if true, fix the jump bug via QC
float current_maxfps;	// current value of serverinfo maxfps

// constants for the impulse commands:
const float  KT_IMPULSE_VOTE_CHANGE           =  13;
const float  KT_IMPULSE_VOTE_YES              =  14;
const float  KT_IMPULSE_VOTE_NO               =  15;
const float  KT_IMPULSE_PRINT_SCORES          =  16;
const float  KT_IMPULSE_PRINT_CMDS            =  17;
const float  KT_IMPULSE_MSG_KILLER            =  18;
const float  KT_IMPULSE_MSG_VICTIM            =  19;
const float  KT_IMPULSE_MSG_NEWCOMER          =  20;
const float  KT_IMPULSE_PRINT_VERSION         =  21;

