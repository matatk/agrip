#!/usr/bin/env python
import sys, os  # chdir hack
import subprocess  # controller
from GUI import Window, Button, application
from GUI.StdMenus import basic_menus, fundamental_cmds
import pyttsx


class GameController(object):
	_opts_default = (
		"./zquake-glsdl",
		"-window",
		"+set sensitivity 0")

	_opts_tutorial = (
		"+coop 0",
		"+deathmatch 0",
		"+map agtut01")
	
	def _say(self, line):
		sys.stdout.write("say: " + line)  # TODO remove for production
		subprocess.Popen(('/usr/bin/say', line))

	def _launch_core(self, command_line):
		proc = subprocess.Popen(command_line, stdout=subprocess.PIPE)
		while True:
			retcode = proc.poll()
			line = proc.stdout.readline()
			self._say(line)
			if retcode is not None:
				break

	def launch_default(self):
		self._launch_core(self._opts_default)
	
	def launch_tutorial(self):
		self._launch_core(self._opts_default + self._opts_tutorial)


class LauncherSingletonWindow(Window):
	def __init__(self, application, *args, **kwargs):
		super(LauncherSingletonWindow, self).__init__(
			title = "Launcher",
			resizable = False,
			zoomable = False,
			*args,
			**kwargs)
		self._application = application
		self._game = GameController()

		self.auto_position = False
		self.position = (200, 250)
		self.size = (140, 135)
		self.resizable = 0
		self.zoomable = 0

		self.add(Button(
			position = (10, 10), 
			size = (120, 25),
		    title = "Play Quake",
			action = self.btn_default
		))
		
		self.add(Button(
			position = (10, 40), 
			size = (120, 25),
		    title = "Play Tutorial",
			action = self.btn_tutorial
		))

		self.add(Button(
			position = (10, 100), 
			size = (120, 25),
		    title = "Quit Launcher",
			action = self.close_cmd
		))

		self.engine = pyttsx.init()
		self.engine.say('Welcome to Quake')
		self.engine.startLoop(False)
		self.engine.iterate()
	
	def close_cmd(self):
		self.engine.endLoop()
		self._application.quit_cmd()
	
	def btn_default(self):
		self._game.launch_default()

	def btn_tutorial(self):
		self._game.launch_tutorial()


if __name__ == '__main__':
	os.chdir(os.path.dirname(sys.argv[0]))
	app = application()
	app.menus = basic_menus(include = fundamental_cmds)
	launcher = LauncherSingletonWindow(app)
	launcher.show()
	app.run()
