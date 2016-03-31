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

for style in ('-Regular','-Bold') :
    font(target = FILENAMEBASE + style + '.ttf',
#        source = 'source/' + FILENAMEBASE + style + '.ufo',
        source = create(FILENAMEBASE + style + '-not.sfd', cmd("../tools/FFRemoveOverlapAll.py ${SRC} ${TGT}", ['source/' + FILENAMEBASE + style + '.ufo']),
                                          cmd("../tools/FFRemoveOverlapAll.py ${DEP} ${TGT}")),
        version = VERSION,
        license = ofl('CharisSIL','SIL'),
        opentype = internal(),
        woff = woff()
    )