"""AudioQuake & LDL Launcher - Map tab"""
import xml.dom.minidom
from pathlib import Path
import shutil
from sys import exc_info

import wx
import wx.lib.expando

from launcherlib import dirs
from launcherlib.game_controller import RootGame
from launcherlib.ui.helpers import \
	add_widget, add_opener_button, launch_core, \
	Info, Warn, Error, HOW_TO_INSTALL, associate_controls, \
	platform_appropriate_grouping
from launcherlib.utils import opener
from ldllib.convert import convert
from ldllib.build import build, bsp_maybe_hc
from ldllib.utils import LDLError, have_wad, WADs, use_bins, use_wads

# The game data dirs where the map should go, given the WAD being used.
# The absolute path is constructed in build_and_copy().
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
		self._map_path = ''

		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		add_opener_button(
			self, sizer, 'Read the LDL tutorial',
			dirs.manuals / 'ldl-tutorial.html')

		# File picker and choosing a tutorial or example map bits

		open_map = platform_appropriate_grouping(
			self, 'Open a Level Description Language (LDL) map')

		def add_map_picker(place, kinda):
			def pick_map_handler(event):
				pick_ldl_map(place, kinda)

			maps_button = wx.Button(self, -1, kinda + ' maps')
			maps_button.Bind(wx.EVT_BUTTON, pick_map_handler)
			add_widget(open_map, maps_button)

		def pick_ldl_map(place, kinda):
			maps = find_ldl_maps(place)
			chooser = wx.SingleChoiceDialog(
				self, f'{kinda} maps:', 'Select map', list(maps.values()))
			if chooser.ShowModal() == wx.ID_OK:
				choice = chooser.GetSelection()
				self.map_path = str(list(maps.keys())[choice])

		add_map_picker(dirs.maps_tutorial, 'Tutorial')
		add_map_picker(dirs.maps_example, 'Example')

		def pick_custom_map(event):
			with wx.FileDialog(
				self, message='Open map', wildcard=WILDCARD,
				style=wx.FLP_OPEN | wx.FLP_FILE_MUST_EXIST) as fileDialog:
				if fileDialog.ShowModal() == wx.ID_CANCEL:
					return
				self.map_path = fileDialog.GetPath()

		file_picker_button = wx.Button(self, -1, 'Open custom map...')
		file_picker_button.Bind(wx.EVT_BUTTON, pick_custom_map)
		add_widget(open_map, file_picker_button)

		chosen_label = wx.StaticText(self, -1, 'Chosen map:')
		self.chosen_text = wx.lib.expando.ExpandoTextCtrl(
			self, -1, style=wx.TE_READONLY)
		self.chosen_text.SetMaxHeight(1)
		add_widget(
			open_map, associate_controls(chosen_label, self.chosen_text))

		add_widget(sizer, open_map)

		# Play and texture selection

		play_checkbox = wx.CheckBox(self, -1, "Play the map when built")
		play_checkbox.SetValue(True)
		add_widget(sizer, play_checkbox)

		texture_label = wx.StaticText(self, label='Play map with texture set:')
		texset_pick = wx.Choice(self, -1, choices=list(game_names.keys()))
		texset_pick.SetSelection(0)  # Needed on Windows
		add_widget(sizer, associate_controls(texture_label, texset_pick))

		# Let's do this!

		btn_build = wx.Button(self, -1, "Build the map")

		def check_picker_path():
			filename = self.map_path

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
				play_wad = list(game_names.values())[texset_pick.GetSelection()]
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

		btn_edit = wx.Button(self, -1, "Edit map (with default editor)")

		def edit_map_handler(event):
			if path := check_picker_path():
				opener(path)

		btn_edit.Bind(wx.EVT_BUTTON, edit_map_handler)
		add_widget(sizer, btn_edit)

		# Wiring wrap-up

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

		# Set up LDL paths

		use_bins(dirs.map_tools)
		use_wads(dirs.map_tools, dirs.data / 'id1')

	def build_and_play(self, xmlfile, play_wad):
		for wad, destinations in wad_bspdests.items():
			if wad == WADs.QUAKE and not have_wad(WADs.QUAKE, quiet=True):
				continue
			try:
				self.build_and_copy(xmlfile, wad, destinations)
			except LDLError:
				Error(self, str(exc_info()[1]))  # TODO: Why not str(err)?
				return

		if play_wad:
			map_basename = bsp_maybe_hc(play_wad, xmlfile).with_suffix('')

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
				raise TypeError(f'Unknown WAD type "{play_wad}"')

			launch_core(self, lambda: self.game_controller.launch_map(
				map_basename, game=play_as_game))
		else:
			Info(
				self, xmlfile.stem
				+ ' built (for all texture sets) and installed.')

	@property
	def map_path(self):
		return self._map_path

	@map_path.setter
	def map_path(self, pathstr):
		self._map_path = pathstr
		self.chosen_text.SetValue(Path(pathstr).name)

	@staticmethod
	def build_and_copy(xmlfile, wad, dest_dirs):
		mapfile = xmlfile.with_suffix('.map')
		bspfile = bsp_maybe_hc(wad, xmlfile)

		convert(xmlfile, wad=wad)
		build(mapfile, bsp_file=bspfile, quiet=True, throw=True)

		for dest_dir in dest_dirs:
			full_dest = dirs.data / dest_dir / 'maps' / bspfile
			shutil.copy(bspfile, full_dest)

		bspfile.unlink()
		mapfile.unlink()
