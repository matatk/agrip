"""AudioQuake Game Launcher"""
from os import path, chdir
import sys
import traceback

import wx

from launcherlib.config import init as init_config
from launcherlib.ui.launcher import LauncherWindow
from launcherlib.ui.helpers import MsgBox


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
	chdir(getattr(sys, '_MEIPASS', path.abspath(path.dirname(__file__))))
	init_config()
	LauncherWindow(None, "AudioQuake and LDL Launcher").Show()
	app.MainLoop()
