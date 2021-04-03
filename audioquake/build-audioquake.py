#!/usr/bin/env python3
"""Get all the bits and bobs ready to build AudioQuake"""
import argparse
from os import chdir
from pathlib import Path
import re
import string
import shutil

try:
	import winshell
except ImportError:
	pass

import mistune
import mistune_contrib.toc

from buildlib import Build, \
	try_to_run, doset, doset_only, check_platform, die, comeback, prep_dir
from ldllib.build import build, swap_wad, bsp_maybe_hc
from ldllib.utils import use_repo_wads, have_wad, WADs, \
	have_needed_tools, use_repo_bins
from release import version_string, release_name


#
# Texture mapping for building .map files
#

# Note: The LDL texture mappings are done in ldl/style.xml
texture_map = {
	'*lava1': {WADs.FREE: '*lava_s2', WADs.PROTOTYPE: '*lava_64_1'},
	'+0basebtn': {WADs.FREE: '+0switch', WADs.PROTOTYPE: '+0button_1'},
	'+0slip': {WADs.FREE: '*teleport', WADs.PROTOTYPE: '*tele01'},
	'bricka2_2': {WADs.FREE: 's64h', WADs.PROTOTYPE: '64_green_3'},
	'crate0_side': {WADs.FREE: 'tsl_crate2', WADs.PROTOTYPE: 'light1_big'},
	'crate1_top': {WADs.FREE: 'tsl_crate2top', WADs.PROTOTYPE: 'light1_grt'},
	'door02_7': {WADs.FREE: 'srib2', WADs.PROTOTYPE: 'blood_1'},
	'door03_3': {WADs.FREE: 'tile', WADs.PROTOTYPE: 'cyan_1'},
	'emetal1_3': {WADs.FREE: 'strangethang', WADs.PROTOTYPE: '128_honey_1'},
	'ground1_1': {WADs.FREE: 'grass4', WADs.PROTOTYPE: '128_green_1'},
	'med100': {WADs.FREE: 'chimneytop', WADs.PROTOTYPE: '32_honey_2'},
	'metal2_4': {WADs.FREE: 'bolt10', WADs.PROTOTYPE: '128_grey_3'},  # TODO x2
	'sfloor4_1': {WADs.FREE: 'shex2', WADs.PROTOTYPE: '128_blue_3'},
	'sfloor4_6': {WADs.FREE: 'u_tex22', WADs.PROTOTYPE: '64_honey_3'},
	'sky1': {WADs.FREE: 'sky3', WADs.PROTOTYPE: 'sky1'},
	'tech01_1': {WADs.FREE: 'swire2c', WADs.PROTOTYPE: '128_grey_3'},
	'tech01_5': {WADs.FREE: 'swire4', WADs.PROTOTYPE: '128_grey_2'},
	'tech02_2': {WADs.FREE: 'bolt7', WADs.PROTOTYPE: '16_honey_1'},
	'tech03_2': {WADs.FREE: 'u_tex24', WADs.PROTOTYPE: '128_brown_2'},
	'tech04_7': {WADs.FREE: 'sriba3', WADs.PROTOTYPE: '16_cyan_1'},
	'tech06_2': {WADs.FREE: 's128z', WADs.PROTOTYPE: '128_honey_2'},
	'tech08_1': {WADs.FREE: 's128f', WADs.PROTOTYPE: '128_cyan_3'},
	'tech08_2': {WADs.FREE: 's128k', WADs.PROTOTYPE: '128_brown_3'},
	'wswitch1': {WADs.FREE: '+0u_1', WADs.PROTOTYPE: 'text_light'}
}


#
# Files to copy into final directory structure
#

# These files copied in here are going to end up outside of the launcher
# directory/bundle, so are easily publicly accessible.

# NOTE: Synch with launcherlib/dirs.py and AudioQuake.spec.

# source is relative to the <repo>/audioquake/ dir
# dest is relative to the final directory structure's root
collated_dir_files = [
	('mod-static-files/', 'data/id1'),
	('mod-conditional-files/id1/mod.cfg', 'data/id1'),
	('maps-prototypewad/*.bsp', 'data/id1/maps/'),
	('../giants/zq-repo/qc/agrip/qwprogs.dat', 'data/id1'),
	('../giants/zq-repo/qc/agrip/spprogs.dat', 'data/id1'),

	('../giants/oq-pak-src-2004.08.01/', 'data/oq'),
	('mod-static-files/', 'data/oq'),
	('mod-conditional-files/oq/mod.cfg', 'data/oq'),
	('maps-freewad/*.bsp', 'data/oq/maps/'),
	('maps-prototypewad/*.bsp', 'data/oq/maps/'),
	('../giants/zq-repo/qc/agrip/qwprogs.dat', 'data/oq'),
	('../giants/zq-repo/qc/agrip/spprogs.dat', 'data/oq'),

	('manuals-converted/', 'docs'),
	('manuals/agrip.css', 'docs'),

	('../ldl/tut*.xml', 'tutorial-maps'),
	('../ldl/test_05_*.xml', 'example-maps'),
	('../ldl/t*ldl.xml', 'example-maps')]

