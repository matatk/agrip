"""
	ldl.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2008 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.

	This file contains the common code across all stack stages.
"""

import sys
import xml.dom.minidom
import split
import pprint
from plane import Point
from conf import *


#
# Construction Code
#

# FIXME this flips the up and down (and others?) walls when the room starts < 0
# z-wise
# FIXME make the walls extend vertically if top/bottom missing.
# FIXME make specificaton of texture over style possible
def makeHollow(doc, worldspawn, sf, origin, extent, absentwalls, holes, style):
	'''Makes a hollow object (room/corridor) with the given paramaters.

	Works out the brushes, textures.

	Returns the origin and extent of the inner area.

	The north and south walls cover the entire width of the hollow.  The east
	and west ones fit inbetween the north and south ones.  However...

	To avoid leaks, when some walls are absent, the others must be made longer
	to cover the possible holes.  For example, if there is no north wall, the
	east and west ones need to be ldl.lip units longer in case them not being
	so would cause a leak.'''
	inner_origin = origin + lip
	inner_abslut_extent = (origin + extent) - lip

	# down (floor)
	if not DCP_DOWN in absentwalls:
		brush_start = origin
		brush_extent = Point(extent.x, extent.y, lip)
	parts = split.splitWall(
		Region2D(
			Point2D(brush_start.x, brush_start.y),
			Point2D(brush_extent.x, brush_extent.y)
		),
		getHoles(holes, DCP_DOWN))
	for part in parts:
		part3d = addDim(part, DIM_Z, brush_start.z)
		#uprint('Part:   ' + str(part) + '\nPart3D: ' + str(part3d))
		makeBrush(doc, worldspawn, sf, style, part3d, DCP_DOWN)
	# up (ceiling)
	if not DCP_UP in absentwalls:
		brush_start = origin + Point(0, 0, extent.z - lip)
		brush_extent = Point(extent.x, extent.y, lip)
	parts = split.splitWall(
		Region2D(
			Point2D(brush_start.x, brush_start.y),
			Point2D(brush_extent.x, brush_extent.y)
		),
		getHoles(holes, DCP_UP))
	for part in parts:
		part3d = addDim(part, DIM_Z, brush_start.z)
		#uprint('Part:   ' + str(part) + '\nPart3D: ' + str(part3d))
		makeBrush(doc, worldspawn, sf, style, part3d, DCP_UP)
	# north wall; y represents depth
	if not DCP_NORTH in absentwalls:
		brush_start = origin + Point(0, extent.y - lip, lip)
		brush_extent = Point(extent.x, lip, extent.z - lip*2)
		wall_holes = getHoles(holes, DCP_NORTH)
		parts = split.splitWall(
			Region2D(
				Point2D(brush_start.x, brush_start.z),
				Point2D(brush_extent.x, brush_extent.z)
			),
			getHoles(holes, DCP_NORTH))
		for part in parts:
			part3d = addDim(part, DIM_Y, brush_start.y)
			#uprint('Part:   ' + str(part) + '\nPart3D: ' + str(part3d))
			makeBrush(doc, worldspawn, sf, style, part3d, DCP_NORTH)
	# south wall
	# FIXME holes need to be expressed the other way 'round (i.e. 0 is at RHS not LHS)?
	if not DCP_SOUTH in absentwalls:
		brush_start = origin + Point(0, 0, lip)
		brush_extent = Point(extent.x, lip, extent.z - lip*2)
		wall_holes = getHoles(holes, DCP_SOUTH)
		parts = split.splitWall(
			Region2D(
				Point2D(brush_start.x, brush_start.z),
				Point2D(brush_extent.x, brush_extent.z)
			),
			getHoles(holes, DCP_SOUTH))
		for part in parts:
			part3d = addDim(part, DIM_Y, brush_start.y)
			#uprint('Part:   ' + str(part) + '\nPart3D: ' + str(part3d))
			makeBrush(doc, worldspawn, sf, style, part3d, DCP_SOUTH)
	# west wall
	if not DCP_WEST in absentwalls:
		if DCP_NORTH not in absentwalls and DCP_SOUTH not in absentwalls:
			brush_start = origin + Point(0, lip, lip)
			brush_extent = Point(lip, extent.y - lip*2, extent.z - lip*2)
		elif DCP_NORTH in absentwalls and DCP_SOUTH in absentwalls:
			brush_start = origin + Point(0, lip, lip)
			brush_extent = Point(lip, extent.y - lip*2, extent.z - lip*2)
		elif DCP_NORTH in absentwalls:
			brush_start = origin + Point(0, lip, lip)
			brush_extent = Point(lip, extent.y - lip, extent.z - lip*2)
		elif DCP_SOUTH in absentwalls:
			brush_start = origin + Point(0, 0, lip)
			brush_extent = Point(lip, extent.y - lip, extent.z - lip*2)
		else:
			error('absentwalls')
		wall_holes = getHoles(holes, DCP_WEST)
		parts = split.splitWall(
			Region2D(
				Point2D(brush_start.y, brush_start.z),
				Point2D(brush_extent.y, brush_extent.z)
			),
			getHoles(holes, DCP_WEST))
		for part in parts:
			part3d = addDim(part, DIM_X, brush_start.x)
			#uprint('Part:   ' + str(part) + '\nPart3D: ' + str(part3d))
			makeBrush(doc, worldspawn, sf, style, part3d, DCP_WEST)
	# east wall
	if not DCP_EAST in absentwalls:
		if DCP_NORTH not in absentwalls and DCP_SOUTH not in absentwalls:
			brush_start = origin + Point(extent.x - lip, lip, lip)
			brush_extent = Point(lip, extent.y - lip*2, extent.z - lip*2)
		elif DCP_NORTH in absentwalls and DCP_SOUTH in absentwalls:
			brush_start = origin + Point(extent.x - lip, 0, lip)
			brush_extent = Point(lip, extent.y, extent.z - lip*2)
		elif DCP_NORTH in absentwalls:
			brush_start = origin + Point(extent.x - lip, lip, lip)
			brush_extent = Point(lip, extent.y - lip, extent.z - lip*2)
		elif DCP_SOUTH in absentwalls:
			brush_start = origin + Point(extent.x - lip, 0, lip)
			brush_extent = Point(lip, extent.y - lip, extent.z - lip*2)
		else:
			error('absentwalls')
		parts = split.splitWall(
			Region2D(
				Point2D(brush_start.y, brush_start.z),
				Point2D(brush_extent.y, brush_extent.z)
			),
			getHoles(holes, DCP_EAST))
		for part in parts:
			part3d = addDim(part, DIM_X, brush_start.x)
			#uprint('Part:   ' + str(part) + '\nPart3D: ' + str(part3d))
			makeBrush(doc, worldspawn, sf, style, part3d, DCP_EAST)
	# Return inner extents...
	return inner_origin, inner_abslut_extent


