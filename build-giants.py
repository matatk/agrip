#!/usr/bin/env python3
"""FIXME"""
from buildlib import \
	check_platform, compile_zqcc, compile_zquake, compile_gamecode, is_mac, \
	compile_map_tools, rename_qutils, patch_map_tools


def build_giants():
	check_platform()

	print('Compiling ZQuake, ZQCC, Gamecode and Quake map tools...')

	if is_mac():
		print('Compiling zquake')
		compile_zquake()
		print('Compiling zqcc')
		compile_zqcc()
	else:
		print(
			"On Windows, we don't compile the engine here; "
			"we just pick up the existing binaries.")

	print('Compiling gamecode')
	compile_gamecode()

	print('Renaming all qutils files to lower-case...')
	rename_qutils()

	print('Patching the Quake map tools...')
	patch_map_tools()

	print('Compiling the Quake map tools...')
	compile_map_tools()

	print('Compiled ZQuake, ZQCC, Gamecode and Quake map tools.')


if __name__ == '__main__':
	build_giants()
