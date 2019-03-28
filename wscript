#!/usr/bin/python2
# encoding: utf-8
# this is a smith configuration file

# output folders use smith defaults and don't need to be set here

# set the version control system
VCS = 'git'

# set the font name, version, licensing and description
APPNAME="CharisSIL"
FAMILYNAME = APPNAME
DESC_SHORT = "Unicode font for Roman- and Cyrillic-based writing systems"
DESC_LONG = """
CharisSIL is a Unicode font for Roman- and Cyrillic-based writing systems
Font sources are published in the repository and a smith open workflow is
used for building, testing and releasing.
"""

# packaging
DEBPKG = 'fonts-sil-charis'

# Get version and authorship information from Regular UFO; must be first function call:
getufoinfo('source/' + FAMILYNAME + '-Regular' + '.ufo')
BUILDLABEL = "alpha"

fontfamily="CharisSIL"
for dspace in ('Roman', 'Italic'):
#for dspace in ('Roman',):
#for dspace in ('Italic',):
    designspace('source/' + fontfamily + dspace + '.designspace',
                target = process('${DS:FILENAME_BASE}.ttf', 
                    cmd('psfchangettfglyphnames ${SRC} ${DEP} ${TGT}', ['${DS:FILE}'])),
                ap = 'source/${DS:FILENAME_BASE}_ap.xml',
                classes = 'source/opentype/%s_classes.xml' % fontfamily, 
                opentype = fea('source/${DS:FILENAME_BASE}.fea',
                    master = 'source/opentype/${DS:FILENAME_BASE}.fea',
                    make_params = "--omitaps 'C L11 L12 L13 L21 L22 L23 L31 L32 L33 " + \
                        "C11 C12 C13 C21 C22 C23 C31 C32 C33 U11 U12 U13 U21 U22 U23 U31 U32 U33'",
#                   $DS:FAMILYNAME == "Charis SIL" != "CharisSIL" in file name
                    depends = ('source/opentype/%s_gsub.fea' % fontfamily, 
                        'source/opentype/${DS:FILENAME_BASE}_gpos_lkups.fea', 
                        'source/opentype/%s_gpos_feats.fea' % fontfamily, 
                        'source/opentype/%s_gdef.fea' % fontfamily)
                    ),
                graphite = gdl('source/${DS:FILENAME_BASE}.gdl',
                    master = 'source/graphite/main.gdh', 
                    params = '-e gdlerr-${DS:FILENAME_BASE}.txt',
                    ),
                woff = woff()
                )
