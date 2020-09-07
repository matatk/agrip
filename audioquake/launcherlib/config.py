"""AudioQuake Game Launcher - Configuration service"""
from configparser import ConfigParser

CONFIG_FILENAME = 'audioquake.ini'  # i.e. in the current directory

INITIAL_CONFIG = {
	'first_game_run': 'yes'
}

_config = None

# This isn't a package, but __path__ has to be set or __getattr__ gets called
__path__ = None


def init():
	"""Read the existing config file, or create a default one

	Due to the default path (above) this will create the file in the current
	directory, so needs to be called in the right place."""
	global _config
	_config = ConfigParser()
	_config.read(CONFIG_FILENAME)
	if len(_config) == 1:  # always has a default section
		_config['launcher'] = INITIAL_CONFIG
		save()


def save():
	with open(CONFIG_FILENAME, 'w') as configfile:
		_config.write(configfile)


def _convert_to_string(value):
	if value is True:
		return 'yes'
	elif value is False:
		return 'no'
	else:
		return str(value)


def _convert_to_type(string):
	if string == 'yes' or string == 'true':
		return True
	elif string == 'no' or string == 'false':
		return False
	else:
		return string


def _get_or_set_core(name, value=None):
	if value is None:
		return _convert_to_type(_config['launcher'][name])
	else:
		_config['launcher'][name] = _convert_to_string(value)
		save()


def __getattr__(name):
	if name in _config['launcher']:
		return lambda value=None: _get_or_set_core(name, value)
	else:
		raise AttributeError(name)
