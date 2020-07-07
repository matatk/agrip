"""AudioQuake Game Launcher - Utilities"""
import platform


def on_windows():
	return platform.system() == 'Windows'


def opener():
	if on_windows():
		return ('cmd', '/c', 'start')
	else:  # assume Mac for now (may also work on Linux)
		return ('open',)
