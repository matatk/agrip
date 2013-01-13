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
#include "rc_wad.h"
#include "crc.h"

static void	OnChange_gl_smoothfont (cvar_t *var, char *string, qbool *cancel);
cvar_t		gl_smoothfont = {"gl_smoothfont", "0", 0, OnChange_gl_smoothfont};

byte		*draw_chars;				// 8*8 graphic characters
static mpic_t	*draw_disc;

int			translate_texture;
int			char_texture;
#define		NUMCROSSHAIRS 6
int			crosshairtextures[NUMCROSSHAIRS];

static byte crosshairdata[NUMCROSSHAIRS][64] = {
	{
	0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
	0xfe, 0xff, 0xfe, 0xff, 0xfe, 0xff, 0xfe, 0xff,
	0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	},

	{
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	},

	{
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	},

	{
	0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xff,
	0xff, 0xfe, 0xff, 0xff, 0xff, 0xfe, 0xff, 0xff,
	0xff, 0xff, 0xfe, 0xff, 0xfe, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xfe, 0xff, 0xfe, 0xff, 0xff, 0xff,
	0xff, 0xfe, 0xff, 0xff, 0xff, 0xfe, 0xff, 0xff,
	0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	},

	{
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xfe, 0xff, 0xff, 0xff, 0xfe, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	},

	{
	0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xff,
	0xfe, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xfe, 0xff,
	0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	}
};


static void	R_LoadCharset (void);

/*
=============================================================================

  scrap allocation

  Allocate all the little status bar objects into a single texture
  to crutch up stupid hardware / drivers

=============================================================================
*/

// some cards have low quality of alpha pics, so load the pics
// without transparent pixels into a different scrap block.
// scrap 0 is solid pics, 1 is transparent
#define	MAX_SCRAPS		2
#define	BLOCK_WIDTH		256
#define	BLOCK_HEIGHT	256

static int	scrap_allocated[MAX_SCRAPS][BLOCK_WIDTH];
/* static */ byte	scrap_texels[MAX_SCRAPS][BLOCK_WIDTH*BLOCK_HEIGHT*4];
static int	scrap_dirty = 0;	// bit mask
static int	scrap_texnum;

// returns false if allocation failed
static qbool Scrap_AllocBlock (int scrapnum, int w, int h, int *x, int *y)
{
	int		i, j;
	int		best, best2;

	best = BLOCK_HEIGHT;
	
	for (i=0 ; i<BLOCK_WIDTH-w ; i++)
	{
		best2 = 0;
		
		for (j=0 ; j<w ; j++)
		{
			if (scrap_allocated[scrapnum][i+j] >= best)
				break;
			if (scrap_allocated[scrapnum][i+j] > best2)
				best2 = scrap_allocated[scrapnum][i+j];
		}
		if (j == w)
		{	// this is a valid spot
			*x = i;
			*y = best = best2;
		}
	}
	
	if (best + h > BLOCK_HEIGHT)
		return false;
	
	for (i=0 ; i<w ; i++)
		scrap_allocated[scrapnum][*x + i] = best + h;

	scrap_dirty |= (1 << scrapnum);

	return true;
}

static void Scrap_Upload (void)
{
	int i;

	for (i=0 ; i<2 ; i++) {
		if ( !(scrap_dirty & (1 << i)) )
			continue;
		scrap_dirty &= ~(1 << i);
		GL_Bind (scrap_texnum + i);
		GL_Upload8 (scrap_texels[i], BLOCK_WIDTH, BLOCK_HEIGHT, false, i, false);
	}
}

//=============================================================================
/* Support Routines */

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

byte		menuplyr_pixels[4096];		// the menu needs them

static int	GL_LoadPicTexture (char *name, cachepic_t *pic, byte *data);


