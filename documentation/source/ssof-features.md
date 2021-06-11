---
title: SIL Fonts - Using Font Features
fontversion: 6.000
---

## Characters and Font Features

Each Unicode character supported by our fonts is typically represented by a single glyph, although that glyph may change depending on what other characters are in the sequence nearby, or may even be combined with other glyphs. There are, however, situations in which a different style or appearance of a glyph is preferred. For example:

- a different typographic style (e.g. small caps)
- text in a particular language (e.g. Serbian)
- a special use (e.g. literacy teaching)
- ornamental purposes (e.g. certain ligatures)

These alternate glyphs can be controlled through the use of **font features**. These are user-selectable features applied to text, and often activated in applications through a font properties menu item, dialog, or style definition. They depend on either [OpenType](https://en.wikipedia.org/wiki/OpenType) or [Graphite](https://graphite.sil.org) technology. A font may include features for either technology—or both.

Features may be activated through:

- a special UI setting (**Properties / OpenType / All Small Caps**)
- by using a feature’s four-letter ID or tag (`'scmp'`, `'ss05'`, `'cv01'` )
- by referring to the feature and setting by name (Uppercase Eng alternates=Large eng on baseline)

## Application support

There is no standard method used by all applications. Every application tends to have a unique way to control features. Applications also differ in which types of features they support. For example, Adobe InDesign supports *stylistic set* features (`ss##`) but offers no easy way to control *character variant* features (`cv##`).

The following sections describe how to activate particular features in individual applications and describe any limits on supported features. **Examples of some features are given, but for details of which fonts support which features see the individual font project documentation.**

### Web browsers

See separate page about [Using SIL Fonts on Web Pages](https://software.sil.org/fonts/webfonts).

### Adobe InDesign (and similar Adobe apps)

Select the text and apply the feature as follows, either using the **OpenType** button (**Properties** palette, **Character** section) or the **OpenType** submenu of the **Character** palette. Some of these settings can also be applied in style definitions.

Alternate glyphs for individual characters can also be chosen by selecting the character and choosing the alternate from the set of choices that appear under the character.

- **Common features:** *Small caps:* **OpenType**, **All Small Caps**.

- **Stylistic sets:** **OpenType**, **Stylistic Sets**, then choose the feature by name.

- **Character variants:** Not supported.

- **Language-specific alternates:** Set the language using the drop-down menu in **Properties** palette, **Character** section. If the language you want is not in that list there may be ways to add support to InDesign, although we have not thoroughly tested them. See this [Adobe blog post and the important updates](https://blog.typekit.com/2011/11/04/how-to-enable-more-languages-in-indesign-cs5-5/).

- **Graphite features:** Not supported.

### LibreOffice

Font features have good support in LibreOffice:

- **Language-specific alternates:** Set the language in **Format / Character / Font**. For more information and alternatives see [(LO Help) Selecting the Document Language](https://help.libreoffice.org/latest/en-GB/text/shared/guide/language_select.html?DbPAR=SHARED#bm_id3083278).

- **Graphite features:** Supported in the UI, including multi-valued features. *Note that if a font supports both OpenType and Graphite, LibreOffice will default to using the Graphite features.*

There are two ways to activate stylistic sets and character variants, and the type and level of support has slight differences.

#### Using the LibreOffice UI

To activate one or more features select the text, go to **Format / Character / Font**, choose the **Features** button, then choose one or more features. These can also be applied when defining a style. *Note, however, that there is no way to control multi-valued OpenType features through the UI. It needs to be set using the font description (see below). This limitation does not apply to Graphite features.*

- **Common features:** Listed with a descriptive name, such as “Lowercase to Small Capitals”. *Warning: using **Format / Character / Font Effects / Case / Small capitals** will not use the proper OpenType or Graphite small caps feature!* 

- **Stylistic sets:** Listed as “Stylistic Set” and the feature ID number, as in “Stylistic Set 01”.

- **Character variants:** Listed as “Character Variant” and the feature ID number, as in “Character Variant 05”.

#### Editing the LibreOffice font description

Features can also be turned on by selecting the text, choosing the font, then adding the specific feature settings at the end of the font name in the font selection box using the feature ID, as in: *fontname:feature=setting*

For example, using the Charis SIL font, the Uppercase Eng alternate “Capital N with tail” would be specified as `Charis SIL:Engs=2`. If you wish to apply two (or more) features, you can separate them with `&amp;`. Thus, `Charis SIL:Engs=2&amp;smcp=1` would apply “Capital N with tail” plus the “Small capitals” feature. 

- **Common features, stylistic sets, character variants:** Use the feature ID, as in `'smcp'`, `'ss01'`, or `'cv05'`.

### Microsoft Word

Support for font features is very limited in Microsoft Word. 

- **Common features:** *Small caps:* Not supported. *Warning: using **Format / Font / Effects / Small caps** will not use the proper OpenType or Graphite feature!* 

- **Stylistic sets:** Select the text and choose **Format / Font / Advanced / Stylistic sets**. Only one set can be specified, and only by number.

- **Character variants:** Not supported.

- **Language-specific alternates:** Select the text and choose **Tools / Language** then set the language. If the preferred language is not listed it may be possible to add some additional languages. See [Microsoft support](https://support.microsoft.com/en-us/office/add-an-editing-or-authoring-language-or-set-language-preferences-in-office-663d9d94-ca99-4a0d-973e-7c4a6b8a827d).

- **Graphite features:** Not supported.

### XeTeX

Font features can be set in XeTeX font specifications in the source document or stylesheet.

- **Common features:** *Small caps:* If using XeLaTeX you can use `^textsc^{small caps text goes here^}` in document text. Otherwise use `+smcp` in the font specification, as in `"Doulos SIL:+smcp"`.

- **Stylistic sets, character variants:** Add `feature=setting` to the font specification using the feature ID, as in `"Charis SIL:cv43=2"`. Multiple features can be added, separated by `;`, as in `"Charis SIL:cv43=2;ss01=1"`.

- **Language-specific alternates:** Add `language=code` to the font specification as in `"Charis SIL:language=VIT"` This can be added to other features settings, as in `"Charis SIL:ss01=1;language=VIT"`. For OpenType the language should be specified using the [OpenType Language System Tag](https://docs.microsoft.com/en-us/typography/opentype/spec/languagetags). For Graphite use the ( NEED SOURCE FOR APPROPRIATE LANGTAG HERE ).

- **Graphite features:** Add `feature=setting` to the font specification. For Graphite features it is also possible to specify the feature and setting by name, as in `"Doulos SIL/GR:Uppercase Eng alternates=Large eng on
baseline"`. To force use of Graphite features it may be necessary to add `/GR` to the font name.

## If your application does not support font features

The only way to control features in applications that support neither OpenType nor Graphite is to create derivative fonts that have the desired behaviors (e.g. alternate glyphs) activated by default. For example, you could have a font called “Gentium Plus UCEng” that is just like Gentium Plus except it normally renders the Eng using the uppercase form. We have created a tool called [TypeTuner Web](https://scripts.sil.org/ttw/fonts2go.cgi) which you can use to create derivative fonts like this based on many of our fonts.

Another good use of [TypeTuner Web](https://scripts.sil.org/ttw/fonts2go.cgi) is to create a small capitals font for use in applications that do not support OpenType small caps (such as Microsoft Word). On TypeTuner Web select the font, choose “Select features”, change the Small Caps setting to “True”, then download and install the font. That will give you a special small capitals font for use in all applications.
 
