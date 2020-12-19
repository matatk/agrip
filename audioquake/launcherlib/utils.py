"""AudioQuake & LDL Launcher - Utilities"""
from subprocess import check_call
from sys import exc_info
from traceback import format_exception_only, format_tb

from platform import system
if system() == 'Windows':
	from os import startfile

from buildlib import doset
from launcherlib import dirs


def opener(openee):
	doset(
		mac=lambda: check_call(['open', openee]),
		windows=lambda: startfile(openee))


def have_registered_data():
	pak0path = dirs.data / 'id1' / 'pak0.pak'
	pak1path = dirs.data / 'id1' / 'pak1.pak'
	return pak0path.is_file() and pak1path.is_file()


def error_message_and_title():
	etype, value, trace = exc_info()
	exception_info = format_exception_only(etype, value)
	trace_info = format_tb(trace)
	please_report = (
		'Please report this error, with the following details, at '
		'https://github.com/matatk/agrip/issues/new - thanks!\n\n')
	message = "".join(
		[please_report] + exception_info + ['\n'] + trace_info)
	return (message, 'Unanticipated error (launcher bug)')
