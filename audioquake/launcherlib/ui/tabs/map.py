"""AudioQuake Game Launcher - Map tab"""
from pathlib import Path
import shutil

import wx

from launcherlib.utils import have_registered_data
from launcherlib.ui.helpers import \
	add_widget, add_opener_button, launch_core, \
	Info, Warn, Error, ErrorException
from ldllib.convert import convert, have_wad_for
from ldllib.build import build, have_needed_progs
from ldllib.utils import LDLError

MAPS_DIR = 'ldl-tutorial-maps'


class MapTab(wx.Panel):
	def __init__(self, parent, game_controller):
		WILDCARD = "XML files (*.xml)|*.xml"
		self.game_controller = game_controller

		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		add_opener_button(
			self, sizer, 'Read the LDL tutorial',
			Path('manuals') / 'ldl-tutorial.html')  # TODO DRY?

		# File picker bits

		add_widget(sizer, wx.StaticText(
			self, -1, 'Open a Level Description Language (LDL) map'))
		file_picker = wx.FilePickerCtrl(
			self, -1, message="Open map", wildcard=WILDCARD)
		add_widget(sizer, file_picker)

		def pick_tutorial_map(event):
			maps = sorted(list(map(
				lambda xml: xml.name, Path(MAPS_DIR).glob('*'))))
			chooser = wx.SingleChoiceDialog(
				self, 'LDL Tutorial Maps', 'Choose map', maps)
			if chooser.ShowModal() == wx.ID_OK:
				choice = chooser.GetStringSelection()
				file_picker.SetPath(str(Path(MAPS_DIR) / choice))

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

		add_widget(texture_set_hbox, label, border=False)
		add_widget(texture_set_hbox, pick, border=False, expand=True)
		add_widget(sizer, texture_set_hbox)

		btn_pick_ldl_map_file = wx.Button(self, -1, "Build the map")

		def pick_ldl_map_file(event):
			filename = file_picker.GetPath()

			if len(filename) == 0:
				Warn(self, 'No file chosen.')
				return

			path = Path(filename)
			if not path.is_file():
				Error(self, "Can't find chosen file.")
				return

			self.build_and_play_ldl_map(path, play_checkbox.GetValue())

		btn_pick_ldl_map_file.Bind(wx.EVT_BUTTON, pick_ldl_map_file)
		add_widget(sizer, btn_pick_ldl_map_file)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def build_and_play_ldl_map(self, xmlfile, play_when_built=True):
		wad_bspdests = {
			'quake': ['id1'],
			'free': ['oq'],
			'prototype': ['id1', 'oq']
		}

		if not have_wad_for('quake'):
			print('no quake wad')
			return

		for wad, destinations in wadfile_bspdests.items():
			if wad == 'quake.wad' and not have_registered_data():
				continue
			elif wad == 'prototype_1_2.wad':
				pass  # TODO
			try:
				self.build_and_copy(xmlfile, wad, destinations)
			except LDLError:
				ErrorException(self)
				return

		if play_when_built:
			map_basename = xmlfile.stem
			launch_core(
				self, lambda: self.game_controller.launch_map(map_basename))
		else:
			Info(self, map_basename + ' built and installed')

	@staticmethod
	def build_and_copy(xmlfile, wad_file, dest_dirs):
		print('build_and_copy():', xmlfile, wad_file, dest_dirs)
		mapfile = xmlfile.with_suffix('.map')
		bspfile = xmlfile.with_suffix('.bsp')

		for dest_dir in dest_dirs:
			convert(xmlfile, wad=wad_file)
			build(mapfile, quiet=True, throw=True)
			full_dest = Path(dest_dir) / 'maps' / bspfile
			print('full_dest is: ', full_dest)
			print('moving', bspfile, 'to', full_dest)
			shutil.move(bspfile, full_dest)
