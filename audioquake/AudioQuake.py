"""AudioQuake & LDL Launcher"""
import sys
import traceback

import wx

from buildlib import doset_only
from launcherlib.config import init as init_config
import launcherlib.dirs as dirs
from launcherlib.ui.launcher import LauncherWindow
from launcherlib.ui.helpers import MsgBox, Warn


def error_hook(etype, value, trace):
	# TODO focus goes to the OK button :-S.
	exception_info = traceback.format_exception_only(etype, value)
	trace_info = traceback.format_tb(trace)
	please_report = (
		'Please report this error, with the following details, at '
		'https://github.com/matatk/agrip/issues/new - thanks!\n\n')
	message = "".join(
		[please_report] + exception_info + ['\n'] + trace_info)
	MsgBox(None, message, 'Unanticipated error (launcher bug)', wx.ICON_ERROR)


if __name__ == '__main__':
	app = wx.App()
	sys.excepthook = error_hook

	try:
		init_config(dirs.root)
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
