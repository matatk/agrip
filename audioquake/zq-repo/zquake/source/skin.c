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

#include "quakedef.h"
#include "rc_image.h"
#include "teamplay.h"

cvar_t		baseskin = {"baseskin", "base"};
cvar_t		noskins = {"noskins", "0"};

char	allskins[MAX_OSPATH];

#define	MAX_CACHED_SKINS		128
skin_t		skins[MAX_CACHED_SKINS];
int			numskins;

/*
================
Skin_Find

  Determines the best skin for the given scoreboard
  slot, and sets scoreboard->skin

================
*/
void Skin_Find (player_info_t *sc)
{
	skin_t		*skin;
	int			i;
	char		name[MAX_OSPATH], *s;
    int         tracknum;
    char        *skinforcing_team = "";

	if (allskins[0])
		strcpy (name, allskins);
	else
	{
		s = Info_ValueForKey (sc->userinfo, "skin");
		if (s && s[0])
			strcpy (name, s);
		else
			strcpy (name, baseskin.string);
	}

	if (cl.spectator && (tracknum = Cam_PlayerNum()) != -1)
		skinforcing_team = cl.players[tracknum].team;
	else if (!cl.spectator)
		skinforcing_team = cl.players[cl.playernum].team;

    
	// ZQuake: check teamskin/enemyskin
	if ( !cl.teamfortress && !(cl.fpd & FPD_NO_FORCE_SKIN) )
	{
        char *skinname = NULL;
        qbool teammate;

        teammate = (cl.teamplay && !strcmp(sc->team, skinforcing_team)) ? true : false;

		if (!skinname || !skinname[0])
			skinname = teammate ? cl_teamskin.string : cl_enemyskin.string;
        if( skinname[0] )
            strlcpy (name, skinname, sizeof(name));
	}

	if (strstr (name, "..") || *name == '.')
		strcpy (name, "base");

	COM_StripExtension (name, name);

	for (i=0 ; i<numskins ; i++)
	{
		if (!strcmp (name, skins[i].name))
		{
			sc->skin = &skins[i];
			Skin_Cache (sc->skin);
			return;
		}
	}

	if (numskins == MAX_CACHED_SKINS)
	{	// ran out of spots, so flush everything
		Skin_Skins_f ();
		return;
	}

	skin = &skins[numskins];
	sc->skin = skin;
	numskins++;

	memset (skin, 0, sizeof(*skin));
	strlcpy (skin->name, name, sizeof(skin->name));
}


/*
==========
Skin_Cache

Returns a pointer to the skin bitmap, or NULL to use the default
==========
*/
byte *Skin_Cache (skin_t *skin)
{
	int		y;
	byte	*pic, *out, *pix;
	int		width, height;
	char	name[MAX_OSPATH];

	if (cls.downloadtype == dl_skin)
		return NULL;		// use base until downloaded
	if (noskins.value == 1) // JACK: So NOSKINS > 1 will show skins, but
		return NULL;		// not download new ones.
	if (skin->failedload)
		return NULL;

	out = Cache_Check (&skin->cache);
	if (out)
		return out;

//
// load the pic from disk
//
	Q_snprintfz (name, sizeof(name), "skins/%s.pcx", skin->name);
	LoadPCX (name, &pic, &width, &height);
	if (!pic || width > 320 || height > 200)
	{
		if (pic)
			Q_free (pic);	// Q_malloc'ed by LoadPCX
		Com_Printf ("Couldn't load skin %s\n", name);

		Q_snprintfz (name, sizeof(name), "skins/%s.pcx", baseskin.string);
		LoadPCX (name, &pic, &width, &height);
		if (!pic || width > 320 || height > 200)
		{
			if (pic)
				Q_free (pic);	// Q_malloc'ed by LoadPCX
			skin->failedload = true;
			return NULL;
		}
	}

	out = pix = Cache_Alloc (&skin->cache, 320*200, skin->name);
	if (!out)
		Sys_Error ("Skin_Cache: couldn't allocate");

	memset (out, 0, 320*200);
	for (y=0 ; y<height ; y++, pix += 320)
		memcpy (pix, pic + y*width, width);

	Q_free (pic);	// Q_malloc'ed by LoadPCX

	skin->failedload = false;

	return out;
}


/*
=================
Skin_NextDownload
=================
*/
void Skin_NextDownload (void)
{
	player_info_t	*sc;
	int			i;

#ifndef AGRIP
	if (cls.downloadnumber == 0) {
		if (!com_serveractive || developer.value)
			Com_Printf ("Checking skins...\n");
	}
#endif
	cls.downloadtype = dl_skin;

	for ( 
		; cls.downloadnumber != MAX_CLIENTS
		; cls.downloadnumber++)
	{
		sc = &cl.players[cls.downloadnumber];
		if (!sc->name[0])
			continue;
		Skin_Find (sc);
		if (noskins.value)
			continue;
		if (!CL_CheckOrDownloadFile(va("skins/%s.pcx", sc->skin->name)))
			return;		// started a download
	}

	cls.downloadtype = dl_none;

	// now load them in for real
	for (i=0 ; i<MAX_CLIENTS ; i++)
	{
		sc = &cl.players[i];
		if (!sc->name[0])
			continue;
		Skin_Cache (sc->skin);
#ifdef GLQUAKE
		sc->skin = NULL;
#endif
	}

// Tonik: only download when connecting
	if (cls.state == ca_onserver)
	{	// get next signon phase
		MSG_WriteByte (&cls.netchan.message, clc_stringcmd);
		MSG_WriteString (&cls.netchan.message,
			va("begin %i", cl.servercount));
		Cache_Report ();		// print remaining memory
	}
}


/*
==========
Skin_Skins_f

Refind all skins, downloading if needed.
==========
*/
void Skin_Skins_f (void)
{
	int		i;

	for (i=0 ; i<numskins ; i++)
	{
		if (skins[i].cache.data)
			Cache_Free (&skins[i].cache);
	}
	numskins = 0;

	cls.downloadnumber = 0;
	cls.downloadtype = dl_skin;
	Skin_NextDownload ();
}


/*
==========
Skin_AllSkins_f

Sets all skins to one specific one
==========
*/
void Skin_AllSkins_f (void)
{
	strlcpy (allskins, Cmd_Argv(1), sizeof(allskins));
	Skin_Skins_f ();
}
