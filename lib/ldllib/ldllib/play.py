'''LDL interface to Quake map playing

This is only intended to be used by the command-line LDL tool. The AudioQuake
launcher uses its own method for starting the game.'''
from os import getcwd, chdir
from pathlib import Path
from platform import system
import subprocess
import shutil

from buildlib import Config

# FIXME: Make this call the launcher with a special mode
# FIXME: sort paths
# FIXME: use build lib paths? don't see an issue; other parts of ldl use it
# FIXME: may not need this at all?
base = Path(__file__).parent.parent.parent.parent
if system() == 'Darwin':
	engine = './zquake-glsdl'
elif system() == 'Windows':
	engine = 'zquake-gl.exe'
else:
	raise NotImplementedError

maps_dir = Config.dir_dist_collated / 'data' / 'id1' / 'maps'

# FIXME: Make this call the launcher with a special mode
command_line_basis = [
	engine,
	'-window',
	'-width', '640',
	'-height', '480',
	'+deathmatch', '0',
	'+set', 'cl_confirmquit', '0',
	'+map']


def _run(map_base_name, verbose=False):
	starting_dir = getcwd()
	# FIXME: Make this call the launcher with a special mode
	chdir(Config.dir_aq_exe_internals / 'engines')  # FIXME: synch note with spec?
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


def play(bsp_file, verbose=False):
	print('Playing', bsp_file)
	shutil.copy(bsp_file, maps_dir)
	_run(bsp_file.with_suffix('').name, verbose)
