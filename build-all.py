#!/usr/bin/env python3
"""Bootstrap the virtual environment and run a build"""
import argparse
import os.path
import platform
import subprocess
import sys

VENV = '.venv'
verbose = False


#
# Main stages
#

def main():
	print(BANNER)
	print()
	if sys.prefix == sys.base_prefix:
		stage_1_create_venv()
	else:
		stage_2_bootstrap_venv()
		stage_3_build_everything()
	print()
	print('Remember to deactivate the virtual environment when finished with:')
	print('    deactivate')


def stage_1_create_venv():
	print('Stage 1 of 3: Creating and entering the virtual Python environment')
	print()
	if not os.path.exists(VENV):
		print('Creating the environment in:', VENV)
		try_to_run(['python3', '-m', 'venv', VENV])
	else:
		print('The environment already exists.')
	print()
	print('Please enter the virtual environment and run bootstrap again:')
	print('    source ' + VENV + '/bin/activate && ./bootstrap.py')


def stage_2_bootstrap_venv():
	try:
		import buildlib  # noqa 401
		import ldllib    # noqa 401
	except ImportError:
		print('Stage 2 of 3: Installing required packages and shared code')
		print()
		install_deps_and_shared_code()


def install_deps_and_shared_code():
	print('This will call pip to update itself, then install the required')
	print('packages and code shared between AudioQuake and Level Description')
	print('Language.')
	print()
	print('Normally this produces a lot of output; it will be kept quiet unless')
	print('there is an error.')
	print()
	try:
		input('Press Enter to continue, or interrupt to exit. ')
	except KeyboardInterrupt:
		print()
		sys.exit(0)

	print('Updating pip')
	try_to_run(['pip3', 'install', '--upgrade', 'pip'])
	print('Installing required packages (may take some time)')
	try_to_run(['pip3', 'install', '--requirement', 'requirements.txt'])
	print('Installing shared code as packages')
	try_to_run(['pip3', 'install', '--editable', os.path.join('lib', 'buildlib')])
	try_to_run(['pip3', 'install', '--editable', os.path.join('lib', 'ldllib')])
	print()


def stage_3_build_everything():
	print('Stage 3 of 3: Running a build')
	print()
	print('Now to build everything:')
	print('a. compile the engine, gamecod and map tools')
	print('b. assemble an AQ & LDL release')
	print('Any building work done so far will be re-used.')
	print()

	try:
		input('Run these build steps? (Enter to run or interrupt to abort) ')
		print()
		build_everything_core()
	except KeyboardInterrupt:
		print()


def build_everything_core():
	if platform.system() == 'Darwin':
		try_to_run(['python', 'build-giants.py'], force_verbose=True)
		print()
		try_to_run(
			['python', os.path.join('audioquake', 'build-audioquake.py')],
			force_verbose=True)
	elif platform.system() == 'Windows':
		try_to_run(['build-all.bat'])
	else:
		raise NotImplementedError


#
# Support
#

def try_to_run(args, force_verbose=False):
	sink = None if verbose or force_verbose else subprocess.DEVNULL
	try:
		subprocess.check_call(args, stdout=sink, stderr=sink)
	except subprocess.CalledProcessError:
		if verbose or force_verbose:
			sys.exit(42)
		else:
			print('Error encountered; trying again...')
			try:
				subprocess.check_call(args)
			except subprocess.CalledProcessError:
				sys.exit(42)


if __name__ == '__main__':
	BANNER = 'Build AudioQuake & Level Descripton Languge'

	parser = argparse.ArgumentParser(description=BANNER)

	parser.add_argument(
		'-v', '--verbose', action='store_true',
		help='always show full output when trying to run commands')

	args = parser.parse_args()

	if args.verbose:
		verbose = True

	main()
