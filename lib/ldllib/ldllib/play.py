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
	# TODO: Synch note
	LAUNCHER = Build.dir_dist_collated / 'AudioQuake.app' / 'Contents' \
		/ 'MacOS' / 'AudioQuake'
elif system() == 'Windows':
	# TODO: Synch note
	LAUNCHER = Build.dir_dist_collated / 'app-support-files' / 'AudioQuake.exe'
else:
	raise NotImplementedError


def _run(map_base_name, verbose=False):
	command_line = [LAUNCHER, 'map', map_base_name]
	try:
		res = subprocess.run(command_line, capture_output=True, check=True)
		if verbose is True:
			print(res.stdout.decode())
	except subprocess.CalledProcessError:
		if system() == 'Windows':
			print(
				'There was an error running AudioQuake. Unfortunately on '
				'Windows it is not possible to give you the details, but '
				'make sure you have run the game at least once via the GUI '
				'(as this is needed on Windows).')
		else:
			print('There was an error running AudioQuake; details follow.')
			subprocess.run(command_line)


def play(bsp_file, verbose=False):
	print('Playing', bsp_file)
	shutil.copy(bsp_file, MAPS_DIR)
	_run(bsp_file.with_suffix('').name, verbose)