#
# Style Code
#

class StyleFetcher:

	'''Lighting Style Set Stuff'''

	def getLightingStyleId(self, stylename, size):
		# FIXME assumes 2 ids -- one with and one w/o size
		sizes = []
		largest = None
		if stylename in self.lightingSets:
			# FIXME do a proper sort!
			not_sorted_list = []
			for key in list(self.lightingSets[stylename].keys()):
				not_sorted_list.insert(0, key)

			for lighting in not_sorted_list:
				maxs = self.lightingSets[stylename][lighting]['maxs']
				if not maxs:
					maxs = Point(0, 0, 0)
					largest = lighting
				else:
					maxs = getPoint(maxs)

				#uprint('getLightingStyle: size: ' + str(size) + '; maxs: ' + str(maxs) + '; ', True)
				if size.x <= maxs.x or size.y <= maxs.y:
					#uprint('return ' + lighting)
					return lighting
				else:
					#uprint('try next...')
					pass
			# if nothing returned here, use the largest one
			#uprint('return largest')
			return largest
		else:
			error('StyleFetcher: unkown lighting set name \'' + stylename + '\'.')

	def getLightingStyleType(self, style, id):
		'''Find out if a lighting substyle is of type perimeter or grid'''
		return self.lightingSets[style][id]['type']

	def _getLightingSetSimpleProp(self, style, id, style_type, prop_type, prop):
		'''Get a property such as entity, light level or sound.
		We search for properties specific to the type of our lighting sub-scheme (perimeter/grid).
		If we can't find a specific value, we use the default one (which applies to all types).'''
		#uprint('_getLightingSetSimpleProp():\n\tstyle: ' + style + '; id: ' + id + '; style_type: ' + style_type + '; prop_type: ' + prop_type + '; prop: ' + prop + '.')
		if style in self.lightingSets:
			if id in self.lightingSets[style]:
				if prop in self.lightingSets[style][id]:
					if style_type in self.lightingSets[style][id][prop]:
						# Only return the specific (perimeter/grid) value if it's there;
						# fall back to using the default.
						if self.lightingSets[style][id][prop][style_type]:
							val = self.lightingSets[style][id][prop][style_type]
						else:
							if self.lightingSets[style][id][prop]['default']:
								val = self.lightingSets[style][id][prop]['default']
							else:
								return None
						# Got value; work out type to return...
						if prop_type == PT_TEXT:
							return val
						elif prop_type == PT_INT:
							return int(val)
						else:
							error('StyleFetcher: unknown property prop_type ' + prop_type)
					else:
						error('unkown style type ' + style_type + ' or style ' + style + '/' + id + '/' + prop + ' does not contain information on this style type.')
				else:
					error('lighting style ' + style + ' subscheme ' + id + ' has no property ' + prop)
			else:
				error('lighting style ' + style + ' doesn\'t have substyle with id ' + id)
		else:
			error('unknown lighting style ' + style)

	def getLightingSetEntity(self, style, id, type):
		return self._getLightingSetSimpleProp(style, id, type, PT_TEXT, 'entities')

	def getLightingSetLevel(self, style, id, type):
		return self._getLightingSetSimpleProp(style, id, type, PT_INT, 'levels')

	def getLightingSetSound(self, style, id, type):
		return self._getLightingSetSimpleProp(style, id, type, PT_TEXT, 'sounds')

	def _getLightingSetComplexProp(self, style, id, type, prop, dim):
		'''Get a property from a deeply nested hash like offsets or min gaps in each dimension.
		We search for properties specific to the type of our lighting sub-scheme (perimeter/grid).
		If we can't find a specific value, we use the default one (which applies to all types).'''
		if style in self.lightingSets:
			if id in self.lightingSets[style]:
				if prop in self.lightingSets[style][id]:
					if type in self.lightingSets[style][id][prop] \
					and dim in self.lightingSets[style][id][prop][type]:
						# Has a property for this type of lighting sub-scheme...
						return int(self.lightingSets[style][id][prop][type][dim])
					else:
						# Use default, or just 0 if no value specified at all...
						if dim in self.lightingSets[style][id][prop]:
							return int(self.lightingSets[style][id][prop][dim])
						else:
							return 0
				else:
					error('unknown lighting style property ' + prop)
			else:
				error('lighting style ' + style + ' doesn\'t have substyle with id ' + id)
		else:
			error('unknown lighting style ' + style)

	def getLightingSetMindist(self, style, id, type, dim):
		return self._getLightingSetComplexProp(style, id, type, 'mins', dim)

	def getLightingSetOffset(self, style, id, type, dim):
		return self._getLightingSetComplexProp(style, id, type, 'offsets', dim)

	def getLightingSetType(self, style):
		if style in self.lightingSets:
			if 'type' in self.lightingSets[style]:
				type = self.lightingSets[style]['type']
				if type == LS_CENTRE or type == LS_PERIMETER:
					return type
				else:
					error('invalid type \'' + type + '\'specified for lighting style \'' + style + '\'')
			else:
				error('no type (grid, perimeter, ...) specified for lighting style ' + style)
		else:
			error('no such lighting style \'' + style + '\'')

	'''Texture Table and Texture Set Stuff'''

	def getWorldtypeName(self, style):
		if style in self.worldtypeTable:
			return self.worldtypeTable[style]
		else:
			error('getWorldtype: Trying to find worldtype for a nonexistant style \'' + str(style) + '\'.  Please make sure that the style name is correct.')

	'''Texture Table and Texture Set Stuff'''

	def getTex(self, tex):
		if tex in self.textureTable:
			return self.textureTable[tex]
		else:
			return False

	def getSetTex(self, style, surf):
		if style in self.textureSets:
			return self.textureTable[self.textureSets[style][surf]]
		else:
			error('getSetTex: no such texture style set \'' + style + '\'.')

	def __init__(self):
		self.worldtypeTable = {};  # translates style names to their worldtype names
		self.textureTable = {};  # translates easy texture names to actual texture names
		self.textureSets = {};  # a set of textures to be applied to a hollow
		self.lightingSets = {};  # as above but with lighting
		tempTexSet = {};  # we build up the texture set hash in here
		tLS = {};  # as above but with lighting
		s = xml.dom.minidom.parse(STYLE_FILE)
		# Get worldtypes...
		for worldtype in s.getElementsByTagName('worldtype'):
			self.worldtypeTable[worldtype.getAttribute('style')] = worldtype.getAttribute('value')
		# Get textures...
		for texture in s.getElementsByTagName('texture'):
			self.textureTable[texture.getAttribute('name')] = texture.getAttribute('value')
		# Get texturesets...
		for textureset in s.getElementsByTagName('textureset'):
			for surface in textureset.getElementsByTagName('surface'):
				# FIXME check that each surface id is valid.
				tempTexSet[surface.getAttribute('id')] = surface.getAttribute('texture')
			self.textureSets[textureset.getAttribute('name')] = tempTexSet
			tempTexSet = {};
		# Get lighting styles...
		for lightingset in s.getElementsByTagName('lightingset'):
			# Within each lighting set is a lighting element that contains the rest...
			ls_name = lightingset.getAttribute('name')
			tLS[ls_name] = {}
			# Now populate this lighting set's child schemes...
			for lighting in lightingset.childNodes:
				# Check it's a lighting element, not whitespace.
				# NB: if we don't do this an error will be triggered.
				if lighting.localName == 'lighting':
					# Each lighting element is a lighting scheme for rooms upto a particular size...
					l_id = lighting.getAttribute('id')
					tLS[ls_name][l_id] = {}
					tLS[ls_name][l_id]['maxs'] = lighting.getAttribute('maxs')
					tLS[ls_name][l_id]['type'] = lighting.getAttribute('type')

					# Offsets is a child hash that stores light offsets into the hollow...
					tLS[ls_name][l_id]['offsets'] = {}
					# offsets contains default values, but if we find values specific to the perimeter, or specific to the centre lights, we have to store those too...
					tLS[ls_name][l_id]['offsets']['perimeter'] = {}
					tLS[ls_name][l_id]['offsets']['centre'] = {}

					# mins is a child hash that stores the minimum distance between lights...
					tLS[ls_name][l_id]['mins'] = {}
					# mins contains default values, but if we find values specific to the perimeter, or specific to the centre lights, we have to store those too...
					tLS[ls_name][l_id]['mins']['perimeter'] = {}
					tLS[ls_name][l_id]['mins']['centre'] = {}

					# entities is a child hash that stores the minimum distance between lights...
					tLS[ls_name][l_id]['entities'] = {}
					# entities contains default values, but if we find values specific to the perimeter, or specific to the centre lights, we have to store those too...
					tLS[ls_name][l_id]['entities']['perimeter'] = {}
					tLS[ls_name][l_id]['entities']['centre'] = {}
					tLS[ls_name][l_id]['entities']['default'] = None

					# sounds is a child hash that stores the minimum distance between lights...
					tLS[ls_name][l_id]['sounds'] = {}
					# sounds contains default values, but if we find values specific to the perimeter, or specific to the centre lights, we have to store those too...
					tLS[ls_name][l_id]['sounds']['perimeter'] = {}
					tLS[ls_name][l_id]['sounds']['centre'] = {}
					tLS[ls_name][l_id]['sounds']['default'] = None

					# levels is a child hash that stores light levels into the hollow...
					tLS[ls_name][l_id]['levels'] = {}
					# levels contains default values, but if we find values specific to the perimeter, or specific to the centre lights, we have to store those too...
					tLS[ls_name][l_id]['levels']['perimeter'] = {}
					tLS[ls_name][l_id]['levels']['centre'] = {}
					tLS[ls_name][l_id]['levels']['default'] = None

					# Now we can look inside this lighting scheme to see what the jicy bits are...
					for lc in lighting.childNodes:
						lc_name = lc.localName
						if lc_name:
							lc_type = lc.getAttribute('type')
							if lc_name == 'offset':
								if lc_type == LS_PERIMETER:
									tLS[ls_name][l_id]['offsets'][LS_PERIMETER][lc.getAttribute('dim')] = lc.getAttribute('value')
								elif lc_type == LS_CENTRE:
									tLS[ls_name][l_id]['offsets'][LS_CENTRE][lc.getAttribute('dim')] = lc.getAttribute('value')
								elif lc_type == LS_DEF:
									tLS[ls_name][l_id]['offsets'][lc.getAttribute('dim')] = lc.getAttribute('value')
								else:
									error('unknown offset type ' + lc_type + ' specified for lighting scheme ' + l_id)
							if lc_name == 'min':
								if lc_type == LS_PERIMETER:
									tLS[ls_name][l_id]['mins'][LS_PERIMETER][lc.getAttribute('dim')] = lc.getAttribute('value')
								elif lc_type == LS_CENTRE:
									tLS[ls_name][l_id]['mins'][LS_CENTRE][lc.getAttribute('dim')] = lc.getAttribute('value')
								elif lc_type == LS_DEF:
									tLS[ls_name][l_id]['mins'][lc.getAttribute('dim')] = lc.getAttribute('value')
								else:
									error('unknown min type ' + lc_type + ' specified for lighting scheme ' + l_id)
							elif lc_name == 'level':
								if lc_type == LS_PERIMETER:
									tLS[ls_name][l_id]['levels'][LS_PERIMETER] = lc.getAttribute('value')
								elif lc_type == LS_CENTRE:
									tLS[ls_name][l_id]['levels'][LS_CENTRE] = lc.getAttribute('value')
								elif lc_type == LS_DEF:
									tLS[ls_name][l_id]['levels']['default'] = lc.getAttribute('value')
								else:
									error('unknown light level type ' + lc_type + ' specified for lighting scheme ' + l_id)
							elif lc_name == 'entity':
								if lc_type == LS_PERIMETER:
									tLS[ls_name][l_id]['entities'][LS_PERIMETER] = lc.getAttribute('value')
								elif lc_type == LS_CENTRE:
									tLS[ls_name][l_id]['entities'][LS_CENTRE] = lc.getAttribute('value')
								elif lc_type == LS_DEF:
									tLS[ls_name][l_id]['entities']['default'] = lc.getAttribute('value')
								else:
									error('unknown light level type ' + lc_type + ' specified for lighting scheme ' + l_id)
							elif lc_name == 'sound':
								if lc_type == LS_PERIMETER:
									tLS[ls_name][l_id]['sounds'][LS_PERIMETER] = lc.getAttribute('value')
								elif lc_type == LS_CENTRE:
									tLS[ls_name][l_id]['sounds'][LS_CENTRE] = lc.getAttribute('value')
								elif lc_type == LS_DEF:
									tLS[ls_name][l_id]['sounds']['default'] = lc.getAttribute('value')
								else:
									error('unknown sound type ' + lc_type + ' specified for lighting scheme ' + l_id)
						else:
							pass  # probably whitespace
			else:
				pass  # probably whitespace
		# Reset the hashes back to defaults...
		self.lightingSets = tLS
		tLS = {}

	def __str__(self):
		pp = pprint.PrettyPrinter()
		out = 'TEXTURE TABLE:\n' + pp.pformat(self.textureTable) + '\n'
		out = out + '\nTEXTURE SETS:\n' + pp.pformat(self.textureSets) + '\n'
		out = out + '\nLIGHTING SETS:\n' + pp.pformat(self.lightingSets)
		return out

