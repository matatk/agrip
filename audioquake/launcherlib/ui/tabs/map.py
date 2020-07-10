"""AudioQuake Game Launcher - Map tab"""
from os import path
import subprocess
import shutil

import wx

from launcherlib.ui.helpers import \
	add_widget, add_opener_button, launch_core, pick_file, \
	Info, Warn, Error, ErrorException
from ldllib.conf import prog
from ldllib.convert import convert
from ldllib.build import build, have_needed_stuff


class MapTab(wx.Panel):
	def __init__(self, parent, game_controller):
		WILDCARD = "XML files (*.xml)|*.xml"
		self.game_controller = game_controller

		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		# File picker bits

		add_widget(sizer, wx.StaticText(
			self, -1, 'Open a Level Description Language (LDL) map'))
		file_picker = wx.FilePickerCtrl(
			self, -1, message="Open map", wildcard=WILDCARD)
		add_widget(sizer, file_picker)

		def pick_tutorial_map(event):
			chosen = pick_file(self, "Open tutorial map", WILDCARD)
			if chosen:
				file_picker.SetPath(chosen)

		tutorial_maps_button = wx.Button(self, -1, 'Choose a LDL tutorial map')
		tutorial_maps_button.Bind(wx.EVT_BUTTON, pick_tutorial_map)
		add_widget(sizer, tutorial_maps_button)

		play_checkbox = wx.CheckBox(self, -1, "Play the map when built")
		play_checkbox.SetValue(True)
		add_widget(sizer, play_checkbox)

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

		add_opener_button(
			self, sizer, 'Open the LDL tutorial document',
			('ldl-tutorial.html',))

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def build_and_play_ldl_map(self, filename, play_when_built=True):
		# We're already in the AQ dir
		bindir = 'bin'
		prog.qbsp = path.join(bindir, 'qbsp')
		prog.vis = path.join(bindir, 'vis')
		prog.light = path.join(bindir, 'light')
		prog.bspinfo = path.join(bindir, 'bspinfo')
		# prog.quakewad
		# prog.STYLE_FILE

		aq_maps_dir = path.join('id1', 'maps')

		xmldir, xmlfile = path.split(filename)
		map_base = path.splitext(xmlfile)[0]
		mapfile = map_base + '.map'
		bspfile = map_base + '.bsp'
		abs_installed_bspfile = path.join(aq_maps_dir, bspfile)

		if have_needed_stuff():
			try:
				convert(filename, map_base, False, False)
				build(mapfile, map_base, False)

				shutil.move(bspfile, abs_installed_bspfile)

				if play_when_built:
					launch_core(
						self, lambda: self.game_controller.launch_map(map_base))
				else:
					Info(self, bspfile + ' built and installed')

			except subprocess.CalledProcessError as error:
				Error(self, error.output.decode().splitlines()[-1])

			except:  # noqa E722
				ErrorException(self)
		else:
			Warn(self, "Can't find map-building tools")
