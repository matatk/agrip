"""AudioQuake Game Launcher - Game controller"""
import enum

from launcherlib.utils import have_registered_data
from launcherlib.game_controller.engine_wrapper import EngineWrapper


class LaunchState(enum.Enum):
	LAUNCHED = enum.auto()
	NOT_FOUND = enum.auto()
	ALREADY_RUNNING = enum.auto()
	NO_REGISTERED_DATA = enum.auto()


class GameController():
	opts_default = ("-window", "+set sensitivity 0")
	opts_open_quartz = ("-rootgame", "oq")
	opts_custom_map_base = ("+coop 0", "+deathmatch 0")
	opts_tutorial = opts_custom_map_base + ("+map agtut01",)

	def __init__(self, on_error):
		self._engine_wrapper = None
		self._on_error = on_error

	def _is_running(self):
		if not self._engine_wrapper or not self._engine_wrapper.is_alive():
			return False
		elif self._engine_wrapper.is_alive():
			return True

	def _launch_core(self, options=(), game=None):
		if self._is_running():
			return LaunchState.ALREADY_RUNNING

		parameters = self.opts_default + options

		if game is None:
			if have_registered_data():
				pass  # prefer quake
			else:
				parameters += self.opts_open_quartz
		elif game == 'quake':
			if have_registered_data():
				pass  # ok
			else:
				return LaunchState.NO_REGISTERED_DATA
		elif game == 'open-quartz':
			parameters += self.opts_open_quartz
		else:
			raise TypeError(f"Invalid game name '{game}'")

		print('_launch_core():', game, parameters)
		self._engine_wrapper = EngineWrapper(parameters, self._on_error)

		if not self._engine_wrapper.engine_found():
			return LaunchState.NOT_FOUND

		self._engine_wrapper.start()
		return LaunchState.LAUNCHED

	def launch_quake(self):
		return self._launch_core(game='quake')

	def launch_open_quartz(self):
		return self._launch_core(game='open-quartz')

	def launch_tutorial(self):
		return self._launch_core(self.opts_tutorial)

	def launch_map(self, name):
		return self._launch_core(self.opts_custom_map_base + ('+map', name))

	def launch_mod(self, name):
		return self._launch_core(('-game', name))

	def quit(self):
		if self._is_running():
			return False
		else:
			return True
