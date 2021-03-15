README
Charis SIL v5.890
========================

This file describes the Graphite source files included with the Charis SIL font family. This information should be distributed along with the Charis SIL fonts and any derivative works.

These files are from the Charis SIL project (https://software.sil.org/charis/).
Copyright (c) 1997-2021 SIL International (http://www.sil.org/) with Reserved
Font Names "Charis" and "SIL". This Font Software is licensed under the SIL
Open Font License, Version 1.1 (http://scripts.sil.org/OFL).
            
charis.gdl            - definition of glyphs and glyph classes; auto-generated from the font
main.gdh              - bulk of Graphite rules and extra definitions to support them
features.gdh          - feature and language-feature definitions
pitches.gdh           - rules and definitions to support tone ligatures
pua.gdh               - mapping from PUA pseudo-glyphs to real Unicode glyphs
takes_lowProfile.gdh  - definitions to support low-profile feature; auto-generated
fontSpecific.gdh      - font-specific definition for Charis SIL
stddef.gdh            - standard GDL abbreviations

In order to modify the Graphite tables in this font:
* Strip out the existing tables
  Using the Font-TTF-Scripts package ( http://scripts.sil.org/FontUtils ), you could use something like:
    ttftable -delete graphite old-font-with-Graphite-tables.ttf  new-font-without-Graphite-tables.ttf 
* Run:
    grcompiler -d -v2 -n2048 -w3521 -w510 font.gdl ttf-file-with-Graphite-tables-stripped.ttf output-ttf.ttf
    
Further detail of features is available in the file /source/opentype/featureinfo.xlsx
