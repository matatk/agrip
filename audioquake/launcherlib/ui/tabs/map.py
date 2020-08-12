"""AudioQuake Game Launcher - Map tab"""
from glob import glob
from os import path
import shutil

import wx

from launcherlib.utils import have_registered_data
from launcherlib.ui.helpers import \
	add_widget, add_opener_button, launch_core, \
	Info, Warn, Error, ErrorException
from ldllib.convert import convert
from ldllib.build import build, have_needed_stuff

MAPS_DIR = 'ldl-tutorial-maps'


class MapTab(wx.Panel):
	def __init__(self, parent, game_controller):
		WILDCARD = "XML files (*.xml)|*.xml"
		self.game_controller = game_controller

		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		add_opener_button(
			self, sizer, 'Read the LDL tutorial',
			path.join('manuals', 'ldl-tutorial.html'))  # FIXME DRY?

		# File picker bits

		add_widget(sizer, wx.StaticText(
			self, -1, 'Open a Level Description Language (LDL) map'))
		file_picker = wx.FilePickerCtrl(
			self, -1, message="Open map", wildcard=WILDCARD)
		add_widget(sizer, file_picker)

		def pick_tutorial_map(event):
			maps = sorted(list(map(
				lambda xml: path.basename(xml), glob(MAPS_DIR + '/*'))))
			chooser = wx.SingleChoiceDialog(
				self, 'LDL Tutorial Maps', 'Choose map', maps)
			if chooser.ShowModal() == wx.ID_OK:
				choice = chooser.GetStringSelection()
				file_picker.SetPath(path.join(MAPS_DIR, choice))

		tutorial_maps_button = wx.Button(self, -1, 'Choose a LDL tutorial map')
		tutorial_maps_button.Bind(wx.EVT_BUTTON, pick_tutorial_map)
		add_widget(sizer, tutorial_maps_button)

		play_checkbox = wx.CheckBox(self, -1, "Play the map when built")
		play_checkbox.SetValue(True)
		add_widget(sizer, play_checkbox)

		texture_set_hbox = wx.BoxSizer(wx.HORIZONTAL)

		label = wx.StaticText(self, label='Texture set:')

		pick = wx.Choice(
			self, -1, choices=['Quake', 'Open Quartz', 'High contrast'])

		if not have_registered_data():
			pick.SetSelection(1)

		# FIXME name= doesn't get reflected by VO; what about NVDA?
		btn_info = wx.Button(
			self, label='?', name='Info about the texture set',
			style=wx.BU_EXACTFIT)
		btn_info.Bind(wx.EVT_BUTTON, lambda event: Info(
			self, 'FIXME'))  # FIXME

		add_widget(texture_set_hbox, label, border=False)
		add_widget(texture_set_hbox, pick, border=False, expand=True)
		add_widget(texture_set_hbox, btn_info, border=False)
		add_widget(sizer, texture_set_hbox)

		btn_ldl_test = wx.Button(self, -1, "Build the map")

		def ldl_test(event):
			filename = file_picker.GetPath()

			if len(filename) == 0:
				Warn(self, 'No file chosen.')
				return

			if not path.isfile(filename):
				Error(self, "Can't find chosen file.")
				return

			self.build_and_play_ldl_map(filename, play_checkbox.GetValue())

		btn_ldl_test.Bind(wx.EVT_BUTTON, ldl_test)
		add_widget(sizer, btn_ldl_test)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def build_and_play_ldl_map(self, filename, play_when_built=True):
		if have_registered_data():
			base = 'id1'
			# TODO quake.wad management; ... ?
		else:
			base = 'oq'
			# TODO quake.wad management; ... ?

		aq_maps_dir = path.join(base, 'maps')

		xmldir, xmlfile = path.split(filename)
		map_base = path.splitext(xmlfile)[0]
		mapfile = map_base + '.map'
		bspfile = map_base + '.bsp'
		abs_installed_bspfile = path.join(aq_maps_dir, bspfile)

		if have_needed_stuff():
			try:
				convert(filename, verbose=False, keep_intermediate=False)
				build(mapfile, verbose=False)

				shutil.move(bspfile, abs_installed_bspfile)

				if play_when_built:
					launch_core(
						self, lambda: self.game_controller.launch_map(map_base))
				else:
					Info(self, bspfile + ' built and installed')
			except:  # noqa E722
				# FIXME LDLError only?
				ErrorException(self)
		else:
			Warn(self, "Can't find map-building tools")
