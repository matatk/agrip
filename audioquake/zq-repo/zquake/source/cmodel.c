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
// cmodel.c

#include "common.h"

#ifdef hpux
	// HP-UX already has a typedef cnode_t
	// --> we rename it for that platform:
#  ifdef cnode_t
#    undef cnode_t
#  endif
#  define cnode_t	mycnode_t
#endif


typedef struct cnode_s
{
// common with leaf
	int			contents;		// 0, to differentiate from leafs
	struct cnode_s	*parent;

// node specific
	mplane_t	*plane;
	struct cnode_s	*children[2];	
} cnode_t;


typedef struct cleaf_s
{
// common with node
	int			contents;		// a negative contents number
	struct cnode_s	*parent;

// leaf specific
	byte		ambient_sound_level[NUM_AMBIENTS];
} cleaf_t;



static char			loadname[32];	// for hunk tags

static char			map_name[MAX_QPATH];
static unsigned int	map_checksum, map_checksum2;

static int			numcmodels;
static cmodel_t		map_cmodels[MAX_MAP_MODELS];

static mplane_t		*map_planes;
static int			numplanes;

static cnode_t		*map_nodes;
static int			numnodes;

static dclipnode_t	*map_clipnodes;
static int			numclipnodes;

static cleaf_t		*map_leafs;
static int			numleafs;
static int			visleafs;

static byte			map_novis[MAX_MAP_LEAFS/8];

static byte			*map_pvs;					// fully expanded and decompressed
static byte			*map_phs;					// only valid if we are the server
static int			map_vis_rowbytes;			// for both pvs and phs
static int			map_vis_rowlongs;			// map_vis_rowbytes / 4

static char			*map_entitystring;

static qbool		map_halflife;

static byte			*cmod_base;					// for CM_Load* functions



/*
===============================================================================

HULL BOXES

===============================================================================
*/

static hull_t		box_hull;
static dclipnode_t	box_clipnodes[6];
static mplane_t		box_planes[6];

/*
** CM_InitBoxHull
**
** Set up the planes and clipnodes so that the six floats of a bounding box
** can just be stored out and get a proper hull_t structure.
*/
static void CM_InitBoxHull (void)
{
	int		i;
	int		side;

	box_hull.clipnodes = box_clipnodes;
	box_hull.planes = box_planes;
	box_hull.firstclipnode = 0;
	box_hull.lastclipnode = 5;

	for (i=0 ; i<6 ; i++)
	{
		box_clipnodes[i].planenum = i;
		
		side = i&1;
		
		box_clipnodes[i].children[side] = CONTENTS_EMPTY;
		if (i != 5)
			box_clipnodes[i].children[side^1] = i + 1;
		else
			box_clipnodes[i].children[side^1] = CONTENTS_SOLID;
		
		box_planes[i].type = i>>1;
		box_planes[i].normal[i>>1] = 1;
	}
	
}


/*
** CM_HullForBox
**
** To keep everything totally uniform, bounding boxes are turned into small
** BSP trees instead of being compared directly.
*/
hull_t *CM_HullForBox (vec3_t mins, vec3_t maxs)
{
	box_planes[0].dist = maxs[0];
	box_planes[1].dist = mins[0];
	box_planes[2].dist = maxs[1];
	box_planes[3].dist = mins[1];
	box_planes[4].dist = maxs[2];
	box_planes[5].dist = mins[2];

	return &box_hull;
}


int CM_HullPointContents (hull_t *hull, int num, vec3_t p)
{
	float		d;
	dclipnode_t	*node;
	mplane_t	*plane;

	while (num >= 0)
	{
		if (num < hull->firstclipnode || num > hull->lastclipnode)
			Sys_Error ("CM_HullPointContents: bad node number");
	
		node = hull->clipnodes + num;
		plane = hull->planes + node->planenum;
		
		if (plane->type < 3)
			d = p[plane->type] - plane->dist;
		else
			d = DotProduct (plane->normal, p) - plane->dist;
		if (d < 0)
			num = node->children[1];
		else
			num = node->children[0];
	}
	
	return num;
}


/*
===============================================================================

LINE TESTING IN HULLS

===============================================================================
*/

