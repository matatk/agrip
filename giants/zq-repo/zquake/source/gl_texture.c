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
// gl_texture.c - GL texture management

#include "gl_local.h"
#include "crc.h"
#include "version.h"

#ifdef MINGW32
#include <GL/glext.h>	// GL_COLOR_INDEX8_EXT is defined here
#endif /* MINGW32 */

extern unsigned char d_15to8table[65536];
extern unsigned d_8to24table2[256];

static void	OnChange_gl_texturemode (cvar_t *var, char *string, qbool *cancel);

cvar_t		gl_nobind = {"gl_nobind", "0"};
cvar_t		gl_picmip = {"gl_picmip", "0"};
cvar_t		gl_lerpimages = {"r_lerpimages", "1"};
cvar_t		gl_texturemode = {"gl_texturemode", "GL_LINEAR_MIPMAP_NEAREST", 0, OnChange_gl_texturemode};

int		texture_extension_number = 1;

int		gl_lightmap_format = 4;
int		gl_solid_format = 3;
int		gl_alpha_format = 4;

int		gl_filter_min = GL_LINEAR_MIPMAP_NEAREST;
int		gl_filter_max = GL_LINEAR;

int		gl_max_texsize;

int		texels;

extern byte	scrap_texels[2][256*256*4];	// FIXME FIXME FIXME

typedef struct
{
	int		texnum;
	char	identifier[64];
	int		width, height;
	qbool	mipmap;
	qbool	brighten;
	unsigned	crc;
} gltexture_t;

gltexture_t	gltextures[MAX_GLTEXTURES];
int			numgltextures;

qbool	mtexenabled = false;

#ifdef _WIN32
lpMTexFUNC qglMultiTexCoord2f = NULL;
lpSelTexFUNC qglActiveTexture = NULL;
#endif

void GL_Bind (int texnum)
{
	extern int char_texture;

	if (gl_nobind.value)
		texnum = char_texture;
	if (currenttexture == texnum)
		return;
	currenttexture = texnum;
#ifdef _WIN32
	bindTexFunc (GL_TEXTURE_2D, texnum);
#else
	glBindTexture (GL_TEXTURE_2D, texnum);
#endif
}

static GLenum oldtarget = GL_TEXTURE0_ARB;

void GL_SelectTexture (GLenum target)
{
	if (!gl_mtexable)
		return;
#ifdef _WIN32 // no multitexture under Linux or Darwin yet
	qglActiveTexture (target);
#endif
	if (target == oldtarget)
		return;
	cnttextures[oldtarget-GL_TEXTURE0_ARB] = currenttexture;
	currenttexture = cnttextures[target-GL_TEXTURE0_ARB];
	oldtarget = target;
}

void GL_DisableMultitexture (void)
{
	if (mtexenabled) {
		glDisable (GL_TEXTURE_2D);
		GL_SelectTexture (GL_TEXTURE0_ARB);
		mtexenabled = false;
	}
}

void GL_EnableMultitexture (void)
{
	if (gl_mtexable) {
		GL_SelectTexture (GL_TEXTURE1_ARB);
		glEnable (GL_TEXTURE_2D);
		mtexenabled = true;
	}
}


//====================================================================

typedef struct
{
	char *name;
	int	minimize, maximize;
} glmode_t;

static glmode_t modes[] = {
	{"GL_NEAREST", GL_NEAREST, GL_NEAREST},
	{"GL_LINEAR", GL_LINEAR, GL_LINEAR},
	{"GL_NEAREST_MIPMAP_NEAREST", GL_NEAREST_MIPMAP_NEAREST, GL_NEAREST},
	{"GL_LINEAR_MIPMAP_NEAREST", GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR},
	{"GL_NEAREST_MIPMAP_LINEAR", GL_NEAREST_MIPMAP_LINEAR, GL_NEAREST},
	{"GL_LINEAR_MIPMAP_LINEAR", GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR}
};


