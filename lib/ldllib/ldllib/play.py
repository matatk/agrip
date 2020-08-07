'''LDL interface to Quake map playing

This is only intended to be used by the command-line LDL tool. The AudioQuake
launcher uses its own method for starting the game.'''
from os import getcwd, chdir
from os.path import basename
from pathlib import Path
import subprocess
import shutil

base = Path(__file__).parent.parent.parent.parent
aq_dir = base / 'audioquake' / 'dist' / 'AudioQuake.app' / 'Contents' / 'MacOS'
maps_dir = aq_dir / 'id1' / 'maps'

command_line_basis = [
	'./zquake-glsdl',
	'-window',
	'-width', '640',
	'-height', '480',
	'+deathmatch', '0',
	'+set', 'cl_confirmquit', '0',
	'+map']


def _run(map_base_name, verbose):
	starting_dir = getcwd()
	chdir(aq_dir)
	command_line = command_line_basis + [map_base_name]
	try:
		res = subprocess.run(command_line, capture_output=True, check=True)
		if verbose is True:
			print(res.stdout.decode())
	except subprocess.CalledProcessError:
		print('There was an error running ZQuake - details follow')
		subprocess.run(command_line)
		print()
		print('You may need to build AudioQuake and import the registered data.')
	chdir(starting_dir)


def play(bsp_file_name, verbose):
	without_ext = bsp_file_name[:-4]
	print('Playing', bsp_file_name)
	shutil.copy(bsp_file_name, maps_dir)
	_run(basename(without_ext), verbose)
