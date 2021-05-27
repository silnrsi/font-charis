---
title: SIL Font Documentation Markdown Test
fontversion: 6.000
---

This document gives examples of how to use markdown for font documentation, for both in-project docs (html, pdf) and product site page source (md). Although these three target doc types each support some unique capabilities (e.g. product site accordions) this doc focuses on markdown that works for all three types.

## Paragraphs, text formatting, line breaking

This paragraph gives examples of formatting that uses special enclosing characters: *italic*, **bold**, `inline code`. 

Here is a second paragraph. If you want to<br>
break a line in a specific place the clearest way is to use `<br>`.

## Headings

Note that H1 is not used for font documentation pages.

## H2

The H2 is the most common heading type used.

### H3
#### H4
##### H5
###### H6

## Tables

Unicode block | Font support
------------- | ------------
C0 Controls and Basic Latin|U+0020..U+007E
C1 Controls and Latin-1 Supplement|U+00A0..U+00FF

## Lists

### Ordered List

1. First item
2. Second item
3. Third item

### Unordered List

- List item
- Another item
- And another item

### Nested List

- List item
    - Subitem
    - Another subitem
- Another item

## Blockquotes

> Here is a block quote.
> **Note** that you can use *Markdown syntax* within a blockquote.

## Code blocks

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Example HTML5 Document</title>
</head>
<body>
  <p>Test</p>
</body>
</html>
```

## Links

External links always specify the full URL ([Keyman](https://keyman.com), [SIL Language Technology](https://software.sil.org)). Relative links should point to the relevant markdown file ([This project’s About page](about.md)).

Links can be specified inline, with the full link in the text, or using named references ([This project’s About page][about]).

## Footnotes

Here is an example of a footnote[^1] that will appear at the very bottom[^anytext] of the page. Footnotes will automatically be numbered sequentially when rendered.

[^1]: Here is an example of how the footnote text is indicated. This example reference is in the text.

## Images

Images should be specified in markdown syntax with the local path used as the link. The class is required and needs to be defined in {}, usually {.fullsize}. Then the actual path to the image in the product site image library needs to be placed in a comment using a special syntax. If you want a caption it needs to be placed in a separate html *figcaption* element. Example:

![Charis SIL Sample - Precomposed Latin Diacritics](assets/images/CharisSILTypePage.png){.fullsize}
<!-- PRODUCT SITE IMAGE SRC http://software.sil.org/charis/wp-content/uploads/sites/14/2015/12/CharisSILTypePage.png -->
<figcaption>This is the caption</figcaption>

## Web fonts

To display text in the html and pdf versions using generated fonts a few things need to be in place:

- Each font that is used needs to have both `@font-face` and a corresponding class definition in `/documentation/source/assets/css/webfonts.css`
- The WOFF2 fonts used must be manually copied into the local `/web` folder of whatever machine is used to generate the pdfs. These should ideally not be committed to the project repo. The generated fonts are already automatically in the right place in the user install archive.
- The text must be enclosed in a `<span>` with the appropriate class definition.
- If the font size needs to be different from the main body text, then the font-size (in rem) needs to be added to the css for that class in either theme.css or webfonts.css. Instead the size can be explicitly set in the individual `<span>`

In order for text marked up in the same way to display properly on the product sites a few additional things need to be set up:

- The WOFF2 font files need to be uploaded to the product site server (see docs elsewhere), and be given reference names to match the font family names used in webfonts.css.
- Each page that uses the font needs to have a [font] shortcode definition that matches the css class id and font family names.
- The classes listed in individual `<span>`s need to include 'normal' to remove any inherited styling. 

Example: <span class='charis-R normal'>Charis SIL regular,</span> <span class='charis-I normal'>italic,</span> <span class='charis-B normal'>bold,</span> and <span class='charis-BI normal'>bold italic.</span>

## Font features

Activating font features requires setting feature values. It is possible to set the font-feature-settings using special css classes, but it may be better to set the feature setting in the `<span>`. This reduces the number of [font] shortcode defintions that need to be added to each page. Examples:

Feature | Default | Activated
------- | ------- | ---------
Small caps (scmp) | <span class='charis-R normal'>abcde</span> | <span class='charis-R normal' style='font-feature-settings: "smcp"'>abcde</span>
Eng alternate 1 (cv43) | <span class='charis-R normal'>Ŋ</span> | <span class='charis-R normal' style='font-feature-settings: "cv43" 1'>Ŋ</span>
Eng alternate 2 (cv43) | <span class='charis-R normal'>Ŋ</span> | <span class='charis-R normal' style='font-feature-settings: "cv43" 2'>Ŋ</span>
Eng alternate 3 (cv43) | <span class='charis-R normal'>Ŋ</span> | <span class='charis-R normal' style='font-feature-settings: "cv43" 3'>Ŋ</span>
Serbian italic alternates (language-specific) | <span class='charis-I normal'>б г д п т</span> | <span class='charis-I normal' lang='sr'>б г д п т</span>

## Horizontal rule

Paragraph before rule.

---

Paragraph after rule.

## Formatting using special html entities

H<sub>2</sub>O

X<sup>n</sup> + Y<sup>n</sup> = Z<sup>n</sup>

Press <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>C</kbd> to copy.

Text can be <mark>highlighted</mark>, though that can be very distracting.

[about]: about.md

[^anytext]: Footnote references can also be text but will still get numbered correctly. The references can be placed at the bottom of the markdown page.

<!-- PRODUCT SITE ONLY
[font id='charis' face='CharisSIL-R' italic='CharisSIL-I' bold='CharisSIL-B' bolditalic='CharisSIL-BI' size='150%']
-->
