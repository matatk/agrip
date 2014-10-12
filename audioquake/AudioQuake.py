import sys         # chdir
import os          # chdir, stamp file
import platform    # conditional stuff
import subprocess  # launching the game
import threading   # engine TTS wrapper

from GUI import Window, Button, Alerts, application

import pyttsx


class EngineWrapper(threading.Thread):
    def __init__(self, command_line, speaker):
        threading.Thread.__init__(self)
        self._command_line = command_line
        self._speaker = speaker

    def run(self):
        try:
            # The docs imply this shouldn't be necessary but it seems to be...
            if platform.system() is 'Windows':
                self._command_line = ' '.join(self._command_line)

            # Buffering may be necessary for Windows; seems not to affect Mac
            print 'Running:', self._command_line
            proc = subprocess.Popen(
                self._command_line, bufsize=1, stdout=subprocess.PIPE)

            while True:
                retcode = proc.poll()
                line = proc.stdout.readline().rstrip()

                length = len(line)
                if length > 0:
                    # Some messages are high priority, others are critical.
                    # These need to be spoken instead of anything else queued up.
                    if length is 1 or line[0] is '!':
                        print 'STOPPING'
                        self._speaker.stop()

                    print 'SAYING', line
                    self._speaker.say(line)
                else:
                    # Blank line occurs after all the initialisation spewage
                    print 'BLANK'
                    self._speaker.stop()

                print 'TICK'
                self._speaker.iterate()

                if retcode is not None:
                    break
        except:
            pass

        print 'Game thread done.'


class GameController(object):
    _engine = None
    _opts_default = ("-window", "+set sensitivity 0")
    _opts_tutorial = ("+coop 0", "+deathmatch 0", "+map agtut01")

    def __init__(self):
        if platform.system() == 'Windows':
            self._engine = 'zquake-gl.exe'
        else:  # assume Mac for now (may also work on Linux)
            self._engine = './zquake-glsdl'

        self._engine_wrapper = None
        self._tts = pyttsx.init()
        self._tts.startLoop(False)

    def _running(self):
        if not self._engine_wrapper or not self._engine_wrapper.is_alive():
            print 'Game running? No'
            return False
        elif self._engine_wrapper.is_alive():
            print 'Game running? Yes'
            return True

    def _launch_core(self, command_line):
        if self._running():
            return
        else:
            if os.path.exists(self._engine):
                # Saying something is necessary on 'doze; probably inits COM
                self._tts.say(' ')
                self._tts.iterate()
                self._engine_wrapper = EngineWrapper(command_line, self._tts)
                self._engine_wrapper.start()
                return True
            else:
                return False

    def launch_default(self):
        return self._launch_core((self._engine,) + self._opts_default)

    def launch_tutorial(self):
        # FIXME the tutorial options are ignored on Windows
        return self._launch_core((self._engine,) + self._opts_default + self._opts_tutorial)

    def quit(self, application):
        if self._running():
            return
        else:
            print 'Closing TTS...'
            self._tts.endLoop()
            print 'Quitting...'
            application.quit_cmd()
            print 'Quat!'


class LauncherSingletonWindow(Window):
    _text_viewer_command = None

    def __init__(self, application, *args, **kwargs):
        if platform.system() == 'Windows':
            self._text_viewer_command = ('cmd', '/c', 'start', 'wordpad')
        else:  # assume Mac for now (won't work on Linux)
            self._text_viewer_command = ('open', '-a', 'TextEdit')

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
            action = self.close_cmd
        ))

    def close_cmd(self):
        self._game_controller.quit(self._application)

    def _launch_button_core(self, method):
        self._first_time_check()
        result = method()
        if not result:
            self._launch_problem()

    def _btn_default(self):
        self._launch_button_core(self._game_controller.launch_default)

    def _btn_tutorial(self):
        self._launch_button_core(self._game_controller.launch_tutorial)

    def _btn_readme(self):
        subprocess.call(self._text_viewer_command + ('README.md',))

    def _btn_licence(self):
        subprocess.call(self._text_viewer_command + ('LICENCE.md',))

    def _first_time_check(self):
        if platform.system() == 'Windows':
            stamp_file_name = 'not-first-run'
            prompt = 'When the Quake engine first runs, Windows may ask you to allow it through the firewall; this will be done in a secure window that pops up above the Quake engine, which you will need an Assistive Technology (such as Narrator) to access.'
            if not os.path.exists(stamp_file_name):
                Alerts.alert('caution', prompt)
                open(stamp_file_name, 'a').close()

    def _launch_problem(self):
        Alerts.alert('stop', 'There was a problem launching the game; it is likely the Quake engine could not be found.')


if __name__ == '__main__':
    os.chdir(os.path.abspath(os.path.dirname(sys.argv[0])))
    app = application()
    launcher = LauncherSingletonWindow(app)
    launcher.show()
    app.run()
