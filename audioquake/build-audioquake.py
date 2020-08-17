#!/usr/bin/env python3
"""Get all the bits and bobs ready to build AudioQuake"""
import argparse
from os import chdir
from pathlib import Path
import re
import string
import shutil

import mistune
import mistune_contrib.toc

from buildlib import Config, \
	try_to_run, platform_set, check_platform, die, comeback, prep_dir
from ldllib.build import build, have_needed_progs, use_repo_bins, \
	swap_wad, hc_variant
from ldllib.convert import use_repo_wads, have_wad_for

texture_map = {
	'*lava1': {'free': '*lava_s2', 'prototype': '*lava_64_1'},
	'+0basebtn': {'free': '+0switch', 'prototype': '+0button_1'},
	'+0slip': {'free': '*teleport', 'prototype': '*tele01'},
	'bricka2_2': {'free': 'bricks256', 'prototype': '64_green_3'},
	'crate0_side': {'free': 'tsl_crate2', 'prototype': 'light1_big'},
	'crate1_top': {'free': 'tsl_crate2top', 'prototype': 'light1_grt'},
	'door02_7': {'free': 'srib2', 'prototype': 'blood_1'},
	'door03_3': {'free': 'tile', 'prototype': 'cyan_1'},
	'emetal1_3': {'free': 'strangethang', 'prototype': '128_honey_1'},
	'ground1_1': {'free': 'grass4', 'prototype': '128_green_1'},
	'med100': {'free': 'chimneytop', 'prototype': '32_honey_2'},
	'metal2_4': {'free': 'bolt10', 'prototype': '128_grey_3'},  # TODO as below
	'sfloor4_1': {'free': 'shex2', 'prototype': '128_blue_3'},
	'sfloor4_6': {'free': 'u_tex22', 'prototype': '64_honey_3'},
	'sky1': {'free': 'sky3', 'prototype': 'sky1'},
	'tech01_1': {'free': 'swire2c', 'prototype': '128_grey_3'},
	'tech01_5': {'free': 'swire4', 'prototype': '128_grey_2'},
	'tech02_2': {'free': 'bolt7', 'prototype': '16_honey_1'},
	'tech03_2': {'free': 'u_tex24', 'prototype': '128_brown_2'},
	'tech04_7': {'free': 'sriba3', 'prototype': '16_cyan_1'},
	'tech06_2': {'free': 's128z', 'prototype': '128_honey_2'},
	'tech08_1': {'free': 's128f', 'prototype': '128_cyan_3'},
	'tech08_2': {'free': 's128k', 'prototype': '128_brown_3'},
	'wswitch1': {'free': '+0u_1', 'prototype': 'text_light'}
}

skip_pyinstaller = False           # set via command-line option
force_map_build = False            # also set via CLI

maps_were_built_for_quake = False  # detected via build_maps_for_quake()


#
# Building the maps
#

def high_contrast(map_string):
	return re.sub(r'"map" "(.+)"', r'"map" "\1hc"', map_string)


def swap_textures(map_string, to):
	for texture in texture_map:
		map_string = map_string.replace(texture, texture_map[texture][to])
	return map_string


def build_maps_for(bsp_dir, key):
	global maps_were_built_for_quake  # only used if key is 'quake'
	used_cached_maps = False

	use_repo_bins()
	use_repo_wads(root=Config.base)
	bsp_dir.mkdir(exist_ok=True)

	if not have_needed_progs():
		raise Exception('Quake map tools missing')

	maps = list(Config.dir_maps_source.glob('*.map'))
	maps.remove(Config.dir_maps_source / 'agdm02l.map')  # TODO: it is borked
	maps_to_build = list(maps)  # i.e. copy

	for mapfile in maps:
		map_name = hc_variant(key, mapfile)
		this_wad_mapfile = bsp_dir / map_name
		this_wad_bspfile = this_wad_mapfile.with_suffix('.bsp')

		if force_map_build or not this_wad_bspfile.is_file() \
			or not this_wad_mapfile.is_file() \
			or this_wad_mapfile.stat().st_mtime < mapfile.stat().st_mtime:

			if not have_wad_for(key, quiet=True):
				continue

			map_string = mapfile.read_text()
			map_string = swap_wad(map_string, key)

			if key != 'quake':
				map_string = swap_textures(map_string, key)
				throw_errors = True
			else:
				throw_errors = False

			if key == 'prototype':
				map_string = high_contrast(map_string)

			this_wad_mapfile.write_text(map_string)
			build(this_wad_mapfile, throw=throw_errors, quiet=True)
		else:
			used_cached_maps = True

		maps_to_build.remove(mapfile)

	if len(maps_to_build) > 0:
		print(len(maps_to_build), 'maps left to build (may need WAD file)')
	elif used_cached_maps:
		print('all maps were retrieved from the cache or built')
	else:
		print('all maps were built')

	if key == 'quake' and len(maps_to_build) == 0:
		maps_were_built_for_quake = True


