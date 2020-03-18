#!/usr/bin/python3

from xml.etree import ElementTree as ET
import argparse


def main():
    parser = argparse.ArgumentParser(description='Compare two anchor XML files')
    parser.add_argument('--version', action='version', version='%(prog)s ')
    parser.add_argument('old', help='old XML anchor file')
    parser.add_argument('new', help='new XML anchor file')
    args = parser.parse_args()

    compare_anchors(args.old, args.new)


def compare_anchors(old_anchor_filename, new_anchor_filename):
    """Compare anchors in two XML files."""
    old_anchor_info = read_anchors(old_anchor_filename)
    new_anchor_info = read_anchors(new_anchor_filename)

    # use sets to compare anchor inventory
    old_glyph_anchors = set(old_anchor_info)
    new_glyph_anchors = set(new_anchor_info)

    print('anchors that are in a different position')
    common_glyph_anchors = old_glyph_anchors & new_glyph_anchors
    for glyph_anchor_name in sorted(common_glyph_anchors):
        old_glyph_anchor = old_anchor_info[glyph_anchor_name]
        new_glyph_anchor = new_anchor_info[glyph_anchor_name]
        if old_glyph_anchor != new_glyph_anchor:
            glyph_name = new_glyph_anchor[0]
            anchor_name = new_glyph_anchor[1]
            old_x = old_glyph_anchor[2]
            old_y = old_glyph_anchor[3]
            new_x = new_glyph_anchor[2]
            new_y = new_glyph_anchor[3]
            print(f'{glyph_name} {anchor_name} {old_x},{old_y} -> {new_x},{new_y}')

    print('glyphs/anchors only in the new anchor XML files')
    for glyph_anchor_name in sorted(new_glyph_anchors - old_glyph_anchors):
        print(glyph_anchor_name)

    print('glyphs/anchors only in the old anchor XML files')
    for glyph_anchor_name in sorted(old_glyph_anchors - new_glyph_anchors):
        print(glyph_anchor_name)


def read_anchors(anchorinfo):
    """Read anchor information from an XML file."""
    anchors = dict()
    try:
        for g in ET.parse(anchorinfo).getroot().findall('glyph'):
            glyph_name = g.get('PSName')
            for p in g.findall('point'):
                anchor_name = p.get('type')
                # assume subelement location is first child
                x = p[0].get('x')
                y = p[0].get('y')
                if anchor_name and x and y:
                    anchors[f'{glyph_name}-{anchor_name}'] = (glyph_name, anchor_name, x, y)
                else:
                    print(f'Incomplete information for anchor {anchor_name} in glyph {glyph_name}')
        return anchors
    except ET.ParseError:
        return dict()


if __name__ == '__main__':
    main()
