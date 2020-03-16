#!/usr/bin/python3

from fontParts.world import *
import argparse


def main():
    parser = argparse.ArgumentParser(description='Find differences in glyph inventory between v5 and v6 CDGA')
    parser.add_argument('--version', action='version', version='%(prog)s ')
    parser.add_argument('old', help='old v5 list of glyphs')
    parser.add_argument('new', help='new v6 UFO')
    args = parser.parse_args()

    find_differences(args)


def find_differences(args):
    """Report two list of glyphs,
    one list of glyphs in v5 that are not in v6,
    another list of glyphs in v6 that are not in v5.
    """

    # read old (v5) list of glyphs
    old_glyphs_list = set()
    with open(args.old, 'r') as old:
        for line in old:
            glyph_name = line.strip()
            old_glyphs_list.add(glyph_name)

    # read new (v6) list of glyphs
    new_glyphs_list = set()
    ufo = OpenFont(args.new)
    for glyph in ufo:
        new_glyphs_list.add(glyph.name)

    print('glyphs only in the old (v5) fonts')
    for glyph_name in sorted(old_glyphs_list - new_glyphs_list):
        print(glyph_name)

    print('glyphs only in the new (v6) fonts')
    for glyph_name in sorted(new_glyphs_list - old_glyphs_list):
        print(glyph_name)


if __name__ == '__main__':
    main()
