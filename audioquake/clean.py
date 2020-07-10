"""Clean up"""
import platform
import shutil
import subprocess
import os

things_to_remove = {
	'manuals-converted': 'converted (HTML) manuals',
	'build': 'PyInstaller build directory',
	'dist': 'PyInstaller dist directory',
	'__pycache__': 'Python cache'}

if platform.system() != 'Windows':
	os.chdir('zq-repo')
	subprocess.call(('./agrip-cleanup.sh'),)
	os.chdir('..')
else:
	print("Can't automatically clean ZQuake and gamecode on Windows.")

for path, name in things_to_remove.items():
	print('Removing ' + name + '...')
	shutil.rmtree(path, ignore_errors=True)
