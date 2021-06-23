#!/usr/bin/python3

import re

f = open('LornasData.xml', 'r')
lines = f.readlines()
f.close()

parse_regex = '&#xf130;(.*)&#xf131;  (.*)<'

test_seq, comment_str = [], []
for l in lines[3:-1]:
    m = re.search(parse_regex, l)
    if not m:
        print("line mismatch: {}\n".format(l))
    else:
        test_seq.append(m.group(1))
        comment_str.append(m.group(2))
# print("{}    {}\n".format(len(test_seq), len(comment_str)))

ftml_hdr = '''<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet href="../tools/ftml.xsl" type="text/xsl"?>
<ftml version="1.0">
  <head>
    <fontscale>200</fontscale>
    <fontsrc>url(../results/CharisSIL-Regular.ttf)</fontsrc>
    <fontsrc>url(../results/CharisSIL-Bold.ttf)</fontsrc>
    <fontsrc>url(../results/CharisSIL-Italic.ttf)</fontsrc>
    <fontsrc>url(../results/CharisSIL-BoldItalic.ttf)</fontsrc>
    <fontsrc label="CRv5">url(../references/v5/CharisSIL-Regular.ttf)</fontsrc>
    <fontsrc label="CIv5">url(../references/v5/CharisSIL-Italic.ttf)</fontsrc>
    <fontsrc label="DRb1">url(../references/b1/DoulosSIL-Regular.ttf)</fontsrc>
    <fontsrc label="DRv5">url(../references/v5/DoulosSIL-Regular.ttf)</fontsrc>
    <title>LornasData</title>
  </head>
  <testgroup label="Common base diacritic combos">
'''

ftml_ftr = '''  </testgroup>
</ftml>
'''

test_tmplt = '''    <test label="{}">
      <comment>{}</comment>
      <string>{}</string>
    </test>
'''

f = open("LornasData.ftml", "w")
f.write(ftml_hdr)
for test_utf8, comment in zip(test_seq, comment_str):
#    print(comment);
    test, label_str = "", ""
    for c in test_utf8:
        usv = ord(c)
        if usv > 0xFFFF: # detect values that don't work with the below
            print (f"USV too large: {usv}\n") 
        test += "\\u" + format(usv, "06X")
        label_str += "U+" + format(usv, "04X") + " "
    label_str = label_str[:-1]
    f.write(test_tmplt.format(label_str, comment, test))
f.write(ftml_ftr)
f.close()
