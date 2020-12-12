"""AudioQuake & LDL Launcher - Directories

This works out the paths to the different directories that the launcher needs.
Some files are distributed inside the bundle created by PyInstaller, whereas
others are kept outside (because they'll be modified). The launcher could be
running from within an Application (Mac) or folder (Windows).

Note: if changing whether things are included in or outsdie of the app
bundle/dir, you'll want to change AudioQuake.spec too."""
from pathlib import Path
import sys

from buildlib import doset

_inited = False
_latest_code_only = False

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
			_latest_code_only = True
	_inited = True
	print('root dir:', root_dir)

root = root_dir                     # Where audioquake.ini goes
data = root_dir / 'data'            # The game data (id1, oq, mods) and config
manuals = root_dir / 'manuals'      # Manuals and standalone docs
engines = launcher_dir / 'engines'  # The game/server and start commands (Mac)
mapping = launcher_dir / 'mapping'  # Mapping binaries and resources

if _latest_code_only:
	data = root_dir
