'''LDL XML-to-map Converter'''
import os

from .level_00_down_map2mapxml import main as level0
from .level_01_down_brushsizes import main as level1
from .level_02_down_rooms import main as level2
from .level_03_down_lighting import main as level3
from .level_04_down_buildermacros import main as level4
from .level_05_down_connections import main as level5
from .utils import set_verbosity


def _keep(keep, level, without_ext, content):
	if keep:
		with open(without_ext + '_level_' + str(level) + '.xml', 'w') as out:
			out.write(content)


def convert(xml_file_name, verbose, keep):
	without_ext = os.path.splitext(xml_file_name)[0]
	print('Converting', xml_file_name)
	set_verbosity(verbose)

	with open(xml_file_name, 'r') as xml_file:
		ldl_string = xml_file.read()

	level4string = level5(ldl_string)
	_keep(keep, 4, without_ext, level4string)
	level3string = level4(level4string)
	_keep(keep, 3, without_ext, level3string)
	level2string = level3(level3string)
	_keep(keep, 2, without_ext, level2string)
	level1string = level2(level2string)
	_keep(keep, 1, without_ext, level1string)
	level0string = level1(level1string)
	_keep(keep, 0, without_ext, level0string)
	mapfile = level0(level0string)

	with open(without_ext + '.map', 'w') as outfile:
		outfile.write(mapfile)
