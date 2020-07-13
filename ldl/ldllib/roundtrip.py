'''LDL Roundtrip from .map file back to .map file converter'''
from .level_00_up_map2mapxml import main as level0up
from .level_01_up_brushsizes import main as level1up
from .level_00_down_map2mapxml import main as level0down
from .level_01_down_brushsizes import main as level1down
from .utils import set_verbosity
from ldllib.play import play


def _keep(keep, level, basename, content):
	if keep:
		with open(basename + '_level_' + str(level) + '.xml', 'w') as out:
			out.write(content)


def roundtrip(map_file_name, basename, verbose, keep, play_after):
	print('Roundtripping', map_file_name)
	roundtripped_map_file_basename = basename + '_roundtripped'
	roundtripped_map_file_name = roundtripped_map_file_basename + '.map'
	set_verbosity(verbose)
	with open(map_file_name, 'r') as map_file:
		mapstring = map_file.read()
	map_xml = level0up(mapstring)
	_keep(keep, 0, basename + '_up', map_xml)
	level_1 = level1up(map_xml)
	_keep(keep, 1, basename + '_up', level_1)
	map_xml_again = level1down(level_1)
	_keep(keep, 0, basename + '_down', map_xml_again)
	map_again = level0down(map_xml_again)
	with open(roundtripped_map_file_name, 'w') as outfile:
		outfile.write(map_again)

	if play_after is True:
		play(map_file_name, basename, verbose)
		play(roundtripped_map_file_name, roundtripped_map_file_basename, verbose)
