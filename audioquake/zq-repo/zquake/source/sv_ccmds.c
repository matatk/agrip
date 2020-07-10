/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// sv_ccmds.c - server console commands

#include "server.h"

cvar_t	sv_cheats = {"sv_cheats", "0"};
qbool	sv_allow_cheats = false;

int		fp_messages=4, fp_persecond=4, fp_secondsdead=10;
cvar_t	sv_floodprotmsg = {"floodprotmsg", ""};

extern cvar_t cl_warncmd;
extern redirect_t sv_redirected;


/*
===============================================================================

OPERATOR CONSOLE ONLY COMMANDS

These commands can only be entered from stdin or by a remote operator datagram
===============================================================================
*/

/*
==================
SV_Quit_f
==================
*/
void SV_Quit_f (void)
{
	Com_Printf ("Shutting down.\n");
	Host_Quit ();
}

#define MAX_LOGFILES	1000

/*
============
SV_Fraglogfile_f
============
*/
void SV_Fraglogfile_f (void)
{
	char	name[MAX_OSPATH];
	int		i;

	if (sv_fraglogfile)
	{
		Com_Printf ("Frag file logging off.\n");
		fclose (sv_fraglogfile);
		sv_fraglogfile = NULL;
		return;
	}

	// find an unused name
	for (i=0 ; i<MAX_LOGFILES ; i++)
	{
		Q_snprintfz (name, sizeof(name), "%s/frag_%i.log", com_gamedir, i);
		sv_fraglogfile = fopen (name, "r");
		if (!sv_fraglogfile)
		{	// can't read it, so create this one
			sv_fraglogfile = fopen (name, "w");
			if (!sv_fraglogfile)
				i=MAX_LOGFILES;	// give error
			break;
		}
		fclose (sv_fraglogfile);
	}
	if (i==MAX_LOGFILES)
	{
		Com_Printf ("Couldn't open any logfiles.\n");
		sv_fraglogfile = NULL;
		return;
	}

	Com_Printf ("Logging frags to %s.\n", name);
}


/*
==================
SV_SetPlayer

Sets sv_client and sv_player to the player with idnum Cmd_Argv(1)
==================
*/
qbool SV_SetPlayer (void)
{
	client_t	*cl;
	int			i;
	int			idnum;

	idnum = atoi(Cmd_Argv(1));

	for (i=0,cl=svs.clients ; i<MAX_CLIENTS ; i++,cl++)
	{
		if (!cl->state)
			continue;
		if (cl->userid == idnum)
		{
			sv_client = cl;
			sv_player = sv_client->edict;
			return true;
		}
	}
	Com_Printf ("Userid %i is not on the server\n", idnum);
	return false;
}


/*
======================
SV_Map_f

handle a 
map <mapname>
command from the console or progs.
======================
*/
void SV_Map_f (void)
{
	char	expanded[MAX_QPATH];
	FILE	*f;

	if (Cmd_Argc() != 2) {
		Com_Printf ("map <mapname> : continue game on a new map\n");
		return;
	}

	// check to make sure the level exists
	Q_snprintfz (expanded, sizeof(expanded), "maps/%s.bsp", Cmd_Argv(1));
	FS_FOpenFile (expanded, &f);
	if (!f) {
		Com_Printf ("Can't find %s\n", expanded);
		return;
	}
	fclose (f);

	NET_ServerConfig (true);

	if (!dedicated)
		CL_BeginLocalConnection ();

	SV_BroadcastCommand ("changing\n");
	SV_SendMessagesToAll ();

	SV_SpawnServer (Cmd_Argv(1), !Q_stricmp(Cmd_Argv(0), "devmap"));

	SV_BroadcastCommand ("reconnect\n");
}


/*
================
SV_KillServer_f

================
*/
void SV_KillServer_f (void)
{
	SV_Shutdown ("Server was killed\n");
}


