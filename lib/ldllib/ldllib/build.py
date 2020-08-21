'''LDL interface to Quake map compilation tools'''
from pathlib import Path
import platform
import subprocess

from .conf import prog
from .utils import LDLError

clean = ['.h1', '.h2', '.prt', '.pts']


def use_repo_bins():
	if platform.system() == 'Darwin':
		bin_base = Path('..', 'giants', 'Quake-Tools', 'qutils', 'qbsp')
		prog.qbsp = bin_base / 'qbsp'
		prog.light = bin_base / 'light'
		prog.vis = bin_base / 'vis'
		prog.bspinfo = bin_base / 'bspinfo'
	elif platform.system() == 'Windows':
		bin_base = Path('..', 'giants', 'Quake-Tools', 'qutils')
		prog.qbsp = bin_base / 'qbsp' / 'Release' / 'qbsp.exe'
		prog.light = bin_base / 'light' / 'Release' / 'light.exe'
		prog.vis = bin_base / 'vis' / 'Release' / 'vis.exe'
		prog.bspinfo = bin_base / 'bspinfo' / 'Release' / 'bspinfo.exe'
	else:
		raise NotImplementedError


def have_needed_progs():
	missing = []
	for exe in [prog.qbsp, prog.vis, prog.light, prog.bspinfo]:
		if not exe.is_file():
			missing.append(exe)

	if len(missing) > 0:
		print(
			'ERROR: The following map tools are missing:\n\t'
			+ '\n\t'.join([str(path) for path in missing]))
		return False
	else:
		return True


def run(args, errorcheck=True, verbose=False, quiet=False, throw=False):
	"""Run a builder program

	args       - the program to run, including command-line arguments
	errorcheck - whether to monitor for CalledProcessErrors at all
	verbose    - whether to print the stdout from the program
	quiet      - whether to print anything to stdout (overrides 'verbose')
	throw      - whether to raise a CalledProcessError if encountered"""
	try:
		res = subprocess.run(args, capture_output=True, check=errorcheck)
		# We may not be doing strict error-checking (e.g. for vis) but still
		# want to know when it didn't work
		if not quiet and verbose:
			print(res.stdout.decode())
		elif res.returncode != 0 and not quiet:
			print('Ignored error from', args[0].name)
	except subprocess.CalledProcessError as error:
		if throw:
			details = error.output.decode().splitlines()[-1]
			raise LDLError(error.cmd[0].name + ': ' + details)
		elif not quiet:
			print('Error from', error.cmd[0].name)
			if verbose:
				print(error.output.decode())


def build(map_file, verbose=False, quiet=False, throw=False):
	"""Run a complete build for this map

	verbose - whether to print the stdout from the program
	quiet   - whether to print anything to stdout (overrides 'verbose')
	throw   - whether to raise a CalledProcessError if encountered

	If this is being called via the LDL command-line tools, we generally don't
	want to throw errors (because there may be other files to process), but we
	do want to monitor for them. There's a switch for verbosity. If we're
	running this via code, we probably can't see the output, so there's no
	need, and we probably do want to re-raise errors."""

	if not quiet:
		print('Building', map_file)
	without_ext = map_file.with_suffix('')

	run(
		[prog.qbsp, without_ext], verbose=verbose, quiet=quiet, throw=throw)
	run(
		[prog.light, '-extra', without_ext],
		verbose=verbose, quiet=quiet, throw=throw)
	run(
		[prog.vis, '-level', '4', without_ext],
		verbose=verbose, errorcheck=False, quiet=quiet, throw=throw)

	if not quiet and verbose:
		run([prog.bspinfo, without_ext], verbose=True, errorcheck=False)

	for ext in clean:
		map_file.with_suffix(ext).unlink(missing_ok=True)
