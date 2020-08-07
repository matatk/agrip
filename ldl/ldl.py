#!/usr/bin/env python3
'''Level Description Language front-end'''
import argparse
import argcomplete
import os
import sys
from ldllib.conf import prog
from ldllib.convert import convert
from ldllib.build import build, have_needed_stuff
from ldllib.play import play
from ldllib.roundtrip import roundtrip


# These paths only work for *nix
bin_base = os.path.join('..', 'giants', 'Quake-Tools', 'qutils', 'qbsp')
prog.qbsp = os.path.join(bin_base, 'qbsp')
prog.light = os.path.join(bin_base, 'light')
prog.vis = os.path.join(bin_base, 'vis')
prog.bspinfo = os.path.join(bin_base, 'bspinfo')
# quake.wad has to be in the current directory


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
	for filename in args.files:
		if not os.path.isfile(filename):
			print(filename, 'is not a readable file - skipping')
			continue
		root, ext = os.path.splitext(filename)
		if ext == '.xml':
			try:
				convert(filename, args.verbose, args.keep)
			except:  # noqa: E722
				print_exception()
		else:
			print('skipping', filename, '- not an XML file')


def handle_build(args):
	if not have_needed_stuff():
		sys.exit(42)

	already_processed = set()
	for filename in args.files:
		if not os.path.isfile(filename):
			print(filename, 'is not a readable file - skipping')
			continue
		root, ext = os.path.splitext(filename)
		base = os.path.basename(root)
		if base not in already_processed:
			if ext == '.map':
				try:
					build(filename, args.verbose)
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
			elif ext == '.xml':
				try:
					convert(filename, args.verbose, args.keep)
					build(base + '.map', base, args.verbose)
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
			else:
				print('skipping', filename, '- not an expected file type')
		else:
			if args.verbose:
				print('skipping', filename, '- already processed', base)


def handle_play(args):
	if not have_needed_stuff():
		sys.exit(42)

	already_processed = set()
	for filename in args.files:
		if not os.path.isfile(filename):
			print(filename, 'is not a readable file - skipping')
			continue
		root, ext = os.path.splitext(filename)
		base = os.path.basename(root)
		if base not in already_processed:
			if ext == '.bsp':
				try:
					play(filename, args.verbose)
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
			if ext == '.map':
				try:
					build(filename, args.verbose)
					play(root + '.bsp', args.verbose)
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
			elif ext == '.xml':
				try:
					convert(filename, args.verbose, args.keep)
					build(root + '.map', args.verbose)
					play(root + '.bsp', args.verbose)
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
		else:
			if args.verbose:
				print('skipping', filename, '- already processed', base)


def handle_roundtrip(args):
	# TODO cope with XML too?
	# TODO cope with XML and non-built MAPs when PLAY is requested?
	for filename in args.files:
		if not os.path.isfile(filename):
			print(filename, 'is not a readable file - skipping')
			continue
		root, ext = os.path.splitext(filename)
		if ext == '.map':
			roundtrip(filename, args.verbose, args.keep, args.play)


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


argcomplete.autocomplete(parser)
args = parser.parse_args()
args.func(args)