/*
==================
SV_Kick_f

Kick a user off of the server
==================
*/
void SV_Kick_f (void)
{
	int			i, j;
	client_t	*cl;
	int			uid;
	int			c;
	int			saved_state;
	char		reason[80] = "";

	c = Cmd_Argc ();
	if (c < 2) {
#ifndef SERVERONLY
		// some mods use a "kick" alias for their own needs, sigh
		if (CL_ClientState() && Cmd_FindAlias("kick")) {
			Cmd_ExecuteString (Cmd_AliasString("kick"));
			return;
		}
#endif
		Com_Printf ("kick <userid> [reason]\n");
		return;
	}

	uid = atoi(Cmd_Argv(1));
	
	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if (!cl->state)
			continue;
		if (cl->userid == uid)
		{
			if (c > 2) {
				strcpy (reason, " (");
				for (j=2 ; j<c; j++) {
					strncat (reason, Cmd_Argv(j), sizeof(reason)-4);
					if (j < c-1)
						strncat (reason, " ", sizeof(reason)-4);
				}
				if (strlen(reason) < 3)
					reason[0] = '\0';
				else
					strncat (reason, ")", sizeof(reason));
			}

			saved_state = cl->state;
			cl->state = cs_free; // HACK: don't broadcast to this client
			SV_BroadcastPrintf (PRINT_HIGH, "%s was kicked%s\n", cl->name, reason);
			cl->state = saved_state;
			SV_ClientPrintf (cl, PRINT_HIGH, "You were kicked from the game%s\n", reason);
			SV_DropClient (cl); 
			return;
		}
	}

	Com_Printf ("Couldn't find user number %i\n", uid);
}


/*
================
SV_Status_f
================
*/
void SV_Status_f (void)
{
	int			i, j, l;
	client_t	*cl;
	float		cpu, avg, pak;
	char		*s;

#ifndef SERVERONLY
	// some mods use a "status" alias for their own needs, sigh
	if (!sv_redirected && !Q_stricmp(Cmd_Argv(0), "status")
		&& CL_ClientState() && Cmd_FindAlias("status")) {
		Cmd_ExecuteString (Cmd_AliasString("status"));
		return;
	}
#endif

	cpu = (svs.stats.latched_active+svs.stats.latched_idle);
	if (cpu)
		cpu = 100*svs.stats.latched_active/cpu;
	avg = 1000*svs.stats.latched_active / STATFRAMES;
	pak = (float)svs.stats.latched_packets/ STATFRAMES;

	Com_Printf ("net address      : %s\n",NET_AdrToString (net_local_adr));
	Com_Printf ("cpu utilization  : %3i%%\n",(int)cpu);
	Com_Printf ("avg response time: %i ms\n",(int)avg);
	Com_Printf ("packets/frame    : %5.2f (%d)\n", pak, num_prstr);
	
// min fps lat drp
	if (sv_redirected != RD_NONE) {
		// most remote clients are 40 columns
		//           0123456789012345678901234567890123456789
		Com_Printf ("name               userid frags\n");
        Com_Printf ("  address          rate ping drop\n");
		Com_Printf ("  ---------------- ---- ---- -----\n");
		for (i=0,cl=svs.clients ; i<MAX_CLIENTS ; i++,cl++)
		{
			if (!cl->state)
				continue;

			Com_Printf ("%-16.16s  ", cl->name);

			Com_Printf ("%6i %5i", cl->userid, (int)cl->edict->v.frags);
			if (cl->spectator)
				Com_Printf (" (s)\n");
			else			
				Com_Printf ("\n");

			s = NET_BaseAdrToString ( cl->netchan.remote_address);
			Com_Printf ("  %-16.16s", s);
			if (cl->state == cs_connected)
			{
				Com_Printf ("CONNECTING\n");
				continue;
			}
			if (cl->state == cs_zombie)
			{
				Com_Printf ("ZOMBIE\n");
				continue;
			}
			Com_Printf ("%4i %4i %5.2f\n"
				, (int)(1000*cl->netchan.frame_rate)
				, (int)SV_CalcPing (cl)
				, 100.0*cl->netchan.drop_count / cl->netchan.incoming_sequence);
		}
	} else {
		Com_Printf ("frags userid address         name            rate ping drop  qport\n");
		Com_Printf ("----- ------ --------------- --------------- ---- ---- ----- -----\n");
		for (i=0,cl=svs.clients ; i<MAX_CLIENTS ; i++,cl++)
		{
			if (!cl->state)
				continue;
			Com_Printf ("%5i %6i ", (int)cl->edict->v.frags,  cl->userid);

			s = NET_BaseAdrToString ( cl->netchan.remote_address);
			Com_Printf ("%s", s);
			l = 16 - strlen(s);
			for (j=0 ; j<l ; j++)
				Com_Printf (" ");
			
			Com_Printf ("%s", cl->name);
			l = 16 - strlen(cl->name);
			for (j=0 ; j<l ; j++)
				Com_Printf (" ");
			if (cl->state == cs_connected)
			{
				Com_Printf ("CONNECTING\n");
				continue;
			}
			if (cl->state == cs_zombie)
			{
				Com_Printf ("ZOMBIE\n");
				continue;
			}
			Com_Printf ("%4i %4i %3.1f %4i"
				, (int)(1000*cl->netchan.frame_rate)
				, (int)SV_CalcPing (cl)
				, 100.0*cl->netchan.drop_count / cl->netchan.incoming_sequence
				, cl->netchan.qport);
			if (cl->spectator)
				Com_Printf (" (s)\n");
			else			
				Com_Printf ("\n");

				
		}
	}
	Com_Printf ("\n");
}

