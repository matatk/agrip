"""FIXME"""
import platform
import os
import sys
import subprocess
import traceback

import patch_ng as patch


def is_mac():
	return platform.system() == 'Darwin'


def is_windows():
	return platform.system() == 'Windows'


class Config:
	base = os.path.dirname(os.path.abspath(__file__))

	dir_make_zqcc = os.path.join(base, 'giants', 'zq-repo', 'zqcc')
	dir_make_zquake = os.path.join(base, 'giants', 'zq-repo', 'zquake')
	dir_qc = os.path.join(base, 'giants', 'zq-repo', 'qc', 'agrip')
	dir_dist = os.path.join(base, 'audioquake', 'dist')
	dir_ldllib = os.path.join(base, 'ldl', 'ldllib')

	if is_mac():
		bin_zqcc = os.path.join(dir_make_zqcc, 'zqcc')
		bin_zqgl = os.path.join(dir_make_zquake, 'release-mac', 'zquake-glsdl')
		bin_zqds = os.path.join(dir_make_zquake, 'release-mac', 'zqds')
		dir_dist_aq = os.path.join(dir_dist, 'AudioQuake.app', 'Contents', 'MacOS')
	elif is_windows():
		bin_zqcc = os.path.join(dir_make_zqcc, 'Release', 'zqcc.exe')
		bin_zqgl = os.path.join(
			dir_make_zquake, 'source', 'Release-GL', 'zquake-gl.exe')
		bin_zqds = os.path.join(
			dir_make_zquake, 'source', 'Release-server', 'zqds.exe')
		dir_dist_aq = os.path.join(dir_dist, 'AudioQuake')
	else:
		raise NotImplementedError

	dir_manuals = os.path.join(base, 'audioquake', 'manuals')
	dir_manuals_converted = os.path.join(base, 'audioquake', 'manuals-converted')
	dir_dist_rcon = os.path.join(dir_dist, 'rcon')
	dir_readme_licence = base

	quake_tools = os.path.join(base, 'giants', 'Quake-Tools')
	dir_qutils = os.path.join(quake_tools, 'qutils')
	dir_qbsp = os.path.join(dir_qutils, 'qbsp')

	dir_patches = os.path.join(base, 'ldl', 'patches')

	file_aq_release = os.path.join(base, 'audioquake', 'release')


#
# Utilities
#

def comeback(function):
	def wrapper(*args, **kwargs):
		original = os.getcwd()
		function(*args, **kwargs)
		try:
			os.chdir(original)
		except:  # noqa E727
			die("couldn't return to original directory: " + original)
	return wrapper


def die(message):
	exc_type, exc_value, exc_traceback = sys.exc_info()
	if exc_type:
		print('\nAn error has ooccurred; details follow.\n')
		traceback.print_exc()
		print()
	print('Error:', message)
	sys.exit(42)


def check_platform():
	if not is_mac() and not is_windows():
		die('Sorry, your platform is not supported yet.')


def prep_dir(directory):
	if os.path.exists(directory):
		if not os.path.isdir(directory):
			raise Exception(directory + ' exists but is not a directory')
	else:
		os.mkdir(directory)


def try_to_run(process_args, error_message):
	with open(os.devnull, 'w') as DEVNULL:
		result = subprocess.call(
			process_args, stdout=DEVNULL, stderr=subprocess.STDOUT)
		if result != 0:
			print('Error running: ' + str(process_args)
									+ ' - trying again, with full output...')
			result = subprocess.call(process_args)
			if result != 0:
				die(error_message)


#
# Engine compilation
#

def compile_zqcc():
	_compile(Config.dir_make_zqcc, 'zqcc')


def compile_zquake():
	_compile(Config.dir_make_zquake, 'zquake', ['gl', 'server'])


def _make(name, target=None):
	error_message = 'failed to compile ' + name + ' [target: ' + str(target) + ']'
	process_args = ['make']
	if target is not None:
		process_args.append(target)
	try_to_run(process_args, error_message)


@comeback
def _compile(path, name, targets=[]):
	try:
		os.chdir(path)
	except:  # noqa E727
		die("can't change directory to: " + path)
	if len(targets) == 0:
		_make(name)
	else:
		for targ in targets:
			_make(name, targ)


#
# QuakeC Compilation
#

def _chdir_gamecode():  # TODO remove
	try:
		os.chdir(Config.dir_qc)
	except:  # noqa E727
		die("can't change to QuakeC directory: " + Config.dir_qc)


@comeback
def compile_gamecode():
	_chdir_gamecode()
	_compile_gamecode('progs.src')
	_compile_gamecode('spprogs.src')


def _compile_gamecode(progs):
	try_to_run(
		(os.path.join(Config.dir_qc, Config.bin_zqcc), '-progs', progs),
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


def patch_map_tools():
	patches = {
		'Makefile': os.path.join(Config.dir_patches, 'makefile.patch'),
		'writebsp.c': os.path.join(Config.dir_patches, 'writebsp.c.patch'),
		'qbsp.c': os.path.join(Config.dir_patches, 'qbsp.c.patch')
	}

	for title, patch_file in patches.items():
		print('Patching', title + '...')
		patch_set = patch.fromfile(patch_file)
		if not patch_set.apply(root=Config.dir_qbsp):
			raise Exception('Patch', patch_file, 'failed.')


def compile_map_tools():
	_compile(Config.dir_qbsp, 'Quake map tools')
