#!/usr/bin/python3
'Make fea classes and lookups for Roman fonts'

# __url__ = 'https://github.com/silnrsi/pysilfont'
__copyright__ = 'Copyright (c) 2018-2024 SIL Global  (https://www.sil.org)'
__license__ = 'Released under the MIT License (https://opensource.org/licenses/MIT)'
__author__ = 'Alan Ward'

from collections import OrderedDict
import re
import silfont.ufo as ufo
from silfont.core import execute

class_spec_lst = [('smcp', 'sc'),
                  ('lit', 'SngStory', 'SngBowl'),
                  ('lita', 'SngStory'),
                  ('litg', 'SngBowl'),
                  ('sital', 'SItal', '2StorySItal'),
                  # psfmakefea BarBowl classes wrongly map LtnSmG to LtnSmG.BarBowl
                  ('barbowl', 'BarBowl'),
                  ('viet', 'VN'),
                  ('dotlss', 'Dotless'),
                  ('rtrhk', 'RetroHook'),
                  ('caron', 'Caron'),
                  ('iotasub', 'ISub'),
                  ('lowprof', 'LP', 'VNLP'),
                  ('bartp', 'BarTop'),
                  ('nobar', 'NB')
                  ]

super_sub_mod_regex = r"\wSubSm\w|\wSupSm\w|^ModCap\w|^ModSm\w|^ModCy\w"

glyph_class_additions = {# 'cno_c2sc' : ['LtnYr', 'CyPalochka'],
                         # 'c_c2sc' : ['LtnSmCapR.sc', 'CyPalochka.sc'],
                         # 'cno_lit' : ['LtnSmGBarredBowl', 'LtnSmGStrk'],
                         # 'c_lit' : ['LtnSmGBarredSngBowl','LtnSmGBarredSngBowl'],
                         # 'cno_litg' : ['LtnSmGBarredBowl', 'LtnSmGStrk'],
                         # 'c_litg' : ['LtnSmGBarredSngBowl','LtnSmGBarredSngBowl'],
                         'c_superscripts' : ['ModGlottalStop', 'ModRevGlottalStop'],
                         }

