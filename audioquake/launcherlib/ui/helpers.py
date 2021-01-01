"""AudioQuake & LDL Launcher - GUI helpers"""
import shutil

import wx

from buildlib import doset_only
import launcherlib.config as config
from launcherlib import dirs
from launcherlib.game_controller import LaunchState
from launcherlib.utils import opener, error_message_and_title

BORDER_SIZE = 5

HOW_TO_INSTALL = (
	'If you bought Quake, you can install the registered data - '
	'check out the "Customise" tab.')

launch_messages = {
	LaunchState.NOT_FOUND: 'Engine not found.',
	LaunchState.ALREADY_RUNNING: 'The game is already running.',
	LaunchState.NO_REGISTERED_DATA: (
		'Registered Quake data not found.\n\n' + HOW_TO_INSTALL + '\n\nYou can play Open Quartz without the registered version of Quake.')
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


def YesNoWithTitle(parent, title, body):
	return MsgBox(parent, body, title, wx.ICON_QUESTION, wx.YES_NO)


def MsgBox(parent, message, caption, icon, style=wx.OK):
	return wx.MessageDialog(parent, message, caption, style | icon).ShowModal()


# FIXME: need to apply to mod loading for the first time (already done?)
def first_time_windows_prompt(parent):
	prompt = (
		'When you run the game for the first time, Windows '
		'may ask you to allow it through the firewall.\n\n'

		'This will be done in a secure window that pops up '
		'above the Quake engine, which you will need to use ALT-TAB '
		'and an Assistive Technology to access.\n\n'

		# FIXME: do this somewhere else?
		'Please also note that the server output window, and '
		'the remote console facility, are not self-voicing; they are text-mode programs and will run in a terminal window.')
	Warn(parent, prompt)


def _update_oq_configs():
	for config_file in ['autoexec.cfg', 'config.cfg']:
		id1_file = dirs.data / 'id1' / config_file
		oq_file = dirs.data / 'oq' / config_file
		if id1_file.stat().st_mtime > oq_file.stat().st_mtime:
			shutil.copy(id1_file, oq_file)


def launch_core(parent, method):
	if config.first_game_run():
		doset_only(windows=lambda: first_time_windows_prompt(parent))

	_update_oq_configs()

	launch_state = method()
	if launch_state is LaunchState.LAUNCHED:
		config.first_game_run(False)
	else:
		Error(parent, launch_messages[launch_state])


def gui_error_hook(etype, value, traceback):
	message, title = error_message_and_title(etype, value, traceback)
	MsgBox(None, message, title, wx.ICON_ERROR)
