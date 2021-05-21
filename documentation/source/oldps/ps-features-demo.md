Charis SIL is an OpenType and Graphite-enabled font that supports the Latin and Cyrillic scripts. This page demonstrates the use of Web Open Font Format (.WOFF) fonts using Charis SIL on a web page. A PDF showing the correct rendering -- that is, what this page <em>should</em> look like -- can be seen [here](/charis/wp-content/uploads/sites/14/2017/05/Features-demo-using-.WOFF-fonts_Charis-SIL.pdf).

The Charis SIL font includes a number of optional features that provide alternative rendering that might be preferable for use in some contexts. The sections below enumerate the details of these features. Whether these features are available to users will depend on both the application and the rendering technology ([Graphite](http://graphite.sil.org/) or OpenType) being used. Most features are available in both Graphite and OpenType, though there may be minor differences in their implementation.

In [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/products/), with either Graphite or OpenType rendering, features can be accessed using the appropriate CSS markup. See [Using SIL Fonts on Web Pages: OpenType and Graphite feature support](http://scripts.sil.org/using_web_fonts#feat) (the technique described there works for both Graphite and OpenType).

[Chrome](https://www.google.com/chrome/browser/desktop/) and [Safari](https://support.apple.com/downloads/safari) use OpenType rendering and features can be accessed using the appropriate CSS markup. 

[Internet Explorer](https://support.microsoft.com/en-us/help/17621/internet-explorer-downloads)/[Edge](https://www.microsoft.com/en-us/windows/microsoft-edge?FORM=MM13KD&amp;OCID=MM13KD&amp;wt.mc_id=MM13KD#AMRW31IudoH9lreo.97) do not consistently render the features in Charis SIL properly. 

## Language specific

### Vietnamese-style diacritics

Affects: U+1EA4 U+1EA5 U+1EA6 U+1EA7 U+1EA8 U+1EA9 U+1EAA U+1EAB U+1EAE U+1EAF U+1EB0 U+1EB1 U+1EB2 U+1EB3 U+1EB4 U+1EB5 U+1EBE U+1EBF U+1EC0 U+1EC1 U+1EC2 U+1EC3 U+1EC4 U+1EC5 U+1ED0 U+1ED1 U+1ED2 U+1ED3 U+1ED4 U+1ED5 U+1ED6 U+1ED7

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>Ấấ Ầầ Ẩẩ Ẫẫ Ắắ Ằằ Ẳẳ Ẵẵ Ếế Ềề Ểể Ễễ Ốố Ồồ Ổổ Ỗỗ</span>| G,O,T | cv75=0 | viet=0
Vietnamese-style | <span class='charis-cv75-R normal'>Ấấ Ầầ Ẩẩ Ẫẫ Ắắ Ằằ Ẳẳ Ẵẵ Ếế Ềề Ểể Ễễ Ốố Ồồ Ổổ Ỗỗ</span>| G,O,T | cv75=1 | viet=1

### Serbian-style alternates

Affects: U+0431 U+0433 U+0434 U+043F U+0442

*Primary differences will be visible for italic faces.*

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-I normal'>Бб Гг Дд Пп Тт</span>| G,O,T |  | serb=0
True | <span class='charis-serb-I normal' lang='srb'>Бб Гг Дд Пп Тт</span>| G,O,T | lang='srb' | serb=1


### Chinantec tones

Affects: U+02CB U+02C8 U+02C9 U+02CA

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>ˋ ˈ ˉ ˊ</span>| G,O,T | cv90=0 | chtn=0
Chinantec-style | <span class='charis-cv90-R normal'>ˋ ˈ ˉ ˊ</span>| G,O,T | cv90=1 | chtn=1

## Cyrillic²

### Mongolian-style Cyrillic E

Affects: U+042D U+044D

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>Ээ</span>| G,O,T | cv80=0 | mone=0
Mongolian-style | <span class='charis-cv80-R normal'>Ээ</span>| G,O,T | cv80=1 | mone=1

### Combining breve Cyrillic form

Affects: U+0306

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>anything with ◌̆ (Ә̆ә̆)</span>| G,O,T | cv82=0 | sbrv=0
Cyrillic-style | <span class='charis-cv82-R normal'>anything with ◌̆ (Ә̆ә̆)</span>| G,O,T | cv82=1 | sbrv=1

### Cyrillic shha alternate

Affects: U+04BB

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>Һһ</span>| G,O,T | cv81=0 | shha=0
Uppercase style | <span class='charis-cv81-R normal'>Һһ</span>| G,O,T | cv81=1 | shha=1

## Tone-related

### Tone numbers

Affects: U+02E5 U+02E6 U+02E7 U+02E8 U+02E9 U+A712 U+A713 U+A714 U+A715 U+A716

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Bars | <span class='charis-dflt-R normal'>˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖</span>| G,O,T | cv91=0 | tone=0
Numbers | <span class='charis-cv91-R normal'>˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖</span>| G,O,T | cv91=1 | tone=1

### Hide tone contour staves

Affects: U+02E5 U+02E6 U+02E7 U+02E8 U+02E9 U+A712 U+A713 U+A714 U+A715 U+A716

*Does not seem to be working in OpenType implementations.*

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖ (˩˦˥˧˨ ꜖꜓꜒꜔꜕)</span>| G,O,T | cv92=0 | tstv=0
True | <span class='charis-cv92-R normal'>˥ ˦ ˧ ˨ ˩ ꜒ ꜓ ꜔ ꜕ ꜖ (˩˦˥˧˨ ꜖꜓꜒꜔꜕)</span>| G,O,T | cv92=1 | tstv=1

## Miscellaneous

### Literacy alternates 

Affects: U+0061 U+00E0 U+00E1 U+00E2 U+00E3 U+00E4 U+00E5 U+0101 U+0103 U+0105 U+01CE U+01DF U+01E1 U+01FB U+0201 U+0203 U+0227 U+1E01 U+1E9A U+1EA1 U+1EA3 U+1EA5 U+1EA7 U+1EA9 U+1EAB U+1EAD U+1EAF U+1EB1 U+1EB3 U+1EB5 U+1EB7 U+2C65 U+2090 U+1D43 U+0363 U+0067 U+011D U+011F U+0121 U+0123 U+01E7 U+01F5 U+01E5 U+1E21 U+A7A1 U+1D4D

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>Aa Àà Áá Ââ Ãã Ää Åå Āā Ăă Ąą Ǎǎ Ǟǟ Ǡǡ Ǻǻ Ȁȁ Ȃȃ Ȧȧ Ḁḁ ẚ Ạạ Ảả Ấấ Ầầ Ẩẩ Ẫẫ Ậậ Ắắ Ằằ Ẳẳ Ẵẵ Ặặ Ⱥⱥ ₐ ᵃ ◌ͣ Gg Ĝĝ Ğğ Ġġ Ģģ Ǧǧ Ǵǵ Ǥǥ Ḡḡ Ꞡꞡ ᵍ </span>| G,O,T | ss01=0 | litr=0
True | <span class='charis-ss01-R normal'>Aa Àà Áá Ââ Ãã Ää Åå Āā Ăă Ąą Ǎǎ Ǟǟ Ǡǡ Ǻǻ Ȁȁ Ȃȃ Ȧȧ Ḁḁ ẚ Ạạ Ảả Ấấ Ầầ Ẩẩ Ẫẫ Ậậ Ắắ Ằằ Ẳẳ Ẵẵ Ặặ Ⱥⱥ ₐ ᵃ ◌ͣ Gg Ĝĝ Ğğ Ġġ Ģģ Ǧǧ Ǵǵ Ǥǥ Ḡḡ Ꞡꞡ ᵍ </span>| G,O,T | ss01=1 | litr=1

### Barred-bowl forms 

Affects: U+0111 U+0180 U+01E5

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>Đđ Ƀƀ Ǥǥ</span>| G,O,T | ss04=0 | bowl=0
Barred-bowl | <span class='charis-ss04-R normal'>Đđ Ƀƀ Ǥǥ</span>| G,O,T | ss04=1 | bowl=1

### Slant italic specials

Affects: U+0061 U+00E3 U+00E0 U+00E1 U+00E2 U+00E4 U+00E5 U+0101 U+0103 U+01CE U+01DF U+01E1 U+01FB U+0201 U+0203 U+0227 U+1E01 U+1E9A U+1EA3 U+1EA5 U+1EA7 U+1EA9 U+1EAB U+1EAD U+1EAF U+1EB1 U+1EB3 U+1EB5 U+1EA1 U+1EB7 U+2C65 U+0250 U+00E6 U+0066 U+1E1F U+0069 U+00EC U+00ED U+00EE U+00EF U+0129 U+012B U+012D U+012F U+01D0 U+0209 U+020B U+1E2D U+1E2F U+1EC9 U+1ECB U+0131 U+006C U+013A U+1E37 U+1E39 U+1E3B U+1E3D U+0076 U+1E7D U+1E7F U+007A U+017A U+017C U+017E U+1E91 U+1E93 U+1E95 U+0493 U+04FB U+F327 U+A749 U+A75F U+2097

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
European style | <span class='charis-dflt-I normal'>Aa Ãã Àà Áá Ââ Ää Åå Āā Ăă Ǎǎ Ǟǟ Ǡǡ Ǻǻ Ȁȁ Ȃȃ Ȧȧ Ḁḁ ẚ Ảả Ấấ Ầầ Ẩẩ Ẫẫ Ậậ Ắắ Ằằ Ẳẳ Ẵẵ Ạạ Ặặ Ⱥⱥ ɐ Ææ Ff Ḟḟ Ii Ìì Íí Îî Ïï Ĩĩ Īī Ĭĭ Įį Ǐǐ Ȉȉ Ȋȋ Ḭḭ Ḯḯ Ỉỉ Ịị Iı Ll Ĺĺ Ḷḷ Ḹḹ Ḻḻ Ḽḽ Ꝉꝉ ₗ Vv Ṽṽ Ṿṿ Ꝟꝟ Zz Źź Żż Žž Ẑẑ Ẓẓ Ẕẕ Ғғ Ӻӻ  fi ffi</span>| G,O,T | ss05=0 | ital=0
Non-European style | <span class='charis-ss05-I normal'>Aa Ãã Àà Áá Ââ Ää Åå Āā Ăă Ǎǎ Ǟǟ Ǡǡ Ǻǻ Ȁȁ Ȃȃ Ȧȧ Ḁḁ ẚ Ảả Ấấ Ầầ Ẩẩ Ẫẫ Ậậ Ắắ Ằằ Ẳẳ Ẵẵ Ạạ Ặặ Ⱥⱥ ɐ Ææ Ff Ḟḟ Ii Ìì Íí Îî Ïï Ĩĩ Īī Ĭĭ Įį Ǐǐ Ȉȉ Ȋȋ Ḭḭ Ḯḯ Ỉỉ Ịị Iı Ll Ĺĺ Ḷḷ Ḹḹ Ḻḻ Ḽḽ Ꝉꝉ ₗ Vv Ṽṽ Ṿṿ Ꝟꝟ Zz Źź Żż Žž Ẑẑ Ẓẓ Ẕẕ Ғғ Ӻӻ  fi ffi</span>| G,O,T | ss05=1 | ital=1


### Non-European caron alternates

Affects: U+0164 U+0165 U+010E U+010F U+013D U+013E

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
European style | <span class='charis-dflt-R normal'>Ťť Ďď Ľľ</span>| G,O,T | cv77=0 | carn=0
Non-European style | <span class='charis-cv77-R normal'>Ťť Ďď Ľľ</span>| G,O,T | cv77=1 | carn=1

### Ogonek alternate

Affects: U+0328 U+0104 U+0105 U+0118 U+0119 U+012E U+012F U+0172 U+0173 U+01EA U+01EB U+01EC U+01ED

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Curved | <span class='charis-dflt-R normal'>anything with ◌̨ (Ąą Ęę Įį Ųų Ǫǫ Ǭǭ)</span>| G,O,T | cv76=0 | ogon=0
Straight | <span class='charis-cv76-R normal'>anything with ◌̨ (Ąą Ęę Įį Ųų Ǫǫ Ǭǭ)</span>| G,O,T | cv76=1 | ogon=1

### Capital B-hook alternate

Affects: U+0181

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Uppercase style | <span class='charis-dflt-R normal'>Ɓɓ</span>| G,O,T | cv13=0 | B_hk=0
Lowercase style | <span class='charis-cv13-R normal'>Ɓɓ</span>| G,O,T | cv13=1 | B_hk=1

### Capital D-hook alternate

Affects: U+018A

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Uppercase style | <span class='charis-dflt-R normal'>Ɗɗ</span>| G,O,T | cv17=0 | D_hk=0
Lowercase style | <span class='charis-cv17-R normal'>Ɗɗ</span>| G,O,T | cv17=1 | D_hk=1

### Rams horn alternates

Affects: U+0264

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Small bowl | <span class='charis-dflt-R normal'>ɤ</span>| G,O,T | cv25=0 | ramh=0
Large bowl | <span class='charis-cv25-1-R normal'>ɤ</span>| G,O,T | cv25=1 | ramh=1
Small gamma | <span class='charis-cv25-2-R normal'>ɤ</span>| G,O,T | cv25=2 | ramh=2


### Capital H-stroke alternate

Affects: U+0126

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>Ħħ</span>| G,O,T | cv28=0 | Hstk=0
Vertical-stroke | <span class='charis-cv28-R normal'>Ħħ</span>| G,O,T | cv28=1 | Hstk=1

### J-stroke hook alternate

Affects: U+0284

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
No serif | <span class='charis-dflt-R normal'>ʄ</span>| G,O,T | cv37=0 | Jstk=0
Top serif | <span class='charis-cv37-R normal'>ʄ</span>| G,O,T | cv37=1 | Jstk=1

### Capital Eng alternates

Affects: U+014A

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Lowercase style with descender | <span class='charis-dflt-R normal'>Ŋŋ</span>| G,O,T | cv43=0 | Engs=0
Lowercase style on baseline | <span class='charis-cv43-1-R normal'>Ŋŋ</span>| G,O,T | cv43=1 | Engs=1
Uppercase style with descender | <span class='charis-cv43-2-R normal'>Ŋŋ</span>| G,O,T | cv43=2 | Engs=2
Alt. lowercase style on baseline | <span class='charis-cv43-3-R normal'>Ŋŋ</span>| G,O,T | cv43=3 | Engs=3


### Capital N-left-hook alternate

Affects: U+019D

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Uppercase style | <span class='charis-dflt-R normal'>Ɲɲ</span>| G,O,T | cv44=0 | N_hk=0
Lowercase style | <span class='charis-cv44-R normal'>Ɲɲ</span>| G,O,T | cv44=1 | N_hk=1

### Open-O alternate

Affects: U+0186 U+0254 U+1D10 U+1D53 U+1D97

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Bottom serif | <span class='charis-dflt-R normal'>Ɔɔ ᴐ ᵓ ᶗ</span>| G,O,T | cv46=0 | opnO=0
Top serif | <span class='charis-cv46-R normal'>Ɔɔ ᴐ ᵓ ᶗ</span>| G,O,T | cv46=1 | opnO=1

### Small p-hook alternate

Affects: U+01A5

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Left hook | <span class='charis-dflt-R normal'>Ƥƥ</span>| G,O,T | cv49=0 | p_hk=0
Right hook | <span class='charis-cv49-R normal'>Ƥƥ</span>| G,O,T | cv49=1 | p_hk=1

### Capital R-tail alternate

Affects: U+2C64

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Uppercase style | <span class='charis-dflt-R normal'>Ɽɽ</span>| G,O,T | cv55=0 | R_tl=0
Lowercase style | <span class='charis-cv55-R normal'>Ɽɽ</span>| G,O,T | cv55=1 | R_tl=1

### Capital T-hook alternate

Affects: U+01AC

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Left hook | <span class='charis-dflt-R normal'>Ƭƭ</span>| G,O,T | cv57=0 | t_hk=0
Right hook | <span class='charis-cv57-R normal'>Ƭƭ</span>| G,O,T | cv57=1 | t_hk=1

### V-hook alternates

Affects: U+01B2 U+028B U+1DB9

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Curved | <span class='charis-dflt-R normal'>Ʋʋᶹ</span>| G,O,T | cv62=0 | v_hk=0
Straight with low hook | <span class='charis-cv62-1-R normal'>Ʋʋᶹ</span>| G,O,T | cv62=1 | v_hk=1
Straight with high hook | <span class='charis-cv62-2-R normal'>Ʋʋᶹ</span>| G,O,T | cv62=2 | v_hk=2


### Capital Y-hook alternate

Affects: U+01B3

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Right hook | <span class='charis-dflt-R normal'>Ƴƴ</span>| G,O,T | cv68=0 | Y_hk=1
Left hook | <span class='charis-cv68-R normal'>Ƴƴ</span>| G,O,T | cv68=1 | Y_hk=0

### Small ezh-curl alternate

Affects: U+0293

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Small bowl | <span class='charis-dflt-R normal'>ʓ</span>| G,O,T | cv19=0 | ezhc=0
Large bowl | <span class='charis-cv19-R normal'>ʓ</span>| G,O,T | cv19=1 | ezhc=1

### Capital Ezh alternates

Affects: U+01B7 U+04E0

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Normal | <span class='charis-dflt-R normal'>Ʒʒ Ӡӡ</span>| G,O,T | cv20=0 | Ezhr=0
Reversed sigma | <span class='charis-cv20-R normal'>Ʒʒ Ӡӡ</span>| G,O,T | cv20=1 | Ezhr=1

### OU alternates

Affects: U+0222 U+0223 U+1D3D U+1D15

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Closed | <span class='charis-dflt-R normal'>Ȣȣᴕᴽ</span>| G,O,T | cv47=0 | opOU=0
Open | <span class='charis-cv47-R normal'>Ȣȣᴕᴽ</span>| G,O,T | cv47=1 | opOU=1

### Modifier apostrophe alternates

Affects: U+02BC U+A78B U+A78C

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Small | <span class='charis-dflt-R normal'>ʼ Ꞌꞌ</span>| G,O,T | cv70=0 | apos=0
Large | <span class='charis-cv70-R normal'>ʼ Ꞌꞌ</span>| G,O,T | cv70=1 | apos=1

### Modifier colon alternate

Affects: U+A789

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Tight | <span class='charis-dflt-R normal'>꞉</span>| G,O,T | cv71=0 | coln=0
Expanded | <span class='charis-cv71-R normal'>꞉</span>| G,O,T | cv71=1 | coln=1

### Empty set alternates

Affects: U+2205

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
Circle | <span class='charis-dflt-R normal'>∅</span>| G,O,T | cv98=0 | empt=0
Zero | <span class='charis-cv98-R normal'>∅</span>| G,O,T | cv98=1 | empt=1

### Small Caps

Affects: all lower-case letters with upper-case equivalents

Feature | Sample | Rendering¹ | OT Feature ID | Graphite Feature ID
------------- | --------------- |------------- | ------------- 
False | <span class='charis-dflt-R normal'>a b c d e f g h i j k l m n o p q r s t u v w x y z à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ø ù ú û ü ý þ ÿ ā ă ą ć ĉ ċ č ď đ ē ĕ ė ę ě ĝ ğ ġ ģ ĥ ħ ĩ ī ĭ į ı ĳ ĵ ķ ĺ ļ ľ ŀ ł ń ņ ň ŋ ō ŏ ő œ ŕ ŗ ř ś ŝ ş š ţ ť ŧ ũ ū ŭ ů ű ų ŵ ŷ ź ż ž ƀ ƃ ƅ ƈ ƌ ƒ ƕ ƙ ƚ ƞ ơ ƣ ƥ ƨ ƭ ư ƴ ƶ ƹ ƽ ƿ ǅ ǆ ǈ ǉ ǋ ǌ ǎ ǐ ǒ ǔ ǖ ǘ ǚ ǜ ǝ ǟ ǡ ǣ ǥ ǧ ǩ ǫ ǭ ǯ ǲ ǳ ǵ ǹ ǻ ǽ ǿ ȁ ȃ ȅ ȇ ȉ ȋ ȍ ȏ ȑ ȓ ȕ ȗ ș ț ȝ ȟ ȣ ȥ ȧ ȩ ȫ ȭ ȯ ȱ ȳ ȼ ɂ ɇ ɉ ɋ ɍ ɏ ɐ ɑ ɓ ɔ ɗ ə ɛ ɠ ɣ ɨ ɩ ɫ ɯ ɱ ɲ ɵ ɽ ʀ ʃ ʈ ʉ ʊ ʋ ʌ ʒ ᵽ ḁ ḃ ḅ ḇ ḉ ḋ ḍ ḏ ḑ ḓ ḕ ḗ ḙ ḛ ḝ ḟ ḡ ḣ ḥ ḧ ḩ ḫ ḭ ḯ ḱ ḳ ḵ ḷ ḹ ḻ ḽ ḿ ṁ ṃ ṅ ṇ ṉ ṋ ṍ ṏ ṑ ṓ ṕ ṗ ṙ ṛ ṝ ṟ ṡ ṣ ṥ ṧ ṩ ṫ ṭ ṯ ṱ ṳ ṵ ṷ ṹ ṻ ṽ ṿ ẁ ẃ ẅ ẇ ẉ ẋ ẍ ẏ ẑ ẓ ẕ ạ ả ấ ầ ẩ ẫ ậ ắ ằ ẳ ẵ ặ ẹ ẻ ẽ ế ề ể ễ ệ ỉ ị ọ ỏ ố ồ ổ ỗ ộ ớ ờ ở ỡ ợ ụ ủ ứ ừ ử ữ ự ỳ ỵ ỷ ỹ ỻ ỽ ỿ ⱡ ⱥ ⱦ ⱨ ⱪ ⱬ ⱳ ȿ ɀ ⱶ ꜣ ꜥ ꜧ ꜩ ꜫ ꜭ ꜯ ꜳ ꜵ ꜷ ꜹ ꜻ ꜽ ꜿ ꝁ ꝃ ꝅ ꝇ ꝉ ꝋ ꝍ ꝏ ꝑ ꝓ ꝕ ꝗ ꝙ ꝛ ꝝ ꝟ ꝡ ꝣ ꝥ ꝧ ꝩ ꝫ ꝭ ꝯ ꝺ ꝼ ꝿ ꞁ ꞃ ꞅ ꞇ ꞌ ɥ ꞑ ꞓ ꞗ ꞙ ꞡ ꞣ ꞥ ꞧ ꞩ ɦ ɜ ɡ ɬ ʞ ʇ ɖ ᵹ ꜣ ꜥ</span>| G,O,T | c2sc=0 or smcp=0 | smcp=0
True | <span class='charis-smcp-R normal'>a b c d e f g h i j k l m n o p q r s t u v w x y z à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ø ù ú û ü ý þ ÿ ā ă ą ć ĉ ċ č ď đ ē ĕ ė ę ě ĝ ğ ġ ģ ĥ ħ ĩ ī ĭ į ı ĳ ĵ ķ ĺ ļ ľ ŀ ł ń ņ ň ŋ ō ŏ ő œ ŕ ŗ ř ś ŝ ş š ţ ť ŧ ũ ū ŭ ů ű ų ŵ ŷ ź ż ž ƀ ƃ ƅ ƈ ƌ ƒ ƕ ƙ ƚ ƞ ơ ƣ ƥ ƨ ƭ ư ƴ ƶ ƹ ƽ ƿ ǅ ǆ ǈ ǉ ǋ ǌ ǎ ǐ ǒ ǔ ǖ ǘ ǚ ǜ ǝ ǟ ǡ ǣ ǥ ǧ ǩ ǫ ǭ ǯ ǲ ǳ ǵ ǹ ǻ ǽ ǿ ȁ ȃ ȅ ȇ ȉ ȋ ȍ ȏ ȑ ȓ ȕ ȗ ș ț ȝ ȟ ȣ ȥ ȧ ȩ ȫ ȭ ȯ ȱ ȳ ȼ ɂ ɇ ɉ ɋ ɍ ɏ ɐ ɑ ɓ ɔ ɗ ə ɛ ɠ ɣ ɨ ɩ ɫ ɯ ɱ ɲ ɵ ɽ ʀ ʃ ʈ ʉ ʊ ʋ ʌ ʒ ᵽ ḁ ḃ ḅ ḇ ḉ ḋ ḍ ḏ ḑ ḓ ḕ ḗ ḙ ḛ ḝ ḟ ḡ ḣ ḥ ḧ ḩ ḫ ḭ ḯ ḱ ḳ ḵ ḷ ḹ ḻ ḽ ḿ ṁ ṃ ṅ ṇ ṉ ṋ ṍ ṏ ṑ ṓ ṕ ṗ ṙ ṛ ṝ ṟ ṡ ṣ ṥ ṧ ṩ ṫ ṭ ṯ ṱ ṳ ṵ ṷ ṹ ṻ ṽ ṿ ẁ ẃ ẅ ẇ ẉ ẋ ẍ ẏ ẑ ẓ ẕ ạ ả ấ ầ ẩ ẫ ậ ắ ằ ẳ ẵ ặ ẹ ẻ ẽ ế ề ể ễ ệ ỉ ị ọ ỏ ố ồ ổ ỗ ộ ớ ờ ở ỡ ợ ụ ủ ứ ừ ử ữ ự ỳ ỵ ỷ ỹ ỻ ỽ ỿ ⱡ ⱥ ⱦ ⱨ ⱪ ⱬ ⱳ ȿ ɀ ⱶ ꜣ ꜥ ꜧ ꜩ ꜫ ꜭ ꜯ ꜳ ꜵ ꜷ ꜹ ꜻ ꜽ ꜿ ꝁ ꝃ ꝅ ꝇ ꝉ ꝋ ꝍ ꝏ ꝑ ꝓ ꝕ ꝗ ꝙ ꝛ ꝝ ꝟ ꝡ ꝣ ꝥ ꝧ ꝩ ꝫ ꝭ ꝯ ꝺ ꝼ ꝿ ꞁ ꞃ ꞅ ꞇ ꞌ ɥ ꞑ ꞓ ꞗ ꞙ ꞡ ꞣ ꞥ ꞧ ꞩ ɦ ɜ ɡ ɬ ʞ ʇ ɖ ᵹ ꜣ ꜥ</span>| G,O,T | c2sc=1 or smcp=1 | smcp=1


¹<b>Legend:</b> G=Implemented in Graphite; O=Implemented in OpenType; T=Implemented in TypeTuner (command line version: [http://scripts.sil.org/TypeTuner](http://scripts.sil.org/TypeTuner) and web-based version: [http://scripts.sil.org/ttw](http://scripts.sil.org/ttw)).

²There are also Cyrillic characters affected by the “Capital Ezh alternates” and “Small capitals” features. Some languages may also use the “Modifier apostrophe alternates.”

[top]

[font id='charis-dflt' face='CharisSIL-R' italic='CharisSIL-I' size='120%']
[font id='charis-cv13'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv13 1, B_hk 1' size='120%']
[font id='charis-cv17'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv17 1, D_hk 1' size='120%']
[font id='charis-cv19'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv19 1, ezhc 1' size='120%']
[font id='charis-cv20'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv20 1, Ezhr 1' size='120%']
[font id='charis-cv25-1' face='CharisSIL-R' italic='CharisSIL-I' feats='cv25 1, ramh 1' size='120%']
[font id='charis-cv25-2' face='CharisSIL-R' italic='CharisSIL-I' feats='cv25 2, ramh 2' size='120%']
[font id='charis-cv28'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv28 1, Hstk 1' size='120%']
[font id='charis-cv34'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv34 1, jser 1' size='120%']
[font id='charis-cv37'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv37 1, Jstk 1' size='120%']
[font id='charis-cv43-1' face='CharisSIL-R' italic='CharisSIL-I' feats='cv43 1, Engs 1' size='120%']
[font id='charis-cv43-2' face='CharisSIL-R' italic='CharisSIL-I' feats='cv43 2, Engs 2' size='120%']
[font id='charis-cv43-3' face='CharisSIL-R' italic='CharisSIL-I' feats='cv43 3, Engs 3' size='120%']
[font id='charis-cv44'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv44 1, N_hk 1' size='120%']
[font id='charis-cv46'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv46 1, opnO 1' size='120%']
[font id='charis-cv47'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv47 1, opOU 1' size='120%']
[font id='charis-cv49'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv49 1, p_hk 1' size='120%']
[font id='charis-cv55'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv55 1, R_tl 1' size='120%']
[font id='charis-cv57'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv57 1, t_hk 1' size='120%']
[font id='charis-cv62-1' face='CharisSIL-R' italic='CharisSIL-I' feats='cv62 1, v_hk 1' size='120%']
[font id='charis-cv62-2' face='CharisSIL-R' italic='CharisSIL-I' feats='cv62 2, v_hk 2' size='120%']
[font id='charis-cv68'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv68 1, Y_hk 0' size='120%']
[font id='charis-cv67'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv67 1, y_tl 1' size='120%']
[font id='charis-cv70'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv70 1, apos 1' size='120%']
[font id='charis-cv71'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv71 1, coln 1' size='120%']
[font id='charis-cv75'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv75 1, viet 1' size='120%']
[font id='charis-cv76'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv76 1, ogon 1' size='120%']
[font id='charis-cv77'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv77 1, carn 1' size='120%']
[font id='charis-cv80'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv80 1, mone 1' size='120%']
[font id='charis-cv81'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv81 1, shha 1' size='120%']
[font id='charis-cv82'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv82 1, sbrv 1' size='120%']
[font id='charis-cv91'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv91 1, tone 1' size='120%']
[font id='charis-cv92'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv92 1, tstv 1' size='120%']
[font id='charis-cv98'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv98 1, empt 1' size='120%']
[font id='charis-cv90'   face='CharisSIL-R' italic='CharisSIL-I' feats='cv90 1, chtn 1' size='120%']
[font id='charis-ss01'   face='CharisSIL-R' italic='CharisSIL-I' feats='ss01 1, litr 1' size='120%']
[font id='charis-ss04'   face='CharisSIL-R' italic='CharisSIL-I' feats='ss04 1, bowl 1' size='120%']
[font id='charis-ss05'   face='CharisSIL-R' italic='CharisSIL-I' feats='ss05 1, ital 1' size='120%']
[font id='charis-ss06'   face='CharisSIL-R' italic='CharisSIL-I' feats='ss06 1, invs 1' size='120%']
[font id='charis-smcp'   face='CharisSIL-R' italic='CharisSIL-I' feats='smcp 1, c2sc 1' size='120%']
[font id='charis-serb'   face='CharisSIL-R' italic='CharisSIL-I' feats='serb 1' size='120%']
