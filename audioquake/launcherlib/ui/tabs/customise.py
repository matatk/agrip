"""AudioQuake Game Launcher - Customise tab"""
from os import path
import shutil

import wx

from launcherlib.utils import have_registered_data

from launcherlib.ui.helpers import \
	add_opener_buttons, add_widget, pick_directory, \
	Info, Error, ErrorException


class CustomiseTab(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		# Settings

		add_opener_buttons(self, sizer, {
			'Edit autoexec.cfg': path.join('id1', 'autoexec.cfg'),
			'Edit config.cfg': path.join('id1', 'config.cfg'),
		})

		# Install registered data

		reg_data_button = wx.Button(self, -1, 'Install registered Quake data')
		reg_data_button.Bind(wx.EVT_BUTTON, self.install_registered_data)
		add_widget(sizer, reg_data_button)

		# Wiring

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def install_registered_data(self, event):
		if have_registered_data():
			Info(self, 'The registered data files are already installed.')
		else:
			incoming = pick_directory(
				self, "Select folder containing pak0.pak and pak1.pak")
			if incoming:
				incoming_pak0 = path.join(incoming, 'pak0.pak')
				incoming_pak1 = path.join(incoming, 'pak1.pak')
				if path.isfile(incoming_pak0) and path.isfile(incoming_pak1):
					try:
						shutil.copy(incoming_pak0, 'id1')
						shutil.copy(incoming_pak1, 'id1')
						Info(self, 'Registered data installed.')
					except:  # noqa E722
						ErrorException(self)
				else:
					Error(
						self,
						"One or both of the registered data files could "
						+ "not be found in the chosen directory.")
