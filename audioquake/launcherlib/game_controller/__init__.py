"""AudioQuake Game Launcher - Game controller"""
import enum
import os

from launcherlib.utils import on_windows, have_registered_data
from launcherlib.game_controller.engine_wrapper import EngineWrapper


class LaunchState(enum.Enum):
	LAUNCHED = enum.auto()
	NOT_FOUND = enum.auto()
	ALREADY_RUNNING = enum.auto()
	NO_REGISTERED_DATA = enum.auto()


class GameController():
	_opts_default = ("-window", "+set sensitivity 0")
	_opts_open_quartz = ("-rootgame", "oq")
	_opts_custom_map_base = ("+coop 0", "+deathmatch 0")
	_opts_tutorial = _opts_custom_map_base + ("+map agtut01",)

	def __init__(self, on_error):
		self._engine = 'zquake-gl.exe' if on_windows() else './zquake-glsdl'
		self._engine_wrapper = None
		self._on_error = on_error

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
				if not have_registered_data():
					command_line += self._opts_open_quartz
				self._engine_wrapper = EngineWrapper(command_line, self._on_error)
				self._engine_wrapper.start()
				return LaunchState.LAUNCHED
			else:
				return LaunchState.NOT_FOUND

	def launch_default(self):
		if have_registered_data():
			return self._launch_core((self._engine,) + self._opts_default)
		else:
			return LaunchState.NO_REGISTERED_DATA

	def launch_open_quartz(self):
		return self._launch_core(
			(self._engine,) + self._opts_default + self._opts_open_quartz)

	def launch_tutorial(self):
		return self._launch_core(
			(self._engine,)
			+ self._opts_default
			+ self._opts_tutorial)

	def launch_map(self, name):
		return self._launch_core(
			(self._engine,)
			+ self._opts_default
			+ self._opts_custom_map_base
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
