#!/usr/bin/python3
'generate ftml tests from glyph_data.csv and UFO'
__url__ = 'http://github.com/silnrsi/pysilfont'
__copyright__ = 'Copyright (c) 2019 SIL International  (http://www.sil.org)'
__license__ = 'Released under the MIT License (http://opensource.org/licenses/MIT)'
__author__ = 'Alan Ward'

from silfont.core import execute
import silfont.ftml_builder as FB
from palaso.unicode.ucd import get_ucd
import re
from itertools import combinations, chain, product

argspec = [
    ('ifont',{'help': 'Input UFO'}, {'type': 'infont'}),
    ('output',{'help': 'Output file ftml in XML format', 'nargs': '?'}, {'type': 'outfile', 'def': '_out.ftml'}),
    ('-i','--input',{'help': 'Glyph info csv file'}, {'type': 'incsv', 'def': 'glyph_data.csv'}),
    ('-f','--fontcode',{'help': 'letter to filter for glyph_data'},{}),
    ('-l','--log',{'help': 'Set log file name'}, {'type': 'outfile', 'def': '_ftml.log'}),
    ('-t','--test', {'help': 'which test to build', 'default': None, 'action': 'store'}, {}),
    ('-s','--fontsrc', {'help': 'default font source optionally followed by "=label"', 'action': 'append'}, {}),
    ('--scale', {'help': '% to scale rendered text'}, {}),
    ('--ap', {'help': 'regular expression describing APs to examine', 'default': '.', 'action': 'store'}, {}),
    ('--xsl', {'help': 'XSL stylesheet to use'}, {}),
]

