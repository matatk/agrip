#!/usr/bin/env python3
"""
	level_01_down_brushsizes.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2008 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.

	This program reads a MapXML file on stdin with simplified brush
	definitions and makes up a lower-level MapXML file that contains planes.

	ASSUMPTIONS
	* All brushes are cuboids made up of 6 planes.
	* The same texture is applied to all planes of each brush.
"""

import sys
import xml.dom.minidom
import re
import utils
from plane import Point
from conf import prog

r_planepoints = re.compile('(-?[0-9.]+) (-?[0-9.]+) (-?[0-9.]+)')


def PointFromString(str):
	point_match = r_planepoints.match(str)
	return Point(
		float(point_match.group(1)),
		float(point_match.group(2)),
		float(point_match.group(3)))


def get_planes(origin, extent):
	'''Work out the six intersecting planes, in the form of sets of 3 points,
	that bound the given space.

	Returns a list of 6 planes, each containing a list of 3 points (i.e 2D
	array).'''
	brush_planes = []
	abslut = origin + extent
	# Create points on planes around origin and absolute...
	brush_planes = [
		[[origin.x, 0, 0], [origin.x, 1, 0], [origin.x, 0, 1]],
		[[abslut.x, 0, 0], [abslut.x, 0, 1], [abslut.x, 1, 0]],
		[[0, origin.y, 0], [0, origin.y, 1], [1, origin.y, 0]],
		[[0, abslut.y, 0], [1, abslut.y, 0], [0, abslut.y, 1]],
		[[0, 0, origin.z], [1, 0, origin.z], [0, 1, origin.z]],
		[[0, 0, abslut.z], [0, 1, abslut.z], [1, 0, abslut.z]]]
	return brush_planes


# From the Python documentation...
def getText(nodelist):
	ret = ''
	for node in nodelist:
		if node.nodeType == node.TEXT_NODE:
			ret = ret + node.data
	return ret


def processBrushes(map):
	for brush in map.getElementsByTagName('brush'):
		# Get attributes...
		brush_origin = PointFromString(brush.getAttribute('origin'))
		brush_extent = PointFromString(brush.getAttribute('extent'))
		brush_planes = get_planes(brush_origin, brush_extent)
		brush_texture = brush.getAttribute('texture')
		brush.removeAttribute('origin')
		brush.removeAttribute('extent')
		brush.removeAttribute('texture')
		# Create planes...
		for i in range(6):
			plane = map.createElement('plane')
			for j in range(3):
				point = map.createElement('point')
				point.appendChild(map.createTextNode(
					str(brush_planes[i][j][0]) + ' '
					+ str(brush_planes[i][j][1]) + ' '
					+ str(brush_planes[i][j][2])))
				plane.appendChild(point)
			texture = map.createElement('texture')
			texture.appendChild(map.createTextNode(brush_texture))
			plane.appendChild(texture)
			brush.appendChild(plane)


# FIXME DRY
def main(xml_in):
	utils.stage = '01'
	utils.uprint('\n === ' + prog.stackdescs[utils.stage] + ' ===')
	try:
		m = xml.dom.minidom.parseString(xml_in)
	except:  # noqa E722
		utils.failParse()
	processBrushes(m)
	utils.remove_whitespace_nodes(m)
	m.getElementsByTagName('map')[0] \
		.setAttribute('stackdesc', prog.stackdescs['01'])
	m.getElementsByTagName('map')[0].setAttribute('generator', __file__)
	return m.toprettyxml()


if __name__ == '__main__':
	print(main(sys.stdin.read()))
