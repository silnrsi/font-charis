#!/usr/bin/python3
'Make fea classes and lookups for Roman fonts'
# TODO:
# __url__ = 'http://github.com/silnrsi/pysilfont'
__copyright__ = 'Copyright (c) 2018 SIL International  (http://www.sil.org)'
__license__ = 'Released under the MIT License (http://opensource.org/licenses/MIT)'
__author__ = 'Alan Ward'

import re
import silfont.ufo as ufo
from silfont.core import execute

class_spec_lst = [('lit', 'SngStory', 'SngBowl'),
                  ('sital', 'SItal', '2StorySItal'),
                  ('viet', 'VN'),
                  ('dotlss', 'Dotless'),
                  ('rtrhk', 'RetroHook'),
                  ]

argspec = [
    ('infile', {'help': 'Input UFO'}, {}),
    ('-o', '--output', {'help': 'Output fea file'}, {}),
    ('--debug', {'help': 'Drop into pdb', 'action': 'store_true'}, {}),
    ('-l', '--log', {'help': 'Log file (default: *_makeromanfea.log)'},
        {'type': 'outfile', 'def': '_makeromanfea.log'}),
]

class Font(object):
    def __init__(self):
        self.file_nm = ''
        self.glyphs = {}
        self.classes = {}
        self.lookups = {}

    def read_font(self, ufo_nm):
        self.file_nm = ufo_nm
        ufo_f = ufo.Ufont(ufo_nm)
        for g_name in ufo_f.deflayer:
            ufo_g = ufo_f.deflayer[g_name]
            glyph = Glyph(g_name)
            self.glyphs[g_name] = glyph
            if 'anchor' in ufo_g._contents:
                for anchor in ufo_g._contents['anchor']:
                    a_attr = anchor.element.attrib
                    glyph.add_anchor(a_attr['name'], int(float(a_attr['x'])), int(float(a_attr['y'])))

    def make_classes(self, class_spec_lst):
        for class_spec in class_spec_lst:
            class_nm = class_spec[0]
            c_nm, cno_nm = "c_" + class_nm, "cno_" + class_nm
            c_lst, cno_lst = [], []
            for suffix in class_spec[1:]:
                for g in self.glyphs:
                    if re.search("\." + suffix, g):
                        g_no = re.sub("\." + suffix, "", g)
                        if g_no in self.glyphs:
                            c_lst.append(g)
                            cno_lst.append(g_no)
            if c_lst:
                self.classes.setdefault(c_nm, []).extend(c_lst)
                self.classes.setdefault(cno_nm, []).extend(cno_lst)

    def make_lookups(self):
        pass

    def write_fea(self, file_nm):
        with open(file_nm, "w") as o_f:
            for c in self.classes.keys():
                glyph_str = " ".join(self.classes[c])
                o_f.write("%s = [%s];\n" % (c, glyph_str))

class Glyph(object):
    def __init__(self, name):
        self.name = name
        self.anchors = {}

    def add_anchor(self, name, x, y):
        self.anchors[name] = (x, y)

def doit(args) :
    if args.infile and args.infile.endswith('.ufo'):
        font = Font()
        font.read_font(args.infile)
        font.make_classes(class_spec_lst)
        font.make_lookups()
        if args.output:
            font.write_fea(args.output)
    else:
           args.logger.log('Only UFOs accepted as input', 'S')


def cmd(): execute(None, doit, argspec)
if __name__ == '__main__': cmd()
