"""AudioQuake & LDL Launcher - Play tab"""
try:
	from subprocess import run, CalledProcessError, CREATE_NEW_CONSOLE
except ImportError:
	pass

import wx
import wx.html2

from buildlib import doset, doset_only
from launcherlib import dirs
from launcherlib.utils import have_registered_data, format_bindings_as_html
from launcherlib.ui.helpers import add_widget, launch_core, \
	Error, HOW_TO_INSTALL


#
# Console program starter helpers
#

def registered_check():
	if not have_registered_data():
		Error(None, (
			'You must have the registered version of Quake in order to run '
			'a server that uses custom maps.\n\n' + HOW_TO_INSTALL))
		return False
	return True


def start_server_mac(event):
	if registered_check():
		zqds = dirs.engines / 'zqds'
		run_apple_script(f'{zqds} -basedir {dirs.data} -game id1')


def run_apple_script(command):
	script = f'tell application "Terminal" to activate do script "{command}"'
	args = ['osascript', '-e', script]
	try:
		run(args, check=True)
	except CalledProcessError:
		Error(None, (
			'The dedicated server and remote console are text-mode programs. '
			'In order to run them, the AudioQuake & LDL launcher needs access '
			'to automate the Terminal app.\n\n'

			'You can grant this permission in System Preferences > Security & '
			'Privacy > Privacy tab. Go to "Automation" in the list of '
			'permissions, then find "AudioQuake" in the list of applications, '
			'and be sure to select the "Terminal" checkbox.'))


def start_server_windows(event):
	if registered_check():
		run_win_console([dirs.engines / 'zqds.exe', '-basedir', dirs.data])


def run_win_console(prog):
	run(prog, creationflags=CREATE_NEW_CONSOLE)


#
# General helpers
#

def add_launch_button(parent, sizer, title, action):
	button = wx.Button(parent, -1, title)

	def make_launch_function(game_start_method):
		def launch_handler(event):
			launch_core(parent, game_start_method)
		return launch_handler

	button.Bind(wx.EVT_BUTTON, make_launch_function(action))
	add_widget(sizer, button)


def add_cli_tool_button(parent, sizer, title, action):
	button = wx.Button(parent, -1, title)
	button.Bind(wx.EVT_BUTTON, action)
	add_widget(sizer, button)


def windows_accessibility_fix(browser):
	robot = wx.UIActionSimulator()
	browser.SetFocus()
	position = browser.GetPosition()
	position = browser.ClientToScreen(position)
	robot.MouseMove(position)
	robot.MouseClick()


#
# The main event
#

class KeyBindingsView(wx.Dialog):
	def __init__(self, parent):
		screen_width, screen_height = wx.GetDisplaySize()

		wx.Dialog.__init__(
			self, parent, style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER,
			size=(screen_width * 0.5, screen_height * 0.7),
			title='Key bindings')
		sizer = wx.BoxSizer(wx.VERTICAL)

		browser = wx.html2.WebView.New(self)
		display = format_bindings_as_html()
		browser.SetPage(display, "")
		sizer.Add(browser, 1, wx.EXPAND, 10)

		close = wx.Button(self, -1, 'Close')
		close.Bind(wx.EVT_BUTTON, lambda event: self.Destroy())
		add_widget(sizer, close)

		self.SetSizer(sizer)

		doset_only(windows=lambda: windows_accessibility_fix(browser))


class PlayTab(wx.Panel):
	def __init__(self, parent, game_controller):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		# Playing the game

		game_modes = {
			"Play Quake": game_controller.launch_quake,
			"Play Open Quartz": game_controller.launch_open_quartz,
			"Tutorial":
				lambda: game_controller.launch_tutorial(high_contrast=False),
			"Tutorial (high-contrast maps)":
				lambda: game_controller.launch_tutorial(high_contrast=True)
		}

		for title, action in game_modes.items():
			add_launch_button(self, sizer, title, action)

		# Listing key bindings

		add_widget(sizer, wx.StaticLine(self, -1))

		bindings = wx.Button(self, -1, 'List key bindings')

		def bindings_window(event):
			KeyBindingsView(self).Show()

		bindings.Bind(wx.EVT_BUTTON, bindings_window)
		add_widget(sizer, bindings)

		# Server stuff

		add_widget(sizer, wx.StaticLine(self, -1))

		server_stuff = {
			"Dedicated server": doset(
				mac=start_server_mac,
				windows=start_server_windows,
				set_only=True),
			"Remote console": doset(
				mac=lambda evt: run_apple_script(dirs.gubbins / 'rcon'),
				windows=lambda evt: run_win_console(dirs.gubbins / 'rcon.exe'),
				set_only=True)
		}

		for title, action in server_stuff.items():
			add_cli_tool_button(self, sizer, title, action)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
