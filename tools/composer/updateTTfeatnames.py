import xml.etree.ElementTree as ET
import os, re

feat_info_fn = "featureinfo.yaml"
font = "C"
feat_all_in_fn = "feat_all_composer.xml"
feat_all_out_fn = "feat_all_composer_yaml.xml"
feat_map_in_fn = "feature_map.csv"  # can be set to None to disable processing
feat_map_out_fn = "feature_map_yaml.csv"

xml_hdr = '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE all_features SYSTEM "feat_all.dtd">\n'

feat_all_tree = ET.parse(feat_all_in_fn)
feat_all_root = feat_all_tree.getroot()

if feat_map_in_fn:
    feat_map_f = open(feat_map_in_fn, "r")
    feat_map_lines = feat_map_f.readlines()

feat_info_f = open(feat_info_fn, "r")

# for feat_info yaml processing
# tags that are substrings of other tags must come later since the list is used in simplistic search
fields = ["ss_name", "cv_label", "setting_value", 
"tt_name", "tt_value", "tt_setting_name", "tt_setting_tag", "tt_tag", "tag"] 
record_start = "^-\s*tag:"

# find the value after a colon in a line of yaml
def find_value(line):
    return line[line.find(":") + 1 :].strip()

# parse the featureinfo yaml file
feat_info_lines = feat_info_f.readlines()
skip_record = False
feat_info = {}
feature = None
for line in feat_info_lines:
    if line.find("fonts") != -1 and not font in find_value(line):
        skip_record = True
        feature = None
        continue
    if re.search(record_start, line):
        skip_record = False
        if feature and "tt_value" in feature.keys(): # do not store records the have no tt_* fields
            if not feature["tt_value"] in feature["tt_setting_name"]:
                print(f"**for feature {feature[tag]} tt_value {feature[tt_value]} does not match any tt_setting_name")
            feat_info[feature["tt_tag"]] = feature
        elif feature:
            print(f"feature {feature['tag']} in feature info has no tt_value field")
        feature = {}
    if skip_record:
        continue
    for field in fields:
        if line.find(field) != -1:
            value = find_value(line)
            if field.find("setting") == -1:
                feature[field] = value
            else:
                feature.setdefault(field, []).append(value)
            break
# store last record if needed
if feature:
    if not feature["tt_value"] in feature["tt_setting_name"]:
        print(f"**for feature {feature[tag]} tt_value {feature[tt_value]} does not match any tt_setting_name")
    feat_info[feature["tt_tag"]] = feature

for feat in feat_info:
    # for each record in the feature info yaml, modify the typetuner features xml file
    print(f"feat: {feat}")
    feature_lst = feat_all_root.findall(f"./feature[@tag='{feat}']")
    if len(feature_lst) == 0:
        print(f"** no <feature> matches tt_tag {feat} used by feature info tag {feat_info[feat]['tag']}")
        continue
    if len(feature_lst) > 1:
        print(f"** more than one feature matches tt_tag {feat}")
        continue
    el = feature_lst[0] # <feature> nodes in the feal_all xml file
    el.set("value", feat_info[feat]["tt_value"])
    el.set("name", feat_info[feat]["tt_name"])
    i = 0
    for value_name in feat_info[feat]["tt_setting_name"]:
        if int(feat_info[feat]["setting_value"][i]) != i:
            print(f"** setting_values for feature {feat} must be sequential starting from zero")
        el[i].set("name", value_name) # <value> sub node under <feature> elements in the xml file
        # cannot do the below unlesss the tags in the <interactions> section are changed also
        # el[i].set("tag", feat_info[feat].tt_setting_tag[i])
        feat_all_tag = el[i].attrib["tag"]
        feat_info_tag = feat_info[feat]["tt_setting_tag"][i]
        # if feat_all_tag != "Dflt" and feat_all_tag != feat_info_tag:
        if feat_all_tag != feat_info_tag:
            print(f"for feature {feat}: value tag {feat_all_tag} does not match feature info {feat_info_tag}")
        i += 1

    # modify the feature map file
    if not feat_map_in_fn:
        continue
    tag = feat_info[feat]["tag"]
    for (ix, line) in enumerate(feat_map_lines):
        map_tag = line.split(",")[0]
        if map_tag == f'"{tag}"':
            new_line = f'"{tag}"'
            new_line += f',"{feat_info[feat]["tt_name"]}"'
            if font != "A" or tag != "ss01":
                for set_nm in feat_info[feat]["tt_setting_name"]:
                    new_line += f',"{set_nm}"'
            else: #if font == "A" and tag == "ss01":
                for set_nm in feat_info[feat]["tt_setting_name"][::-1]: # reverse the list
                    new_line += f',"{set_nm}"'
            feat_map_lines[ix] = new_line + "\n"
            break

feat_all_tree.write(feat_all_out_fn + ".tmp", encoding = "UTF-8", xml_declaration = False)
input_f = open(feat_all_out_fn + ".tmp", "r")
output_f = open(feat_all_out_fn, "w")
output_f.write(xml_hdr)
lines = input_f.readlines()
output_f.writelines(lines)
output_f.write("\n")
output_f.close()
input_f.close()
os.remove(feat_all_out_fn + ".tmp")

output_f = open(feat_map_out_fn, "w")
output_f.writelines(feat_map_lines)
feat_map_f.close()

feat_info_f.close()