class FTMLBuilder_LCG(FB.FTMLBuilder):
    def readGlyphData(self, incsv, fontcode = None, font = None):
        # super(FTMLBuilder_Ltn, self).readGlyphData(incsv, fontcode, font)
        #### the below code was copied from ftml_buider.FTMLBuilder.readGlyphData() and modified ####

        if font == None:
            self.logger.log('font is required', 'S')

        # iterate over UFO to create FChar objs for encoded glyphs
        for gname in font.deflayer:
            try:
                uid = int(font.deflayer[gname]['unicode'][0].hex, 16)
                if uid in self.uids():
                    self.logger.log('USV %04X previously seen (repeated on glyph %s)' % (uid, gname), 'W')
                else:
                    # Create character object for this USV
                    # TODO: test uid validity
                    self.addChar(uid, gname)
            except: # exception will be thrown if glyph has no Unicode value
                continue

        # Remember csv file for other methods:
        self.incsv = incsv

        # Validate fontcode, if provided
        if fontcode is not None:
            whichfont = fontcode.strip().lower()
            if len(whichfont) != 1:
                self.logger.log('fontcode must be a single letter', 'S')
        else:
            whichfont = None

        # handle differences in csv data for Charis, Doulos, Gentium, and Andika
        if whichfont in ('c', 'd', 'g'):
            usvField = 'assoc_uids_cdg'
            featField = 'assoc_feat_cdg'
        elif whichfont in ('a'):
            usvField = 'assoc_uids_a'
            featField = 'assoc_feat_a'
        else: # includes None
            self.logger.log('fontcode must be: C, D, G, or A', 'S')

        # Get headings from csvfile:
        #   cols: glyph_name,ps_name,sort_final_cdg,sort_final_a,
        #     assoc_feat_cdg,assoc_feat_a,assoc_feat_val,assoc_uids_cdg,assoc_uids_a
        fl = incsv.firstline # fl is a list
        if fl is None: self.logger.log("Empty imput file", "S")
        # required columns:
        try:
            nameCol = fl.index('glyph_name');
        except ValueError as e:
            self.logger.log('Missing csv input field: ' + e.message, 'S')
        except Exception as e:
            self.logger.log('Error reading csv input field: ' + e.message, 'S')

        # optional columns:

        # Allow for projects that use only production glyph names (ps_name same as glyph_name)
        psCol = fl.index('ps_name') if 'ps_name' in fl else nameCol
        # Allow for projects that have no feature and/or lang-specific behaviors
        featCol = fl.index(featField) if featField in fl else None
        valCol = fl.index('assoc_feat_val') if 'assoc_feat_val' in fl else None
        usvCol = fl.index(usvField) if usvField in fl else None
        bcp47Col = fl.index('bcp47tags') if 'bcp47tags' in fl else None

        next(incsv.reader, None)  # Skip first line with headers in

        # regex that matches names of glyphs we don't care about
        # TODO: is 'glyph_name' needed in the regex?
        namesToSkipRE = re.compile('^(?:[._].*|null|cr|nonmarkingreturn|tab|glyph_name)$',re.IGNORECASE)

        # keep track of glyph names we've seen to detect duplicates
        namesSeen = set()
        psnamesSeen = set()

        # OK, process all records in glyph_data
        # FChars have been added for encoded glyphs in the font UFO
        for line in incsv:
            gname = line[nameCol].strip()
            if gname not in font.deflayer:
                # skip glyphs in glyph_data but not in UFO
                continue

            # things to ignore:
            if namesToSkipRE.match(gname):
                continue
            if len(gname) == 0:
                self._csvWarning('empty glyph name in glyph_data; ignored')
                continue
            if gname.startswith('#'):
                continue
            if gname in namesSeen:
                self._csvWarning('glyph name %s previously seen in glyph_data; ignored' % gname)
                continue
            namesSeen.add(gname)

            psname = line[psCol].strip() or gname   # If psname absent, working name will be production name
            if len(psname) == 0:
                self._csvWarning('empty ps_name in glyph_data')
            if psname in psnamesSeen:
                self._csvWarning('psname %s previously seen; ignored' % psname)
                continue
            psnamesSeen.add(psname)

            # Find USV and FChar obj for gname from font (ufo object)
            try:
                # encoded glyphs
                c = self.char(gname)
                uid = c.uid
            except:
                # unencoded glyphs
                c = uid = None
            # Examine APs to determine if this character takes marks
            if c: self.checkGlyph(c, gname, font, self.apRE)

            # Process associated USVs
            # could be empty string, a single USV or space-separated list of USVs
            try:
                uidList = [int(x, 16) for x in line[usvCol].split()]
            except Exception as e:
                self._csvWarning("invalid associated USV '%s' (%s); ignored: " % (line[usvCol], e.message))
                uidList = []

            assoc_uid = None
            if len(uidList) == 1:
                # Handle unencoded glyphs
                assoc_uid = uidList[0]
                try:
                    c = self.char(assoc_uid)
                except:
                    self._csvWarning('associated USV %04X for glyph %s matches no encoded glyph' % (assoc_uid, gname))
                    c = None
                # if c: self.checkGlyph(c, gname, font, self.apRE)
            elif len(uidList) > 1:
                # Handle ligatures - unlike encoded glyphs, these have not been loaded from the UFO
                lig_encoding_ok = True
                for uid in uidList:
                    if uid not in self.uids():
                        self._csvWarning('USV %04X for ligature glyph %s is not encoded in the font' % (uid, gname))
                        lig_encoding_ok = False
                        continue
                if lig_encoding_ok:
                    try:
                        c = self.special(uidList)
                    except:
                        c = self.addSpecial(uidList, gname)
                    self.checkGlyph(c, gname, font, self.apRE)
            else:
                pass # glyphs with no associated USV field should be encoded ones

            if featCol is not None:
                feat = line[featCol].strip()
                if feat:
                    feature = self.features.setdefault(feat, FB.Feature(feat)) #TODO: using FB.Feature is messy
                    if valCol:
                        # if values supplied, collect default and maximum values for this feature:
                        val = line[valCol].strip()
                        value = int(val) if val else 0
                        # Latin fonts never specify an associated uid or feature on encoded glyphs
                        # if uid: # encoded glyph
                        #     feature.default = value
                        feature.maxval = max(value, feature.maxval)
                    if c:
                        # Record that this feature affects this character:
                        c.feats.add(feat)
                    else:
                        self._csvWarning('untestable feature "%s" : no known USV' % feat)

            if bcp47Col is not None: # this field does not exist in LCG fonts
                bcp47 = line[bcp47Col].strip()
                if len(bcp47) > 0 and not(bcp47.startswith('#')):
                    if c is not None:
                        for tag in re.split(r'\s*[\s,]\s*', bcp47): # Allow comma- or space-separated tags
                            c.langs.add(tag)        # lang-tags mentioned for this character
                            if not self._langsComplete:
                                self.allLangs.add(tag)  # keep track of all possible lang-tags
                    else:
                        self._csvWarning('untestable langs: no known USV')

        # set default values for features where the default is non-zero
        if fontcode == 'A':
            self.features['ss01'].default = 1
        self.features['cv68'].default = 1

        # add features that are not present in glyph_data.csv
        # ss01 - lit; ss02 - lita; ss03 - litg
        self.features.setdefault('ss02', FB.Feature('ss02'))
        self.features.setdefault('ss03', FB.Feature('ss03'))
        for uid in self.uids():
            c = self.char(uid)
            if "ss01" in c.feats:
                if re.search("SmA", c.basename):
                    c.feats.add("ss02")
                elif re.search("SmG", c.basename):
                    c.feats.add("ss03")
                else:
                    self.logger.log('Glyph with "ss01" found without "SmA" or "SmG"', "W")

        # cv91 - tone numbers
        self.features.setdefault('cv91', FB.Feature('cv91'))
        for nm in ('TnLtr1', 'TnLtr2', 'TnLtr3', 'TnLtr4', 'TnLtr5'):
            c = self.char(nm)
            c.feats.add('cv91')

        # We're finally done, but if allLangs is a set, let's order it (for lack of anything better) and make a list:
        if not self._langsComplete:
            self.allLangs = list(sorted(self.allLangs))
            self.allLangs = list(sorted(self.allLangs))

    def render_lists(self, base_uid_lst, diac_uid_lst, ftml, feature_lst=None, keyUID=0, descUIDs=None):
        baselst_lst = [base_uid_lst[i:i+8] for i in range(0, len(base_uid_lst), 8)]
        for base_lst in baselst_lst:
            descUIDs_lst = base_lst if descUIDs is None else descUIDs
            ftml.closeTest()
            ftml.clearFeatures()
            for base in base_lst:
                self.render([base] + diac_uid_lst, ftml, keyUID=keyUID, descUIDs=descUIDs_lst)
            if feature_lst is None:
                ftml.closeTest()
                for base in base_lst:
                    self.render([base], ftml, keyUID=keyUID, descUIDs=descUIDs_lst)
            else:
                ftml.closeTest()
                ftml.setFeatures(feature_lst)
                for base in base_lst:
                    self.render([base] + diac_uid_lst, ftml, keyUID=keyUID, descUIDs=descUIDs_lst)

