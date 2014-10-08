# Python script to add character variant features to makeot.pl
# Templates for the features are stored in this file
# makeot.pl contains special comments that 
#  1) specify the field values for the templates and 
#  2) indicate where to insert the templates (place holders)
# makeot.pl also contains the essential data that specify cv feature content
# The generated makeot.pl file will contain TODO_cv comments that 
#  indicate where hand edits are needed
# the special comments that specify the field values are retained but marked so they will be ignored
#  if this script is ran on the generated makeot.pl
#  this retains the field values for generated char var features and allows new cv feats to be added

in_file = open("makeot.pl", "r")
out_file = open("makeot_cvs.pl", "w")

makeot_lines = in_file.readlines()
in_file.close()

class cv_info:
	def __init__(self, data_nm, lookup_nm, feature_nm):
		self.data_nm, self.lkup_nm, self.feat_nm = (data_nm, lookup_nm, feature_nm)
		
cv_info_lst = []

for line in makeot_lines: 

	# parse the template field values
	# source cv insert: cap_y_hook_alts yhk_sub cv11"
	if (line.find("# source cv insert:") != -1):
		#print line
		cv_data_nm, cv_lookup_nm, cv_feature_nm = line.split()[4:]
		cv_info_lst.append(cv_info(cv_data_nm, cv_lookup_nm, cv_feature_nm))
		line_tmp = line.replace("source cv insert", "source cv done")
		out_file.write(line_tmp)
		continue #don't write cv source info

	# template for creating Perl OT data structs
	tmp_str = '''\
my $%s_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $%s_action = [];
my $%s_parms = Font::TTF::Features::Cvar->new();
'''
	if (line.find("# insert OT cv structs") != -1):
		for cv in cv_info_lst:
			out_file.write(tmp_str % (cv.data_nm, cv.data_nm, cv.data_nm))   
		out_file.write(line)
		continue
	
	# template that calls a function that connects the OT data structures to cv feat data
	tmp_str = "add_cv_feat($%s_cv, \\$nid, $%s_cover, $%s_action, $%s_parms);\n"
	if (line.find("# insert add_cv_feat calls") != -1):
		for cv in cv_info_lst:
			out_file.write(tmp_str % (cv.data_nm, cv.data_nm, cv.data_nm, cv.data_nm))   
		out_file.write(line)
		continue

	# template to insert cv lookup tags that must parallel the GSUB lookups
	tmp_str = ""
	if (line.find("# insert cv lookup tags (format later by hand)") != -1):
		for cv in cv_info_lst:
			tmp_str += cv.lkup_nm + " "
		if tmp_str:
			out_file.write("#TODO_cv: format the below line by hand\n")
			out_file.write(tmp_str[:-1] + "\n") #slice off last space
		out_file.write(line)
		continue

	# template for a cv GSUB lookup
	tmp_str = '''\
        'TYPE' => 3,                            # %s: TODO_cv: add descriptive label
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $%s_cover,
            'RULES' => $%s_action
    }]}, {

'''
	if (line.find("# insert cv lookups") != -1):
		for cv in cv_info_lst:
			out_file.write(tmp_str % (cv.lkup_nm, cv.data_nm, cv.data_nm))
		out_file.write(line)
		continue
		
	# template to add cv feature tags to various lists of features
	tmp_str = ""
	if (line.find("# insert cv feature tags in features list") != -1):
		#there should be six place holders
		for cv in cv_info_lst:
			tmp_str += "'%s', " % cv.feat_nm
		if tmp_str:	
			out_file.write("#TODO_cv: format the below line\n")
			out_file.write(tmp_str + "\n")
		out_file.write(line)
		continue
		
	# template to create a cv feature
	tmp_str = "    '%s' => {'PARMS' => $%s_parms, 'LOOKUPS' => [lk('%s')]},"
	if (line.find("# insert cv features") != -1):
		for cv in cv_info_lst:
			out_file.write(tmp_str % (cv.feat_nm, cv.data_nm, cv.lkup_nm) + "\n")
		out_file.write(line)
		continue			

	out_file.write(line)

out_file.close()	