// 1/32 epsilon to keep floating point happy
#define	DIST_EPSILON	(0.03125)

static hull_t	trace_hull;
static trace_t	trace_trace;

static qbool RecursiveHullTrace (int num, float p1f, float p2f, vec3_t p1, vec3_t p2)
{
	dclipnode_t	*node;
	mplane_t	*plane;
	float		t1, t2;
	float		frac;
	int			i;
	vec3_t		mid;
	int			side;
	float		midf;

// check for empty
	if (num < 0)
	{
		if (num != CONTENTS_SOLID)
		{
			trace_trace.allsolid = false;
			if (num == CONTENTS_EMPTY)
				trace_trace.inopen = true;
			else
				trace_trace.inwater = true;
		}
		else
			trace_trace.startsolid = true;
		return true;		// empty
	}

	// FIXME, check at load time
	if (num < trace_hull.firstclipnode || num > trace_hull.lastclipnode)
		Sys_Error ("RecursiveHullTrace: bad node number");

//
// find the point distances
//
	node = trace_hull.clipnodes + num;
	plane = trace_hull.planes + node->planenum;

	if (plane->type < 3)
	{
		t1 = p1[plane->type] - plane->dist;
		t2 = p2[plane->type] - plane->dist;
	}
	else
	{
		t1 = DotProduct (plane->normal, p1) - plane->dist;
		t2 = DotProduct (plane->normal, p2) - plane->dist;
	}
	
#if 1
	if (t1 >= 0 && t2 >= 0)
		return RecursiveHullTrace (node->children[0], p1f, p2f, p1, p2);
	if (t1 < 0 && t2 < 0)
		return RecursiveHullTrace (node->children[1], p1f, p2f, p1, p2);
#else
	if ( (t1 >= DIST_EPSILON && t2 >= DIST_EPSILON) || (t2 > t1 && t1 >= 0) )
		return RecursiveHullTrace (node->children[0], p1f, p2f, p1, p2);
	if ( (t1 <= -DIST_EPSILON && t2 <= -DIST_EPSILON) || (t2 < t1 && t1 <= 0) )
		return RecursiveHullTrace (node->children[1], p1f, p2f, p1, p2);
#endif

// put the crosspoint DIST_EPSILON pixels on the near side
	if (t1 < 0)
		frac = (t1 + DIST_EPSILON)/(t1-t2);
	else
		frac = (t1 - DIST_EPSILON)/(t1-t2);
	if (frac < 0)
		frac = 0;
	if (frac > 1)
		frac = 1;
		
	midf = p1f + (p2f - p1f)*frac;
	for (i=0 ; i<3 ; i++)
		mid[i] = p1[i] + frac*(p2[i] - p1[i]);

	side = (t1 < 0);

// move up to the node
	if (!RecursiveHullTrace (node->children[side], p1f, midf, p1, mid))
		return false;

#ifdef PARANOID
	if (CM_HullPointContents (sv_hullmodel, mid, node->children[side])
	== CONTENTS_SOLID)
	{
		Com_Printf ("mid PointInHullSolid\n");
		return false;
	}
#endif
	
	if (CM_HullPointContents (&trace_hull, node->children[side^1], mid)
	!= CONTENTS_SOLID)
// go past the node
		return RecursiveHullTrace (node->children[side^1], midf, p2f, mid, p2);
	
	if (trace_trace.allsolid)
		return false;		// never got out of the solid area
		
//==================
// the other side of the node is solid, this is the impact point
//==================
	if (!side)
	{
		VectorCopy (plane->normal, trace_trace.plane.normal);
		trace_trace.plane.dist = plane->dist;
	}
	else
	{
		VectorNegate (plane->normal, trace_trace.plane.normal);
		trace_trace.plane.dist = -plane->dist;
	}

	while (CM_HullPointContents (&trace_hull, trace_hull.firstclipnode, mid)
	== CONTENTS_SOLID)
	{ // shouldn't really happen, but does occasionally
		frac -= 0.1;
		if (frac < 0)
		{
			trace_trace.fraction = midf;
			VectorCopy (mid, trace_trace.endpos);
			Com_DPrintf ("backup past 0\n");
			return false;
		}
		midf = p1f + (p2f - p1f)*frac;
		for (i=0 ; i<3 ; i++)
			mid[i] = p1[i] + frac*(p2[i] - p1[i]);
	}

	trace_trace.fraction = midf;
	VectorCopy (mid, trace_trace.endpos);

	return false;
}

