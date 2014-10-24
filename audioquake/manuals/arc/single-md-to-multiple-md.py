#!/usr/bin/env python
"""Split up the Markdown files on all but the first 'H1'"""
import os

def process(name):
    PATTERN = '='
    part = 0
    lines = []
    print 'Splitting', name
    with open(single_md_name(name), 'r') as manual:
        for line in manual:
            lines.append(line)
            if line.startswith(PATTERN):
                if not lines[-2].startswith('AGRIP'):  # ignore dup'd title
                    part += 1
                    print 'Found part', part, 'at:', lines[-2].strip()
                    found_part(name, part-1, lines[:-3])  # inc redundant blank
                    lines = lines[-2:]
                else:
                    print 'Ignoring redundant title part:', \
                        lines[-2].strip()

        # Some lines will be left over...
        print 'Ending on part', part, lines[0]
        found_part(name, part, lines)

    # Remove the single markdown file to avoid confusion
    os.remove(single_md_name(name))


def found_part(name, part, lines):
    output = open(file_inc_part_name(name, part), 'w')
    for line in lines:
        output.write(line)
    output.close()


def single_md_name(name):
    return name + '.md'


def file_inc_part_name(name, part):
    return name + '-part%02d' % part + '.md'


if __name__ == '__main__':
    for manual in ['user-manual', 'development-manual']:
        process(manual)