#
# Utility Code
#

def check_entity_name(name):
	'''See if the given entity name is valid.'''
	if name in valid_entities:
		return True
	else:
		error('The given entity name \'' + name + '\' is not a valid one.  The list of valid entities is as follows.\n\t' + '\n\t'.join([n for n in valid_entities]))

def addDim(region, dim, d, e=None):
	'''Convert a Region2D into a Region3D by adding an extra dminsion, that was taken away by the splitting algorithm.
	e is only passed when making holes in solids as we need to know the depth then.'''
	o = 0  # offset: used for insetting doors
	if not e: e = lip
	if region.type == RT_DOOR:
		o = lip_small_margin
		e = lip_small
	if dim == DIM_X:
		return Region3D(
				Point(d+o, region.origin.x, region.origin.y),
				Point(e, region.extent.x, region.extent.y),
				region.type,
				region.props)
	elif dim == DIM_Y:
		return Region3D(
				Point(region.origin.x, d+o, region.origin.y),
				Point(region.extent.x, e, region.extent.y),
				region.type,
				region.props)
	elif dim == DIM_Z:
		return Region3D(
				Point(region.origin.x, region.origin.y, d+o),
				Point(region.extent.x, region.extent.y, e),
				region.type,
				region.props)
	else:
		error('Invalid dimension specified for addDim().')

