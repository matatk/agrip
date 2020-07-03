"""QMOD file handling"""
from pathlib import Path
from zipfile import ZipFile
from configparser import ConfigParser


class BadQMODFileException(Exception):
	pass


class QMODFile():
	def __init__(self, path):
		zipfile = ZipFile(path, mode='r')
		if zipfile.testzip() is not None:
			raise BadQMODFileException("'" + path + "' failed zip test")
		files = zipfile.namelist()
		if 'qmod.ini' not in files:
			raise BadQMODFileException("Missing 'qmod.ini'")
		files.remove('qmod.ini')
		dirs = set([Path(x).parts[0] for x in files])
		if len(dirs) > 1:
			raise BadQMODFileException('Improper directory structure')

		ini_string = zipfile.read('qmod.ini').decode('utf-8')
		config = ConfigParser()
		config.read_string(ini_string)

		self.name = config['general']['name']
		self.shortdesc = config['general']['shortdesc']
		self.version = config['general']['version']
		self.longdesc = ' '.join([line for line in config['longdesc'].values()])

		self.gamedir = config['general']['gamedir']
		self.watch_config = config['general']['watch_config']    # TODO impl
		self.watch_config = config['general']['watch_autoexec']  # TODO impl

		self.datafiles = files
		self.zipfile = zipfile

	def install(self):
		for datafile in self.datafiles:
			self.zipfile.extract(datafile)

		self.zipfile.extract('qmod.ini', path=self.gamedir)
