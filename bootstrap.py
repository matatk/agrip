#!/usr/bin/env python3
"""Bootstrap the virtual environment"""
import argparse
import os.path
import platform
import subprocess
import sys

VENV = '.venv'
verbose = False


def try_to_run(args, force_verbose=False):
	sink = None if verbose or force_verbose else subprocess.DEVNULL
	try:
		subprocess.check_call(args, stdout=sink, stderr=sink)
	except subprocess.CalledProcessError:
		if verbose:
			sys.exit(42)
		else:
			print('Error encountered; trying again...')
			try:
				subprocess.check_call(args)
			except subprocess.CalledProcessError:
				sys.exit(42)


def make_venv():
	try_to_run(['python3', '-m', 'venv', VENV])


def install_deps_and_shared_code():
	print('This will call pip to update itself, then install the required')
	print('packages and code shared between AudioQuake and Level Description')
	print('Language.')
	print()
	print('Normally this produces a lot of output; it will be kept quiet unless')
	print('there is an error.')
	print()
	try:
		input('Press Enter to continue, or interrupt to exit.')
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


if __name__ == '__main__':
	parser = argparse.ArgumentParser(
		description='Set up the virtual Python environment for building AQ and LDL')

	parser.add_argument(
		'-v', '--verbose', action='store_true',
		help='always show full details when trying to run commands')

	args = parser.parse_args()

	if args.verbose:
		verbose = True

	if sys.prefix != sys.base_prefix:
		# in venv
		try:
			import buildlib  # noqa 401
			import ldllib    # noqa 401
		except ImportError:
			install_deps_and_shared_code()
			print()

		print('Now to build everything')
		try:
			input('Build everything?')
			if platform.system() == 'Darwin':
				try_to_run(
					['python', 'build-giants.py'],
					force_verbose=True)
				print()
				try_to_run(['python', os.path.join(
					'audioquake', 'build-audioquake.py')],
					force_verbose=True)
			elif platform.system() == 'Windows':
				try_to_run(['build-all.bat'])
			else:
				raise NotImplementedError
		except KeyboardInterrupt:
			print()
		print()

		print('Remember to deactivate the virtual environment when finished with:')
		print('    deactivate')
	else:
		# not in venv
		if not os.path.exists(VENV):
			make_venv()
		print('You need to use the virtual environment:')
		print('    source ' + VENV + '/bin/activate')
