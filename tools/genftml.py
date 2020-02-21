import sys
import psfgenftml

args = [
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
sys.argv.extend(args)

psfgenftml.cmd()
