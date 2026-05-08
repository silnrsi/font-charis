#!/usr/bin/env python3
'''Creates new kerning groups for small caps based on capital letter kerning groups.'''
__url__ = 'https://github.com/silnrsi/pysilfont'
__copyright__ = 'Copyright (c) 2026 SIL International (https://www.sil.org)'
__license__ = 'Released under the MIT License (https://opensource.org/licenses/MIT)'
__author__ = 'Victor Gaultney'

from silfont.core import execute

argspec = [
    ('ifont', {'help': 'Font file'}, {'type': 'infont'}),
    ('ofont',{'help': 'Output font file','nargs': '?' }, {'type': 'outfont'}),
    ('-i','--input',{'help': 'Input csv file'}, {'type': 'incsv', 'def': 'c2sc_mapping.csv'}),
    ('-l', '--log', {'help': 'Log file'}, {'type': 'outfile', 'def': '_newsckerngroups.log'})]

def doit(args) :
    font = args.ifont
    logger = args.logger

    # Process csv list into a dictionary structure
    args.input.numfields = 2
    smcaps = {}
    for line in args.input :
        smcaps[line[0]] = {"smcap": line[1]}

    logger.log("Creating new small cap kern groups", "P")

    for group, members in font.groups.items():
        if group.startswith("public.kern1.LCap") or group.startswith("public.kern2.RCap"):
            newgroup = group[0:14] + "SC" + group[17:]
            newmembers = []
            for glyph in members:
                if glyph in smcaps:
                    newglyph = smcaps[glyph]["smcap"]
                    newmembers.append(newglyph)
            font.groups[newgroup] = newmembers
            print(newgroup)
    
    return font

def cmd() : execute("FP",doit,argspec)
if __name__ == "__main__": cmd()
