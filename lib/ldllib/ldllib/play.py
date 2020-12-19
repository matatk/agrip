'''LDL interface to Quake map playing

This is only intended to be used by the command-line LDL tool. The AudioQuake
launcher uses its own method for starting the game.'''
from platform import system
import subprocess
import shutil

from buildlib import Build

MAPS_DIR = Build.dir_dist_collated / 'data' / 'id1' / 'maps'

if system() == 'Darwin':
	# TODO: Couldn't use dir_aq_exe_internals but it's almost right
	LAUNCHER = Build.dir_dist_collated / 'AudioQuake.app' / 'Contents' \
		/ 'MacOS' / 'AudioQuake'
elif system() == 'Windows':
	LAUNCHER = Build.dir_dist_collated / 'AudioQuake' / 'AudioQuake.exe'
else:
	raise NotImplementedError


def _run(map_base_name, verbose=False):
	command_line = [LAUNCHER, 'map', map_base_name]
	try:
		res = subprocess.run(command_line, capture_output=True, check=True)
		if verbose is True:
			print(res.stdout.decode())
	except subprocess.CalledProcessError:
		print('There was an error running the game - details follow')
		print()
		subprocess.run(command_line)
		print()
		print('You may need to build AudioQuake and import the registered data.')


def play(bsp_file, verbose=False):
	print('Playing', bsp_file)
	shutil.copy(bsp_file, MAPS_DIR)
	_run(bsp_file.with_suffix('').name, verbose)
