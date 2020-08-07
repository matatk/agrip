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
	try:
		res = subprocess.run(args, capture_output=True, check=errorcheck)
		# We may not be doing strict error-checking (e.g. for vis) but still
		# want to know when it didn't work
		if res.returncode != 0:
			print('Ignored error from', os.path.basename(args[0]))
	except subprocess.CalledProcessError as error:
		print('Error from', error.cmd[0])
	if verbose is True:
		print(res.stdout.decode())


def build(map_file_name, verbose):
	print('Building', map_file_name)
	without_ext = os.path.splitext(map_file_name)[0]
	run([prog.qbsp, without_ext], verbose)
	run([prog.light, '-extra', without_ext], verbose)
	run([prog.vis, '-level', '4', without_ext], verbose, errorcheck=False)

	if verbose is True:
		run([prog.bspinfo, without_ext], True, False)

	for ext in clean:
		try:
			os.unlink(without_ext + ext)
		except FileNotFoundError:
			pass  # it may not have been created, e.g. if vis failed
