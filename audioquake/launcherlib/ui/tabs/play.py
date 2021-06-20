"""AudioQuake & LDL Launcher - Play tab"""
from platform import system

if system() == 'Darwin':
	from subprocess import run, CalledProcessError
elif system() == 'Windows':
	import os
else:
	raise NotImplementedError

import wx
import wx.html2

from buildlib import doset
from launcherlib import dirs
from launcherlib.utils import have_registered_data, format_bindings_as_html
from launcherlib.ui.helpers import add_widget, launch_core, \
	Error, HOW_TO_INSTALL, modal_html_page


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
	args = [str(x) for x in prog]
	command = ' '.join(args)
	os.system(f'start cmd /k {command}')


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


#
# The main event
#

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

		keys_button = wx.Button(self, -1, 'List key bindings')

		def show_bindings(event):
			bindings_html = format_bindings_as_html()
			modal_html_page(self, 'Key bindings', bindings_html)

		keys_button.Bind(wx.EVT_BUTTON, show_bindings)
		add_widget(sizer, keys_button)

		# Server stuff

		add_widget(sizer, wx.StaticLine(self, -1))

		server_stuff = {
			"Dedicated server": doset(
				mac=start_server_mac,
				windows=start_server_windows,
				set_only=True),
			"Remote console": doset(
				mac=lambda evt: run_apple_script(dirs.gubbins / 'rcon'),
				windows=lambda evt: run_win_console([dirs.gubbins / 'rcon.exe']),
				set_only=True)
		}

		for title, action in server_stuff.items():
			add_cli_tool_button(self, sizer, title, action)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
