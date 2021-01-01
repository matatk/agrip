"""AudioQuake & LDL Launcher - Customise tab"""
from os import path

import wx

from launcherlib import dirs
import launcherlib.config as config
from launcherlib.utils import have_registered_data
from launcherlib.ui.helpers import \
	add_opener_buttons, add_widget, pick_directory, Info, Error
from launcherlib.ui.munging import copy_paks_and_create_textures_wad


class CustomiseTab(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		# Settings

		add_opener_buttons(self, sizer, {
			'Edit autoexec.cfg (with default editor)':
				dirs.data / 'id1' / 'autoexec.cfg',
			'Edit config.cfg (with default editor)':
				dirs.data / 'id1' / 'config.cfg'
		})

		# Install registered data

		reg_data_button = wx.Button(self, -1, 'Install registered Quake data')
		reg_data_button.Bind(wx.EVT_BUTTON, self.install_data_handler)
		add_widget(sizer, reg_data_button)

		# Video mode settings

		fullscreen = wx.CheckBox(self, -1, "Fullscreen")
		fullscreen.SetValue(config.fullscreen())
		self.Bind(
			wx.EVT_CHECKBOX,
			lambda event: config.fullscreen(event.IsChecked()),
			fullscreen)
		add_widget(sizer, fullscreen)

		# Wiring

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def install_data_handler(self, event):
		if have_registered_data():
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
					finally:
						progress.Destroy()
				else:
					Error(self, (
						'One or both of the registered data files could '
						'not be found in the chosen directory.'))