class Point2D:
	def __init__(self, x, y):
		self.x = x
		self.y = y
	def __str__(self):
		return str(self.x) + ' ' + str(self.y)
	def __add__(self, other):
		return Point2D(self.x + other.x, self.y + other.y)
	def __sub__(self, other):
		return Point2D(self.x - other.x, self.y - other.y)
	def divide_coords_by(self, factor):
		return Point2D(self.x/factor, self.y/factor)

def checkType(rtype):
	result = False
	if not rtype:
		result = True
	elif	rtype == RT_DOOR \
		 or rtype == RT_PLAT \
		 or rtype == RT_STEP:
		result = True

	if not result:
		error('Unknown region type \'' + str(rtype) + '\'')
	else:
		return True

class Region3D:
	'''A 3D region.
	This is used by the wall-spliting functions to return the final chunks to be put into the map.'''
	def __init__(self, origin, extent, rtype=None, props=None):
		if type(origin) != type(Point(0, 0, 0)):
			if type(origin) == type(Point2D(0, 0)):
				origin = Point(origin.x, origin.y, 0)  # FIXME fix callers :-)
			else:
				raise TypeError('origin is not a 3D Point')
		if type(extent) != type(Point(0, 0, 0)):
			if type(extent) == type(Point2D(0, 0)):
				extent = Point(extent.x, extent.y, 0)  # FIXME fix callers :-)
			else:
				raise TypeError('extent is not a 3D Point')
		self.origin = origin
		self.extent = extent
		self.end = self.origin + self.extent
		checkType(rtype)
		self.type = rtype
		self.props = props

	def __str__(self):
		return 'at: ' + str(self.origin) + ' extent: ' + str(self.extent) + ' type: ' + str(self.type)