// trace a line through the supplied clipping hull
// does not fill trace.e.ent
trace_t CM_HullTrace (hull_t *hull, vec3_t start, vec3_t end)
{
	// fill in a default trace
	memset (&trace_trace, 0, sizeof(trace_trace));
	trace_trace.fraction = 1;
	trace_trace.allsolid = true;
//	trace_trace.startsolid = true;		// this was (commented out) in pmovetst.c, why? -- Tonik
	VectorCopy (end, trace_trace.endpos);

	trace_hull = *hull;

	RecursiveHullTrace (trace_hull.firstclipnode, 0, 1, start, end);

	return trace_trace;
}

//===========================================================================


int	CM_NumInlineModels (void)
{
	return numcmodels;
}

char *CM_EntityString (void)
{
	return map_entitystring;
}

int CM_Leafnum (const cleaf_t *leaf)
{
	assert (leaf);
	return leaf - map_leafs;
}

int	CM_LeafAmbientLevel (const cleaf_t *leaf, int ambient_channel)
{
	assert ((unsigned)ambient_channel <= NUM_AMBIENTS);
	assert (leaf);

	return leaf->ambient_sound_level[ambient_channel];
}

// always returns a valid cleaf_t pointer
cleaf_t *CM_PointInLeaf (const vec3_t p)
{
	cnode_t		*node;
	float		d;
	mplane_t	*plane;
	
	if (!numnodes)
		Host_Error ("CM_PointInLeaf: numnodes == 0");

	node = map_nodes;
	while (1)
	{
		if (node->contents < 0)
			return (cleaf_t *)node;
		plane = node->plane;
		d = DotProduct (p,plane->normal) - plane->dist;
		if (d > 0)
			node = node->children[0];
		else
			node = node->children[1];
	}
	
	return NULL;	// never reached
}


byte *CM_LeafPVS (const cleaf_t *leaf)
{
	if (leaf == map_leafs)
		return map_novis;

	return map_pvs + (leaf - 1 - map_leafs) * map_vis_rowbytes;
}


/*
** only the server may call this
*/
byte *CM_LeafPHS (const cleaf_t *leaf)
{
	if (leaf == map_leafs)
		return map_novis;

	return map_phs + (leaf - 1 - map_leafs) * map_vis_rowbytes;
}

/*
=============================================================================

The PVS must include a small area around the client to allow head bobbing
or other small motion on the client side.  Otherwise, a bob might cause an
entity that should be visible to not show up, especially when the bob
crosses a waterline.

=============================================================================
*/
static int	fatbytes;
static byte	fatpvs[MAX_MAP_LEAFS/8];
static vec3_t	fatpvs_org;

static void AddToFatPVS_r (cnode_t *node)
{
	int		i;
	byte	*pvs;
	mplane_t	*plane;
	float	d;

	while (1)
	{
	// if this is a leaf, accumulate the pvs bits
		if (node->contents < 0)
		{
			if (node->contents != CONTENTS_SOLID)
			{
				pvs = CM_LeafPVS ( (cleaf_t *)node);
				for (i=0 ; i<fatbytes ; i++)
					fatpvs[i] |= pvs[i];
			}
			return;
		}
	
		plane = node->plane;
		d = DotProduct (fatpvs_org, plane->normal) - plane->dist;
		if (d > 8)
			node = node->children[0];
		else if (d < -8)
			node = node->children[1];
		else
		{	// go down both
			AddToFatPVS_r (node->children[0]);
			node = node->children[1];
		}
	}
}

/*
=============
CM_FatPVS

Calculates a PVS that is the inclusive or of all leafs within 8 pixels of the
given point.
=============
*/
byte *CM_FatPVS (vec3_t org)
{
	VectorCopy (org, fatpvs_org);

	fatbytes = (visleafs+31)>>3;
	memset (fatpvs, 0, fatbytes);
	AddToFatPVS_r (map_nodes);
	return fatpvs;
}


