"""AudioQuake Game Launcher - Customise tab"""
from os import path

import wx

from launcherlib.utils import have_registered_data
from launcherlib.ui.helpers import \
	add_opener_buttons, add_widget, pick_directory, \
	Info, Error, ErrorException
from launcherlib.ui.munging import copy_paks_and_create_textures_wad


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
		if have_registered_data():  # FIXME what if something else is missing?
			Info(self, 'The registered data files are already installed.')
		else:
			Info(self, (
				"If you've bought Quake, please select the folder where the "
				"registered Quake data files are. They'll be copied to the "
				'AudioQuake folder. Then the textures will be extracted, so '
				'you can use them in your own maps.'))
			incoming = pick_directory(
				self, "Select folder containing pak0.pak and pak1.pak")
			if incoming:
				incoming_pak0 = path.join(incoming, 'pak0.pak')
				incoming_pak1 = path.join(incoming, 'pak1.pak')
				if path.isfile(incoming_pak0) and path.isfile(incoming_pak1):
					try:
						progress = wx.ProgressDialog(
							'Installation', '', parent=self,
							style=wx.PD_APP_MODAL | wx.PD_AUTO_HIDE)
						copy_paks_and_create_textures_wad(
							progress, incoming_pak0, incoming_pak1)
						Info(self, 'Installation complete.')
					except:  # noqa E722
						ErrorException(self)
					finally:
						progress.Destroy()
				else:
					Error(self, (
						'One or both of the registered data files could '
						'not be found in the chosen directory.'))
