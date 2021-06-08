---
title: SIL Fonts - Using SIL Fonts on Web Pages
fontversion: 6.000
---

SIL fonts can be successfully used on web pages. There are many strategies available, and some tricks to making them work well. A basic assumption is that the page text is encoded as Unicode UTF-8 text.

## Primary method: Server-hosted WOFF fonts

Our font packages include special versions of our fonts in WOFF or WOFF2 format. WOFF (Web Open Font Format) and WOFF2 are font ‘wrapping’ technologies that have become the standard for web fonts and are supported by all modern browsers. They compress the font data to be more efficient (and faster) than referring to hosted TrueType or OpenType fonts.

For example, to use the Gentium Plus Regular and Italic WOFF2 fonts, copy them to your server and refer to them in your CSS:

```
@font-face {
  font-family: GentiumPlus;
  src: url(http://site/fonts/GentiumPlus-Regular.woff2);
}
@font-face {
  font-family: GentiumPlus;
  font-style: italic;
  src: url(http://site/fonts/GentiumPlus-Italic.woff2);
}
```

Change `//site/fonts/` to your domain and the path to where you have stored the font.

Then define your font styles to refer to the font by defined name:

```
p { font-family: GentiumPlus, serif; }
```

More information on the WOFF/WOFF2 formats is available from the [W3C](https://www.w3.org/TR/WOFF2/) and [Mozilla](https://developer.mozilla.org/en-US/docs/Web/Guide/WOFF) websites.

## Alternate methods

### Server-hosted TTF

You can also use standard TTF versions of the fonts rather than WOFF, however since they are larger they will take longer to load.

### Local fonts

It remains possible to have your CSS refer to locally-installed versions of SIL fonts and avoid the extra delay of loading fonts frow the web server. *However you must be sure that every user has the font installed on their local system. This is a dangerous assumption! There is also no way to check that the viewer has the latest version installed.*

```
p { font-family: "Gentium Plus", serif; }
```

### Google Fonts

If the SIL font you need is available on the [Google Fonts](https://fonts.google.com/) service then it is an excellent, high-performance source for the font. For example, you can load the whole [Andika New Basic](https://fonts.google.com/specimen/Andika+New+Basic?query=andika+New+Basic) family with this line in the `<head>` of your html file:

```
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Andika+New+Basic:ital,wght@0,400;0,700;1,400;1,700&display=swap" rel="stylesheet">
```

Then refer to it in your CSS as:

```
p { font-family: 'Andika New Basic', sans-serif; }
```

**Warning:** The Google Fonts versions look the same as the originals but have been streamlined and optimized. They may support fewer characters and character behaviors and so may not support some languages properly. The best way to determine support is to test it with language text yourself. If it works well then use it!

One helpful tip: If you want support for extended Latin characters you need to be sure to include `'&subset=latin,latin-ext'` in the link. Otherwise the font will only support basic Latin usage. Extended Cyrillic requires a similar specification.

### Older formats and technologies

There are older web fonts technologies, such as [EOT (Embedded OpenType)](https://en.wikipedia.org/wiki/Embedded_OpenType). Each of these modifies the font in some way, and so according to the [SIL Open Font License (OFL)](https://scripts.sil.org/ofl) the font name must be changed. You are allowed to use these technologies to deliver fonts to web pages, but you must change the font names and follow all other OFL rules. We do not offer any support for these technologies.

## Accessing OpenType and Graphite features

Modern browsers support activation of OpenType features through CSS properties for both local and externally loaded fonts.

It is possible to make use of OpenType and/or Graphite font features in an HTML page by specifying them with CSS. To do this you must know the ID of the feature of interest in the font and the value you wish to use. This information is usually included in the font documentation.

In this example we will use the Scheherazade font.

To declare the font, the CSS syntax is:

```
@font-face {
    font-family: Scheherazade-Regular;
    src: url("http://site/fonts/Scheherazade-Regular.woff") format("woff");
}
```

To declare the feature, the syntax is:

```
.sch-cv12-R {
    font-family: Scheherazade-Regular; 
    font-feature-settings: "cv12" 1; 
}
```
To use the feature, the syntax is:

```
class='sch-cv12-R'
```

It is also possible to use other features, such as selection of language features. In the following example, the default Scheherazade font is selected (as you have defined it) and the Urdu (ur) language is selected. Any alternate features defined in Urdu will be displayed.

```
class='sch-dflt-R' lang='ur'
```

More complete documentation of feature settings in CSS can be found on the [W3C Site](https://dev.w3.org/csswg/css3-fonts/#propdef-font-feature-settings).

For more information about turning on Graphite features, see [Using Graphite in Mozilla Firefox](https://scripts.sil.org/cms/scripts/page.php?site_id=projects&item_id=graphite_firefox).