#    def render(self, uids, ftml, keyUID=0, descSimple=False):
    def render(self, uids, ftml, keyUID=0, descUIDs=None):
        """ general purpose (but not required) function to generate ftml for a character sequence """
        if len(uids) == 0:
            return
        # Make a copy so we don't affect caller
        uids = list(uids)
        # Remember first uid and original length for later
        startUID = uids[0]
        uidLen = len(uids)
        # if keyUID wasn't supplied, use startUID
        if keyUID == 0: keyUID = startUID
        # Construct label from uids:
        if not descUIDs:
            descUIDs = uids
        label = '\n'.join(['U+{0:04X}'.format(u) for u in descUIDs])
        # Construct comment from glyph names:
        comment = ' '.join([self._charFromUID[u].basename for u in descUIDs])
        if get_ucd(startUID, 'gc') == 'Mn':
            # First char is a NSM... prefix a suitable base
            uids.insert(0, self.diacBase)
        elif get_ucd(startUID, 'WSpace'):
            # First char is whitespace -- prefix with baseline brackets:
            uids.insert(0, 0xF130)
        lastNonMark = [x for x in uids if get_ucd(x, 'gc') != 'Mn'][-1]
        if get_ucd(lastNonMark, 'WSpace'):
            # Last non-mark is whitespace -- append baseline brackets:
            uids.append(0xF131)
        s = ''.join([chr(uid) for uid in uids])
        if uidLen > 1:
            ftml.addToTest(keyUID, s, label=label, comment=comment)
        else:
            ftml.addToTest(keyUID, s, comment=comment)

