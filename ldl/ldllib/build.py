'''LDL interface to Quake map compilation tools'''
import os
import subprocess

from .conf import prog

clean = ['.h1', '.h2', '.prt', '.pts']


def have_needed_stuff():
	missing = []
	for exe in [prog.qbsp, prog.vis, prog.light, prog.bspinfo, prog.quakewad]:
		if not os.path.isfile(exe):
			missing.append(exe)

	if len(missing) > 0:
		print(
			'ERROR: The following map tools and support files are missing:\n\t'
			+ '\n\t'.join(missing))
		return False
	else:
		return True


def run(args, verbose, errorcheck=True):
	res = subprocess.run(args, capture_output=True, check=errorcheck)
	if verbose is True:
		print(res.stdout.decode())


def build(map_file_name, basename, verbose):
	print('Building', map_file_name)
	run([prog.qbsp, basename], verbose)
	run([prog.light, '-extra', basename], verbose)
	run([prog.vis, '-level', '4', basename], verbose)

	if verbose is True:
		run([prog.bspinfo, basename], True, False)

	for ext in clean:
		try:
			os.unlink(basename + ext)
		except FileNotFoundError:
			pass  # it may not have been created, e.g. if vis failed
