"""AudioQuake Game Launcher - Map tab"""
from pathlib import Path
import shutil

import wx

from launcherlib.utils import have_registered_data
from launcherlib.ui.helpers import \
	add_widget, add_opener_button, launch_core, \
	Info, Warn, Error, ErrorException
from ldllib.convert import convert, have_wad_for
from ldllib.build import build, basename_maybe_hc
from ldllib.utils import LDLError

LDL_TUTORIAL_MAPS_DIR = 'ldl-tutorial-maps'
PRETTY_WAD_NAMES = ['Quake', 'Open Quartz', 'High contrast']
LOOKUP_WAD_NAMES = ['quake', 'free', 'prototype']
wad_bspdests = {
	'quake': ['id1'],
	'free': ['oq'],
	'prototype': ['id1', 'oq']
}


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
				lambda xml: xml.name, Path(LDL_TUTORIAL_MAPS_DIR).glob('*'))))
			chooser = wx.SingleChoiceDialog(
				self, 'LDL Tutorial Maps', 'Choose map', maps)
			if chooser.ShowModal() == wx.ID_OK:
				choice = chooser.GetStringSelection()
				file_picker.SetPath(str(Path(LDL_TUTORIAL_MAPS_DIR) / choice))

		tutorial_maps_button = wx.Button(self, -1, 'Choose a LDL tutorial map')
		tutorial_maps_button.Bind(wx.EVT_BUTTON, pick_tutorial_map)
		add_widget(sizer, tutorial_maps_button)

		play_checkbox = wx.CheckBox(self, -1, "Play the map when built")
		play_checkbox.SetValue(True)
		add_widget(sizer, play_checkbox)

		texture_set_hbox = wx.BoxSizer(wx.HORIZONTAL)

		label = wx.StaticText(self, label='Texture set:')

		pick = wx.Choice(
			self, -1, choices=PRETTY_WAD_NAMES)

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

			if play_checkbox.GetValue() is True:
				play_as = LOOKUP_WAD_NAMES[pick.GetSelection()]
			else:
				play_as = None

			self.build_and_play_ldl_map(path, play_as)

		btn_pick_ldl_map_file.Bind(wx.EVT_BUTTON, pick_ldl_map_file)
		add_widget(sizer, btn_pick_ldl_map_file)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def build_and_play_ldl_map(self, xmlfile, play_as):
		for wad, destinations in wad_bspdests.items():
			if wad == 'quake' and not have_wad_for('quake', quiet=True):
				continue
			try:
				self.build_and_copy(xmlfile, wad, destinations)
			except LDLError:
				ErrorException(self)
				return

		if play_as:
			map_basename = basename_maybe_hc(play_as, xmlfile.with_suffix(''))

			if play_as == 'quake' and not have_wad_for('quake', quiet=True):
				Warn(self, 'Quake is not installed, so will play in Open Quartz')
			if play_as == 'free' and have_wad_for('quake', quiet=True):
				Warn(self, 'bug; playing in Quake anyway!')

			launch_core(
				self, lambda: self.game_controller.launch_map(map_basename))
		else:
			Info(self, map_basename + ' built and installed')

	@staticmethod
	def build_and_copy(xmlfile, wad, dest_dirs):
		mapfile = xmlfile.with_suffix('.map')
		bspfile = basename_maybe_hc(wad, xmlfile.with_suffix('.bsp'))

		convert(xmlfile, wad=wad)
		build(mapfile, bsp_file=bspfile, quiet=True, throw=True)

		for dest_dir in dest_dirs:
			full_dest = Path(dest_dir) / 'maps' / bspfile
			shutil.copy(bspfile, full_dest)

		bspfile.unlink()
		mapfile.unlink()