static void OnChange_gl_texturemode (cvar_t *var, char *string, qbool *cancel)
{
	int		i;
	gltexture_t	*glt;

	for (i=0 ; i<6 ; i++)
	{
		if (!Q_stricmp (modes[i].name, string ) )
			break;
	}
	if (i == 6)
	{
		Com_Printf ("bad filter name: %s\n", string);
		*cancel = true;		// don't change the cvar
		return;
	}

	gl_filter_min = modes[i].minimize;
	gl_filter_max = modes[i].maximize;

	// change all the existing mipmap texture objects
	for (i=0, glt=gltextures ; i<numgltextures ; i++, glt++)
	{
		if (glt->mipmap)
		{
			GL_Bind (glt->texnum);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, gl_filter_min);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, gl_filter_max);
		}
	}
}


//====================================================================

/*
================
GL_FindTexture
================
*/
int GL_FindTexture (char *identifier)
{
	int		i;
	gltexture_t	*glt;

	for (i=0, glt=gltextures ; i<numgltextures ; i++, glt++)
	{
		if (!strcmp (identifier, glt->identifier))
			return gltextures[i].texnum;
	}

	return -1;
}


void R_ResampleTextureLerpLine (byte *in, byte *out, int inwidth,
		int outwidth)
{
	int		j, xi, oldx = 0, f, fstep, endx;
	fstep = (int) (inwidth*65536.0f/outwidth);
	endx = (inwidth-1);
	for (j = 0,f = 0;j < outwidth;j++, f += fstep)
	{
		xi = (int) f >> 16;
		if (xi != oldx)
		{
			in += (xi - oldx) * 4;
			oldx = xi;
		}
		if (xi < endx)
		{
			int lerp = f & 0xFFFF;
			*out++ = (byte) ((((in[4] - in[0]) * lerp) >> 16) + in[0]);
			*out++ = (byte) ((((in[5] - in[1]) * lerp) >> 16) + in[1]);
			*out++ = (byte) ((((in[6] - in[2]) * lerp) >> 16) + in[2]);
			*out++ = (byte) ((((in[7] - in[3]) * lerp) >> 16) + in[3]);
		}
		else // last pixel of the line has no pixel to lerp to
		{
			*out++ = in[0];
			*out++ = in[1];
			*out++ = in[2];
			*out++ = in[3];
		}
	}
}

/*
================
GL_ResampleTexture
================
*/
void GL_ResampleTexture (unsigned *indata, int inwidth, int inheight,
		unsigned *outdata, int outwidth, int outheight)
{
	if (gl_lerpimages.value)
	{
		int		i, j, yi, oldy, f, fstep, endy = (inheight-1);
		byte	*inrow, *out, *row1, *row2;
		out = (byte *) outdata;
		fstep = (int) (inheight*65536.0f/outheight);

		row1 = Q_malloc(outwidth*4);
		row2 = Q_malloc(outwidth*4);
		inrow = (byte *) indata;
		oldy = 0;
		R_ResampleTextureLerpLine (inrow, row1, inwidth, outwidth);
		R_ResampleTextureLerpLine (inrow + inwidth*4, row2, inwidth,
				outwidth);
		for (i = 0, f = 0;i < outheight;i++,f += fstep)
		{
			yi = f >> 16;
			if (yi < endy)
			{
				int lerp = f & 0xFFFF;
				if (yi != oldy)
				{
					inrow = (byte *)indata + inwidth*4*yi;
					if (yi == oldy+1)
						memcpy(row1, row2, outwidth*4);
					else
						R_ResampleTextureLerpLine (inrow, row1, inwidth,
								outwidth);
					R_ResampleTextureLerpLine (inrow + inwidth*4, row2,
							inwidth, outwidth);
					oldy = yi;
				}
				for (j=outwidth ; j ; j--)
				{
					out[0] = (byte) ((((row2[ 0] - row1[ 0]) * lerp) >> 16)
							+ row1[ 0]);
					out[1] = (byte) ((((row2[ 1] - row1[ 1]) * lerp) >> 16)
							+ row1[ 1]);
					out[2] = (byte) ((((row2[ 2] - row1[ 2]) * lerp) >> 16)
							+ row1[ 2]);
					out[3] = (byte) ((((row2[ 3] - row1[ 3]) * lerp) >> 16)
							+ row1[ 3]);
					out += 4;
					row1 += 4;
					row2 += 4;
				}
				row1 -= outwidth*4;
				row2 -= outwidth*4;
			}
			else
			{
				if (yi != oldy)
				{
					inrow = (byte *)indata + inwidth*4*yi;
					if (yi == oldy+1)
						memcpy(row1, row2, outwidth*4);
					else
						R_ResampleTextureLerpLine (inrow, row1, inwidth,
								outwidth);
					oldy = yi;
				}
				memcpy(out, row1, outwidth * 4);
			}
		}
		Q_free (row1);
		Q_free (row2);
	}
	else
	{
		int i, j;
		unsigned frac, fracstep;
		unsigned int *inrow, *out;
		out = outdata;

		fracstep = inwidth*0x10000/outwidth;
		for (i = 0;i < outheight;i++)
		{
			inrow = (unsigned int *)((int *)indata + inwidth*(i*inheight/outheight));
			frac = fracstep >> 1;
			for (j = outwidth >> 2 ; j ; j--)
			{
				out[0] = inrow[frac >> 16]; frac += fracstep;
				out[1] = inrow[frac >> 16]; frac += fracstep;
				out[2] = inrow[frac >> 16]; frac += fracstep;
				out[3] = inrow[frac >> 16]; frac += fracstep;
				out += 4;
			}
			for (j = outwidth & 3 ; j ; j--)
			{
				*out = inrow[frac >> 16]; frac += fracstep;
				out++;
			}
		}
	}
}

