"""AudioQuake Game Launcher"""
import sys
import os
import subprocess
import traceback
import shutil

import wx

from launcherlib import LaunchState, GameController, on_windows, opener

from ldllib.conf import prog
from ldllib.convert import convert
from ldllib.build import build, have_needed_stuff

launch_messages = {
	LaunchState.NOT_FOUND: 'Engine not found',
	LaunchState.ALREADY_RUNNING: 'The game is already running'
}

BORDER_SIZE = 5

game_controller = GameController()  # FIXME global


class AudioQuakeTab(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		# Launching the game

		game_modes = {
			"Play": game_controller.launch_default,
			"Tutorial": game_controller.launch_tutorial,
			"Server": game_controller.launch_server,
			"Remote console": game_controller.launch_rcon
		}

		for title, action in game_modes.items():
			add_launch_button(self, sizer, title, action)

		# Opening things

		things_to_open = {
			'README': os.path.join('manuals', 'README.html'),
			'User manual': os.path.join('manuals', 'user-manual.html'),
			'Sound legend': os.path.join('manuals', 'sound-legend.html'),
			'LICENCE': os.path.join('manuals', 'LICENCE.html'),
			'Show all files': '.'
		}

		for title, thing_to_open in things_to_open.items():
			button = wx.Button(self, -1, title)

			def make_open_function(openee):
				def open_thing(event):
					subprocess.call(opener() + (openee,))
				return open_thing

			button.Bind(wx.EVT_BUTTON, make_open_function(thing_to_open))
			add_widget(sizer, button)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)


class LevelDescriptionLanguageTab(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		add_widget(sizer, wx.StaticText(self, -1, 'Choose an LDL XML file'))

		file_picker = wx.FilePickerCtrl(self, -1)
		add_widget(sizer, file_picker)

		play_checkbox = wx.CheckBox(self, -1, "Play when built")
		play_checkbox.SetValue(True)
		add_widget(sizer, play_checkbox)

		btn_ldl_test = wx.Button(self, -1, "Convert XML and build BSP")

		def ldl_test(event):
			filename = file_picker.GetPath()

			if len(filename) == 0:
				Warn(self, 'No file chosen.')
				return

			if not os.path.isfile(filename):
				Warn(self, "Can't find chosen file.")
				return

			# TODO check for XML file?

			# We're already in the AQ dir
			bindir = 'bin'
			prog.qbsp = os.path.join(bindir, 'qbsp')
			prog.vis = os.path.join(bindir, 'vis')
			prog.light = os.path.join(bindir, 'light')
			prog.bspinfo = os.path.join(bindir, 'bspinfo')
			# prog.quakewad
			# prog.STYLE_FILE

			aq_maps_dir = os.path.join(os.getcwd(), 'id1', 'maps')  # TODO ?

			xmldir, xmlfile = os.path.split(filename)
			map_base = os.path.splitext(xmlfile)[0]
			mapfile = map_base + '.map'
			bspfile = map_base + '.bsp'
			abs_installed_bspfile = os.path.join(aq_maps_dir, bspfile)

			if have_needed_stuff():
				try:
					convert(filename, map_base, False, False)
					build(mapfile, map_base, False)

					shutil.move(bspfile, abs_installed_bspfile)

					if play_checkbox.GetValue():
						def try_map():
							return game_controller.launch_map(map_base)

						launch_button_core(self, try_map)
					else:
						Info(self, bspfile + ' built and installed')

				except subprocess.CalledProcessError as error:
					Warn(self, error.output.decode().splitlines()[-1])

				except:  # noqa E722
					etype, evalue, etraceback = sys.exc_info()
					traceback.print_tb(etraceback)
					Warn(self, str(evalue))
			else:
				Warn(self, "Can't find map-building tools")

		btn_ldl_test.Bind(wx.EVT_BUTTON, ldl_test)
		add_widget(sizer, btn_ldl_test)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)


class LauncherWindow(wx.Frame):
	def __init__(self, parent, title):
		wx.Frame.__init__(self, parent, title=title)

		panel = wx.Panel(self)
		root_vbox = wx.BoxSizer(wx.VERTICAL)
		child_hbox = wx.BoxSizer(wx.HORIZONTAL)

		# Tabs

		notebook = wx.Notebook(panel)

		tab_audioquake = AudioQuakeTab(notebook)
		tab_level_description_language = LevelDescriptionLanguageTab(notebook)

		notebook.AddPage(tab_audioquake, "AudioQuake")
		notebook.AddPage(
			tab_level_description_language, "Level Description Language")

		root_vbox.Add(notebook, 1, wx.EXPAND)

		# Buttons

		btn_quit = wx.Button(panel, -1, "Quit Launcher")

		def quit_it(event):
			if game_controller.quit():
				self.Close()
			else:
				Warn(self, "Can't quit whilst Quake is still running.")

		btn_quit.Bind(wx.EVT_BUTTON, quit_it)

		add_widget(child_hbox, btn_quit, border=False)

		# Wiring

		root_vbox.Add(child_hbox, 0, wx.ALIGN_RIGHT | wx.ALL, BORDER_SIZE)
		panel.SetSizer(root_vbox)
		# root_vbox.SetSizeHints(self)  # doesn't seem to be needed?


def add_launch_button(parent, sizer, title, action):
	button = wx.Button(parent, -1, title)

	def make_launch_function(game_start_method):
		def launch(event):
			launch_button_core(parent, game_start_method)
		return launch

	button.Bind(wx.EVT_BUTTON, make_launch_function(action))
	add_widget(sizer, button)


def add_widget(sizer, widget, border=True, expand=True):
	expand_flag = wx.EXPAND if expand else 0
	border_flag = wx.ALL if border else 0
	border_size = BORDER_SIZE if border else 0
	sizer.Add(widget, 0, expand_flag | border_flag, border_size)


def Info(parent, message):
	MsgBox(parent, message, 'Info')


# FIXME Error too?
def Warn(parent, message):
	MsgBox(parent, message, 'Warning')


def MsgBox(parent, message, caption):
	dlg = wx.MessageDialog(parent, message, caption, wx.OK | wx.ICON_WARNING)
	dlg.ShowModal()
	dlg.Destroy()


def stamp_file_check(gui_parent, name):
	# TODO decouple from GUI
	# TODO needs to work on Mac? not think so
	stamp_file_name = 'not-first-run-' + name
	prompt = 'When you run the ' + name + ' for the first time, Windows ' + \
		'may ask you to allow it through the firewall.'
	if name == 'game':
		prompt += ' This will be done in a secure window that pops up ' + \
			'above the Quake engine, which you will need to use ALT-TAB ' + \
			'and an Assistive Technology to access.'
	elif name == 'server':
		prompt += ' Please also note that the server output window, and ' + \
			'the remote console facility, are not self-voicing.'
	else:
		raise TypeError

	if not os.path.exists(stamp_file_name):
		Warn(gui_parent, prompt)
		open(stamp_file_name, 'a').close()


def launch_button_core(gui, method):
	first_time_check('game')
	launch_state = method()
	if launch_state is not LaunchState.OK:
		Warn(gui, launch_messages[launch_state])


def first_time_check(name):
	if on_windows():
		stamp_file_check(name)
	else:
		pass


if __name__ == '__main__':
	def get_path():
		if getattr(sys, 'frozen', False):
			return os.path.dirname(sys.executable)
		else:
			return os.path.abspath(os.path.dirname(sys.argv[0]))

	app = wx.App(False)
	os.chdir(get_path())
	LauncherWindow(None, "AudioQuake Launcher").Show()
	app.MainLoop()
