#!/usr/bin/env python3
"""
	level_04_down_buildermacros.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2008 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.
"""

import sys
import utils
from plane import Point
import xml.sax
from xml.sax.saxutils import XMLGenerator, XMLFilterBase
import io
from conf import (
	connector,
	dcp,
	prog
)


class BuilderFilter(XMLFilterBase):
	"""
	SAX filter to FIXME
	"""

	def __init__(self, parent):
		super().__init__(parent)
		self.current_element = None  # what element are we inside?
		self.passthrough = False  # allow current element through the filter?
		# Placeholders for the attributes for the builder and shape elements...
		self.builder_info = None
		self.shape_info = None

	def dispatch_macro(self, bi, si):
		'''Call the appropriate Macro'''
		type = si['type']
		if type == connector.STAIRS:
			self.macro_stairs(bi, si)
		elif type == connector.PLAT:
			self.macro_plat(bi, si)
		else:
			utils.error('unkown macro type ' + type)

	def macro_plat(self, bi, si):
		'''Make a plat

		Note that we don't specify the size of plat here as
		later we need to make it either at the top or the bottom of the larger
		brush.'''
		origin = utils.getPoint(bi['origin'])
		size = utils.getPoint(bi['extent'])
		if 'texture' in bi:
			texture = 'texture=\'' + bi['texture'] + '\' '
		else:
			texture = ''
		if 'position' in si:
			pos = si['position']  # dcp.UP or dcp.DOWN (top or bottomw
		else:
			utils.error('plat given without a position (up or down)')

		super().startElement('solid', {
			'origin': str(origin),
			'extent': str(size),
			'texture': texture,
			'type': 'plat',
			'position': pos
		})
		super().endElement('solid')

	def macro_stairs(self, bi, si):
		'''Make some stairs

		we see this as a 2D problem then add the missing dimension later
		(width/depth) dir tells us in which dir the steps go up length is the
		distance from start of lowest to end of heighest step height is the
		height of the highest step'''
		# FIXME cope with being able to make a hole through (under) the stairs
		origin = utils.getPoint(bi['origin'])
		size = utils.getPoint(bi['extent'])
		dir = si['dir']
		texture = ''
		if 'texture' in bi:
			texture = bi['texture']
		slength = 0
		sheight = float(si['stepheight'])
		parts = []
		parts3d = []

		# FIXME repeated code: n/e == s/w -- collapse into 2?

		# Work out which dimension is which
		if dir == dcp.NORTH:
			# use X and Y; Z rising with increasing Y
			length = size.y
			height = size.z
			width = size.x
			flip = False
			parts = self._macro_stairs_core(
				length, height, width, flip, slength, sheight, texture)
			for part in parts:
				part3d = utils.Region3D(
					Point(0, part.origin.x, part.origin.y) + origin,
					Point(width, part.extent.x, part.extent.y)
				)
				parts3d.append(part3d)
		elif dir == dcp.SOUTH:
			# use X and Y; Z falling with increasing Y
			length = size.y
			height = size.z
			width = size.x
			flip = True
			parts = self._macro_stairs_core(
				length, height, width, flip, slength, sheight, texture)
			for part in parts:
				part3d = utils.Region3D(
					Point(0, part.origin.x, part.origin.y) + origin,
					Point(width, part.extent.x, part.extent.y)
				)
				parts3d.append(part3d)
		elif dir == dcp.EAST:
			# use X and Y; Z rising with increasing X
			length = size.x
			height = size.z
			width = size.y
			flip = False
			parts = self._macro_stairs_core(
				length, height, width, flip, slength, sheight, texture)
			for part in parts:
				part3d = utils.Region3D(
					Point(part.origin.x, 0, part.origin.y) + origin,
					Point(part.extent.x, width, part.extent.y)
				)
				parts3d.append(part3d)
		elif dir == dcp.WEST:
			# use X and y; Z falling with increasing X
			length = size.x
			height = size.z
			width = size.y
			flip = True
			parts = self._macro_stairs_core(
				length, height, width, flip, slength, sheight, texture)
			for part in parts:
				part3d = utils.Region3D(
					Point(part.origin.x, 0, part.origin.y) + origin,
					Point(part.extent.x, width, part.extent.y)
				)
				parts3d.append(part3d)
		else:
			utils.error(
				'invalid direction specified for stairs (up and down are currently '
				'unsupported)')

		for part3d in parts3d:
			super().startElement('solid', {
				'origin': str(part3d.origin),
				'extent': str(part3d.extent),
				'texture': texture,
				'type': 'step'
			})
			super().endElement('solid')

	def _macro_stairs_core(
		self, full_length, full_height, full_depth, flip, step_length,
		step_height, t):
		'''Create stairs by iteration.'''
		parts = []
		# Find closest match for step length and height...
		step_height = self._macro_stairs_match(full_height, step_height)
		num_steps = full_height / step_height
		step_length = full_length / num_steps
		# Create parts...
		length_iter = int(full_length / step_length)
		if flip:
			for i in range(length_iter):
				parts.append(
					utils.Region3D(
						utils.Point2D(step_length * i, 0),
						utils.Point2D(step_length, step_height * (length_iter - i))
					)
				)
		else:
			for i in range(length_iter):
				parts.append(
					utils.Region3D(
						utils.Point2D(step_length * i, 0),
						utils.Point2D(step_length, step_height * (i + 1))
					)
				)
		return parts

	def _macro_stairs_match(self, full, individual):
		'''Take in the dimension of the whole staircase and that of an
		individual step; check that they divide w/o a remainder (i.e. the steps
		of length/height x fit an integer numer of times) If they don't, find
		another value for the dimension of the individual step that allows a
		whole number of steps to fit in.  We allow a tollerance of 0.01.'''
		tolerance = 0.01
		difference = 1  # start high to get the loop going
		decrement = 0.01
		lower_bound = individual / 2  # abort if it reduces to this value

		if full / individual != int(full / individual):
			while individual > lower_bound and difference > tolerance:
				individual = individual - decrement
				difference = abs(full / individual - int(full / individual))
			if individual > lower_bound:
				return individual
			else:
				utils.error('couldn\'t find a suitable step dimension')
		else:
			return individual

	def startElement(self, name, attrs):
		'''FIXME'''
		self.got_all_info = False
		# set True when we have all required info for builder

		# Allow most elements through; builders must be turned into solids.
		if name != 'builder' and name != 'shape':
			self.passthrough = True  # allow these elements through unaltered
		elif name == 'builder':
			self.passthrough = False
			self.builder_info = attrs
		elif name == 'shape':
			self.passthrough = False
			self.shape_info = attrs
			# Now we (hopefully) have builder and shape info...
			self.got_all_info = True
		else:
			utils.error('unknown element type' + name)

		if self.passthrough:
			super().startElement(name, attrs)
		else:
			if self.got_all_info:
				self.dispatch_macro(self.builder_info, self.shape_info)
				self.got_all_info = False
				self.builder_info = None
				self.shape_info = None
			else:
				pass  # wait for more info

	def endElement(self, name):
		# Builder element ends should be ignored as their beginnings are too.
		if name != 'builder' and name != 'shape':
			super().endElement(name)

	# Utility Functions...

	def padded_print(self, msg):
		for i in range(self.padding_level):
			utils.uprint('  ', sameLine=True)
		utils.uprint(msg)


# FIXME DRY
def main(xml_in):
	utils.set_stage(4)
	filtered_reader = BuilderFilter(xml.sax.make_parser())
	xml_out = io.StringIO()
	filtered_reader.setContentHandler(
		XMLGenerator(xml_out, short_empty_elements=True))
	try:
		hacky = io.StringIO(xml_in)
		filtered_reader.parse(hacky)
	except xml.sax.SAXParseException as detail:
		utils.error('The XML you supplied is not valid: ' + str(detail))
	except:  # noqa: E722
		raise
		utils.failParse()
	return xml_out.getvalue()
