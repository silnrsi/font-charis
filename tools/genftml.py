# Script to call psfgenftml.py multiple times -- once for each test
# Relies on "smith test" to generate html that will render the generated ftml for each style

import sys, glob, os.path
import psfgenftml

# tests to generate (see psfgenftml.py)
test_lst = ["allchars", "diacs", "features", "smcp"]
AP_type_lst = ["U", "L", "O", "H", "R"]
for a in AP_type_lst:
    test_lst.append("features_" + a)
    test_lst.append("smcp_" + a)

# find file name without extension of the Regular style ufo
regular_ufo_fn_lst = glob.glob("source/*-Regular.ufo")
regular_ufo_base = os.path.splitext(os.path.basename(regular_ufo_fn_lst[0]))[0]

# values to be applied to items in arg_template_lst
arg_values_dict = {
    "test" : test_lst[0],
    "ufo_regular" : regular_ufo_base,
    "font_code" : regular_ufo_base[0],
    "glyph_data": "glyph_data",
    "scale" : "200",
}

# This arg_lst can be used for debugging
#  but will be replaced by "instances" of arg_template_lst (below)
arg_lst = [
    "source/CharisSIL-Regular.ufo",
    "tests/allchars.ftml",
    "-t", "allchars",
    "-f", "C",
    "-i", "source/glyph_data.csv",
    "-s", "results/CharisSIL-Regular.ttf",
    "--scale", "200",
    "-l", "tests/logs/allchars.log",
]

# Templates for arguments to be passed to psfgenftml.py thru sys.argv
# Paths are relative to the directory the script is ran from
#  which is assumed to be the top of the font repo
# Assumes the standard directory structure is present
arg_template_lst = [
    "source/{ufo_regular}.ufo",
    "tests/{test}.ftml",
    "-t", "{test}",
    "-f", "{font_code}",
    "-i", "source/{glyph_data}.csv",
    "-s", "results/{ufo_regular}.ttf",
    "--scale", "{scale}",
    "-l", "tests/logs/{test}.log",
]

# Call psfgenftml for each test
for test in test_lst:
    arg_values_dict["test"] = test
    arg_lst = [arg.format(**arg_values_dict) for arg in arg_template_lst]
    sys.argv = [psfgenftml.__file__]
    sys.argv.extend(arg_lst)
    psfgenftml.cmd()
