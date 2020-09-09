"""AudioQuake & LDL Launcher - Utilities"""
from subprocess import check_call

from platform import system
if system() == 'Windows':
	from os import startfile

from buildlib import doset
from launcherlib import dirs


def opener(openee):
	doset(
		mac=lambda: check_call(['open', openee]),
		windows=lambda: startfile(openee))


def have_registered_data():
	pak0path = dirs.data / 'id1' / 'pak0.pak'
	pak1path = dirs.data / 'id1' / 'pak1.pak'
	return pak0path.is_file() and pak1path.is_file()