/*
================
GL_Resample8BitTexture -- JACK
================
*/
void GL_Resample8BitTexture (unsigned char *in, int inwidth, int inheight, unsigned char *out,  int outwidth, int outheight)
{
	int		i, j;
	unsigned	char *inrow;
	unsigned	frac, fracstep;

	fracstep = inwidth*0x10000/outwidth;
	for (i=0 ; i<outheight ; i++, out += outwidth)
	{
		inrow = in + inwidth*(i*inheight/outheight);
		frac = fracstep >> 1;
		for (j=0 ; j<outwidth ; j+=4)
		{
			out[j] = inrow[frac>>16];
			frac += fracstep;
			out[j+1] = inrow[frac>>16];
			frac += fracstep;
			out[j+2] = inrow[frac>>16];
			frac += fracstep;
			out[j+3] = inrow[frac>>16];
			frac += fracstep;
		}
	}
}

/*
================
GL_MipMap

Operates in place, quartering the size of the texture
================
*/
void GL_MipMap (byte *in, int width, int height)
{
	int		i, j;
	byte	*out;

	width <<=2;
	height >>= 1;
	out = in;
	for (i=0 ; i<height ; i++, in+=width)
	{
		for (j=0 ; j<width ; j+=8, out+=4, in+=8)
		{
			out[0] = (in[0] + in[4] + in[width+0] + in[width+4])>>2;
			out[1] = (in[1] + in[5] + in[width+1] + in[width+5])>>2;
			out[2] = (in[2] + in[6] + in[width+2] + in[width+6])>>2;
			out[3] = (in[3] + in[7] + in[width+3] + in[width+7])>>2;
		}
	}
}

/*
================
GL_MipMap8Bit

Mipping for 8 bit textures
================
*/
void GL_MipMap8Bit (byte *in, int width, int height)
{
	int		i, j;
	byte	*out;
	unsigned short     r,g,b;
	byte	*at1, *at2, *at3, *at4;

	height >>= 1;
	out = in;
	for (i=0 ; i<height ; i++, in+=width)
		for (j=0 ; j<width ; j+=2, out+=1, in+=2)
		{
			at1 = (byte *) &d_8to24table[in[0]];
			at2 = (byte *) &d_8to24table[in[1]];
			at3 = (byte *) &d_8to24table[in[width+0]];
			at4 = (byte *) &d_8to24table[in[width+1]];

 			r = (at1[0]+at2[0]+at3[0]+at4[0]); r>>=5;
 			g = (at1[1]+at2[1]+at3[1]+at4[1]); g>>=5;
 			b = (at1[2]+at2[2]+at3[2]+at4[2]); b>>=5;

			out[0] = d_15to8table[(r<<0) + (g<<5) + (b<<10)];
		}
}

