#!/usr/bin/env python3
"""Recursively rename Quake-Tools/qutils/ to be lower-case, then apply patches
so the tools can be built"""
import os
import shutil
import subprocess

import patch_ng as patch


def rename(directory):
	for root, files, dirs in os.walk(directory, topdown=False):
		for name in files + dirs:
			os.rename(
				os.path.join(root, name),
				os.path.join(root, name.lower()))


if __name__ == '__main__':
	script_dir = os.path.dirname(os.path.abspath(__file__))

	qtools_dir = os.path.join(script_dir, '..', 'vendor', 'Quake-Tools')
	qutils_dir = os.path.join(qtools_dir, 'qutils')
	qbsp_dir = os.path.join(qutils_dir, 'qbsp')

	patches_dir = os.path.join(script_dir, 'patches')

	patches = {
		'Makefile': os.path.join(patches_dir, 'makefile.patch'),
		'writebsp.c': os.path.join(patches_dir, 'writebsp.c.patch'),
		'qbsp.c': os.path.join(patches_dir, 'qbsp.c.patch')
	}

	bin_dir = os.path.join(script_dir, 'bin')

	print('Renaming all qutils files to lower-case...')
	rename(qutils_dir)

	for title, patch_file in patches.items():
		print('Patching', title + '...')
		patch_set = patch.fromfile(patch_file)
		if not patch_set.apply(root=qbsp_dir):
			raise Exception('Patch', patch_file, 'failed.')

	print('Building...')
	os.chdir(qbsp_dir)
	subprocess.call('make')

	if not os.path.isdir(bin_dir):
		os.mkdir(bin_dir)

	for tool in ['qbsp', 'light', 'vis', 'bspinfo']:
		shutil.copy(os.path.join(os.getcwd(), tool), bin_dir)

	print('Done')