/*
** Recursively build a list of leafs touched by a rectangular volume
*/
static int leafs_count;
static int leafs_maxcount;
static int *leafs_list;
static int leafs_topnode;
static vec3_t leafs_mins, leafs_maxs;

static void FindTouchedLeafs_r (const cnode_t *node)
{
	mplane_t *splitplane;
	cleaf_t	*leaf;
	int sides;

	while (1)
	{
		if (node->contents == CONTENTS_SOLID)
			return;

	// the node is a leaf
		if (node->contents < 0)
		{
			if (leafs_count == leafs_maxcount)
				return;

			leaf = (cleaf_t *)node;
			leafs_list[leafs_count++] = leaf - map_leafs;
			return;
		}
		
	// NODE_MIXED
		splitplane = node->plane;
		sides = BOX_ON_PLANE_SIDE (leafs_mins, leafs_maxs, splitplane);
		
	// recurse down the contacted sides
		if (sides == 1)
			node = node->children[0];
		else if (sides == 2)
			node = node->children[1];
		else
		{
			if (leafs_topnode == -1)
				leafs_topnode = node - map_nodes;
			FindTouchedLeafs_r (node->children[0]);
			node = node->children[1];
		}
	}
}

/*
** Returns an array filled with leaf nums
*/
int CM_FindTouchedLeafs (const vec3_t mins, const vec3_t maxs, int leafs[], int maxleafs, int headnode, int *topnode)
{
	leafs_count = 0;
	leafs_maxcount = maxleafs;
	leafs_list = leafs;
	leafs_topnode = -1;
	VectorCopy (mins, leafs_mins);
	VectorCopy (maxs, leafs_maxs);

	FindTouchedLeafs_r (&map_nodes[headnode]);

	if (topnode)
		*topnode = leafs_topnode;

	return leafs_count;
}


/*
===============================================================================

					BRUSHMODEL LOADING

===============================================================================
*/

static void CM_LoadEntities (lump_t *l)
{
	if (!l->filelen) {
		map_entitystring = NULL;
		return;
	}
	map_entitystring = Hunk_AllocName ( l->filelen, loadname);	
	memcpy (map_entitystring, cmod_base + l->fileofs, l->filelen);
}


/*
=================
CM_LoadSubmodels
=================
*/
static void CM_LoadSubmodels (lump_t *l)
{
	dmodel_t	*in;
	cmodel_t	*out;
	int			i, j, count;

	in = (dmodel_t *)(cmod_base + l->fileofs);
	if (l->filelen % sizeof(*in))
		Host_Error ("CM_LoadMap: funny lump size");
	count = l->filelen / sizeof(*in);

	if (count < 1)
		Host_Error ("Map with no models");
	if (count > MAX_MAP_MODELS)
		Host_Error ("Map has too many models");

	out = map_cmodels;
	numcmodels = count;

	visleafs = LittleLong (in[0].visleafs);

	for (i = 0; i < count; i++, in++, out++)
	{
		for (j = 0; j < 3; j++) {
			// spread the mins / maxs by a pixel
			out->mins[j] = LittleFloat (in->mins[j]) - 1;
			out->maxs[j] = LittleFloat (in->maxs[j]) + 1;
			out->origin[j] = LittleFloat (in->origin[j]);
		}
		for (j = 0; j < MAX_MAP_HULLS; j++) {
			out->hulls[j].planes = map_planes;
			out->hulls[j].clipnodes = map_clipnodes;
			out->hulls[j].firstclipnode = LittleLong (in->headnode[j]);
			out->hulls[j].lastclipnode = numclipnodes - 1;
		}

		VectorClear (out->hulls[0].clip_mins);
		VectorClear (out->hulls[0].clip_maxs);

		if (map_halflife)
		{
			VectorSet (out->hulls[1].clip_mins, -16, -16, -32);
			VectorSet (out->hulls[1].clip_maxs, 16, 16, 32);

			VectorSet (out->hulls[2].clip_mins, -32, -32, -32);
			VectorSet (out->hulls[2].clip_maxs, 32, 32, 32);
			// not really used
			VectorSet (out->hulls[3].clip_mins, -16, -16, -18);
			VectorSet (out->hulls[3].clip_maxs, 16, 16, 18);
		}
		else
		{
			VectorSet (out->hulls[1].clip_mins, -16, -16, -24);
			VectorSet (out->hulls[1].clip_maxs, 16, 16, 32);

			VectorSet (out->hulls[2].clip_mins, -32, -32, -24);
			VectorSet (out->hulls[2].clip_maxs, 32, 32, 64);
		}
	}
}

