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

#include "gl_local.h"

// some cards have low quality of alpha pics, so load the pics
// without transparent pixels into a different scrap block.
// scrap 0 is solid pics, 1 is transparent
#define	MAX_SCRAPS		2
#define	BLOCK_WIDTH		256
#define	BLOCK_HEIGHT	256

byte	scrap_texels[MAX_SCRAPS][BLOCK_WIDTH*BLOCK_HEIGHT*4];

static qbool Scrap_AllocBlock (int scrapnum, int w, int h, int *x, int *y)
{
}

static void Scrap_Upload (void)
{
}

typedef struct cachepic_s
{
	mpic_t		pic;
	char		name[MAX_QPATH];
	int			texnum;
	float		sl, tl, sh, th;
} cachepic_t;

#define	MAX_CACHED_PICS		256
static cachepic_t	cachepics[MAX_CACHED_PICS];
static int			numcachepics;

static mpic_t *R_CachePic_impl (char *path, qbool wad, qbool crash)
{
}

mpic_t *R_CachePic (char *path)
{
}

mpic_t *R_CacheWadPic (char *name)
{
}

static int GL_LoadPicTexture (char *name, cachepic_t *cpic, byte *data)
{
}

static void OnChange_gl_smoothfont (cvar_t *var, char *string, qbool *cancel)
{
}

void R_FlushPics (void)
{
}

void R_Draw_Init (void)
{
}

void R_DrawChar (int x, int y, int num)
{
}

void R_DrawString (int x, int y, const char *str)
{
}

void R_DrawCrosshair (int num, byte color, int crossx, int crossy)
{
}

void R_DrawPic (int x, int y, mpic_t *pic)
{
	return;
}

void R_DrawSubPic (int x, int y, mpic_t *pic, int srcx, int srcy, int width, int height)
{
}

void R_DrawTransPicTranslate (int x, int y, mpic_t *pic, byte *translation)
{
}

void R_DrawStretchPic (int x, int y, int width, int height, mpic_t *pic, float alpha)
{
}

void R_DrawTile (int x, int y, int w, int h, mpic_t *pic)
{
}

void R_DrawFilledRect (int x, int y, int w, int h, int c)
{
}

void R_FadeScreen (void)
{
}

void R_BeginDisc (void)
{
}


void R_EndDisc (void)
{
}
