#!/usr/bin/env python3
"""
	00-d-map2mapxml.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2008 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.

	This program reads a MapXML file on stdin and prints a MAP file to stdout.
	Please ensure the input is a valid MapXML file.
"""

import xml.sax
import sys
import ldl


def norm_ws(text):
	return ' '.join(text.split())


class MapXML2Map(xml.sax.ContentHandler):
	def __init__(self):
		self.paddinglevel = 0
		self.chPadding()
		self.inName = self.inValue = self.inPoint = self.inTexture = 0
		self._result = ''

	def _add(self, string):
		self._result += string

	def chPadding(self):
		self.padding = ''
		for i in range(0, self.paddinglevel):
			self.padding = self.padding + ' '

	def startElement(self, name, attrs):
		if name == 'map':
			self._add(ldl.boilerplate_map + '// ' + ldl.stackdescs['00'] + '\n')
		elif name == 'entity':
			self._add(self.padding + '// Entity \n' + self.padding + '{\n')
			self.paddinglevel = self.paddinglevel + 1
			self.chPadding()
		elif name == 'brush':
			self._add(self.padding + '// Brush \n' + self.padding + '{\n')
			self.paddinglevel = self.paddinglevel + 1
			self.chPadding()
		elif name == 'plane':
			self._add(self.padding),
		elif name == 'point':
			self._add('( ')
			self.inPoint = 1
		elif name == 'texture':
			self.inTexture = 1
		elif name == 'property':
			self.paddinglevel = self.paddinglevel + 1
			self._add(
				self.padding + '"' + attrs['name'] + '" "' + attrs['value'] + '"\n')
			self.paddinglevel = self.paddinglevel - 1

	def characters(self, ch):
		if self.inPoint or self.inTexture or self.inName or self.inValue:
			self._add(ch)

	def endElement(self, name):
		if name == 'entity' \
			or name == 'brush':
			self.paddinglevel = self.paddinglevel - 1
			self.chPadding()
			self._add(self.padding + '}\n')
		elif name == 'point':
			self.inPoint = 0
			self._add(' ) ')
		elif name == 'texture':
			self.inTexture = 0
			self._add('\n')
		elif name == 'name':
			self.inName = 0
			self._add('" ')
		elif name == 'value':
			self.inValue = 0
			self._add('"\n')


def main(xml_in):
	ldl.stage = '00'
	ldl.uprint('\n === ' + ldl.stackdescs[ldl.stage] + ' ===')
	conv = MapXML2Map()
	try:
		xml.sax.parseString(xml_in, conv)
	except:  # noqa E722
		raise
		ldl.failParse()
	return conv._result


if __name__ == '__main__':
	# TODO: turn off ldl.uprint here, or send to stderr?
	print(main(sys.stdin.read()))
