"""AudioQuake & LDL Launcher - Help tab"""
import wx

from launcherlib import dirs
from launcherlib.ui.helpers import add_opener_buttons, about_page, add_widget


class HelpTab(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		add_opener_buttons(self, sizer, {
			'User manual': dirs.manuals / 'user-manual.html',
			'Sound legend': dirs.manuals / 'sound-legend.html',
		})

		add_widget(sizer, wx.StaticLine(self, -1))

		about = wx.Button(self, -1, 'About')
		about.Bind(wx.EVT_BUTTON, lambda event: about_page(self))
		add_widget(sizer, about)

		add_widget(sizer, wx.StaticLine(self, -1))

		add_opener_buttons(self, sizer, {
			'README': dirs.manuals / 'README.html',
			'LICENCE': dirs.manuals / 'LICENCE.html',
			'CHANGELOG': dirs.manuals / 'CHANGELOG.html',
			'ACKNOWLEDGEMENTS': dirs.manuals / 'ACKNOWLEDGEMENTS.html'
		})

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
