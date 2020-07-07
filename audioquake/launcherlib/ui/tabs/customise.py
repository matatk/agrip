"""AudioQuake Game Launcher - Customise tab"""
from os import path
import shutil

import wx

from launcherlib.ui.helpers import \
	add_opener_buttons, add_widget, pick_file, \
	Info, Warn, WarnException


class CustomiseTab(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		# Settings

		add_opener_buttons(self, sizer, {
			'Edit autoexec.cfg': (path.join('id1', 'autoexec.cfg'),),
			'Edit config.cfg': (path.join('id1', 'config.cfg'),),
		})

		# Install registered data

		reg_data_button = wx.Button(self, -1, 'Install registered Quake data')
		reg_data_button.Bind(wx.EVT_BUTTON, self.install_registered_data)
		add_widget(sizer, reg_data_button)

		# Wiring

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def edit_config(self, event):
		Info(self, 'edit config')

	def edit_autoexec(self, event):
		Info(self, 'edit autoexec')

	def install_registered_data(self, event):
		pak1path = path.join('id1', 'pak1.pak')
		Info(
			self, "If you have the registered Quake data file "
			+ "('pak1.pak'), please select it, and it will be copied to "
			+ "the AudioQuake directory.")
		if path.exists(pak1path):
			Info(self, 'pak1.pak is already installed')
		else:
			incoming = pick_file(self, "Select pak1.pak", "pak1.pak|*.pak")
			if incoming:
				if path.basename(incoming) == 'pak1.pak':
					try:
						shutil.copy(incoming, pak1path)
						Info(self, 'pak1.pak installed successfully')
					except:  # noqa E722
						WarnException(self)
				else:
					Warn(self, "You must select a file called 'pak1.pak'")
