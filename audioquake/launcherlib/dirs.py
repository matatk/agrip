"""AudioQuake & LDL Launcher - Directories

This works out the paths to the different directories that the launcher needs.
Some files are distributed inside the bundle created by PyInstaller, whereas
others are kept outside (because they'll be modified). The launcher could be
running from within an Application (Mac) or folder (Windows)."""
from pathlib import Path
import sys

from buildlib import doset

_inited = False
_adjust_config_dir_to_be_root = False

if not _inited:
	print('dirs module init')
	if hasattr(sys, '_MEIPASS'):
		# Running from frozen app bundle/dir
		print('running frozen')
		launcher_dir = Path(getattr(sys, '_MEIPASS'))
		root_dir = doset(
			mac=launcher_dir.parent.parent.parent,
			windows=launcher_dir.parent)  # FIXME: check
	else:
		# Did we already run a build, and thus can use the data already there?
		collated = Path(__file__).parent.parent / 'dist' / 'collated'
		if collated.is_dir():
			# Using latest .py code, but already-prepared frozen assets
			print('running with latest code and already-prepared assets')
			launcher_dir = doset(
				mac=collated / 'AudioQuake.app' / 'Contents' / 'MacOS',
				windows=collated / 'AudioQuake')  # FIXME: check
			root_dir = collated
		else:
			# Using latest .py code and no frozen assets (this won't work
			# terribly much :-))
			print('running with latest code and no prepared assets')
			launcher_dir = root_dir = Path(__file__).resolve().parent.parent
			# Set a flag to later adjust the 'data' path because that's where
			# the config file goes, and if we're just running the latest code
			# from the development repo, there's no 'data' directory.
			_adjust_config_dir_to_be_root = True
	_inited = True
	print('root dir:', root_dir)

# NOTE: If editing the below, synch up with AudioQuake.spec
data = root_dir / 'data'                    # Game files (id1, oq, mods)
config = root_dir / 'data'                  # Where audioquake.ini goes
manuals = root_dir / 'docs'                 # Manuals and standalone docs
engines = launcher_dir / 'engines'          # The game/server and Mac cmds
map_tools = launcher_dir / 'maptools'       # Mapping bins and resources
# NOTE: If editing the below, synch up with build-audioquake.py
maps_example = root_dir / 'example-maps'    # LDL example maps
maps_tutorial = root_dir / 'tutorial-maps'  # LDL tutorial maps

if _adjust_config_dir_to_be_root:
	config = root_dir
