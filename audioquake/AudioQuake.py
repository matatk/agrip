"""AudioQuake & LDL Launcher"""
import argparse
import sys

from buildlib import doset_only
import launcherlib.config as config
import launcherlib.dirs as dirs
from launcherlib.game_controller import GameController
from launcherlib.utils import error_message_and_title, format_bindings_as_text


#
# Modes
#

def gui_main(game_controller, args):
	import wx

	from launcherlib.ui.launcher import LauncherWindow
	from launcherlib.ui.helpers import Warn, gui_error_hook

	app = wx.App()
	sys.excepthook = gui_error_hook
	game_controller.set_error_handler(gui_error_hook)

	try:
		LauncherWindow(
			None, "AudioQuake & LDL Launcher", game_controller).Show()
		app.MainLoop()
	except OSError:
		doset_only(mac=lambda: Warn(None, (
			'The code behind AudioQuake, Level Description Language and '
			"supporting tools is not signed, so it can't be verified by "
			'Apple.\n\n'

			'If you still want to run them, move this application somewhere '
			'else on your computer and re-open it.\n\n'

			"If you've already done that, you may need to grant permission "
			'for the application to access certain folders, in System '
			'Preferences > Security & Privacy > Privacy tab.')))


def play_map(game_controller, args):
	_play_core(lambda: game_controller.launch_map(args.name))


def list_mods(game_controller, args):
	print('list mods - TODO!')  # FIXME: implement :-)


def play_mod(game_controller, args):
	# FIXME: check valid mod
	_play_core(lambda: game_controller.launch_mod(args.dir))


def list_keys(game_controller, args):
	config_bindings, autoexec_bindings = format_bindings_as_text()
	print('config.cfg bindings')
	print("\n".join(config_bindings))
	print()
	print('autoexec.cfg bindings')
	print("\n".join(autoexec_bindings))


#
# Helpers
#

def text_error_hook(etype, value, traceback):
	message, title = error_message_and_title(etype, value, traceback)
	print(f'{title}: {message}')


def windows_chdir():
	"""If the shortcut is used, the working directory will be the system
	directory, which is not a nice place to try to build maps."""
	from os import chdir
	chdir(dirs.root)


def cli_first_time_windows_check():
	if config.first_game_run():
		print(
			'Sorry, you must run AudioQuake from the GUI launcher for the '
			'first time on Windows. You may then run it from the command line.')
		sys.exit(42)


def _play_core(action):
	doset_only(windows=cli_first_time_windows_check)
	result = action()
	print('Result of launching game:', result)


if __name__ == '__main__':
	sys.excepthook = text_error_hook
	game_controller = GameController()
	game_controller.set_error_handler(text_error_hook)
	config.init(dirs.config)
	doset_only(windows=windows_chdir)

	parser = argparse.ArgumentParser(
		description='AudioQuake & Level Description Language Launcher',
		epilog='There is a separate LDL command-line tool in the AGRIP repo.')
	subparsers = parser.add_subparsers(
		title='actions',
		description='issue "{action} -h/--help" for more help on each one',
		help='By default the Launcher will start in GUI mode')

	map_cmd = subparsers.add_parser(
		'map', help='Boot into a particular map (via Quake or Open Quartz)')
	map_cmd.add_argument('name', help="The map's name without trailing '.bsp'")
	map_cmd.set_defaults(func=play_map)

	ls_mods_cmd = subparsers.add_parser('list-mods', help='List installed mods')
	ls_mods_cmd.set_defaults(func=list_mods)

	mod_cmd = subparsers.add_parser('mod', help='Boot into a particular mod')
	mod_cmd.add_argument('dir', help="The mod's directory name")
	mod_cmd.set_defaults(func=play_mod)

	ls_keys_cmd = subparsers.add_parser('list-keys', help='List key bindings')
	ls_keys_cmd.set_defaults(func=list_keys)

	parser.set_defaults(func=gui_main)
	args = parser.parse_args()
	args.func(game_controller, args)
