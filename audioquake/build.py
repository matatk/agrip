"""Get all the bits and bobs ready to build AudioQuake"""
import platform
import os
import sys
import subprocess
import urllib.request
import zipfile
import traceback
import glob
import string
import shutil

import mistune
import mistune_contrib.toc


def is_mac():
	return platform.system() == 'Darwin'


def is_windows():
	return platform.system() == 'Windows'


class Info:
	release_number = None
	release_name = None
	base_dir = os.getcwd()


class Config:
	dir_make_zqcc = os.path.join('zq-repo', 'zqcc')
	dir_make_zquake = os.path.join('zq-repo', 'zquake')
	dir_qc = os.path.join('zq-repo', 'qc', 'agrip')
	dir_dist = 'dist'
	dir_ldllib = os.path.join('..', 'ldl', 'ldllib')

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

	dir_assets = 'downloaded-assets'
	dir_manuals = 'manuals'
	dir_manuals_converted = 'manuals-converted'
	dir_dist_rcon = os.path.join(dir_dist, 'rcon')
	dir_readme_licence = '..'


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


def banner():
	with open('release', 'r') as f:
		Info.release_number = f.readline().rstrip()
		Info.release_name = f.readline().rstrip()
		print('Building', Info.release_number, ':', Info.release_name)


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
		(os.path.join(Info.base_dir, Config.bin_zqcc), '-progs', progs),
		'failed to compile gamecode file: ' + progs)


#
# Converting the manuals and other docs
#

class TocRenderer(mistune_contrib.toc.TocMixin, mistune.Renderer):
	pass


def convert_markdown_files(base_name, markdown_files, output_dir):
	toc = TocRenderer()
	md = mistune.Markdown(renderer=toc)

	source = ''

	fancy_name = base_name.translate({ord('-'): ' '}).title()

	document_template = open(
		os.path.join(Config.dir_manuals, 'template.html'), 'r').read()

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

	open(os.path.join(output_dir, base_name + '.html'), 'w').write(
		full_document)


def convert_manuals():
	for manual in ['user-manual', 'development-manual']:
		print('Converting', manual + '...')
		sources = sorted(glob.glob(os.path.join(Config.dir_manuals, manual) + '*'))
		convert_markdown_files(manual, sources, Config.dir_manuals_converted)

	single_docs_to_convert = {
		'sound-legend': os.path.join(Config.dir_manuals, 'user-manual-part07-b.md'),
		'README': os.path.join(Config.dir_readme_licence, 'README.md'),
		'LICENCE': os.path.join(Config.dir_readme_licence, 'LICENCE.md')}

	for docname, docpath in single_docs_to_convert.items():
		print('Converting ' + docname + '...')
		convert_markdown_files(docname, docpath, Config.dir_manuals_converted)


#
# Downloading support files
#

def get_summat(dest_dir, check_file, plural_name, url):
	print('Checking:', plural_name)
	real_dest_dir = os.path.join(Config.dir_assets, dest_dir)
	if not os.path.isdir(real_dest_dir) \
		or not os.path.isfile(os.path.join(real_dest_dir, check_file)):
		print("It seems you don't have", plural_name)
		# Try to re-extract, or re-download
		zip_file_name = real_dest_dir + '.zip'
		if os.path.isfile(zip_file_name):
			print('Re-extracting...')
		else:
			print('Downloading...')
			try:
				urllib.request.urlretrieve(url, zip_file_name)
			except:  # noqa E727
				die('whilst downloading ' + url)
		# Actually try to extract
		try:
			zipfile.ZipFile(zip_file_name).extractall(Config.dir_assets)
		except:  # noqa E727
			die('when extracting ' + zip_file_name)


#
# Running PyInstaller
#

def run_pyinstaller():
	# Grab the LDL library from the next directory along
	dir_local_ldllib = os.path.join(os.getcwd(), 'ldllib')
	shutil.rmtree(dir_local_ldllib, ignore_errors=True)
	shutil.copytree(Config.dir_ldllib, dir_local_ldllib)

	for spec in ['AudioQuake.spec', 'rcon.spec']:
		print('Running PyInstaller on ' + spec + '...')
		try_to_run(
			('pyinstaller', '-y', spec),
			'failed to run PyInstaller on ' + spec)


def copy_in_rcon():
	if is_mac():
		rcon_bin = 'rcon'
	else:
		rcon_bin = 'rcon.exe'

	shutil.copy(
		os.path.join(Config.dir_dist_rcon, rcon_bin),
		Config.dir_dist_aq)


#
# Let's script like it's 1989...
#

if __name__ == '__main__':
	banner()
	check_platform()

	print('Preparing downloaded assets dir')
	prep_dir(Config.dir_assets)
	print('Preparing converted (HTML) manual dir')
	prep_dir(Config.dir_manuals_converted)

	if is_mac():
		print('Compiling zqcc')
		compile_zqcc()
		print('Compiling zquake')
		compile_zquake()
	else:
		print(
			"On Windows, we don't compile the engine here; "
			"we just pick up the existing binaries.")

	print('Compiling gamecode')
	compile_gamecode()

	# Markdown to HTML...
	convert_manuals()  # TODO replace with a check if it needs doing

	# Build the executables
	run_pyinstaller()
	copy_in_rcon()
