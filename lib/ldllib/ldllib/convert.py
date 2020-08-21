'''LDL XML-to-map Converter'''
from pathlib import Path
from platform import system

from .level_00_down_map2mapxml import main as level0
from .level_01_down_brushsizes import main as level1
from .level_02_down_rooms import main as level2
from .level_03_down_lighting import main as level3
from .level_04_down_buildermacros import main as level4
from .level_05_down_connections import main as level5
from .utils import keep, set_verbosity

WAD_CHOICES = ['quake', 'free', 'prototype']
DEFAULT_WAD = 'quake'

# Assume the WAD files are in the current directory
wad_files = {
	'quake': Path('quake.wad'),
	'free': Path('free_wad.wad'),
	'prototype': Path('prototype_1_2.wad')
}


def use_repo_wads(root=None):
	# If being called from LDL, the base path is one level up. If being run as
	# part of the AudioQuake build process, the absolute base path can be
	# passed in.
	# FIXME: If running LDL from a different directory... ?
	base = root if root else Path('..')

	if system() == 'Darwin':
		wad_files['quake'] = base / 'audioquake' / 'dist' \
			/ 'AudioQuake.app' / 'Contents' / 'MacOS' / 'quake.wad'
	elif system() == 'Windows':
		wad_files['quake'] = base / 'audioquake' / 'dist' \
			/ 'AudioQuake' / 'quake.wad'
	else:
		raise NotImplementedError

	wad_files['free'] = base / 'giants' / 'oq-pak-src-2004.08.01' / 'maps' / \
		'textures' / 'free_wad.wad'
	wad_files['prototype'] = base / 'giants' / 'prototype_wad_1_2' / \
		'prototype_1_2.wad'


def have_wad_for(name):
	if not wad_files[name].is_file():
		print(f'ERROR: Missing {wad_files[name]}')
		return False
	return True


def convert(
	xml_file, wad=DEFAULT_WAD, verbose=False, keep_intermediate=False):
	print('Converting', xml_file, 'using', wad, 'textures')
	set_verbosity(verbose)

	ldl_string = xml_file.read_text()
	without_ext = xml_file.with_suffix('')

	level4string = level5(ldl_string)
	keep(keep_intermediate, 4, without_ext, level4string)
	level3string = level4(level4string)
	keep(keep_intermediate, 3, without_ext, level3string)
	level2string = level3(level3string)
	keep(keep_intermediate, 2, without_ext, level2string)
	level1string = level2(level2string, wad)
	keep(keep_intermediate, 1, without_ext, level1string)
	level0string = level1(level1string)
	keep(keep_intermediate, 0, without_ext, level0string)
	mapfile = level0(level0string, wad_files[wad])

	with xml_file.with_suffix('.map').open('w') as outfile:
		outfile.write(mapfile)
