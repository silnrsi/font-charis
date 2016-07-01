#!/usr/bin/python
# this is a smith configuration file

# set the default output folders
out="results"
DOCDIR="documentation"
OUTDIR="installers"
ZIPDIR="releases"
STANDARDS = 'standards'

# set the font name, version, licensing and description
APPNAME="CharisSIL"
FILENAMEBASE="CharisSIL"
VERSION="6.000"
TTF_VERSION="6.000"
COPYRIGHT="Copyright (c) 2007-2016, SIL International (http://www.sil.org)"
LICENSE='OFL.txt'

DESC_SHORT = "Unicode font for Roman- and Cyrillic-based writing systems"
DESC_LONG = """
CharisSIL is a Unicode font for Roman- and Cyrillic-based writing systems
Font sources are published in the repository and a smith open workflow is
used for building, testing and releasing.
"""
DESC_NAME = "CharisSIL"
DEBPKG = 'fonts-sil-charis'

# set the build and test parameters

#for style in ('-Regular','-Bold') :
for style in ('-Regular',) :
    fname = FILENAMEBASE + style
    font(target = fname + '.ttf',
#        source = 'source/' + fname + '.ufo',
        source = create(fname + '-not.sfd', cmd("../tools/FFRemoveOverlapAll.py ${SRC} ${TGT}", ['source/' + fname + '.ufo'])),
        version = VERSION,
        ap =  'source/' + fname +'_ap' + '.xml',
        #classes = 'source/' + fname +'_classes' + '.xml',
        opentype = fea('source/' + fname + '.fea',
            master = 'source/opentype/' + fname + '.fea',
            #preinclude = 'font-source/padauk' + f + '_init.fea',
            make_params="-o 'C L11 L12 L13 L21 L22 L23 L31 L32 L33 C11 C12 C13 C21 C22 C23 C31 C32 C33 U11 U12 U13 U21 U22 U23 U31 U32 U33'",
           # depends = map(lambda x:"font-source/padauk-"+x+".fea",
           #     ('mym2_features', 'mym2_GSUB', 'dflt_GSUB'))
            ),
        graphite = gdl('source/' + fname + '.gdl',
            master = 'source/graphite/charis.gdl'),
        license = ofl('CharisSIL','SIL'),
        woff = woff()
        )
