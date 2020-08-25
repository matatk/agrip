"""AudioQuake Game Launcher - Map tab"""
import xml.dom.minidom
from pathlib import Path
import shutil

import wx

from launcherlib.game_controller import RootGame
from launcherlib.ui.helpers import \
	add_widget, add_opener_button, launch_core, \
	Info, Warn, Error, ErrorException, HOW_TO_INSTALL
from launcherlib.utils import opener
from ldllib.convert import convert, have_wad, WADs
from ldllib.build import build, basename_maybe_hc
from ldllib.utils import LDLError

LDL_TUTORIAL_MAPS_DIR = 'ldl-tutorial-maps'
LDL_EXAMPLE_MAPS_DIR = 'ldl-example-maps'

wad_bspdests = {
	WADs.QUAKE: ['id1'],
	WADs.FREE: ['oq'],
	WADs.PROTOTYPE: ['id1', 'oq']
}

game_names = {
	'Quake': WADs.QUAKE,
	'Open Quartz': WADs.FREE,
	'High contrast': WADs.PROTOTYPE
}


def find_ldl_maps(place):
	maps = {}
	map_filenames = sorted(list(Path(place).glob('*.xml')))
	for ldlfile in map_filenames:
		dom = xml.dom.minidom.parseString(ldlfile.read_text())
		pretty = dom.getElementsByTagName('map')[0].getAttribute('name')
		maps[ldlfile] = pretty
	return maps


class MapTab(wx.Panel):
	def __init__(self, parent, game_controller):
		WILDCARD = "XML files (*.xml)|*.xml"
		self.game_controller = game_controller

		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		add_opener_button(
			self, sizer, 'Read the LDL tutorial',
			Path('manuals') / 'ldl-tutorial.html')  # TODO DRY?

		# File picker and choosing a tutorial or example map bits

		add_widget(sizer, wx.StaticText(
			self, -1, 'Open a Level Description Language (LDL) map'))

		def add_map_picker(place, kinda):
			def pick_map_handler(event):
				pick_ldl_map(place, kinda)

			maps_button = wx.Button(self, -1, kinda + ' maps')
			maps_button.Bind(wx.EVT_BUTTON, pick_map_handler)
			add_widget(sizer, maps_button)

		def pick_ldl_map(place, kinda):
			maps = find_ldl_maps(place)
			chooser = wx.SingleChoiceDialog(
				self, f'{kinda} maps:', 'Select map', list(maps.values()))
			if chooser.ShowModal() == wx.ID_OK:
				choice = chooser.GetSelection()
				file_picker.SetPath(str(list(maps.keys())[choice]))

		add_map_picker(LDL_TUTORIAL_MAPS_DIR, 'LDL tutorial')
		add_map_picker(LDL_EXAMPLE_MAPS_DIR, 'LDL example')

		file_picker = wx.FilePickerCtrl(
			self, -1, message="Open map", wildcard=WILDCARD)

		add_widget(sizer, file_picker)

		# Play and texture selection

		play_checkbox = wx.CheckBox(self, -1, "Play the map when built")
		play_checkbox.SetValue(True)
		add_widget(sizer, play_checkbox)

		texture_set_hbox = wx.BoxSizer(wx.HORIZONTAL)

		label = wx.StaticText(self, label='Play map with texture set:')
		pick = wx.Choice(self, -1, choices=list(game_names.keys()))
		pick.SetSelection(0)  # Needed on Windows

		add_widget(texture_set_hbox, label, border=False)
		add_widget(texture_set_hbox, pick, border=False, expand=True)
		add_widget(sizer, texture_set_hbox)

		# Let's do this!

		btn_build = wx.Button(self, -1, "Build the map")

		def check_picker_path():
			filename = file_picker.GetPath()

			if len(filename) == 0:
				Warn(self, 'No file chosen.')
				return

			path = Path(filename)
			if not path.is_file():
				Error(self, "Can't find chosen file.")
				return

			return path

		def build_and_play_handler(event):
			if (path := check_picker_path()) is None:
				return

			if play_checkbox.GetValue() is True:
				play_wad = list(game_names.values())[pick.GetSelection()]
			else:
				play_wad = None

			if path.name == 'tut07.xml' \
				and not have_wad(WADs.QUAKE, quiet=True):
				Warn(self, (
					'Sorry, ' + path.name + ' requires the Quake data '
					'in order to run. This is a known issue.'))
			else:
				self.build_and_play(path, play_wad)

		btn_build.Bind(wx.EVT_BUTTON, build_and_play_handler)
		add_widget(sizer, btn_build)

		btn_edit = wx.Button(self, -1, "Edit the map (default editor)")

		def edit_map_handler(event):
			if path := check_picker_path():
				opener(path)

		btn_edit.Bind(wx.EVT_BUTTON, edit_map_handler)
		add_widget(sizer, btn_edit)

		# Wiring wrap-up

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def build_and_play(self, xmlfile, play_wad):
		for wad, destinations in wad_bspdests.items():
			if wad == WADs.QUAKE and not have_wad(WADs.QUAKE, quiet=True):
				continue
			try:
				self.build_and_copy(xmlfile, wad, destinations)
			except LDLError:
				ErrorException(self)
				return

		if play_wad:
			map_basename = basename_maybe_hc(play_wad, xmlfile.with_suffix(''))

			if play_wad == WADs.QUAKE:
				if not have_wad(WADs.QUAKE, quiet=True):
					Warn(self, (
						'Quake is not installed, so the map will play in Open '
						'Quartz.\n\n' + HOW_TO_INSTALL))
					play_as_game = RootGame.OPEN_QUARTZ
				else:
					play_as_game = RootGame.QUAKE
			elif play_wad == WADs.FREE:
				play_as_game = RootGame.OPEN_QUARTZ
			elif play_wad == WADs.PROTOTYPE:
				play_as_game = RootGame.ANY
			else:
				raise TypeError(f"Unknown WAD type '{play_wad}'")

			launch_core(self, lambda: self.game_controller.launch_map(
				map_basename, game=play_as_game))
		else:
			Info(
				self, xmlfile.stem
				+ ' built (for all texture sets) and installed.')

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