glyph_class_deletions = {'c_barbowl' : ['LtnSmG.BarBowl', 'LtnSmG.BarBowl.sc', 
                            'LtnSmG.BarBowl.SngBowl', 'LtnSmG.BarBowl.SngBowl.sc'],
                         'cno_barbowl' : ['LtnSmG', 'LtnSmG.sc', 
                            'LtnSmG.SngBowl', 'LtnSmG.SngBowl.sc'],
                         'c_dotlss' : ['LtnSmIOgonek.Dotless'],
                         'cno_dotlss' : ['LtnSmIOgonek'],
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
        self.u_levels = {}
        self.l_levels = {}

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
                usv_str = unicode_lst[0].hex
                self.unicodes.setdefault(usv_str, []).append(glyph)
            if 'anchor' in ufo_g:
                for anchor in ufo_g['anchor']:
                    a_attr = anchor.element.attrib
                    a_nm, a_x, a_y = a_attr['name'], int(float(a_attr['x'])), int(float(a_attr['y']))
                    glyph.add_anchor(a_nm, a_x, a_y)
                    if a_nm == "U":
                        self.u_levels.setdefault(a_y, []).append(glyph)
                    if a_nm == "L":
                        self.l_levels.setdefault(a_y, []).append(glyph)

        lib_plist = ufo_f.lib.getval("org.sil.lcg.bridgeLevels")
        self.level_ranges = {}
        for k in ('high', 'mid', 'low'):
            self.level_ranges[k] = (lib_plist[k]['UAnchorMin'], lib_plist[k]['UAnchorMax'])
        for k in ('belowhigh', 'belowlow'):
            self.level_ranges[k] = (lib_plist[k]['LAnchorMin'], lib_plist[k]['LAnchorMax'])

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
                    if re.search(r"\." + suffix, g_nm):
                        gno_nm = re.sub(r"\." + suffix, "", g_nm)
                        if gno_nm in self.glyphs:
                            c_lst.append(g_nm)
                            cno_lst.append(gno_nm)
            if c_lst:
                self.g_classes.setdefault(c_nm, []).extend(c_lst)
                self.g_classes.setdefault(cno_nm, []).extend(cno_lst)

        # create classes for c2sc
        for uni_str in self.unicodes:
            upper_unichr = chr(int(uni_str, 16))
            if upper_unichr.isupper() and upper_unichr.lower(): # TODO: Is this complete?
                lower_unichr = upper_unichr.lower()
                if len(lower_unichr) > 1: continue
                # lower_str = hex(ord(lower_unichr))[2:].zfill(4)
                lower_str = "{0:04X}".format(ord(lower_unichr))
                if lower_str in self.unicodes:
                    lower_glyph_lst = self.unicodes[lower_str]
                    assert(len(lower_glyph_lst) == 1) # no double encoded glyphs allowed
                    lower_sc_name = lower_glyph_lst[0].name + '.sc'
                    if lower_sc_name in self.glyphs:
                        upper_glyph_lst = self.unicodes[uni_str]
                        assert (len(upper_glyph_lst) == 1)
                        upper_name = upper_glyph_lst[0].name
                        self.g_classes.setdefault('cno_c2sc', []).append(upper_name)
                        self.g_classes.setdefault('c_c2sc', []).append(lower_sc_name)

        # create classes for c2sc
        # this might miss some glyphs not named using the below convention
        # like LtnYr & LtnSmCapR.sc and CyPalochka & CyPalochka.sc
        #  which should be added using glyph_class_additions
        if False:
            for g_nm in self.glyphs:
                if (re.search('LtnCap|CyCap', g_nm)):
                    g_smcp_nm = re.sub('Cap', 'Sm', g_nm) + ".sc"
                    if (g_smcp_nm in self.glyphs):
                        self.g_classes.setdefault('cno_c2sc', []).append(g_nm)
                        self.g_classes.setdefault('c_c2sc', []).append(g_smcp_nm)

        # create class of glyphs that need .sup diacritics
        #   match substrings in glyph names
        #   is there a Unicode prop that would specify these?
        # TODO: does this include too many glyhs? compare to hard-coded list in makeot.pl
        for g_nm in self.glyphs:
            # if (re.search('\wSubSm\w',g_nm) or re.search('\wSupSm\w',g_nm)
            #         or re.search('^ModCap\w', g_nm) or re.search('^ModSm\w', g_nm)):
            if re.search(super_sub_mod_regex, g_nm):
                if not re.search('Dep$', g_nm): # discard glyphs for deprecated chars
                    self.g_classes.setdefault('c_superscripts', []).append(g_nm)

        # create classes of glyphs to support Kayan diacritics (grave+acute -> grave_acute)
        #  need to decompose glyphs that contain to a grave
        for g_nm in self.glyphs:
            if (re.search('Ltn(Cap|Sm).Grave', g_nm)):
                g_base_nm = re.sub('(.*)Grave(.*)', r'\g<1>\g<2>', g_nm)
                # TODO: generalize the below
                if g_base_nm.find('LtnSmI') != -1 and g_base_nm.find('.sc') == -1 :
                    g_base_nm = re.sub('LtnSmI', 'LtnSmI.Dotless', g_base_nm)
                if (g_base_nm in self.glyphs):
                    self.g_classes.setdefault('c_grave_comp', []).append(g_nm)
                    self.g_classes.setdefault('c_grave_base', []).append(g_base_nm)

        # create classes of glyphs containing combining diacs w low profile variants
        for g_nm in self.glyphs:
            if (re.search(r'Comb.*\.(LP|VNLP)', g_nm)):
                g_no_nm = g_nm[:-3] if g_nm.find('VNLP') == -1 else g_nm[:-2]
                self.g_classes.setdefault('c_lprof_diac', []).append(g_nm)
                self.g_classes.setdefault('cno_lprof_diac', []).append(g_no_nm)

        # create class used to test for glyphs that need low profile diacritics by default
        # Latin, Roman numerals, or Cyrillic upper case with U AP;
        # variants can be ignored because LP diacs handled early in processing
        for uni_str in self.unicodes:
            unichr = chr(int(uni_str, 16))
            if unichr.isupper():
                glyph_lst = self.unicodes[uni_str]
                assert(len(glyph_lst) == 1)
                g_nm = glyph_lst[0].name
                if g_nm.startswith('Ltn') or g_nm.startswith('Rom') or g_nm.startswith('Cy'):
                    for a in glyph_lst[0].anchors:
                        if a == 'U':
                            self.g_classes.setdefault('c_takes_lp_diac', []).append(g_nm)

        # create classes of glyphs for supporting bridging diacrtics
        # TODO: explain criteria for class membership
        for level in self.u_levels:
            if not level >= self.level_ranges['low'][0]: continue
            for glyph in self.u_levels[level]:
                if 'L' in glyph.anchors and glyph.anchors['L'][1] <= self.level_ranges['belowhigh'][0]:
                    if level >= self.level_ranges['low'][0] and level <= self.level_ranges['low'][1]:
                        self.g_classes.setdefault('c_takes_low_diac',[]).append(glyph.name)
                    if level >= self.level_ranges['mid'][0] and level <= self.level_ranges['mid'][1]:
                        self.g_classes.setdefault('c_takes_mid_diac',[]).append(glyph.name)
                    if level >= self.level_ranges['high'][0] and level <= self.level_ranges['high'][1]:
                        # self.g_classes.setdefault('c_takes_udflt_diac',[]).append(glyph.name)
                        self.g_classes.setdefault('c_takes_high_diac',[]).append(glyph.name)
        for level in self.l_levels:
            if not level <= self.level_ranges['belowhigh'][1]: continue
            for glyph in self.l_levels[level]:
                if 'U' in glyph.anchors and glyph.anchors['U'][1] >= self.level_ranges['low'][0]:
                    if level >= self.level_ranges['belowhigh'][0] and level <= self.level_ranges['belowhigh'][1]:
                        self.g_classes.setdefault('c_takes_belowhigh_diac',[]).append(glyph.name)
                    if level >= self.level_ranges['belowlow'][0] and level <= self.level_ranges['belowlow'][1]:
                        # self.g_classes.setdefault('c_takes_ldflt_diac',[]).append(glyph.name)
                        self.g_classes.setdefault('c_takes_belowlow_diac',[]).append(glyph.name)

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

        # delete irregular glyphs from classes added by the above algorithms
        for cls, g_lst in glyph_class_deletions.items():
            if not cls in self.g_classes:
                logger.log("class %s from class deletions missing" % cls, 'W')
            for g in g_lst:
                if g in self.g_classes[cls]:
                    l = self.g_classes[cls]
                    del l[l.index(g)]
                else:
                    logger.log("glyph %s from class deletions not present" % g, 'W')

    def find_variants(self):
        # create single and multiple alternate lkups for aalt (sa_sub, ma_sub)
        #  creates a mapping from a glyph to all glyphs with an additional suffix
        # only called if fea is being generated
        for g_nm in self.glyphs:
            suffix_lst = re.findall(r'(\..*?)(?=\.|$)', g_nm)
            for suffix in suffix_lst:
                if suffix in ('.notdef', '.null'):
                    continue
                if re.match(r'\.(1|2|3|4|5|rstaff|rstaffno|lstaff|lstaffno)$',suffix):
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

    def write_classes(self, file_nm, ix=None):
        with open(file_nm, "w") as o_f:
            o_f.write(classes_xml_hd)
            for c, g in self.g_classes.items():
                if ix is not None:
                    o_f.write('\t<class name="{}" fixed="{}">\n'.format(c, ix))
                else:
                    o_f.write('\t<class name="{}">\n'.format(c))
                glyph_str_lst = [g[i:i + 4] for i in range(0, len(g), 4)]
                for l in glyph_str_lst:
                    o_f.write("\t\t{}\n".format(" ".join(l)))
                o_f.write('\t</class>\n')
            o_f.write(classes_xml_ft)

    def write_fixed_classes(self, file_nm):
        with open(file_nm, "w") as o_f:
            o_f.write(classes_xml_hd)
            for c, g_lst in self.g_classes.items():
                ix = 0
                for g in g_lst:
                    o_f.write('\t<class name="{}[{}]">{}</class>\n'.format(c, ix, g))
                    ix += 1
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
            font.write_classes(args.output_xml, 0)
            # font.write_fixed_classes(args.output_xml)
        if not args.output_fea and not args.output_xml:
            # TODO: handle output if output not specified
            pass
    else:
       args.logger.log('Only UFOs accepted as input', 'S')

def cmd(): execute(None, doit, argspec)
if __name__ == '__main__': cmd()
