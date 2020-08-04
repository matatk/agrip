"""AudioQuake Game Launcher - Game controller - Engine wrapper"""
import threading
import subprocess
import sys

from launcherlib.utils import on_windows
from launcherlib.game_controller.speech_synth import SpeechSynth


class EngineWrapper(threading.Thread):
	def __init__(self, command_line, on_error):
		threading.Thread.__init__(self)
		self._command_line = command_line
		self._on_error = on_error

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
						self._on_error(error)
					break
		except:  # noqa E722
			self.conduit.put(sys.exc_info())
