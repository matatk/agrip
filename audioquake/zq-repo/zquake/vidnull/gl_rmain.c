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
// gl_rmain.c

#include "gl_local.h"

model_t		*r_worldmodel;
entity_t	r_worldentity;

qbool		r_cache_thrash;		// compatability

vec3_t		modelorg, r_entorigin;
entity_t	*currententity;

int			r_framecount;		// used for dlight push checking

int			particletexture;	// little dot for particles


//
// view origin
//
vec3_t	vup;
vec3_t	vpn;
vec3_t	vright;
vec3_t	r_origin;

//
// screen size info
//
//refdef_t	r_refdef;
refdef2_t	r_refdef2;

mleaf_t		*r_viewleaf, *r_oldviewleaf;
mleaf_t		*r_viewleaf2, *r_oldviewleaf2;	// for watervis hack

texture_t	*r_notexture_mip;

cvar_t	r_norefresh = {"r_norefresh","0"};
cvar_t	r_drawentities = {"r_drawentities","1"};
cvar_t	r_drawflame = {"r_drawflame","1"};
cvar_t	r_speeds = {"r_speeds","0"};
cvar_t	r_fullbright = {"r_fullbright","0"};
cvar_t	r_lightmap = {"r_lightmap","0"};
cvar_t	r_shadows = {"r_shadows","0"};
cvar_t	r_wateralpha = {"r_wateralpha","1"};
cvar_t	r_dynamic = {"r_dynamic","1"};
cvar_t	r_novis = {"r_novis","0"};
cvar_t	r_netgraph = {"r_netgraph","0"};
cvar_t	r_fullbrightSkins = {"r_fullbrightSkins", "0"};
cvar_t	r_fastsky = {"r_fastsky", "0"};
cvar_t	r_skycolor = {"r_skycolor", "4"};
cvar_t	r_fastturb = {"r_fastturb", "0"};

cvar_t	gl_subdivide_size = {"gl_subdivide_size", "64", CVAR_ARCHIVE};
cvar_t	gl_clear = {"gl_clear","0"};
cvar_t	gl_cull = {"gl_cull","1"};
cvar_t	gl_texsort = {"gl_texsort","1"};
cvar_t	gl_ztrick = {"gl_ztrick", "1"};
cvar_t	gl_smoothmodels = {"gl_smoothmodels","1"};
cvar_t	gl_affinemodels = {"gl_affinemodels","0"};
cvar_t	gl_polyblend = {"gl_polyblend","1"};
cvar_t	gl_flashblend = {"gl_flashblend","0"};
cvar_t	gl_playermip = {"gl_playermip","0"};
cvar_t	gl_nocolors = {"gl_nocolors","0"};
cvar_t	gl_finish = {"gl_finish","0"};
cvar_t	gl_fb_depthhack = {"gl_fb_depthhack","1"};
cvar_t	gl_fb_bmodels = {"gl_fb_bmodels","1"};
cvar_t	gl_fb_models = {"gl_fb_models","1"};
cvar_t	gl_colorlights = {"gl_colorlights","1"};
cvar_t	gl_loadlitfiles = {"gl_loadlitfiles","1"};
cvar_t	gl_lightmode = {"gl_lightmode","2"};
cvar_t	gl_solidparticles = {"gl_solidparticles", "0"};

int		lightmode = 2;

void R_Init (unsigned char *palette)
{
}

void R_RenderView (void)
{
}

// matatk:
void VID_Update(vrect_t *rects)
{
}

void D_DisableBackBufferAccess()
{
}

void D_EnableBackBufferAccess()
{
}