/*
=================
CM_SetParent
=================
*/
static void CM_SetParent (cnode_t *node, cnode_t *parent)
{
	node->parent = parent;
	if (node->contents < 0)
		return;
	CM_SetParent (node->children[0], node);
	CM_SetParent (node->children[1], node);
}

/*
=================
CM_LoadNodes
=================
*/
static void CM_LoadNodes (lump_t *l)
{
	int			i, j, count, p;
	dnode_t		*in;
	cnode_t 	*out;

	in = (dnode_t *)(cmod_base + l->fileofs);
	if (l->filelen % sizeof(*in))
		Host_Error ("CM_LoadMap: funny lump size");
	count = l->filelen / sizeof(*in);
	out = Hunk_AllocName ( count*sizeof(*out), loadname);	

	map_nodes = out;
	numnodes = count;

	for (i = 0; i < count; i++, in++, out++)
	{
		p = LittleLong(in->planenum);
		out->plane = map_planes + p;

		for (j=0 ; j<2 ; j++)
		{
			p = LittleShort (in->children[j]);
			if (p >= 0)
				out->children[j] = map_nodes + p;
			else
				out->children[j] = (cnode_t *)(map_leafs + (-1 - p));
		}
	}
	
	CM_SetParent (map_nodes, NULL);		// sets nodes and leafs
}

/*
** CM_LoadLeafs
*/
static void CM_LoadLeafs (lump_t *l)
{
	dleaf_t 	*in;
	cleaf_t 	*out;
	int			i, j, count, p;

	in = (dleaf_t *)(cmod_base + l->fileofs);
	if (l->filelen % sizeof(*in))
		Host_Error ("CM_LoadMap: funny lump size");
	count = l->filelen / sizeof(*in);
	out = Hunk_AllocName ( count*sizeof(*out), loadname);	

	map_leafs = out;
	numleafs = count;

	for (i = 0; i < count; i++, in++, out++) {
		p = LittleLong(in->contents);
		out->contents = p;
		for (j = 0; j < 4; j++)
			out->ambient_sound_level[j] = in->ambient_level[j];
	}	

}

/*
=================
CM_LoadClipnodes
=================
*/
static void CM_LoadClipnodes (lump_t *l)
{
	dclipnode_t *in, *out;
	int			i, count;

	in = (void *)(cmod_base + l->fileofs);
	if (l->filelen % sizeof(*in))
		Host_Error ("CM_LoadMap: funny lump size");
	count = l->filelen / sizeof(*in);
	out = Hunk_AllocName ( count*sizeof(*out), loadname);	

	map_clipnodes = out;
	numclipnodes = count;

	for (i = 0; i < count; i++, out++, in++)
	{
		out->planenum = LittleLong(in->planenum);
		out->children[0] = LittleShort(in->children[0]);
		out->children[1] = LittleShort(in->children[1]);
	}
}

/*
=================
CM_MakeHull0

Deplicate the drawing hull structure as a clipping hull
=================
*/
static void CM_MakeHull0 (void)
{
	cnode_t		*in, *child;
	dclipnode_t *out;
	int			i, j, count;

	in = map_nodes;
	count = numnodes;
	out = Hunk_AllocName ( count*sizeof(*out), loadname);	

	// fix up hull 0 in all cmodels
	for (i = 0; i < numcmodels; i++) {
		map_cmodels[i].hulls[0].clipnodes = out;
		map_cmodels[i].hulls[0].lastclipnode = count - 1;
	}

	// build clipnodes from nodes
	for (i = 0; i < count; i++, out++, in++)
	{
		out->planenum = in->plane - map_planes;
		for (j = 0; j < 2; j++)
		{
			child = in->children[j];
			if (child->contents < 0)
				out->children[j] = child->contents;
			else
				out->children[j] = child - map_nodes;
		}
	}
}

