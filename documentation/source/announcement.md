Release 6.200 - New features and additional character support

180+ new chars
240+ new glyphs
3609 > 3857 glyphs +248


This is a maintenance release primarily focused on making the v6 fonts available on *TypeTuner Web*. This enables us to also provide v6 versions of many special-purpose modified fonts, including *Literacy* and *Compact* versions.

Both desktop and web fonts are provided in a single, all-platforms package on the [Download page](https://software.sil.org/charis/download). Special-purpose fonts are available from a [dedicated page](https://software.sil.org/lcgfonts/download/).

#### New

- The fonts now support SIL *TypeTuner*. Customized fonts can be created at *TypeTuner Web* (https://scripts.sil.org/ttw/fonts2go.cgi)

- New `locl` OpenType feature that supports Macedonian (MKD/mk) Cyrillic alternates

- Serbian and Macedonian alternates are also available through a new OpenType feature (cv84) for applications that do not support language-specific `locl` features

- Characters have been added to support Unicode versions up to 14.0.0 (more to be added in future releases):
    - U+A7C4 LATIN CAPITAL LETTER C WITH PALATAL HOOK
    - U+A7C5 LATIN CAPITAL LETTER S WITH HOOK
    - U+1DF00 LATIN SMALL LETTER FENG DIGRAPH WITH TRILL
    - U+1DF01 LATIN SMALL LETTER REVERSED SCRIPT G
    - U+1DF02 LATIN LETTER SMALL CAPITAL TURNED G
    - U+1DF03 LATIN SMALL LETTER REVERSED K
    - U+1DF05 LATIN SMALL LETTER LEZH WITH RETROFLEX HOOK
    - U+1DF07 LATIN SMALL LETTER REVERSED ENG
    - U+1DF09 LATIN SMALL LETTER T WITH HOOK AND RETROFLEX HOOK
    - U+1DF0A LATIN LETTER RETROFLEX CLICK WITH RETROFLEX HOOK
    - U+1DF0B LATIN SMALL LETTER ESH WITH DOUBLE BAR
    - U+1DF0C LATIN SMALL LETTER ESH WITH DOUBLE BAR AND CURL
    - U+1DF0D LATIN SMALL LETTER TURNED T WITH CURL
    - U+1DF0E LATIN LETTER INVERTED GLOTTAL STOP WITH CURL
    - U+1DF0F LATIN LETTER STRETCHED C WITH CURL
    - U+1DF10 LATIN LETTER SMALL CAPITAL TURNED K
    - U+1DF11 LATIN SMALL LETTER L WITH FISHHOOK
    - U+1DF12 LATIN SMALL LETTER DEZH DIGRAPH WITH PALATAL HOOK
    - U+1DF13 LATIN SMALL LETTER L WITH BELT AND PALATAL HOOK
    - U+1DF14 LATIN SMALL LETTER ENG WITH PALATAL HOOK
    - U+1DF15 LATIN SMALL LETTER TURNED R WITH PALATAL HOOK
    - U+1DF16 LATIN SMALL LETTER R WITH FISHHOOK AND PALATAL HOOK
    - U+1DF17 LATIN SMALL LETTER TESH DIGRAPH WITH PALATAL HOOK
    - U+1DF19 LATIN SMALL LETTER DEZH DIGRAPH WITH RETROFLEX HOOK
    - U+1DF1A LATIN SMALL LETTER I WITH STROKE AND RETROFLEX HOOK
    - U+1DF1B LATIN SMALL LETTER O WITH RETROFLEX HOOK
    - U+1DF1C LATIN SMALL LETTER TESH DIGRAPH WITH RETROFLEX HOOK
    - U+1DF1D LATIN SMALL LETTER C WITH RETROFLEX HOOK
    - U+1DF1E LATIN SMALL LETTER S WITH CURL
    
#### Improved

- The special-purpose modified fonts have been updated to be based on the current version. These are available at https://software.sil.org/lcgfonts/download/ and include *Literacy* and *Compact* versions.

- U+02DE MODIFIER LETTER RHOTIC HOOK position improved with modifier vowels: 
    - U+02B8 MODIFIER LETTER SMALL Y
    - U+1D53 MODIFIER LETTER SMALL OPEN O
    - U+1D5A MODIFIER LETTER SMALL TURNED M
    - U+1DBA MODIFIER LETTER SMALL TURNED V

- Design improved for these characters:
    - U+0184 LATIN CAPITAL LETTER TONE SIX
    - U+0185 LATIN SMALL LETTER TONE SIX

- The small caps feature (smcp) now supports more characters

- The spacing of Serbian italic alternates has been improved

#### Changed encoding

- The following characters were in the SIL PUA but have now been given Unicode assignments. The SIL PUA characters are now deprecated:
    - U+A7C6 LATIN CAPITAL LETTER Z WITH PALATAL HOOK (was U+F234)
    - U+10783 MODIFIER LETTER SMALL AE (was U+F1A1)
    - U+1078F MODIFIER LETTER SMALL CLOSED REVERSED OPEN E (was U+F1A4)
    - U+10791 MODIFIER LETTER SMALL RAMS HORN (was U+F1B5)
    - U+10795 MODIFIER LETTER SMALL H WITH STROKE (was U+F1BC)
    - U+107A0 MODIFIER LETTER SMALL TURNED Y (was U+F1CE)
    - U+107A2 MODIFIER LETTER SMALL O WITH STROKE (was U+F1AB)
    - U+107A3 MODIFIER LETTER SMALL CAPITAL OE (was U+F1AE)
    - U+107B2 MODIFIER LETTER SMALL CAPITAL Y (was U+F1B4)
    - U+1088E NABATAEAN LETTER FINAL KAPH (was U+F1A3)
    - U+1DF04 LATIN LETTER SMALL CAPITAL L WITH BELT (was U+F268)
    - U+1DF06 LATIN SMALL LETTER TURNED Y WITH BELT (was U+F267)
    - U+1DF08 LATIN SMALL LETTER TURNED R WITH LONG LEG AND RETROFLEX HOOK (was U+F269)
    - U+1DF18 LATIN SMALL LETTER EZH WITH PALATAL HOOK (was U+F235)
