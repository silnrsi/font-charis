#!/usr/bin/env python3
'''Creates new kerning data for small caps based on capital letter kerning data.'''
__url__ = 'https://github.com/silnrsi/pysilfont'
__copyright__ = 'Copyright (c) 2026 SIL International (https://www.sil.org)'
__license__ = 'Released under the MIT License (https://opensource.org/licenses/MIT)'
__author__ = 'Victor Gaultney'

from silfont.core import execute

argspec = [
    ('ifont', {'help': 'Font file'}, {'type': 'infont'}),
    ('ofont',{'help': 'Output font file','nargs': '?' }, {'type': 'outfont'}),
    ('--scale', {'help': 'Scaling factor', 'default': 1.0}, {}),
    ('-l', '--log', {'help': 'Log file'}, {'type': 'outfile', 'def': '_newsckerngroups.log'})]

def doit(args) :
    font = args.ifont
    logger = args.logger
    scale = float(args.scale)
    print(scale)

    logger.log("Creating new small cap kern data", "P")

    for pair, kern in font.kerning.items():
        lname, rname = pair
        newlname, newrname = lname[0:14] + "SC" + lname[17:], rname[0:14] + "SC" + rname[17:]
        newkern = int(kern * scale)
        if lname.startswith("public.kern1.LCap"):
            if rname.startswith("public.kern2.RCap"):
                   font.kerning[(newlname, newrname)] = newkern
                   font.kerning[(lname, newrname)] = newkern
            elif rname == "public.kern2.RQuote" or rname == "public.kern2.RModApos" or rname == "public.kern2.RRelease" or rname == "public.kern2.RPunctBase":
                   font.kerning[(newlname, rname)] = kern
        elif lname == "public.kern1.LQuote":
            if rname.startswith("public.kern2.RCap"):
                   font.kerning[(lname, newrname)] = kern

    return font

def cmd() : execute("FP",doit,argspec)
if __name__ == "__main__": cmd()
