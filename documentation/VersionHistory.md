# Detailed Version History

For a more concise log of versions see the [FONTLOG](FONTLOG.txt).

## Charis SIL v5.950 (beta)

_This is an early beta version of the next major release. Please use it only for testing, not production, and give us your feedback._

This is the first (beta) release that uses a UFO-based design and production workflow, with all sources in open formats and a completely open-source build toolkit. For more details see [SIL Font Development Notes](https://silnrsi.github.io/silfontdev/en-US/Introduction.html).

_This major release includes spacing changes to some glyphs, so text in existing documents may reflow. However, the spacing changes are mostly for rare glyphs that most users are not likely to use. If you see significant differences in layout between version 5.000 and this version of the fonts please let us know._

### Additional characters supported

Many characters added to Unicode in versions 7.0-13.0 are now supported, including within features (e.g. small caps) where appropriate. Others have been added due to user request.

U+03D1 GREEK THETA SYMBOL
U+03F4 GREEK CAPITAL THETA SYMBOL
U+1AB0 COMBINING DOUBLED CIRCUMFLEX ACCENT
U+1AB1 COMBINING DIAERESIS-RING
U+1AB2 COMBINING INFINITY
U+1AB3 COMBINING DOWNWARDS ARROW
U+1AB4 COMBINING TRIPLE DOT
U+1AB5 COMBINING X-X BELOW
U+1AB6 COMBINING WIGGLY LINE BELOW
U+1AB7 COMBINING OPEN MARK BELOW
U+1AB8 COMBINING DOUBLE OPEN MARK BELOW
U+1AB9 COMBINING LIGHT CENTRALIZATION STROKE BELOW
U+1ABA COMBINING STRONG CENTRALIZATION STROKE BELOW
U+1DF5 COMBINING UP TACK ABOVE
U+203B REFERENCE MARK
U+20BE LARI SIGN
U+20BF BITCOIN SIGN
U+27E8 MATHEMATICAL LEFT ANGLE BRACKET
U+27E9 MATHEMATICAL RIGHT ANGLE BRACKET
U+2E13 DOTTED OBELOS
U+2E14 DOWNWARDS ANCORA
U+2E17 DOUBLE OBLIQUE HYPHEN
U+2E22 TOP LEFT HALF BRACKET
U+2E23 TOP RIGHT HALF BRACKET
U+2E24 BOTTOM LEFT HALF BRACKET
U+2E25 BOTTOM RIGHT HALF BRACKET
U+A78F LATIN LETTER SINOLOGICAL DOT
U+A7AE LATIN CAPITAL LETTER SMALL CAPITAL I
U+A7AF LATIN LETTER SMALL CAPITAL Q
U+A7B3 LATIN CAPITAL LETTER CHI
U+A7B4 LATIN CAPITAL LETTER BETA
U+A7B5 LATIN SMALL LETTER BETA
U+A7B6 LATIN CAPITAL LETTER OMEGA
U+A7B7 LATIN SMALL LETTER OMEGA
U+A7B8 LATIN CAPITAL LETTER U WITH STROKE
U+A7B9 LATIN SMALL LETTER U WITH STROKE
U+AB30 LATIN SMALL LETTER BARRED ALPHA
U+AB53 LATIN SMALL LETTER CHI
U+AB5C MODIFIER LETTER SMALL HENG
U+AB5E MODIFIER LETTER SMALL L WITH MIDDLE TILDE
U+F26E CAPITAL RAMS HORN (in SIL PUA)

### New and changed features (OpenType and Graphite)

Added two new features for controlling literacy forms of a and g separately
Added feature to support side-by-side rendering of U+0300 plus U+0301
Added feature to provide alternate form of Capital J with top serif
Added support for clicks to small caps feature
Synchronized Graphite and OpenType feature tags

### Fixes and improvements

Improved miscellaneous anchor positions
Made many basic glyphs interpolation compatible
Fixed missing or distorted Vietnamese composite glyphs
Fixed miscellaneous distorted glyphs
Increased size of Combining Commas
Improved design of retroflex laterals
Improved position of Cyrillic Breve over some glyphs

Numerous other fixes and improvements to various glyphs, including:
U+0037 DIGIT SEVEN (spacing)
U+00E6 LATIN SMALL LETTER AE (made single-story in italic)
U+01E5 LATIN SMALL LETTER G WITH STROKE (bar position on single-story variant)
U+026E LATIN SMALL LETTER EZH
U+02D6 MODIFIER LETTER PLUS SIGN (size)
U+02DF MODIFIER LETTER CROSS ACCENT (size)
U+031F COMBINING PLUS SIGN BELOW (design)
U+033B COMBINING SQUARE BELOW (more rectangular)
U+04E0 CYRILLIC CAPITAL LETTER ABKHASIAN DZE
U+1D02 LATIN SMALL LETTER TURNED AE (made double-story in italic)
U+1D46 MODIFIER LETTER SMALL TURNED AE (made double-story in italic)
U+1EFC LATIN CAPITAL LETTER MIDDLE-WELSH V
U+2053 SWUNG DASH
U+A778 LATIN SMALL LETTER UM (spacing)
U+A7FA LATIN LETTER SMALL CAPITAL TURNED M (italic)

### No longer supported

The 'Show Invisibles' feature has been removed

Nine-level pitch contours are no longer supported and will be replaced by a standalone pitch contours font in the future

