"""AudioQuake Game Launcher - Utilities"""
import os
from subprocess import check_call

from buildlib import do_something


def opener(openee):
	do_something(
		mac=check_call(['open', openee]),
		windows=os.startfile(openee))


def have_registered_data():
	pak0path = os.path.join('id1', 'pak0.pak')
	pak1path = os.path.join('id1', 'pak1.pak')
	return os.path.exists(pak0path) and os.path.exists(pak1path)
