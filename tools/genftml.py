# Script to call psfgenftml.py multiple times -- once for each test
# Creates multi-font tests which can be directly opened in a browser
# Tests work with "smith ftml" to render the test data using the chosen font
# Tests work with "smith test" for comparing the rendered test data against a prior version of the font
#
# Differences in the directory structure for Gentium (compared to Charis) are handled
#  as are the heavier (Book) weights

import sys, glob, os.path, re
import psfgenftml

# tests to generate (see psfgenftml.py)
test_lst = ["allchars", "allframed", "diacs", "features", "smcp"]
AP_type_lst = ["U", "L", "O", "H", "R"]
for a in AP_type_lst:
    test_lst.append("features_" + a)
    test_lst.append("smcp_" + a)

# find the file name without the extension of the Regular style ufo
# TODO: ensure that Book Regular is not chosen ?
for ufo_path in ("source/", "results/source/instances/", "source/masters/"):
    regular_ufo_fn_lst = glob.glob(ufo_path + "*-Regular.ufo")
    if regular_ufo_fn_lst: break
regular_ufo_base = os.path.splitext(os.path.basename(regular_ufo_fn_lst[0]))[0]
assert(ufo_path and regular_ufo_base)

# find list of all built ttfs for multi-font tests and sort
ttf_results_fn_lst = glob.glob("results/*.ttf")
ttf_fn_lst = [os.path.basename(f) for f in ttf_results_fn_lst]

sort_style_lst = ["-Regular", "-Bold(?!Italic)", "-(?!Bold)Italic", "-BoldItalic"]
# heavy_style = "Book" # not needed in current implementation

# sort() and reverse() ensure Regular comes before Book Regular
ttf_fn_lst.sort()
ttf_fn_lst.reverse()
ttf_fn_sort_lst = []
for style in sort_style_lst:
    for fn in ttf_fn_lst:
        if re.search(style, fn):
            ttf_fn_sort_lst.append(fn)
assert(ttf_fn_sort_lst)

# values to be applied to items in arg_template_lst
arg_values_dict = {
    "test" : test_lst[0],
    "ufo_regular" : regular_ufo_base,
    "font_code" : regular_ufo_base[0],
    "glyph_data": "glyph_data",
    "classes": "classes.xml",
    "scale" : "200",
    "xsl" : "ftml",
}

# This arg_lst can be used for debugging
#  but will be replaced by "instances" of template lists (below)
arg_lst = [
    "source/CharisSIL-Regular.ufo",
    "tests/allchars.ftml",
    "-t", "allchars",
    "-f", "C",
    "-i", "source/glyph_data.csv",
    "--classes", "source/classes.xml"
    "-s", "../results/CharisSIL-Regular.ttf",
    "--scale", "200",
    "--xsl", "../tools/ftml.xsl",
    "-l", "tests/logs/allchars.log",
]

# Template for arguments to be passed to psfgenftml.py thru sys.argv
# Paths are relative to the directory the script is ran from
#  which is assumed to be the top of the font repo
# Except for the -s arg, which is relative to where the generated ftml is opened from
# Assumes the standard directory structure is present
arg_cols_template_lst = [
    ufo_path + "{ufo_regular}.ufo",
    "tests/{test}.ftml",
    "-t", "{test}",
    "-f", "{font_code}",
    "-i", "source/{glyph_data}.csv",
    "--classes", "source/{classes}",
#    "-s", "../results/{ufo_regular}.ttf", # multiple "-s" args will be appended for multi-font tests
    "--scale", "{scale}",
    "--xsl", "../tools/{xsl}.xsl",
    "-l", "tests/logs/{test}.log",
]

# Call psfgenftml for each test
for test in test_lst:
    arg_values_dict["test"] = test

    # generate multi-font test
    arg_lst = [arg.format(**arg_values_dict) for arg in arg_cols_template_lst]
    for fn in ttf_fn_sort_lst:
        family = fn[0]
        family += 'Bk' if fn.find('Book') != -1 else ''
        style = fn[fn.index('-') + 1]
        style += 'I' if fn.find('BoldItalic') != -1 else ''
        arg_lst.extend(["-s", "../results/{}={}{}".format(fn, family, style)])
    # TODO: kludgy way to add columns for other fonts, assumes tests/reference folder
    arg_lst.extend(["-s", "../references/v6101/CharisSIL-Regular.ttf=CR6"])
    arg_lst.extend(["-s", "../references/v6101/CharisSIL-Bold.ttf=CB6"])
    arg_lst.extend(["-s", "../references/v6101/CharisSIL-Italic.ttf=CI6"])
    arg_lst.extend(["-s", "../references/v6101/CharisSIL-BoldItalic.ttf=CBI6"])
    sys.argv = [psfgenftml.__file__]
    sys.argv.extend(arg_lst)
    psfgenftml.cmd()
