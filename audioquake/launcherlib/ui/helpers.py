"""AudioQuake & LDL Launcher - GUI helpers"""
import shutil

import wx

from buildlib import doset_only, doset
import launcherlib.config as config
from launcherlib import dirs
from launcherlib.utils import opener, error_message_and_title, LaunchState, \
	html_template
from release import version_string, release_name

BORDER_SIZE = 5
GAP_BETWIXT_ASSOCIATED_CONTROLS = 5

HOW_TO_INSTALL = (
	'If you bought Quake, you can install the registered data - '
	'check out the "Customise" tab.')

launch_messages = {
	LaunchState.NOT_FOUND: 'Engine not found.',
	LaunchState.ALREADY_RUNNING: 'The game is already running.',
	LaunchState.NO_REGISTERED_DATA: (
		'Registered Quake data not found.\n\n' + HOW_TO_INSTALL + '\n\n'
		'You can play Open Quartz without the registered version of Quake.')
}


class _HTMLPageDialog(wx.Dialog):
	def __init__(self, parent, title, html):
		screen_width, screen_height = wx.GetDisplaySize()

		wx.Dialog.__init__(
			self, parent, style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER,
			size=(
				min(screen_width * 0.6, 1000),
				min(screen_height * 0.75, 703)),
			title=title)
		sizer = wx.BoxSizer(wx.VERTICAL)

		browser = wx.html2.WebView.New(self)
		browser.SetPage(html, "")
		sizer.Add(browser, 1, wx.EXPAND, 10)

		close = wx.Button(self, -1, 'Close')
		close.Bind(wx.EVT_BUTTON, lambda event: self.EndModal(wx.OK))
		add_widget(sizer, close)

		self.SetSizer(sizer)

		def windows_accessibility_fix():
			robot = wx.UIActionSimulator()
			browser.SetFocus()
			position = browser.GetPosition()
			position = browser.ClientToScreen(position)
			robot.MouseMove(position)
			robot.MouseClick()

		doset_only(windows=windows_accessibility_fix)


def modal_html_page(parent, title, html):
	with _HTMLPageDialog(parent, title, html) as dialog:
		dialog.ShowModal()


def about_page(parent):
	html = html_template(
		dirs.gubbins / 'about.html',
		version=version_string + ': ' + release_name)
	modal_html_page(
		parent, 'About AudioQuake & Level Description Language', html)


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


def add_widget(sizer, widget):
	sizer.Add(widget, 0, wx.EXPAND | wx.ALL, BORDER_SIZE)


def associate_controls(first, second, even_split=False):
	"""Place the label and control in a horizontal sizer to associate them.

	By default, the label will only take up as much space as it needs.

	Setting even_split to True makes each control take half of the available
	space."""
	sizer = wx.BoxSizer(wx.HORIZONTAL)

	first_flag = wx.EXPAND if even_split else wx.ALIGN_CENTER_VERTICAL
	first_proportion = 1 if even_split else 0
	sizer.Add(first, flag=first_flag, proportion=first_proportion)

	sizer.AddSpacer(GAP_BETWIXT_ASSOCIATED_CONTROLS)
	sizer.Add(second, flag=wx.EXPAND, proportion=1)
	return sizer


def platform_appropriate_grouping(parent, label):
	"""On macOS (Catalina and Big Sur) the focus order with VoiceOver is a bit
	weird with StaticBoxSizer labels coming after so many of the controls
	within. Therefore on macOS we'll just use a sizer and some text, but on
	Windows we can use a StaticBoxSizer."""

	def mac_gropuing():
		group = wx.BoxSizer(wx.VERTICAL)
		add_widget(group, wx.StaticText(
			parent, -1, label, style=wx.ALIGN_CENTRE_HORIZONTAL))
		return group

	return doset(
		mac=mac_gropuing,
		windows=wx.StaticBoxSizer(wx.VERTICAL, parent, label))


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
def first_time_windows_firewall_info(parent):
	if config.first_game_run():
		prompt = (
			'When you run the game for the first time, Windows may ask you '
			'to allow it through the firewall.\n\n'

			'This will be done in a secure window that pops up above the '
			'Quake engine or dedicated server terminal, which you will need '
			'to use ALT-TAB and an Assistive Technology to access.\n\n'

			'Please also note that the server output window, and the remote '
			'console, are not self-voicing; they are text-mode programs and '
			'will run in a terminal window.')
		Warn(parent, prompt)


def _update_oq_configs():
	for config_file in ['autoexec.cfg', 'config.cfg']:
		id1_file = dirs.data / 'id1' / config_file
		oq_file = dirs.data / 'oq' / config_file
		if id1_file.stat().st_mtime > oq_file.stat().st_mtime:
			shutil.copy(id1_file, oq_file)


def game_flickering_check(parent):
	if not config.warning_acknowledged_flickering():
		if does_user_confirm(
			parent,
			'Flickering warning',
			'Please note that Quake is a video game (this is not audio-only)\n'
			'and does include flickering lighting effects.'):
			config.warning_acknowledged_flickering(True)
		else:
			return False
	return True


def launch_core(parent, method):
	doset_only(windows=lambda: first_time_windows_firewall_info(parent))

	# FIXME: this should happen after registered check
	if not game_flickering_check(parent):
		return

	_update_oq_configs()

	launch_state = method()
	if launch_state is LaunchState.LAUNCHED:
		config.first_game_run(False)
	else:
		Error(parent, launch_messages[launch_state])


def gui_error_hook(etype, value, traceback):
	message, title = error_message_and_title(etype, value, traceback)
	MsgBox(None, message, title, wx.ICON_ERROR)


def does_user_confirm(parent, title, message):
	while True:
		dlg = wx.RichMessageDialog(
			parent,
			message,
			caption=title,
			style=wx.OK | wx.CANCEL | wx.CANCEL_DEFAULT | wx.ICON_WARNING)
		dlg.ShowCheckBox("Acknowledged; run the game.")
		if dlg.ShowModal() == wx.ID_OK:
			if dlg.IsCheckBoxChecked():
				return True
			else:
				wx.MessageDialog(
					parent, 'If you wish to continue running the game, please '
					'tick the box. You may also cancel running the game.', title
				).ShowModal()
		else:
			return False
