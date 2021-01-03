"""AudioQuake & LDL Launcher - Customise tab"""
# FIXME: enforce min and max resolutions
from buildlib import doset
import launcherlib.config as config

RESOLUTIONS = [
	'320x200 (16:10)',
	'320x240 (4:3)',
	'640x400 (16:10)',  # Default on macOS
	'848x477 (16:9)',
	'640x480 (4:3)',    # Default on Windows
	'768x480 (16:10)',
	'864x486 (16:9)',
	'720x540 (4:3)',
	'864x540 (16:10)',
	'960x540 (16:9)',
	'800x600 (4:3)',
	'1152x720 (16:10)',
	'1280x720 (16:9)',
	'1024x768 (4:3)',
	'1600x900 (16:9)',
	'1600x1000 (16:10)',
	'1440x1080 (4:3)',
	'1728x1080 (16:10)',
	'1920x1080 (16:9)']

DEFAULT_RESOLUTION_INDEX = doset(mac=2, windows=4)

RESOLUTIONS[DEFAULT_RESOLUTION_INDEX] += ' [default]'


def width_and_height(resolution_string):
	"""Given a string, extract the width and height of the corresponding
	resolution

	Raises ValueError if the string doesn't describe a resolution"""
	if ' ' in resolution_string:
		dimensions = resolution_string.split(' ')[0]
	else:
		dimensions = resolution_string
	xstr, ystr = dimensions.split('x')  # may raise ValueError
	return xstr, ystr


DEFAULT_WIDTH, DEFAULT_HEIGHT = \
	width_and_height(RESOLUTIONS[DEFAULT_RESOLUTION_INDEX])


def resolution_index_and_size(partial_resolution_string):
	"""Given a resolution string, find the index of the matching preset
	resolution, if it exists

	Returns
		(index,    x,    y)  if the string matches a preset resolution
		(   -1,    x,    y)  if the string's resolution doesn't match a preset
		(   -2, None, None)  if the string's resolution is invalid"""
	try:
		given_xstr, given_ystr = width_and_height(partial_resolution_string)
	except ValueError:
		return -2, None, None

	for index, resolution_string in enumerate(RESOLUTIONS):
		res_xstr, res_ystr = width_and_height(resolution_string)
		if given_xstr == res_xstr and given_ystr == res_ystr:
			return index, given_xstr, given_ystr

	return -1, given_xstr, given_ystr


def resolution_details_from_config():
	"""Gets and updates info about the resolution string stored in the
	launcher's INI file.

	If the resolution is valid syntactically, works out if it's one of the
	preset ones and finds its index if so.

	Also finds the x and y sizes of the resultion.

	If the resolution in the INI file is not syntactically correct, replace it
	with the default resolution string for the current platform, then return
	the info on the default resolution.

	Returns
		index     - int/None depending on whether the current res is a preset
		x         - width of current resolution
		y         - height of current resolution
		was_valid - Whether the INI file res was syntactically correct."""
	index, x, y = resolution_index_and_size(config.resolution())
	if index >= 0:
		return index, x, y, True
	elif index == -1:
		return None, x, y, True
	else:
		config.resolution(RESOLUTIONS[DEFAULT_RESOLUTION_INDEX])
		return DEFAULT_RESOLUTION_INDEX, DEFAULT_WIDTH, DEFAULT_HEIGHT, False


def resolution_index_from_config():
	index, _, _, was_valid = resolution_details_from_config()
	return index, was_valid


def resolution_size_from_config():
	_, x, y, was_valid = resolution_details_from_config()
	return x, y, was_valid
