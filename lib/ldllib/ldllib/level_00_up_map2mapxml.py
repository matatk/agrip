#!/usr/bin/env python3
"""
	level_00_up_map2mapxml.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2021 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.

	This program reads a MAP file on stdin and prints a MapXML file to stdout.
	Please ensure the input is a valid MAP file.
"""

import re
from ldllib.conf import prog

r_chunk = re.compile(
	'(\\{'
		# optional leading stuff...
		'[^{}]*?'
		# optional embedded chunks...
		'('
			# start of embedded chunk...
			'\\{'
			# followed by almost anything...
			'[^{}]*?'
			# end of embedded chunk if started earlier...
			'\\}'
			# optional trailing stuff (between ECs)...
			'[^{}]*?'
		')*'
		# optional trailing stuff...
		'[^{}]*?'
	'\\})', re.DOTALL)

r_plane = re.compile(
	'\\( (-?[0-9.]+ -?[0-9.]+ -?[0-9.]+) \\) '
	'\\( (-?[0-9.]+ -?[0-9.]+ -?[0-9.]+) \\) '
	'\\( (-?[0-9.]+ -?[0-9.]+ -?[0-9.]+) \\) '
	'(.+?)(?: \\/\\/.+?)?\n')  # Don't use DOTALL - would capture all planes


class MapParser:
	def __init__(self, map_string):
		self.stream = map_string
		self.nestinglevel = -1
		self.padding = ''
		self.output = ''

	def _add_to_output(self, string):
		self.output += string

	def parseChunk(self, chunk):
		# See if it's an entity or just a brush.
		# If entity, get out properites, then parse for chunks...
		r_estart = re.compile(r'.*?".*?\{?', re.DOTALL)
		res_e = r_estart.match(chunk)
		if res_e:
			#
			# ENTITY
			#
			self._add_to_output(self.padding + '<entity>\n')
			r_property = re.compile(r'"(?P<name>.+?)" "(?P<val>.+?)"', re.DOTALL)
			r_entend = re.compile(r'.*?\{', re.DOTALL)

			# Get properties...
			exitflag = 0
			offset = 0
			while not exitflag:
				res_prop = r_property.search(chunk[offset:])
				if res_prop:
					self._add_to_output(
						self.padding + self.padding + '<property name="'
						+ res_prop.group('name') + '" value="' + res_prop.group('val')
						+ '" />\n')
					offset = offset + res_prop.end()
				else:
					exitflag = 1

			res_eb = r_entend.search(chunk[offset:])
			if res_eb:
				# The entity had embedded brushes...
				self.parseMain(chunk[res_eb.end():len(chunk)])

			self._add_to_output(self.padding + '</entity>\n')
		else:
			#
			# BRUSH
			#
			self._add_to_output(self.padding + '<brush>\n')
			# Get planes out...
			offset = 0
			exitflag = 0
			while not exitflag:
				res_pl = r_plane.search(chunk[offset:])
				if res_pl:
					self._add_to_output(self.padding + self.padding + '<plane>\n')
					# For each group, put out a point section...
					for group in range(1, 4):
						self._add_to_output(
							self.padding + self.padding + self.padding + '<point>'
							+ res_pl.group(group) + '</point>\n')
					self._add_to_output(
						self.padding + self.padding + self.padding + '<texture>'
						+ res_pl.group(4) + '</texture>\n')
					offset = offset + res_pl.end()
					self._add_to_output(self.padding + self.padding + '</plane>\n')
				else:
					exitflag = 1
			self._add_to_output(self.padding + '</brush>\n')

	def parseMain(self, instr):
		# Looks for chunks next to each other within the given string
		# (which could be the whole map file or just part of it)
		self.nestinglevel = self.nestinglevel + 1
		self.padding = self.padding + '  '
		exitflag = 0
		start = 0

		while not exitflag:
			result = r_chunk.search(instr[start:])
			if result:
				self.parseChunk(instr[start + result.start() + 1:start + result.end() - 1])
				# (The -1s are there so we don't get the surrounding {}s.)
				start = start + result.end()
			else:
				exitflag = 1
		self.padding = ''
		for i in range(0, self.nestinglevel):
			self.padding = self.padding + '  '

	def parseMap(self):
		self._add_to_output('<?xml version="1.0" ?>\n')
		self._add_to_output(prog.boilerplate)
		self._add_to_output(
			'<map stackdesc="' + prog.stackdescs[0] + '" generator="' + __file__
			+ '">\n')
		self.parseMain(self.stream)
		self._add_to_output('</map>\n')
		# sys.stdout.close
		# EOF


def main(mapfile_in):
	mp = MapParser(mapfile_in)
	mp.parseMap()
	return mp.output