/*
===============
GL_Upload32
===============
*/
void GL_Upload32 (unsigned *data, int width, int height, qbool mipmap, qbool alpha)
{
	int			samples;
static	unsigned	scaled[1024*512];	// [512*256];
	int			scaled_width, scaled_height;

	for (scaled_width = 1 ; scaled_width < width ; scaled_width<<=1)
		;
	for (scaled_height = 1 ; scaled_height < height ; scaled_height<<=1)
		;

	if (mipmap) {
		scaled_width >>= (int)gl_picmip.value;
		scaled_height >>= (int)gl_picmip.value;
	}

	if (scaled_width > gl_max_texsize)
		scaled_width = gl_max_texsize;
	if (scaled_height > gl_max_texsize)
		scaled_height = gl_max_texsize;
	if (scaled_width < 1)
		scaled_width = 1;
	if (scaled_height < 1)
		scaled_height = 1;

	if (scaled_width * scaled_height > sizeof(scaled)/4)
		Sys_Error ("GL_LoadTexture: too big");

	samples = alpha ? gl_alpha_format : gl_solid_format;

	texels += scaled_width * scaled_height;

	if (scaled_width == width && scaled_height == height)
	{
		if (!mipmap)
		{
			glTexImage2D (GL_TEXTURE_2D, 0, samples, scaled_width, scaled_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
			goto done;
		}
		memcpy (scaled, data, width*height*4);
	}
	else
		GL_ResampleTexture (data, width, height, scaled, scaled_width, scaled_height);

	glTexImage2D (GL_TEXTURE_2D, 0, samples, scaled_width, scaled_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, scaled);
	if (mipmap)
	{
		int		miplevel;

		miplevel = 0;
		while (scaled_width > 1 || scaled_height > 1)
		{
			GL_MipMap ((byte *)scaled, scaled_width, scaled_height);
			scaled_width >>= 1;
			scaled_height >>= 1;
			if (scaled_width < 1)
				scaled_width = 1;
			if (scaled_height < 1)
				scaled_height = 1;
			miplevel++;
			glTexImage2D (GL_TEXTURE_2D, miplevel, samples, scaled_width, scaled_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, scaled);
		}
	}
done: ;


	if (mipmap)
	{
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, gl_filter_min);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, gl_filter_max);
	}
	else
	{
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, gl_filter_max);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, gl_filter_max);
	}
}

void GL_Upload8_EXT (byte *data, int width, int height, qbool mipmap, qbool alpha)
{
	int			i, s;
	qbool		noalpha;
	int			samples;
    static	unsigned char scaled[1024*512];	// [512*256];
	int			scaled_width, scaled_height;

	s = width*height;
	// if there are no transparent pixels, make it a 3 component
	// texture even if it was specified as otherwise
	if (alpha)
	{
		noalpha = true;
		for (i=0 ; i<s ; i++)
		{
			if (data[i] == 255)
				noalpha = false;
		}

		if (alpha && noalpha)
			alpha = false;
	}
	for (scaled_width = 1 ; scaled_width < width ; scaled_width<<=1)
		;
	for (scaled_height = 1 ; scaled_height < height ; scaled_height<<=1)
		;

	if (mipmap) {
		scaled_width >>= (int)gl_picmip.value;
		scaled_height >>= (int)gl_picmip.value;
	}

	if (scaled_width > gl_max_texsize)
		scaled_width = gl_max_texsize;
	if (scaled_height > gl_max_texsize)
		scaled_height = gl_max_texsize;
	if (scaled_width < 1)
		scaled_width = 1;
	if (scaled_height < 1)
		scaled_height = 1;

	if (scaled_width * scaled_height > sizeof(scaled))
		Sys_Error ("GL_LoadTexture: too big");

	samples = 1; // alpha ? gl_alpha_format : gl_solid_format;

	texels += scaled_width * scaled_height;

	if (scaled_width == width && scaled_height == height)
	{
		if (!mipmap)
		{
			glTexImage2D (GL_TEXTURE_2D, 0, GL_COLOR_INDEX8_EXT, scaled_width, scaled_height, 0, GL_COLOR_INDEX , GL_UNSIGNED_BYTE, data);
			goto done;
		}
		memcpy (scaled, data, width*height);
	}
	else
		GL_Resample8BitTexture (data, width, height, scaled, scaled_width, scaled_height);

	glTexImage2D (GL_TEXTURE_2D, 0, GL_COLOR_INDEX8_EXT, scaled_width, scaled_height, 0, GL_COLOR_INDEX, GL_UNSIGNED_BYTE, scaled);
	if (mipmap)
	{
		int		miplevel;

		miplevel = 0;
		while (scaled_width > 1 || scaled_height > 1)
		{
			GL_MipMap8Bit ((byte *)scaled, scaled_width, scaled_height);
			scaled_width >>= 1;
			scaled_height >>= 1;
			if (scaled_width < 1)
				scaled_width = 1;
			if (scaled_height < 1)
				scaled_height = 1;
			miplevel++;
			glTexImage2D (GL_TEXTURE_2D, miplevel, GL_COLOR_INDEX8_EXT, scaled_width, scaled_height, 0, GL_COLOR_INDEX, GL_UNSIGNED_BYTE, scaled);
		}
	}
done: ;

	if (mipmap)
	{
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, gl_filter_min);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, gl_filter_max);
	}
	else
	{
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, gl_filter_max);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, gl_filter_max);
	}
}

