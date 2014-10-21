#!/usr/bin/env python
"""Convert manuals from Markdown to HTML using Pandoc"""
import subprocess
import glob

def convert():
    for manual in ['user-manual', 'development-manual']:
        mdfiles = glob.glob(manual + '*md')
        result = subprocess.call([
            'pandoc',
            '--to', 'html5',
		'--standalone',
		'--smart',
		'--table-of-contents',
		'--toc-depth', '6',
		'--number-sections',
		'--css', 'agrip.css',
		'--include-in-header', 'in-head.html',
		'--output', manual + '.html']
            + mdfiles)
        if result is not 0:
            raise Exception("It appears there was an error using Pandoc.")

if __name__ == '__main__':
    convert()
