#!/usr/bin/env python
"""
	01-d-brushsizes.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2008 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.

	This program reads a MapXML file on stdin with simplified brush
	definitions and makes up a lower-level MapXML file that contains planes.

	ASSUMPTIONS
	* All brushes are cuboids made up of 6 planes.
	* The same texture is applied to all planes of each brush.
"""

#import sys, xml.dom.minidom, xml.dom.ext, re, ldl
import sys, xml.dom.minidom, re, ldl
from plane import Point, Plane3D

r_planepoints = re.compile('(-?[0-9.]+) (-?[0-9.]+) (-?[0-9.]+)')

def PointFromString(str):
	point_match = r_planepoints.match(str)
	return Point(float(point_match.group(1)), float(point_match.group(2)), float(point_match.group(3)))

def get_planes(origin, extent):
	'''Work out the six intersecting planes, in the form of sets of 3 points, that bound the given space.
	Returns a list of 6 planes, each containing a list of 3 points (i.e 2D array).'''
	brush_planes = []
	plane_points = []
	abslut = origin + extent
	#ldl.uprint('Brush: ' + str(origin) + '\te ' + str(extent) + '\ta ' + str(abslut))
	# Create points on planes around origin and absolute...
	brush_planes = [ \
	[ [ origin.x, 0, 0 ], [ origin.x, 1, 0 ], [ origin.x, 0, 1 ] ],
	[ [ abslut.x, 0, 0 ], [ abslut.x, 0, 1 ], [ abslut.x, 1, 0 ] ],
	[ [ 0, origin.y, 0 ], [ 0, origin.y, 1 ], [ 1, origin.y, 0 ] ],
	[ [ 0, abslut.y, 0 ], [ 1, abslut.y, 0 ], [ 0, abslut.y, 1 ] ],
	[ [ 0, 0, origin.z ], [ 1, 0, origin.z ], [ 0, 1, origin.z ] ],
	[ [ 0, 0, abslut.z ], [ 0, 1, abslut.z ], [ 1, 0, abslut.z ] ] ]
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
						str(brush_planes[i][j][0]) + ' ' +
						str(brush_planes[i][j][1]) + ' ' +
						str(brush_planes[i][j][2])
					)
				)
				plane.appendChild(point)
			texture = map.createElement('texture')
			texture.appendChild(map.createTextNode(brush_texture))
			plane.appendChild(texture)
			brush.appendChild(plane)

if __name__ == '__main__':
	ldl.stage = '01'
	ldl.uprint('\n === ' + ldl.stackdescs[ldl.stage] + ' ===')
	try:
		m = xml.dom.minidom.parse(sys.stdin)
	except:
		ldl.failParse()
	processBrushes(m)
	ldl.remove_whitespace_nodes(m)
	m.getElementsByTagName('map')[0].setAttribute('stackdesc', ldl.stackdescs['01'])
	m.getElementsByTagName('map')[0].setAttribute('generator', __file__)
	#xml.dom.ext.PrettyPrint(m)
	print m.toxml()
	m.unlink()
