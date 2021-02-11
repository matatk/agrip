"""QMOD file handling"""
from configparser import ConfigParser
from pathlib import Path
import shutil
from zipfile import ZipFile, BadZipFile


class BadQMODFileError(Exception):
	pass


class NoQMODDirectoryError(Exception):
	pass


class BadQMODDirectoryError(Exception):
	pass


class QMODFile():
	def __init__(self, path):
		try:
			archive = ZipFile(path, mode='r')
		except BadZipFile:
			name = Path(path).name
			raise BadQMODFileError(f"'{name}' is not in ZIP compressed format")

		if archive.testzip() is not None:
			raise BadQMODFileError(f"'{path}' failed zip test")

		files = archive.namelist()
		if 'qmod.ini' not in files:
			raise BadQMODFileError("Missing 'qmod.ini'")
		files.remove('qmod.ini')

		dirs = set([Path(x).parts[0] for x in files])
		if len(dirs) > 1:
			raise BadQMODFileError('Improper directory structure')

		try:
			ini_string = archive.read('qmod.ini').decode('utf-8')
		except Exception as err:
			raise BadQMODFileError(f"Couldn't read/decode 'qmod.ini': {err}")

		try:
			config = ConfigParser()
			config.read_string(ini_string)
		except Exception as err:
			raise BadQMODFileError(f"'qmod.ini' is invalid: {err}")

		try:
			self.name = config['ge3eral']['name']
			self.shortdesc = config['general']['shortdesc']
			self.version = config['general']['version']
			self.longdesc = ' '.join(
				[line for line in config['longdesc'].values()])
			self.gamedir = config['general']['gamedir']
		except KeyError as err:
			raise BadQMODFileError(f"'qmod.ini' is missing section/key '{err}'")

		self.datafiles = files
		self.archive = archive

	def install(self, root):
		for datafile in self.datafiles:
			self.archive.extract(datafile, path=root)  # will be within gamedir

		self.archive.extract('qmod.ini', path=root / self.gamedir)


class InstalledQMOD():
	def __init__(self, name):
		path = Path(name)

		if not path.is_dir():
			raise NoQMODDirectoryError()

		ini_path = path / 'qmod.ini'

		if not ini_path.is_file():
			raise BadQMODDirectoryError()

		config = ConfigParser()
		config.read_file(open(ini_path))

		self.watch_config = config['general'].getboolean('watch_config')
		self.watch_autoexec = config['general'].getboolean('watch_autoexec')

		self.name = config['general']['name']
		self.version = config['general']['version']

		self.mod_path = path

	def apply_watches(self):
		id1_path = self.mod_path.parent / 'id1'

		if self.watch_config:
			shutil.copy(id1_path / 'config.cfg', self.mod_path)

		if self.watch_autoexec:
			shutil.copy(id1_path / 'autoexec.cfg', self.mod_path)
