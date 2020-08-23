"""AudioQuake Game Launcher - Configuration service"""
from configparser import ConfigParser

CONFIG_FILENAME = 'audioquake.ini'

INITIAL_CONFIG = {
	'first_game_run': 'yes'
}

_config = None


def save():
	with open(CONFIG_FILENAME, 'w') as configfile:
		_config.write(configfile)


def convert_to_string(value):
	if value is True:
		return 'yes'
	elif value is False:
		return 'no'
	else:
		return str(value)


def convert_to_type(string):
	if string == 'yes' or string == 'true':
		return True
	elif string == 'no' or string == 'false':
		return False
	else:
		return string


def get_or_set_core(name, value=None):
	if value is None:
		return convert_to_type(_config['launcher'][name])
	else:
		_config['launcher'][name] = convert_to_string(value)
		save()


def __getattr__(name):
	if name in _config['launcher']:
		return lambda value=None: get_or_set_core(name, value)
	else:
		raise AttributeError(name)


_config = ConfigParser()
_config.read(CONFIG_FILENAME)
if len(_config) == 1:  # always has a default section
	_config['launcher'] = INITIAL_CONFIG
	save()
