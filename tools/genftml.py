# Script to call psfgenftml.py multiple times -- once for each test
# Relies on "smith ftml" to generate html that will render the generated ftml for each style
# Creates single and multi- font tests
# The multi-font tests will be included in the ftml_index.html produced by "smith ftml"
#  But they will not render correctly in that environment because the xsl specified in the ftml will be overridden
# However they will work if directly opened in a browser
# Differences in the directory structure for Gentium (compared to Charis) are handled
#  as are the heavier (Book) weights
# TODO: Add arg to generate only single or multi-font tests

import sys, glob, os.path, re
import psfgenftml

# tests to generate (see psfgenftml.py)
test_lst = ["allchars", "diacs", "features", "smcp"]
AP_type_lst = ["U", "L", "O", "H", "R"]
for a in AP_type_lst:
    test_lst.append("features_" + a)
    test_lst.append("smcp_" + a)

# find the file name without the extension of the Regular style ufo
# TODO: ensure that Book Regular is not chosen ?
for ufo_path in ("source/", "results/source/instances/"):
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
    "scale" : "200",
    "xsl" : "ftml",
    "xsl_cols" : "ftml_createListCols"
}

# This arg_lst can be used for debugging
#  but will be replaced by "instances" of template lists (below)
arg_lst = [
    "source/CharisSIL-Regular.ufo",
    "tests/allchars.ftml",
    "-t", "allchars",
    "-f", "C",
    "-i", "source/glyph_data.csv",
    "-s", "../results/CharisSIL-Regular.ttf",
    "--scale", "200",
    "--xsl", "ftml.xsl",
    "-l", "tests/logs/allchars.log",
]

# Templates for arguments to be passed to psfgenftml.py thru sys.argv
# Paths are relative to the directory the script is ran from
#  which is assumed to be the top of the font repo
# Except for the -s arg, which is relative to where the generated ftml is opened from
# Assumes the standard directory structure is present
arg_template_lst = [
    ufo_path + "{ufo_regular}.ufo",
    "tests/{test}.ftml",
    "-t", "{test}",
    "-f", "{font_code}",
    "-i", "source/{glyph_data}.csv",
    "-s", "../results/{ufo_regular}.ttf",
    "--scale", "{scale}",
    "--xsl", "{xsl}.xsl",
    "-l", "tests/logs/{test}.log",
]

# for multi-font tests
arg_cols_template_lst = [
    ufo_path + "{ufo_regular}.ufo",
    "tests/{test}_cols.ftml",
    "-t", "{test}",
    "-f", "{font_code}",
    "-i", "source/{glyph_data}.csv",
#    "-s", "../results/{ufo_regular}.ttf", # multiple "-s" args will be appended for multi-font tests
    "--scale", "{scale}",
    "--xsl", "{xsl_cols}.xsl",
    "-l", "tests/logs/{test}_cols.log",
]

# Call psfgenftml for each test
for test in test_lst:
    arg_values_dict["test"] = test

    # generate single font test
    arg_lst = [arg.format(**arg_values_dict) for arg in arg_template_lst]
    sys.argv = [psfgenftml.__file__]
    sys.argv.extend(arg_lst)
    psfgenftml.cmd()

    # generate multi-font test
    arg_lst = [arg.format(**arg_values_dict) for arg in arg_cols_template_lst]
    for fn in ttf_fn_sort_lst:
        arg_lst.extend(["-s", "../results/{}".format(fn)])
    sys.argv = [psfgenftml.__file__]
    sys.argv.extend(arg_lst)
    psfgenftml.cmd()
