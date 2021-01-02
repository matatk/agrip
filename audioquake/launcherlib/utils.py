"""AudioQuake & LDL Launcher - Utilities"""
import enum
from subprocess import check_call
from traceback import format_exception_only, format_tb

try:
	from os import startfile
except ImportError:
	pass

from buildlib import doset
from launcherlib import dirs


class LaunchState(enum.Enum):
	LAUNCHED = enum.auto()
	NOT_FOUND = enum.auto()
	ALREADY_RUNNING = enum.auto()
	NO_REGISTERED_DATA = enum.auto()


class InvalidResolutionError(Exception):
	pass


def width_and_height(resolution_name):
	if ' ' in resolution_name:
		dimensions = resolution_name.split(' ')[0]
	else:
		dimensions = resolution_name
	try:
		xstr, ystr = dimensions.split('x')
	except ValueError:
		raise InvalidResolutionError(
			f'Invalid screen resolution "{resolution_name}" - if you manually '
			'edited audioquake.ini please check it is correct. To fix this you '
			'can choose a preset screen resolution in the Customise tab.')
	return xstr, ystr


def opener(openee):
	doset(
		mac=lambda: check_call(['open', openee]),
		windows=lambda: startfile(openee))


def have_registered_data():
	pak0path = dirs.data / 'id1' / 'pak0.pak'
	pak1path = dirs.data / 'id1' / 'pak1.pak'
	return pak0path.is_file() and pak1path.is_file()


def error_message_and_title(etype, value, traceback):
	exception_info = format_exception_only(etype, value)
	trace_info = format_tb(traceback)
	please_report = (
		'Please report this error, with the following details, at '
		'https://github.com/matatk/agrip/issues/new - thanks!\n\n')
	if etype is InvalidResolutionError:
		message = value
		title = 'Whoops, apocalypse'
	else:
		message = "".join(
			[please_report] + exception_info + ['\n'] + trace_info)
		title = 'Unanticipated error (launcher bug)'
	return message, title
