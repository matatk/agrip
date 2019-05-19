#!/usr/bin/env python
"""
	04-d-buildermac.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2008 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.
"""

import sys, ldl
from plane import Point
from xml import sax
from xml.sax.saxutils import XMLGenerator
from xml.sax.saxutils import XMLFilterBase

class BuilderFilter(XMLFilterBase):
	"""
	SAX filter to FIXME
	"""

	def __init__(self, upstream, downstream):
		XMLFilterBase.__init__(self, upstream)
		self._downstream = downstream
		self._accumulator = []
		#self.padding_level = -1  # for pretty debug printing
		self.current_element = None  # what element are we inside?
		self.passthrough = False  # allow current element through the filter?
		# Placeholders for the attributes for the builder and shape elements...
		self.builder_info = None
		self.shape_info = None

	def dispatch_macro(self, bi, si):
		'''Call the appropriate Macro'''
		type = si['type']
		if type == ldl.ST_STAIRS:
			self.macro_stairs(bi, si)
		elif type == ldl.ST_PLAT:
			self.macro_plat(bi, si)
		else:
			ldl.error('unkown macro type ' + type)

	def macro_plat(self, bi, si):
		'''Make a plat
		Note that we don't specify the size of plat here as later we need to make it either at the top or the bottom of the larger brush.'''
		origin = ldl.getPoint(bi['origin'])
		size = ldl.getPoint(bi['extent'])
		if bi.has_key('texture'):
			texture = 'texture=\'' + bi['texture'] + '\' '
		else:
			texture = ''
		if si.has_key('position'):
			pos = si['position']  # DCP_UP or DCP_DOWN (top or bottomw
		else:
			ldl.error('plat given without a position (up or down)')
		print "<solid origin='" + str(origin) + "' extent='" + str(size) + "' " + texture + "type='plat' position='" + pos + "' />"

	def macro_stairs(self, bi, si):
		'''Make some stairs
		we see this as a 2D problem then add the missing dimension later (width/depth)
		dir tells us in which dir the steps go up
		length is the distance from start of lowest to end of heighest step
		height is the height of the highest step'''
		# FIXME cope with being able to make a hole through (under) the stairs
		origin = ldl.getPoint(bi['origin'])
		size = ldl.getPoint(bi['extent'])
		dir = si['dir']
		texture = ''
		if bi.has_key('texture'): texture = bi['texture']
		#slength = float(si['steplength'])
		slength = 0
		sheight = float(si['stepheight'])
		parts = []
		parts3d = []

		# FIXME repeated code: n/e == s/w -- collapse into 2?

		# Work out which dimension is which
		if dir == ldl.DCP_NORTH:
			# use X and Y; Z rising with increasing Y
			length = size.y
			height = size.z
			width = size.x
			flip = False
			parts = self._macro_stairs_core(length, height, width, flip, slength, sheight, texture)
			for part in parts:
				part3d = ldl.Region3D(
					Point(0,part.origin.x,part.origin.y) + origin,
					Point(width, part.extent.x, part.extent.y)
				)
				parts3d.append(part3d)
		elif dir == ldl.DCP_SOUTH:
			# use X and Y; Z falling with increasing Y
			length = size.y
			height = size.z
			width = size.x
			flip = True
			parts = self._macro_stairs_core(length, height, width, flip, slength, sheight, texture)
			for part in parts:
				part3d = ldl.Region3D(
					Point(0,part.origin.x,part.origin.y) + origin,
					Point(width, part.extent.x, part.extent.y)
				)
				parts3d.append(part3d)
		elif dir == ldl.DCP_EAST:
			# use X and Y; Z rising with increasing X
			length = size.x
			height = size.z
			width = size.y
			flip = False
			parts = self._macro_stairs_core(length, height, width, flip, slength, sheight, texture)
			for part in parts:
				part3d = ldl.Region3D(
					Point(part.origin.x, 0, part.origin.y) + origin,
					Point(part.extent.x, width, part.extent.y)
				)
				parts3d.append(part3d)
		elif dir == ldl.DCP_WEST:
			# use X and y; Z falling with increasing X
			length = size.x
			height = size.z
			width = size.y
			flip = True
			parts = self._macro_stairs_core(length, height, width, flip, slength, sheight, texture)
			for part in parts:
				part3d = ldl.Region3D(
					Point(part.origin.x, 0, part.origin.y) + origin,
					Point(part.extent.x, width, part.extent.y)
				)
				parts3d.append(part3d)
		else:
			ldl.error('invalid direction specified for stairs (up and down are currently unsupported)')

		for part3d in parts3d:
			#ldl.uprint(str(part3d))
			print "<solid origin='" + str(part3d.origin) + "' extent='" + str(part3d.extent) + "' texture='" + texture + "' type='step' />"

	def _macro_stairs_core(self, full_length, full_height, full_depth, flip, step_length, step_height, t):
		'''Create stairs by iteration.'''
		parts = []
		#ldl.uprint('create steps:\n\tstaircase length: ' + str(full_length) + '\n\tstaircase height: ' + str(full_height) + '\n\tstaircase depth: ' + str(full_depth) + '\n\tflip: ' + str(flip) + '\n\tstep length: ' + str(step_length) + '\n\tstep height: ' + str(step_height) + '\n\ttexture: ' + t)
		# Find closest match for step length and height...
		step_height = self._macro_stairs_match(full_height, step_height)
		num_steps = full_height/step_height
		step_length = full_length/num_steps
		#ldl.uprint('\tnum_steps: ' + str(num_steps) + '\n\tstep_length: ' + str(step_length) + '\n\tstep_height: ' + str(step_height))
		# Create parts...
		length_iter = int(full_length/step_length)
		if flip:
			for i in range(length_iter):
				parts.append(
					ldl.Region3D(
						ldl.Point2D(step_length*i,0),
						ldl.Point2D( step_length,step_height*(length_iter-i) )
					)
				)
		else:
			for i in range(length_iter):
				parts.append(
					ldl.Region3D(
						ldl.Point2D(step_length*i,0),
						ldl.Point2D( step_length,step_height*(i+1) )
					)
				)
		return parts

	def _macro_stairs_match(self, full, individual):
		'''Take in the dimension of the whole staircase and that of an individual step;
		check that they divide w/o a remainder (i.e. the steps of length/height x fit an integer numer of times)
		If they don't, find another value for the dimension of the individual step that allows a whole number of steps to fit in.
		We allow a tollerance of 0.01.'''
		tolerance = 0.01
		difference = 1  # start high to get the loop going
		decrement = 0.01
		lower_bound = individual / 2  # abort if it reduces to this value

		if full/individual != int(full/individual):
			while individual > lower_bound and difference > tolerance:
				individual = individual - decrement
				difference = abs(full/individual - int(full/individual))
			if individual > lower_bound:
				return individual
			else:
				ldl.error('couldn\'t find a suitable step dimension')
		else:
			return individual

	def _complete_text_node(self):
		if self._accumulator:
			self._downstream.characters(''.join(self._accumulator))
			self._accumulator = []

	def startElement(self, name, attrs):
		'''FIXME'''
		#self.padding_level = self.padding_level + 1
		#self.current_element = name
		#self.padded_print(self.current_element)
		self.got_all_info = False  # set True when we have all required info for builder
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
			ldl.error('unknown element type' + name)

		if self.passthrough:
			self._downstream.startElement(name, attrs)
		else:
			if self.got_all_info:
				self.dispatch_macro(self.builder_info, self.shape_info)
				self.got_all_info = False
				self.builder_info = None
				self.shape_info = None
			else:
				pass  # wait for more info

	def startElementNS(self, name, qname, attrs):
		self._complete_text_node()
		self._downstream.startElementNS(name, qname, attrs)

	def endElement(self, name):
		self._complete_text_node()
		# Builder element ends should be ignored as their beginnings are too.
		if name != 'builder' and name != 'shape':
			self._downstream.endElement(name)
		else:
			pass
		#self.padding_level = self.padding_level - 1

	def endElementNS(self, name, qname):
		self._complete_text_node()
		self._downstream.endElementNS(name, qname)

	def processingInstruction(self, target, body):
		self._complete_text_node()
		self._downstream.processingInstruction(target, body)

	def comment(self, body):
		self._complete_text_node()
		self._downstream.comment(body)

	def characters(self, text):
		self._accumulator.append(text)

	def ignorableWhitespace(self, ws):
		self._accumulator.append(text)

	# Utility Functions...

	def padded_print(self, msg):
		for i in range(self.padding_level):
			ldl.uprint('  ', sameLine=True)
		ldl.uprint(msg)

if __name__ == "__main__":
	ldl.stage = '04'
	ldl.uprint('\n === ' + ldl.stackdescs['04'] + ' ===')
	parser = sax.make_parser()
	#XMLGenerator is a special SAX handler that merely writes
	#SAX events back into an XML document
	downstream_handler = XMLGenerator()
	#upstream, the parser, downstream, the next handler in the chain
	filter_handler = BuilderFilter(parser, downstream_handler)
	#The SAX filter base is designed so that the filter takes
	#on much of the interface of the parser itself, including the
	#"parse" method
	try:
		filter_handler.parse(sys.stdin)
	except sax.SAXParseException, detail:
		ldl.error('The XML you supplied is not valid: ' + str(detail))
	except:
		raise
		ldl.failParse()
