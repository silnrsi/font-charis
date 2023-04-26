#!/usr/bin/python3
# this is a smith configuration file

# set the default output folders for release docs
DOCDIR = ["documentation", "web"]

STANDARDS = 'references/v6101'

APPNAME = 'CharisSIL'
familyname = APPNAME
DEBPKG = 'fonts-sil-charis'

# Get VERSION and BUILDLABEL from Regular UFO; must be first function call:
getufoinfo('source/masters/' + familyname + '-Regular' + '.ufo')

ftmlTest('tools/ftml-smith.xsl')

opts = preprocess_args({'opt': '--quick'})

# APs to ignore when generating OT and GDL classes
omitapps = '--omitaps "C _C L11 L12 L13 L21 L22 L23 L31 L32 L33 ' + \
                'C11 C12 C13 C21 C22 C23 C31 C32 C33 U11 U12 U13 U21 U22 U23 U31 U32 U33"'

cmds = []
cmds.append(cmd('psfchangettfglyphnames ${SRC} ${DEP} ${TGT}', ['${source}']))
cmds.append(cmd('${TTFAUTOHINT} -n -W ${DEP} ${TGT}'))

for dspace in ('Roman', 'Italic'):
#for dspace in ('Roman',):
#for dspace in ('Italic',):
    designspace('source/' + familyname + dspace + '.designspace',
                target = process('${DS:FILENAME_BASE}.ttf', *cmds),
                instances = ['Charis SIL Regular'] if '--quick' in opts else None,
#                classes = 'source/${DS:FAMILYNAME_NOSPC}_classes.xml', # fails for Gentium Book
                classes = 'source/classes.xml',
                opentype = fea('source/${DS:FILENAME_BASE}.fea',
                    master = 'source/opentype/main.feax',
                    make_params = omitapps,
                    depends = ('source/opentype/gsub.feax',
                        'source/opentype/gpos.feax',
                        'source/opentype/gdef.feax'),
                    mapfile = 'source/${DS:FILENAME_BASE}.map',
                    to_ufo = 'True' # copies to instance UFOs
                    ),
                typetuner = typetuner('source/typetuner/feat_all.xml'),
                woff = woff('web/${DS:FILENAME_BASE}.woff',
                    metadata=f'../source/{familyname}-WOFF-metadata.xml'),
                version = VERSION,
#                pdf=fret(params = '-r -oi')
                )

def configure(ctx):
    ctx.find_program('ttfautohint')