static mpic_t *R_CachePic_impl (char *path, qbool wad, qbool crash)
{
	qpic_t	*p;
	cachepic_t	*pic;
	int		i;

	for (pic = cachepics, i = 0; i < numcachepics; pic++, i++)
		if (!strcmp (path, pic->name))
			return &pic->pic;

	if (wad) {
		p = W_GetLumpName (path, crash);
		if (!p)
			return NULL;
	}
	else {
		// load the pic from disk
		p = (qpic_t *)FS_LoadTempFile (path);	
		if (!p) {
			if (crash)
				Sys_Error ("R_CachePic: failed to load %s", path);
			else
				return NULL;
		}
		SwapPic (p);

		// HACK HACK HACK --- we need to keep the bytes for
		// the translatable player picture just for the menu
		// configuration dialog
		if (!strcmp (path, "gfx/menuplyr.lmp")) {
			if ((unsigned)(p->width*p->height) > sizeof(menuplyr_pixels))
				Sys_Error ("gfx/menuplyr.lmp has invalid dimensions");
			memcpy (menuplyr_pixels, p->data, p->width*p->height);
		}
	}

	if (numcachepics == MAX_CACHED_PICS)
		Sys_Error ("numcachepics == MAX_CACHED_PICS");

	numcachepics++;

	strlcpy (pic->name, path, sizeof(pic->name));
	pic->pic.width = p->width;
	pic->pic.height = p->height;

	// load little ones into the scrap
	if (wad && p->width < 64 && p->height < 64)
	{
		int		x, y;
		int		i, j, k;
		int		texnum;

		texnum = memchr(p->data, 255, p->width*p->height) != NULL;
		if (!Scrap_AllocBlock (texnum, p->width, p->height, &x, &y)) {
			GL_LoadPicTexture (path, pic, p->data);
			return &pic->pic;
		}
		k = 0;
		for (i=0 ; i<p->height ; i++)
			for (j=0 ; j<p->width ; j++, k++)
				scrap_texels[texnum][(y+i)*BLOCK_WIDTH + x + j] = p->data[k];
		texnum += scrap_texnum;
		pic->texnum = texnum;
		pic->sl = (x+0.01)/(float)BLOCK_WIDTH;
		pic->sh = (x+p->width-0.01)/(float)BLOCK_WIDTH;
		pic->tl = (y+0.01)/(float)BLOCK_WIDTH;
		pic->th = (y+p->height-0.01)/(float)BLOCK_WIDTH;
	}
	else
		GL_LoadPicTexture (path, pic, p->data);

	return &pic->pic;
}

mpic_t *R_CachePic (char *path)
{
	return R_CachePic_impl (path, false, true);
}

mpic_t *R_CacheWadPic (char *name)
{
	return R_CachePic_impl (name, true, false);
}


/*
================
GL_LoadPicTexture
================
*/
static int GL_LoadPicTexture (char *name, cachepic_t *cpic, byte *data)
{
	int		glwidth, glheight;
	int		i;
	char	fullname[64] = "pic:";

	strlcpy (fullname + 4, name, sizeof(fullname)-4);

	for (glwidth = 1 ; glwidth < cpic->pic.width ; glwidth<<=1)
		;
	for (glheight = 1 ; glheight < cpic->pic.height ; glheight<<=1)
		;

	if (glwidth == cpic->pic.width && glheight == cpic->pic.height)
	{
		cpic->texnum = GL_LoadTexture (fullname, glwidth, glheight, data,
						false, true, false);
		cpic->sl = 0;
		cpic->sh = 1;
		cpic->tl = 0;
		cpic->th = 1;
	}
	else
	{
		byte *src, *dest;
		byte *buf;

		buf = Q_malloc (glwidth*glheight);

		memset (buf, 0, glwidth*glheight);
		src = data;
		dest = buf;
		for (i = 0; i < cpic->pic.height; i++) {
			memcpy (dest, src, cpic->pic.width);
			src += cpic->pic.width;
			dest += glwidth;
		}

		cpic->texnum = GL_LoadTexture (fullname, glwidth, glheight, buf,
						false, true, false);
		cpic->sl = 0;
		cpic->sh = (float)cpic->pic.width / glwidth;
		cpic->tl = 0;
		cpic->th = (float)cpic->pic.height / glheight;

		Q_free (buf);
	}

	return cpic->texnum;
}


