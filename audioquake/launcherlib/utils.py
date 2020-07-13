"""AudioQuake Game Launcher - Utilities"""
from os import path
import platform


def on_windows():
	return platform.system() == 'Windows'


def opener():
	if on_windows():
		return ('cmd', '/c', 'start')
	else:  # assume Mac for now (may also work on Linux)
		return ('open',)


def have_registered_data():
	pak0path = path.join('id1', 'pak0.pak')
	pak1path = path.join('id1', 'pak1.pak')
	return path.exists(pak0path) and path.exists(pak1path)
