---
title: Latin, Cyrillic, and Greek Fonts - Frequently Asked Questions
fontversion: 6.000
---

Here are some of the most frequently asked questions regarding SIL’s Latin, Cyrillic, and Greek fonts. For questions that relate to a specific font please consult the individual font project web site. For general questions about SIL fonts see the [SIL Fonts FAQ](http://software.sil.org/fonts/faq) and [The SIL Open Font License FAQ (OFL-FAQ)](https://scripts.sil.org/OFL-FAQ_web).

#### *Do you supply a keyboard with the fonts?*

No. Our Latin, Cyrillic, and Greek fonts do not include any keyboarding utilities. If you cannot use the built-in keyboards or input methods of the operating system, you will need to install one for the characters of the language you wish to use. SIL’s [Keyman](https://keyman.com/) provides keyboards for over 2000 languages and works on all major desktop and mobile platforms. For information on other keyboarding options see the overview at [Keyboard Systems Overview (ScriptSource)](https://scriptsource.org/entry/ytr8g8n6sw).

#### *How do I type IPA characters?*

To type IPA characters most easily you will need to download and install an IPA keyboard. An excellent IPA keyboard for most desktop and mobile platforms is available from the [Keyman site](https://keyman.com/keyboards/sil_ipa). Other Keyman-based keyboards [are also available](https://keyman.com/keyboards/h/ipa/).

#### *I can’t find the ‘o with right hook’ in the font. Where is it?*

Combinations of base letters with diacritics are often called *composite*, or *pre-composed* glyphs. Our fonts have hundreds of these, mostly ones that are included in Unicode. There are, however, many common combinations that are not represented by a single composite. It is possible to enter these into a document, but only as individual components. So ‘o with right hook’ would be entered as ‘o’, then ‘right hook’. Our Latin, Cyrillic, and Greek fonts include OpenType support that tries to render these combinations well, although we’re not able to anticipate every possible combination.

#### *What OpenType features are in the fonts and how can I use them?*

Most of the OpenType capabilites of the fonts (diacritic positioning, ligature formation) are automatically activated in applications that support OpenType. To find out what user-selectable features are in the fonts see the **Features** page for individual font families (e.g. [Charis SIL font features](https://software.sil.org/charis/features)). For information on controlling OpenType features in specific apps see [Using Font Features](https://software.sil.org/fonts/features). For how to specify OpenType features on web pages see [Using SIL Fonts on Web Pages](https://software.sil.org/fonts/webfonts).

#### *How do I use both a single-story and double-story ‘a’ in italic?*

There is an OpenType feature—*Slant Italic Specials (ss05)*—that provides a double-story ‘a’ in italic. 

#### *Why don’t my diacritics position properly?*

There may be three causes for this:

- No OpenType support. The application you are using does not support OpenType or you are using characters from the [Private Use Area (PUA)](https://scripts.sil.org/PUA_home) in an OpenType application. There is no solution for this situation.

- Formatting errors. If any characters in the sequence are formatted in a different font, or with different settings (size, spacing, color), the application may invisibly break up the text into separate pieces and cause diacritic positioning to fail. The solution is to remove all formatting from the text and reapply any styles or formatting. 

- A font bug. We carefully test the fonts with thousands of sequences to avoid problems, but if you find a combination that does not position properly please contact us so we can improve it in a future version.

#### *Why are some of my diacritics colliding with nearby letters?*

When combined with some narrow glyphs (such as ’i’), wide diacritics (such as the tilde) may collide with adjacent glyphs. In many cases this is not a problem—it is sometimes OK for glyphs to collide. If this causes difficulty with the legibility of the text, then manually space those letters apart in your text using manual kerning or character spacing settings in your application. We do not include kerning for most of these situations as there are many thousands of possible combinations.

#### *Why is the line spacing so much looser that other fonts?*

These fonts include characters with multiple stacked diacritics that need more generous line spacing (for example, U+1EA8 Ẩ). To avoid problems with diacritics that collide with other lines or get cut off we have set the default line spacing greater than in many other fonts.

You may be able to overcome this by adjusting the line spacing in the application. For example, in Microsoft Word select **Format / Paragraph** and set the line spacing to use the **Exactly** setting and a value more suited to your needs. For example, if the font size is 12 pt, select line spacing of **Exactly** 13 pt. This will give a tighter line spacing. You can adjust the value up or down depending on how many diacritics you need to stack. On web pages you can explicitly set the the `line-height` property.

For applications that do not allow explicit line spacing control we provide ‘compact’ variants of the version 5 fonts on individual font download pages.

#### *When I updated to the latest version of the fonts the line spacing and line breaking changed—why?*

Major version updates to the fonts (v4 to v5, v5 to v6) may include changes to some glyph widths and other font metrics, although we try to keep those to a minimum and usually only change rare glyphs. If this causes a problem you may wish to keep using the earlier versions of the fonts. Since new versions also fix bugs and make other improvements it may be better to accept the changes. *If you are archiving documents we strongly suggest that you archive a copy of the fonts with the document to avoid version differences.*

## FAQ for version 5 and earlier fonts

The FAQ from older versions of the fonts remain available at [Latin, Cyrillic, and Greek Fonts - FAQ v5](http://software.sil.org/lcgfonts/faq). **Please understand that the information on that page may be out-of-date, irrelevant, or incorrect for current OSes and applications!** It is only provided as a help to users of older versions.
