---
title: Charis SIL - Font Features
fontversion: 6.101
---

Charis SIL is an OpenType-enabled font family that supports the Latin and Cyrillic scripts. It includes a number of optional features that may be useful or required for particular uses or languages. This document lists all the available features.

These OpenType features are primarily specified using four-letter tags (e.g. 'cv17'), although some applications may provide a direct way to control certain common features such as small caps. For more information on how to access OpenType features in specific environments and applications, see [Using Font Features](http://software.sil.org/fonts/features).

*Please note that Graphite support has been removed in the current release, but continues to be available in the version 5 fonts. See our [Previous Versions archive](http://software.sil.org/charis/download/previous-versions).*

This page uses web fonts (WOFF2) to demonstrate font features and should display correctly in all modern browsers. For a more concise example of how to use Charis SIL as a web font see *CharisSIL-webfont-example.html* in the font package *web* folder. For detailed information see [Using SIL Fonts on Web Pages](http://software.sil.org/fonts/webfonts).

*If this document is not displaying correctly a PDF version is also provided in the documentation/pdf folder of the release package.*

## Complete feature list

### Stylistic alternates

#### Small caps from lowercase

<span class='affects'>Affects: all lowercase letters with capital equivalents</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard   | <span class='charis-R normal'>a ... z</span> (all letters with capital equivalents) | `smcp=0`
Small caps | <span class='charis-R normal' style='font-feature-settings: "smcp" 1'>a ... z</span> (all letters with capital equivalents) | `smcp=1`

#### Small caps from capitals

*This feature is not supported in TypeTuner Web.*

<span class='affects'>Affects: all capitals</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard   | <span class='charis-R normal'>A ... Z</span> (all capitals) | `c2sc=0`
Small caps | <span class='charis-R normal' style='font-feature-settings: "c2sc" 1'>A ... Z</span> (all capitals) | `c2sc=1`

#### Double-story a and g

*This feature was formerly called 'Literacy alternates'.*

<span class='affects'>Affects: U+0061 U+00E0 U+00E1 U+00E2 U+00E3 U+00E4 U+00E5 U+0101 U+0103 U+0105 U+01CE U+01DF U+01E1 U+01FB U+0201 U+0203 U+0227 U+1E01 U+1E9A U+1EA1 U+1EA3 U+1EA5 U+1EA7 U+1EA9 U+1EAB U+1EAD U+1EAF U+1EB1 U+1EB3 U+1EB5 U+1EB7 U+2C65 U+2090 U+1D43 U+0363 U+0067 U+011D U+011F U+0121 U+0123 U+01E7 U+01F5 U+01E5 U+1E21 U+A7A1 U+1D4D</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard     | <span class='charis-R normal'>a à á â ã ä å ā ă ą ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ạ ả ấ ầ ẩ ẫ ậ ắ ằ ẳ ẵ ặ ⱥ ₐ ᵃ ◌ͣ g ĝ ğ ġ ģ ǧ ǵ ǥ ḡ ꞡ ᵍ </span> | `ss01=0`
Single-story | <span class='charis-R normal' style='font-feature-settings: "ss01" 1'>a à á â ã ä å ā ă ą ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ạ ả ấ ầ ẩ ẫ ậ ắ ằ ẳ ẵ ặ ⱥ ₐ ᵃ ◌ͣ g ĝ ğ ġ ģ ǧ ǵ ǥ ḡ ꞡ ᵍ </span> | `ss01=1`

#### Single-story a (only)

<span class='affects'>Affects: U+0061 U+00E0 U+00E1 U+00E2 U+00E3 U+00E4 U+00E5 U+0101 U+0103 U+0105 U+01CE U+01DF U+01E1 U+01FB U+0201 U+0203 U+0227 U+1E01 U+1E9A U+1EA1 U+1EA3 U+1EA5 U+1EA7 U+1EA9 U+1EAB U+1EAD U+1EAF U+1EB1 U+1EB3 U+1EB5 U+1EB7 U+2C65 U+2090 U+1D43 U+0363</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard     | <span class='charis-R normal'>a à á â ã ä å ā ă ą ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ạ ả ấ ầ ẩ ẫ ậ ắ ằ ẳ ẵ ặ ⱥ ₐ ᵃ ◌ͣ </span> | `ss11=0`
Single-story | <span class='charis-R normal' style='font-feature-settings: "ss11" 1'>a à á â ã ä å ā ă ą ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ạ ả ấ ầ ẩ ẫ ậ ắ ằ ẳ ẵ ặ ⱥ ₐ ᵃ ◌ͣ </span> | `ss11=1`

#### Single-story g (only)

<span class='affects'>Affects: U+0067 U+011D U+011F U+0121 U+0123 U+01E7 U+01F5 U+01E5 U+1E21 U+A7A1 U+1D4D</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard     | <span class='charis-R normal'>g ĝ ğ ġ ģ ǧ ǵ ǥ ḡ ꞡ ᵍ </span> | `ss12=0`
Single-story | <span class='charis-R normal' style='font-feature-settings: "ss12" 1'>g ĝ ğ ġ ģ ǧ ǵ ǥ ḡ ꞡ ᵍ </span> | `ss12=1`

#### Barred-bowl forms 

<span class='affects'>Affects: U+0111 U+0180 U+01E5</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard    | <span class='charis-R normal'>đ ƀ ǥ</span> | `ss04=0`
Barred-bowl | <span class='charis-R normal' style='font-feature-settings: "ss04" 1'>đ ƀ ǥ</span> | `ss04=1`

#### Slant italic specials

<span class='affects'>Affects: U+0061 U+00E3 U+00E0 U+00E1 U+00E2 U+00E4 U+00E5 U+0101 U+0103 U+01CE U+01DF U+01E1 U+01FB U+0201 U+0203 U+0227 U+1E01 U+1E9A U+1EA3 U+1EA5 U+1EA7 U+1EA9 U+1EAB U+1EAD U+1EAF U+1EB1 U+1EB3 U+1EB5 U+1EA1 U+1EB7 U+2C65 U+0250 U+00E6 U+0066 U+1E1F U+0069 U+00EC U+00ED U+00EE U+00EF U+0129 U+012B U+012D U+012F U+01D0 U+0209 U+020B U+1E2D U+1E2F U+1EC9 U+1ECB U+0131 U+006C U+013A U+1E37 U+1E39 U+1E3B U+1E3D U+0076 U+1E7D U+1E7F U+007A U+017A U+017C U+017E U+1E91 U+1E93 U+1E95 U+0493 U+04FB U+F327 U+A749 U+A75F U+2097</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard | <span class='charis-I normal'>a ã à á â ä å ā ă ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ả ấ ầ ẩ ẫ ậ ắ ằ ẳ ẵ ạ ặ ⱥ ɐ æ f ḟ i ì í î ï ĩ ī ĭ į ǐ ȉ ȋ ḭ ḯ ỉ ị ı l ĺ ḷ ḹ ḻ ḽ ꝉ ₗ v ṽ ṿ ꝟ z ź ż ž ẑ ẓ ẕ ғ ӻ  fi ffi</span> | `ss05=0`
Slanted  | <span class='charis-I normal' style='font-feature-settings: "ss05" 1'>a ã à á â ä å ā ă ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ả ấ ầ ẩ ẫ ậ ắ ằ ẳ ẵ ạ ặ ⱥ ɐ æ f ḟ i ì í î ï ĩ ī ĭ į ǐ ȉ ȋ ḭ ḯ ỉ ị ı l ĺ ḷ ḹ ḻ ḽ ꝉ ₗ v ṽ ṿ ꝟ z ź ż ž ẑ ẓ ẕ ғ ӻ  fi ffi</span> | `ss05=1`

### Character alternates

#### B hook

<span class='affects'>Affects: U+0181</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard        | <span class='charis-R normal'>Ɓ</span> | `cv13=0`
Lowercase-style | <span class='charis-R normal' style='font-feature-settings: "cv13" 1'>Ɓ</span> | `cv13=1`

#### D hook

<span class='affects'>Affects: U+018A</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard        | <span class='charis-R normal'>Ɗ</span> | `cv17=0`
Lowercase-style | <span class='charis-R normal' style='font-feature-settings: "cv17" 1'>Ɗ</span> | `cv17=1`

#### H stroke

<span class='affects'>Affects: U+0126</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard        | <span class='charis-R normal'>Ħ</span> | `cv28=0`
Vertical stroke | <span class='charis-R normal' style='font-feature-settings: "cv28" 1'>Ħ</span> | `cv28=1`

#### J stroke hook

<span class='affects'>Affects: U+0284</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard  | <span class='charis-R normal'>ʄ</span> | `cv37=0`
Top serif | <span class='charis-R normal' style='font-feature-settings: "cv37" 1'>ʄ</span> | `cv37=1`

#### Eng

<span class='affects'>Affects: U+014A</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard                          | <span class='charis-R normal'>Ŋ</span> | `cv43=0`
Lowercase style on baseline       | <span class='charis-R normal' style='font-feature-settings: "cv43" 1'>Ŋ</span> | `cv43=1`
Uppercase style with descender    | <span class='charis-R normal' style='font-feature-settings: "cv43" 2'>Ŋ</span> | `cv43=2`
Alt. lowercase style on baseline  | <span class='charis-R normal' style='font-feature-settings: "cv43" 3'>Ŋ</span> | `cv43=3`

#### N left hook

<span class='affects'>Affects: U+019D</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard        | <span class='charis-R normal'>Ɲ</span> | `cv44=0`
Lowercase-style | <span class='charis-R normal' style='font-feature-settings: "cv44" 1'>Ɲ</span> | `cv44=1`

#### Open-O

<span class='affects'>Affects: U+0186 U+0254 U+1D10 U+1D53 U+1D97</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard  | <span class='charis-R normal'>Ɔ ɔ ᴐ ᵓ ᶗ</span> | `cv46=0`
Top serif | <span class='charis-R normal' style='font-feature-settings: "cv46" 1'>Ɔ ɔ ᴐ ᵓ ᶗ</span> | `cv46=1`

#### OU

<span class='affects'>Affects: U+0222 U+0223 U+1D3D U+1D15</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard | <span class='charis-R normal'>Ȣ ȣ ᴕ ᴽ</span> | `cv47=0`
Open     | <span class='charis-R normal' style='font-feature-settings: "cv47" 1'>Ȣ ȣ ᴕ ᴽ</span> | `cv47=1`

#### p hook

<span class='affects'>Affects: U+01A5</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard   | <span class='charis-R normal'>ƥ</span> | `cv49=0`
Right hook | <span class='charis-R normal' style='font-feature-settings: "cv49" 1'>ƥ</span> | `cv49=1`

####  R tail

<span class='affects'>Affects: U+2C64</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard        | <span class='charis-R normal'>Ɽ</span> | `cv55=0`
Lowercase-style | <span class='charis-R normal' style='font-feature-settings: "cv55" 1'>Ɽ</span> | `cv55=1`

#### T hook

<span class='affects'>Affects: U+01AC</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard   | <span class='charis-R normal'>Ƭ</span> | `cv57=0`
Right hook | <span class='charis-R normal' style='font-feature-settings: "cv57" 1'>Ƭ</span> | `cv57=1`

#### V hook

<span class='affects'>Affects: U+01B2 U+028B U+1DB9</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard                | <span class='charis-R normal'>Ʋ ʋ ᶹ</span> | `cv62=0`
Straight with low hook  | <span class='charis-R normal' style='font-feature-settings: "cv62" 1'>Ʋ ʋ ᶹ</span> | `cv62=1`
Straight with high hook | <span class='charis-R normal' style='font-feature-settings: "cv62" 2'>Ʋ ʋ ᶹ</span> | `cv62=2`

#### Y hook

<span class='affects'>Affects: U+01B3</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard  | <span class='charis-R normal'>Ƴ</span> | `cv68=0`
Left hook | <span class='charis-R normal' style='font-feature-settings: "cv68" 1'>Ƴ</span> | `cv68=1`

#### Ezh

<span class='affects'>Affects: U+01B7 U+04E0</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard       | <span class='charis-R normal'>Ʒ Ӡ</span> | `cv20=0`
Reversed sigma | <span class='charis-R normal' style='font-feature-settings: "cv20" 1'>Ʒ Ӡ</span> | `cv20=1`

#### ezh curl

<span class='affects'>Affects: U+0293</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard   | <span class='charis-R normal'>ʓ</span> | `cv19=0`
Large bowl | <span class='charis-R normal' style='font-feature-settings: "cv19" 1'>ʓ</span> | `cv19=1`

#### rams horn

<span class='affects'>Affects: U+0264</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard    | <span class='charis-R normal'>ɤ</span> | `cv25=0`
Large bowl  | <span class='charis-R normal' style='font-feature-settings: "cv25" 1'>ɤ</span> | `cv25=1`
Small gamma | <span class='charis-R normal' style='font-feature-settings: "cv25" 2'>ɤ</span> | `cv25=2`

### Diacritic and symbol alternates

#### Vietnamese-style diacritics

<span class='affects'>Affects: U+1EA4 U+1EA5 U+1EA6 U+1EA7 U+1EA8 U+1EA9 U+1EAA U+1EAB U+1EAE U+1EAF U+1EB0 U+1EB1 U+1EB2 U+1EB3 U+1EB4 U+1EB5 U+1EBE U+1EBF U+1EC0 U+1EC1 U+1EC2 U+1EC3 U+1EC4 U+1EC5 U+1ED0 U+1ED1 U+1ED2 U+1ED3 U+1ED4 U+1ED5 U+1ED6 U+1ED7</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard         | <span class='charis-R normal'>Ấấ Ầầ Ẩẩ Ẫẫ Ắắ Ằằ Ẳẳ Ẵẵ Ếế Ềề Ểể Ễễ Ốố Ồồ Ổổ Ỗỗ</span> | `cv75=0`
Vietnamese-style | <span class='charis-R normal' style='font-feature-settings: "cv75" 1'>Ấấ Ầầ Ẩẩ Ẫẫ Ắắ Ằằ Ẳẳ Ẵẵ Ếế Ềề Ểể Ễễ Ốố Ồồ Ổổ Ỗỗ</span> | `cv75=1`

#### Kayan diacritics

*This feature is not supported in TypeTuner Web.*

<span class='affects'>Affects: U+0300 U+0301</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard     | <span class='charis-R normal'>◌̀́</span> | `cv79=0`
Side by side | <span class='charis-R normal' style='font-feature-settings: "cv79" 1'>◌̀́</span> | `cv79=1`

#### Ogonek

<span class='affects'>Affects: U+0328 U+0104 U+0105 U+0118 U+0119 U+012E U+012F U+0172 U+0173 U+01EA U+01EB U+01EC U+01ED</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard | <span class='charis-R normal'>anything with ◌̨ (Ąą Ęę Įį Ųų Ǫǫ Ǭǭ)</span> | `cv76=0`
Straight | <span class='charis-R normal' style='font-feature-settings: "cv76" 1'>anything with ◌̨ (Ąą Ęę Įį Ųų Ǫǫ Ǭǭ)</span> | `cv76=1`

#### Caron

<span class='affects'>Affects: U+010F U+013D U+013E U+0165</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard     | <span class='charis-R normal'>ď Ľ ľ ť</span> | `cv77=0`
Global-style | <span class='charis-R normal' style='font-feature-settings: "cv77" 1'>ď Ľ ľ ť</span> | `cv77=1`

#### Modifier apostrophe

<span class='affects'>Affects: U+02BC U+A78B U+A78C</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard | <span class='charis-R normal'>ʼ Ꞌ ꞌ</span> | `cv70=0`
Large    | <span class='charis-R normal' style='font-feature-settings: "cv70" 1'>ʼ Ꞌ ꞌ</span> | `cv70=1`

#### Modifier colon

<span class='affects'>Affects: U+A789</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard | <span class='charis-R normal'>꞉</span> | `cv71=0`
Expanded | <span class='charis-R normal' style='font-feature-settings: "cv71" 1'>꞉</span> | `cv71=1`

#### Empty set

<span class='affects'>Affects: U+2205</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard   | <span class='charis-R normal'>∅</span> | `cv98=0`
Zero-style | <span class='charis-R normal' style='font-feature-settings: "cv98" 1'>∅</span> | `cv98=1`

### Cyrillic alternates

*There are also Cyrillic characters affected by the “Ezh” and “Small capitals” features. Some languages may also use the “Modifier apostrophe”.*

#### Cyrillic E

<span class='affects'>Affects: U+042D U+044D</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard        | <span class='charis-R normal'>Э э</span> | `cv80=0`
Mongolian-style | <span class='charis-R normal' style='font-feature-settings: "cv80" 1'>Э э</span> | `cv80=1`

#### Cyrillic shha

<span class='affects'>Affects: U+04BB</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard        | <span class='charis-R normal'>һ</span> | `cv81=0`
Uppercase-style | <span class='charis-R normal' style='font-feature-settings: "cv81" 1'>һ</span> | `cv81=1`

#### Cyrillic breve

<span class='affects'>Affects: U+0306</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard       | <span class='charis-R normal'>anything with ◌̆ (Ә̆ә̆)</span> | `cv82=0`
Cyrillic-style | <span class='charis-R normal' style='font-feature-settings: "cv82" 1'>anything with ◌̆ (Ә̆ә̆)</span> | `cv82=1`

#### Serbian Cyrillic alternates

*These alternate forms mainly affect italic styles. Unlike other features this is activated by tagging the span of text as being in the Serbian language, not by turning on an OpenType feature. It is also not available through TypeTuner Web although a similar feature is supported (cv84).*

<span class='affects'>Affects: U+0431 U+0433 U+0434 U+043F U+0442 U+0453</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard | <span class='charis-I normal'>б г д п т ѓ</span> | 
Serbian  | <span class='charis-I normal' lang='sr'>б г д п т ѓ</span> | `lang='sr'`

#### Macedonian Cyrillic alternates

*These alternate forms mainly affect italic styles. Unlike other features this is activated by tagging the span of text as being in the Macedonian language, not by turning on an OpenType feature. It is also not available through TypeTuner Web although a similar feature is supported (cv84).*

<span class='affects'>Affects: U+0431 U+0433 U+0434 U+043F U+0442 U+0453</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard   | <span class='charis-I normal'>б г д п т ѓ</span> | 
Macedonian | <span class='charis-I normal' lang='mk'>б г д п т ѓ</span> | `lang='mk'`

#### Serbian and Macedonian Cyrillic alternates

*This feature provides an alternate way to activate the Serbian and Macedonian forms in applications that do not support language-specific features.*

<span class='affects'>Affects: U+0431 U+0433 U+0434 U+043F U+0442 U+0453</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard                 | <span class='charis-I normal'>б г д п т ѓ</span> | `cv84=0`
Serbian Macedonian forms | <span class='charis-I normal' style='font-feature-settings: "cv84" 1'>б г д п т ѓ</span> | `cv84=1`

### Tone alternates

#### Chinantec tones

<span class='affects'>Affects: U+02CB U+02C8 U+02C9 U+02CA</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard        | <span class='charis-R normal'>ˋ ˈ ˉ ˊ</span> | `cv90=0`
Chinantec-style | <span class='charis-R normal' style='font-feature-settings: "cv90" 1'>ˋ ˈ ˉ ˊ</span> | `cv90=1`

#### Tone numbers

*This feature is not supported in TypeTuner Web.*

<span class='affects'>Affects: U+02E5 U+02E6 U+02E7 U+02E8 U+02E9 U+A712 U+A713 U+A714 U+A715 U+A716</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard | <span class='charis-R normal'>˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖</span> | `cv91=0`
Numbers  | <span class='charis-R normal' style='font-feature-settings: "cv91" 1'>˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖</span> | `cv91=1`

#### Hide tone contour staves

*This feature is not supported in TypeTuner Web.*

<span class='affects'>Affects: U+02E5 U+02E6 U+02E7 U+02E8 U+02E9 U+A712 U+A713 U+A714 U+A715 U+A716</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard | <span class='charis-R normal'>˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖ (˩˦˥˧˨ ꜖꜓꜒꜔꜕)</span> | `cv92=0`
Hide staves  | <span class='charis-R normal' style='font-feature-settings: "cv92" 1'>˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖ (˩˦˥˧˨ ꜖꜓꜒꜔꜕)</span> | `cv92=1`

<!-- PRODUCT SITE ONLY
[font id='charis' face='CharisSIL-Regular' italic='CharisSIL-Italic' bold='CharisSIL-Bold' bolditalic='CharisSIL-BoldItalic' size='150%']
-->