/*
=================
CM_LoadPlanes
=================
*/
static void CM_LoadPlanes (lump_t *l)
{
	int			i, j;
	mplane_t	*out;
	dplane_t 	*in;
	int			count;
	int			bits;
	
	in = (void *)(cmod_base + l->fileofs);
	if (l->filelen % sizeof(*in))
		Host_Error ("CM_LoadMap: funny lump size");
	count = l->filelen / sizeof(*in);
	out = Hunk_AllocName (count * sizeof(*out), loadname);	
	
	map_planes = out;
	numplanes = count;

	for (i = 0; i < count; i++, in++, out++)
	{
		bits = 0;
		for (j=0 ; j<3 ; j++)
		{
			out->normal[j] = LittleFloat (in->normal[j]);
			if (out->normal[j] < 0)
				bits |= 1<<j;
		}

		out->dist = LittleFloat (in->dist);
		out->type = LittleLong (in->type);
		out->signbits = bits;
	}
}


/*
** DecompressVis
*/
static byte *DecompressVis (byte *in)
{
	static byte	decompressed[MAX_MAP_LEAFS/8];
	int		c;
	byte	*out;
	int		row;

	row = (visleafs + 7) >> 3;	
	out = decompressed;

	if (!in)
	{	// no vis info, so make all visible
		while (row)
		{
			*out++ = 0xff;
			row--;
		}
		return decompressed;		
	}

	do
	{
		if (*in)
		{
			*out++ = *in++;
			continue;
		}
	
		c = in[1];
		in += 2;
		while (c)
		{
			*out++ = 0;
			c--;
		}
	} while (out - decompressed < row);
	
	return decompressed;
}


/*
** CM_BuildPVS
**
** Call after CM_LoadLeafs!
*/
static void CM_BuildPVS (lump_t *lump_vis, lump_t *lump_leafs)
{
	int		i;
	byte	*visdata;
	dleaf_t *in;
	byte	*scan;

	map_vis_rowlongs = (visleafs + 31) >> 5;
	map_vis_rowbytes = map_vis_rowlongs * 4;
	map_pvs = Hunk_Alloc (map_vis_rowbytes * visleafs);

	if (!lump_vis->filelen) {
		memset (map_pvs, 0xff, map_vis_rowbytes * visleafs);
		return;
	}

	// FIXME, add checks for lump_vis->filelen and leafs' visofs

	visdata = cmod_base + lump_vis->fileofs;

	// go through all leafs and decompress visibility data
	in = (dleaf_t *)(cmod_base + lump_leafs->fileofs);
	in++;	// pvs row 0 is leaf 1
	scan = map_pvs;
	for (i = 0; i < visleafs; i++, in++, scan += map_vis_rowbytes)
	{
		int p = LittleLong(in->visofs);
		if (p == -1)
			memcpy (scan, map_novis, map_vis_rowbytes);
		else
			memcpy (scan, DecompressVis (visdata + p), map_vis_rowbytes);
	}	
}


/*
** CM_BuildPHS
**
** Expands the PVS and calculates the PHS (potentially hearable set)
** Call after CM_BuildPVS (so that map_vis_rowbytes & map_vis_rowlongs are set)
*/
static void CM_BuildPHS (void)
{
	int		i, j, k, l, index;
	int		bitbyte;
	unsigned	*dest, *src;
	byte	*scan;

	map_phs = Hunk_Alloc (map_vis_rowbytes * visleafs);
	scan = map_pvs;
	dest = (unsigned *)map_phs;
	for (i = 0; i < visleafs; i++, dest += map_vis_rowlongs, scan += map_vis_rowbytes)
	{
		// copy from pvs
		memcpy (dest, scan, map_vis_rowbytes);

		// or in hearable leafs
		for (j = 0; j < map_vis_rowbytes; j++)
		{
			bitbyte = scan[j];
			if (!bitbyte)
				continue;
			for (k = 0; k < 8; k++)
			{
				if (! (bitbyte & (1<<k)) )
					continue;
				// or this pvs row into the phs
				index = (j<<3) + k;
				if (index >= visleafs)
					continue;
				src = (unsigned *)map_pvs + index * map_vis_rowlongs;
				for (l = 0; l < map_vis_rowlongs; l++)
					dest[l] |= src[l];
			}
		}
	}
}