extern qbool VID_Is8bit();

/*
===============
GL_Upload8
===============
*/
void GL_Upload8 (byte *data, int width, int height, qbool mipmap, qbool alpha, qbool brighten)
{
	static	unsigned	trans[640*480];		// FIXME, temporary
	int			i, s;
	qbool		noalpha;
	int			p;
	unsigned	*table;

	if (brighten)
		table = d_8to24table2;
	else
		table = d_8to24table;

	s = width*height;

	if (alpha == 2)
	{
	// this is a fullbright mask, so make all non-fullbright
	// colors transparent
		for (i=0 ; i<s ; i++)
		{
			p = data[i];
			if (p < 224)
				trans[i] = table[p] & LittleLong(0x00FFFFFF); // transparent
			else
				trans[i] = table[p];	// fullbright
		}
	}
	else if (alpha)
	{
	// if there are no transparent pixels, make it a 3 component
	// texture even if it was specified as otherwise
		noalpha = true;
		for (i=0 ; i<s ; i++)
		{
			p = data[i];
			if (p == 255)
				noalpha = false;
			trans[i] = table[p];
		}

		if (alpha && noalpha)
			alpha = false;
	}
	else
	{
		if (s&3)
			Sys_Error ("GL_Upload8: s&3");
		for (i=0 ; i<s ; i+=4)
		{
			trans[i] = table[data[i]];
			trans[i+1] = table[data[i+1]];
			trans[i+2] = table[data[i+2]];
			trans[i+3] = table[data[i+3]];
		}
	}

	if (VID_Is8bit() && !alpha && (data!=scrap_texels[0])) {
		GL_Upload8_EXT (data, width, height, mipmap, alpha);
		return;
	}

	GL_Upload32 (trans, width, height, mipmap, alpha);
}

/*
================
GL_LoadTexture
================
*/
int GL_LoadTexture (char *identifier, int width, int height, byte *data, qbool mipmap, qbool alpha, qbool brighten)
{
	int			i;
	unsigned	crc = 0;
	gltexture_t	*glt;

	if (lightmode != 2)
		brighten = false;

	// see if the texture is already present
	if (identifier[0]) {
		crc = CRC_Block (data, width*height);
		for (i=0, glt=gltextures ; i<numgltextures ; i++, glt++) {
			if (!strncmp (identifier, glt->identifier, sizeof(glt->identifier)-1)) {
				if (width == glt->width && height == glt->height
					&& crc == glt->crc && brighten == glt->brighten)
					return gltextures[i].texnum;
				else
					goto setuptexture;	// reload the texture into the same slot
			}
		}
	}
	else
		glt = &gltextures[numgltextures];

	if (numgltextures == MAX_GLTEXTURES)
		Sys_Error ("GL_LoadTexture: numgltextures == MAX_GLTEXTURES");
	numgltextures++;

	strlcpy (glt->identifier, identifier, sizeof(glt->identifier));
	glt->texnum = texture_extension_number;
	texture_extension_number++;

setuptexture:
	glt->width = width;
	glt->height = height;
	glt->mipmap = mipmap;
	glt->brighten = brighten;
	glt->crc = crc;

	GL_Bind (glt->texnum);

	GL_Upload8 (data, width, height, mipmap, alpha, brighten);

	return glt->texnum;
}


