"""AudioQuake & LDL Launcher - Help tab"""
import wx

from launcherlib import dirs
from launcherlib.ui.helpers import add_opener_buttons, about_page, add_widget


class HelpTab(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		add_opener_buttons(self, sizer, {
			'README': dirs.manuals / 'README.html',
			'User manual': dirs.manuals / 'user-manual.html',
			'Sound legend': dirs.manuals / 'sound-legend.html',
			'LICENCE': dirs.manuals / 'LICENCE.html'
		})

		about = wx.Button(self, -1, 'About')
		about.Bind(wx.EVT_BUTTON, lambda event: about_page(self))
		add_widget(sizer, about)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
