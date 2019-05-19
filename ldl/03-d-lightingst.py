#!/usr/bin/env python
"""
	03-d-lightingst.py
	Part of the Level Description Language (LDL) from the AGRIP project. 
	Copyright 2005-2008 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.
"""

import sys, ldl
from plane import Point
from xml import sax
from xml.sax.saxutils import XMLGenerator
from xml.sax.saxutils import XMLFilterBase

class LightingStyleFilter(XMLFilterBase):
	"""
	SAX filter to FIXME
	"""
	
	def __init__(self, upstream, downstream):
		XMLFilterBase.__init__(self, upstream)
		self._downstream = downstream
		self._accumulator = []
		#self.padding_level = -1  # for pretty debug printing
		self.lightStack = []  # for storing the light array for each hollow, so it can be put at the end of the hollow definition as opposed to the start

	def _check_proximity(self, limit, val, tolerance):
		'''is a point close to limit, or zero?'''
		diff = limit - val
		# difference must be either:
		#   within tolerance of limit
		#   within tolerance of 0
		if diff <= tolerance or (limit - diff) <= tolerance:
			return True
		else:
			return False

	def _get_gap(self, smallest, total):
		'''Return a gap size >= smallest that allows an integer number of lights.'''
		found = False
		increment = 1  # for smallest (making it greater until num_lights comes out integer)
		tolerance = 0.05  # difference between the integer and float number of lights
		while not found and smallest < total:
			num_lights = total/smallest
			if abs(num_lights - int(num_lights)) <= tolerance:
				found = True
			else:
				smallest = smallest + increment
		return smallest

	def _make_lights_core(self, style, id, type, bounds):
		'''Make lights in this around the walls only.'''
		lights = []
		xoffs = styleFetcher.getLightingSetOffset(style, id, type, 'x')
		yoffs = styleFetcher.getLightingSetOffset(style, id, type, 'y')
		zoffs = styleFetcher.getLightingSetOffset(style, id, type, 'z')
		xmin = styleFetcher.getLightingSetMindist(style, id, type, 'x')
		ymin = styleFetcher.getLightingSetMindist(style, id, type, 'y')
		zmin = styleFetcher.getLightingSetMindist(style, id, type, 'z')
		entity = styleFetcher.getLightingSetEntity(style, id, type)
		light = styleFetcher.getLightingSetLevel(style, id, type)
		sound = styleFetcher.getLightingSetSound(style, id, type)

		# Lights must go in the corners.
		#	i.e.	xoffs,				yoffs,				zoffs
		#	    	xoffs,				bounds.y - yoffs,	zoffs
		#	    	bounds.x - xoffs,	yoffs,				zoffs
		#			bounds.x - xoffs,	bounds.y - yoffs,	zoffs
		# Work out how many to go inbetween the corners (along walls).
		# That may be repeated vertically according to zstep.
		# Do we have them in middle of room?
	
		xgap = bounds.x# - 2*xoffs
		ygap = bounds.y# - 2*yoffs
		zgap = bounds.z# - 2*yoffs

		# How many lights in xgap?
		# We need a ``smallest gap'' metric.
		# This can be used to work out how many lights we can fit in between these two.
		# Now find a gap size >= smallest_gap that will give us an integer number of lights...
		xmin = self._get_gap(xmin, xgap)
		ymin = self._get_gap(ymin, ygap)
		zmin = self._get_gap(zmin, zgap)

		#ldl.uprint('smallest gap x: ' + str(xmin) + ' num_lights x: ' + str(xgap/xmin))
		#ldl.uprint('smallest gap y: ' + str(ymin) + ' num_lights y: ' + str(ygap/ymin))
		#ldl.uprint('smallest gap z: ' + str(zmin) + ' num_lights z: ' + str(zgap/zmin))

		for i in range(xoffs, int(bounds.x), xmin):
			for j in range(yoffs, int(bounds.y), ymin):
				for k in range(zoffs, int(bounds.z), zmin):
					# Do a test that the lights are near the perimeter of the room,
					# if we are in perimeter mode...
						
					# If the spot is near the walls then use it...
					xclose = self._check_proximity(bounds.x, i, xoffs*1.5)
					yclose = self._check_proximity(bounds.y, j, yoffs*1.5)
					#zclose = self._check_proximity(bounds.z, k, zoffs*1.5)
					# If any test passed, then it's near one of the walls...
					close_to_perimeter = xclose or yclose #or zclose

					if type == ldl.LS_PERIMETER:
						if close_to_perimeter:
							drawlight = True
						else:
							drawlight = False
					elif type == ldl.LS_CENTRE:
						if close_to_perimeter:
							drawlight = False
						else:
							drawlight = True
					else:
						error('invalid lighting subscheme type ' + type + ' specified.')
					
					#ldl.uprint('Light: ' + str(i) + ' ' + str(j) + ' ' + str(k) + '\tclose: ' + str(close_to_perimeter) + '\tType: ' + type + '\tdraw: ' + str(drawlight))

					# Now to render the light to XML...
					if drawlight:
						prop_ent = '<property name=\'classname\' value=\'' + entity + '\'/>'
						prop_org = '<property name=\'origin\' value=\'' + str(i) + ' ' + str(j) + ' ' + str(k) + '\'/>'
						prop_lev = '<property name=\'light\' value=\'' + str(light) + '\'/>'
						if sound:
							prop_snd = '<property name=\'classname\' value=\'' + sound + '\'/>'
						else:
							prop_snd = ''
						ent = '<entity>' + prop_ent + prop_org + prop_lev + prop_snd + '</entity>'
						lights.append(ent)
					else:
						pass
		return lights

	def _get_bounds(self, hollow_attrs):
		'''Work out the internal cube of the hollow.'''
		origin = ldl.getPoint(hollow_attrs['origin'])
		extent = ldl.getPoint(hollow_attrs['extent'])
		return extent - Point(ldl.lip*2, ldl.lip*2, ldl.lip*2)

	def _complete_text_node(self):
		if self._accumulator:
			self._downstream.characters(''.join(self._accumulator))
			self._accumulator = []
		return

	def startElement(self, name, attrs):
		'''FIXME'''
		# FIXME allow z offsets to be specified from the top of the room? (for hanging lights)
		#self.padding_level = self.padding_level + 1
		#self.padded_print(name)
		# Start element normally...
		self._downstream.startElement(name, attrs)
		# Allow most elements through; builders must be turned into solids.
		if name == 'hollow':
			bounds = self._get_bounds(attrs)
			#ldl.uprint('STARTING ROOM... (' + attrs['origin'] + ' ext: ' + str(bounds) + ')')
			style_name = attrs['style']
			# Based on size of room, which lighting substyle (by its id) should we use?
			style_id = styleFetcher.getLightingStyleId(style_name, bounds)
			# Get type of scheme, get paramaters for both perimeter and grid, or just perimeter...
			style_type = styleFetcher.getLightingStyleType(style_name, style_id)

			# Perimeter => just the edges
			# Grid => a superset: perimeter + grid in the centre
			if style_type == ldl.LS_PERIMETER:
				lights = self._make_lights_core(style_name, style_id, style_type, bounds)
			else:
				lights1 = self._make_lights_core(style_name, style_id, ldl.LS_PERIMETER, bounds)
				lights2 = self._make_lights_core(style_name, style_id, ldl.LS_CENTRE, bounds)
				lights = lights1 + lights2
			# Done -- append results...
			self.lightStack.append(lights)
		return

	def startElementNS(self, name, qname, attrs):
		self._complete_text_node()
		self._downstream.startElementNS(name, qname, attrs)
		return

	def endElement(self, name):
		if name == 'hollow':
			#ldl.uprint('...ENDING ROOM')
			for light in self.lightStack.pop():
				print light
		self._complete_text_node()
		self._downstream.endElement(name)
		#self.padding_level = self.padding_level - 1
		return

	def endElementNS(self, name, qname):
		self._complete_text_node()
		self._downstream.endElementNS(name, qname)
		return

	def processingInstruction(self, target, body):
		self._complete_text_node()
		self._downstream.processingInstruction(target, body)
		return

	def comment(self, body):
		self._complete_text_node()
		self._downstream.comment(body)
		return

	def characters(self, text):
		self._accumulator.append(text)
		return

	def ignorableWhitespace(self, ws):
		self._accumulator.append(text)
		return

	# Utility Functions...

	def padded_print(self, msg):
		for i in range(self.padding_level):
			ldl.uprint('  ', sameLine=True)
		ldl.uprint(msg)

if __name__ == "__main__":
	ldl.stage = '03'
	ldl.uprint('\n === ' + ldl.stackdescs[ldl.stage] + ' ===')
	styleFetcher = ldl.StyleFetcher()
	parser = sax.make_parser()
	#XMLGenerator is a special SAX handler that merely writes
	#SAX events back into an XML document
	downstream_handler = XMLGenerator()
	#upstream, the parser, downstream, the next handler in the chain
	filter_handler = LightingStyleFilter(parser, downstream_handler)
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
