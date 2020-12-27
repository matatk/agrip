#!/usr/bin/env python3
"""Build the engine, QuakeC compiler, gamecode and map tools"""
import os

import patch_ng as patch

from buildlib import Build, \
	comeback, check_platform, doset, doset_only, make, die, try_to_run


#
# Engine compilation
#

def compile_zqcc():
	make(Build.dir_make_zqcc, 'zqcc')


def compile_zquake():
	make(Build.dir_make_zquake, 'zquake', ['gl', 'server'])


def compile_zquake_windows():
	path = Build.dir_zquake_source
	try:
		os.chdir(path)
	except:  # noqa E727
		die("can't change directory to: " + path)
	try_to_run(
		['msbuild', 'zquake.sln', '/p:Configuration=GLRelease', '/p:Platform=Win32'],
		'ZQuake compilation')


def compile_zqcc_windows():  # FIXME DRY
	path = Build.dir_make_zqcc
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
		os.chdir(Build.dir_qc)
	except:  # noqa E727
		die("can't change to QuakeC directory: " + Build.dir_qc)
	make_gamecode('progs.src')
	make_gamecode('spprogs.src')


def make_gamecode(progs):
	try_to_run(
		(Build.dir_qc / Build.bin_zqcc, '-progs', progs),
		'failed to compile gamecode file: ' + progs)


#
# Map tools compilation
#

def rename_qutils():
	for root, files, dirs in os.walk(Build.dir_qutils, topdown=False):
		for name in files + dirs:
			os.rename(
				os.path.join(root, name),
				os.path.join(root, name.lower()))


def _patch_map_tools_core(patches, root):
	for title, patch_file in patches.items():
		patch_set = patch.fromfile(patch_file)
		if not patch_set.apply(root=root):
			die(f'Patch "{patch_file.name}" failed (try cleaning the giants/Quake-Tools submodule)')


def patch_map_tools_all():
	patches_all = {
		'Makefile': Build.dir_patches / 'makefile.patch',
		'writebsp.c': Build.dir_patches / 'writebsp.c.patch',
		'qbsp.c': Build.dir_patches / 'qbsp.c.patch'
	}
	_patch_map_tools_core(patches_all, Build.dir_qbsp)


def patch_map_tools_windows():
	windows_patches = {
		'qbsp.mak': Build.dir_patches / 'qbsp.mak.patch',
		'light.mak': Build.dir_patches / 'light.mak.patch',
		'vis.mak': Build.dir_patches / 'vis.mak.patch',
		'bspinfo.mak': Build.dir_patches / 'bspinfo.mak.patch'
	}
	_patch_map_tools_core(windows_patches, Build.dir_quake_tools)


def compile_map_tools():
	make(Build.dir_qbsp, 'Quake map tools')


@comeback
def compile_map_tools_windows():  # FIXME DRY
	for prog in ['qbsp', 'vis', 'light', 'bspinfo']:
		path = os.path.join(Build.dir_qutils, prog)
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
