'''LDL Roundtrip from .map file back to .map file converter'''
from .level_00_up_map2mapxml import main as level0up
from .level_01_up_brushsizes import main as level1up
from .level_00_down_map2mapxml import main as level0down
from .level_01_down_brushsizes import main as level1down
from .utils import keep, set_verbosity
from ldllib.play import play


def roundtrip(
	map_name, verbose=False, keep_intermediate=False, play_after=False):
	print('Roundtripping', map_name)
	map_name_without_ext = map_name[:-4]
	roundtripped_map_name_without_ext = map_name_without_ext + '_roundtripped'
	roundtripped_map_name = roundtripped_map_name_without_ext + '.map'
	set_verbosity(verbose)

	with open(map_name, 'r') as map_file:
		map_string = map_file.read()

	map_xml = level0up(map_string)
	keep(keep_intermediate, 0, map_name_without_ext + '_up', map_xml)
	level_1 = level1up(map_xml)
	keep(keep_intermediate, 1, map_name_without_ext + '_up', level_1)
	map_xml_again = level1down(level_1)
	keep(keep_intermediate, 0, map_name_without_ext + '_down', map_xml_again)
	map_again = level0down(map_xml_again)

	with open(roundtripped_map_name, 'w') as outfile:
		outfile.write(map_again)

	if play_after is True:
		play(map_name, verbose)
		play(roundtripped_map_name, verbose)