/*
** hunk was reset by host, so the data is no longer valid
*/
void CM_InvalidateMap (void)
{
	map_name[0] = 0;

	// null out the pointers to turn up any attempt to call CM functions
	map_planes = NULL;
	map_nodes = NULL;
	map_clipnodes = NULL;
	map_leafs = NULL;
	map_pvs = NULL;
	map_phs = NULL;
	map_entitystring = NULL;
}

/*
** CM_LoadMap
*/
cmodel_t *CM_LoadMap (char *name, qbool clientload, unsigned *checksum, unsigned *checksum2)
{
	int			i;
	dheader_t	*header;
	unsigned int *buf;

	if (map_name[0]) {
		assert(!strcmp(name, map_name));

		if (checksum)
			*checksum = map_checksum;
		*checksum2 = map_checksum2;
		return &map_cmodels[0];		// still have the right version
	}

	// load the file
	buf = (unsigned int *)FS_LoadTempFile (name);
	if (!buf)
		Host_Error ("CM_LoadMap: %s not found", name);

	COM_FileBase (name, loadname);

	header = (dheader_t *)buf;

	i = LittleLong (header->version);
	if (i != BSPVERSION && i != HL_BSPVERSION)
		Host_Error ("CM_LoadMap: %s has wrong version number (%i should be %i)", name, i, BSPVERSION);

	map_halflife = (i == HL_BSPVERSION);

	// let progs know if we've loaded a Half-Life map
	if (!clientload)
		Cvar_ForceSet(Cvar_Get("sv_halflifebsp", "0", CVAR_ROM), map_halflife ? "1" : "0");

	// swap all the lumps
	cmod_base = (byte *)header;

	for (i = 0; i < sizeof(dheader_t)/4; i++)
		((int *)header)[i] = LittleLong(((int *)header)[i]);

	// checksum all of the map, except for entities
	map_checksum = map_checksum2 = 0;
	for (i = 0; i < HEADER_LUMPS; i++) {
		if (i == LUMP_ENTITIES)
			continue;
		map_checksum ^= LittleLong(Com_BlockChecksum(cmod_base + header->lumps[i].fileofs, 
			header->lumps[i].filelen));

		if (i == LUMP_VISIBILITY || i == LUMP_LEAFS || i == LUMP_NODES)
			continue;
		map_checksum2 ^= LittleLong(Com_BlockChecksum(cmod_base + header->lumps[i].fileofs, 
			header->lumps[i].filelen));
	}
	if (checksum)
		*checksum = map_checksum;
	*checksum2 = map_checksum2;

	// load into heap
	CM_LoadPlanes (&header->lumps[LUMP_PLANES]);
	CM_LoadLeafs (&header->lumps[LUMP_LEAFS]);
	CM_LoadNodes (&header->lumps[LUMP_NODES]);
	CM_LoadClipnodes (&header->lumps[LUMP_CLIPNODES]);
	CM_LoadEntities (&header->lumps[LUMP_ENTITIES]);
	CM_LoadSubmodels (&header->lumps[LUMP_MODELS]);

	CM_MakeHull0 ();

	CM_BuildPVS (&header->lumps[LUMP_VISIBILITY], &header->lumps[LUMP_LEAFS]);

	if (!clientload)			// client doesn't need PHS
		CM_BuildPHS ();

	strlcpy (map_name, name, sizeof(map_name));

	return &map_cmodels[0];
}

cmodel_t *CM_InlineModel (char *name)
{
	int		num;

	if (!name || name[0] != '*')
		Host_Error ("CM_InlineModel: bad name");

	num = atoi (name+1);
	if (num < 1 || num >= numcmodels)
		Host_Error ("CM_InlineModel: bad number");

	return &map_cmodels[num];
}


void CM_Init (void)
{
	memset (map_novis, 0xff, sizeof(map_novis));
	CM_InitBoxHull ();
}

/* vi: set noet ts=4 sts=4 ai sw=4: */