/*
==================
SV_ConSay_f
==================
*/
void SV_ConSay_f(void)
{
	client_t *client;
	int		j;
	char	*p;
	char	text[1024];

	if (Cmd_Argc () < 2)
		return;

	strcpy (text, "console: ");
	p = Cmd_Args();

	if (*p == '"')
	{
		p++;
		p[strlen(p)-1] = 0;
	}

	strcat(text, p);

	for (j = 0, client = svs.clients; j < MAX_CLIENTS; j++, client++)
	{
		if (client->state != cs_spawned)
			continue;
		SV_ClientPrintf(client, PRINT_CHAT, "%s\n", text);
	}
}


void SV_SendServerInfoChange(char *key, char *value)
{
	if (!sv.state)
		return;

	MSG_WriteByte (&sv.reliable_datagram, svc_serverinfo);
	MSG_WriteString (&sv.reliable_datagram, key);
	MSG_WriteString (&sv.reliable_datagram, value);
}

/*
==================
SV_ServerinfoChanged

Cvar system calls this when a CVAR_SERVERINFO cvar changes
==================
*/
void SV_ServerinfoChanged (char *key, char *str)
{
	if ( (!strcmp(key, "pm_bunnyspeedcap") || !strcmp(key, "pm_slidefix")
		|| !strcmp(key, "pm_airstep") || !strcmp(key, "pm_pground")
		|| !strcmp(key, "samelevel") || !strcmp(key, "watervis") || !strcmp(key, "coop") )
		&& !strcmp(str, "0") ) {
		// don't add default values to serverinfo to keep it cleaner
		str = "";
	}

	if (strcmp(str, Info_ValueForKey (svs.info, key)))
	{
		Info_SetValueForKey (svs.info, key, str, MAX_SERVERINFO_STRING);
		SV_SendServerInfoChange (key, str);
	}
}


/*
===========
SV_Serverinfo_f

Examine or change the serverinfo string
===========
*/
void SV_Serverinfo_f (void)
{
	cvar_t	*var;
	char	*key, *value;

	if (Cmd_Argc() == 1)
	{
		Com_Printf ("Server info settings:\n");
		Info_Print (svs.info);
		return;
	}

	if (Cmd_Argc() != 3)
	{
		Com_Printf ("usage: serverinfo [ <key> <value> ]\n");
		return;
	}

	key = Cmd_Argv(1);
	value = Cmd_Argv(2);

	if (key[0] == '*')
	{
		Com_Printf ("Star variables cannot be changed.\n");
		return;
	}

	if (!strcmp(key, "maxpitch") || !strcmp(Cmd_Argv(1), "minpitch")) {
		Cvar_Set (Cvar_FindVar(va("sv_%s", key)), value);
		return;		// cvar callbacks will take care of updating serverinfo
	}

#ifdef VWEP_TEST
	if (!strcmp(key, "#vw"))
		return;		// reserved for VWep precaches
#endif

	Info_SetValueForKey (svs.info, key, value, MAX_SERVERINFO_STRING);

	// if the key is also a serverinfo cvar, change it too
	var = Cvar_FindVar (key);
	if (var && (var->flags & CVAR_SERVERINFO))
	{
		// a hack - strip the serverinfo flag so that the Cvar_Set
		// doesn't trigger SV_ServerinfoChanged
		var->flags &= ~CVAR_SERVERINFO;
		Cvar_Set (var, Cmd_Argv(2));
		var->flags |= CVAR_SERVERINFO;		// put it back
	}

	// FIXME, don't send if the key hasn't changed
	SV_SendServerInfoChange (key, value);
}


/*
===========
SV_Localinfo_f

Examine or change the localinfo string
===========
*/
void SV_Localinfo_f (void)
{
	if (Cmd_Argc() == 1)
	{
		Com_Printf ("Local info settings:\n");
		Info_Print (localinfo);
		return;
	}

	if (Cmd_Argc() != 3)
	{
		Com_Printf ("usage: localinfo [ <key> <value> ]\n");
		return;
	}

	if (Cmd_Argv(1)[0] == '*')
	{
		Com_Printf ("Star variables cannot be changed.\n");
		return;
	}
	Info_SetValueForKey (localinfo, Cmd_Argv(1), Cmd_Argv(2), MAX_LOCALINFO_STRING);
}


