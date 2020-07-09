#Python script to replace all occurrences of various strings in a text file with 
# string-specific substitutes
#Written to update the ps_name and var_uid elements in the RFS MGI XML file - 14 Aug 2008
#Add a filter to only apply changes to lines in the input file that match the filter
# Added to reverse changes to the var_uid element in the MGI XML file - 20 Oct 2008

__copyright__ = 'Copyright (c) 2019 SIL International  (http://www.sil.org)'
__license__ = 'Released under the MIT License (http://opensource.org/licenses/MIT)'
__author__ = 'Alan Ward'

import re

ifn = r"CharisSIL_gsub.fea"
subfn = r"C_lkup_nm_map.csv.txt"
ofn = r"CharisSIL_gsub.fea.new"
rfn = r"RepFileStrs_C_rpt.txt"
filter_str = "lookup |\}"

ifile = open(ifn, "r")
lines = ifile.readlines()

subf = open(subfn, "r")
subs = subf.readlines()
subf.close()

#use compiled regex for speed
filter_regex = re.compile(filter_str)

regexs = []
for s in subs:
    s = s[:-1] #remove \n
    s1, s2 = s.split(",")
    if not s2:
        continue
    s1, s2 = s2, s1 #csv file contains fields in reverse order
    regexs.append((s1, s2))
regexs.sort(lambda a, b : len(b[0]) - len(a[0])) #sort list based on string length of substitution match
#print(regexs)

ofile = open(ofn, "wb")
rfile = open(rfn, "w")
             
ct = 0
for l in lines:
    ct += 1
    if ct % 1000 == 0:
        print ct
    done = False
    if filter_regex.search(l):
        for r, s in regexs:
            if (re.search(r, l)):
                m = re.sub(r, s, l)
                ofile.write(m)
                print >>rfile, l[:-1], " -> ", m[:-1]
                done = True
                break
    if not done:
        ofile.write(l)

ifile.close()
ofile.close()
rfile.close()
