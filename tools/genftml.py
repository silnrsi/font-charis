# Script to call psfgenftml.py multiple times -- once for each test
# Relies on "smith alltest" to generate html that will invoke the generated ftml for each style

import sys
import psfgenftml

test_lst = [
    "allchars",
    "diacs",
    "features",
    "smcp"
]

AP_type_lst = ["U", "L", "O", "H", "R"]
for a in AP_type_lst:
    test_lst.append("features_" + a)
    test_lst.append("smcp_" + a)

# Paths are relative to directory script is ran from (font-<>/tools)
# Assumes the standard directory structure is present

ufo_regular = "CharisSIL-Regular.ufo"
test_nm = "allchars"
ftml_fn = test_nm + ".ftml"
font_spec = "C"
glyph_data_fn = "glyph_data.csv"
xsl_fontsrc = "CharisSIL-Regular.ttf"
ftml_scale = "200"
log_fn = test_nm + ".log"

args_lst = [
"../source/CharisSIL-Regular.ufo",
"../tests/AllCharsCR.ftml",
"-t", "allchars",
"-f", "C",
"-i", "../source/glyph_data.csv",
"-s", "../results/CharisSIL-Regular.ttf",
"--scale", "200",
"-l", "../tests/logs/AllChars_CR.log"
]

print(sys.argv)
print(psfgenftml.__file__)
sys.argv = [psfgenftml.__file__]
sys.argv.extend(args_lst)

psfgenftml.cmd()
