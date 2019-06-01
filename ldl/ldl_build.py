'''LDL interface to Quake map compilation tools'''
import os
import subprocess

bins = os.path.join('q1tools_gpl.qutils', 'qbsp')
qbsp = os.path.join(bins, 'qbsp')
vis = os.path.join(bins, 'vis')
light = os.path.join(bins, 'light')
bspinfo = os.path.join(bins, 'bspinfo')

always_clean = ['.h1', '.h2', '.prt', '.pts']


def run(args, verbose, errorcheck=True):
	exe = os.path.basename(args[0])
	try:
		res = subprocess.run(args, capture_output=True, check=errorcheck)
		if verbose is True:
			print(res.stdout.decode())
	except subprocess.SubprocessError:
		print("There was an error running '" + exe + "' - details follow")
		subprocess.run(args)


def build(map_file_name, basename, verbose, keep):
	print('Building', map_file_name)
	run([qbsp, basename], verbose)
	run([light, '-extra', basename], verbose)
	run([vis, '-level', '4', basename], verbose)
	if verbose is True:
		run([bspinfo, basename], True, False)

	for ext in always_clean:
		try:
			os.unlink(basename + ext)
		except FileNotFoundError:
			pass  # it may not have been created, e.g. if vis failed
