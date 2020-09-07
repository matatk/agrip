#!/usr/bin/env python3
"""Build the engine, QuakeC compiler, gamecode and map tools"""
import os

import patch_ng as patch

from buildlib import Config, \
	comeback, check_platform, doset, doset_only, make, die, try_to_run


#
# Engine compilation
#

def compile_zqcc():
	make(Config.dir_make_zqcc, 'zqcc')


def compile_zquake():
	make(Config.dir_make_zquake, 'zquake', ['gl', 'server'])


def compile_zquake_windows():
	path = Config.dir_zquake_source
	try:
		os.chdir(path)
	except:  # noqa E727
		die("can't change directory to: " + path)
	try_to_run(
		['msbuild', 'zquake.sln', '/p:Configuration=GLRelease', '/p:Platform=Win32'],
		'ZQuake compilation')


def compile_zqcc_windows():  # FIXME DRY
	path = Config.dir_make_zqcc
	try:
		os.chdir(path)
	except:  # noqa E727
		die("can't change directory to: " + path)
	try_to_run(
		['msbuild', 'zqcc.sln', '/p:Configuration=Release', '/p:Platform=Win32'],
		'ZQCC compilation')


#
# QuakeC Compilation
#

@comeback
def compile_gamecode():
	try:
		os.chdir(Config.dir_qc)
	except:  # noqa E727
		die("can't change to QuakeC directory: " + Config.dir_qc)
	make_gamecode('progs.src')
	make_gamecode('spprogs.src')


def make_gamecode(progs):
	try_to_run(
		(Config.dir_qc / Config.bin_zqcc, '-progs', progs),
		'failed to compile gamecode file: ' + progs)


#
# Map tools compilation
#

def rename_qutils():
	for root, files, dirs in os.walk(Config.dir_qutils, topdown=False):
		for name in files + dirs:
			os.rename(
				os.path.join(root, name),
				os.path.join(root, name.lower()))


def _patch_map_tools_core(patches, root):
	for title, patch_file in patches.items():
		patch_set = patch.fromfile(patch_file)
		if not patch_set.apply(root=root):
			raise Exception(f'Patch "{patch_file.name}": OK')


def patch_map_tools_all():
	patches_all = {
		'Makefile': Config.dir_patches / 'makefile.patch',
		'writebsp.c': Config.dir_patches / 'writebsp.c.patch',
		'qbsp.c': Config.dir_patches / 'qbsp.c.patch'
	}
	_patch_map_tools_core(patches_all, Config.dir_qbsp)


def patch_map_tools_windows():
	windows_patches = {
		'qbsp.mak': Config.dir_patches / 'qbsp.mak.patch',
		'light.mak': Config.dir_patches / 'light.mak.patch',
		'vis.mak': Config.dir_patches / 'vis.mak.patch',
		'bspinfo.mak': Config.dir_patches / 'bspinfo.mak.patch'
	}
	_patch_map_tools_core(windows_patches, Config.dir_quake_tools)


def compile_map_tools():
	make(Config.dir_qbsp, 'Quake map tools')


@comeback
def compile_map_tools_windows():  # FIXME DRY
	for prog in ['qbsp', 'vis', 'light', 'bspinfo']:
		path = os.path.join(Config.dir_qutils, prog)
		try:
			os.chdir(path)
		except:  # noqa E727
			die("can't change directory to: " + path)
		try_to_run([
			'nmake',
			'/f', prog + '.mak',
			'CFG=' + prog + ' - Win32 Release'],
			prog + ' compilation')


#
# Main
#

def build_giants():
	check_platform()
	stuff = 'ZQuake, ZQCC, gamecode and Quake map tools'

	print('Building', stuff + '...')

	print('Compiling zquake')
	doset(
		mac=compile_zquake,
		windows=compile_zquake_windows)

	print('Compiling zqcc')
	doset(
		mac=compile_zqcc,
		windows=compile_zqcc_windows)

	print('Compiling gamecode')
	compile_gamecode()

	print('Renaming qutils files to lower-case')
	rename_qutils()

	print('Patching the Quake map tools')
	patch_map_tools_all()
	doset_only(windows=patch_map_tools_windows)

	print('Compiling the Quake map tools')
	doset(
		mac=compile_map_tools,
		windows=compile_map_tools_windows)

	print('Completed building', stuff + '.')


if __name__ == '__main__':
	build_giants()
