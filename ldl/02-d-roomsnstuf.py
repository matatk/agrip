#!/usr/bin/env python3
"""
	02-d-roomsnstuf.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2008 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.

	This stage takes a room definition and turns it into brushes.

	ASSUMPTIONS
	* All brushes are cuboids made up of 6 planes.
	* The same texture is applied to all planes of each brush.
"""

import sys
import xml.dom.minidom
import ldl
import split
from plane import Point

paddinglevel = -1
padding = '  '


def processMap(doc):
	map = doc.documentElement
	worldspawn = processInfo(doc, map)
	# Go through each successive element and process it accordingly.
	# (Yes, this is very SAX-like but we don't use SAX because by using DOM we
	# get to manipulate the tree as we go, which we do need to do.)
	for node in map.childNodes[1:]:
		processNode(doc, map, worldspawn, s, Point(0, 0, 0), node)


def processInfo(doc, map):
	info = map.firstChild
	for property in info.childNodes:
		# FIXME we assume all children of info are property elements
		ptype = property.getAttribute('name')
		if ptype == 'mapname':
			mapname = property.getAttribute('value')
		elif ptype == 'worldtype':
			worldtype = property.getAttribute('value')
			if worldtype in ldl.worldtypes:
				worldtype_num = ldl.worldtypes[worldtype]
			else:
				ldl.error('Invalid worldtype ' + worldtype + ' specified.')
		else:
			ldl.error('Invalid map info property ' + ptype + ' specified.')
	worldspawn = doc.createElement('entity')
	worldspawn.appendChild(ldl.createProperty(doc, 'classname', 'worldspawn'))
	worldspawn.appendChild(
		ldl.createProperty(doc, 'worldtype', str(worldtype_num)))
	worldspawn.appendChild(ldl.createProperty(doc, 'message', mapname))
	worldspawn.appendChild(ldl.createProperty(doc, 'wad', ldl.wadfile))
	map.replaceChild(worldspawn, info)
	return worldspawn


def processNode(doc, parent, worldspawn, s, offset, node):
	global paddinglevel
	paddinglevel = paddinglevel + 1
	if node.localName == 'hollow':
		processHollow(doc, parent, worldspawn, s, offset, node)
	elif node.localName == 'solid':
		processSolid(doc, parent, worldspawn, s, offset, node)
	elif node.localName == 'entity':
		processEntity(doc, parent, offset, node)
	elif node.localName is None:
		pass  # comment node
	else:
		ldl.error('unknown element type ' + node.localName + '.\n')
	paddinglevel = paddinglevel - 1


style = None


def processHollow(doc, parent, worldspawn, s, offset, hollow):
	'''Note: sets global style var.'''
	global style
	o = ldl.getPoint(hollow.getAttribute('origin')) + offset
	e = ldl.getPoint(hollow.getAttribute('extent'))
	style = hollow.getAttribute('style')
	holes = {}
	absentwalls = []
	# FIXME the following is where we see if this hollow contains an
	# absentwalls element and a holes element before proceeding.  It's
	# implemented in a bit of a hacky way; we ought to be using SAX but then it
	# would be a *lot* more work to create the output XML.  This way we can
	# just change what's there a bit.
	for hollowChild in hollow.childNodes:
		if hollowChild.localName == 'absentwalls':
			# Get absent walls info...
			for absentwall in hollowChild.childNodes:
				wall = absentwall.getAttribute('value')
				absentwalls.append(wall)
			ldl.insertPlaceholder(doc, hollow, hollowChild)
		elif hollowChild.localName == 'holes':
			# Get holes info...
			for hole in hollowChild.childNodes:
				wall = hole.getAttribute('wall')
				# If we've not added a hole to this wall yet then set up an empty array...
				if wall not in holes:
					holes[wall] = []
				o_x, o_y = hole.getAttribute('origin').split()
				e_x, e_y = hole.getAttribute('extent').split()
				type = hole.getAttribute('type')
				if type == ldl.RT_DOOR:
					key = hole.getAttribute('key')
					button = hole.getAttribute('button')  # FIXME test real map
				else:
					key = button = None  # FIXME test real map
				# FIXME deal with other types
				holes[wall].append(ldl.Hole2D(
					ldl.Point2D(float(o_x), float(o_y)),
					ldl.Point2D(float(e_x), float(e_y)),
					type, {ldl.PROPS_K_KEY: key}))
			# FIXME we shouldn't need to detect overlapping holes here because
			# they'll be detected higher up (by overlapping connected hollows)
			ldl.insertPlaceholder(doc, hollow, hollowChild)

	# Now we have the required structural info (absent walls and holes), we can
	# turn this hollow into a series of textured brushes...
	io, ie = ldl.makeHollow(doc, worldspawn, s, o, e, absentwalls, holes, style)
	# Contained solids, hollows and entities...
	for node in hollow.childNodes:
		processNode(doc, hollow, worldspawn, s, io, node)
	# We can't remove the child or we screw over tree traversal (urgh)...
	ldl.insertPlaceholder(doc, parent, hollow)


