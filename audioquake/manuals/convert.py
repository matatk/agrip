#!/usr/bin/env python
"""Convert manuals from Markdown to HTML using Pandoc"""
import subprocess
import glob
import sys  # command-line

def _convert_core(output_name, input_names, manuals_mode=False):
    main_command_bits = [
        'pandoc',
        '--to', 'html5',
        '--standalone',
        '--smart',
        '--table-of-contents',
        '--toc-depth', '6',
        '--number-sections',
        '--output', output_name]
    # Manuals are converted before being copied to the staging area; set paths
    # for header HTML and CSS (which will always be in the same dir as them)
    manual_extra_bits = [
        '--css', 'agrip.css',
        '--include-in-header', 'in-head.html']
    # The standalone documents will be converted in the app-staging area; set
    # paths appropriate to that conversion and CSS usage
    standalone_extra_bits = [
        '--css', 'manuals/agrip.css',
        '--include-in-header', '../manuals/in-head.html']

    if manuals_mode:
        pandoc_command = main_command_bits + manual_extra_bits
    else:
        pandoc_command = main_command_bits + standalone_extra_bits

    result = subprocess.call(pandoc_command + input_names)
    if result is not 0:
        raise Exception("It appears there was an error using Pandoc.")


def manuals():
    for manual in ['user-manual', 'development-manual']:
        print 'manual:', manual
        mdfiles = glob.glob(manual + '*md')
        _convert_core(manual + '.html', mdfiles, True)


def single_md_to_html(file_name):
    print 'single_md_to_html:', file_name
    if file_name.endswith('.md'):
        output_file = file_name[:-3] + '.html'
    else:
        print 'File name', file_name, 'does not end with .md'
        return
    _convert_core(output_file, [file_name])


def all_single_md_files():
    mdfiles = glob.glob('*.md')
    for mdfile in mdfiles:
        single_md_to_html(mdfile)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print 'Usage:', sys.argv[0], 'manuals|all-single'
    else:
        if sys.argv[1] == 'manuals':
            manuals()
        elif sys.argv[1] == 'all-single':
            all_single_md_files()
        else:
            print 'Unrecognised sub-command:', sys.argv[1]
