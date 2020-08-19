"""AudioQuake Game Launcher - Play tab"""
import wx

from launcherlib.ui.helpers import add_launch_button, add_opener_buttons
from launcherlib.utils import on_windows


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

		if on_windows():
			# FIXME use a function to set the value, give the function options
			server = 'zqds.exe'
			rcon = 'rcon.exe'
		else:
			server = './start-server.command'
			rcon = './start-rcon.command'

		add_opener_buttons(self, sizer, {
			"Dedicated server": server,
			"Remote console": rcon,
		})

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
