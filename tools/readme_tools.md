Shell scripts are often used to call Python scripts with the needed command lines. Some Python scripts lack command line interfaces and use hard-coded values at the start of the file. Such scripts often use files with standardized names. The shell scripts may copy needed input files from their canonical location to the tools folder.

Glpyh classes specified in classes.xml are used in feax where psfmakefea does not generate classes with all the needed glyphs (historically because of differences in processing order between gdl and ot). Some classes and glpyh names (if that seemed more readable than using classes) are hard-coded in feax.

Feat_all.xml is the TypeTuner features file. feature_map.csv contains a mapping from OT features to TypeTuner features settings and is used to generate html that renders tuned fonts beside OT features.

Testing is typically done by opening ftml files directly in a browser. Ftml tests typically include multiple columns of styles and reference fonts. Most tests are generated based on glyph name (usually suffixes), AP names, or Unicode properties. Some tests do use classes specified in classes.xml and a few use hard-code characters.

Ftml tests exist for encoded characters, APs, features, and small caps. (The small caps test was separated from the features test because it includes so many characters. Other features interacting with the smcp feature are included in the features tests). In order to test the APs against all glyphs (not just the encoded ones), feature (and smcp) tests are generated with each AP type.

Run before building as needed (after glyphs added, features changed, etc.): update_source_ftml

update_source_ftml: generates classes.xml, feat_all.xml, and ftml tests
	make_classes: generates classes.xml by running makeromanclasses.py
		makeromanclasses.py: generates classes.xml based on glyph_data.csv and UFO

	build_feat_all_xml: generates feat_all.xml and feature_map.csv
		glyph_data_to_gsi.py: converts glyph_data.csv to xml input file needed by composer.pl
		composer.pl: generates feat_all.xml and feature_map.csv based on glyph_data.csv and UFO
			gsi_dfltvars.xml: input file for composer.pl that supplements glyph_data.csv for encoded glyphs associated with multi-value features
		updateTTfeatnames.py: updates UI strings in feat_all.xml based on featureinfo.yaml
	test_feat_all_xml: tests integrity of feat_all.xml using typetuner to maximally tune a font
	copy_feat_all_xml: copies feat_all.xml and feature_map.xml to source folder

	genftml.py: calls psfgenftml.py to generate ftml tests for all fonts in family
		psfgenftml.py: generates ftml tests based on glyph_data.csv and UFO

Run after building (when all built fonts include feat_all.xml) as needed (when features change, glyphs are added, etc.): ftml2TThtml

ftml2TThtml: generates html in results folder to render tuned fonts and opentype features side-by-side


ftml.xsl: xsl used to render fmtl as html in a browser (referenced from ftml files)
ftml-smith.xsl: xsl used to render ftml in "smith test" generated output (regression testing)
ftml.dtd: could be used to validate ftml


advance_widths.py
compare_anchors.py
glyph_inventory.py

