"""AudioQuake & LDL Launcher - Configuration service"""
from configparser import ConfigParser
from datetime import datetime, timezone
from hashlib import sha224
from time import time

from key import SECRET

CONFIG_FILENAME = 'audioquake.ini'

INITIAL_CONFIG = {
	'_validation': '',  # This will be set by code.
	'first_game_run': 'yes',
	'fullscreen': 'no',
	'resolution': ''    # The platform default will be inserted.
}

_config_file_path = None
_config = None
_made_changes = False
_has_been_validated = False
_initial_validation_mismatch = False

# This isn't a package, but __path__ has to be set or __getattr__ gets called
__path__ = None


def init(root):
	"""Read the existing config file, or create a default one

	root is a pathlib.Path that points to an existing directory.

	Due to the default path (above) this will create the file in the current
	directory, so needs to be called in the right place.

	This also checks that the user had entered a valid date of birth (which is
	not stored) and returns True if this has been done, or False otherwise.
	Whilst it would be possible for someone very determined to break the method
	used, it should prevent accidental or "casual" attempts to circumvent the
	check."""
	global _config
	global _config_file_path
	global _initial_validation_mismatch

	_config = ConfigParser()
	_config_file_path = root / CONFIG_FILENAME
	_config.read(_config_file_path)
	if len(_config.sections()) == 0:
		_config['launcher'] = INITIAL_CONFIG
	else:
		_upgrade_config()

	if not _config_file_path.exists():
		print('no config file yet')
		return False

	previous_hash = _get_or_set_core('_validation')

	if not previous_hash:
		print('no validation yet')
		return False

	mtime = int(_config_file_path.stat().st_mtime)
	modified = datetime.fromtimestamp(mtime, tz=timezone.utc)
	print("config.init(): ini mod'd:", mtime, modified)
	ini_modified_hash = _wrap(mtime)

	if ini_modified_hash == previous_hash:
		set_is_valid()
		return True
	else:
		print('hashes do not match')
		_initial_validation_mismatch = True
		return False


def set_is_valid():
	"""Called when it's been ascertained the user may play the game."""
	print('config.set_is_valid(): validation passed')
	global _has_been_validated
	global _made_changes
	_has_been_validated = True
	if _initial_validation_mismatch:
		_made_changes = True


def quit():
	"""Call this when the program is exiting to persist any changes."""
	if _made_changes or not _config_file_path.exists():
		if _has_been_validated:
			new_time = int(time())
			modified = datetime.fromtimestamp(new_time, tz=timezone.utc)
			print('config.quit(): new time will be:', new_time, modified)
			_get_or_set_core('_validation', _wrap(new_time))

		print('config.quit(): new file or had made changes; saving...')
		with open(_config_file_path, 'w') as configfile:
			_config.write(configfile)
	else:
		print('config.quit(): no changes made to config; not saving')


def _wrap(thing):
	hashed = sha224(bytes(SECRET + str(thing), 'utf-8')).hexdigest()
	print(hashed)
	return hashed


def _upgrade_config():
	"""Check if any new defaults were added and apply them if so.

	Limitation: deprecated fields will remain in the file."""
	global _made_changes

	for key, default in INITIAL_CONFIG.items():
		if key not in _config['launcher']:
			_config['launcher'][key] = default
			_made_changes = True


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
	global _made_changes

	if new_value is None:
		return _convert_to_type(_config['launcher'][name])

	new_value_string = _convert_to_string(new_value)
	if _config['launcher'][name] != new_value_string:
		_config['launcher'][name] = new_value_string
		_made_changes = True


def __getattr__(name):
	if name in _config['launcher']:
		return lambda value=None: _get_or_set_core(name, value)
	else:
		raise AttributeError(name)
