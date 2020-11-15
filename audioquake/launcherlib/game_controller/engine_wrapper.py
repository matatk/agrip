"""AudioQuake & LDL Launcher - Game controller - Engine wrapper"""
from pathlib import Path
import threading
import subprocess

from buildlib import doset, doset_only
from launcherlib import dirs
from launcherlib.game_controller.speech_synth import SpeechSynth


class EngineWrapper(threading.Thread):
	def __init__(self, args, on_error):
		threading.Thread.__init__(self)
		self._engine = doset(
			mac=dirs.engines / 'zquake-glsdl',
			windows=dirs.engines / 'zquake-gl.exe')
		self._command_line = (self._engine,) + args
		self._on_error = on_error

	def engine_found(self):
		return Path(self._engine).is_file()

	def run(self):
		try:
			speaker = SpeechSynth()

			# The docs imply this shouldn't be necessary but it is...
			def reassign_commandline():
				self._command_line = ' '.join(str(part) for part in self._command_line)
			doset_only(windows=reassign_commandline)

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
						self._on_error(error)
					break
		except:  # noqa E722
			self._on_error()
