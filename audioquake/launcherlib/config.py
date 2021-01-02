"""AudioQuake & LDL Launcher - Configuration service"""
from configparser import ConfigParser

CONFIG_FILENAME = 'audioquake.ini'  # i.e. in the current directory

INITIAL_CONFIG = {
	'first_game_run': 'yes',
	'fullscreen': 'no',
	'resolution': '640x400'  # ZQuake default
}

_config_file_directory = None
_config = None

# This isn't a package, but __path__ has to be set or __getattr__ gets called
__path__ = None


def init(root):
	"""Read the existing config file, or create a default one

	root is a pathlib.Path that points to an existing directory.

	Due to the default path (above) this will create the file in the current
	directory, so needs to be called in the right place."""
	global _config
	global _config_file_directory
	_config_file_directory = root
	_config = ConfigParser()
	_config.read(_config_file_directory / CONFIG_FILENAME)
	if len(_config.sections()) == 0:
		_config['launcher'] = INITIAL_CONFIG
		save()
	else:
		_upgrade_config()


def _upgrade_config():
	made_changes = False

	for key, default in INITIAL_CONFIG.items():
		if key not in _config['launcher']:
			_config['launcher'][key] = default
			made_changes = True

	if made_changes:
		save()


def save():
	with open(_config_file_directory / CONFIG_FILENAME, 'w') as configfile:
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


def _get_or_set_core(name, new_value=None):
	if new_value is None:
		return _convert_to_type(_config['launcher'][name])

	new_value_string = _convert_to_string(new_value)
	if _config['launcher'][name] != new_value_string:
		_config['launcher'][name] = new_value_string
		save()


def __getattr__(name):
	if name in _config['launcher']:
		return lambda value=None: _get_or_set_core(name, value)
	else:
		raise AttributeError(name)
