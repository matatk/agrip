"""AudioQuake & LDL Launcher - Directories

This works out the paths to the different directories that the launcher needs.
Some files are distributed inside the bundle created by PyInstaller, whereas
others are kept outside (because they'll be modified). The launcher could be
running from within an Application (Mac) or folder (Windows)."""
from pathlib import Path
import sys

from buildlib import doset

_inited = False

if not _inited:
	if hasattr(sys, '_MEIPASS'):
		# Running frozen
		launcher_dir = Path(getattr(sys, '_MEIPASS'))
		root_dir = doset(
			mac=launcher_dir.parent.parent.parent,
			windows=launcher_dir.parent)  # FIXME: check
	else:
		# Did we already run a build, and thus can use the data already there?
		collated = Path(__file__).parent.parent / 'dist' / 'collated'
		if collated.is_dir():
			# Using latest .py code, but already-prepared frozen assets
			launcher_dir = doset(
				mac=collated / 'AudioQuake.app' / 'Contents' / 'MacOS',
				windows=collated / 'AudioQuake')  # FIXME: check
			root_dir = collated
		else:
			# Using latest .py code and no frozen assets (this won't work
			# terribly much :-))
			launcher_dir = root_dir = Path(__file__).resolve().parent
	_inited = True

root = root_dir                     # Where audioquake.ini goes
data = root_dir / 'data'            # The game data (id1, oq, mods)
manuals = root_dir / 'manuals'      # Manuals and standalone docs
engines = launcher_dir / 'engines'  # The game/server and start commands (Mac)
mapping = launcher_dir / 'mapping'  # Mapping binaries and resources