class Region2D:
	'''A 2D region in a wall that is to be split.
	This could correspond to a door, in which case when it's ``rebuilt'' into 3D it will be created as such.'''
	def __init__(self, origin, extent, rtype=None, props=None):
		if type(origin) != type(Point2D(0, 0)) \
		or type(extent) != type(Point2D(0, 0)) \
		or type(rtype) == type(Point2D(0, 0)):
			raise TypeError
		self.origin = origin
		self.extent = extent
		self.end = self.origin + self.extent
		checkType(rtype)
		self.type = rtype
		self.props = props

	def __str__(self):
		return 'at: ' + str(self.origin) + ' extent: ' + str(self.extent) + ' type: ' + str(self.type)

class Chunk2D(Region2D): pass

class Hole2D(Region2D): pass

def getHoles(dict, wall):
	'''Holes are stored in a dictionary where the keys are the names of the walls (DCP_ values).  There can be multiple holes per wall.  This funtion extracts and returns them as a list of Hole objects (which themselves contain Point2D objects).'''
	holes_list = []
	if wall in dict:
		return dict[wall]
	else:
		return False

def warning(data):
	sys.stderr.write('Stage ' + stage + ' WARNING! ' + data + '\n')

def error(data):
	sys.stderr.write('Stage ' + stage + ' ERROR! ' + data + '\n')
	sys.exit(42)

