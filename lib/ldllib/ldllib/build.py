'''LDL interface to Quake map compilation tools'''
from pathlib import Path
import platform
import subprocess

from .conf import prog
from .utils import LDLError
from .convert import WAD_FILES, WADs

clean = ['.h1', '.h2', '.prt', '.pts', '.temp']  # last is if WAD path updated
temp_map_suffix = '.temp'


# Public

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


def swap_wad(map_string, to):
	return map_string.replace('"wad" "quake.wad"', f'"wad" "{WAD_FILES[to]}"')


# TODO move this, and the above, and the ones in convert? to somewhere central?
# FIXME doesn't do basename; preserves suffix
def basename_maybe_hc(wad, file_path):
	if wad == WADs.PROTOTYPE:
		out = file_path.stem + 'hc' + file_path.suffix
	else:
		out = file_path.name
	return Path(out)


def build(map_file, bsp_file=None, verbose=False, quiet=False, throw=False):
	"""Run a complete build for this map

	map_file - source map file
	bsp_file - output bsp file (this may be different, e.g. high-contrast mode
	verbose  - whether to print the stdout from the program
	quiet    - whether to print anything to stdout (overrides 'verbose')
	throw    - whether to raise a CalledProcessError if encountered

	If this is being called via the LDL command-line tools, we generally don't
	want to throw errors (because there may be other files to process), but we
	do want to monitor for them. There's a switch for verbosity. If we're
	running this via code, we probably can't see the output, so there's no
	need, and we probably do want to re-raise errors."""

	if not quiet:
		print('Building', map_file)

	# If the map file has a relative path to "quake.wad" we need to point it to
	# the correct full path. The map is then saved with a new name.
	build_map_path = swap_quake_wad_for_full_path(map_file)
	built_file = build_map_path.with_suffix('') if not bsp_file else bsp_file

	qbsp_args = [prog.qbsp, build_map_path]
	if bsp_file:
		qbsp_args.append(bsp_file)

	run(
		qbsp_args, verbose=verbose, quiet=quiet, throw=throw)
	run(
		[prog.light, '-extra', built_file],
		verbose=verbose, quiet=quiet, throw=throw)
	run(
		[prog.vis, '-level', '4', built_file],
		verbose=verbose, errorcheck=False, quiet=quiet, throw=throw)

	if not quiet and verbose:
		run([prog.bspinfo, built_file], verbose=True, errorcheck=False)

	for ext in clean:
		map_file.with_suffix(ext).unlink(missing_ok=True)


# Private

def swap_quake_wad_for_full_path(map_path):
	"""Use the full/correct WAD file path

	If changes needed to be made, save the map file as mapname.temp.

	Returns the original or new map file path"""
	map_string = map_path.read_text()
	modifed_map_string = swap_wad(map_string, WADs.QUAKE)
	if len(map_string) != len(modifed_map_string):
		output_map = map_path.with_suffix(temp_map_suffix)
		output_map.write_text(modifed_map_string)
		return output_map
	return map_path


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
