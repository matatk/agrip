"""AudioQuake Game Launcher"""
import sys
from os import path, chdir

import wx

from launcherlib.ui.launcher import LauncherWindow

if __name__ == '__main__':
	app = wx.App()
	chdir(getattr(sys, '_MEIPASS', path.abspath(path.dirname(__file__))))
	LauncherWindow(None, "AudioQuake Launcher").Show()
	app.MainLoop()
