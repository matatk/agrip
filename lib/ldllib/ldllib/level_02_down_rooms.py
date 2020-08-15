#!/usr/bin/env python3
"""
	level_02_down_rooms.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2019 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.

	This stage takes a room definition and turns it into brushes.

	ASSUMPTIONS
	* All brushes are cuboids made up of 6 planes.
	* The same texture is applied to all planes of each brush.
"""

import xml.dom.minidom
import ldllib.utils as utils
import ldllib.split as split
from ldllib.plane import Point
from ldllib.conf import (
	connector,
	dcp,
	dims,
	prog,
	worldtypes
)

paddinglevel = -1
padding = '  '


def processMap(doc):
	map = doc.documentElement
	worldtype, worldspawn = processInfo(doc, map)
	# Go through each successive element and process it accordingly.
	# (Yes, this is very SAX-like but we don't use SAX because by using DOM we
	# get to manipulate the tree as we go, which we do need to do.)
	for node in map.childNodes[1:]:
		processNode(doc, map, worldtype, worldspawn, s, Point(0, 0, 0), node)


def processInfo(doc, map):
	info = map.firstChild
	for property in info.childNodes:
		# FIXME we assume all children of info are property elements
		ptype = property.getAttribute('name')
		if ptype == 'mapname':
			mapname = property.getAttribute('value')
		elif ptype == 'worldtype':
			worldtype = property.getAttribute('value')
			if worldtype in worldtypes:  # TODO conf.worldtypes?
				worldtype_num = worldtypes[worldtype]
			else:
				utils.error('Invalid worldtype ' + worldtype + ' specified.')
		else:
			utils.error('Invalid map info property ' + ptype + ' specified.')
	worldspawn = doc.createElement('entity')
	worldspawn.appendChild(utils.createProperty(doc, 'classname', 'worldspawn'))
	worldspawn.appendChild(
		utils.createProperty(doc, 'worldtype', str(worldtype_num)))
	worldspawn.appendChild(utils.createProperty(doc, 'message', mapname))
	# FIXME style:
	worldspawn.appendChild(utils.createProperty(doc, 'wad', str(prog.wadfile)))
	map.replaceChild(worldspawn, info)
	return (worldtype, worldspawn)


def processNode(doc, parent, worldtype, worldspawn, s, offset, node):
	global paddinglevel  # FIXME remove?
	paddinglevel = paddinglevel + 1
	if node.localName == 'hollow':
		processHollow(doc, parent, worldtype, worldspawn, s, offset, node)
	elif node.localName == 'solid':
		processSolid(doc, parent, worldtype, worldspawn, s, offset, node)
	elif node.localName == 'entity':
		processEntity(doc, parent, offset, node)
	elif node.localName is None:
		pass  # comment node
	else:
		utils.error('unknown element type ' + node.localName + '.\n')
	paddinglevel = paddinglevel - 1


def processHollow(doc, parent, worldtype, worldspawn, s, offset, hollow):
	o = utils.getPoint(hollow.getAttribute('origin')) + offset
	e = utils.getPoint(hollow.getAttribute('extent'))
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
			utils.insertPlaceholder(doc, hollow, hollowChild)
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
				if type == connector.DOOR:
					key = hole.getAttribute('key')
					button = hole.getAttribute('button')  # FIXME test real map
				else:
					key = button = None  # FIXME test real map
				# FIXME deal with other types
				holes[wall].append(utils.Hole2D(
					utils.Point2D(float(o_x), float(o_y)),
					utils.Point2D(float(e_x), float(e_y)),
					type, {'key': key}))
			# FIXME we shouldn't need to detect overlapping holes here because
			# they'll be detected higher up (by overlapping connected hollows)
			utils.insertPlaceholder(doc, hollow, hollowChild)

	# Now we have the required structural info (absent walls and holes), we can
	# turn this hollow into a series of textured brushes...
	io, ie = utils.makeHollow(doc, worldtype, worldspawn, s, o, e, absentwalls, holes, style)
	# Contained solids, hollows and entities...
	for node in hollow.childNodes:
		processNode(doc, hollow, worldtype, worldspawn, s, io, node)
	# We can't remove the child or we screw over tree traversal (urgh)...
	utils.insertPlaceholder(doc, parent, hollow)


def processSolid(doc, parent, worldtype, worldspawn, sf, offset, solid):
	style = parent.getAttribute('style')
	o = utils.getPoint(solid.getAttribute('origin')) + offset
	e = utils.getPoint(solid.getAttribute('extent'))
	type = solid.getAttribute('type')
	if not type:
		utils.error('solid with no type')
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
			elif type == connector.DOOR:
				props['key'] = hole.getAttribute('key')
			else:
				utils.warning('only doors allowed as hole types; not plats or others.')
			# FIXME deal with other types
			holes.append(utils.Hole2D(
				utils.Point2D(float(ho_x), float(ho_y)),
				utils.Point2D(float(he_x), float(he_y)),
				type, props))
		# Built split (2D) parts into 3D brushes; mapping of coords to 3D
		# depends on which direction/face the hole was constructed in.
		if f == dcp.NORTH:
			parts = split.splitWall(
				utils.Region2D(
					utils.Point2D(o.x, o.z),
					utils.Point2D(e.x, e.z)
				),
				holes)
			for part in parts:
				part3d = utils.addDim(part, dims.Y, o.y, e.y)
				utils.makeBrush(doc, worldtype, worldspawn, sf, style, part3d, f)
		elif f == dcp.UP:
			parts = split.splitWall(
				utils.Region2D(
					utils.Point2D(o.x, o.y),
					utils.Point2D(e.x, e.y)
				),
				holes)
			for part in parts:
				part3d = utils.addDim(
					part, dims.Z, o.z + prog.lip_small, e.z - prog.lip_small * 2)
				utils.makeBrush(doc, worldtype, worldspawn, sf, style, part3d, f)
			else:
				utils.error('Unsupported holeface ' + f + ' requested for hole in solid.')
	else:
		# Doesn't have child nodes...
		if not type or type == connector.STEP:
			pass  # no properties to set
		elif type == connector.DOOR:
			props['key'] = solid.getAttribute('key')
		elif type == connector.PLAT:
			props['position'] = solid.getAttribute('position')
		else:
			utils.warning('unknown type ' + type + ' specifed.')

		brush = utils.Region3D(
			Point(o.x, o.y, o.z),
			Point(e.x, e.y, e.z),
			type,
			props
		)
		utils.makeBrush(doc, worldtype, worldspawn, sf, style, brush, type)
	# We can't remove the child or we screw over tree traversal (urgh)...
	utils.insertPlaceholder(doc, parent, solid)


def processEntity(doc, parent, offset, entity):
	# Adjust coords...
	for property in entity.childNodes:  # assume all children are property nodes
		if property.getAttribute('name') == 'origin':
			o = utils.getPoint(property.getAttribute('value')) + offset
			property.setAttribute('value', str(o))
	# Clone node (inc properties) and add to map...
	doc.documentElement.appendChild(entity.cloneNode(True))


# FIXME DRY
def main(xml_in):
	utils.set_stage(2)
	global s  # FIXME remove?
	s = utils.StyleFetcher()
	try:
		m = xml.dom.minidom.parseString(xml_in)
	except:  # noqa: E722
		utils.failParse()
	utils.remove_whitespace_nodes(m)
	processMap(m)
	m.getElementsByTagName('map')[0] \
		.setAttribute('stackdesc', prog.stackdescs[2])
	m.getElementsByTagName('map')[0].setAttribute('generator', __file__)
	return m.toprettyxml()
