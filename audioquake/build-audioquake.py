#!/usr/bin/env python3
"""Get all the bits and bobs ready to build AudioQuake"""
import argparse
from os import chdir
from pathlib import Path
import string
import shutil

import mistune
import mistune_contrib.toc

from buildlib import Config, \
	prep_dir, try_to_run, platform_set, check_platform, die, comeback

skip_pyinstaller = False  # set via command-line option


#
# Converting the manuals and other docs
#

class TocRenderer(mistune_contrib.toc.TocMixin, mistune.Renderer):
	pass


def convert_markdown_files(base_name, markdown_files, output_dir):
	toc = TocRenderer()
	md = mistune.Markdown(renderer=toc)

	source = ''

	fancy_name = base_name.translate({ord('-'): ' '}).title()

	document_template = open(Config.dir_manuals / 'template.html', 'r').read()

	if not isinstance(markdown_files, list):
		markdown_files = [markdown_files]

	for markdown_file in markdown_files:
		source += open(markdown_file, 'r', encoding='utf-8').read()

	toc.reset_toc()
	html_content = md.parse(source)
	html_toc = toc.render_toc(level=3)

	full_document = string.Template(document_template).substitute(
		title=fancy_name,
		toc=html_toc,
		content=html_content)

	open(output_dir / (base_name + '.html'), 'w').write(full_document)


def convert_manuals():
	for manual in ['user-manual', 'development-manual']:
		print('Converting', manual)
		sources = sorted(Config.dir_manuals.glob(manual + '*'))
		convert_markdown_files(manual, sources, Config.dir_manuals_converted)

	single_docs_to_convert = {
		'sound-legend': Config.dir_manuals / 'user-manual-part07-b.md',
		'README': Config.dir_readme_licence / 'README.md',
		'LICENCE': Config.dir_readme_licence / 'LICENCE.md',
		'ldl-tutorial': Config.dir_ldl / 'ldl-tutorial.md'
	}

	for docname, docpath in single_docs_to_convert.items():
		print('Converting ' + docname)
		convert_markdown_files(docname, docpath, Config.dir_manuals_converted)


#
# Running PyInstaller
#

@comeback
def run_pyinstaller():
	# FIXME DRY all these chdirs
	path = Path(__file__).parent
	try:
		chdir(path)
	except:  # noqa E727
		die("can't change directory to: " + path)

	for spec in ['AudioQuake.spec', 'rcon.spec']:
		print('Running PyInstaller on ' + spec)
		try_to_run(
			('pyinstaller', '-y', spec),
			'failed to run PyInstaller on ' + spec)


def copy_in_rcon():
	rcon_bin = platform_set(
		mac='rcon',
		windows='rcon.exe')

	shutil.copy(
		Config.dir_dist_rcon / rcon_bin,
		Config.dir_aq_data)


def build_audioquake():
	with open(Config.file_aq_release, 'r') as f:
		print(
			'Building AudioQuake',
			f.readline().rstrip() + ':', f.readline().rstrip())

	check_platform()

	print('Preparing converted (HTML) manual dir')
	prep_dir(Config.dir_manuals_converted)

	# Markdown to HTML
	convert_manuals()  # TODO replace with a check if it needs doing

	# Build the executables
	if not skip_pyinstaller:
		run_pyinstaller()
		copy_in_rcon()
		print('Completed building AudioQuake with Level Description Language.')
		print('Distributable software is in:', Config.dir_dist)
	else:
		print('Skipping running PyInstaller')


if __name__ == '__main__':
	BANNER = 'Build AudioQuake'

	parser = argparse.ArgumentParser(description=BANNER)

	parser.add_argument(
		'-s', '--skip-pyinstaller', action='store_true',
		help="Don't run PyInstaller (used for debugging manual conversion)")

	args = parser.parse_args()

	if args.skip_pyinstaller:
		skip_pyinstaller = True

	build_audioquake()
