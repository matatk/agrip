#!/usr/bin/env python3
'''Level Description Language front-end'''
import argparse
from enum import IntEnum
from pathlib import Path
import sys

import argcomplete

from ldllib.convert import WADs, DEFAULT_WAD, use_repo_wads, have_wad, convert
from ldllib.build import build, have_needed_progs, use_repo_bins
from ldllib.play import play
from ldllib.roundtrip import roundtrip
from ldllib.utils import LDLError


class Mode(IntEnum):
	CONVERT = 0
	BUILD = 1
	PLAY = 2

	def __str__(self):
		return self.name.lower()


def print_exception():
	etype, evalue, etraceback = sys.exc_info()
	print(evalue)


def handle_convert(args):
	handle_core(args, Mode.CONVERT)


def handle_build(args):
	handle_core(args, Mode.BUILD)


def handle_play(args):
	handle_core(args, Mode.PLAY)


def handle_core(args, mode):
	if mode >= Mode.BUILD and not have_needed_progs():
		sys.exit(42)

	if mode >= Mode.BUILD and not have_wad(args.wad):
		sys.exit(42)

	# We only loop over the basenames of the files passed in, because the user
	# could have various temporary files in the directory, and we want to go
	# from the XML by default.

	files = [Path(filename) for filename in args.files]
	bases = [filepath.with_suffix('') for filepath in files]

	for basename in bases:
		xmlfile = basename.with_suffix('.xml')
		mapfile = basename.with_suffix('.map')
		bspfile = basename.with_suffix('.bsp')

		if xmlfile in files:
			try:
				if mode >= Mode.CONVERT:
					convert(
						xmlfile,
						wad=args.wad,
						verbose=args.verbose,
						keep_intermediate=args.keep)
					if mode >= Mode.BUILD:
						build(mapfile, args.verbose)
						if mode == Mode.PLAY:
							play(bspfile, args.verbose)
			except (LDLError, FileNotFoundError):
				print_exception()

		elif mapfile in files:
			try:
				if mode >= Mode.BUILD:
					build(mapfile, args.verbose)
					if mode == Mode.PLAY:
						play(bspfile, args.verbose)
			except (LDLError, FileNotFoundError):
				print_exception()

		elif bspfile in files:
			try:
				if mode == Mode.PLAY:
					play(bspfile, args.verbose)
			except LDLError:
				print_exception()

		else:
			if args.verbose:
				print("Can't", mode, basename, '-- skipping')


def handle_roundtrip(args):
	# TODO cope with XML too?
	# TODO cope with XML and non-built MAPs when PLAY is requested?
	for filename_string in args.files:
		filename = Path(filename_string)
		if not filename.is_file():
			if args.verbose:
				print(filename_string, 'is not a readable file - skipping')
			continue
		if filename.suffix == '.map':
			try:
				roundtrip(filename, args.verbose, args.keep, args.play)
			except LDLError:
				print_exception()


parser = argparse.ArgumentParser(
	description='AGRIP Level Description Language Tools',
	epilog=(
		'The order of precedence for file extensions is: ".xml"; ".map"; '
		'".bsp". Thus if you ask for the "convert" action, and there is both a '
		'"mymap.xml" and a "mymap.map" file in the list of files to process, '
		'then "mymap.xml" is converted, overwriting "mymap.map". '

		"The rationale for this behaviour is that it's best to keep the XML "
		'files as the single point of truth, so LDL should always try to work '
		'as closely to the XML files as possible. '

		'It also means that you can keep intermediate files from previous runs '
		'and still use wildcards quite liberally on the command-line.'),
	formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument(
	'-v', '--verbose', action='store_true',
	help='display extra details whilst processing')

parser.add_argument(
	'-k', '--keep', action='store_true',
	help='save intermediate XML files at each level of conversion')

parser.add_argument(
	'-w', '--wad',
	default=DEFAULT_WAD.value,
	choices=[w.value for w in WADs],
	help='Texture WAD file to use')


subparsers = parser.add_subparsers(
	title='actions', required=True, dest='action',
	description='issue "roundtrip -h/--help" for more help on that one')


parser_convert = subparsers.add_parser(
	'convert', help='Convert from XML to .map',
	description='Transform LDL XML files into Quake .map files')

parser_convert.add_argument(
	'files', nargs='+', metavar='xml-file',
	help='XML file(s) to convert')

parser_convert.set_defaults(func=handle_convert)


parser_build = subparsers.add_parser(
	'build', help='Build playable .bsp files', description='\
		Run the Quake tools to compile .map files into playable .bsp files')

parser_build.add_argument(
	'files', nargs='+', metavar='xml-or-map-file',
	help='XML or converted .map file(s) to build')

parser_build.set_defaults(func=handle_build)


parser_play = subparsers.add_parser(
	'play', help='Play maps in-game', description='\
		Try maps (possibly converting and building them first) in-game')

parser_play.add_argument(
	'files', nargs='+', metavar='xml-or-map-or-bsp',
	help='XML, converted .map or bulit .bsp file(s) to play')

parser_play.set_defaults(func=handle_play)


parser_roundtrip = subparsers.add_parser(
	'roundtrip', help='Round-trip .map files', description='\
		Convert a .map into second-level LDL XML and back')

parser_roundtrip.add_argument(
	'-p', '--play', action='store_true',
	help='play the map(s) after round-trip')

parser_roundtrip.add_argument(
	'files', nargs='+', metavar='map-file', help='.map file(s) to round-trip')

parser_roundtrip.set_defaults(func=handle_roundtrip)


use_repo_bins()
use_repo_wads()

argcomplete.autocomplete(parser)
args = parser.parse_args()
args.wad = WADs(args.wad)
args.func(args)
