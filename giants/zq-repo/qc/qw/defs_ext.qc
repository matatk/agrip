/*
	defs_ext.qc

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

//
// Extended builtins
//

// check if a builtin function is available on the server
float(string name) checkextension = #99;

// DP_QC_TRACEBOX
void (vector v1, vector mins, vector maxs, vector v2, float nomonsters, entity forent) tracebox = #90;

// ZQ_QC_STRINGS
float (string s) strlen = #114;
string(string s1, string s2) stradd = #115;
string(string s, float start, float length) substring = #116;
string(string s) strzone = #118;
void(string s) strunzone = #119;

// ZQ_QC_TOKENIZE
float tokenize(string s) = #84;
float() argc = #85;
string(float n) argv = #86;

// ZQ_SOUNDTOCLIENT
void (entity client, entity e, float chan, string samp, float vol, float atten) soundtoclient = #0x5a08;


#ifdef FRIKBOT
entity (string name) testbot = #0x5a0A;
//void (entity e, string key, string value) setinfo = #0x5a0B;
#endif


//FIXME, this will be changed
void (entity e, string key, string value) setinfo = #0x5a0B;



#ifdef VWEP_TEST
void (float index, string model) precache_vwep_model = #0x5a09;
.float vw_index;
.float vw_frame;
float vw_available;
#endif
