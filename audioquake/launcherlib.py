"""Launcher Gubbins"""
import enum
import platform
import threading
import subprocess
import os


def on_windows(): return platform.system() == 'Windows'


class LaunchState(enum.Enum):
    OK = enum.auto()
    NOT_FOUND = enum.auto()
    ALREADY_RUNNING = enum.auto()


class SpeechSynth():
    def __init__(self):
        if on_windows():
            raise NotImplementedError
        else:
            from AppKit import NSSpeechSynthesizer
            nssp = NSSpeechSynthesizer
            self.ve = nssp.alloc().init()
            self.ve.setVoice_("com.apple.speech.synthesis.voice.Alex")

    def say(self, text):
        if on_windows():
            raise NotImplementedError
        else:
            self.ve.startSpeakingString_(text)

    def stop(self):
        if on_windows():
            raise NotImplementedError
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
            print('Running:', self._command_line)
            proc = subprocess.Popen(
                    self._command_line, bufsize=1, stdout=subprocess.PIPE)

            while True:
                retcode = proc.poll()
                line = proc.stdout.readline().rstrip().decode('ascii')

                length = len(line)
                if length > 0:
                    # Some messages are high priority, others are critical.
                    # These must be spoken instead of anything else queued up.
                    if length is 1 or line[0] is '!':
                        print('STOPPING')
                        speaker.stop()

                    print('SAYING', line)
                    speaker.say(line)
                else:
                    # Blank line occurs after all the initialisation spewage
                    print('BLANK')
                    speaker.stop()

                # print('TICK')
                # speaker.iterate()

                if retcode is not None:
                    break
        except:
            raise

        print('Game thread done.')


class GameController():
    _engine = None
    _opts_default = ("-window", "+set sensitivity 0")
    _opts_tutorial = ("+coop 0", "+deathmatch 0", "+map agtut01")

    def __init__(self):
        if on_windows():
            self._engine = 'zquake-gl.exe'
        else:  # assume Mac for now (may also work on Linux)
            self._engine = './zquake-glsdl'

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
                return LaunchState.OK
            else:
                return LaunchState.NOT_FOUND

    def launch_default(self):
        return self._launch_core((self._engine,) + self._opts_default)

    def launch_tutorial(self):
        return self._launch_core((self._engine,)
                                 + self._opts_default
                                 + self._opts_tutorial)

    def quit(self):
        if self._running():
            return False
        else:
            return True
