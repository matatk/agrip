"""Launcher Gubbins"""
import enum
import platform
import threading
import subprocess
import os
import sys


def on_windows():
	return platform.system() == 'Windows'


if on_windows():
	import pythoncom
	import win32com.client
else:
	from AppKit import NSSpeechSynthesizer


def opener():
	if on_windows():
		return ('cmd', '/c', 'start')
	else:  # assume Mac for now (may also work on Linux)
		return ('open',)


class LaunchState(enum.Enum):
	LAUNCHED = enum.auto()
	NOT_FOUND = enum.auto()
	ALREADY_RUNNING = enum.auto()


class SpeechSynth():
	def __init__(self):
		if on_windows():
			pythoncom.CoInitialize()
			self.speaker = win32com.client.Dispatch("SAPI.SpVoice")
		else:
			nssp = NSSpeechSynthesizer
			self.ve = nssp.alloc().init()
			self.ve.setVoice_("com.apple.speech.synthesis.voice.Alex")

	def say(self, text):
		if on_windows():
			self.speaker.Speak(text, 1)  # async
			# FIXME TODO: get ENUM value so that's not magic number
		else:
			self.ve.startSpeakingString_(text)

	def stop(self):
		if on_windows():
			self.speaker.Speak('', 2)  # purge before speaking
			# FIXME TODO: get ENUM value so that's not magic number
		else:
			self.ve.stopSpeaking()


class EngineWrapper(threading.Thread):
	def __init__(self, command_line):
		threading.Thread.__init__(self)
		self._command_line = command_line

	def run(self):
		try:
			speaker = SpeechSynth()

			# The docs imply this shouldn't be necessary but it seems to be...
			# FIXME needed?
			if on_windows():
				self._command_line = ' '.join(self._command_line)

			# Buffering may be necessary for Windows; seems not to affect Mac
			proc = subprocess.Popen(
				self._command_line,
				bufsize=1,
				stdout=subprocess.PIPE,
				stderr=subprocess.PIPE)

			while True:
				retcode = proc.poll()
				line = proc.stdout.readline().rstrip().decode('ascii')

				length = len(line)
				if length > 0:
					# Some messages are high priority, others are critical.
					# These must be spoken instead of anything else queued up.
					if length == 1 or line[0] == '!':
						speaker.stop()

					speaker.say(line)
				else:
					# Blank line occurs after all the initialisation spewage
					speaker.stop()

				if retcode is not None:
					if retcode != 0:
						error = proc.stderr.read().decode('ascii')
						speaker.say(error)
					break
		except:  # noqa E722
			self.conduit.put(sys.exc_info())


class GameController():
	_opts_default = ("-window", "+set sensitivity 0")
	_opts_tutorial = ("+coop 0", "+deathmatch 0", "+map agtut01")
	_opts_custom_map = ("+coop 0", "+deathmatch 0")  # FIXME DRY

	def __init__(self):
		self._engine = 'zquake-gl.exe' if on_windows() else './zquake-glsdl'
		self._engine_wrapper = None

	def _running(self):
		if not self._engine_wrapper or not self._engine_wrapper.is_alive():
			return False
		elif self._engine_wrapper.is_alive():
			return True

	def _launch_core(self, command_line):
		if self._running():
			return LaunchState.ALREADY_RUNNING
		else:
			if os.path.exists(self._engine):
				self._engine_wrapper = EngineWrapper(command_line)
				self._engine_wrapper.start()
				return LaunchState.LAUNCHED
			else:
				return LaunchState.NOT_FOUND

	def launch_default(self):
		return self._launch_core((self._engine,) + self._opts_default)

	def launch_tutorial(self):
		return self._launch_core(
			(self._engine,)
			+ self._opts_default
			+ self._opts_tutorial)

	def launch_map(self, name):
		return self._launch_core(
			(self._engine,)
			+ self._opts_default
			+ self._opts_custom_map
			+ ('+map', name))

	def launch_mod(self, name):
		return self._launch_core(
			(self._engine,)
			+ self._opts_default
			+ ('-game', name))

	def quit(self):
		if self._running():
			return False
		else:
			return True