#
# Converting the manuals and other docs
#

class TocRenderer(mistune_contrib.toc.TocMixin, mistune.Renderer):
	pass


def convert_markdown_files(base_name, fancy_name, markdown_files, output_dir):
	toc = TocRenderer()
	md = mistune.Markdown(renderer=toc)
	document_template = open(Config.dir_manuals / 'template.html', 'r').read()
	source = ''

	if not isinstance(markdown_files, list):
		markdown_files = [markdown_files]

	for markdown_file in markdown_files:
		source += open(markdown_file, 'r', encoding='utf-8').read()

	toc.reset_toc()
	html_content = md.parse(source)
	html_toc = toc.render_toc(level=3)

	full_document = string.Template(document_template).substitute(
		title=fancy_name,
		toc=html_toc,
		content=html_content)

	open(output_dir / (base_name + '.html'), 'w').write(full_document)


def convert_manuals():
	manuals = {
		'AudioQuake User Manual': 'user-manual',
		'AudioQuake Development Manual': 'development-manual'
	}

	for title, manual_basename in manuals.items():
		sources = sorted(Config.dir_manuals.glob(manual_basename + '*'))
		convert_markdown_files(
			manual_basename, title, sources, Config.dir_manuals_converted)

	single_docs_to_convert = {
		'README': [Config.dir_readme_licence / 'README.md', 'README'],
		'LICENCE': [Config.dir_readme_licence / 'LICENCE.md', 'LICENCE'],
		'AudioQuake sound legend': [
			Config.dir_manuals / 'user-manual-part07-b.md',
			'sound-legend'
		],
		'Level Description Language tutorial': [
			Config.dir_ldl / 'tutorial.md',
			'ldl-tutorial'
		]
	}

	for title, details in single_docs_to_convert.items():
		source, output = details
		convert_markdown_files(
			output, title, source, Config.dir_manuals_converted)


#
# Running PyInstaller
#

@comeback
def run_pyinstaller():
	# FIXME DRY all these chdirs
	path = Path(__file__).parent
	try:
		chdir(path)
	except:  # noqa E727
		die("can't change directory to: " + path)

	for spec in ['AudioQuake.spec', 'rcon.spec']:
		print('Running PyInstaller on ' + spec)
		try_to_run(
			('pyinstaller', '-y', spec),
			'failed to run PyInstaller on ' + spec)


def copy_in_rcon():
	rcon_bin = platform_set(
		mac='rcon',
		windows='rcon.exe')

	shutil.copy(
		Config.dir_dist_rcon / rcon_bin,
		Config.dir_aq_data)


def build_audioquake():
	with open(Config.file_aq_release, 'r') as f:
		print(
			'Building AudioQuake',
			f.readline().rstrip() + ':', f.readline().rstrip())

	check_platform()

	print('Converting manuals and single docs to HTML')
	prep_dir(Config.dir_manuals_converted)
	convert_manuals()  # TODO replace with a check if it needs doing

	print('Building AGRIP maps for Quake')
	build_maps_for(Config.dir_maps_quakewad, 'quake')

	print('Building AGRIP maps for Open Quartz')
	build_maps_for(Config.dir_maps_freewad, 'free')

	print('Building AGRIP maps for high-contrast mode')
	build_maps_for(Config.dir_maps_prototypewad, 'prototype')

	# Build the executables
	if not skip_pyinstaller:
		run_pyinstaller()
		copy_in_rcon()
		print('Completed building AudioQuake with Level Description Language.')
		print('Output directory:', Config.dir_dist)
	else:
		print('Skipping running PyInstaller')

	if not maps_were_built_for_quake:
		print(
			'\nPlease note: the "quake.wad" file, containing id Software\'s '
			'Quake textures, is not present in the AudioQuake distributable '
			'directory. This means the AGRIP maps have not been built for '
			'Quake. That needs to happen in order to make a redistributable '
			'version of AudioQuake and the Level Description Language.\n\n'

			'You can make "quake.wad" by running AudioQuake directly from the '
			'distributable directory, and using the launcher\'s "Install '
			'registered Quake data" feature. Then re-run the build process, '
			'and the WAD file will be picked up, and the maps will be '
			'compiled.\n\n'

			'The "quake.wad" file itself should not be redistributed.')


if __name__ == '__main__':
	BANNER = 'Build AudioQuake'

	parser = argparse.ArgumentParser(description=BANNER)

	parser.add_argument(
		'-s', '--skip-pyinstaller', action='store_true',
		help="Don't run PyInstaller (used for debugging manual conversion)")

	parser.add_argument(
		'-f', '--force-map-build', action='store_true',
		help='Rebuild the maps (useful for debugging texture changes)')

	args = parser.parse_args()

	skip_pyinstaller = args.skip_pyinstaller
	force_map_build = args.force_map_build

	build_audioquake()
