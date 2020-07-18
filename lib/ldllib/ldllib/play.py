'''LDL interface to Quake map playing'''
import os
import subprocess
import shutil

# FIXME hardcoded path
aq_dir = os.path.join(
	'..', 'audioquake', 'dist', 'AudioQuake.app', 'Contents', 'MacOS')

map_dir = os.path.join(aq_dir, 'id1', 'maps')

command_line_basis = [
	'./zquake-glsdl',
	'-window',
	'-width', '640',
	'-height', '480',
	'+deathmatch', '0',
	'+set', 'cl_confirmquit', '0',
	'+map']


def run(map_base_name, verbose):
	starting_dir = os.getcwd()
	os.chdir(aq_dir)
	command_line = command_line_basis + [map_base_name]
	try:
		res = subprocess.run(command_line, capture_output=True, check=True)
		if verbose is True:
			print(res.stdout.decode())
	except subprocess.SubprocessError:
		print('There was an error running ZQuake - details follow')
		subprocess.run(command_line)
	os.chdir(starting_dir)


def play(bsp_file_name, basename, verbose):
	print('Playing', bsp_file_name)
	shutil.copy(bsp_file_name, map_dir)
	run(basename, verbose)
