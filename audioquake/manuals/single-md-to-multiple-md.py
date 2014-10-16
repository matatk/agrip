#!/usr/bin/env python
"""Split up the Markdown files on all but the first 'H1'"""
import os

def process(name):
    PATTERN = '='
    part = -1
    lines = []
    print 'Splitting', name
    with open(single_md_name(name), 'r') as manual:
        for line in manual:
            lines.append(line)
            if line.startswith(PATTERN):
                if not lines[-2].startswith('AGRIP'):
                    part += 1
                    print 'Found part', part + 1, 'at:', lines[-2].strip()
                    output = open(file_inc_part_name(name, part), 'w')
                    for line in lines[:-3]:  # assume now-redundant blank line
                        output.write(line)
                    output.close()
                    lines = lines[-2:]
                else:
                    print 'Ignoring redundant title part:', \
                        lines[-2].strip()
    os.remove(single_md_name(name))


def single_md_name(name):
    return name + '.md'


def file_inc_part_name(name, part):
    return name + '-part%02d' % part + '.md'


if __name__ == '__main__':
    for manual in ['user-manual', 'development-manual']:
        process(manual)
