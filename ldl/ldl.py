#!/usr/bin/env python3
'''Level Description Language front-end'''
import argparse
import argcomplete
import os
import sys
import traceback
from ldl_convert import convert
from ldl_build import build, have_needed_stuff
from ldl_play import play
from ldl_roundtrip import roundtrip


def print_exception():
	etype, evalue, etraceback = sys.exc_info()
	print('ERROR:', evalue)
	traceback.print_tb(etraceback)


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
	for filename in args.files:
		if not os.path.isfile(filename):
			print(filename, "doesn't exist - skipping")
			continue
		root, ext = os.path.splitext(filename)
		base = os.path.basename(root)
		if ext == '.xml':
			try:
				convert(filename, base, args.verbose, args.keep)
			except SystemExit:
				pass
			except:  # noqa: E722
				print_exception()


def handle_build(args):
	if not have_needed_stuff():
		sys.exit(42)

	already_processed = set()
	for filename in args.files:
		if not os.path.isfile(filename):
			print(filename, "doesn't exist - skipping")
			continue
		root, ext = os.path.splitext(filename)
		base = os.path.basename(root)
		if base not in already_processed:
			if ext == '.map':
				try:
					build(filename, base, args.verbose)
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
			elif ext == '.xml':
				try:
					convert(filename, base, args.verbose, False)
					build(base + '.map', base, args.verbose)
				except SystemExit:
					pass
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
		else:
			if args.verbose:
				print('skipping', filename, '- already processed', base)


def handle_play(args):
	if not have_needed_stuff():
		sys.exit(42)

	already_processed = set()
	for filename in args.files:
		if not os.path.isfile(filename):
			print(filename, "doesn't exist - skipping")
			continue
		root, ext = os.path.splitext(filename)
		base = os.path.basename(root)
		if base not in already_processed:
			if ext == '.bsp':
				try:
					play(filename, base, args.verbose)
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
			if ext == '.map':
				try:
					build(filename, base, args.verbose)
					play(base + '.bsp', base, args.verbose)
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
			elif ext == '.xml':
				try:
					convert(filename, base, args.verbose, False)
					build(base + '.map', base, args.verbose)
					play(base + '.bsp', base, args.verbose)
				except SystemExit:
					pass
				except:  # noqa: E722
					print_exception()
				already_processed.add(base)
		else:
			if args.verbose:
				print('skipping', filename, '- already processed', base)


def handle_roundtrip(args):
	for filename in args.files:
		root, ext = os.path.splitext(filename)
		base = os.path.basename(root)
		# FIXME cope with XML too
		# FIXME cope with XML and non-built MAPs when PLAY is requested
		if ext == '.map':
			roundtrip(filename, base, args.verbose, args.keep, args.play)


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
