"""AudioQuake Game Launcher - Help tab"""
from os import path

import wx

from launcherlib.ui.helpers import add_opener_buttons


class HelpTab(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		add_opener_buttons(self, sizer, {
			'User manual': path.join('manuals', 'user-manual.html'),
			'Sound legend': path.join('manuals', 'sound-legend.html'),
			'README': path.join('manuals', 'README.html'),
			'LICENCE': path.join('manuals', 'LICENCE.html')
		})

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
