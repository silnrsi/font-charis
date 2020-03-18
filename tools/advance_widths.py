#!/usr/bin/python3

from fontTools.ttLib import TTFont
import argparse


def main():
    parser = argparse.ArgumentParser(description='Find differences in advance widths between two TTFs')
    parser.add_argument('--version', action='version', version='%(prog)s ')
    parser.add_argument('old', help='old TTF')
    parser.add_argument('new', help='new TTF')
    args = parser.parse_args()

    find_differences(args.old, args.new)


def find_differences(old_font_filename, new_font_filename):
    """Report differences between two TTFs
    if the advance width of a glyph is different.
    """

    old_advances = dict()
    old = TTFont(old_font_filename)
    for glyph_name in old.getGlyphOrder():
        advance, lsb = old['hmtx'].metrics[glyph_name]
        old_advances[glyph_name] = advance

    new = TTFont(new_font_filename)
    for glyph_name in new.getGlyphOrder():
        advance, lsb = new['hmtx'].metrics[glyph_name]
        if glyph_name in old_advances:
            if old_advances[glyph_name] != advance:
                print(f'{glyph_name} {old_advances[glyph_name]} -> {advance}')


if __name__ == '__main__':
    main()