/*
================
GL_LoadTexture32

FIXME: merge with GL_LoadTexture
================
*/
int GL_LoadTexture32 (char *identifier, int width, int height, byte *data, qbool mipmap, qbool alpha, qbool brighten)
{
	int			i;
	unsigned	crc = 0;
	gltexture_t	*glt;

	if (lightmode != 2)
		brighten = false;

	// see if the texture is already present
	if (identifier[0]) {
		crc = CRC_Block (data, width*height);
		for (i=0, glt=gltextures ; i<numgltextures ; i++, glt++) {
			if (!strncmp (identifier, glt->identifier, sizeof(glt->identifier)-1)) {
				if (width == glt->width && height == glt->height
					&& crc == glt->crc && brighten == glt->brighten)
					return gltextures[i].texnum;
				else
					goto setuptexture;	// reload the texture into the same slot
			}
		}
	}
	else
		glt = &gltextures[numgltextures];

	if (numgltextures == MAX_GLTEXTURES)
		Sys_Error ("GL_LoadTexture: numgltextures == MAX_GLTEXTURES");
	numgltextures++;

	strlcpy (glt->identifier, identifier, sizeof(glt->identifier));
	glt->texnum = texture_extension_number;
	texture_extension_number++;

setuptexture:
	glt->width = width;
	glt->height = height;
	glt->mipmap = mipmap;
	glt->brighten = false /* brighten */;
	glt->crc = crc;

	GL_Bind (glt->texnum);

	GL_Upload32 ((unsigned int *)data, width, height, mipmap, alpha);

	return glt->texnum;
}


static void R_InitParticleTexture (void)
{
	int		i, x, y;
	unsigned int	data[32][32];

	particletexture = texture_extension_number++;
    GL_Bind (particletexture);

	// clear to transparent white
	for (i=0 ; i<32*32 ; i++)
		((unsigned *)data)[i] = LittleLong(0x00FFFFFF);

	// draw a circle in the top left corner
	for (x=0 ; x<16 ; x++)
		for (y=0 ; y<16 ; y++) {
			if ((x - 7.5)*(x - 7.5) + (y - 7.5)*(y - 7.5) <= 8*8)
				data[y][x] = LittleLong(0xFFFFFFFF);	// solid white
		}

	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	GL_Upload32 ((unsigned *) data, 32, 32, true, true);
}


static void R_InitDefaultTexture (void)
{
	int		x,y, m;
	byte	*dest;

// create a simple checkerboard texture for the default
	r_notexture_mip = Hunk_AllocName (sizeof(texture_t) + 16*16+8*8+4*4+2*2, "notexture");

	r_notexture_mip->width = r_notexture_mip->height = 16;
	r_notexture_mip->offsets[0] = sizeof(texture_t);
	r_notexture_mip->offsets[1] = r_notexture_mip->offsets[0] + 16*16;
	r_notexture_mip->offsets[2] = r_notexture_mip->offsets[1] + 8*8;
	r_notexture_mip->offsets[3] = r_notexture_mip->offsets[2] + 4*4;

	for (m=0 ; m<4 ; m++)
	{
		dest = (byte *)r_notexture_mip + r_notexture_mip->offsets[m];
		for (y=0 ; y< (16>>m) ; y++)
			for (x=0 ; x< (16>>m) ; x++)
			{
				if (  (y< (8>>m) ) ^ (x< (8>>m) ) )
					*dest++ = 0;
				else
					*dest++ = 15;
			}
	}
}


/*
===============
R_InitTextures
===============
*/
void R_InitTextures (void)
{
	Cvar_Register (&gl_nobind);
	Cvar_Register (&gl_picmip);
	Cvar_Register (&gl_lerpimages);
	Cvar_Register (&gl_texturemode);

	// get the maximum texture size from driver
	glGetIntegerv (GL_MAX_TEXTURE_SIZE, (GLint *) &gl_max_texsize);

	R_InitDefaultTexture ();
	R_InitParticleTexture ();
}

/* vi: set noet ts=4 sts=4 ai sw=4: */
