#!/usr/bin/env python3
"""Get all the bits and bobs ready to build AudioQuake"""
import os
import string
import glob
import shutil
import sys

import mistune
import mistune_contrib.toc

aq_path = os.path.dirname(os.path.abspath(__file__))
lib_path = os.path.join(aq_path, os.pardir)
sys.path.append(lib_path)

from buildlib import Config, \
	prep_dir, try_to_run, is_mac, check_platform, die, comeback


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

	document_template = open(
		os.path.join(Config.dir_manuals, 'template.html'), 'r').read()

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

	open(os.path.join(output_dir, base_name + '.html'), 'w').write(
		full_document)


def convert_manuals():
	for manual in ['user-manual', 'development-manual']:
		print('Converting', manual)
		sources = sorted(glob.glob(os.path.join(Config.dir_manuals, manual) + '*'))
		convert_markdown_files(manual, sources, Config.dir_manuals_converted)

	single_docs_to_convert = {
		'sound-legend': os.path.join(Config.dir_manuals, 'user-manual-part07-b.md'),
		'README': os.path.join(Config.dir_readme_licence, 'README.md'),
		'LICENCE': os.path.join(Config.dir_readme_licence, 'LICENCE.md')}

	for docname, docpath in single_docs_to_convert.items():
		print('Converting ' + docname)
		convert_markdown_files(docname, docpath, Config.dir_manuals_converted)


#
# Running PyInstaller
#

@comeback
def run_pyinstaller():
	# FIXME DRY all these chdirs
	path = os.path.dirname(os.path.abspath(__file__))
	try:
		os.chdir(path)
	except:  # noqa E727
		die("can't change directory to: " + path)

	# Grab the LDL library from the next directory along
	dir_local_ldllib = os.path.join(os.getcwd(), 'ldllib')
	shutil.rmtree(dir_local_ldllib, ignore_errors=True)
	shutil.copytree(Config.dir_ldllib, dir_local_ldllib)

	for spec in ['AudioQuake.spec', 'rcon.spec']:
		print('Running PyInstaller on ' + spec)
		try_to_run(
			('pyinstaller', '-y', spec),
			'failed to run PyInstaller on ' + spec)


def copy_in_rcon():
	if is_mac():
		rcon_bin = 'rcon'
	else:
		rcon_bin = 'rcon.exe'

	shutil.copy(
		os.path.join(Config.dir_dist_rcon, rcon_bin),
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
	run_pyinstaller()
	copy_in_rcon()

	print('Completed building AudioQuake with Level Description Language.')
	print('Distributable software is in:', Config.dir_dist)


if __name__ == '__main__':
	build_audioquake()