/*
===========
SV_User_f

Examine a users info strings
===========
*/
void SV_User_f (void)
{
	if (Cmd_Argc() != 2)
	{
		Com_Printf ("Usage: user <userid>\n");
		return;
	}

	if (!SV_SetPlayer ())
		return;

	Info_Print (sv_client->userinfo);
}

/*
================
SV_Gamedir

Sets the fake *gamedir to a different directory.
================
*/
void SV_Gamedir (void)
{
	char			*dir;

	if (Cmd_Argc() == 1)
	{
		Com_Printf ("Current *gamedir: %s\n", Info_ValueForKey (svs.info, "*gamedir"));
		return;
	}

	if (Cmd_Argc() != 2)
	{
		Com_Printf ("Usage: sv_gamedir <newgamedir>\n");
		return;
	}

	dir = Cmd_Argv(1);

	if (strstr(dir, "..") || strstr(dir, "/")
		|| strstr(dir, "\\") || strstr(dir, ":") )
	{
		Com_Printf ("*gamedir should be a single filename, not a path\n");
		return;
	}

	Info_SetValueForStarKey (svs.info, "*gamedir", dir, MAX_SERVERINFO_STRING);
}

/*
================
SV_Floodport_f

Sets the gamedir and path to a different directory.
================
*/

void SV_Floodprot_f (void)
{
	int arg1, arg2, arg3;
	
	if (Cmd_Argc() == 1)
	{
		if (fp_messages) {
			Com_Printf ("Current floodprot settings: \nAfter %d msgs per %d seconds, silence for %d seconds\n", 
				fp_messages, fp_persecond, fp_secondsdead);
			return;
		} else
			Com_Printf ("No floodprots enabled.\n");
	}

	if (Cmd_Argc() != 4)
	{
		Com_Printf ("Usage: floodprot <# of messages> <per # of seconds> <seconds to silence>\n");
		Com_Printf ("Use floodprotmsg to set a custom message to say to the flooder.\n");
		return;
	}

	arg1 = atoi(Cmd_Argv(1));
	arg2 = atoi(Cmd_Argv(2));
	arg3 = atoi(Cmd_Argv(3));

	if (arg1<=0 || arg2 <= 0 || arg3<=0) {
		Com_Printf ("All values must be positive numbers\n");
		return;
	}
	
	if (arg1 > 10) {
		Com_Printf ("Can only track up to 10 messages.\n");
		return;
	}

	fp_messages	= arg1;
	fp_persecond = arg2;
	fp_secondsdead = arg3;
}

/*
================
SV_Gamedir_f

Sets the gamedir and path to a different directory.
================
*/
void SV_Gamedir_f (void)
{
	char			*dir;

	if (Cmd_Argc() == 1)
	{
		Com_Printf ("Current gamedir: %s\n", com_gamedirfile);
		return;
	}

	if (Cmd_Argc() != 2)
	{
		Com_Printf ("Usage: gamedir <newdir>\n");
		return;
	}

	dir = Cmd_Argv(1);

	if (strstr(dir, "..") || strstr(dir, "/")
		|| strstr(dir, "\\") || strstr(dir, ":") )
	{
		Com_Printf ("gamedir should be a single filename, not a path\n");
		return;
	}

#ifndef SERVERONLY
	if (CL_ClientState())
	{
		Com_Printf ("you must disconnect before changing gamedir\n");
		return;
	}
#endif

	FS_SetGamedir (dir);

#if 0
	// Tonik: this is to fight lame admins having all sorts of shit in their servers'
	// *gamedir, causing nuisance like configs and downloads being written
	// where you don't really want them to be.
	// Fortress, arena, etc do need a separate *gamedir; for everything else,
	// you'll have to force it with "sv_gamedir foo" if indeed necessary
	if (!strcmp(dir, "fortress") || !strcmp(dir, "arena") || !strcmp(dir, "ctf")
		|| !strcmp(dir, "rogue") || !strcmp(dir, "hipnotic"))
		Info_SetValueForStarKey (svs.info, "*gamedir", dir, MAX_SERVERINFO_STRING);
	else
		Info_SetValueForStarKey (svs.info, "*gamedir", "", MAX_SERVERINFO_STRING);
#else
	Info_SetValueForStarKey (svs.info, "*gamedir", dir, MAX_SERVERINFO_STRING);
#endif
}