def doit(args):
    logger = args.logger

    builder = FTMLBuilder_LCG(logger, incsv = args.input, fontcode = args.fontcode, font = args.ifont, ap = args.ap)

    # Initialize FTML document:
    test = args.test or "AllChars"  # Default to "AllChars"

    # split labels from fontsource parameter
    fontsrc_lst, fontlabel_lst = [], []
    for sl in args.fontsrc:
        try:
            s, l = sl.split('=', 1)
            fontsrc_lst.append(s)
            fontlabel_lst.append(l)
        except ValueError:
            fontsrc_lst.append(sl)
            fontlabel_lst.append(None)

    ftml = FB.FTML(test, logger, rendercheck = False, fontscale = args.scale, xslfn = args.xsl,
                   fontsrc = fontsrc_lst, fontlabel = fontlabel_lst)

    # Char to use in allframed test to surround other chars for checking spacing
    frame_uid = 0x006F

    # Representative base and diac chars:
    #  cedilla (H), vertical line below (L), ogonek (O), comma abov right (R), vertical line above (U)
    repDiac = [x for x in [0x0327, 0x0329, 0x0328, 0x0315, 0x030D] if x in builder.uids()]
    ap_type_uid = {}
    for diac_uid in repDiac:
        c = builder.char(diac_uid)
        for ap in c.aps:
            if ap.startswith("_"):
                ap_type_uid[ap[1:]] = diac_uid

    if test.lower().startswith("allchars") or test.lower().startswith("allframed"):
        # all chars that should be in the font:
        framed = test.lower().startswith("allframed")
        uids = special_uids = None

        ftml.startTestGroup('Encoded characters')
        for uid in sorted(builder.uids()):
            if uid < 32: continue
            c = builder.char(uid)
            if not framed:
                builder.render((uid,), ftml)
            else: # TODO: is there a cleaner way to create uids? (also see special_uids creation below)
                uids = [frame_uid]
                uids.extend((uid,)) # used extend() instead of append() to be parallel to special_uids
                uids.append(frame_uid)
                builder.render(uids, ftml, keyUID=uid, descUIDs=(uid,))
            ftml.closeTest()
            for langID in sorted(c.langs):
                ftml.setLang(langID)
                if not framed:
                    builder.render((uid,), ftml)
                else:
                    builder.render(uids, ftml, keyUID=uid, descUIDs=(uid,))
            ftml.clearLang()

        # Add unencoded specials and ligatures -- i.e., things with a sequence of USVs in the glyph_data:
        ftml.startTestGroup('Specials & ligatures from glyph_data')
        for gname in sorted(builder.specials()):
            special = builder.special(gname)
            if not framed:
                builder.render(special.uids, ftml)
            else:
                special_uids = [frame_uid]
                special_uids.extend(special.uids)
                special_uids.append(frame_uid)
                builder.render(special_uids, ftml, keyUID=special.uids[0], descUIDs=(special.uids))
            ftml.closeTest()
            if len(special.langs):
                for langID in sorted(special.langs):
                    ftml.setLang(langID)
                    if not framed:
                        builder.render(special.uids, ftml)
                    else:
                        builder.render(special_uids, ftml, keyUID=special.uids[0], descUIDs=(special.uids))
                ftml.clearLang()

    if test.lower().startswith("features"):
        # support for adding a diac after each char that is being tested
        # tests include: feature, feature_U, feature_L, feature_O, feature_H, feature_R
        ap_type, c_mark = None, None
        ix = test.find("_")
        if ix != -1:
            ap_type = test[ix + 1:]
        if ap_type:
            try: ap_uid = ap_type_uid[ap_type]
            except KeyError: logger.log("Invalid AP type: %s" % ap_type, "S")
            c_mark = builder.char(ap_uid)

        ftml.startTestGroup('Features from glyph_data')

        # build map from features (and all combinations) to the uids that are affected by a feature
        feats_to_uid = {}
        char_special_iter = chain([builder.char(uid) for uid in builder.uids()],
              [builder.special(gname) for gname in builder.specials()])
        for cs in char_special_iter:
            feat_combs = chain.from_iterable(combinations(cs.feats, r) for r in range(len(cs.feats) + 1))
            for feats in feat_combs:
                if not feats: continue
                feats = sorted(feats)
                feat_set = " ".join(feats)
                if type(cs) is FB.FChar:
                    feats_to_uid.setdefault(feat_set, []).append(cs.uid)
                elif type(cs) is FB.FSpecial:
                    feats_to_uid.setdefault(feat_set, []).append(cs.uids)
                else:
                    pass

        # create tests for all uids affected by a feature, organized by features
        feats_sort = {} # sort based on number of features in combo
        for feat_set in feats_to_uid.keys():
            cnt = len(feat_set.split(" "))
            try: feats_sort[cnt].append(feat_set)
            except: feats_sort[cnt] = [feat_set]

        for i in sorted(feats_sort.keys()):
            feat_set_lst = sorted(feats_sort[i]) # list of feat combos where number in combo is i
            for feat_set in feat_set_lst: # one feat combo
                if feat_set == "smcp":
                    continue # skip smcp test (but not interaction of smcp with other features); see "smcp" test
                ftml.startTestGroup(f'{feat_set}')

                feats = feat_set.split(" ") # separate feat combo into feats
                tvlist_lst = []
                for feat in feats:
                    tvlist = builder.features[feat].tvlist[1:] # all values of feats except default
                    tvlist_lst.append(tvlist) # build list of list of all value for each feat
                p_lst = list(product(*tvlist_lst)) # find all combo of all values, MUST flatten the list of lists

                # list of uids to test against feat combo
                uid_lst = sorted(feats_to_uid[feat_set], key=lambda x: x[0] if type(x) is list else x)
                uid_char_lst = [u for u in uid_lst if type(u) is int]
                uid_lig_lst = [u for u in uid_lst if type(u) is list]

                # break uids into groups
                uidlst_ct = 16 if not ap_type else 8

                # generate ftml for all chars associated with the features
                uidlst_lst = [uid_char_lst[i:i+uidlst_ct] for i in range(0, len(uid_char_lst), uidlst_ct)]
                for uidlst in uidlst_lst: #uidlst contains uids to test
                    base_diac_lst, base_lst = [], []
                    if not ap_type:
                        # features test (no '_<AP>')
                        base_diac_lst, base_lst = uidlst, uidlst
                    else:
                        # features_U, features_L, etc. tests
                        for uid in uidlst:
                            c_base = builder.char(uid)
                            if builder.matchMarkBase(c_mark, c_base):
                                base_lst.append(uid)
                                base_diac_lst.extend((uid, ap_uid))
                    ftml.clearFeatures()
                    builder.render(base_diac_lst, ftml, descUIDs=base_lst) # render all uids without feat setting
                    for tv_lst in p_lst: # for one list of values out of all lists of values
                        ftml.setFeatures(tv_lst)
                        builder.render(base_diac_lst, ftml, descUIDs=base_lst)

                # generate ftml for all ligatures associated with the features
                #   the ligature sequence is followed by a space
                liglst_lst = [uid_lig_lst[i:i+uidlst_ct] for i in range(0, len(uid_lig_lst), uidlst_ct)]
                for liglst in liglst_lst: # liglst contains lists of uids & name to tests
                    lig_lst, lig_diac_lst = [], []
                    for lig in liglst: # lig is alist of uids & name
                        if not ap_type:
                            # 'features test (no '_<AP>')
                            lig_lst.extend(lig)
                            lig_lst.append(ord(' '))
                            lig_diac_lst.extend(lig)
                            lig_diac_lst.append(ord(' '))
                        else:
                            # features_U, features_L, etc. tests
                            c_base = builder.special(lig)
                            if builder.matchMarkBase(c_mark, c_base):
                                lig_lst.extend(lig)
                                lig_lst.append(ord(' '))
                                lig_diac_lst.extend(lig)
                                lig_diac_lst.append(ap_uid) # add AP based on type of features_<AP> test
                                lig_diac_lst.append(ord(' '))
                    lig_lst, lig_diac_lst = lig_lst[0:-1], lig_diac_lst[0:-1] # trim trailing spaces
                    ftml.clearFeatures()
                    builder.render(lig_diac_lst, ftml, descUIDs=lig_lst) # render all uids without feat setting
                    for tv_lst in p_lst: # for one list of values out of all lists of values
                        ftml.setFeatures(tv_lst)
                        builder.render(lig_diac_lst, ftml, descUIDs=lig_lst)

    if test.lower().startswith("smcp"):
        # TODO: improve test for "c2sc" ?
        # Example of what report needs to show: LtnSmEgAlef LtnSmEgAlef.sc LtnCapEgAlef
        #  could add "LtnCapEgAlef <with 'c2sc' feature applied>" but commented out below

        # support adding a diac after each char that is being tested
        # tests include: smcp, smcp_U, etc

        ap_type = None
        ix = test.find("_")
        if ix != -1:
            ap_type = test[ix + 1:]
        if ap_type:
            try: ap_uid = ap_type_uid[ap_type]
            except KeyError: logger.log("Invalid AP type: %s" % ap_type, "S")
            c_mark = builder.char(ap_uid)

        ftml.startTestGroup('Small caps from glyph_data')

        char_special_iter = chain([builder.char(uid) for uid in builder.uids()],
              [builder.special(gname) for gname in builder.specials()])
        smcp_uid_lst = []
        for cs in char_special_iter:
            if 'smcp' in cs.feats:
                if type(cs) is FB.FChar: smcp_uid_lst.append(cs.uid)
                if type(cs) is FB.FSpecial: smcp_uid_lst.append(cs.uids)

        smcp_uid_lst.sort(key=lambda x: x[0] if type(x) is list else x)
        smcp_char_lst = [u for u in smcp_uid_lst if type(u) is int]
        smcp_lig_lst = [u for u in smcp_uid_lst if type(u) is list]

        uidlst_ct = 16 if not ap_type else 8

        uidlst_lst = [smcp_char_lst[i:i+uidlst_ct] for i in range(0, len(smcp_char_lst), uidlst_ct)]
        for uidlst in uidlst_lst:
            base_diac_lst, base_lst = [], []
            if not ap_type:
                base_diac_lst, base_lst = uidlst, uidlst
            else:
                for uid in uidlst:
                    c_base = builder.char(uid)
                    if builder.matchMarkBase(c_mark, c_base):
                        base_lst.append(uid)
                        base_diac_lst.extend((uid, ap_uid))
            ftml.clearFeatures()
            builder.render(base_diac_lst, ftml, descUIDs=base_lst)  # render all uids without feat setting
            ftml.setFeatures(builder.features['smcp'].tvlist[1:])
            builder.render(base_diac_lst, ftml, descUIDs=base_lst)
            ftml.clearFeatures()

            # add uppercase uids to test
            # TODO: may need a better way to convert lower to upper
            upper_base_diac_lst, upper_base_lst = [], []
            for lower_uid in base_diac_lst:
                try: upper_base_diac_lst.append(ord(chr(lower_uid).upper()))
                except: upper_base_diac_lst.append(ord('X'))
            for lower_uid in base_lst:
                try: upper_base_lst.append(ord(chr(lower_uid).upper()))
                except: upper_base_lst.append(ord('X'))
            builder.render(upper_base_diac_lst, ftml, descUIDs=upper_base_lst)
            ftml.setFeatures([("c2sc", "1")]) # TODO: kludgy way to add a 'c2sc' test
            builder.render(upper_base_diac_lst, ftml, descUIDs=upper_base_lst)

        liglst_lst = [smcp_lig_lst[i:i + uidlst_ct] for i in range(0, len(smcp_lig_lst), uidlst_ct)]
        for liglst in liglst_lst:  # liglst contains lists of uids & name to tests
            lig_lst, lig_diac_lst = [], []
            for lig in liglst:  # lig is alist of uids & name
                if not ap_type:
                    # 'smcp test (no '_<AP>')
                    lig_lst.extend(lig)
                    lig_lst.append(ord(' '))
                    lig_diac_lst.extend(lig)
                    lig_diac_lst.append(ord(' '))
                else:
                    # scmp_U, smcp_L, etc. tests
                    c_base = builder.special(lig)
                    if builder.matchMarkBase(c_mark, c_base):
                        lig_lst.extend(lig)
                        lig_lst.append(ord(' '))
                        lig_diac_lst.extend(lig)
                        lig_diac_lst.append(ap_uid)  # add AP based on type of features_<AP> test
                        lig_diac_lst.append(ord(' '))
            lig_lst, lig_diac_lst = lig_lst[0:-1], lig_diac_lst[0:-1]  # trim trailing spaces
            ftml.clearFeatures()
            builder.render(lig_diac_lst, ftml, descUIDs=lig_lst)  # render all uids without feat setting
            ftml.setFeatures(builder.features['smcp'].tvlist[1:])
            builder.render(lig_diac_lst, ftml, descUIDs=lig_lst)

    if test.lower().startswith("diac"):
        # A E H O a e i o
        repBase = [x for x in [0x0041, 0x0045, 0x0048, 0x004F, 0x0061, 0x0065, 0x0069, 0x006F] if x in builder.uids()]

        # Diac attachment:
        ftml.startTestGroup('Representative diacritics on all bases that take diacritics')
        for uid in sorted(builder.uids()):
            # adjust for Latin
            # ignore some I don't care about:
            # if uid < 32 or uid in (0xAA, 0xBA): continue
            if uid < 32: continue
            c = builder.char(uid)
            # Always process Lo, but others only if that take marks:
            if c.general == 'Lo' or c.isBase:
                for diac in repDiac:
                    c_mark = builder.char(diac)
                    if builder.matchMarkBase(c_mark, c):
                        builder.render((uid, diac), ftml, keyUID=uid, descUIDs=[uid])
                    else:
                        # TODO: possibly output 'X' to mark place where mismatches occur
                        pass
                    # for featlist in builder.permuteFeatures(uids = (uid,diac)):
                    #     ftml.setFeatures(featlist)
                    #     # Don't automatically separate connecting or mirrored forms into separate lines:
                    #     builder.render((uid,diac), ftml, addBreaks = False)
                    # ftml.clearFeatures()
                ftml.closeTest()

        ftml.startTestGroup('All diacritics on representative bases')
        for uid in sorted(builder.uids()):
            c = builder.char(uid)
            if c.general == 'Mn':
                for base in repBase:
                    c_base = builder.char(base)
                    if builder.matchMarkBase(c, c_base):
                        builder.render((base, uid), ftml, keyUID=uid, descUIDs=[uid])
                    else: # TODO: possibly output 'X' to mark place where mismatches occur
                        pass
                    # for featlist in builder.permuteFeatures(uids = (uid,base)):
                    #     ftml.setFeatures(featlist)
                    #     builder.render((base,uid), ftml, keyUID = uid, addBreaks = False)
                    # ftml.clearFeatures()
                ftml.closeTest()

        ftml.startTestGroup('Special case - cv79 (NFD)')
        # cv79 - Kayan grave_acute
        kayan_diac_lst = [0x0300, 0x0301] # comb_grave, comb_acute
        kayan_base_char_lst = ['a', 'e', 'i', 'o', 'n', 'u', 'w', 'y', 'A', 'E', 'I', 'O', 'N', 'U', 'W', 'Y']
        kayan_base_lst = [ord(x) for x in kayan_base_char_lst]
        builder.render_lists(kayan_base_lst, kayan_diac_lst, ftml, [('cv79','1')], keyUID=kayan_diac_lst[0])
        ftml.closeTestGroup()

        ftml.startTestGroup('Special case - cv79 (NFC)')
        # cv79 - Kayan grave_acute
        kayan_diac_lst = [0x0301] # comb_acute
        kayan_base_name_lst = ['LtnSmAGrave', 'LtnSmEGrave', 'LtnSmIGrave', 'LtnSmOGrave', 'LtnSmNGrave', 'LtnSmUGrave',
                          'LtnSmWGrave', 'LtnSmYGrave', 'LtnCapAGrave', 'LtnCapEGrave', 'LtnCapIGrave',
                          'LtnCapOGrave', 'LtnCapNGrave', 'LtnCapUGrave', 'LtnCapWGrave', 'LtnCapYGrave']
        kayan_base_lst = [builder.char(x).uid for x in kayan_base_name_lst]
        builder.render_lists(kayan_base_lst, kayan_diac_lst, ftml, [('cv79','1')], keyUID=kayan_diac_lst[0])
        ftml.closeTestGroup()

        ftml.startTestGroup('Dot removal')
        diac_lst = [0x301] #comb_acute
        # the below glyph list was copied from classes.xml and massaged into Python format
        base_name_lst = ['CySmByelorusUkrainI', 'CySmJe', 'LtnSmI', 'LtnSmI.SItal', 'LtnSmI.sc', 'LtnSmIOgonek',
                    'LtnSmIRetrHook', 'LtnSmIStrk', 'LtnSmJ', 'LtnSmJCrossedTail', 'LtnSmJStrk',
                    'LtnSubSmI', 'LtnSubSmJ', 'LtnSupSmI', 'LtnSupSmIStrk', 'ModSmJ', 'ModSmJCrossedTail']
        base_lst = []
        for x in base_name_lst:
            try: base_lst.append(builder.char(x).uid)
            except: pass
        builder.render_lists(base_lst, diac_lst, ftml, keyUID=diac_lst[0])
        builder.render_lists(base_lst, diac_lst, ftml, feature_lst=builder.features['smcp'].tvlist[1:], keyUID=diac_lst[0])
        builder.render_lists(base_lst, diac_lst, ftml, feature_lst=builder.features['ss05'].tvlist[1:], keyUID=diac_lst[0])
        ftml.closeTestGroup()

        ftml.startTestGroup('Superscript diacritics')
        diac_lst = [0x308] #CombDiaer.Sup
        # the below glyph list was copied from classes.xml and massaged into Python format
        base_name_lst = [
            'GrSubSmBeta', 'GrSubSmChi', 'GrSubSmGamma', 'GrSubSmPhi', 'GrSubSmRho', 'LtnSubSmA',
            'LtnSubSmA.SngStory', 'LtnSubSmE', 'LtnSubSmH', 'LtnSubSmI', 'LtnSubSmI.Dotless', 'LtnSubSmJ',
            'LtnSubSmJ.Dotless', 'LtnSubSmK', 'LtnSubSmL', 'LtnSubSmL.SItal', 'LtnSubSmM', 'LtnSubSmN',
            'LtnSubSmO', 'LtnSubSmP', 'LtnSubSmR', 'LtnSubSmS', 'LtnSubSmSchwa', 'LtnSubSmT', 'LtnSubSmU',
            'LtnSubSmV', 'LtnSubSmX', 'LtnSupSmA', 'LtnSupSmA.SngStory', 'LtnSupSmAe', 'LtnSupSmAlpha',
            'LtnSupSmB', 'LtnSupSmBarredO', 'LtnSupSmBarredODep', 'LtnSupSmCCurl', 'LtnSupSmCCurlDep',
            'LtnSupSmCapI', 'LtnSupSmCapIDep', 'LtnSupSmCapOe', 'LtnSupSmCapY', 'LtnSupSmClosedRevOpnE',
            'LtnSupSmD', 'LtnSupSmDotlessJStrk', 'LtnSupSmDotlessJStrkDep', 'LtnSupSmE', 'LtnSupSmEng',
            'LtnSupSmEngDep', 'LtnSupSmEsh', 'LtnSupSmEshDep', 'LtnSupSmEzh', 'LtnSupSmEzhDep', 'LtnSupSmF',
            'LtnSupSmFDep', 'LtnSupSmG', 'LtnSupSmG.SngBowl', 'LtnSupSmI', 'LtnSupSmI.Dotless', 'LtnSupSmIStrk',
            'LtnSupSmIStrk.Dotless', 'LtnSupSmIStrkDep', 'LtnSupSmK', 'LtnSupSmLRetrHook',
            'LtnSupSmLRetrHookDep', 'LtnSupSmM', 'LtnSupSmMDep', 'LtnSupSmN', 'LtnSupSmNLftHook',
            'LtnSupSmNLftHookDep', 'LtnSupSmO', 'LtnSupSmOStrk', 'LtnSupSmOe', 'LtnSupSmOeDep', 'LtnSupSmOpnE',
            'LtnSupSmOpnO', 'LtnSupSmOpnO.TopSerif', 'LtnSupSmP', 'LtnSupSmRamsHorn', 'LtnSupSmRevE',
            'LtnSupSmRevOpnE', 'LtnSupSmRevOpnEDep', 'LtnSupSmSchwa', 'LtnSupSmScriptG', 'LtnSupSmScriptGDep',
            'LtnSupSmT', 'LtnSupSmTurnedA', 'LtnSupSmTurnedAlpha', 'LtnSupSmTurnedAlphaDep', 'LtnSupSmTurnedM',
            'LtnSupSmTurnedMLngLeg', 'LtnSupSmTurnedMLngLegDep', 'LtnSupSmTurnedV', 'LtnSupSmTurnedVDep',
            'LtnSupSmU', 'LtnSupSmUBar', 'LtnSupSmUBarDep', 'LtnSupSmUpsilon', 'LtnSupSmUpsilonDep',
            'LtnSupSmV', 'LtnSupSmZ', 'LtnSupSmZCurl', 'LtnSupSmZCurlDep', 'LtnSupSmZDep', 'ModCapA',
            'ModCapAe', 'ModCapB', 'ModCapBarredB', 'ModCapD', 'ModCapE', 'ModCapG', 'ModCapH', 'ModCapHStrk',
            'ModCapI', 'ModCapJ', 'ModCapK', 'ModCapL', 'ModCapM', 'ModCapN', 'ModCapO', 'ModCapOu',
            'ModCapOu.OpenTop', 'ModCapP', 'ModCapR', 'ModCapRevE', 'ModCapRevN', 'ModCapT', 'ModCapU',
            'ModCapV', 'ModCapW', 'ModSmAin', 'ModSmBeta', 'ModSmBottomHalfO', 'ModSmC', 'ModSmCDep',
            'ModSmCapIStrk', 'ModSmCapIStrkDep', 'ModSmCapInvR', 'ModSmCapL', 'ModSmCapLDep', 'ModSmCapN',
            'ModSmCapNDep', 'ModSmCapU', 'ModSmCapUBar', 'ModSmCapUDep', 'ModSmChi', 'ModSmDelta', 'ModSmEth',
            'ModSmEthDep', 'ModSmGamma', 'ModSmGrGamma', 'ModSmGrPhi', 'ModSmH', 'ModSmHHook', 'ModSmHStrk',
            'ModSmHeng', 'ModSmIota', 'ModSmIotaDep', 'ModSmJ', 'ModSmJ.Dotless', 'ModSmJCrossedTail',
            'ModSmJCrossedTail.Dotless', 'ModSmJCrossedTailDep', 'ModSmL', 'ModSmLMiddleTilde', 'ModSmLPalHook',
            'ModSmLPalHookDep', 'ModSmMHook', 'ModSmMHookDep', 'ModSmNRetrHook', 'ModSmNRetrHookDep',
            'ModSmPhi', 'ModSmPhiDep', 'ModSmR', 'ModSmRevGlottalStop', 'ModSmS', 'ModSmSHook', 'ModSmSHookDep',
            'ModSmSdwysU', 'ModSmTPalHook', 'ModSmTPalHookDep', 'ModSmTheta', 'ModSmThetaDep', 'ModSmTopHalfO',
            'ModSmTrndAe', 'ModSmTrndI', 'ModSmTrndOpnE', 'ModSmTrndR', 'ModSmTrndRHook', 'ModSmTurnedH',
            'ModSmTurnedHDep', 'ModSmTurnedY', 'ModSmVHook', 'ModSmVHook.StraightLft',
            'ModSmVHook.StraightLftHighHook', 'ModSmVHookDep', 'ModSmW', 'ModSmX', 'ModSmY', 'ModSmZRetrHook',
            'ModSmZRetrHookDep', 'ModGlottalStop', 'ModRevGlottalStop'
        ]
        base_lst = []
        for x in base_name_lst:
            try: base_lst.append(builder.char(x).uid)
            except: pass
        builder.render_lists(base_lst, diac_lst, ftml, keyUID=diac_lst[0])
        ftml.closeTestGroup()

        # ftml.startTestGroup('Special case - cv75')
        # ftml.clearFeatures()
        # # comb_circumflex, comb_acute, space, a, comb_circumflex, comb_acute
        # builder.render((0x0302, 0x0301, 0x0020, 0x0061, 0x0302, 0x0301), ftml, descUIDs=(0x0302, 0x0301))
        # # o, comb_circumflex, comb_acute
        # builder.render((0x006F, 0x0302, 0x0301), ftml, keyUID=0x0302)
        # ftml.setFeatures([["cv75", "1"]])
        # builder.render((0x0302, 0x0301, 0x0020, 0x0061, 0x0302, 0x0301), ftml, descUIDs=(0x0302, 0x0301))
        # builder.render((0x006F, 0x0302, 0x0301), ftml, keyUID=0x0302)
        # ftml.closeTestGroup()

    # Write the output ftml file
    ftml.writeFile(args.output)

def cmd() : execute("UFO",doit,argspec)
if __name__ == "__main__": cmd()