if next(Build.dir_maps_quakewad.glob('*.bsp'), None) is not None:
	collated_dir_files.extend([('maps-quakewad/*.bsp', 'data/id1/maps/')])


#
# Constants and state
#

skip_pyinstaller = False  # set via command-line option
force_map_build = False   # also set via CLI
needed_quake_wad = False  # detected via build_maps_for_quake()


#
# Building the maps
#

def high_contrast(map_string):
	return re.sub(r'"map" "(.+)"', r'"map" "\1hc"', map_string)


def swap_textures(map_string, to):
	for texture in texture_map:
		map_string = map_string.replace(texture, texture_map[texture][to])
	return map_string


def build_maps_for(bsp_dir, wad):
	global needed_quake_wad  # only used if wad is 'quake'
	used_cached_maps = False

	use_repo_bins(Build.base)
	use_repo_wads(Build.base)
	bsp_dir.mkdir(exist_ok=True)

	if not have_needed_tools():
		raise Exception('Quake map tools missing')

	maps = list(Build.dir_maps_source.glob('*.map'))
	maps.remove(Build.dir_maps_source / 'agdm02l.map')  # TODO: it is borked
	maps_to_build = list(maps)

	for mapfile in maps:
		bsp_name = bsp_maybe_hc(wad, mapfile)
		this_wad_mapfile = (bsp_dir / bsp_name).with_suffix('.map')
		this_wad_bspfile = this_wad_mapfile.with_suffix('.bsp')

		if force_map_build or not this_wad_bspfile.is_file() \
			or not this_wad_mapfile.is_file() \
			or this_wad_mapfile.stat().st_mtime < mapfile.stat().st_mtime:

			if not have_wad(wad, quiet=True):
				continue

			map_string = mapfile.read_text()
			map_string = swap_wad(map_string, wad)

			if wad != WADs.QUAKE:
				map_string = swap_textures(map_string, wad)
				throw_errors = True
			else:
				throw_errors = False

			if wad == WADs.PROTOTYPE:
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

	if wad == WADs.QUAKE and len(maps_to_build) > 0:
		needed_quake_wad = True


#
# Converting the manuals and other docs
#

class TocRenderer(mistune_contrib.toc.TocMixin, mistune.Renderer):
	pass


def convert_markdown_files(base_name, fancy_name, markdown_files, output_dir):
	toc = TocRenderer()
	md = mistune.Markdown(renderer=toc)
	document_template = open(Build.dir_manuals_src / 'template.html', 'r').read()
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
		sources = sorted(Build.dir_manuals_src.glob(manual_basename + '*'))
		convert_markdown_files(
			manual_basename, title, sources, Build.dir_manuals_converted)

	single_docs_to_convert = {
		'README': [Build.dir_readme_licence / 'README.md', 'README'],
		'LICENCE': [Build.dir_readme_licence / 'LICENCE.md', 'LICENCE'],
		'CHANGELOG': [Build.dir_aq / 'CHANGELOG.md', 'CHANGELOG'],
		'ACKNOWLEDGEMENTS': [
			Build.dir_aq / 'ACKNOWLEDGEMENTS.md', 'ACKNOWLEDGEMENTS'],
		'AudioQuake sound legend': [
			Build.dir_manuals_src / 'user-manual-part07-b.md', 'sound-legend'],
		'Level Description Language tutorial': [
			Build.dir_ldl / 'tutorial.md', 'ldl-tutorial']
	}

	for title, details in single_docs_to_convert.items():
		source, output = details
		convert_markdown_files(
			output, title, source, Build.dir_manuals_converted)


#
# Running PyInstaller
#

@comeback
def run_pyinstaller():
	# TODO DRY all these chdirs
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
	rcon_bin = doset(
		mac='rcon',
		windows='rcon.exe')

	shutil.copy(
		Build.dir_dist_rcon / rcon_bin,
		Build.dir_aq_exe_internals)


