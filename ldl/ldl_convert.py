'''LDL XML-to-map Converter'''
from level_00_down_map2mapxml import main as level0
from level_01_down_brushsizes import main as level1
from level_02_down_rooms import main as level2
from level_03_down_lighting import main as level3
from level_04_down_buildermacros import main as level4
from level_05_down_connections import main as level5
from utils import set_verbosity


def _keep(keep, level, basename, content):
	if keep:
		with open(basename + '_level_' + str(level) + '.xml', 'w') as out:
			out.write(content)


def convert(xml_file_name, basename, verbose, keep):
	print('Converting', xml_file_name)
	set_verbosity(verbose)
	with open(xml_file_name, 'r') as xml_file:
		ldlstring = xml_file.read()
	level4string = level5(ldlstring)
	_keep(keep, 4, basename, level4string)
	level3string = level4(level4string)
	_keep(keep, 3, basename, level3string)
	level2string = level3(level3string)
	_keep(keep, 2, basename, level2string)
	level1string = level2(level2string)
	_keep(keep, 1, basename, level1string)
	level0string = level1(level1string)
	_keep(keep, 0, basename, level0string)
	mapfile = level0(level0string)
	with open(basename + '.map', 'w') as outfile:
		outfile.write(mapfile)