def failParse(data=None):
	if data:
		sys.stderr.write('Stage: ' + stage + ' FAILURE! ' + data + '\n')
	else:
		sys.stderr.write('Processing stage ' + stage + ': there was an error in the input given to this stage of processing -- perhaps the previous stage didn\'t work?\n')
	sys.exit(42)

def makeBrush(doc, worldspawn, sf, style, part, dir, texture=None):
	# FIXME split into two versions -- onef for dir / style and one for just plain text?
	'''Make a brush
	optional texture name used to force a particular texture (e.g. when making a solid)
	note that we have to append brush last for QuArK to able to read the .map file.'''
	mode_style = True
	if sf.getTex(texture):
		mode_style = False

	# React to step brushes as normal ones by simply adding them as static brushes; react to other, more complex types differently...
	if not part.type or part.type == RT_STEP:  # assume just regular solid brush...
		if mode_style:
			t = sf.getSetTex(style,dir)
			if t:
				worldspawn.appendChild(createSolid(doc, part.origin, part.extent, t))
			else:
				error('something')
		else:
			worldspawn.appendChild(createSolid(doc, part.origin, part.extent, sf.getTex(texture)))
	elif part.type == RT_DOOR:
		# need to append to map, not worldspawn
		map = doc.getElementsByTagName('map')[0]
		door_ent = doc.createElement('entity')
		door_ent.appendChild(createProperty(doc, 'classname', 'func_door'))
		door_ent.appendChild(createProperty(doc, 'angle', '-1'))
		door_ent.appendChild(createProperty(doc, 'speed', '400'))
		door_ent.appendChild(createProperty(doc, 'sounds', soundtypes_door[sf.getWorldtypeName(style)]))
		if part.props[PROPS_K_KEY]:
			door_ent.appendChild(createProperty(doc, 'spawnflags', key_access[part.props[PROPS_K_KEY]]))
		# Ignore specified texture for doors; use style one...
		door_ent.appendChild(createSolid(doc, part.origin, part.extent, sf.getSetTex(style, RT_DOOR)))
		map.appendChild(door_ent)
	elif part.type == RT_PLAT:
		# need to append to map, not worldspawn
		map = doc.getElementsByTagName('map')[0]
		plat_ent = doc.createElement('entity')
		plat_ent.appendChild(createProperty(doc, 'classname', 'func_plat'))
		plat_ent.appendChild(createProperty(doc, 'sounds', soundtypes_plat[sf.getWorldtypeName(style)]))
		if part.props[PROPS_K_POS] == DCP_DOWN:
			height = part.extent.z - lip
			part.origin.z = part.origin.z + part.extent.z - lip
			part.extent.z = lip
		elif part.props[PROPS_K_POS] == DCP_UP:
			error('up plats not imlemented yet')
		else:
			error('Platform only allowed to have position ' + DCP_UP + ' or ' + DCP_DOWN + '.')
		plat_ent.appendChild(createProperty(doc, 'height', str(height)))
		# Ignore specified texture for plats; use style one...
		plat_ent.appendChild(createSolid(doc, part.origin, part.extent, sf.getSetTex(style, RT_PLAT)))
		map.appendChild(plat_ent)
	else:
		error('Unknown brush type \'' + str(part.type) + '\' specified for brush ' + str(part) + '.')