#
# Creating the final directory and archive
#

def make_collated_dir():
	src_base = Build.dir_aq
	dest_base = Build.dir_dist_collated

	# TODO do something with this like caching
	shutil.rmtree(dest_base, ignore_errors=True)

	for src, dest in collated_dir_files:
		src_path = src_base / src
		dest_path = dest_base / dest
		if '*' in src:  # Have to check this first on Windows
			if not dest_path.is_dir():
				dest_path.mkdir()
			for globbywobby in Build.dir_aq.glob(src):
				shutil.copy(globbywobby, dest_path, follow_symlinks=False)
		elif src_path.is_dir():
			shutil.copytree(src_path, dest_path, dirs_exist_ok=True)
		elif src_path.is_file():
			if not dest_path.is_dir():
				dest_path.mkdir()
			shutil.copy(src_path, dest_path, follow_symlinks=False)
		else:
			raise TypeError(src)


def move_app_to_collated_dir():
	source = doset(
		mac=Build.dir_dist / 'AudioQuake.app',
		windows=Build.dir_dist / 'AudioQuake')

	destination = doset(
		mac=Build.dir_dist_collated,
		windows=Build.dir_dist_collated)

	if source.is_dir() and destination.is_dir():
		shutil.move(str(source), str(destination))
	else:
		raise Exception(f'Either "{source}" or "{destination}" is not a directory!')


def windows_make_shortcut_to_app():
	pyinstaller_built_folder = Build.dir_dist_collated / 'AudioQuake'
	new_folder_path = Build.dir_dist_collated / Build.dir_windows_app
	link_path = Build.dir_dist_collated / 'AudioQuake.lnk'
	relative_path_to_exe = Path(Build.dir_windows_app) / 'AudioQuake.exe'

	print('Making Windows launcher shortcut (and renaming generated directory)')
	pyinstaller_built_folder.rename(new_folder_path)

	with winshell.shortcut(str(link_path)) as shortcut:
		shortcut.path = r'%windir%\explorer.exe'
		shortcut.arguments = '"' + str(relative_path_to_exe) + '"'
		# The icon shall be the XP-style white arrow on green background
		shortcut.icon_location = r'%SystemRoot%\System32\SHELL32.dll', 176
		shortcut.description = "AudioQuake & LDL Launcher"


def make_zip():
	program_name = 'AudioQuake+LDL'
	platform_name = doset(mac='Mac', windows='Windows')
	archive_name = f'{program_name}_{version_string}_{platform_name}'
	shutil.make_archive(
		Build.dir_dist / archive_name, 'zip', Build.dir_dist_collated)


#
# Main
#

def build_audioquake():
	print(
		'Building AudioQuake & Level Description Language',
		version_string + ': ' + release_name)

	check_platform()

	print('Converting manuals and single docs to HTML')
	prep_dir(Build.dir_manuals_converted)
	convert_manuals()  # TODO replace with a check if it needs doing

	print('Building AGRIP maps for Quake')
	build_maps_for(Build.dir_maps_quakewad, WADs.QUAKE)

	print('Building AGRIP maps for Open Quartz')
	build_maps_for(Build.dir_maps_freewad, WADs.FREE)

	print('Building AGRIP maps for high-contrast mode')
	build_maps_for(Build.dir_maps_prototypewad, WADs.PROTOTYPE)

	# Build the executables
	if not skip_pyinstaller:
		run_pyinstaller()
		copy_in_rcon()
		print('Creating distributable directory structure')
		make_collated_dir()
		move_app_to_collated_dir()
		doset_only(windows=windows_make_shortcut_to_app)
		if not args.skip_zip:
			print('Creating distributable archive')
			make_zip()

	if needed_quake_wad:
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
	BANNER = 'Build AudioQuake & Level Description Language'

	parser = argparse.ArgumentParser(description=BANNER)

	parser.add_argument(
		'-P', '--skip-pyinstaller', action='store_true',
		help=(
			"Don't run PyInstaller (and don't create the distributable "
			'directory nor archive)'))

	parser.add_argument(
		'-Z', '--skip-zip', action='store_true',
		help="Don't make the distributable archive")

	parser.add_argument(
		'-m', '--force-map-build', action='store_true',
		help='Rebuild the maps (useful for debugging texture changes)')

	args = parser.parse_args()

	skip_pyinstaller = args.skip_pyinstaller
	force_map_build = args.force_map_build

	build_audioquake()
