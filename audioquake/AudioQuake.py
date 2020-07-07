"""AudioQuake Game Launcher"""
import sys
from os import path, chdir

import wx

from launcherlib.game_controller import GameController
from launcherlib.ui.launcher import LauncherWindow

if __name__ == '__main__':
	app = wx.App()
	chdir(getattr(sys, '_MEIPASS', path.abspath(path.dirname(__file__))))
	LauncherWindow(None, "AudioQuake Launcher", GameController()).Show()
	app.MainLoop()
