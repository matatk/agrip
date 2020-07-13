"""AudioQuake Game Launcher - Game controller"""
import enum
import os

from launcherlib.utils import on_windows
from launcherlib.game_controller.engine_wrapper import EngineWrapper


class LaunchState(enum.Enum):
	LAUNCHED = enum.auto()
	NOT_FOUND = enum.auto()
	ALREADY_RUNNING = enum.auto()


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
