## P3D.py (module 'P3D') Version 1.03
## Copyright (c) 2006 Bruce Vaughan, BV Detailing & Design, Inc.
## All rights reserved.
## NOT FOR SALE. The software is provided "as is" without any warranty.
## Edited by matatk to turn it into a library for AGRIP LDL.
## Original at http://local.wasp.uwa.edu.au/~pbourke/geometry/3planes/P3D.py
#############################################################################

from math import pi, sqrt, acos, cos, sin
#from point import Point

class Point:

	# FIXME unify with plane
	def cross_product(self, other):
		p1 = self
		p2 = other
		return Point(p1.y*p2.z - p1.z*p2.y, p1.z*p2.x - p1.x*p2.z, p1.x*p2.y - p1.y*p2.x)

	# FIXME unify with plane
	def dot_product(self, other):
		p1 = self
		p2 = other
		return (p1.x*p2.x + p1.y*p2.y + p1.z*p2.z)

	# point * number
	def __mul__(self, other):
		return Point(self.x * other, self.y * other, self.z * other)

	# point / number
	def divide_coords_by(self, factor):
		return Point(self.x/factor, self.y/factor, self.z/factor)

	def __init__(self, x, y, z):
		self.x = x
		self.y = y
		self.z = z

	def __add__(self, o):
		if type(o) == type(0) or type(o) == type(0.0):
			return Point(self.x + o, self.y + o, self.z + o)
		else:
			return Point(self.x + o.x, self.y + o.y, self.z + o.z)

	def __sub__(self, o):
		if type(o) == type(0) or type(o) == type(0.0):
			return Point(self.x - o, self.y - o, self.z - o)
		else:
			return Point(self.x - o.x, self.y - o.y, self.z - o.z)

	def __neg__(self):
		return Point(-self.x, -self.y, -self.z)

	def dist(self, o):
		dx = o.x - self.x
		dy = o.y - self.y
		dz = o.z - self.z
		return sqrt(dx**2 + dy**2 + dz**2)

	def __str__(self):
		return str(self.x) + ' ' + str(self.y) + ' ' + str(self.z)

	def __cmp__(self, other):
		# compare x
		if self.x < other.x:
			x = -1
		elif self.x == other.x:
			x = 0
		else:
			x = 1
		# compare y
		if self.y < other.y:
			y = -1
		elif self.y == other.y:
			y = 0
		else:
			y = 1
		# compare z
		if self.z < other.x:
			z = -1
		elif self.z == other.x:
			z = 0
		else:
			z = 1
		# self is less than other if ...
		if x < 0 and y < 0 and z < 0:
			return -1
		elif x == 0 and y == 0 and z == 0:
			return 0
		elif x > 0 and y > 0 and z > 0:
			return 1
		else:
			error('points are not comparable')

class Plane3D:

	def cross_product(self, p1, p2):
		return Point(p1.y*p2.z - p1.z*p2.y, p1.z*p2.x - p1.x*p2.z, p1.x*p2.y - p1.y*p2.x)

	def dot_product(self, p1, p2):
		return (p1.x*p2.x + p1.y*p2.y + p1.z*p2.z)

	def plane_def(self, p1, p2, p3):
		N = self.cross_product(p2-p1, p3-p1)
		A = N.x
		B = N.y
		C = N.z
		D = self.dot_product(-N, p1)
		return N, A, B, C, D

	def __init__(self, p1, p2, p3, theta1 = 0):

		def chk_type(p_list):
			ret_list = []
			for p in p_list:
				if type(p) == type(Point(0,0,0)):
					ret_list.append(True)
				else:
					ret_list.append(None)
			return ret_list

		if None not in chk_type([p1, p2, p3]):
			"""
			/// Define a plane from 3 non-collinear points
			/// Ax + By + Cz + D = 0
			/// The normal 'N' to the plane is the vector (A, B, C)
			"""
			self.N, A, B, C, self.D = self.plane_def(p1, p2, p3)
			self.N_len = round(sqrt(A*A + B*B + C*C), 6)
			if self.N_len > 0.0:
				self.N_uv = Point(self.N.x/self.N_len, self.N.y/self.N_len, self.N.z/self.N_len)
			else:
				self.N_uv = Point(0.0, 0.0, 0.0)
			# make p1 global to class namespace
			self.p1 = p1
			"""
			/// If vector N is the normal to the plane then all points 'p' on the plane satisfy the following:
			/// N dot p = k where 'dot' is the dot product
			/// N dot p = N.x*p.x + N.y*p.y + N.z*p.z
			"""
			self.k = round(self.dot_product(self.N, p1), 6)			 # calculation of plane constant 'k'
			self.k0 = round(self.dot_product(self.N_uv, p1), 6)		 # displacement of the plane from the origin
			"""
			/// Determine vector e and unit vector e0 (p1 to p3)
			/// Determine vector d and unit vector d0 (p1 to p2)
			/// Determine location of point F, midpoint on vector d
			/// Determine location of point G, midpoint on vector e
			"""
			e = p3 - p1
			e_len = (sqrt(e.x**2 + e.y**2 + e.z**2))
			if e_len > 0.0:
				self.e0 = Point(e.x/e_len, e.y/e_len, e.z/e_len)
			else:
				self.e0 = Point(0.0, 0.0, 0.0)
			d = p2 - p1
			d_len = (sqrt(d.x**2 + d.y**2 + d.z**2))
			if d_len > 0.0:
				self.d0 = Point(d.x/d_len, d.y/d_len, d.z/d_len)
			else:
				self.d0 = Point(0.0, 0.0, 0.0)
			self.F = Point(p1.x + (d.x/2), p1.y + (d.y/2), p1.z + (d.z/2))
			self.G = Point(p1.x + (e.x/2), p1.y + (e.y/2), p1.z + (e.z/2))
			# Make variables 'e' and 'd' available as attributes
			self.e = e
			self.d = d

			# Calculate distance between points p1 and p2
			self.Ra = p2.dist(p1)

			"""
			/// Calculate net angle between vectors d0 and e0 (Q)
			/// Radius = self.Ra
			/// Calculate point to point distance (pp)
			"""
			if abs(theta1) == pi:
				self.Q = theta1
			else:
				self.Q = acos(self.dot_product(self.d0, self.e0))   # radians
			self.pp = abs(self.Q * self.Ra)

		else:
			raise TypeError('The arguments passed to Plane3D must be a POINT')

	def lie_check(self, p):
		"""
		/// Given any point 'a' on a plane: N dot (a-p) = 0
		"""
		return round(self.dot_product(self.N, (p - self.p1)))

	def __str__(self):
		return 'Plane: ' + str(self.N) + ' . ' + str(self.p1) + ' = ' + str(self.k)