static void OnChange_gl_smoothfont (cvar_t *var, char *string, qbool *cancel)
{
	float	newval;

	newval = Q_atof (string);
	if (!newval == !gl_smoothfont.value || !char_texture)
		return;

	GL_Bind(char_texture);
        
	if (newval)
	{
		glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
	else
	{
		glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	}
}


static void R_LoadCharset (void)
{
	int i;
	byte	buf[128*256];
	byte	*src, *dest;

	draw_chars = W_GetLumpName ("conchars", true);
	for (i=0 ; i<256*64 ; i++)
		if (draw_chars[i] == 0)
			draw_chars[i] = 255;	// proper transparent color

	// Convert the 128*128 conchars texture to 128*256 leaving
	// empty space between rows so that chars don't stumble on
	// each other because of texture smoothing.
	// This hack costs us 64K of GL texture memory
	memset (buf, 255, sizeof(buf));
	src = draw_chars;
	dest = buf;
	for (i=0 ; i<16 ; i++) {
		memcpy (dest, src, 128*8);
		src += 128*8;
		dest += 128*8*2;
	}

	char_texture = GL_LoadTexture ("pic:charset", 128, 256, buf, false, true, false);
	if (!gl_smoothfont.value)
	{
		glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	}
}


void R_FlushPics (void)
{
	if (!draw_chars)
		return;		// not initialized yet (FIXME?)

	numcachepics = 0;

	memset (scrap_allocated, 0, sizeof(scrap_allocated));
	memset (scrap_texels, 0, sizeof(scrap_texels));
	scrap_dirty = false;

	draw_chars = NULL;
	draw_disc = NULL;

	// load a new gfx.wad
	W_LoadWadFile ("gfx.wad");

	// load the charset by hand
	R_LoadCharset ();

	// the disc access monitor pic
	draw_disc = R_CachePic_impl ("disc", true, false);
}



/*
===============
R_Draw_Init
===============
*/
void R_Draw_Init (void)
{
	int		i;

	Cvar_Register (&gl_smoothfont);

	// save a texture slot for translated picture
	translate_texture = texture_extension_number++;

	// save slots for scraps
	scrap_texnum = texture_extension_number;
	texture_extension_number += MAX_SCRAPS;

	// load the crosshair pics
	for (i=0 ; i<NUMCROSSHAIRS ; i++) {
		crosshairtextures[i] = GL_LoadTexture ("", 8, 8, crosshairdata[i], false, true, false);
		glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	}

	W_LoadWadFile ("gfx.wad");

	// load the charset by hand
	R_LoadCharset ();

	// the disc access monitor pic
	draw_disc = R_CachePic_impl ("disc", true, false);
}


/*
================
R_DrawChar

Draws one 8*8 graphics character with 0 being transparent.
It can be clipped to the top of the screen to allow the console to be
smoothly scrolled off.
================
*/
void R_DrawChar (int x, int y, int num)
{
	int				row, col;
	float			frow, fcol;

	if (y <= -8)
		return;			// totally off screen

	if (num == 32)
		return;		// space

	num &= 255;

	row = num>>4;
	col = num&15;

	frow = row*0.0625;
	fcol = col*0.0625;

	GL_Bind (char_texture);

	glBegin (GL_QUADS);
	glTexCoord2f (fcol, frow);
	glVertex2f (x, y);
	glTexCoord2f (fcol + 0.0625, frow);
	glVertex2f (x+8, y);
	glTexCoord2f (fcol + 0.0625, frow + 0.03125);
	glVertex2f (x+8, y+8);
	glTexCoord2f (fcol, frow + 0.03125);
	glVertex2f (x, y+8);
	glEnd ();
}

void R_DrawString (int x, int y, const char *str)
{
	float			frow, fcol;
	int num;

	if (y <= -8)
		return;			// totally off screen
	if (!*str)
		return;

	GL_Bind (char_texture);

	glBegin (GL_QUADS);

	while (*str) // stop rendering when out of characters
	{
		if ((num = *str++) != 32) // skip spaces
		{
			frow = (float) (num >> 4)*0.0625;
			fcol = (float) (num & 15)*0.0625;
			glTexCoord2f (fcol, frow);
			glVertex2f (x, y);
			glTexCoord2f (fcol + 0.0625, frow);
			glVertex2f (x+8, y);
			glTexCoord2f (fcol + 0.0625, frow + 0.03125);
			glVertex2f (x+8, y+8);
			glTexCoord2f (fcol, frow + 0.03125);
			glVertex2f (x, y+8);
		}

		x += 8;
	}

	glEnd ();
}

static byte *StringToRGB(char *s) {
	byte *col;
	static byte rgb[4];

	Cmd_TokenizeString(s);
	if (Cmd_Argc() == 3) {
		rgb[0] = (byte) Q_atoi(Cmd_Argv(0));
		rgb[1] = (byte) Q_atoi(Cmd_Argv(1));
		rgb[2] = (byte) Q_atoi(Cmd_Argv(2));
	} else {
		col = (byte *) &d_8to24table[(byte) Q_atoi(s)];
		rgb[0] = col[0];
		rgb[1] = col[1];
		rgb[2] = col[2];
	}
	rgb[3] = 255;
	return rgb;
}

void R_DrawCrosshair (int num, int crossx, int crossy)
{
	int		x, y;
	int		ofs1, ofs2;
	byte    *col;
	extern vrect_t scr_vrect;
	extern cvar_t crosshaircolor;

	x = scr_vrect.x + scr_vrect.width/2 + crossx;
	y = scr_vrect.y + scr_vrect.height/2 + crossy;

	col = StringToRGB(crosshaircolor.string);

	if (num >= 2 && num <= NUMCROSSHAIRS+1) {
		glTexEnvf (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
		glColor3ubv (col);
		GL_Bind (crosshairtextures[num - 2]);

		if (vid.width == 320) {
			ofs1 = 3;//3.5;
			ofs2 = 5;//4.5;
		} else {
			ofs1 = 7;
			ofs2 = 9;
		}
		glBegin (GL_QUADS);
		glTexCoord2f (0, 0);
		glVertex2f (x - ofs1, y - ofs1);
		glTexCoord2f (1, 0);
		glVertex2f (x + ofs2, y - ofs1);
		glTexCoord2f (1, 1);
		glVertex2f (x + ofs2, y + ofs2);
		glTexCoord2f (0, 1);
		glVertex2f (x - ofs1, y + ofs2);
		glEnd ();

		glTexEnvf (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
		glColor3f (1, 1, 1);
	}
	else {
		R_DrawChar (x - 4, y - 4, '+');
	}
}


/*
================
R_DrawDebugChar

Draws a single character directly to the upper right corner of the screen.
This is for debugging lockups by drawing different chars in different parts
of the code.
================
*/
void R_DrawDebugChar (char num)
{
}


void R_DrawPic (int x, int y, mpic_t *pic)
{
/*	if ((x < 0) || (x + pic->width > vid.width) ||
		(y < 0) || (y + pic->height > vid.height))
	{
		Sys_Error ("R_DrawPic: bad coordinates");
	}
*/
	cachepic_t *cpic = (cachepic_t *) pic;

	if (!pic)
		return;

	if (scrap_dirty)
		Scrap_Upload ();

	GL_Bind (cpic->texnum);
	glBegin (GL_QUADS);
	glTexCoord2f (cpic->sl, cpic->tl);
	glVertex2f (x, y);
	glTexCoord2f (cpic->sh, cpic->tl);
	glVertex2f (x + pic->width, y);
	glTexCoord2f (cpic->sh, cpic->th);
	glVertex2f (x + pic->width, y + pic->height);
	glTexCoord2f (cpic->sl, cpic->th);
	glVertex2f (x, y + pic->height);
	glEnd ();
}

// not really used any more
void Draw_AlphaPic (int x, int y, mpic_t *pic, float alpha)
{
	cachepic_t *cpic = (cachepic_t *) pic;

	if (scrap_dirty)
		Scrap_Upload ();

	glDisable(GL_ALPHA_TEST);
	glEnable (GL_BLEND);
//	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glCullFace(GL_FRONT);
	glColor4f (1, 1, 1, alpha);
	GL_Bind (cpic->texnum);
	glBegin (GL_QUADS);
	glTexCoord2f (cpic->sl, cpic->tl);
	glVertex2f (x, y);
	glTexCoord2f (cpic->sh, cpic->tl);
	glVertex2f (x + pic->width, y);
	glTexCoord2f (cpic->sh, cpic->th);
	glVertex2f (x + pic->width, y + pic->height);
	glTexCoord2f (cpic->sl, cpic->th);
	glVertex2f (x, y + pic->height);
	glEnd ();
	glColor3f (1, 1, 1);
	glEnable(GL_ALPHA_TEST);
	glDisable (GL_BLEND);
}

void R_DrawSubPic (int x, int y, mpic_t *pic, int srcx, int srcy, int width, int height)
{
	float newsl, newtl, newsh, newth;
	float oldglwidth, oldglheight;
	cachepic_t *cpic = (cachepic_t *) pic;

	if (!pic)
		return;

	if (scrap_dirty)
		Scrap_Upload ();
	
	oldglwidth = cpic->sh - cpic->sl;
	oldglheight = cpic->th - cpic->tl;

	newsl = cpic->sl + (srcx*oldglwidth)/pic->width;
	newsh = newsl + (width*oldglwidth)/pic->width;

	newtl = cpic->tl + (srcy*oldglheight)/pic->height;
	newth = newtl + (height*oldglheight)/pic->height;
	
	GL_Bind (cpic->texnum);
	glBegin (GL_QUADS);
	glTexCoord2f (newsl, newtl);
	glVertex2f (x, y);
	glTexCoord2f (newsh, newtl);
	glVertex2f (x + width, y);
	glTexCoord2f (newsh, newth);
	glVertex2f (x + width, y + height);
	glTexCoord2f (newsl, newth);
	glVertex2f (x, y + height);
	glEnd ();
}

/*
=============
R_DrawTransPicTranslate

Only used for the player color selection menu
=============
*/
void R_DrawTransPicTranslate (int x, int y, mpic_t *pic, byte *translation)
{
	int				v, u, c;
	unsigned		trans[64*64], *dest;
	byte			*src;
	int				p;

	if (!pic)
		return;

	GL_Bind (translate_texture);

	c = pic->width * pic->height;

	dest = trans;
	for (v=0 ; v<64 ; v++, dest += 64)
	{
		src = &menuplyr_pixels[ ((v*pic->height)>>6) *pic->width];
		for (u=0 ; u<64 ; u++)
		{
			p = src[(u*pic->width)>>6];
			if (p == 255)
				dest[u] = p;
			else
				dest[u] =  d_8to24table[translation[p]];
		}
	}

	glTexImage2D (GL_TEXTURE_2D, 0, gl_alpha_format, 64, 64, 0, GL_RGBA, GL_UNSIGNED_BYTE, trans);

	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	glBegin (GL_QUADS);
	glTexCoord2f (0, 0);
	glVertex2f (x, y);
	glTexCoord2f (1, 0);
	glVertex2f (x+pic->width, y);
	glTexCoord2f (1, 1);
	glVertex2f (x+pic->width, y+pic->height);
	glTexCoord2f (0, 1);
	glVertex2f (x, y+pic->height);
	glEnd ();
}


void R_DrawStretchPic (int x, int y, int width, int height, mpic_t *pic, float alpha)
{
	cachepic_t *cpic = (cachepic_t *) pic;

	if (!pic || !alpha)
		return;

	if (scrap_dirty)
		Scrap_Upload ();

	glDisable(GL_ALPHA_TEST);
	glEnable (GL_BLEND);
//	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glCullFace(GL_FRONT);
	glColor4f (1, 1, 1, alpha);
	GL_Bind (cpic->texnum);
	glBegin (GL_QUADS);
	glTexCoord2f (cpic->sl, cpic->tl);
	glVertex2f (x, y);
	glTexCoord2f (cpic->sh, cpic->tl);
	glVertex2f (x + width, y);
	glTexCoord2f (cpic->sh, cpic->th);
	glVertex2f (x + width, y + height);
	glTexCoord2f (cpic->sl, cpic->th);
	glVertex2f (x, y + height);
	glEnd ();
	glColor3f (1, 1, 1);
	glEnable(GL_ALPHA_TEST);
	glDisable (GL_BLEND);
}


/*
=============
R_DrawTile

This repeats a 64*64 tile graphic to fill the screen around a sized down
refresh window.
=============
*/
void R_DrawTile (int x, int y, int w, int h, mpic_t *pic)
{
	GL_Bind (((cachepic_t *)pic)->texnum);
	glBegin (GL_QUADS);
	glTexCoord2f (x/64.0, y/64.0);
	glVertex2f (x, y);
	glTexCoord2f ( (x+w)/64.0, y/64.0);
	glVertex2f (x+w, y);
	glTexCoord2f ( (x+w)/64.0, (y+h)/64.0);
	glVertex2f (x+w, y+h);
	glTexCoord2f ( x/64.0, (y+h)/64.0 );
	glVertex2f (x, y+h);
	glEnd ();
}


/*
=============
R_DrawFilledRect

Fills a box of pixels with a single color
=============
*/
void R_DrawFilledRect (int x, int y, int w, int h, int c)
{
	glDisable (GL_TEXTURE_2D);
	glColor3f (host_basepal[c*3]/255.0,
		host_basepal[c*3+1]/255.0,
		host_basepal[c*3+2]/255.0);

	glBegin (GL_QUADS);

	glVertex2f (x,y);
	glVertex2f (x+w, y);
	glVertex2f (x+w, y+h);
	glVertex2f (x, y+h);

	glEnd ();
	glColor3f (1, 1, 1);
	glEnable (GL_TEXTURE_2D);
}
//=============================================================================


void R_FadeScreen (void)
{
	glEnable (GL_BLEND);
	glDisable (GL_TEXTURE_2D);
	glColor4f (0, 0, 0, 0.7);
	glBegin (GL_QUADS);

	glVertex2f (0,0);
	glVertex2f (vid.width, 0);
	glVertex2f (vid.width, vid.height);
	glVertex2f (0, vid.height);

	glEnd ();
	glColor3f (1, 1, 1);
	glEnable (GL_TEXTURE_2D);
	glDisable (GL_BLEND);
}

//=============================================================================

/*
================
R_BeginDisc

Draws the little blue disc in the corner of the screen.
Call before beginning any disc IO.
================
*/
void R_BeginDisc (void)
{
	if (!draw_disc)
		return;
	glDrawBuffer  (GL_FRONT);
	R_DrawPic (vid.width - 24, 0, draw_disc);
	glDrawBuffer  (GL_BACK);
}


/*
================
R_EndDisc

Erases the disc icon.
Call after completing any disc IO
================
*/
void R_EndDisc (void)
{
}

/*
================
GL_Set2D

Setup as if the screen was 320*200
================
*/
void GL_Set2D (void)
{
	glViewport (0, 0, vid.realwidth, vid.realheight);

	glMatrixMode(GL_PROJECTION);
    glLoadIdentity ();
	glOrtho  (0, vid.width, vid.height, 0, -99999, 99999);

	glMatrixMode(GL_MODELVIEW);
    glLoadIdentity ();

	glDisable (GL_DEPTH_TEST);
	glDisable (GL_CULL_FACE);
	glDisable (GL_BLEND);
	glEnable (GL_ALPHA_TEST);
//	glDisable (GL_ALPHA_TEST);

	glColor3f (1, 1, 1);
}

/* vi: set noet ts=4 sts=4 ai sw=4: */
