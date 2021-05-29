#!/usr/bin/python3

from silfont.core import loggerobj
import silfont.ftml_builder

tone_bars = [0x02E5, 0x02E6, 0x02E7, 0x02E8, 0x02E9]
leftstem_tone_bars = [0xA712, 0xA713, 0xA714, 0xA715, 0xA716]
dotted_tone_bars = [0xA708, 0xA709, 0xA70A, 0xA70B, 0xA70C]
dotted_leftstem_tone_bars = [0xA70D, 0xA70E, 0xA70F, 0xA710, 0xA711]

def generate_test_group(ftml, name, uid_lst):
    ftml.startTestGroup(name)

    # def addToTest(self, uid, s = "", label = None, comment = None, rtl = None):

    s = " ".join(["\\u" + format(u, "06X") for u in uid_lst])
    label = " ".join(["U+" + format(u, "04X") for u in uid_lst])
    comment = "solo tones"
    ftml.addToTest(0, s, label, comment)
    ftml.closeTest()

    s = "".join([f" \\u{u:06X}\\u{u:06X} " for u in uid_lst])
    label = " ".join(["U+" + format(u, "04X") for u in uid_lst])
    comment = "identical paired tones"
    ftml.addToTest(0, s, label, comment)
    ftml.closeTest()

    for u in uid_lst:
        for v in uid_lst:
            s = f"\\u{u:06X}\\u{v:06X}"
            label = f"U+{u:04X}"
            comment = f"tone pairs"
            ftml.addToTest(u, s, label, comment)
        ftml.closeTest()
    ftml.closeTest()

    for u in uid_lst:
        for v in uid_lst:
            for w in uid_lst:
                s = f"\\u{u:06X}\\u{v:06X}\\u{w:06X}"
                label = f"U+{u:04X} U+{v:04X}"
                comment = f"tone triplets"
                ftml.addToTest(v, s, label, comment)
            ftml.closeTest()
    ftml.closeTest()

    ftml.closeTestGroup()

def main():
    # def __init__(self, title, logger, comment=None, fontsrc=None, fontlabel=None, fontscale=None,
    #              widths=None, rendercheck=True, xslfn=None, defaultrtl=False):
    logger = loggerobj()
    ftml = silfont.ftml_builder.FTML("Tone Bar tests", logger, fontsrc="../results/CharisSIL-Regular.ttf",
                                     fontscale=200, rendercheck=False, xslfn="../tools/ftml.xsl")

    generate_test_group(ftml, "Tone Bars", tone_bars)
    ftml.setFeatures([("cv91", "1")])
    generate_test_group(ftml, "Tone Numbers", tone_bars)
    ftml.setFeatures([("cv92", "1")])
    generate_test_group(ftml, "Tone Bars hidden staves", tone_bars)

    generate_test_group(ftml, "Leftstem Tone Bars", leftstem_tone_bars)
    ftml.setFeatures([("cv91", "1")])
    generate_test_group(ftml, "Leftstem Tone Numbers", leftstem_tone_bars)
    ftml.setFeatures([("cv92", "1")])
    generate_test_group(ftml, "Leftstem Tone Bars hidden staves", leftstem_tone_bars)

    generate_test_group(ftml, "Dotted Tone Bars", dotted_tone_bars)
    generate_test_group(ftml, "Dotted Leftstem Tone Bars", dotted_leftstem_tone_bars)

    f = open("tests/ToneBars.ftml", "w")
    ftml.writeFile(f)
    f.close()

if __name__ == "__main__": main()
