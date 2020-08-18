"""AudioQuake Game Launcher - Game controller - Speech synth"""
from launcherlib.utils import on_windows

if on_windows():
	import pythoncom
	import win32com.client
else:
	from AppKit import NSSpeechSynthesizer


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
			# TODO: get ENUM value so that's not magic number
		else:
			self.ve.startSpeakingString_(text)

	def stop(self):
		if on_windows():
			self.speaker.Speak('', 2)  # purge before speaking
			# TODO: get ENUM value so that's not magic number
		else:
			self.ve.stopSpeaking()
