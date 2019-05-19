#!/usr/bin/env python3
"""
	00-d-map2mapxml.py
	Part of the Level Description Language (LDL) from the AGRIP project. 
	Copyright 2005-2008 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.

	This program reads a MapXML file on stdin and prints a MAP file to stdout.
	Please ensure the input is a valid MapXML file.
"""

from xml.sax import ContentHandler, make_parser
import sys, ldl

def norm_ws(text):
	return ' '.join(text.split())

class MapXML2Map(ContentHandler):
	def __init__(self):
		self.paddinglevel = 0
		self.chPadding()
		self.inName = self.inValue = self.inPoint = self.inTexture = 0

	def chPadding(self):
		self.padding = ''
		for i in range(0,self.paddinglevel):
			self.padding = self.padding + ' '

	def startElement(self, name, attrs):
		if	  name == 'map':
			sys.stdout.write(ldl.boilerplate_map + '// ' + ldl.stackdescs['00'] + '\n')
		elif	name == 'entity':
			sys.stdout.write(self.padding + '// Entity \n' + self.padding + '{\n')
			self.paddinglevel = self.paddinglevel + 1
			self.chPadding()
		elif	name == 'brush':
			sys.stdout.write(self.padding + '// Brush \n' + self.padding + '{\n')
			self.paddinglevel = self.paddinglevel + 1
			self.chPadding()
		elif	name == 'plane':
			sys.stdout.write(self.padding),
		elif	name == 'point':
			sys.stdout.write('( ')
			self.inPoint = 1
		elif	name == 'texture':
			self.inTexture = 1
		elif	name == 'property':
			self.paddinglevel = self.paddinglevel + 1
			sys.stdout.write(self.padding + '"' + attrs['name'] + '" "' + attrs['value'] + '"\n')
			self.paddinglevel = self.paddinglevel - 1

	def characters(self, ch):
		if self.inPoint or self.inTexture or self.inName or self.inValue:
			sys.stdout.write(ch)

	def endElement(self, name):
		if	  name == 'entity' \
			or  name == 'brush':
			self.paddinglevel = self.paddinglevel - 1
			self.chPadding()
			sys.stdout.write(self.padding + '}\n')
		elif	name == 'point':
			self.inPoint = 0
			sys.stdout.write(' ) ')
		elif name == 'texture':
			self.inTexture = 0
			sys.stdout.write('\n')
		elif	name == 'name':
			self.inName = 0
			sys.stdout.write('" ')
		elif	name == 'value':
			self.inValue = 0
			sys.stdout.write('"\n')


if __name__ == '__main__':
	ldl.stage = '00'
	ldl.uprint('\n === ' + ldl.stackdescs[ldl.stage] + ' ===')
	parser = make_parser()
	conv = MapXML2Map()
	parser.setContentHandler(conv)
	try:
		parser.parse(sys.stdin)
	except:
		ldl.failParse()
