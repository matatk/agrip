"""AudioQuake & LDL Launcher - Customise tab"""
from os import path

import wx

from buildlib import doset_only
from launcherlib import dirs
import launcherlib.config as config
from launcherlib.utils import have_registered_data
from launcherlib.ui.helpers import associate_controls, \
	add_opener_buttons, add_widget, pick_directory, Info, Error, \
	platform_appropriate_grouping, does_user_confirm, game_flickering_check
from launcherlib.ui.munging import copy_paks_and_create_textures_wad
from launcherlib.resolutions import resolution_index_from_config, \
	RESOLUTIONS, DEFAULT_RESOLUTION_INDEX


class CustomiseTab(wx.Panel):
	def __init__(self, parent, game_controller):
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

		add_widget(sizer, wx.StaticLine(self, -1))
		reg_data_button = wx.Button(self, -1, 'Install registered Quake data')
		reg_data_button.Bind(wx.EVT_BUTTON, self.install_data_handler)
		add_widget(sizer, reg_data_button)

		# Video mode settings

		add_widget(sizer, wx.StaticLine(self, -1))

		box = platform_appropriate_grouping(self, 'Video mode settings')

		fullscreen = wx.CheckBox(
			self, -1, 'Run full-screen (instead of windowed)')

		fullscreen.SetValue(config.fullscreen())
		fullscreen.Bind(
			wx.EVT_CHECKBOX,
			lambda event: config.fullscreen(event.IsChecked()))
		add_widget(box, fullscreen)

		res_label = wx.StaticText(self, label='Resolution:')
		res_pick = wx.Choice(self, -1, choices=RESOLUTIONS)

		index, _ = resolution_index_from_config()
		if index >= 0:
			res_pick.SetSelection(index)
		else:
			res_pick.Disable()

		res_pick.Bind(
			wx.EVT_CHOICE,
			lambda event: config.resolution(RESOLUTIONS[event.GetSelection()]))

		add_widget(box, associate_controls(res_label, res_pick))

		doset_only(windows=lambda: add_widget(box, wx.StaticText(
			self, -1, "Some modes may not be available full-screen.")))
		doset_only(windows=lambda: add_widget(box, wx.StaticText(
			self, -1, "Modes may be cropped when Windows' UI is scaled.")))

		def mode_test(event):
			if fullscreen.GetValue() is True:
				if not config.warning_acknowledged_flickering_mode_test():
					if does_user_confirm(
						parent,
						'Full-screen flickering warning',
						fullscreen_warning_message):
						config.warning_acknowledged_flickering_mode_test(True)
					else:
						fullscreen.SetValue(False)
						return
			else:
				if not game_flickering_check(parent):
					return
			game_controller.launch_tutorial()

		quick_test = wx.Button(self, -1, 'Try it out: Play tutorial')
		quick_test.Bind(wx.EVT_BUTTON, mode_test)
		add_widget(box, quick_test)

		def reset_to_defaults(event):
			fullscreen.SetValue(False)
			wx.PostEvent(fullscreen, wx.CommandEvent(wx.wxEVT_CHECKBOX))
			res_pick.SetSelection(DEFAULT_RESOLUTION_INDEX)
			choice_event = wx.CommandEvent(wx.wxEVT_CHOICE)
			choice_event.SetInt(DEFAULT_RESOLUTION_INDEX)
			wx.PostEvent(res_pick, choice_event)
			res_pick.Enable()

		reset = wx.Button(self, -1, 'Reset video mode to defaults')
		reset.Bind(wx.EVT_BUTTON, reset_to_defaults)
		add_widget(box, reset)

		add_widget(sizer, box)

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


fullscreen_warning_message = (
	'Please note that on some systems, there may be flickering\n'
	'graphical bugs in some full-screen modes (particularly if\n'
	'you set custom modes in the config file). Also Quake does\n'
	'use flickering lighting effects, and the screen may flicker\n'
	'when the mode is changed.\n')
