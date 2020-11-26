'''LDL Global Configuration Variables and Constants'''
from pathlib import Path
import platform


#
# Configuration Variables
#

class prog:
	lip = 8  # thickness of wall brushes.
	lip_small = lip / 2  # thickness of door brushes.
	lip_small_margin = lip_small / 2  # thickness of margins around door brushes.
	# FIXME: put in the style file...
	boilerplate = '<!-- This file was generated by a Level Description ' \
		'Language (LDL) script from\n	 the AGRIP project ' \
		'(http://www.agrip.org.uk/). -->\n'
	boilerplate_map = '// This file was generated by a Level Description ' \
		'Language (LDL) script from\n// the AGRIP project ' \
		'(http://www.agrip.org.uk/).\n'
	stackdescs = {
		0: 'Stage 00: Raw .map files to simple XML',
		1: 'Stage 01: Brush origins and extents',
		2: 'Stage 02: Rooms\'n\'Stuff',
		3: 'Stage 03: Lighting styles.',
		4: 'Stage 04: Builder Macros',
		5: 'Stage 0y: 3D Connections Level'
	}
	STYLE_FILE = Path('mapping') / 'style.xml'
	# the style file for our maps (contains textures, sounds and lighting presets)
	concretion_attempts = 3
	# number of times the top level tries to parse the hash for info required for
	# the lower levels.
	MAP_ORIGIN = (0, 0, 0)
	ELEV_DIST = 30

	bins = Path('bin')
	qbsp = bins / 'qbsp'
	vis = bins / 'vis'
	light = bins / 'light'
	bspinfo = bins / 'bspinfo'

	if platform.system() == 'Windows':
		qbsp = qbsp.with_suffix('.exe')
		vis = vis.with_suffix('.exe')
		light = light.with_suffix('.exe')
		bspinfo = bspinfo.with_suffix('.exe')


#
# Constants
#

class dims:  # FIXME named plurally due to conflict with a variable name
	X = 'x'
	Y = 'y'
	Z = 'z'


class dcp:
	NORTH = 'n'
	SOUTH = 's'
	EAST = 'e'
	WEST = 'w'
	NORTHEAST = 'ne'
	SOUTHEAST = 'se'
	SOUTHWEST = 'sw'
	NORTHWEST = 'nw'
	UP = 'u'
	DOWN = 'd'
	CENTRE = 'c'

	TOP = 't'
	BOTTOM = 'b'
	RIGHT = 'r'
	LEFT = 'l'
	TOPRIGHT = 'tr'
	BOTTOMRIGHT = 'br'
	BOTTOMLEFT = 'bl'
	TOPLEFT = 'tl'


class connector:
	DOOR = 'door'
	PLAT = 'plat'
	STEP = 'step'
	STAIRS = 'stairs'
	# stairs was separate before, and referred to as an 'elevator' type of
	# thing


class propertytype:
	INT = 'int'
	TEXT = 'text'


worldtypes = {
	'medieval': '0',
	'runic': '1',
	'base': '2'
}

key_ents = {
	'silver': 'item_key1',
	'gold': 'item_key2'
}

key_access = {
	'silver': '16',
	'gold': '8'
}


class lightingstyle:
	GRID = 'grid'
	CENTRE = 'centre'
	PERIMETER = 'perimeter'
	DEF = ''


# Valid items
valid_entities = [
	'air_bubbles',
	'ambient_drip',
	'ambient_drone',
	'ambient_comp_hum',
	'ambient_flouro_buzz',
	'ambient_light_buzz',
	'ambient_suck_wind',
	'ambient_swamp1',
	'ambient_swamp2',
	'ambient_thunder',
	'event_lightning',
	'func_door',
	'func_door_secret',
	'func_wall',
	'func_button',
	'func_train',
	'func_plat',
	'func_dm_only',
	'func_illusionary',
	'info_null',
	'info_notnull',
	'info_intermission',
	'info_player_start',
	'info_player_deathmatch',
	'info_player_coop',
	'info_player_start2',
	'info_teleport_destination',
	'item_cells',
	'item_rockets',
	'item_shells',
	'item_spikes',
	'item_weapon',
	'item_health',
	'item_artifact_envirosuit',
	'item_artifact_super_damage',
	'item_artifact_invulnerability',
	'item_artifact_invisibility',
	'item_armorInv',
	'item_armor2',
	'item_armor1',
	'item_key1',
	'item_key2',
	'item_sigil',
	'light',
	'light_torch_small_walltorch',
	'light_flame_large_yellow',
	'light_flame_small_yellow',
	'light_flame_small_white',
	'light_fluoro',
	'light_fluorospark',
	'light_globe',
	'monster_army',
	'monster_dog',
	'monster_ogre',
	'monster_ogre_marksman',
	'monster_knight',
	'monster_zombie',
	'monster_wizard',
	'monster_demon1',
	'monster_shambler',
	'monster_boss',
	'monster_enforcer',
	'monster_hell_knight',
	'monster_shalrath',
	'monster_tarbaby',
	'monster_fish',
	'monster_oldone',
	'misc_fireball',
	'misc_explobox',
	'misc_explobox2',
	'misc_teleporttrain',
	'path_corner',
	'trap_spikeshooter',
	'trap_shooter',
	'trigger_teleport',
	'trigger_changelevel',
	'trigger_setskill',
	'trigger_counter',
	'trigger_once',
	'trigger_multiple',
	'trigger_onlyregistered',
	'trigger_secret',
	'trigger_monsterjump',
	'trigger_relay',
	'trigger_push',
	'trigger_hurt',
	'weapon_supershotgun',
	'weapon_nailgun',
	'weapon_supernailgun',
	'weapon_grenadelauncher',
	'weapon_rocketlauncher',
	'weapon_lightning'
]
