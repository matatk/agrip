"""AudioQuake & LDL Launcher - GUI helpers"""
import shutil
import sys
import traceback

import wx

from buildlib import doset_only
import launcherlib.config as config
from launcherlib import dirs
from launcherlib.game_controller import LaunchState
from launcherlib.utils import opener

BORDER_SIZE = 5

HOW_TO_INSTALL = (
	'If you bought Quake, you can install the registered data - '
	'check out the "Customise" tab.')

launch_messages = {
	LaunchState.NOT_FOUND: 'Engine not found.',
	LaunchState.ALREADY_RUNNING: 'The game is already running.',
	LaunchState.NO_REGISTERED_DATA: (
		'Registered Quake data not found. ' + HOW_TO_INSTALL)
}


def pick_file(parent, message, wildcard):
	return _pick_core(
		lambda: wx.FileDialog(
			parent, message, wildcard=wildcard,
			style=wx.FD_OPEN | wx.FD_FILE_MUST_EXIST))


def pick_directory(parent, message):
	return _pick_core(
		lambda: wx.DirDialog(parent, message, style=wx.DD_DIR_MUST_EXIST))


def _pick_core(picker_func):
	picker = picker_func()

	if picker.ShowModal() == wx.ID_CANCEL:
		return

	return picker.GetPath()


def add_launch_button(parent, sizer, title, action):
	button = wx.Button(parent, -1, title)

	def make_launch_function(game_start_method):
		def launch_handler(event):
			launch_core(parent, game_start_method)
		return launch_handler

	# FIXME server and rcon don't return LaunchStatusy thingies

	button.Bind(wx.EVT_BUTTON, make_launch_function(action))
	add_widget(sizer, button)


def add_opener_buttons(parent, sizer, things_to_open):
	for title, thing in things_to_open.items():
		add_opener_button(parent, sizer, title, thing)


def add_opener_button(parent, sizer, title, thing_to_open):
	button = wx.Button(parent, -1, title)

	def make_open_function(openee):
		def open_thing_handler(event):
			opener(openee)
		return open_thing_handler

	button.Bind(wx.EVT_BUTTON, make_open_function(thing_to_open))
	add_widget(sizer, button)


def add_widget(sizer, widget, border=True, expand=True):
	expand_flag = wx.EXPAND if expand else 0
	border_flag = wx.ALL if border else 0
	border_size = BORDER_SIZE if border else 0
	sizer.Add(widget, 0, expand_flag | border_flag, border_size)


def Info(parent, message):
	MsgBox(parent, message, 'Info', wx.ICON_INFORMATION)


def Warn(parent, message):
	MsgBox(parent, message, 'Warning', wx.ICON_WARNING)


def Error(parent, message):
	MsgBox(parent, message, 'Error', wx.ICON_ERROR)


def ErrorException(parent):
	Error(parent, str(sys.exc_info()[1]))


def YesNoWithTitle(parent, title, body):
	return MsgBox(parent, body, title, wx.ICON_QUESTION, wx.YES_NO)


def MsgBox(parent, message, caption, icon, style=wx.OK):
	return wx.MessageDialog(parent, message, caption, style | icon).ShowModal()


def first_time_check(parent):
	# TODO need to apply to mod loading for the first time (already done?)
	prompt = (
		'When you run the game for the first time, Windows '
		'may ask you to allow it through the firewall.\n\n'

		'This will be done in a secure window that pops up'
		'above the Quake engine, which you will need to use ALT-TAB'
		'and an Assistive Technology to access.\n\n'

		'Please also note that the server output window, and'
		'the remote console facility, are not self-voicing.')

	if config.first_game_run():
		Warn(parent, prompt)
		config.first_game_run(False)


def _update_oq_configs():
	for config_file in ['autoexec.cfg', 'config.cfg']:
		id1_file = dirs.data / 'id1' / config_file
		oq_file = dirs.data / 'oq' / config_file
		if id1_file.stat().st_mtime > oq_file.stat().st_mtime:
			shutil.copy(id1_file, oq_file)


def launch_core(parent, method):
	doset_only(windows=lambda: first_time_check(parent))
	_update_oq_configs()
	launch_state = method()
	if launch_state is not LaunchState.LAUNCHED:
		Warn(parent, launch_messages[launch_state])


def error_hook(etype, value, trace):
	# TODO focus goes to the OK button :-S.
	exception_info = traceback.format_exception_only(etype, value)
	trace_info = traceback.format_tb(trace)
	please_report = (
		'Please report this error, with the following details, at '
		'https://github.com/matatk/agrip/issues/new - thanks!\n\n')
	message = "".join(
		[please_report] + exception_info + ['\n'] + trace_info)
	MsgBox(None, message, 'Unanticipated error (launcher bug)', wx.ICON_ERROR)
