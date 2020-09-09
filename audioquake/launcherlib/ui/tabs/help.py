"""AudioQuake & LDL Launcher - Help tab"""
import wx

from launcherlib import dirs
from launcherlib.ui.helpers import add_opener_buttons


class HelpTab(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		add_opener_buttons(self, sizer, {
			'User manual': dirs.manuals / 'user-manual.html',
			'Sound legend': dirs.manuals / 'sound-legend.html',
			'README': dirs.manuals / 'README.html',
			'LICENCE': dirs.manuals / 'LICENCE.html'
		})

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
