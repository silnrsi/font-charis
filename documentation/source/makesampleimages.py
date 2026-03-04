#!/usr/bin/env python
'''Produce sample font images'''
__url__ = 'https://github.com/silnrsi/fontdocs'
__copyright__ = 'Copyright (c) 2021-2026 SIL Global (https://www.sil.org)'
__license__ = 'Released under the MIT License (https://opensource.org/licenses/MIT)'
__author__ = 'Victor Gaultney'

import os
from silfont.core import execute
from drawbot_skia.drawbot import *

argspec = [
    ('infont', {'help': 'Input font file'}, {'type': 'filename'}),
    ('outfolder',{'help': 'Output folder', 'nargs': '?'}, {}),
    ('--sizes', {'help': 'Sizes to produce - S, M, L'},{}),
    ('--base', {'help': 'Output filename base'},{}),
]

widths =    {'S': 400,'M': 600,'L': 1200}
heights =   {'S': 30, 'M': 45, 'L': 90  }
typesizes = {'S': 24, 'M': 36, 'L': 72  }

def doit(args):
    infont = args.infont
    outfolder = args.outfolder
    if outfolder and not os.path.exists(outfolder):
        os.makedirs(outfolder)

    infontpath = os.path.abspath(infont)

    sizes = args.sizes.split(",") if args.sizes else ["L"]
    base = args.base if args.base else "fontsample"

    for size in sizes:
        w = widths[size]
        h = heights[size]
        s = typesizes[size]
        newDrawing()
        newPage(w, h)
        fill(1,1,1)
        rect(0, 0, w, h)
        fill(0,0,0)
        font(infontpath)
        fontSize(s)   
        text("Everyone has the right to education", (2, s/3)) # 2px allows for some anti-aliasing space at the left edge
        saveImage(f"./{outfolder}/{base}_{w}x{h}.png")

    return

def cmd() : execute(None,doit, argspec)
if __name__ == "__main__": cmd()
