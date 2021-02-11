"""QMOD file handling"""
from configparser import ConfigParser
from pathlib import Path
import shutil
from zipfile import ZipFile


class BadQMODFileError(Exception):
	pass


class NoQMODDirectoryError(Exception):
	pass


class BadQMODDirectoryError(Exception):
	pass


class QMODFile():
	def __init__(self, path):
		zipfile = ZipFile(path, mode='r')
		if zipfile.testzip() is not None:
			raise BadQMODFileError("'" + path + "' failed zip test")
		files = zipfile.namelist()
		if 'qmod.ini' not in files:
			raise BadQMODFileError("Missing 'qmod.ini'")
		files.remove('qmod.ini')
		dirs = set([Path(x).parts[0] for x in files])
		if len(dirs) > 1:
			raise BadQMODFileError('Improper directory structure')

		ini_string = zipfile.read('qmod.ini').decode('utf-8')
		config = ConfigParser()
		config.read_string(ini_string)

		self.name = config['general']['name']
		self.shortdesc = config['general']['shortdesc']
		self.version = config['general']['version']
		self.longdesc = ' '.join([line for line in config['longdesc'].values()])

		self.gamedir = config['general']['gamedir']

		self.datafiles = files
		self.zipfile = zipfile

	def install(self, root):
		for datafile in self.datafiles:
			self.zipfile.extract(datafile, path=root)  # will be within gamedir

		self.zipfile.extract('qmod.ini', path=root / self.gamedir)


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