/*
================
SV_Snap
================
*/
void SV_Snap (int uid)
{
	client_t	*cl;
	char		pcxname[80]; 
	char		checkname[MAX_OSPATH];
	int			i;
	FILE		*f;

	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if (cl->state < cs_connected)
			continue;
		if (cl->userid == uid)
			break;
	}
	if (i >= MAX_CLIENTS) {
		Com_Printf ("userid not found\n");
		return;
	}

	COM_CreatePath (va("%s/snap/", com_gamedir));
	sprintf (pcxname, "%d-00.pcx", uid);
		
	for (i=0 ; i<=99 ; i++) 
	{ 
		pcxname[strlen(pcxname) - 6] = i/10 + '0'; 
		pcxname[strlen(pcxname) - 5] = i%10 + '0'; 
		Q_snprintfz (checkname, sizeof(checkname), "%s/snap/%s", com_gamedir, pcxname);
		f = fopen (checkname, "rb");
		if (!f)
			break;  // file doesn't exist
		fclose (f);
	} 
	if (i==100) 
	{
		Com_Printf ("Snap: Couldn't create a file, clean some out.\n"); 
		return;
	}
	strcpy(cl->uploadfn, checkname);

	memcpy(&cl->snap_from, &net_from, sizeof(net_from));
	if (sv_redirected != RD_NONE)
		cl->remote_snap = true;
	else
		cl->remote_snap = false;

	ClientReliableWrite_Begin (cl, svc_stufftext);
	ClientReliableWrite_String ("cmd snap\n");
	ClientReliableWrite_End ();
	Com_Printf ("Requesting snap from user %d...\n", uid);
}

/*
================
SV_Snap_f
================
*/
void SV_Snap_f (void)
{
	int			uid;

	if (Cmd_Argc() != 2)
	{
		Com_Printf ("Usage: snap <userid>\n");
		return;
	}

	uid = atoi(Cmd_Argv(1));

	SV_Snap(uid);
}

/*
================
SV_Snap
================
*/
void SV_SnapAll_f (void)
{
	client_t *cl;
	int			i;

	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if (cl->state < cs_connected || cl->spectator)
			continue;
		SV_Snap (cl->userid);
	}
}

/*
==================
SV_InitOperatorCommands
==================
*/
void SV_InitOperatorCommands (void)
{
	Cvar_Register (&sv_cheats);

	if (COM_CheckParm ("-cheats"))
	{
		sv_allow_cheats = true;
		Cvar_SetValue (&sv_cheats, 1);
		Info_SetValueForStarKey (svs.info, "*cheats", "ON", MAX_SERVERINFO_STRING);
	}

	Cmd_AddCommand ("fraglogfile", SV_Fraglogfile_f);

	Cmd_AddCommand ("snap", SV_Snap_f);
	Cmd_AddCommand ("snapall", SV_SnapAll_f);
	Cmd_AddCommand ("kick", SV_Kick_f);
	Cmd_AddCommand ("status", SV_Status_f);
	Cmd_AddCommand ("serverstatus", SV_Status_f);

	Cmd_AddCommand ("map", SV_Map_f);
	Cmd_AddCommand ("devmap", SV_Map_f);
	Cmd_AddCommand ("killserver", SV_KillServer_f);

	Cmd_AddCommand ("setmaster", SV_SetMaster_f);
	Cmd_AddCommand ("heartbeat", SV_Heartbeat_f);

	if (dedicated) {
		Cmd_AddCommand ("say", SV_ConSay_f);
		Cmd_AddCommand ("quit", SV_Quit_f);
		Cmd_AddCommand ("user", SV_User_f);
		Cmd_AddCommand ("serverinfo", SV_Serverinfo_f);
	}

#ifndef SERVERONLY
	if (!dedicated) {
		Cmd_AddCommand ("save", SV_SaveGame_f);
		Cmd_AddCommand ("load", SV_LoadGame_f);
	}
#endif

	Cmd_AddCommand ("localinfo", SV_Localinfo_f);
	Cmd_AddCommand ("gamedir", SV_Gamedir_f);
	Cmd_AddCommand ("sv_gamedir", SV_Gamedir);
	Cmd_AddCommand ("floodprot", SV_Floodprot_f);
	Cvar_Register (&sv_floodprotmsg);

	cl_warncmd.value = 1;
}
