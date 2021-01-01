"""AudioQuake & LDL Launcher - Play tab"""
try:
	from subprocess import run, CalledProcessError, CREATE_NEW_CONSOLE
except ImportError:
	pass

import wx

from buildlib import doset
from launcherlib import dirs
from launcherlib.ui.helpers import add_widget, launch_core, Warn


#
# Console program starter helpers
#

def start_server_mac(event):
	zqds = dirs.engines / 'zqds'
	basedir = dirs.data
	run_apple_script(f'{zqds} -basedir {basedir} -game id1')


def run_apple_script(command):
	script = f'tell application "Terminal" to activate do script "{command}"'
	args = ['osascript', '-e', script]
	try:
		run(args, check=True)
	except CalledProcessError:
		Warn(None, (
			'The dedicated server and remote console are text-mode programs. '
			'In order to run them, the AudioQuake & LDL launcher needs access '
			'to automate the Terminal app.\n\n'

			'You can grant this permission in System Preferences > Security & '
			'Privacy > Privacy tab. Go to "Automation" in the list of '
			'permissions, then find "AudioQuake" in the list of applications, '
			'and be sure to select the "Terminal" checkbox.'))


def run_win_console(prog):
	run(prog, creationflags=CREATE_NEW_CONSOLE)


#
# Helpers
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


#
# The main event
#

class PlayTab(wx.Panel):
	def __init__(self, parent, game_controller):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

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

		server_stuff = {
			"Dedicated server": doset(
				mac=start_server_mac,
				windows=lambda evt: run_win_console(dirs.gubbings / 'rcon.exe'),
				set_only=True),
			"Remote console": doset(
				mac=lambda evt: run_apple_script(dirs.gubbins / 'rcon'),
				windows=lambda evt: run_win_console(dirs.engines / 'zqds.exe'),
				set_only=True)
		}

		for title, action in server_stuff.items():
			add_cli_tool_button(self, sizer, title, action)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
