"""AudioQuake Game Launcher - Play tab"""
import wx

from buildlib import platform_set
from launcherlib.ui.helpers import add_launch_button, add_opener_buttons


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

		server = platform_set(
			mac='./start-server.command',
			windows='zqds.exe')

		rcon = platform_set(
			mac='./start-rcon.command',
			windows='rcon.exe')

		add_opener_buttons(self, sizer, {
			"Dedicated server": server,
			"Remote console": rcon,
		})

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
