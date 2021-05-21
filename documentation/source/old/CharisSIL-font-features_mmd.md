---
fontitalic: CharisSIL-I
fontversion: 5.960 beta2
header-includes:
- |
  ```{=latex}
  %\rowcolors{0}{gray!10}{gray!25}
  ```
testfont: CharisSIL-R
title: Charis SIL Font Features
---

```{=latex}
%\rowcolors{0}{gray!10}{gray!25}
```

Charis SIL is an OpenType-enabled font family that supports the Latin
and Cyrillic scripts. It includes a number of optional features that may
be useful or required for particular uses or languages. These OpenType
features are primarily specified using four-letter tags (e.g. \'cv17\'),
although some applications may provide a direct way to control certain
common features such as small caps. This document lists all the
available features.

This page uses web fonts (WOFF2) to demonstrate font features and should
display correctly in all modern browsers. For a more concise example of
how to use Charis SIL as a web font see [Charis SIL Webfont
Example](../web/CharisSIL-webfont-example.html). See [Using SIL Fonts on
Web Pages: OpenType and Graphite feature
support](http://scripts.sil.org/using_web_fonts#feat) for more
information.

*If this document is not displaying correctly a PDF version is also
provided.*

## Complete feature list

### Stylistic alternates

#### Small caps from lowercase

[Affects: all lowercase letters with capital equivalents]{.affects}

  Feature      Sample                                                            Feature setting
  ------------ ----------------------------------------------------------------- -----------------
  Standard     [a \... z]{feats=""} (all letters with capital equivalents)       `smcp=0`
  Small caps   [a \... z]{feats="smcp"} (all letters with capital equivalents)   `smcp=1`

#### Small caps from capitals

[Affects: all capitals]{.affects}

  Feature      Sample                                    Feature setting
  ------------ ----------------------------------------- -----------------
  Standard     [A \... Z]{feats=""} (all capitals)       `c2sc=0`
  Small caps   [A \... Z]{feats="c2sc"} (all capitals)   `c2sc=1`

#### Literacy a and g

[Affects: U+0061 U+00E0 U+00E1 U+00E2 U+00E3 U+00E4 U+00E5 U+0101 U+0103
U+0105 U+01CE U+01DF U+01E1 U+01FB U+0201 U+0203 U+0227 U+1E01 U+1E9A
U+1EA1 U+1EA3 U+1EA5 U+1EA7 U+1EA9 U+1EAB U+1EAD U+1EAF U+1EB1 U+1EB3
U+1EB5 U+1EB7 U+2C65 U+2090 U+1D43 U+0363 U+0067 U+011D U+011F U+0121
U+0123 U+01E7 U+01F5 U+01E5 U+1E21 U+A7A1 U+1D4D]{.affects}

::: {nobreak="true"}
  --------------------------------------------------------------------------
  Feature        Sample                                         Feature
                                                                setting
  -------------- ---------------------------------------------- ------------
  Standard       [a à á â ã ä å ā ă ą ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ạ ả ấ ầ `ss01=0`
                 ẩ ẫ ậ ắ ằ ẳ ẵ ặ ⱥ ₐ ᵃ ◌ͣ g ĝ ğ ġ ģ ǧ ǵ ǥ ḡ ꞡ ᵍ  
                 ]{feats=""}                                    

  Single-story   [a à á â ã ä å ā ă ą ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ạ ả ấ ầ `ss01=1`
                 ẩ ẫ ậ ắ ằ ẳ ẵ ặ ⱥ ₐ ᵃ ◌ͣ g ĝ ğ ġ ģ ǧ ǵ ǥ ḡ ꞡ ᵍ  
                 ]{feats="ss01"}                                
  --------------------------------------------------------------------------
:::

#### Literacy a (only)

[Affects: U+0061 U+00E0 U+00E1 U+00E2 U+00E3 U+00E4 U+00E5 U+0101 U+0103
U+0105 U+01CE U+01DF U+01E1 U+01FB U+0201 U+0203 U+0227 U+1E01 U+1E9A
U+1EA1 U+1EA3 U+1EA5 U+1EA7 U+1EA9 U+1EAB U+1EAD U+1EAF U+1EB1 U+1EB3
U+1EB5 U+1EB7 U+2C65 U+2090 U+1D43 U+0363]{.affects}

  --------------------------------------------------------------------------
  Feature        Sample                                         Feature
                                                                setting
  -------------- ---------------------------------------------- ------------
  Standard       [a à á â ã ä å ā ă ą ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ạ ả ấ ầ `ss11=0`
                 ẩ ẫ ậ ắ ằ ẳ ẵ ặ ⱥ ₐ ᵃ ◌ͣ ]{feats=""}            

  Single-story   [a à á â ã ä å ā ă ą ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ạ ả ấ ầ `ss11=1`
                 ẩ ẫ ậ ắ ằ ẳ ẵ ặ ⱥ ₐ ᵃ ◌ͣ ]{feats="ss11"}        
  --------------------------------------------------------------------------

#### Literacy g (only)

[Affects: U+0067 U+011D U+011F U+0121 U+0123 U+01E7 U+01F5 U+01E5 U+1E21
U+A7A1 U+1D4D]{.affects}

  Feature        Sample                                   Feature setting
  -------------- ---------------------------------------- -----------------
  Standard       [g ĝ ğ ġ ģ ǧ ǵ ǥ ḡ ꞡ ᵍ ]{feats=""}       `ss12=0`
  Single-story   [g ĝ ğ ġ ģ ǧ ǵ ǥ ḡ ꞡ ᵍ ]{feats="ss12"}   `ss12=1`

#### Barred-bowl forms

[Affects: U+0111 U+0180 U+01E5]{.affects}

  Feature       Sample                  Feature setting
  ------------- ----------------------- -----------------
  Standard      [đ ƀ ǥ]{feats=""}       `ss04=0`
  Barred-bowl   [đ ƀ ǥ]{feats="ss04"}   `ss04=1`

#### Slant italic specials

[Affects: U+0061 U+00E3 U+00E0 U+00E1 U+00E2 U+00E4 U+00E5 U+0101 U+0103
U+01CE U+01DF U+01E1 U+01FB U+0201 U+0203 U+0227 U+1E01 U+1E9A U+1EA3
U+1EA5 U+1EA7 U+1EA9 U+1EAB U+1EAD U+1EAF U+1EB1 U+1EB3 U+1EB5 U+1EA1
U+1EB7 U+2C65 U+0250 U+00E6 U+0066 U+1E1F U+0069 U+00EC U+00ED U+00EE
U+00EF U+0129 U+012B U+012D U+012F U+01D0 U+0209 U+020B U+1E2D U+1E2F
U+1EC9 U+1ECB U+0131 U+006C U+013A U+1E37 U+1E39 U+1E3B U+1E3D U+0076
U+1E7D U+1E7F U+007A U+017A U+017C U+017E U+1E91 U+1E93 U+1E95 U+0493
U+04FB U+F327 U+A749 U+A75F U+2097]{.affects}

  ------------------------------------------------------------------------
  Feature      Sample                                         Feature
                                                              setting
  ------------ ---------------------------------------------- ------------
  Standard     [a ã à á â ä å ā ă ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ả ấ ầ ẩ ẫ `ss05=0`
               ậ ắ ằ ẳ ẵ ạ ặ ⱥ ɐ æ f ḟ i ì í î ï ĩ ī ĭ į ǐ ȉ  
               ȋ ḭ ḯ ỉ ị ı l ĺ ḷ ḹ ḻ ḽ ꝉ ₗ v ṽ ṿ ꝟ z ź ż ž ẑ  
               ẓ ẕ ғ ӻ  fi ffi]{font="$fontitalic"}         

  Slanted      [a ã à á â ä å ā ă ǎ ǟ ǡ ǻ ȁ ȃ ȧ ḁ ẚ ả ấ ầ ẩ ẫ `ss05=1`
               ậ ắ ằ ẳ ẵ ạ ặ ⱥ ɐ æ f ḟ i ì í î ï ĩ ī ĭ į ǐ ȉ  
               ȋ ḭ ḯ ỉ ị ı l ĺ ḷ ḹ ḻ ḽ ꝉ ₗ v ṽ ṿ ꝟ z ź ż ž ẑ  
               ẓ ẕ ғ ӻ  fi ffi]{font="$fontitalic"          
               feats="ss05"}                                  
  ------------------------------------------------------------------------

### Character alternates

#### B hook

[Affects: U+0181]{.affects}

  Feature           Sample                Feature setting
  ----------------- --------------------- -----------------
  Standard          [Ɓ]{feats=""}         `cv13=0`
  Lowercase-style   [Ɓ]{feats="cv13=1"}   `cv13=1`

#### D hook

[Affects: U+018A]{.affects}

  Feature           Sample                Feature setting
  ----------------- --------------------- -----------------
  Standard          [Ɗ]{feats=""}         `cv17=0`
  Lowercase-style   [Ɗ]{feats="cv17=1"}   `cv17=1`

#### H stroke

[Affects: U+0126]{.affects}

  Feature           Sample                Feature setting
  ----------------- --------------------- -----------------
  Standard          [Ħ]{feats=""}         `cv28=0`
  Vertical stroke   [Ħ]{feats="cv28=1"}   `cv28=1`

#### J stroke hook

[Affects: U+0284]{.affects}

  Feature     Sample                Feature setting
  ----------- --------------------- -----------------
  Standard    [ʄ]{feats=""}         `cv37=0`
  Top serif   [ʄ]{feats="cv37=1"}   `cv37=1`

#### Eng

[Affects: U+014A]{.affects}

  Feature                            Sample                Feature setting
  ---------------------------------- --------------------- -----------------
  Standard                           [Ŋ]{feats=""}         `cv43=0`
  Lowercase style on baseline        [Ŋ]{feats="cv43=1"}   `cv43=1`
  Uppercase style with descender     [Ŋ]{feats="cv43=2"}   `cv43=2`
  Alt. lowercase style on baseline   [Ŋ]{feats="cv43=3"}   `cv43=3`

#### N left hook

[Affects: U+019D]{.affects}

  Feature           Sample              Feature setting
  ----------------- ------------------- -----------------
  Standard          [Ɲ]{feats=""}       `cv44=0`
  Lowercase-style   [Ɲ]{feats="cv44"}   `cv44=1`

#### Open-O

[Affects: U+0186 U+0254 U+1D10 U+1D53 U+1D97]{.affects}

  Feature     Sample                      Feature setting
  ----------- --------------------------- -----------------
  Standard    [Ɔ ɔ ᴐ ᵓ ᶗ]{feats=""}       `cv46=0`
  Top serif   [Ɔ ɔ ᴐ ᵓ ᶗ]{feats="cv46"}   `cv46=1`

#### OU

[Affects: U+0222 U+0223 U+1D3D U+1D15]{.affects}

  Feature    Sample                    Feature setting
  ---------- ------------------------- -----------------
  Standard   [Ȣ ȣ ᴕ ᴽ]{feats=""}       `cv47=0`
  Open       [Ȣ ȣ ᴕ ᴽ]{feats="cv47"}   `cv47=1`

#### p hook

[Affects: U+01A5]{.affects}

  Feature      Sample              Feature setting
  ------------ ------------------- -----------------
  Standard     [ƥ]{feats=""}       `cv49=0`
  Right hook   [ƥ]{feats="cv49"}   `cv49=1`

#### R tail

[Affects: U+2C64]{.affects}

  Feature           Sample              Feature setting
  ----------------- ------------------- -----------------
  Standard          [Ɽ]{feats=""}       `cv55=0`
  Lowercase-style   [Ɽ]{feats="cv55"}   `cv55=1`

#### T hook

[Affects: U+01AC]{.affects}

  Feature      Sample              Feature setting
  ------------ ------------------- -----------------
  Standard     [Ƭ]{feats=""}       `cv57=0`
  Right hook   [Ƭ]{feats="cv57"}   `cv57=1`

#### V hook

[Affects: U+01B2 U+028B U+1DB9]{.affects}

  Feature                   Sample                  Feature setting
  ------------------------- ----------------------- -----------------
  Standard                  [Ʋ ʋ ᶹ]{feats=""}       `cv62=0`
  Straight with low hook    [Ʋ ʋ ᶹ]{feats="cv62"}   `cv62=1`
  Straight with high hook   [Ʋ ʋ ᶹ]{feats="cv62"}   `cv62=2`

#### Y hook

[Affects: U+01B3]{.affects}

  Feature     Sample              Feature setting
  ----------- ------------------- -----------------
  Standard    [Ƴ]{feats=""}       `cv68=0`
  Left hook   [Ƴ]{feats="cv68"}   `cv68=1`

#### Ezh

[Affects: U+01B7 U+04E0]{.affects}

  Feature          Sample                Feature setting
  ---------------- --------------------- -----------------
  Standard         [Ʒ Ӡ]{feats=""}       `cv20=0`
  Reversed sigma   [Ʒ Ӡ]{feats="cv20"}   `cv20=1`

#### ezh curl

[Affects: U+0293]{.affects}

  Feature      Sample              Feature setting
  ------------ ------------------- -----------------
  Standard     [ʓ]{feats=""}       `cv19=0`
  Large bowl   [ʓ]{feats="cv19"}   `cv19=1`

#### rams horn

[Affects: U+0264]{.affects}

  Feature       Sample              Feature setting
  ------------- ------------------- -----------------
  Standard      [ɤ]{feats=""}       `cv25=0`
  Large bowl    [ɤ]{feats="cv25"}   `cv25=1`
  Small gamma   [ɤ]{feats="cv25"}   `cv25=2`

### Diacritic and symbol alternates

#### Vietnamese-style diacritics

[Affects: U+1EA4 U+1EA5 U+1EA6 U+1EA7 U+1EA8 U+1EA9 U+1EAA U+1EAB U+1EAE
U+1EAF U+1EB0 U+1EB1 U+1EB2 U+1EB3 U+1EB4 U+1EB5 U+1EBE U+1EBF U+1EC0
U+1EC1 U+1EC2 U+1EC3 U+1EC4 U+1EC5 U+1ED0 U+1ED1 U+1ED2 U+1ED3 U+1ED4
U+1ED5 U+1ED6 U+1ED7]{.affects}

  Feature            Sample                                                            Feature setting
  ------------------ ----------------------------------------------------------------- -----------------
  Standard           [Ấấ Ầầ Ẩẩ Ẫẫ Ắắ Ằằ Ẳẳ Ẵẵ Ếế Ềề Ểể Ễễ Ốố Ồồ Ổổ Ỗỗ]{feats=""}       `cv75=0`
  Vietnamese-style   [Ấấ Ầầ Ẩẩ Ẫẫ Ắắ Ằằ Ẳẳ Ẵẵ Ếế Ềề Ểể Ễễ Ốố Ồồ Ổổ Ỗỗ]{feats="cv75"}   `cv75=1`

#### Kayan diacritics

[Affects: U+0300 U+0301]{.affects}

  Feature        Sample              Feature setting
  -------------- ------------------- -----------------
  Standard       [◌̀́]{feats=""}       `cv79=0`
  Side by side   [◌̀́]{feats="cv79"}   `cv79=1`

#### Ogonek

[Affects: U+0328 U+0104 U+0105 U+0118 U+0119 U+012E U+012F U+0172 U+0173
U+01EA U+01EB U+01EC U+01ED]{.affects}

  Feature    Sample                                                Feature setting
  ---------- ----------------------------------------------------- -----------------
  Standard   [anything with ◌̨ (Ąą Ęę Įį Ųų Ǫǫ Ǭǭ)]{feats=""}       `cv76=0`
  Straight   [anything with ◌̨ (Ąą Ęę Įį Ųų Ǫǫ Ǭǭ)]{feats="cv76"}   `cv76=1`

#### Caron

[Affects: U+010F U+013D U+013E U+0165]{.affects}

  Feature        Sample                    Feature setting
  -------------- ------------------------- -----------------
  Standard       [ď Ľ ľ ť]{feats=""}       `cv77=0`
  Global-style   [ď Ľ ľ ť]{feats="cv77"}   `cv77=1`

#### Modifier apostrophe

[Affects: U+02BC U+A78B U+A78C]{.affects}

  Feature    Sample                  Feature setting
  ---------- ----------------------- -----------------
  Standard   [ʼ Ꞌ ꞌ]{feats=""}       `cv70=0`
  Large      [ʼ Ꞌ ꞌ]{feats="cv70"}   `cv70=1`

#### Modifier colon

[Affects: U+A789]{.affects}

  Feature    Sample              Feature setting
  ---------- ------------------- -----------------
  Standard   [꞉]{feats=""}       `cv71=0`
  Expanded   [꞉]{feats="cv71"}   `cv71=1`

#### Empty set

[Affects: U+2205]{.affects}

  Feature      Sample              Feature setting
  ------------ ------------------- -----------------
  Standard     [∅]{feats=""}       `cv98=0`
  Zero-style   [∅]{feats="cv98"}   `cv98=1`

### Cyrillic alternates

*There are also Cyrillic characters affected by the "Ezh" and "Small
capitals" features. Some languages may also use the "Modifier
apostrophe".*

#### Cyrillic E

[Affects: U+042D U+044D]{.affects}

  Feature           Sample                Feature setting
  ----------------- --------------------- -----------------
  Standard          [Э э]{feats=""}       `cv80=0`
  Mongolian-style   [Э э]{feats="cv80"}   `cv80=1`

#### Cyrillic shha

[Affects: U+04BB]{.affects}

  Feature           Sample              Feature setting
  ----------------- ------------------- -----------------
  Standard          [һ]{feats=""}       `cv81=0`
  Uppercase-style   [һ]{feats="cv81"}   `cv81=1`

#### Cyrillic breve

[Affects: U+0306]{.affects}

  Feature          Sample                                 Feature setting
  ---------------- -------------------------------------- -----------------
  Standard         [anything with ◌̆ (Ә̆ә̆)]{feats=""}       `cv82=0`
  Cyrillic-style   [anything with ◌̆ (Ә̆ә̆)]{feats="cv82"}   `cv82=1`

#### Serbian Cyrillic alternates

*These alternate forms mainly affect italic styles. Unlike other
features this is activated by tagging the span of text as being in the
Serbian language, not by turning on an OpenType feature.*

[Affects: U+0431 U+0433 U+0434 U+043F U+0442]{.affects}

  Feature    Sample                                      Feature setting
  ---------- ------------------------------------------- -----------------
  Standard   [б г д п т]{font="$fontitalic"}             
  Serbian    [б г д п т]{font="$fontitalic" lang="sr"}   `lang='sr'`

### Tone alternates

#### Chinantec tones

[Affects: U+02CB U+02C8 U+02C9 U+02CA]{.affects}

  Feature           Sample                    Feature setting
  ----------------- ------------------------- -----------------
  Standard          [ˋ ˈ ˉ ˊ]{feats=""}       `cv90=0`
  Chinantec-style   [ˋ ˈ ˉ ˊ]{feats="cv90"}   `cv90=1`

#### Tone numbers

[Affects: U+02E5 U+02E6 U+02E7 U+02E8 U+02E9 U+A712 U+A713 U+A714 U+A715
U+A716]{.affects}

  Feature    Sample                                Feature setting
  ---------- ------------------------------------- -----------------
  Standard   [˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖]{feats=""}       `cv91=0`
  Numbers    [˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖]{feats="cv91"}   `cv91=1`

```{=html}
<!-- Not currently working
#### Hide tone contour staves

<span class='affects'>Affects: U+02E5 U+02E6 U+02E7 U+02E8 U+02E9 U+A712 U+A713 U+A714 U+A715 U+A716</span>

Feature | Sample                      | Feature setting
------- | --------------------------- | -------
Standard | <span feats="">˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖ (˩˦˥˧˨ ꜖꜓꜒꜔꜕)</span> | `cv92=0`
Numbers  | <span feats='cv92'>˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖ (˩˦˥˧˨ ꜖꜓꜒꜔꜕)</span> | `cv92=1`
-->
```
