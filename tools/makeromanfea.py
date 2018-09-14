#!/usr/bin/python3
'Make fea classes and lookups for Roman fonts'
# TODO:
# __url__ = 'http://github.com/silnrsi/pysilfont'
__copyright__ = 'Copyright (c) 2018 SIL International  (http://www.sil.org)'
__license__ = 'Released under the MIT License (http://opensource.org/licenses/MIT)'
__author__ = 'Alan Ward'

from collections import OrderedDict
import re
import silfont.ufo as ufo
from silfont.core import execute

class_spec_lst = [('lit', 'SngStory', 'SngBowl'),
                  ('sital', 'SItal', '2StorySItal'),
                  ('viet', 'VN'),
                  ('dotlss', 'Dotless'),
                  ('rtrhk', 'RetroHook'),
                  ]

non_variant_suffixes = ('Dotless', 'VN', 'Sup', 'sc')

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
        self.glyphs = OrderedDict()
        self.classes = OrderedDict()
        self.variants = OrderedDict()

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
        # TODO: create class containing glyphs that need .sup diacs (c_superscripts)
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

    def find_variants(self):
        # TODO: create lkup for c2sc (sc2_sub)
        # TODO (maybe): create lkup for NFD to NFC glyph substitution for glyphs w NFD spellings (c_sub)

        # create single and multiple alternate lkups for aalt (sa_sub, ma_sub)
        for g_nm in self.glyphs:
            suffix_lst = re.findall('(\..*?)(?=\.|$)', g_nm)
            for suffix in suffix_lst:
                if suffix in ('.notdef', '.null'):
                    continue
                if re.match('\.(1|2|3|4|5|rstaff|rstaffno|lstaff|lstaffno)',suffix):
                    continue
                variation = suffix[1:]
                if variation in non_variant_suffixes:
                    continue
                base = re.sub(suffix, '', g_nm)
                if not base in self.glyphs:
                    continue
                self.variants.setdefault(base, []).append(g_nm)

    def write_fea(self, file_nm):
        with open(file_nm, "w") as o_f:
            for c in self.classes:
                glyph_str = " ".join(self.classes[c])
                o_f.write("@%s = [%s];\n" % (c, glyph_str))
            single_alt_str_lst, multi_alt_str_lst = [], []
            for base in self.variants:
                variants_str = ''
                for variant in self.variants[base]:
                    variants_str += '\\%s ' % variant
                variants_str = variants_str[:-1]
                if len(self.variants[base]) == 1:
                    single_alt_str_lst.append('sub \\%s from [%s];' % (base, variants_str))
                else:
                    multi_alt_str_lst.append('sub \\%s from [%s];' % (base, variants_str))

            o_f.write("lookup ma_sub {\n")
            o_f.write("  lookupflag 0;\n")
            for s in multi_alt_str_lst:
                o_f.write("    %s\n" % s)
            o_f.write("} ma_sub;\n")

            o_f.write("lookup sa_sub {\n")
            o_f.write("  lookupflag 0;\n")
            for s in single_alt_str_lst:
                o_f.write("    %s\n" % s)
            o_f.write("} sa_sub;\n")


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
        font.find_variants()
        if args.output:
            font.write_fea(args.output)
        else:
            # TODO: handle output if --output not specified
            pass
    else:
       args.logger.log('Only UFOs accepted as input', 'S')


def cmd(): execute(None, doit, argspec)
if __name__ == '__main__': cmd()
