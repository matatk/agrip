"""AudioQuake Game Launcher - Utilities"""
import inspect
import os
from subprocess import check_call
import platform


def on_windows():  # FIXME move to a more comprehenseive approach
	curframe = inspect.currentframe()
	calframe = inspect.getouterframes(curframe, 2)
	print('on_windows() is DEPRECATED. Called by:', calframe[1][1:4])
	return platform.system() == 'Windows'


def opener(openee):
	system = platform.system()
	if system == 'Windows':
		os.startfile(openee)
	elif system == 'Darwin':
		check_call(['open', openee])
	else:
		raise NotImplementedError


def have_registered_data():
	pak0path = os.path.join('id1', 'pak0.pak')
	pak1path = os.path.join('id1', 'pak1.pak')
	return os.path.exists(pak0path) and os.path.exists(pak1path)
