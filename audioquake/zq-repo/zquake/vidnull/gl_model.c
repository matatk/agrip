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
// gl_model.c -- model loading and caching

#include "gl_local.h"
#include "rc_wad.h"
#include "crc.h"

model_t	*loadmodel;

//void Mod_LoadSpriteModel (model_t *mod, void *buffer);
//void Mod_LoadBrushModel (model_t *mod, void *buffer);
//void Mod_LoadAliasModel (model_t *mod, void *buffer);
model_t *Mod_LoadModel (model_t *mod, qbool crash);

byte	mod_novis[MAX_MAP_LEAFS/8];

#define	MAX_MOD_KNOWN	512
model_t	mod_known[MAX_MOD_KNOWN];
int		mod_numknown;

void Mod_ClearAll (void)
{
}

void Mod_TouchModel (char *name)
{
}

model_t *Mod_ForName (char *name, qbool crash)
{
}

int R_ModelFlags (const struct model_s *model)
{
}

unsigned short R_ModelChecksum (const struct model_s *model)
{
}

