"""Build gubbins"""
import platform
import os
import sys
import subprocess
import traceback


class PlatformSetError(Exception):
	pass


class DoSomethingError(Exception):
	pass


class OnlyOnError(Exception):
	pass


def platform_set(mac=None, windows=None):
	if not mac or not windows:
		raise PlatformSetError()

	if platform.system() == 'Darwin':
		return mac
	elif platform.system() == 'Windows':
		return windows
	else:
		raise NotImplementedError


class Config:
	base = os.path.dirname(os.path.abspath(__file__))

	zq_repo = os.path.join(base, 'giants', 'zq-repo')
	dir_make_zqcc = os.path.join(zq_repo, 'zqcc')
	dir_make_zquake = os.path.join(zq_repo, 'zquake')
	dir_zquake_source = os.path.join(zq_repo, 'zquake', 'source')
	dir_qc = os.path.join(base, 'giants', 'zq-repo', 'qc', 'agrip')
	dir_dist = os.path.join(base, 'audioquake', 'dist')
	dir_ldllib = os.path.join(base, 'ldl', 'ldllib')

	bin_zqcc = platform_set(
		mac=os.path.join(dir_make_zqcc, 'zqcc'),
		windows=os.path.join(dir_make_zqcc, 'Release', 'zqcc.exe'))

	bin_zqgl = platform_set(
		mac=os.path.join(dir_make_zquake, 'release-mac', 'zquake-glsdl'),
		windows=os.path.join(
			dir_make_zquake, 'source', 'Release-GL', 'zquake-gl.exe'))

	bin_zqds = platform_set(
		mac=os.path.join(dir_make_zquake, 'release-mac', 'zqds'),
		windows=os.path.join(
			dir_make_zquake, 'source', 'Release-server', 'zqds.exe'))

	dir_aq_data = platform_set(
		mac=os.path.join(dir_dist, 'AudioQuake.app', 'Contents', 'MacOS'),
		windows=os.path.join(dir_dist, 'AudioQuake'))

	dir_manuals = os.path.join(base, 'audioquake', 'manuals')
	dir_manuals_converted = os.path.join(base, 'audioquake', 'manuals-converted')
	dir_dist_rcon = os.path.join(dir_dist, 'rcon')
	dir_readme_licence = base

	dir_quake_tools = os.path.join(base, 'giants', 'Quake-Tools')
	dir_qutils = os.path.join(dir_quake_tools, 'qutils')
	dir_qbsp = os.path.join(dir_qutils, 'qbsp')

	dir_patches = os.path.join(base, 'ldl', 'patches')

	file_aq_release = os.path.join(base, 'audioquake', 'release')


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
	if platform.system() != 'Darwin' and platform.system() != 'Windows':
		die('Sorry, your platform is not supported yet.')


def prep_dir(directory):
	if os.path.exists(directory):
		if not os.path.isdir(directory):
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


def do_something(mac=None, windows=None):
	if not mac or not windows:
		raise DoSomethingError()

	if platform.system() == 'Darwin':
		mac()
	elif platform.system() == 'Windows':
		windows()
	else:
		raise NotImplementedError


def only_on(mac=None, windows=None):
	if mac and windows:
		raise OnlyOnError()

	if platform.system() == 'Darwin':
		if mac:
			mac()
	elif platform.system() == 'Windows':
		if windows:
			windows()
	else:
		raise NotImplementedError
