"""AudioQuake & LDL Launcher"""
import argparse

from buildlib import doset_only
from launcherlib.config import init as init_config
import launcherlib.dirs as dirs
from launcherlib.ui.launcher import LauncherWindow
from launcherlib.ui.helpers import Warn, error_hook


def gui_main(args):
	import sys
	import wx

	app = wx.App()
	sys.excepthook = error_hook

	try:
		init_config(dirs.config)
		LauncherWindow(None, "AudioQuake & LDL Launcher").Show()
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


def list_mods(args):
	print('list mods')


def play(args):
	print('play', args.mod, args.map)


if __name__ == '__main__':
	BANNER = 'AudioQuake & Level Description Language Launcher'

	# FIXME always init config first; refuse to use CLI on first run
	# FIXME separate game controller from GUI
	# FIXME pass settings to game controller (isn't this already done?)

	parser = argparse.ArgumentParser(
		description=BANNER,
		epilog='There is a separate LDL command-line tool in the AGRIP repo.')
	subparsers = parser.add_subparsers(
		title='actions',
		description='issue "{action} -h/--help" for more help on each one',
		help='By default the Launcher will start in GUI mode')

	mods_cmd = subparsers.add_parser('list-mods', help='List installed mods')
	mods_cmd.set_defaults(func=list_mods)

	play_cmd = subparsers.add_parser(
		'play', help='Boot into a particular mod and map')
	play_cmd.add_argument('mod', help="The mod's directory name")
	play_cmd.add_argument(
		'map', nargs='?', help="The map's name without trailing '.bsp'")
	play_cmd.set_defaults(func=play)

	parser.set_defaults(func=gui_main)

	args = parser.parse_args()
	args.func(args)
