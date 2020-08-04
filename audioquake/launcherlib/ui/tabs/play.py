"""AudioQuake Game Launcher - Play tab"""
from os import path

import wx

from launcherlib.ui.helpers import \
	add_launch_button, add_opener_buttons, add_widget
from launcherlib.game_controller import on_windows


class PlayTab(wx.Panel):
	def __init__(self, parent, game_controller):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		# Launching the game

		play = wx.StaticBoxSizer(wx.VERTICAL, self, "Play")

		game_modes = {
			"Play Quake": game_controller.launch_default,
			"Play Open Quartz": game_controller.launch_open_quartz,
			"Tutorial": game_controller.launch_tutorial,
		}

		for title, action in game_modes.items():
			add_launch_button(self, play, title, action)

		if on_windows():
			# FIXME use a function to set the value, give the function options
			server = 'zqds.exe'
			rcon = 'rcon.exe'
		else:
			server = './start-server.command'
			rcon = './start-rcon.command'

		add_opener_buttons(self, play, {
			"Dedicated server": server,
			"Remote console": rcon,
		})

		add_widget(sizer, play)

		# Help

		docs = wx.StaticBoxSizer(wx.VERTICAL, self, "Help")

		add_opener_buttons(self, docs, {
			'User manual': path.join('manuals', 'user-manual.html'),
			'Sound legend': path.join('manuals', 'sound-legend.html'),
		})

		add_widget(sizer, docs)

		# Wiring

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
