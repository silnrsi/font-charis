---
title: SIL Fonts - Using Font Features
fontversion: 6.000
---

## YET TO BE DRAFTED - INFO HERE IS FROM OLD FAQ

## Technical

#### <a name="features"></a> _How do I use a feature? For example, I see there are four <em>Eng</em> (U+014A Ŋ) variants. How do I choose which variant displays?_

The answer depends on the application in question:

* **Graphite-enabled apps:** Assuming they support features, then you can select the desired Eng variant from the **Format / Font / Feature** menu (or however the interface is arranged).

* **LibreOffice with Graphite:** In LibreOffice the font features can be turned on by choosing the font (ie Charis SIL), followed by a colon, followed by the feature ID, and then followed by the feature setting. So, for example, if the Uppercase eng alternate “Capital N with tail” is desired, the font selection would be “Charis SIL:Engs=2”. If you wish to apply two (or more) features, you can separate them with an “&amp;”. Thus, “Charis SIL:Engs=2&amp;smcp=1” would apply “Capital N with tail” plus the “Small capitals” feature. 

* **InDesign and similar Adobe apps:** Select an Eng in your text and then use the glyph palette (select **Type / Glyphs / Access All Alternates**) to pick an alternate. (The available features will depend on the font selected.)

* **Word and other Uniscribe-based apps:** Sorry, but at this time there is no mechanism to select features or alternate glyphs. 

* **With the XeTeX typesetting system:** Include “feature=setting” pairs in the font specification within the source document or stylesheet; e.g., <code>fontbodytext="Doulos SIL/GR:Uppercase Eng alternates=Large eng on
baseline" at 12pt</code>. The syntax for this can be derived from the Font Features document for the specific font you are using.

So, anticipating your (or someone’s) next question: What do I do if I’m using Word or other Uniscribe-based apps?

* In the long run, we hope that future versions of the Windows OS and application software will provide an architecture and user interface that supports some form of user-selectable font feature mechanism. We’ll see.

* In the meantime, the only alternative is to create derivative fonts that have the desired behaviors (e.g., alternate glyphs) “turned on” by default. So one could imagine a font such as “Doulos SIL Eng4” that is just like Doulos SIL except it renders Eng using the 4th alternate. We have created a tool called <a href="https://scripts.sil.org/ttw/fonts2go.cgi">TypeTuner Web</a> which you can use to create derivative fonts.

#### _How do I use the Small Caps feature?_

The Small Caps feature is an OpenType and a Graphite feature that can be turned on within the font. How to use it will vary from one application to the next.

* **Adobe InDesign** will use the OpenType Small Caps feature. Select your text, then select the character palette, then click on the little down arrow wedge in the top right corner and select **Opentype / All Small Caps.**

* **FieldWorks applications** - small capitals can be selected by selecting **Format / Font / Font Features / Small Caps.**

* **[LibreOffice](https://www.libreoffice.org)** can use small capitals by selecting the text, choosing the font name (eg "Charis SIL") and then after the font name, type in ":smcp=1". Thus, your font entry would be "Charis SIL:smcp=1" If you want to use more than one feature, you can type a "&amp;" in between. Thus, "Charis SIL:smcp=1&amp;Engs=1" would give you an alternate eng plus small capitals.

* **[XeTeX](https://scripts.sil.org/xetex)** can use the Small capitals feature. When you define the font you can just add "+smcp=1" afterward. So, you might have "Doulos SIL: +smcp=1." If you use XeLaTeX you can use the <code>^textsc^{small caps text goes here^}</code> command where everything within <code>^textsc</code> becomes small caps.

* **Other apps** - Microsoft Word and Publisher do not use the OpenType or Graphite Small Caps feature. They make small caps on-the-fly. Other applications, such as RenderX, require the use of a separate font for the small capitals. For both these situations, if you want to use the true small capitals, then you will need to create a separate font with TypeTuner Web. We have created a tool called [TypeTuner Web](https://scripts.sil.org/ttw/fonts2go.cgi) which you can use to create derivative fonts. Just select the font, choose "Select features" and change the Small Caps setting to "True" and download and install the font. That will give you a small capitals font and you would apply that font when you need it. 
