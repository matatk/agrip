#!/usr/bin/env python3
"""
	level_01_up_brushsizes.py
	Part of the Level Description Language (LDL) from the AGRIP project.
	Copyright 2005-2019 Matthew Tylee Atkinson
	Released under the GNU GPL v2 -- See ``COPYING'' for more information.

	This program reads a MapXML file on stdin and simplifies the brush
	definitions from a collection of planes to the origin and extent.

	ASSUMPTIONS
	* All brushes are cuboids made up of 6 planes.
	* The same texture is applied to all planes of each brush.
"""

import xml.dom.minidom
import re
import utils
from plane import Point, Plane3D
from conf import prog

r_planepoints = re.compile('(-?[0-9.]+) (-?[0-9.]+) (-?[0-9.]+)')


# From the Python documentation...
def getText(nodelist):
	ret = ''
	for node in nodelist:
		if node.nodeType == node.TEXT_NODE:
			ret = ret + node.data
	return ret


def listBrushes(map):
	brush_planes = []  # stores the (6) planes that make up one brush
	plane_points = []  # stores the (3) points in the current plane
	psa = []  # store one set of non-parallel planes
	psb = []  # store another set of non-parallel planes
	textureSpec = ''

	# Process all brushes...
	for brush in map.getElementsByTagName('brush'):
		utils.uprint('Brush...')
		# Get all planes...
		for plane in brush.getElementsByTagName('plane'):
			utils.uprint('    Plane...')
			# Get texture spec...
			textureSpec = getText(plane.getElementsByTagName('texture')[0].childNodes)
			utils.uprint('        Texture: ' + textureSpec)
			# Get all points...
			for point in plane.getElementsByTagName('point'):
				point_match = r_planepoints.match(getText(point.childNodes))
				plane_points.append(Point(
					float(point_match.group(1)),
					float(point_match.group(2)),
					float(point_match.group(3))))
				# NB: We use floats above so that later calculations are still accurate.
				utils.uprint('        ' + str(plane_points[len(plane_points) - 1]))
			# Put points into a plane object...
			brush_planes.append(
				Plane3D(
					plane_points[0],
					plane_points[1],
					plane_points[2]))
			plane_points = []
			# Grab texture and remove this plane...
			brush.removeChild(plane)

		# Got all planes; work out brush origin and size...
		for plane in brush_planes:
			utils.uprint('   ' + str(plane))

		# Get and solve parallel planes...
		while len(brush_planes) > 0:
			t = brush_planes.pop(0)
			s = t.N.x + t.N.y + t.N.z
			if s > 0:
				psa.append(t)
			else:
				psb.append(t)
		i1 = intersect(psa[0], psa[1], psa[2])
		i2 = intersect(psb[0], psb[1], psb[2])

		# Work out size (from smallest/lowest coord) and extent...
		i1s = i1.x + i1.y + i1.z
		i2s = i2.x + i2.y + i2.z
		if i1s < i2s:
			origin = i1
			extent = i2 - i1
		else:
			origin = i2
			extent = i2 - i1

		# Update brush info...
		brush.setAttribute('origin', str(origin))
		brush.setAttribute('extent', str(extent))
		brush.setAttribute('texture', textureSpec)
		# Tidy up...
		psa = []
		psb = []


def intersect(P1, P2, P3):
	N1 = P1.N
	N2 = P2.N
	N3 = P3.N
	k1 = P1.k
	k2 = P2.k
	k3 = P3.k
	ptop1 = (N2.cross_product(N3)) * k1
	ptop2 = (N3.cross_product(N1)) * k2
	ptop3 = (N1.cross_product(N2)) * k3
	ptop = ptop1 + ptop2 + ptop3
	pbot = N1.dot_product(N2.cross_product(N3))
	p = ptop.divide_coords_by(pbot)
	# for some reason sometimes these return -0.0 as one of the coors
	if p.x == 0:
		p.x = 0
	if p.y == 0:
		p.y = 0
	if p.z == 0:
		p.z = 0
	return p


# FIXME DRY
def main(xml_in):
	m = xml.dom.minidom.parseString(xml_in)
	listBrushes(m)
	m.getElementsByTagName('map')[0] \
		.setAttribute('stackdesc', prog.stackdescs[1])
	m.getElementsByTagName('map')[0].setAttribute('generator', __file__)
	return m.toprettyxml()