def createSolid(doc, o, e, t):
	b = doc.createElement('brush')
	b.setAttribute('origin',str(o))
	b.setAttribute('extent',str(e))
	b.setAttribute('texture',t + ' 0 0 0 1 1')  # FIXME this will be the offset induced when the level is moved such that the origin is no longer 0 0 0.
	return b

def getPoint(cstr):
	list = cstr.split()
	if len(list) == 3:
		return Point(float(list[0]), float(list[1]), float(list[2]))
	else:
		error('getPoint: received input without 3 parts to make 3D point from -- \'' + str(cstr) + '\'.')

def getPoint2D(cstr):
	list = cstr.split()
	# FIXME some places are calling this and getting away with it
	#if len(list) != 2:
	#	warning('getPoint2D: received input without 2 parts to make 2D point from -- \'' + str(cstr) + '\'.')
	return Point2D(float(list[0]), float(list[1]))

def createProperty(doc, name, value):
	property = doc.createElement('property')
	property.setAttribute('name', name)
	property.setAttribute('value', value)
	return property

def remove_whitespace_nodes(node, unlink=False):
	"""Removes all of the whitespace-only text decendants of a DOM node.

	When creating a DOM from an XML source, XML parsers are required to
	consider several conditions when deciding whether to include
	whitespace-only text nodes. This function ignores all of those
	conditions and removes all whitespace-only text decendants of the
	specified node. If the unlink flag is specified, the removed text
	nodes are unlinked so that their storage can be reclaimed. If the
	specified node is a whitespace-only text node then it is left
	unmodified."""

	remove_list = []
	for child in node.childNodes:
		if child.nodeType == xml.dom.Node.TEXT_NODE and not child.data.strip():
			remove_list.append(child)
		elif child.hasChildNodes():
			remove_whitespace_nodes(child, unlink)
	for node in remove_list:
		node.parentNode.removeChild(node)
		if unlink:
			node.unlink()

def uprint(msg, sameLine=False):
	global debug_printing
	if debug_printing:
		sys.stderr.write(msg)
		if not sameLine: sys.stderr.write('\n')

def getText(nodelist):
	ret = ''
	for node in nodelist:
		if node.nodeType == node.TEXT_NODE:
			ret = ret + node.data
	return ret

def insertPlaceholder(doc, parent, child):
	ph = doc.createComment('placeholder')
	parent.replaceChild(ph, child)
