"""AudioQuake & LDL Launcher"""
import sys

import wx

from buildlib import doset_only
from launcherlib.config import init as init_config
import launcherlib.dirs as dirs
from launcherlib.ui.launcher import LauncherWindow
from launcherlib.ui.helpers import Warn, error_hook


if __name__ == '__main__':
	app = wx.App()
	sys.excepthook = error_hook

	try:
		init_config(dirs.config)
		LauncherWindow(None, "AudioQuake & LDL Launcher").Show()
		app.MainLoop()
	except OSError:
		doset_only(mac=lambda: Warn(None, (
			'The code behind AudioQuake, Level Description Language and '
			"supporting tools is not signed, so it can't be verified by "
			'Apple.\n\n'

			'If you still want to run them, move this application somewhere '
			'else on your computer and re-open it.\n\n'

			"If you've already done that, you may need to grant permission "
			'for the application to access certain folders, in System '
			'Preferences > Security & Privacy > Privacy tab.')))
