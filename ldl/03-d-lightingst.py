#!/usr/bin/env python3
"""
	03-d-lightingst.py
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


class LightingStyleFilter(XMLFilterBase):
	"""
	SAX filter to FIXME
	"""

	def __init__(self, parent):  # TODO needed?
		super().__init__(parent)

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
		increment = 1
		# for smallest (making it greater until num_lights comes out integer)
		tolerance = 0.05  # difference between the integer and float number of lights
		while not found and smallest < total:
			num_lights = total / smallest
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
		#   i.e. xoffs,             yoffs,             zoffs
		#        xoffs,             bounds.y - yoffs,  zoffs
		#        bounds.x - xoffs,  yoffs,             zoffs
		#        bounds.x - xoffs,  bounds.y - yoffs,  zoffs
		# Work out how many to go inbetween the corners (along walls).
		# That may be repeated vertically according to zstep.
		# Do we have them in middle of room?

		xgap = bounds.x  # - 2*xoffs
		ygap = bounds.y  # - 2*yoffs
		zgap = bounds.z  # - 2*yoffs

		# How many lights in xgap?
		# We need a ``smallest gap'' metric.
		# This can be used to work out how many lights we can fit in between
		# these two.
		# Now find a gap size >= smallest_gap that will give us an integer
		# number of lights...
		xmin = self._get_gap(xmin, xgap)
		ymin = self._get_gap(ymin, ygap)
		zmin = self._get_gap(zmin, zgap)

		for i in range(xoffs, int(bounds.x), xmin):
			for j in range(yoffs, int(bounds.y), ymin):
				for k in range(zoffs, int(bounds.z), zmin):
					# Do a test that the lights are near the perimeter of the room,
					# if we are in perimeter mode...

					# If the spot is near the walls then use it...
					xclose = self._check_proximity(bounds.x, i, xoffs * 1.5)
					yclose = self._check_proximity(bounds.y, j, yoffs * 1.5)
					# If any test passed, then it's near one of the walls...
					close_to_perimeter = xclose or yclose  # or zclose

					if type == utils.LS_PERIMETER:
						if close_to_perimeter:
							drawlight = True
						else:
							drawlight = False
					elif type == utils.LS_CENTRE:
						if close_to_perimeter:
							drawlight = False
						else:
							drawlight = True
					else:
						utils.error('invalid lighting subscheme type ' + type + ' specified.')

					# Now to render the light to XML...
					if drawlight:
						super().startElement('entity', {})

						super().startElement('property', {
							'name': 'classname',
							'value': entity
						})
						super().endElement('property')

						super().startElement('property', {
							'name': 'origin',
							'value': str(i) + ' ' + str(j) + ' ' + str(k)
						})
						super().endElement('property')

						super().startElement('property', {
							'name': 'light',
							'value': str(light)
						})
						super().endElement('property')

						if sound:
							super().startElement('property', {
								'name': 'classname',
								'value': sound
							})
							super().endElement('property')

						super().endElement('entity')
					else:
						pass
		return lights

	def _get_bounds(self, hollow_attrs):
		'''Work out the internal cube of the hollow.'''
		extent = utils.getPoint(hollow_attrs['extent'])
		return extent - Point(utils.lip * 2, utils.lip * 2, utils.lip * 2)

	def startElement(self, name, attrs):
		'''FIXME'''
		# FIXME allow z offsets to be specified from the top of the room? (for
		# hanging lights)
		# Start element normally...
		super().startElement(name, attrs)
		# Allow most elements through; builders must be turned into solids.
		if name == 'hollow':
			bounds = self._get_bounds(attrs)
			style_name = attrs['style']
			# Based on size of room, which lighting substyle (by its id) should we use?
			style_id = styleFetcher.getLightingStyleId(style_name, bounds)
			# Get type of scheme, get paramaters for both perimeter and grid,
			# or just perimeter...
			style_type = styleFetcher.getLightingStyleType(style_name, style_id)

			# Perimeter => just the edges
			# Grid => a superset: perimeter + grid in the centre
			if style_type == utils.LS_PERIMETER:
				self._make_lights_core(style_name, style_id, style_type, bounds)
			else:
				self._make_lights_core(
					style_name, style_id, utils.LS_PERIMETER, bounds)
				self._make_lights_core(
					style_name, style_id, utils.LS_CENTRE, bounds)

	# Utility Functions...

	def padded_print(self, msg):
		for i in range(self.padding_level):
			utils.uprint('  ', sameLine=True)
		utils.uprint(msg)


# FIXME DRY
def main(xml_in):
	utils.stage = '03'
	utils.uprint('\n === ' + utils.stackdescs[utils.stage] + ' ===')
	global styleFetcher
	styleFetcher = utils.StyleFetcher()
	filtered_reader = LightingStyleFilter(xml.sax.make_parser())
	xml_out = io.StringIO()
	filtered_reader.setContentHandler(
		XMLGenerator(xml_out, short_empty_elements=True))
	try:
		hacky = io.StringIO(xml_in)
		filtered_reader.parse(hacky)
	except xml.sax.SAXParseException as detail:
		utils.error('The XML you supplied is not valid: ' + str(detail))
	except:  # noqa E722
		raise
		utils.failParse()
	return xml_out.getvalue()


if __name__ == "__main__":
	print(main(sys.stdin.read()))
