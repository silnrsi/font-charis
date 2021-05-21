Charis SIL contains near-complete coverage of all the characters defined in Unicode 7.0 for Latin and Cyrillic. In total, over 3,600 glyphs are included, providing support for over 2,300 characters as well as a large number of ligated character sequences (e.g., contour tone letters used in phonetic transcription of tonal languages). 

In addition, alternately-designed glyphs are also provided for a number of characters for use in particular contexts. The glyphs are accessible in applications that support advanced font technologies, specifically [Graphite](http://graphite.sil.org/) or OpenType. These technologies are also utilized to provide automatic positioning of diacritics relative to base characters in arbitrary base+diacritic combinations (including combinations involving multiple diacritics).

Some important issues with respect to Unicode need to be borne in mind. Unicode is a character encoding and not a glyph encoding. Thus you should endeavor to use the character that reflects your character needs rather than finding a glyph that looks right and using its character code. For example, there is only one code for **CAPITAL ENG (U+014A)**, although there are 4 different glyph shapes for this character in use around the world. 

<table class="sff">
  <tr>
    <th>LATIN CAPITAL LETTER ENG (character name)</th>
    <th>Glyph Options</th>
  </tr>
  <tr>
    <td>Lowercase style with descender</td>
    <td><span class='charis-dflt-R normal'>Ŋŋ</span></td>
  </tr>
  <tr>
    <td>Lowercase style on baseline</td>
    <td><span class='charis-cv43-1-R normal'>Ŋŋ</span></td>
  </tr>
  <tr>
    <td>Uppercase style with descender</td>
    <td><span class='charis-cv43-2-R normal'>Ŋŋ</span></td>
  </tr>
  <tr>
    <td>Alternate lowercase style on baseline</td>
    <td><span class='charis-cv43-3-R normal'>Ŋŋ</span></td>
  </tr>
</table>

Therefore it is necessary to use other means, such as <a href="#user">user-selectable font features</a>, to ensure that your document displays the right glyph for the character that you are anticipating. Graphite and OpenType provide for this very capability.

See also [How do I use a feature?](http://software.sil.org/lcgfonts/support/faq/#features)

See also [Application Support for features](http://software.sil.org/lcgfonts/support/application-support/).

See also [Webfont Features Demo](http://software.sil.org/charis/support/features-demo/).

### Advanced typographic capabilities

This font supports various advanced typographic capabilities using the Graphite or OpenType font technologies. 

* Automatic conversion of sequences of pitch letters (U+02E5..U+02E9 and U+A712..U+A716) into ligatures. 
* Automatic _fi_-type ligatures. 
* Auto placement of diacritics to a sufficient level of stacking. 
* Auto placement of double-width diacritics (U+035C..U+0362) according to heights and depths of adjacent clusters (in Graphite only) 
* Vietnamese diacritic placement handling (enabled via a user-selectable font feature). 

The automatic placement of diacritics is supported for data that may or may not be canonically ordered (as defined by [The Unicode Standard](http://www.unicode.org/)). This should normally be the responsibility of application software and text-processing resources (such as input methods), however, and not the user.

These capabilities are available in any application that supports the Graphite technology. They are also available via the OpenType technology, though this requires applications that provide a sufficient level of support for OpenType features. (See <a href="http://software.sil.org/charis/support/system-requirements/">System Requirements</a>.) 

### <a name="user"></a>User-selectable font features

This document, [Charis SIL Font Features](/charis/wp-content/uploads/sites/14/2015/11/CharisSIL-features5.000.pdf) can be downloaded in order to see all the user-selectable font features that are available in the font. The feature names, feature ids, settings and examples are provided. The document was produced with <a href="http://www.libreoffice.org/">LibreOffice</a>. 

The User-selectable font features are demonstrated using .woff support on this page: [Charis SIL Features Demo](/charis/features-demo).

***NOTE: The Graphite features in this font are now handled by the CSS support in Firefox 11+.***

### Customizing with TypeTuner

For applications that do not make use of Graphite or the OpenType Stylistic Sets feature, you can now download fonts customized with the variant glyphs you choose. Read the <a href="http://software.sil.org/charis/wp-content/uploads/sites/14/2015/11/CharisSIL-features5.000.pdf">Charis SIL Font Features  guide</a>, visit <a href="http://scripts.sil.org/ttw/fonts2go.cgi">TypeTuner Web</a>, then to choose the variants and download your font.

[top]

[font id='charis-dflt' face='CharisSIL-R' size='140%']
[font id='charis-cv43-1' face='CharisSIL-R' feats='cv43 1, Engs 1' size='140%']
[font id='charis-cv43-2' face='CharisSIL-R' feats='cv43 2, Engs 2' size='140%']
[font id='charis-cv43-3' face='CharisSIL-R' feats='cv43 3, Engs 3' size='140%']
