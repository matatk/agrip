#!/usr/bin/env python
import sys, os  # chdir hack
import subprocess, threading, Queue  # launching the game

from GUI import Window, Button, application, Task
from GUI.StdMenus import basic_menus, fundamental_cmds

import pyttsx


class EngineWrapper(threading.Thread):
	def __init__(self, command_line, out_queue):
		threading.Thread.__init__(self)
		self._command_line = command_line
		self._out_queue = out_queue

	def _shut_up(self):
		with self._out_queue.mutex:
			self._out_queue.queue.clear()
		self._out_queue.put(False)

	def run(self):
		seen_blank = False
		initialised = False
		proc = subprocess.Popen(self._command_line, stdout=subprocess.PIPE)

		while True:
			retcode = proc.poll()
			line = proc.stdout.readline().rstrip()

			# Some messages are high priority, others are critical.
			# These need to be spoken instead of anything else queued up.
			if len(line) > 0:
				if len(line) is 1 or line[0] is '!':
					self._shut_up()
				self._out_queue.put(line)
			else:
				# When the engine has finished splurting out stuff
				# during initialisation, the game has started, so
				# clear the queue and start announcing game messages.
				if not initialised and seen_blank:
					self._shut_up()
					initialised = True
				else:
					seen_blank = True

			if retcode is not None:
				self._shut_up()
				self._out_queue.put(None)
				break


class GameController(object):
	_opts_default = (
		"./zquake-glsdl",
		"-window",
		"+set sensitivity 0")

	_opts_tutorial = (
		"+coop 0",
		"+deathmatch 0",
		"+map agtut01")

	def __init__(self):
		self._messages_task = None
		self._running = False
		self._in_queue = Queue.Queue()
		self._speaker = pyttsx.init()
		self._speaker.startLoop(False)

	def quit(self):
		pass  # TODO: terminate the engine if the GUI quits

	def _game_ended(self):
		assert self._running
		assert self._messages_task is not None
		self._messages_task.stop()
		self._messages_task = None
		self._speaker.stop()
		self._running = False

	def _launch_core(self, command_line):
		if self._running:
			return
		self._running = True
		assert self._messages_task is None
		engine_wrapper = EngineWrapper(command_line, self._in_queue)
		engine_wrapper.start()

		def get_messages(speaker, queue, callback):
			try:
				message = queue.get_nowait()
				if message is None:
					callback()
				else:
					assert message is False or type(message) is str
					# We may have been told to cancel the current utterance
					if message is False:
						speaker.stop()
					else:
						speaker.say(message)
						speaker.iterate()
			except Queue.Empty:
				pass

		# Keep checking for and saying new messages
		self._messages_task = Task(
			lambda: get_messages(
				self._speaker,
				self._in_queue,
				self._game_ended),
			0.1,
			True,
			True)

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
		self._game_controller = GameController()

		self.auto_position = False
		self.position = (200, 250)
		self.size = (140, 170)
		self.resizable = 0
		self.zoomable = 0

		self.add(Button(
			position = (10, 10), 
			size = (120, 25),
			title = "Play Quake",
			action = self._btn_default
		))

		self.add(Button(
			position = (10, 40), 
			size = (120, 25),
			title = "Play Tutorial",
			action = self._btn_tutorial
		))

		self.add(Button(
			position = (10, 70), 
			size = (120, 25),
			title = "README",
			action = self._btn_readme
		))

		self.add(Button(
			position = (10, 100), 
			size = (120, 25),
			title = "Licence",
			action = self._btn_licence
		))

		self.add(Button(
			position = (10, 140), 
			size = (120, 25),
			title = "Quit Launcher",
			action = self._close_cmd
		))

	def _close_cmd(self):
		self._game_controller.quit()
		self._application.quit_cmd()

	def _btn_default(self):
		self._game_controller.launch_default()

	def _btn_tutorial(self):
		self._game_controller.launch_tutorial()

	def _btn_readme(self):
		subprocess.call(('open', '-a', 'TextEdit', 'README.md'))

	def _btn_licence(self):
		subprocess.call(('open', '-a', 'TextEdit', 'LICENCE.md'))


if __name__ == '__main__':
	os.chdir(os.path.dirname(sys.argv[0]))
	app = application()
	app.menus = basic_menus(include = fundamental_cmds)
	launcher = LauncherSingletonWindow(app)
	launcher.show()
	app.run()
