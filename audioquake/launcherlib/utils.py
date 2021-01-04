"""AudioQuake & LDL Launcher - Utilities"""
import enum
import re
from subprocess import check_call
from traceback import format_exception_only, format_tb

try:
	from os import startfile
except ImportError:
	pass

from buildlib import doset
from launcherlib import dirs
from launcherlib.game_controller.engine_wrapper import EngineWrapperError


class LaunchState(enum.Enum):
	LAUNCHED = enum.auto()
	NOT_FOUND = enum.auto()
	ALREADY_RUNNING = enum.auto()
	NO_REGISTERED_DATA = enum.auto()


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

	if etype is EngineWrapperError:
		stderr = str(value)
		if len(stderr) > 0:
			extra_info = f'ZQuake error info:\n{stderr}'
		else:
			extra_info = '(No further info available.)'
		message = (
			'This may be due to a screen mode being unavailable, in which '
			'case, please try choosing a different one.\n\nIf it relates to '
			'anything else, ' + please_report.lower() + extra_info)
		title = 'An error was reported by the ZQuake engine'
	else:
		message = "".join(
			[please_report] + exception_info + ['\n'] + trace_info)
		title = 'Unanticipated error (launcher bug)'

	return message, title


def get_bindings():
	config_keys = []

	standard_binding = re.compile(r'^bind (.+) "\+?(.+)"$')
	ignores = ['echo', 'screenshot', 'impulse', '`', 'MOUSE']

	with open(dirs.data / 'id1' / 'config.cfg', 'r') as cfg:
		key = {}
		for line in cfg.readlines():
			ignore = any(map(lambda term: term in line, ignores))
			if not ignore:
				if match := standard_binding.match(line):
					key['current'] = match.group(1)
					key['action'] = match.group(2)
					config_keys.append(key)
					key = {}

	autoexec_keys = []

	alias_binding = re.compile(r'^bind "(.+)" "aga_\w+"$')
	alias_default = re.compile(r'^// default key (?:to|for) (.+) is "(.+)"$')

	with open(dirs.data / 'id1' / 'autoexec.cfg', 'r') as cfg:
		key = {}
		for line in cfg.readlines():
			if match := alias_binding.match(line):
				key['current'] = match.group(1)
			elif match := alias_default.match(line):
				key['help'] = match.group(1)
				key['default'] = match.group(2)
				autoexec_keys.append(key)
				key = {}

	return config_keys, autoexec_keys


def format_bindings_as_text():
	config_keys, autoexec_keys = get_bindings()

	config_list = [f"{key['current']} {key['action']}" for key in config_keys]
	autoexec_list = [
		f"{key['current']} {key['help']} (default: {key['default']})"
		for key in autoexec_keys]

	return config_list, autoexec_list


def format_bindings_as_html():
	config_keys, autoexec_keys = get_bindings()

	html = '<!DOCTYPE html><head><style>\n' \
		+ 'table { border-collapse: collapse; }\n' \
		+ 'th, td { padding: 0.5em; border: 1px solid gray; }</style>\n' \
		+ '</head><body>\n' \
		+ '<h1>Key bindings</h1>' \
		+ '<p>This page shows your current key bindings. To change them, ' \
		+ 'check out the Customise tab, and the comments in the config files ' \
		+ 'as well as the user manual.\n' \
		+ '<h2>Basic movement and action keys</h2>\n'

	html += '<table><tr><th>Key</th><th>Action</th></tr>\n'
	for key in config_keys:
		html += f"<tr><td>{key['current']}</td><td>{key['action']}</td></tr>\n"
	html += '</table>\n'

	html += '<h2>Navigation helpers, devices, bots, messages and more</h2>\n'
	html += '<table><tr><th>Current</th><th>Action</th><th>Default</th></tr>\n'
	for key in autoexec_keys:
		html += (
			f"<tr><td>{key['current']}</td><td>{key['help']}</td>"
			f"<td>{key['default']}</td></tr>\n")
	html += '</table>\n'

	html += '</body></html>'
	return html
