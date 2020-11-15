"""AudioQuake & LDL Launcher - Main launcher window"""
import sys

import wx

from buildlib import doset, doset_only

from launcherlib.game_controller import GameController
from launcherlib.ui.helpers import Warn, error_hook
from launcherlib.ui.tabs.play import PlayTab
from launcherlib.ui.tabs.help import HelpTab
from launcherlib.ui.tabs.customise import CustomiseTab
from launcherlib.ui.tabs.mod import ModTab
from launcherlib.ui.tabs.map import MapTab


class LauncherWindow(wx.Frame):
	def __init__(self, parent, title):
		wx.Frame.__init__(self, parent, title=title)

		game_controller = GameController(lambda: error_hook(*sys.exc_info()))

		sizer = wx.BoxSizer(wx.VERTICAL)

		notebook = doset(
			mac=lambda: wx.Notebook(self),
			windows=lambda: wx.Listbook(self))

		tab_play = PlayTab(notebook, game_controller)
		tab_help = HelpTab(notebook)
		tab_customise = CustomiseTab(notebook)
		tab_mod = ModTab(notebook, game_controller)
		tab_map = MapTab(notebook, game_controller)

		notebook.AddPage(tab_play, "Play")
		notebook.AddPage(tab_help, "Help")
		notebook.AddPage(tab_customise, "Customise")
		notebook.AddPage(tab_mod, "Mod")
		notebook.AddPage(tab_map, "Map")

		sizer.Add(notebook, 1, wx.EXPAND)
		sizer.SetSizeHints(self)  # doesn't seem to be needed?
		self.SetSizer(sizer)

		def set_up_menu_bar():
			menubar = wx.MenuBar()
			wx.MenuBar.MacSetCommonMenuBar(menubar)

		doset_only(mac=set_up_menu_bar)

		# TODO: If Quit on the Menu Bar is used and the engine is running, the
		# app gets the beachball until the engine is quat and then it quits.
		# Sounds like the only solution is to somehow quit Quake.
		def OnClose(event):
			if game_controller.quit():
				self.Destroy()
			else:
				if event.CanVeto():
					event.Veto()
					Warn(self, "Can't quit whilst Quake is still running.")
				else:
					self.Destroy()  # has no effect as Quake still running

		self.Bind(wx.EVT_CLOSE, OnClose)
