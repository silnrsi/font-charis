#!/usr/bin/python2
'Make fea classes and lookups for Roman fonts'

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

glyph_class_additions = {'cno_c2sc' : ['LtnYr', 'CyPalochka'],
                         'c_c2sc' : ['LtnSmCapR.sc', 'CyPalochka.sc'],
                         'cno_lit' : ['LtnSmGBarredBowl', 'LtnSmGStrk'],
                         'c_lit' : ['LtnSmGBarredSngBowl','LtnSmGBarredSngBowl'],
                         }

non_variant_suffixes = ('Dotless', 'VN', 'Sup', 'sc')

argspec = [
    ('infile', {'help': 'Input UFO'}, {}),
    ('-of', '--output_fea', {'help': 'Output fea file'}, {}),
    ('-ox', '--output_xml', {'help': 'Output xml file'}, {}),
    ('--debug', {'help': 'Drop into pdb', 'action': 'store_true'}, {}),
    ('-l', '--log', {'help': 'Log file (default: *_makeromanclasses.log)'},
        {'type': 'outfile', 'def': '_makeromanclasses.log'}),
]

classes_xml_hd = """<?xml version="1.0"?>
<classes>
"""

classes_xml_ft = """</classes>
"""

logger = None

class Font(object):
    def __init__(self):
        self.file_nm = ''
        self.glyphs = OrderedDict()
        self.unicodes = OrderedDict()
        self.g_classes = OrderedDict()
        self.g_variants = OrderedDict()

    def read_font(self, ufo_nm):
        self.file_nm = ufo_nm
        ufo_f = ufo.Ufont(ufo_nm)
        for g_name in ufo_f.deflayer:
            glyph = Glyph(g_name)
            self.glyphs[g_name] = glyph
            ufo_g = ufo_f.deflayer[g_name]
            unicode_lst = ufo_g['unicode']
            if unicode_lst:
                # store primary encoding, allow for double encoding
                self.unicodes.setdefault(unicode_lst[0].hex, []).append(glyph)
            if 'anchor' in ufo_g:
                for anchor in ufo_g['anchor']:
                    a_attr = anchor.element.attrib
                    glyph.add_anchor(a_attr['name'], int(float(a_attr['x'])), int(float(a_attr['y'])))

    def make_classes(self, class_spec_lst):
        # create multisuffix classes
		#  each class contains glyphs that have a suffix specified in a list for that class
		#  some contained glyphs will have multiple suffixes
        for class_spec in class_spec_lst:
            class_nm = class_spec[0]
            c_nm, cno_nm = "c_" + class_nm, "cno_" + class_nm
            c_lst, cno_lst = [], []
            for suffix in class_spec[1:]:
                for g_nm in self.glyphs:
                    if re.search("\." + suffix, g_nm):
                        gno_nm = re.sub("\." + suffix, "", g_nm)
                        if gno_nm in self.glyphs:
                            c_lst.append(g_nm)
                            cno_lst.append(gno_nm)
            if c_lst:
                self.g_classes.setdefault(c_nm, []).extend(c_lst)
                self.g_classes.setdefault(cno_nm, []).extend(cno_lst)

        # create classes for c2sc (sc2_sub)
        # remove block of code below that uses isupper() and lower()
        #  since it does not find all the relevant glyphs
        if False:
            for uni_str in self.unicodes:
                try:
                    upper_unichr = unichr(int(uni_str, 16))
                except(ValueError):
                    continue #skip USVs larger than narrow Python build can handle
                if upper_unichr.isupper() and upper_unichr.lower(): # TODO: Is this complete?
                    lower_unichr = upper_unichr.lower()
                    lower_str = hex(ord(lower_unichr))[2:].zfill(4)
                    if lower_str in self.unicodes:
                        lower_glyph_lst = self.unicodes[lower_str]
                        assert(len(lower_glyph_lst) == 1) # no double encoded glyphs allowed
                        lower_sc_name = lower_glyph_lst[0].name + '.sc'
                        if lower_sc_name in self.glyphs:
                            upper_glyph_lst = self.unicodes[uni_str]
                            assert (len(upper_glyph_lst) == 1)
                            upper_name = upper_glyph_lst[0].name
                            self.g_classes.setdefault('cno_c2sc_1', []).append(upper_name)
                            self.g_classes.setdefault('c_c2sc_str_1', []).append(lower_sc_name)

        # create classes for c2sc (sc2_sub)
        # this might miss some glyphs not named using the below convention
        # like LtnYr & LtnSmCapR.sc and CyPalochka & CyPalochka.sc
        #  which should be added using glyph_class_additions
        for g_nm in self.glyphs:
            if (re.search('LtnCap|CyCap', g_nm)):
                g_smcp_nm = re.sub('Cap', 'Sm', g_nm) + ".sc"
                if (g_smcp_nm in self.glyphs):
                    self.g_classes.setdefault('cno_c2sc', []).append((g_nm))
                    self.g_classes.setdefault('c_c2sc', []).append((g_smcp_nm))

        # create class of glyphs that need .sup diacritics
        #   match substrings in glyph names
        #   is there a Unicode prop that would specify these?
        # TODO: does this include too many glyhs? compare to hard-coded list in makeot.pl
        for g_nm in self.glyphs:
            if (re.search('\wSubSm\w',g_nm) or re.search('\wSupSm\w',g_nm)
                    or re.search('^ModCap\w', g_nm) or re.search('^ModSm\w', g_nm)):
                self.g_classes.setdefault('c_superscripts', []).append(g_nm)

        # add irregular glyphs to classes not found by the above algorithms
        for cls, g_lst in glyph_class_additions.items():
            # for g in g_lst: assert(not g in self.g_classes[cls])
            if not cls in self.g_classes:
                logger.log("class %s from class additions missing" % cls, 'W')
                self.g_classes.setdefault(cls, []).append(cls)
            for g in g_lst:
                if g in self.g_classes[cls]:
                    logger.log("glyph %s from class additions already present" % g, 'W')
                self.g_classes[cls].append(g)

    def find_variants(self):
        # create single and multiple alternate lkups for aalt (sa_sub, ma_sub)
		#  creates a mapping from a glyph to all glyphs with an additional suffix
        # only called if fea is being generated
        for g_nm in self.glyphs:
            suffix_lst = re.findall('(\..*?)(?=\.|$)', g_nm)
            for suffix in suffix_lst:
                if suffix in ('.notdef', '.null'):
                    continue
                if re.match('\.(1|2|3|4|5|rstaff|rstaffno|lstaff|lstaffno)$',suffix):
                    # exclude tone-related glyphs
                    continue
                variation = suffix[1:]
                if variation in non_variant_suffixes:
                    continue
                base = re.sub(suffix, '', g_nm)
                if base in self.glyphs:
                    self.g_variants.setdefault(base, []).append(g_nm)

    def find_NFC_to_NFD(self):
        # create lkup for NFD to NFC glyph substitution for glyphs w NFD spellings (c_sub)
        #   substitution is more efficient than positioning according to MH
        #   but a comment in makeot.pl says that gain may be offset by the larger GSUB table
        # 2018-09-19: Roman font team decided to no longer do this substituion
        #   sub is likely faster but size is more important (downloading web fonts)
        pass

    def write_fea(self, file_nm):
        with open(file_nm, "w") as o_f:
            for c in self.g_classes:
                glyph_str = " ".join(self.g_classes[c])
                o_f.write("@%s = [%s];\n" % (c, glyph_str))

            single_alt_str_lst, multi_alt_str_lst = [], []
            for base in self.g_variants:
                variants = self.g_variants[base]
                variants_str = ' '.join(variants)
                alt_str_lst = single_alt_str_lst if len(variants) == 1 else multi_alt_str_lst
                alt_str_lst.append('sub %s from [%s];' % (base, variants_str))

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

    def write_classes(self, file_nm):
        with open(file_nm, "w") as o_f:
            o_f.write(classes_xml_hd)
            for c, g in self.g_classes.items():
                o_f.write('\t<class name="{}">\n'.format(c))
                glyph_str_lst = [g[i:i + 4] for i in range(0, len(g), 4)]
                for l in glyph_str_lst:
                    o_f.write("\t\t{}\n".format(" ".join(l)))
                o_f.write('\t</class>\n')
            o_f.write(classes_xml_ft)

class Glyph(object):
    def __init__(self, name):
        self.name = name
        self.anchors = {}

    def add_anchor(self, name, x, y):
        self.anchors[name] = (x, y)

def doit(args) :
    global logger
    logger = args.logger
    if args.infile and args.infile.endswith('.ufo'):
        font = Font()
        font.read_font(args.infile)
        font.make_classes(class_spec_lst)
        #font.find_NFC_to_NFD()
        if args.output_fea:
            font.find_variants()
            font.write_fea(args.output_fea)
        if args.output_xml:
            font.write_classes(args.output_xml)
        if not args.output_fea and not args.output_xml:
            # TODO: handle output if output not specified
            pass
    else:
       args.logger.log('Only UFOs accepted as input', 'S')

def cmd(): execute(None, doit, argspec)
if __name__ == '__main__': cmd()