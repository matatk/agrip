"""AudioQuake Game Launcher - Main launcher window"""
from os import path

import wx

from launcherlib.game_controller import GameController
from launcherlib.ui.helpers import add_opener_buttons, add_widget, Warn
from launcherlib.ui.tabs.play import PlayTab
from launcherlib.ui.tabs.customise import CustomiseTab
from launcherlib.ui.tabs.mod import ModTab
from launcherlib.ui.tabs.map import MapTab


class LauncherWindow(wx.Frame):
	def __init__(self, parent, title):
		wx.Frame.__init__(self, parent, title=title)

		panel = wx.Panel(self)
		root_vbox = wx.BoxSizer(wx.VERTICAL)
		child_hbox = wx.BoxSizer(wx.HORIZONTAL)

		game_controller = GameController(lambda message: Warn(self, message))

		# Tabs

		notebook = wx.Notebook(panel)

		tab_play = PlayTab(notebook, game_controller)
		tab_customise = CustomiseTab(notebook)
		tab_mod = ModTab(notebook, game_controller)
		tab_map = MapTab(notebook, game_controller)

		notebook.AddPage(tab_play, "Play")
		notebook.AddPage(tab_customise, "Customise")
		notebook.AddPage(tab_mod, "Mod")
		notebook.AddPage(tab_map, "Map")

		root_vbox.Add(notebook, 1, wx.EXPAND)

		# Buttons

		add_opener_buttons(panel, child_hbox, {
			'README': path.join('manuals', 'README.html'),
			'LICENCE': path.join('manuals', 'LICENCE.html'),
		})

		btn_quit = wx.Button(panel, -1, "Quit launcher")

		def quit_it(event):
			if game_controller.quit():
				self.Close()
			else:
				Warn(self, "Can't quit whilst Quake is still running.")

		btn_quit.Bind(wx.EVT_BUTTON, quit_it)
		add_widget(child_hbox, btn_quit)

		# Wiring

		root_vbox.Add(child_hbox, 0, wx.ALL | wx.ALIGN_RIGHT, -1)
		panel.SetSizer(root_vbox)
		root_vbox.SetSizeHints(self)  # doesn't seem to be needed?
