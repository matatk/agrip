'''Algorithm for splitting walls based on holes

(waaaay too large and stupid)'''
import ldllib.utils as utils
from ldllib.conf import connector

debug_printing = 0


def paddedPrint(msg):
	if debug_printing:
		for i in range(splitWallCoreLevel):
			utils.uprint(splitWallCorePadding, True)
		utils.uprint(msg)


def splitWall(brush, holes):
	'''Splits a brush up in 2D so that it appears to have a hole in it.

	This is achieved by taking the full brush size and the holes list and
	splitting the brush up into multiple parts.'''
	if not holes:
		return [brush]
	parts = []  # stores 2D parts returned by the main function
	finalparts = []  # stores expanded 3D parts
	extent2d = utils.Point2D(brush.extent.x, brush.extent.y)
	# Sort holes by x start coord, then width...
	sortedholes = qsortHoles(holes)
	# Check for errors and add doors into the returned list of parts, as they
	# need to be built...
	for hole in sortedholes:
		# FIXME check for other errors -- backtrack?
		if hole.origin.y + hole.extent.y > extent2d.y:
			utils.error(
				'Hole is taller than containing wall.\n\thole: '
				+ str(hole) + '\n\textent2d: ' + str(extent2d))
		if hole.type == connector.DOOR:
			finalparts.append(utils.Region2D(
				utils.Point2D(
					brush.origin.x + hole.origin.x,
					brush.origin.y + hole.origin.y),
				utils.Point2D(
					hole.extent.x,
					hole.extent.y),
				hole.type,
				hole.props
			))
	# Go to main function...
	# FIXME this should not assume the origin is (0, 0) but it doesn't work if
	# we don't make this true...
	parts = splitWallCore(
		utils.Chunk2D(utils.Point2D(0, 0), extent2d), sortedholes)
	# Take list of brushes and add the z coord back on...
	for p in parts:
		finalparts.append(utils.Region2D(
			utils.Point2D(
				brush.origin.x + p.origin.x,
				brush.origin.y + p.origin.y),
			utils.Point2D(p.extent.x, p.extent.y),
			p.type, p.props
		))
	# Now we can return them...
	return finalparts


splitWallCorePadding = '    '
splitWallCoreLevel = -1


