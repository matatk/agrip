"""AudioQuake Game Launcher"""
import sys
import os
import subprocess

import wx

from launcherlib import LaunchState, GameController, on_windows


launch_messages = {
	LaunchState.NOT_FOUND: 'Engine not found',
	LaunchState.ALREADY_RUNNING: 'The game is already running'}


class LauncherWindow(wx.Frame):
	def __init__(self, parent, title):
		wx.Frame.__init__(self, parent, title=title)
		game_controller = GameController()
		sizer = wx.BoxSizer(wx.VERTICAL)

		# Commands for opening/running stuff

		if on_windows():
			self._open = ('cmd', '/c', 'start')
			self._rcon = self._open + ('rcon.exe', '--ask')
			self._server = self._open + ('zqds.exe',)
		else:  # assume Mac for now (won't work on Linux)
			self._open = ('open',)
			self._rcon = self._open + ('./start-rcon.command',)
			self._server = self._open + ('./start-server.command',)

		# Launching the game

		game_modes = {
			"Play": game_controller.launch_default,
			"Tutorial": game_controller.launch_tutorial}

		for title, action in game_modes.items():
			button = wx.Button(self, -1, title)

			def make_launch_function(game_start_method):
				def launch(event):
					self.launch_button_core(game_start_method)
				return launch

			button.Bind(wx.EVT_BUTTON, make_launch_function(action))
			sizer.Add(button, 0, wx.EXPAND, 0)

		# Opening things

		def open_server(event):
			self.first_time_check('server')
			subprocess.call(self._server)

		btn_open_server = wx.Button(self, -1, "Server")
		btn_open_server.Bind(wx.EVT_BUTTON, open_server)
		sizer.Add(btn_open_server, 0, wx.EXPAND, 0)

		def open_rcon(event):
			subprocess.call(self._rcon)

		btn_open_rcon = wx.Button(self, -1, "Remote Console")
		btn_open_rcon.Bind(wx.EVT_BUTTON, open_rcon)
		sizer.Add(btn_open_rcon, 0, wx.EXPAND, 0)

		things_to_open = {
			'README': os.path.join(
				'manuals', 'README.html'),
			'User Manual': os.path.join(
				'manuals', 'user-manual.html'),
			'Sound Legend': os.path.join(
				'manuals', 'sound-legend.html'),
			'LICENCE': os.path.join(
				'manuals', 'LICENCE.html'),
			'Show all Files': '.'}

		for title, thing_to_open in things_to_open.items():
			button = wx.Button(self, -1, title)

			def make_open_function(openee):
				def open_thing(event):
					subprocess.call(self._open + (openee,))
				return open_thing

			button.Bind(wx.EVT_BUTTON, make_open_function(thing_to_open))
			sizer.Add(button, 0, wx.EXPAND, 0)

		# Quitting

		btn_quit = wx.Button(self, -1, "Quit Launcher")

		def quit_it(event):
			if game_controller.quit():
				self.Close()
			else:
				Warn(self, "Can't quit whilst Quake is still running.")

		btn_quit.Bind(wx.EVT_BUTTON, quit_it)
		sizer.Add(btn_quit, 0, wx.EXPAND, 0)

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)
		self.Show()

	def launch_button_core(self, method):
		self.first_time_check('game')
		launch_state = method()
		if launch_state is not LaunchState.OK:
			Warn(self, launch_messages[launch_state])

	def first_time_check(self, name):
		if on_windows():
			stamp_file_check(name)
		else:
			pass


def Warn(parent, message, caption='Warning!'):
	dlg = wx.MessageDialog(parent, message, caption, wx.OK | wx.ICON_WARNING)
	dlg.ShowModal()
	dlg.Destroy()


def stamp_file_check(name):
	# TODO decouple from GUI
	# TODO needs to work on Mac? not think so
	stamp_file_name = 'not-first-run-' + name
	prompt = 'When you run the ' + name + ' for the first time, Windows may ask you to allow it through the firewall.'
	if name == 'game':
		prompt += ' This will be done in a secure window that pops up above the Quake engine, which you will need to use ALT-TAB and an Assistive Technology to access.'
	elif name == 'server':
		prompt += ' Please also note that the server output window, and the remote console facility, are not self-voicing.'
	else:
		raise TypeError

	if not os.path.exists(stamp_file_name):
		Alerts.alert('caution', prompt)
		open(stamp_file_name, 'a').close()


if __name__ == '__main__':
	def get_path():
		if getattr(sys, 'frozen', False):
			return os.path.dirname(sys.executable)
		else:
			return os.path.abspath(os.path.dirname(sys.argv[0]))

	app = wx.App(False)
	os.chdir(get_path())
	frame = LauncherWindow(None, "AudioQuake Launcher")
	app.MainLoop()
