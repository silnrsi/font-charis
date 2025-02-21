#!/usr/bin/env python3
'''Does a very basic comparison of the number of kern pairs in two fonts'''
__url__ = 'https://github.com/silnrsi/pysilfont'
__copyright__ = 'Copyright (c) 2025 SIL International (https://www.sil.org)'
__license__ = 'Released under the MIT License (https://opensource.org/licenses/MIT)'
__author__ = 'Victor Gaultney'

from silfont.core import execute

argspec = [
    ('fontref', {'help': 'Font file used as reference'}, {'type': 'infont'}),
    ('fontcomp', {'help': 'Font file to be compared'}, {'type': 'infont'}),
    ('-l', '--log', {'help': 'Log file'}, {'type': 'outfile', 'def': '_gorder.log'})]

def doit(args) :
    fontref = args.fontref
    fontcomp = args.fontcomp
    logger = args.logger

    logger.log("Comparing number of kern pairs", "P")

    refkerns = len(fontref.kerning)
    compkerns = len(fontcomp.kerning)

    if refkerns == compkerns:
        logger.log("Number of kern pairs are the same: " + fontref.info.postscriptFontName + " has " + str(refkerns) + " ; " + fontcomp.info.postscriptFontName + " has " + str(compkerns), "P")
    else:
        logger.log("Number of kern pairs do not match: " + fontref.info.postscriptFontName + " has " + str(refkerns) + " ; " + fontcomp.info.postscriptFontName + " has " + str(compkerns), "E")

def cmd() : execute("FP",doit,argspec)
if __name__ == "__main__": cmd()
