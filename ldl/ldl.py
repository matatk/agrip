#!/usr/bin/env python3
'''Level Description Language front-end'''
import argparse
import argcomplete
import os
from ldl_convert import convert


# Don't repeat the valid subcommands in the subcommand help section
# https://stackoverflow.com/a/13429281/1485308
class SubcommandHelpFormatter(argparse.RawDescriptionHelpFormatter):
	def _format_action(self, action):
		parts = super(argparse.RawDescriptionHelpFormatter, self) \
			._format_action(action)
		if action.nargs == argparse.PARSER:
			parts = '\n'.join(parts.split('\n')[1:])
		return parts


keep_intermediate_xml_help_text = '\
	save intermediate XML files at each level of conversion'


def handle_convert(args):
	print('Converting')
	for filename in args.files:
		root, ext = os.path.splitext(filename)
		base = os.path.basename(root)
		if ext == '.xml':
			convert(filename, base, args.verbose)


def handle_build(args):
	already_processed = set()
	print('Building')
	for filename in args.files:
		root, ext = os.path.splitext(filename)
		base = os.path.basename(root)
		if base not in already_processed:
			if ext == '.map':
				print('building', filename)
				already_processed.add(base)
			elif ext == '.xml':
				print('converting', filename, 'first')
				already_processed.add(base)
				# TODO then build it
		else:
			if args.verbose:
				print('skipping', filename, '- already processed', base)


def handle_play(args):
	already_processed = set()
	print('Playing')
	for filename in args.files:
		root, ext = os.path.splitext(filename)
		base = os.path.basename(root)
		if base not in already_processed:
			if ext == '.bsp':
				print('playing', filename)
				already_processed.add(base)
			if ext == '.map':
				print('building', filename, 'first')
				already_processed.add(base)
				# TODO then play it
			elif ext == '.xml':
				print('converting', filename, 'first')
				already_processed.add(base)
				# TODO then build it
				# TODO then play it
		else:
			if args.verbose:
				print('skipping', filename, '- already processed', base)


def handle_roundtrip(args):
	print('Round-tripping')
	for filename in args.files:
		if os.path.splitext(filename)[1] == '.map':
			print('round-tripping', filename)


parser = argparse.ArgumentParser(
	description='AGRIP Level Description Language Tools',
	formatter_class=SubcommandHelpFormatter)

parser.add_argument(
	'-v', '--verbose', action='store_true',
	help='display extra details whilst processing')

subparsers = parser.add_subparsers(
	title='actions', required=True, dest='action',
	description='issue <action> -h/--help for more help on each of these')


parser_convert = subparsers.add_parser(
	'convert', help='Convert from XML to .map',
	description='Transform LDL XML files into Quake .map files')

parser_convert.add_argument(
	'-k', '--keep', action='store_true', help=keep_intermediate_xml_help_text)

parser_convert.add_argument(
	'files', nargs='+', metavar='xml-file',
	help='XML file(s) to convert')

parser_convert.set_defaults(func=handle_convert)


parser_build = subparsers.add_parser(
	'build', help='Build playable .bsp files', description='\
		Run the Quake tools to compile .map files into playable .bsp files')

parser_build.add_argument(
	'-k', '--keep', action='store_true',
	help="don't remove the .map file after building")

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
	'-k', '--keep', action='store_true', help=keep_intermediate_xml_help_text)

parser_roundtrip.add_argument(
	'-p', '--play', action='store_true',
	help='play the map(s) after round-trip')

parser_roundtrip.add_argument(
	'files', nargs='+', metavar='map-file', help='.map file(s) to round-trip')

parser_roundtrip.set_defaults(func=handle_roundtrip)


argcomplete.autocomplete(parser)
args = parser.parse_args()
args.func(args)
