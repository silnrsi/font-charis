#!/usr/bin/python3
# this is a smith configuration file

# output folders use smith defaults and don't need to be set here

# set some default folders (most are already set by default)
#STANDARDS = 'references/v5'
STANDARDS = 'references/b1'

APPNAME = 'CharisSIL'
familyname = APPNAME
DEBPKG = 'fonts-sil-charis'

# Get VERSION and BUILDLABEL from Regular UFO; must be first function call:
getufoinfo('source/' + familyname + '-Regular' + '.ufo')

ftmlTest('tools/ftml-smith.xsl')

# APs to ignore when generating OT and GDL classes
omitapps = '--omitaps "C L11 L12 L13 L21 L22 L23 L31 L32 L33 ' + \
                'C11 C12 C13 C21 C22 C23 C31 C32 C33 U11 U12 U13 U21 U22 U23 U31 U32 U33"'

for dspace in ('Roman', 'Italic'):
#for dspace in ('Roman',):
#for dspace in ('Italic',):
    designspace('source/' + familyname + dspace + '.designspace',
                target = process('${DS:FILENAME_BASE}.ttf', 
                    cmd('psfchangettfglyphnames ${SRC} ${DEP} ${TGT}', ['${DS:FILE}'])),
                ap = 'source/${DS:FILENAME_BASE}_ap.xml',
                classes = 'source/opentype/${DS:FAMILYNAME_NOSPC}_classes.xml',
                opentype = fea('source/${DS:FILENAME_BASE}.fea',
                    master = 'source/opentype/${DS:FILENAME_BASE}.fea',
                    make_params = omitapps,
                    depends = ('source/opentype/${DS:FAMILYNAME_NOSPC}_gsub.fea', 
                        'source/opentype/${DS:FILENAME_BASE}_gpos_lkups.fea', 
                        'source/opentype/${DS:FAMILYNAME_NOSPC}_gpos_feats.fea', 
                        'source/opentype/${DS:FAMILYNAME_NOSPC}_gdef.fea'),
                    to_ufo = 'True'
                    ),
                graphite = gdl('source/${DS:FILENAME_BASE}.gdl',
                    master = 'source/graphite/main.gdh',
                    make_params = omitapps,
                    params = '-e gdlerr-${DS:FILENAME_BASE}.txt',
                    depends = ('source/graphite/features.gdh', 
                        'source/graphite/pitches.gdh', 
                        'source/graphite/stddef.gdh')
                    ),
                woff = woff(),
                version = VERSION,
#                pdf=fret(params = '-r -oi')
                )
