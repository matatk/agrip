"""Build gubbins"""
import os
from pathlib import Path
from platform import system
import sys
import subprocess
import traceback


class PlatformSetError(Exception):
	pass


class DoSomethingError(Exception):
	pass


class OnlyOnError(Exception):
	pass


# FIXME DRY with do_something really (just cope with types)
def platform_set(mac=None, windows=None):
	if not mac or not windows:
		raise PlatformSetError()

	if system() == 'Darwin':
		return mac
	elif system() == 'Windows':
		return windows
	else:
		raise NotImplementedError


class Config:
	base = Path(__file__).parent.parent.parent

	dir_readme_licence = base

	zq_repo = base / 'giants' / 'zq-repo'
	dir_make_zqcc = zq_repo / 'zqcc'
	dir_make_zquake = zq_repo / 'zquake'
	dir_zquake_source = zq_repo / 'zquake' / 'source'
	dir_qc = zq_repo / 'qc' / 'agrip'

	bin_zqcc = platform_set(
		mac=dir_make_zqcc / 'zqcc',
		windows=dir_make_zqcc / 'Release' / 'zqcc.exe')

	bin_zqgl = platform_set(
		mac=dir_make_zquake / 'release-mac' / 'zquake-glsdl',
		windows=dir_make_zquake / 'source' / 'Release-GL' / 'zquake-gl.exe')

	bin_zqds = platform_set(
		mac=dir_make_zquake / 'release-mac' / 'zqds',
		windows=dir_make_zquake / 'source' / 'Release-server' / 'zqds.exe')

	dir_quake_tools = base / 'giants' / 'Quake-Tools'
	dir_qutils = dir_quake_tools / 'qutils'
	dir_qbsp = dir_qutils / 'qbsp'

	dir_ldllib = base / 'ldl' / 'ldllib'

	aq = base / 'audioquake'
	file_aq_release = aq / 'release'
	dir_dist = aq / 'dist'
	dir_manuals = aq / 'manuals'
	dir_manuals_converted = aq / 'manuals-converted'
	dir_dist_rcon = dir_dist / 'rcon'
	dir_maps_source = aq / 'maps'
	dir_maps_quakewad = aq / 'maps-quakewad'
	dir_maps_freewad = aq / 'maps-freewad'
	dir_maps_prototypewad = aq / 'maps-prototypewad'

	dir_aq_data = platform_set(
		mac=dir_dist / 'AudioQuake.app' / 'Contents' / 'MacOS',
		windows=dir_dist / 'AudioQuake')

	dir_ldl = base / 'ldl'
	dir_patches = dir_ldl / 'patches'


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
	if system() != 'Darwin' and system() != 'Windows':
		die('Sorry, your platform is not supported yet.')


def prep_dir(directory):
	if Path(directory).exists():
		if not Path(directory).is_dir():
			raise Exception(directory + ' exists but is not a directory')
	else:
		os.mkdir(directory)


def try_to_run(process_args, error_message):
	result = subprocess.call(
		process_args, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
	if result != 0:
		print('Error running: ' + str(process_args)
								+ ' - trying again, with full output')
		result = subprocess.call(process_args)
		if result != 0:
			die(error_message)


def _make(name, target=None):
	error_message = 'failed to compile ' + name + ' [target: ' + str(target) + ']'
	process_args = ['make']
	if target is not None:
		process_args.append(target)
	try_to_run(process_args, error_message)


@comeback
def make(path, name, targets=[]):
	try:
		os.chdir(path)
	except:  # noqa E727
		die("can't change directory to: " + path)
	if len(targets) == 0:
		_make(name)
	else:
		for targ in targets:
			_make(name, targ)


# FIXME DRY with platform_set really (just cope with types)
def do_something(mac=None, windows=None):
	if not mac or not windows:
		raise DoSomethingError()

	if system() == 'Darwin':
		return mac()
	elif system() == 'Windows':
		return windows()
	else:
		raise NotImplementedError


# FIXME DRY with the others - only diff is the check
def only_on(mac=None, windows=None):
	if (mac and windows) or (not mac and not windows):
		raise OnlyOnError()

	if system() == 'Darwin':
		if mac:
			return mac()
	elif system() == 'Windows':
		if windows:
			return windows()
	else:
		raise NotImplementedError


# FIXME DRY with the others - only diff is the check
def platform_set_only_on(mac=None, windows=None):
	if (mac and windows) or (not mac and not windows):
		raise OnlyOnError()

	if system() == 'Darwin':
		return mac
	elif system() == 'Windows':
		return windows
	else:
		raise NotImplementedError
