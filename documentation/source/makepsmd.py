#!/usr/bin/env python
'''Process font documentation .md files for use on product sites '''
__url__ = 'http://github.com/silnrsi/fontdocs'
__copyright__ = 'Copyright (c) 2021 SIL International (http://www.sil.org)'
__license__ = 'Released under the MIT License (http://opensource.org/licenses/MIT)'
__author__ = 'Victor Gaultney'

import re
from silfont.core import execute

argspec = [
    ('infile', {'help': 'Input .md filename'}, {'type': 'infile'}),
    ('outfile',{'help': 'Output .md filename'}, {'type': 'outfile'})
]

def doit(args):
    infile = args.infile
    outfile = args.outfile

    firstline = True
    inheader = False
    inpsonly = False
    
    temptext = ""

    # remove YAML header and uncomment the [font] shortcode
    for line in infile:
        if firstline:
            firstline = False
            inheader = True
            continue
        if inheader:
            if line.startswith("---"):
                inheader = False
            continue
        if line.startswith("<!-- PRODUCT SITE ONLY"):
            inpsonly = True
            continue
        if inpsonly:
            if line.startswith("-->"):
                inpsonly = False
                continue
        temptext = temptext + line

    # reconfigure image markup
    # mdimage = re.compile(r"!\[(.*?)\]\((\S+\.\w+)\)\{\.(\S+)\}\n?<!--\sPRODUCT\sSITE\sIMAGE\sSRC\s(\S+)\s-->")
    # temptext = mdimage.sub(r"<img class='\3' alt='\1' src='\4' />\n[caption]<em>\1</em>[/caption]", temptext)

    mdimage = re.compile(r"!\[(.*?)\]\((\S+\.\w+)\)\{\.(\S+)\}\n?<!--\sPRODUCT\sSITE\sIMAGE\sSRC\s(\S+)\s-->")
    temptext = mdimage.sub(r"<img class='\3' alt='\1' src='\4' />", temptext)

    mdimagecap = re.compile(r"<figcaption>(.*?)<\/figcaption>")
    temptext = mdimagecap.sub(r"[caption]<em>\1</em>[/caption]", temptext)

    # replace local links with site references
    temptext = temptext.replace(".md","")

    # replace links to external markdown files
    temptext = temptext.replace(".rawmd",".md")

    outfile.write(temptext)

    return


def cmd() : execute(None,doit, argspec)
if __name__ == "__main__": cmd()
