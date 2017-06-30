"""Clean up"""
import platform
import shutil
import subprocess
import os


def on_windows(): return platform.system() == 'Windows'


things_to_remove = {
        'downloaded-assets': 'downloaded assets',
        'manuals-converted': 'converted (HTML) manuals',
        '__pycache__': 'Python cache'}

if not on_windows():
    os.chdir('zq-repo')
    subprocess.call(('./agrip-cleanup.sh'),)
    os.chdir('..')
else:
    print("Can't automatically clean ZQuake and gamecode on Windows.")

for path, name in things_to_remove.items():
    print('Removing ' + name + '...')
    shutil.rmtree(path, ignore_errors=True)
