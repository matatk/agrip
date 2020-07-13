#!/usr/bin/env python3
"""Build the engine, QuakeC compiler, gamecode and map tools"""
from buildlib import \
	check_platform, compile_zqcc, compile_zquake, compile_gamecode, is_mac, \
	compile_map_tools, rename_qutils, patch_map_tools, compile_zqcc_windows, \
	compile_zquake_windows, compile_map_tools_windows

# FIXME bring some of these functions in here


def build_giants():
	check_platform()
	stuff = 'ZQuake, ZQCC, gamecode and Quake map tools'

	print('Building', stuff + '...')

	if is_mac():
		print('Compiling zquake')
		compile_zquake()
		print('Compiling zqcc')
		compile_zqcc()
	else:
		print('Compiling zquake')
		compile_zquake_windows()
		print('Compiling zqcc')
		compile_zqcc_windows()

	print('Compiling gamecode')
	compile_gamecode()

	print('Renaming qutils files to lower-case')
	rename_qutils()

	print('Patching the Quake map tools')
	patch_map_tools()

	print('Compiling the Quake map tools')
	if is_mac():
		compile_map_tools()
	else:
		compile_map_tools_windows()

	print('Completed building', stuff + '.')


if __name__ == '__main__':
	build_giants()
