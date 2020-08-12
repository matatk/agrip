"""AudioQuake Game Launcher - GUI helpers"""
from os import path
import shutil
import sys

import wx

from launcherlib.game_controller import LaunchState
from launcherlib.utils import on_windows, opener

BORDER_SIZE = 5

launch_messages = {
	LaunchState.NOT_FOUND: 'Engine not found',
	LaunchState.ALREADY_RUNNING: 'The game is already running',
	LaunchState.NO_REGISTERED_DATA: 'Registered Quake data not found'
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
		def launch(event):
			launch_core(parent, game_start_method)
		return launch

	# FIXME server and rcon don't return LaunchStatusy thingies

	button.Bind(wx.EVT_BUTTON, make_launch_function(action))
	add_widget(sizer, button)


def add_opener_buttons(parent, sizer, things_to_open):
	for title, thing in things_to_open.items():
		add_opener_button(parent, sizer, title, thing)


def add_opener_button(parent, sizer, title, thing_to_open):
	button = wx.Button(parent, -1, title)

	def make_open_function(openee):
		def open_thing(event):
			opener(openee)
		return open_thing

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


def stamp_file_check(parent, name):
	# TODO only 'game' seems to be used, not 'server'
	# TODO need to apply to mod loading for the first time
	# TODO better sense for filename would be nice
	stamp_file_name = 'not-first-run-' + name
	prompt = (
		'When you run the ' + name + ' for the first time, Windows '
		'may ask you to allow it through the firewall.')
	if name == 'game':
		prompt += (
			' This will be done in a secure window that pops up'
			' above the Quake engine, which you will need to use ALT-TAB'
			' and an Assistive Technology to access.')
	elif name == 'server':
		prompt += (
			' Please also note that the server output window, and'
			' the remote console facility, are not self-voicing.')
	else:
		raise TypeError

	if not path.exists(stamp_file_name):
		Warn(parent, prompt)
		open(stamp_file_name, 'a').close()


def first_time_check(parent, name):
	if on_windows():
		stamp_file_check(parent, name)
	else:
		pass


def _update_oq_configs():
	for config in ['autoexec.cfg', 'config.cfg']:
		id1_file = path.join('id1', config)
		oq_file = path.join('oq', config)
		if path.getmtime(id1_file) > path.getmtime(oq_file):
			shutil.copy(id1_file, oq_file)


def launch_core(parent, method):
	first_time_check(parent, 'game')
	_update_oq_configs()
	try:
		launch_state = method()
		if launch_state is not LaunchState.LAUNCHED:
			Warn(parent, launch_messages[launch_state])
	except:  # noqa E722
		ErrorException(parent)  # FIXME needed?
