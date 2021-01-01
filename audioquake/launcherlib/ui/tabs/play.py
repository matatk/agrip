"""AudioQuake & LDL Launcher - Play tab"""
try:
	from subprocess import run, CREATE_NEW_CONSOLE
except ImportError:
	pass

import wx

from buildlib import doset
from launcherlib import dirs
from launcherlib.ui.helpers import add_widget, launch_core


#
# Mac server/rcon starters
#

def start_server_mac(event):
	zqds = dirs.engines / 'zqds'
	basedir = dirs.data
	run_via_apple_script(f'{zqds} -basedir {basedir} -game id1')


def start_rcon_mac(event):
	run_via_apple_script(dirs.gubbins / 'rcon')


def run_via_apple_script(command):
	script = f'tell application "Terminal" to activate do script "{command}"'
	args = ['osascript', '-e', script]
	run(args)


#
# Windows server/rcon starters
#

def start_in_console(prog):
	run(prog, creationflags=CREATE_NEW_CONSOLE)


def start_server_windows(event):
	start_in_console(dirs.engines / 'zqds.exe')


def start_rcon_windows(event):
	start_in_console(dirs.gubbings / 'rcon.exe')


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
				mac=start_server_mac, windows=start_rcon_windows, set_only=True),
			"Remote console": doset(
				mac=start_rcon_mac, windows=start_rcon_windows, set_only=True)
		}

		for title, action in server_stuff.items():
			add_cli_tool_button(self, sizer, title, action)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