def splitWallCore(chunk, holes):
	'''Take a given area of the face to be split and split it.'''
	global splitWallCoreLevel
	splitWallCoreLevel = splitWallCoreLevel + 1
	parts = []
	if len(holes) == 0:
		paddedPrint('sWC: 0. chunk:' + str(chunk))
		parts.append(chunk)
	elif len(holes) == 1:
		hole = holes.pop()
		paddedPrint('sWC: 1. chunk: ' + str(chunk) + ' holes: ' + str(hole))
		if hole.end.x < chunk.end.x:
			# The hole is not flush with one side of this chunk; split the
			# chunk so it is.
			# We do this by splitting the chunk so that the hole touches its
			# east side.
			# Anything left over after the east side is a single whole chunk.
			paddedPrint(
				'sWC: 1. hole.end.x (' + str(hole.end.x)
				+ ') < chunk.end.x (' + str(chunk.end.x) + ').')
			# Process part of chunk with hole in it...
			paddedPrint('sWC: 1. hole.end.x < chunk.end.x.  HOLE CHUNK')
			addparts = splitWallCore(
				utils.Chunk2D(
					chunk.origin,
					utils.Point2D(hole.end.x - chunk.origin.x, chunk.extent.y)
				),
				[hole])
			for ap in addparts:
				parts.append(ap)
			# Process the bit left at the east side...
			paddedPrint('sWC: 1. hole.end.x < chunk.end.x.  SOLID CHUNK')
			addparts = splitWallCore(
				utils.Chunk2D(
					utils.Point2D(hole.end.x, chunk.origin.y),
					utils.Point2D(chunk.end.x - hole.end.x, chunk.extent.y)
				),
				[])
			for ap in addparts:
				parts.append(ap)
		else:
			# The end x-points of hole and chunk must be equal.
			# Add some parts around the hole...
			paddedPrint('sWC: 1. split flush.')
			# Under hole
			if (hole.origin.y - chunk.origin.y) > 0:
				parts.append(utils.Chunk2D(
					chunk.origin,
					utils.Point2D(
						hole.end.x - chunk.origin.x,
						hole.origin.y - chunk.origin.y)))
			# Left of hole
			if (hole.origin.x - chunk.origin.x) > 0:
				parts.append(utils.Chunk2D(
					chunk.origin + utils.Point2D(
						0,
						hole.origin.y - chunk.origin.y),
					utils.Point2D(
						hole.origin.x - chunk.origin.x,
						hole.extent.y)))
			# Above hole
			if (chunk.end.y - hole.end.y) > 0:
				parts.append(utils.Chunk2D(
					chunk.origin + utils.Point2D(
						0,
						hole.end.y - chunk.origin.y),
					utils.Point2D(
						hole.end.x - chunk.origin.x,
						chunk.end.y - hole.end.y)))
			paddedPrint(
				'sWC: 1. split flush.  results: '
				+ str([str(p) for p in parts]))
	else:  # len(holes) > 1
		paddedPrint(
			'sWC: n. chunk: ' + str(chunk) + ' holes: '
			+ str([str(h) for h in holes]))

		'''Compare first two holes.
		If they do not overlap x-wise, split the chunk at the x value that
		represents the end of the first hole.
		If they do overlap x-wise, see if they overlap y-wise too.
			If they do, we're screwed (can't handle this yet).
			If they overlap y-wise
				See if there are any more nodes.
					If no, then we can just split this chunk at a given y-value
					to keep the holes seperate.
					If yes, then we need to see if we can split this chunk into two:
						one split vertically (at an x-value just after the 2nd
						hole) to seperate our two x-overlapping holes from the
						next one.
						and one split horizontally (at a y-value) to separate
						our overlapping holes
		'''
		holeA = holes[0]
		holeB = holes[1]
		if holeA.end.x < holeB.origin.x:
			paddedPrint(
				'sWC: n. holeA.end.x (' + str(holeA.end.x)
				+ ') < holeB.origin.x (' + str(holeB.origin.x) + ')')
			# Our holes do not overlap x-wise;
			# split our chunk into two:
			#   one chunk containing the first hole (flush to the edge)
			#   another chunk containing all the other holes
			paddedPrint('sWC: n. holeA.end.x < holeB.origin.x.  singleton')
			addparts = splitWallCore(
				utils.Chunk2D(
					chunk.origin, utils.Point2D(
						holeA.end.x - chunk.origin.x,
						chunk.extent.y)),
				[holeA])
			for ap in addparts:
				parts.append(ap)
			paddedPrint('sWC: n. holeA.end.x < holeB.origin.x.  the rest')
			addparts = splitWallCore(
				utils.Chunk2D(
					utils.Point2D(
						holeA.end.x,
						chunk.origin.y),
					utils.Point2D(
						chunk.end.x - holeA.end.x,
						chunk.extent.y)),
				holes[1:])
			for ap in addparts:
				parts.append(ap)
		elif holeA.origin.y >= holeB.end.y \
			or holeB.origin.y >= holeA.end.y:
			paddedPrint(
				'sWC: n. Y.  holeA.origin.y (' + str(holeA.origin.y)
				+ ' >= holeB.end.y (' + str(holeB.end.y) + ')')
			# Our holes overlap x-wise, but they don't overlap y-wise.
			# Which one is on top?
			if holeA.origin.y >= holeB.origin.y:
				upper = holeA
				lower = holeB
			else:
				upper = holeB
				lower = holeA
			# Are there more holes?
			if not len(holes) > 2:
				paddedPrint('sWC: n. Y.  no more holes')
				# No more holes; just split this chunk y-wise...
				paddedPrint('sWC: n. Y.  no more holes.  LOWER.')
				addparts = splitWallCore(
					utils.Chunk2D(
						chunk.origin,
						utils.Point2D(chunk.extent.x, upper.origin.y)
					),
					[lower])
				for ap in addparts:
					parts.append(ap)
				paddedPrint('sWC: n. Y.  no more holes.  UPPER.')
				addparts = splitWallCore(
					utils.Chunk2D(
						utils.Point2D(
							chunk.origin.x,
							upper.origin.y),
						utils.Point2D(
							chunk.extent.x,
							chunk.extent.y - upper.origin.y)),
					[upper])
				for ap in addparts:
					parts.append(ap)
			else:
				# There are more holes; split both y- and x-wise.
				# Use the x-value of the next hole (FIXME could break things?)
				xcutoff = holes[2].origin.x - chunk.origin.x
				paddedPrint(
					'sWC: n. Y.  more holes; xcutoff = ' + str(xcutoff))
				paddedPrint('sWC: n. Y.  more holes.  LOWER.')
				addparts = splitWallCore(
					utils.Chunk2D(
						chunk.origin,
						utils.Point2D(xcutoff, upper.origin.y)),
					[lower])
				for ap in addparts:
					parts.append(ap)
				paddedPrint('sWC: n. Y.  more holes.  UPPER.')
				addparts = splitWallCore(
					utils.Chunk2D(
						utils.Point2D(chunk.origin.x, upper.origin.y),
						utils.Point2D(xcutoff, chunk.extent.y - upper.origin.y)
					),
					[upper])
				for ap in addparts:
					parts.append(ap)
				paddedPrint('sWC: n. Y.  more holes.  REST-OF-X.')
				addparts = splitWallCore(
					utils.Chunk2D(
						utils.Point2D(chunk.origin.x + xcutoff, chunk.origin.y),
						utils.Point2D(chunk.extent.x - xcutoff, chunk.extent.y)
					),
					holes[2:])
				for ap in addparts:
					parts.append(ap)
		else:
			# Our holes overlap both x- and y-wise; for now, we're screwed.
			utils.error(
				"Oh dear: the segmentation algorithm can't cope with holes that overlap "
				'both x- and y-wise!')
	splitWallCoreLevel = splitWallCoreLevel - 1
	return parts


def qsortHoles(list):
	"""adapted from http://en.literateprograms.org/Quicksort_(Python)#Using_list_comprehensions"""  # noqa E501
	if list == []:
		return []
	else:
		pivot = list[0]
		lesser = qsortHoles([x for x in list[1:] if x.origin.x < pivot.origin.x])
		greater = qsortHoles([x for x in list[1:] if x.origin.x >= pivot.origin.x])
		return lesser + [pivot] + greater
