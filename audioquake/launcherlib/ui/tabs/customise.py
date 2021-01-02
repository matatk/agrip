"""AudioQuake & LDL Launcher - Customise tab"""
from os import path

import wx

from launcherlib import dirs
import launcherlib.config as config
from launcherlib.utils import have_registered_data, InvalidResolutionError, \
	width_and_height
from launcherlib.ui.helpers import \
	add_opener_buttons, add_widget, pick_directory, Info, Error
from launcherlib.ui.munging import copy_paks_and_create_textures_wad


RESOLUTIONS = [
	'320x200 (16:10)',
	'320x240 (4:3)',
	'640x400 (16:10) [default]',
	'848x477 (16:9)',
	'640x480 (4:3)',
	'768x480 (16:10)',
	'864x486 (16:9)',
	'720x540 (4:3)',
	'864x540 (16:10)',
	'960x540 (16:9)',
	'800x600 (4:3)',
	'1152x720 (16:10)',
	'1280x720 (16:9)',
	'1024x768 (4:3)',
	'1600x900 (16:9)',
	'1600x1000 (16:10)',
	'1440x1080 (4:3)',
	'1728x1080 (16:10)',
	'1920x1080 (16:9)']

DEFAULT_RESOLUTION_INDEX = 2


def find_resolution_index(partial_resolution):
	"""Given a resolution string, find the index of the resolution, if it
	matches one of the presets. If it doesn't return -1. If it's invalid,
	return -2."""
	try:
		given_xstr, given_ystr = width_and_height(partial_resolution)
	except InvalidResolutionError:
		return -2

	for index, resolution_string in enumerate(RESOLUTIONS):
		res_xstr, res_ystr = width_and_height(resolution_string)
		if given_xstr == res_xstr and given_ystr == res_ystr:
			return index

	return -1


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

		reg_data_button = wx.Button(self, -1, 'Install registered Quake data')
		reg_data_button.Bind(wx.EVT_BUTTON, self.install_data_handler)
		add_widget(sizer, reg_data_button)

		# Video mode settings

		add_widget(sizer, wx.StaticLine(self, -1))
		add_widget(sizer, wx.StaticText(
			self, -1, 'Video mode settings', style=wx.ALIGN_CENTRE_HORIZONTAL))

		fullscreen = wx.CheckBox(
			self, -1, 'Run full-screen (instead of windowed)')
		fullscreen.SetValue(config.fullscreen())
		fullscreen.Bind(
			wx.EVT_CHECKBOX,
			lambda event: config.fullscreen(event.IsChecked()),
			fullscreen)
		add_widget(sizer, fullscreen)

		resolution_hbox = wx.BoxSizer(wx.HORIZONTAL)
		label = wx.StaticText(self, label='Resolution:')

		pick = wx.Choice(self, -1, choices=RESOLUTIONS)
		chosen_resolution_index = find_resolution_index(config.resolution())
		# FIXME: what about if launched via command line?
		print('chosen_resolution_index:', chosen_resolution_index)
		if chosen_resolution_index >= 0:
			print('res is a preset one')
			pick.SetSelection(chosen_resolution_index)
		elif chosen_resolution_index == -1:
			print('res valid but custom')
			pick.Disable()
		else:
			print('res invalid')
			pick.SetSelection(DEFAULT_RESOLUTION_INDEX)
			config.resolution(RESOLUTIONS[DEFAULT_RESOLUTION_INDEX])
		pick.Bind(
			wx.EVT_CHOICE,
			lambda event: config.resolution(RESOLUTIONS[event.GetSelection()]))

		add_widget(resolution_hbox, label, border=False)
		add_widget(resolution_hbox, pick, border=False, expand=True)
		add_widget(sizer, resolution_hbox)

		quick_test = wx.Button(self, -1, 'Play tutorial (F10 to quit game)')
		quick_test.Bind(
			wx.EVT_BUTTON, lambda event: game_controller.launch_tutorial())
		add_widget(sizer, quick_test)

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
