"""AudioQuake Game Launcher"""
import sys
import os
import platform
import subprocess
import threading
import wx
import enum


def on_windows(): return platform.system() == 'Windows'


class LaunchState(enum.Enum):
    OK = enum.auto()
    NOT_FOUND = enum.auto()
    ALREADY_RUNNING = enum.auto()


launch_messages = {
        LaunchState.NOT_FOUND: 'Engine not found',
        LaunchState.ALREADY_RUNNING: 'The game is already running'
        }


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
    def __init__(self, command_line, speaker):
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
                    # These need to be spoken instead of anything else queued up.
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
                self._engine_wrapper = EngineWrapper(command_line, self._tts)
                self._engine_wrapper.start()
                return LaunchState.OK
            else:
                return LaunchState.NOT_FOUND

    def launch_default(self):
        return self._launch_core((self._engine,) + self._opts_default)

    def launch_tutorial(self):
        return self._launch_core((self._engine,) + self._opts_default + self._opts_tutorial)

    def quit(self):
        if self._running():
            return False
        else:
            return True


class LauncherWindow(wx.Frame):
    def __init__(self, parent, title):
        wx.Frame.__init__(self, parent, title=title)
        self.game_controller = GameController()  # TODO !self
        sizer = wx.BoxSizer(wx.VERTICAL)

        # Commands for opening/running stuff

        if on_windows():
            self._open = ('cmd', '/c', 'start')
            self._rcon = ('cmd', '/c', 'start', 'rcon.exe', '--ask')
            self._server = ('cmd', '/c', 'start', 'zqds.exe')
        else:  # assume Mac for now (won't work on Linux)
            self._open = ('open',)
            self._rcon = ('open', './start-rcon.command')
            self._server = ('open', './start-server.command')

        # Launching the game

        btn_launch_default = wx.Button(self, -1, "Play")
        def launch_default(event):
            self.launch_button_core(self.game_controller.launch_default)
        btn_launch_default.Bind(wx.EVT_BUTTON, launch_default)
        sizer.Add(btn_launch_default, 0, wx.EXPAND, 0)

        btn_launch_tutorial = wx.Button(self, -1, "Tutorial")
        def launch_tutorial(event):
            self.launch_button_core(self.game_controller.launch_tutorial)
        btn_launch_tutorial.Bind(wx.EVT_BUTTON, launch_tutorial)
        sizer.Add(btn_launch_tutorial, 0, wx.EXPAND, 0)

        # Opening things

        btn_open_server = wx.Button(self, -1, "Server")
        def open_server(event):
            self.first_time_check('server')
            subprocess.call(self._server)
        btn_open_server.Bind(wx.EVT_BUTTON, open_server)
        sizer.Add(btn_open_server, 0, wx.EXPAND, 0)

        btn_open_rcon = wx.Button(self, -1, "Remote Console")
        def open_rcon(event):
            subprocess.call(self._rcon)
        btn_open_rcon.Bind(wx.EVT_BUTTON, open_rcon)
        sizer.Add(btn_open_rcon, 0, wx.EXPAND, 0)

        btn_open_readme = wx.Button(self, -1, "README")
        def open_readme(event):
            subprocess.call(self._open + ('README.html',))
        btn_open_readme.Bind(wx.EVT_BUTTON, open_readme)
        sizer.Add(btn_open_readme, 0, wx.EXPAND, 0)

        btn_open_manual = wx.Button(self, -1, "Manual")
        def open_manual(event):
            subprocess.call(self._open + (os.path.join('manuals', 'user-manual.html'),))
        btn_open_manual.Bind(wx.EVT_BUTTON, open_manual)
        sizer.Add(btn_open_manual, 0, wx.EXPAND, 0)

        btn_open_sound_legend = wx.Button(self, -1, "Sound Legend")
        def open_sound_legend(event):
            subprocess.call(self._open + (os.path.join('manuals', 'user-manual-part07-b.html'),))
        btn_open_sound_legend.Bind(wx.EVT_BUTTON, open_sound_legend)
        sizer.Add(btn_open_sound_legend, 0, wx.EXPAND, 0)

        btn_open_licence = wx.Button(self, -1, "LICENCE")
        def open_licence(event):
            subprocess.call(self._open + ('LICENCE.html',))
        btn_open_licence.Bind(wx.EVT_BUTTON, open_licence)
        sizer.Add(btn_open_licence, 0, wx.EXPAND, 0)

        btn_open_all_files = wx.Button(self, -1, "Show all Files")
        def open_all_files(event):
            subprocess.call(self._open + ('.',))
        btn_open_all_files.Bind(wx.EVT_BUTTON, open_all_files)
        sizer.Add(btn_open_all_files, 0, wx.EXPAND, 0)

        # Quitting

        btn_quit = wx.Button(self, -1, "Quit Launcher")
        def quit_it(event):
            if self.game_controller.quit():
                self.Close()
            else:
                Warn(self, "Can't quit whilst Quake is still running.")
        btn_quit.Bind(wx.EVT_BUTTON, quit_it)
        sizer.Add(btn_quit, 0, wx.EXPAND, 0)

        sizer.SetSizeHints(self)
        self.SetSizer(sizer)
        self.Show()

    def launch_button_core(self, method):  # TODO !self
        self.first_time_check('game')
        launch_state = method()
        if launch_state is not LaunchState.OK:
            Warn(self, launch_messages[launch_state])

    def first_time_check(self, name):  # TODO !self
        if on_windows():
            stamp_file_check(name)
        else:
            pass


def Warn(parent, message, caption = 'Warning!'):
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
    os.chdir(os.path.abspath(os.path.dirname(sys.argv[0])))
    app = wx.App(False)
    frame = LauncherWindow(None, "AudioQuake Launcher")
    app.MainLoop()