def processSolid(doc, parent, worldspawn, sf, offset, solid):
	'''Note: uses style set in parent hollow.'''
	global style
	o = ldl.getPoint(solid.getAttribute('origin')) + offset
	e = ldl.getPoint(solid.getAttribute('extent'))
	t = solid.getAttribute('texture')
	type = solid.getAttribute('type')
	if not t:
		if not type:
			ldl.error('solid with no type also has no texture attribute set')
	f = solid.getAttribute('holeface')
	# Get holes info...
	# FIXME this is repeated code from the hollow one -- any way we can
	# refactor it?
	props = {}
	holes = []
	# Check if the solid has children (holes).
	# If so, split it up.
	# If not, just add it.
	if solid.hasChildNodes():
		for hole in solid.childNodes:
			ho_x, ho_y = hole.getAttribute('origin').split()
			he_x, he_y = hole.getAttribute('extent').split()
			type = hole.getAttribute('type')
			if not type:
				pass
			elif type == ldl.RT_DOOR:
				props[ldl.PROPS_K_KEY] = hole.getAttribute('key')
			else:
				ldl.warning('only doors allowed as hole types; not plats or others.')
			# FIXME deal with other types
			holes.append(ldl.Hole2D(
				ldl.Point2D(float(ho_x), float(ho_y)),
				ldl.Point2D(float(he_x), float(he_y)),
				type, props))
		# Built split (2D) parts into 3D brushes; mapping of coords to 3D
		# depends on which direction/face the hole was constructed in.
		if f == ldl.DCP_NORTH:
			parts = split.splitWall(
				ldl.Region2D(
					ldl.Point2D(o.x, o.z),
					ldl.Point2D(e.x, e.z)
				),
				holes)
			for part in parts:
				part3d = ldl.addDim(part, ldl.DIM_Y, o.y, e.y)
				ldl.makeBrush(doc, worldspawn, sf, style, part3d, f, t)
		elif f == ldl.DCP_UP:
			parts = split.splitWall(
				ldl.Region2D(
					ldl.Point2D(o.x, o.y),
					ldl.Point2D(e.x, e.y)
				),
				holes)
			for part in parts:
				part3d = ldl.addDim(
					part, ldl.DIM_Z, o.z + ldl.lip_small, e.z - ldl.lip_small * 2)
				ldl.makeBrush(doc, worldspawn, sf, style, part3d, f, t)
			else:
				ldl.error('Unsupported holeface ' + f + ' requested for hole in solid.')
	else:
		# Doesn't have child nodes...
		if not type or type == ldl.RT_STEP:
			pass  # no properties to set
		elif type == ldl.RT_DOOR:
			props[ldl.PROPS_K_KEY] = solid.getAttribute('key')
		elif type == ldl.RT_PLAT:
			props[ldl.PROPS_K_POS] = solid.getAttribute('position')
		else:
			ldl.warning('unknown type ' + type + ' specifed.')

		brush = ldl.Region3D(
			Point(o.x, o.y, o.z),
			Point(e.x, e.y, e.z),
			type,
			props
		)
		ldl.makeBrush(doc, worldspawn, sf, style, brush, type, t)
	# We can't remove the child or we screw over tree traversal (urgh)...
	ldl.insertPlaceholder(doc, parent, solid)


def processEntity(doc, parent, offset, entity):
	# Adjust coords...
	for property in entity.childNodes:  # assume all children are property nodes
		if property.getAttribute('name') == 'origin':
			o = ldl.getPoint(property.getAttribute('value')) + offset
			property.setAttribute('value', str(o))
	# Clone node (inc properties) and add to map...
	doc.documentElement.appendChild(entity.cloneNode(True))


if __name__ == '__main__':
	ldl.stage = '02'
	ldl.uprint('\n === ' + ldl.stackdescs[ldl.stage] + ' ===')
	s = ldl.StyleFetcher()
	try:
		m = xml.dom.minidom.parse(sys.stdin)
	except:  # noqa E722
		ldl.failParse()
	ldl.remove_whitespace_nodes(m)
	processMap(m)
	m.getElementsByTagName('map')[0] \
		.setAttribute('stackdesc', ldl.stackdescs['02'])
	m.getElementsByTagName('map')[0].setAttribute('generator', __file__)
	print(m.toprettyxml())
	m.unlink()
