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
	prep_dir, try_to_run, platform_set, check_platform, die, comeback

from ldllib.build import build, have_needed_stuff, set_wad_file, use_repo_bins

wad_map = {
	'quake': 'quake.wad',  # FIXME this doesn't represent a replacement yet
	'free': 'free.wad',
	'prototype': 'prototype_1_2.wad'
}

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
	'sfloor4_1': {'free': 'u_tex22', 'prototype': '128_blue_3'},
	'sfloor4_6': {'free': 'tsl_hex1', 'prototype': '64_honey_3'},
	'sky1': {'free': 'sky3', 'prototype': 'sky1'},
	'tech01_1': {'free': 'swire2a', 'prototype': '128_grey_3'},
	'tech01_5': {'free': 'swire4', 'prototype': '128_grey_2'},
	'tech02_2': {'free': 'tsl_2', 'prototype': '16_honey_1'},
	'tech03_2': {'free': 'u_tex24', 'prototype': '128_brown_2'},
	'tech04_7': {'free': 'sriba3', 'prototype': '16_cyan_1'},
	'tech06_2': {'free': 'tsl_light1', 'prototype': '128_honey_2'},
	'tech08_1': {'free': 'tsl_1', 'prototype': '128_cyan_3'},
	'tech08_2': {'free': 'smetal64a', 'prototype': '128_brown_3'},
	'wswitch1': {'free': '+0u_1', 'prototype': 'text_light'}
}

skip_pyinstaller = False           # set via command-line option
force_map_build = False            # also set via CLI

maps_were_built_for_quake = False  # detected via build_maps_for_quake()


#
# Building the maps
#

def swap_wad(map_string, to):
	return map_string.replace('"wad" "quake.wad"', f'"wad" "{wad_map[to]}"')


def make_following_map_high_contrast(map_string):
	return re.sub(r'"map" "(.+)"', r'"map" "\1hc"', map_string)


def swap_textures(map_string, to):
	for texture in texture_map:
		map_string = map_string.replace(texture, texture_map[texture][to])
	return map_string


def build_maps_for(bsp_dir, key):
	global maps_were_built_for_quake  # only used if key is 'quake'
	used_cached_maps = False

	use_repo_bins()
	set_wad_file(wad_map[key])
	bsp_dir.mkdir(exist_ok=True)

	if have_needed_stuff():
		maps = Config.dir_maps_source.glob('*.map')

		for mapfile in maps:
			if mapfile.name == 'agdm02l.map':
				continue  # TODO that map's borked

			if key == 'prototype':  # implies high contrast mode
				map_name = mapfile.stem + 'hc' + mapfile.suffix
			else:
				map_name = mapfile.name

			this_wad_mapfile = bsp_dir / map_name
			this_wad_bspfile = this_wad_mapfile.with_suffix('.bsp')

			if force_map_build or not this_wad_bspfile.is_file() \
				or not this_wad_mapfile.is_file() \
				or this_wad_mapfile.stat().st_mtime < mapfile.stat().st_mtime:
				map_string = mapfile.read_text()
				map_string = swap_wad(map_string, key)

				if key != 'quake':
					map_string = swap_textures(map_string, key)

				if key == 'prototype':
					map_string = make_following_map_high_contrast(map_string)

				this_wad_mapfile.write_text(map_string)
				build(this_wad_mapfile, False)
			else:
				used_cached_maps = True

		if used_cached_maps:
			print('Cached maps were used')

		if key == 'quake':
			maps_were_built_for_quake = True
	else:
		if key != 'quake':
			raise Exception('Build tools missing')


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
		print('Converting', manual_basename)
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
		print('Converting ' + output)
		convert_markdown_files(output, title, source, Config.dir_manuals_converted)


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

	print('Preparing converted (HTML) manual dir')
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
			'Quake textures, is not present in the current directory. This '
			'means the AGRIP maps have not been built for Quake. That needs '
			'to happen in order to make a redistributable version of '
			'AudioQuake and the Level Description Language.\n\n'

			'You can make "quake.wad" by using the launcher\'s "Install '
			'registered Quake data" feature. Copy "quake.wad" to this '
			'directory, re-run the build process, and the maps will be '
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
