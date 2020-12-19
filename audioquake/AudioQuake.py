"""AudioQuake & LDL Launcher"""
from platform import system
import argparse

from buildlib import doset_only
import launcherlib.config as config
import launcherlib.dirs as dirs
from launcherlib.game_controller import GameController
from launcherlib.utils import error_message_and_title


def text_error_hook():
	message, title = error_message_and_title()
	print(f'{title}: {message}')


def gui_main(game_controller, args):
	import sys

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


def list_mods(game_controller, args):
	# FIXME: implement :-)
	print('list mods - TODO!')


def play_map(game_controller, args):
	if system() == 'Windows' and config.first_game_run:
		print(
			'Sorry, you must run AudioQuake from the GUI launcher for the '
			'first time on Windows. You may then run it from the command line.')
	else:
		game_controller.launch_map(args.map)


if __name__ == '__main__':
	config.init(dirs.config)
	game_controller = GameController()
	game_controller.set_error_handler(text_error_hook)

	BANNER = 'AudioQuake & Level Description Language Launcher'

	parser = argparse.ArgumentParser(
		description=BANNER,
		epilog='There is a separate LDL command-line tool in the AGRIP repo.')
	subparsers = parser.add_subparsers(
		title='actions',
		description='issue "{action} -h/--help" for more help on each one',
		help='By default the Launcher will start in GUI mode')

	ls_mods_cmd = subparsers.add_parser('list-mods', help='List installed mods')
	ls_mods_cmd.set_defaults(func=list_mods)

	map_cmd = subparsers.add_parser('map', help='Boot into a particular map')
	map_cmd.add_argument('map', help="The map's name without trailing '.bsp'")
	map_cmd.set_defaults(func=play_map)

	parser.set_defaults(func=gui_main)

	args = parser.parse_args()
	args.func(game_controller, args)
