# 2020-03-26
# write add_cv_strs.py:
# extract CV UI strings from makeot.pl and add to _gsub.fea
# resulting _gsub.fea compiles and CV feats look ok in ttx dump
# hand edit CVs 1) with more than one param value, 2) that were not in makeot.pl
# TODO: create better sample text for 1) Mac (0 1) name strings 2) Kayan diac & Viet diac

__copyright__ = 'Copyright (c) 2020 SIL International  (http://www.sil.org)'
__license__ = 'Released under the MIT License (http://opensource.org/licenses/MIT)'
__author__ = 'Alan Ward'

import re

cv_strs_tmpl = """
  cvParameters {{
      FeatUILabelNameID {{
       name 3 1 0x0409 "{0}";  # English US
       name 1 0 0 "{0}";  # Mac English
      }};
      
      FeatUITooltipTextNameID {{
       name 3 1 0x0409 "{1}";  # English US
       name 1 0 0 "{1}";  # Mac English
      }};
      
      SampleTextNameID {{
       name 3 1 0x0409 "{2}";  # English US
       name 1 0 0 "{3}";  # Mac English
      }};
      
      ParamUILabelNameID {{
       name 3 1 0x0409 "{4}";  # English US
       name 1 0 0 "{4}";  # Mac English
      }};
  }};

"""

# makeot_f = open(r"c:\users\wardak\desktop\makeot.pl", "r")
# fea_f = open(r"c:\users\wardak\desktop\CharisSIL_gsub.fea", "r")
# out_f = open(r"c:\users\wardak\desktop\C_gsub_strs.fea", "w", encoding="utf-8")

makeot_f = open(r"makeot.pl", "r")
fea_f = open(r"C:\Users\wardak\Mine\smith_vm\font-andika\tools\Andika_gsub.fea.new", "r")
out_f = open(r"C:\Users\wardak\Mine\smith_vm\font-andika\tools\Andika_gsub_str.fea.new", "w", encoding="utf-8")

makeot_lines = makeot_f.readlines()
makeot_f.close()

# sample of makeot.pl being parsed
## source cv done: v_hook_alts vhk_sub cv62
#my $v_hook_alts_cv = {
#	'glyphs' => [{'base' => 'uni01B2', 'alts' => ['uni01B2.StraightLft', 'uni01B2.StraightLftHighHook']}, 
#		{'base' => 'uni028B', 'alts' => ['uni028B.StraightLft', 'uni028B.StraightLftHighHook']}, 
#		{'base' => 'uni1DB9', 'alts' => ['uni1DB9.StraightLft', 'uni1DB9.StraightLftHighHook']},
#		{'base' => 'uni028B.sc', 'alts' => ['uni028B.StraightLft.sc', 'uni028B.StraightLftHighHook.sc']}],
#	'feature_name' => 'V-hook alternates',
#	'tooltip' => 'V-hook alts',
#	'sample_str' => "\x{01B2}\x{028B}\x{1DB9}", 
#	'param_names' => ['Straight with low hook', 'Straight with high hook'],
#	'characters' => [0x01B2, 0x028B, 0x1DB9],  
#	};

cv_str = {}
cv = None
for ln in makeot_lines:
    if re.search("# source cv done:", ln) and not cv:
        cv = ln[-5:-1]
        cv_str[cv] = {}
        continue

    m = re.search("'feature_name' => '(.*)'", ln)
    if m and cv:
        cv_str[cv]["feat_nm"] = m.group(1)
        continue
        
    m = re.search("'tooltip' => '(.*)'", ln)
    if m and cv:
        cv_str[cv]["tooltip"] = m.group(1)
        continue
        
    m = re.search("'sample_str' => \"(.*)\"", ln)
    if m and cv:    
        cv_str[cv]["sample_text"] = m.group(1)
        continue
        
    m = re.search("'param_names' => \[(.*)\]", ln)
    if m and cv:
        cv_str[cv]["param_nms"] = m.group(1)
        cv = None
        continue

fea_lines = fea_f.readlines()
fea_f.close()

cv = None
for ln in fea_lines:
    out_f.write(ln)
    m = re.search("^feature (cv..)", ln)
    if m:
        cv = m.group(1)
        if cv in cv_str:
            cv_d = cv_str[cv]
            # breakpoint()
            # out_f.write(cv_strs_tmpl)
            sample_str = "".join([chr(int(t[1:-1],16)) for t in cv_d['sample_text'].split(r"\x")[1:]])
            out_f.write(cv_strs_tmpl.format(
                # "feat_nm", 
                cv_d['feat_nm'], 
                # "tooltip", 
                cv_d['tooltip'], 
                # "sample_text", 
                #cv_d['sample_text'], 
                sample_str, 
                "?", 
                # "param_nm"
                ", ".join([s[1:-1] for s in cv_d['param_nms'].split(", ")]), 
                ))
        else:
            out_f.write(cv_strs_tmpl.format("feat_nm", "tooltip", "sample_text", "?", "param_nm"))

out_f.close()
