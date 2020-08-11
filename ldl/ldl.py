#!/usr/bin/env python3
'''Level Description Language front-end'''
import argparse
from enum import IntEnum
from pathlib import Path
import sys

import argcomplete

from ldllib.convert import convert
from ldllib.build import build, have_needed_stuff, use_repo_bins
from ldllib.play import play
from ldllib.roundtrip import roundtrip
from ldllib.utils import LDLException


class Mode(IntEnum):
	CONVERT = 0
	BUILD = 1
	PLAY = 2

	def __str__(self):
		return self.name.lower()


def print_exception():
	etype, evalue, etraceback = sys.exc_info()
	print(evalue)


# Don't repeat the valid subcommands in the subcommand help section
# https://stackoverflow.com/a/13429281/1485308
class SubcommandHelpFormatter(argparse.RawDescriptionHelpFormatter):
	def _format_action(self, action):
		parts = super(argparse.RawDescriptionHelpFormatter, self) \
			._format_action(action)
		if action.nargs == argparse.PARSER:
			parts = '\n'.join(parts.split('\n')[1:])
		return parts


def handle_convert(args):
	handle_core(args, Mode.CONVERT)


def handle_build(args):
	handle_core(args, Mode.BUILD)


def handle_play(args):
	handle_core(args, Mode.PLAY)


def handle_core(args, mode):
	if mode >= Mode.BUILD and not have_needed_stuff():
		sys.exit(42)

	already_processed = set()
	for filename_string in args.files:
		filename = Path(filename_string)
		if not filename.is_file():
			if args.verbose:
				print(filename_string, 'is not a readable file - skipping')
			continue
		ext = filename.suffix
		root = filename.with_suffix('')
		base = filename.stem
		if base not in already_processed:
			if ext == '.bsp' and mode == Mode.PLAY:
				try:
					play(filename, args.verbose)
				except LDLException:
					print_exception()
				already_processed.add(base)
			elif ext == '.map' and mode >= Mode.BUILD:
				try:
					build(filename, args.verbose)
					if mode == Mode.PLAY:
						play(root.with_suffix('.bsp'), args.verbose)
				except (LDLException, FileNotFoundError):
					print_exception()
				already_processed.add(base)
			elif ext == '.xml':
				try:
					convert(filename, args.verbose, args.keep)
					if mode > Mode.CONVERT:
						build(root.with_suffix('.map'), args.verbose)
					if mode == Mode.PLAY:
						play(root.with_suffix('.bsp'), args.verbose)
				except (LDLException, FileNotFoundError):
					print_exception()
				already_processed.add(base)
			else:
				if args.verbose:
					print("Can't", mode, filename, '-- skipping')
		else:
			if args.verbose:
				print('skipping', filename, '- already processed', base)


def handle_roundtrip(args):
	# TODO cope with XML too?
	# TODO cope with XML and non-built MAPs when PLAY is requested?
	for filename_string in args.files:
		filename = Path(filename_string)
		if not filename.is_file():
			print(filename_string, 'is not a readable file - skipping')
			continue
		ext = filename.suffix
		if ext == '.map':
			try:
				roundtrip(filename, args.verbose, args.keep, args.play)
			except LDLException:
				print_exception()


parser = argparse.ArgumentParser(
	description='AGRIP Level Description Language Tools',
	formatter_class=SubcommandHelpFormatter)

parser.add_argument(
	'-v', '--verbose', action='store_true',
	help='display extra details whilst processing')

parser.add_argument(
	'-k', '--keep', action='store_true',
	help='save intermediate XML files at each level of conversion')

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

argcomplete.autocomplete(parser)
args = parser.parse_args()
args.func(args)
