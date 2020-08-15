'''LDL interface to Quake map compilation tools'''
from pathlib import Path
import platform
import subprocess

from .conf import prog

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


def set_wad_file(name):
	prog.wadfile = Path(name)


# FIXME check for WAD files (???)
def have_needed_stuff():
	missing = []
	for exe in [prog.qbsp, prog.vis, prog.light, prog.bspinfo]:
		if not exe.is_file():
			missing.append(exe)

	if len(missing) > 0:
		print(
			'ERROR: The following map tools and support files are missing:\n\t'
			+ '\n\t'.join([str(path) for path in missing]))
		return False
	else:
		return True


def run(args, verbose, errorcheck=True):
	try:
		res = subprocess.run(args, capture_output=True, check=errorcheck)
		# We may not be doing strict error-checking (e.g. for vis) but still
		# want to know when it didn't work
		if verbose is True:
			print(res.stdout.decode())
		elif res.returncode != 0:
			print('Ignored error from', args[0].name)
	except subprocess.CalledProcessError as error:
		print('Error from', error.cmd[0].name)
		if verbose:
			print(error.output.decode())


def build(map_file, verbose=False):
	print('Building', map_file)
	without_ext = map_file.with_suffix('')
	run([prog.qbsp, without_ext], verbose)
	run([prog.light, '-extra', without_ext], verbose)
	run([prog.vis, '-level', '4', without_ext], verbose, errorcheck=False)

	if verbose is True:
		run([prog.bspinfo, without_ext], True, False)

	for ext in clean:
		map_file.with_suffix(ext).unlink(missing_ok=True)
