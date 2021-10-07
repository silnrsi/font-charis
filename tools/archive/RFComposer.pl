# Copyright (c) 2007-2021 SIL International  (http://www.sil.org)
# Released under the MIT License (http://opensource.org/licenses/MIT)

#Script to create a template for the TypeTuner feat_all.xml file for our Roman fonts.
# I should have written this in Python. I could have parsed the features.gdh file myself
# instead of using Font::TTF to get the info from the font.

use strict;
use warnings;

use Font::TTF::Font;
use XML::Parser::Expat;
use Getopt::Std;

#### global variables & constants ####

my $version = "1.7";
#1.7 - add feature reduction rules. add special processing for Andika (because of "backwards" literacy feature
#1.6 - handle four char Graphite feature tags in MGI and corresponding large integers in font
#1.5 - add mechanism to handle glyphs with a suffix but no corresponding feature setting (eg LtnCapYHook.RtHook)
#      select glyphs based on exact number of ps name suffixes indicated by feature settings
#1.4 - add mechanism to map interacting features to a simpler, equivalent form
#1.3 - output old_names section
#1.2 - generate WPFeatures test
#1.1 - handle arbitrary interacting features

# This is the version that goes in feat_all.xml file header.
#   I think it should only change if the way that the xml has to be parsed changes
#    and by more than adding optional elements.
#   The features & settings will indicate what font version the feat_all.xml file goes with.
my $xml_version = "1.0";

#$opt_a - andika processing
#$opt_d - debug output
#$opt_g - output only graphite cmds
#$opt_q - output no graphite cmds
#$opt_t - output <interaction> encode cmds w/o choices for PS name for testing TypeTuner
#$opt_l - list features and settings to a file to help create %nm_to_tag map
#$opt_w - generate a WorldPad file for testing Graphite features TODO: make this a different program
#$opt_z - hook for ad hoc subroutine to analyze parsed glyph data, does NOT produce an output file
our($opt_a, $opt_d, $opt_g, $opt_q, $opt_t, $opt_l, $opt_w, $opt_z); #set by &getopts:
my $opt_str = 'adgqtlw:z';
my $featset_list_fn = 'featset_list.txt';

my $feat_all_base_fn = 'feat_all_composer.xml';
my $feat_all_elem = "all_features";

#all the ids must be 4 chars
my $vietnamese_style_diacs_feat = 'viet';
my $romanian_style_diacs_feat = 'romn';

#generated using the -l switch 
# then copying & pasting the file produced into this file.
# *** Be sure to compare this list to the generated one so as to not lose some tags
#     ie if working on Doulos don't lose the Andika ones.
# "Show deprecated PUA" data retained for now to handle old Feat tables in fonts
# used calls to &Tag_get to create initially then commented them out
# and now use &Tag_lookup calls to maintain
#add revised feature values created for OT char variants. map them to old tags (T or F)
# not as pretty as mapping to descriptive tags but minimizes changes.
# old_names maps the old feature value strings to the new tags (which are the same as old tags)
#  old_names elements are not needed to map old "True" value to "T" even if new value maps to "T"
#modify feature values for 9-level pitches, J-stroke hook alt, V-hook alts, 
# Modifier colon alt, Non-European caron alts, Serif beta alts 
# (where feature.gdh did not match Features.xls)
# as above for OT char variants
#add revised feature values for Andika
# as above for OT char variants but some feature values already were in use 
# so had to also modify featset_to_suffix and reduced_featsets for different value tags
#add Capital J alternate for Andika Basics (will eventually be in all fonts)
# map values to T and F to be like other char variants
my %nm_to_tag = (
	'False' => 'F',
	'True' => 'T',
	'Tone numbers' => 'TnNmbr',
	'Bars' => 'F',
	'Numbers' => 'T',
	'Hide tone contour staves' => 'TnStvsHd',
	'9-level pitches' => 'NineLvl',
	'No tramlines' => 'Lgt',
	'Tramlines' => 'TrmLn',
	'Non-ligated with no tramlines' => 'NoLgt',
	'Non-ligated with tramlines' => 'TrmLnNoLgt',
	'Vietnamese-style diacritics' => 'VIEdiacs',
	'Vietnamese-style' => 'T',
	'Romanian-style diacritics' => 'RONdiacs',
	'Chinantec tones' => 'CHZtn',
	'Chinantec-style' => 'T',
	'Bridging diacritics' => 'BrdgDiacs',
	'Barred-bowl forms' => 'BarBwl',
	'Barred-bowl' => 'T',
	'Literacy alternates' => 'Lit',
	'Slant italic specials' => 'SlntItlc',
	'Uppercase Eng alternates' => 'Eng',
	'Large eng with descender' => 'LgDsc',
	'Large eng on baseline' => 'LgBsln',
	'Capital N with tail' => 'CapN',
	'Large eng with short stem' => 'LgShrtStm',
	'Rams horn alternates' => 'RmHrn',
	'Small bowl' => 'Sm',
	'Large bowl' => 'Lrg',
	'Small gamma' => 'Gma',
	'Ogonek alternate' => 'Ognk',
	'Curved' => 'Crv',
	'Straight' => 'Strt',
	'Capital B-hook alternate' => 'LrgBHk',
	'Capital H-stroke alternate' => 'LgHStrk',
	'Horizontal-stroke' => 'Hrz',
	'Vertical-stroke' => 'Vrt',
	'J-stroke hook alternate' => 'JStrk',
	'No top serif' => 'NoSrf',
	'Top serif' => 'TopSrf',
	'Capital N-left-hook alternate' => 'LgNLftHk',
	'Uppercase style' => 'Uc',
	'Lowercase style' => 'Lc',
	'Open-O alternate' => 'OpnO',
	'Bottom serif' => 'BtmSrf',
	'Small p-hook alternate' => 'SmPHk',
	'Left hook' => 'LftHk',
	'Right hook' => 'RtHk',
	'Capital R-tail alternate' => 'LgRTl',
	'Capital T-hook alternate' => 'LgTHk',
	'V-hook alternates' => 'VHk',
	'Curved' => 'Crvd', 
	'Straight with low hook' => 'StrtLftLowHk',
	'Straight with high hook' => 'StrtLftHk',
	'Capital Y-hook alternate' => 'LgYHk',
	'Small ezh-curl alternate' => 'SmEzhCrl',
	'Capital Ezh alternates' => 'LgEzh',
	'Normal' => 'Nrml',
	'Reversed sigma' => 'RvSgma',
	'OU alternates' => 'Ou',
	'Closed' => 'Clsd',
	'Open' => 'Opn',
	'Mongolian-style Cyrillic E' => 'CyrE',
	'Mongolian-style' => 'T',
	'Modifier apostrophe alternates' => 'ModAp',
	'Small' => 'Sm',
	'Large' => 'Lg',
	'Modifier colon alternate' => 'ModCol',
	'Tight' => 'Tght',
	'Expanded' => 'Wd',
	'Non-European caron alternates' => 'Caron',
	'European style' => 'F',
	'Non-European style' => 'T',
	'Combining breve Cyrillic form' => 'CmbBrvCyr',
	'Cyrillic-style' => 'T',
	'Cyrillic shha alternate' => 'CyShha',
	'Empty set alternates' => 'EmpSet',
	'Circle' => 'Crcl',
	'Zero' => 'Zro',
	'Small Caps' => 'SmCp',
	'Low-profile diacritics' => 'LpDiacs',
	'Serbian-style alternates' => 'Serb', 
	'Serif beta alternates' => 'BetaSerif',  
	'No serif' => 'F',
	'Serif' => 'T',
	'Show deprecated PUA' => 'DepPUA',
	'None' => 'none',
	'Through Unicode 4.0' => '40',
	'Through Unicode 4.1' => '41',
	'Through Unicode 5.0' => '50',
	'Through Unicode 5.1' => '51',
	'Show invisible characters' => 'ShwInv',
	'Digit Zero with slash' => 'Dig0',
	'No slash' => 'F',
	'Slash' => 'T',
	'Digit One without base' => 'Dig1',
	'Base' => 'F',
	'No base' => 'T',
	'Digit Four with open top' => 'Dig4',
	'Digit Six and Nine alternates' => 'Dig69',
	'Curved stem' => 'F',
	'Diagonal stem' => 'T',
	'Digit Seven with bar' => 'Dig7',
	'No bar' => 'F',
	'Bar' => 'T',
	'Small i-tail alternate' => 'SmITail',
	'Curved tail' => 'CrvTl',
	'Capital J alternate' => 'CapJ',
	'No top bar' => 'F',
	'Top bar' => 'T',
	'Small j-serif alternate' => 'SmJSerif',
	'Small l-tail alternate' => 'SmLTail',
	'Capital Q alternate' => 'CapQ',
	'Tail' => 'F',
	'Tail across' => 'T',
	'Small q-tail alternate' => 'SmQTail',
	'Point' => 'T',
	'Small t-tail alternate' => 'SmTTail',
	'Small y-tail alternate' => 'SmYTail',
	'Capital D-hook alternate' => 'LgDHk',
	'Porsonic circumflex' => 'PorCirc', 
	'Porsonic-style' => 'Por',
	'Diacritic selection' => 'DiacSlct',
	'Line spacing' => 'LnSpc',
	'Loose' => 'Ls',
	'Imported' => 'Im',
);

#map feature settings to PS names using regex matching
#the (?! ... ) regex below is a negative look ahead match
#mappings that are missing below will be output as error messages
#*** Be careful to not discard tags needed by fonts other than the one being worked on
# "Show deprecated PUA" data retained for now to handle old MGI data
my %featset_to_suffix = (
	'BarBwl-T' => '\.BarBowl', 
	'Caron-T' => '\.Caron', 
	'CyShha-Uc' => '\.UCStyle', 
	'CyrE-T' => '\.MongolStyle', 
	'Lit-T' => '(\.SngBowl|\.SngStory)',
	'Lit-F' => '^[a-zA-Z0-9]+(\.|$)(?!SngBowl|SngStory)', 
	'ModAp-Lg' => '\.Lrg', 
	'Ognk-Strt' => '\.RetroHook', 
	'OpnO-TopSrf' => '\.TopSerif', 
	'Ou-Opn' => '\.OpenTop', 
	'RONdiacs-T' => '\.CommaStyle', 
	'SlntItlc-T' => '(\.SItal|\.2StorySItal)', 
#	'SmCp-T' => '\.SC',
	'SmCp-T' => '\.sc',
	'SmPHk-RtHk' => '\.BowlHook', 
	'VHk-Crvd' => '(uni01B2|uni028B)(?!\.StraightLftHighHook|\.StraightLft)',  
	'VHk-StrtLftLowHk' => '\.StraightLft', 
	'VHk-StrtLftHk' => '\.StraightLftHighHook', 
	'VIEdiacs-T' => '\.VN',
	'DepPUA-41' => '\.Dep41', 
	'DepPUA-50' => '\.Dep50', 
	'DepPUA-51' => '\.Dep51', 
	'BrdgDiacs-T' => '(\.UU|\.UL|\.LL)',
	'Eng-LgDsc' => '[eE]ng(?!\.UCStyle|\.BaselineHook|\.Kom)', 
	'Eng-LgBsln' => '\.BaselineHook', 
	'Eng-CapN' => '\.UCStyle', 
	'Eng-LgShrtStm' => '\.Kom',
	'LgEzh-RvSgma' => '\.RevSigmaStyle',
	'LgHStrk-Vrt' => '\.VertStrk',
	'LgNLftHk-Lc' => '\.LCStyle',
	'LgRTl-Lc' => '\.LCStyle',
	'LgTHk-RtHk' => '\.RtHook',
	'LgYHk-RtHk' => '\.RtHook', #in %glyph_to_featset
	'LgYHk-LftHk' => '(uni01B4|uni01B3)(?!\.RtHook)',
	'LrgBHk-Lc' => '\.TopBar',
	'LpDiacs-T' => '\.LP',
	'CHZtn-T' => '\.ChinantecTn',
	'Serb-T' => '\.Serb',
	'BetaSerif-T' => '\.Serif',
	'SmITail-CrvTl' => '\.TailI',
	'SmJSerif-TopSrf' => '\.TopLftSerif',
	'SmLTail-CrvTl' => '\.TailL',
	'CapQ-T' => '\.DiagTail',  
	'SmQTail-T' => '\.Point', 
	'SmTTail-Strt' => '\.NoTailT', 
	'SmYTail-Strt' => '\.NoTailY', 
	'LgDHk-Lc' => '\.TopBar', 
	'PorCirc-PorStyle' => '\.Por', 
);

#map one set of feature settings to a simpler set
# each simpler set is used to search for a matching glyph before it's reduced again
# so stepwise simplification is good
# small caps negates literacy alts, slant italics, and
# usually low profile diacritics (since low profile composites for small caps weren't built) 
# (though three *.LP.SC glyphs exist in Gentium, which are found as searching is done)
# literacy negates slant italics
# Chinantec tones negates low profile diacritics
# small caps negate the lower case tail variants
my %reduced_featsets = (
    'CapQ-T SmQTail-T' => 'SmQTail-T', # lower case glyph not affected by Capital Q alternate
    'Caron-T SmCp-T' => 'SmCp-T', 
    'CHZtn-T LpDiacs-T' => 'CHZtn-T',
    'CyShha-Uc SmCp-T' => 'SmCp-T', 
    'LgTHk-RtHk SmTTail-Strt' => 'SmTTail-Strt', # lower case glyph not affected by Capital T-hook alternate
    'LgYHk-LftHk SmYTail-Strt' => 'SmYTail-Strt', # lower case glyph not affected by Capital Y-hook alternate
    'Lit-T SlntItlc-T' => 'Lit-T', 
    'Lit-T SmCp-T' => 'SmCp-T', 
    'LpDiacs-T SmCp-T' => 'SmCp-T',
    'LrgBHk-Lc SmCp-T' => 'SmCp-T', 
    'Serb-T SmCp-T' => 'SmCp-T', 
    'SlntItlc-T SmCp-T' => 'SmCp-T', 
    'SlntItlc-T SmITail-CrvTl' => 'SmITail-CrvTl', # for Andika Reg, which lacks some SlantItalic glyphs
    'SlntItlc-T SmLTail-CrvTl' => 'SmLTail-CrvTl', # for Andika Reg, which lacks some SlantItalic glyphs
    'SmCp-T SmITail-CrvTl' => 'SmCp-T',  
    'SmCp-T SmJSerif-TopSrf' => 'SmCp-T',  
    'SmCp-T SmLTail-CrvTl' => 'SmCp-T',
    'SmCp-T SmPHk-RtHk' => 'SmCp-T', 
    'SmCp-T SmQTail-T' => 'SmCp-T',  
    'SmCp-T SmTTail-Strt' => 'SmCp-T',  
    'SmCp-T SmYTail-Strt' => 'SmCp-T',
    'CapQ-T SmCp-T SmQTail-T' => 'CapQ-T SmCp-T',
    'Caron-T SmCp-T SmLTail-CrvTl' => 'Caron-T SmCp-T', 
    'Caron-T SmCp-T SmTTail-Strt' => 'Caron-T SmCp-T', 
    'LgTHk-RtHk SmCp-T SmTTail-Strt' => 'LgTHk-RtHk SmCp-T', 
    'LgYHk-LftHk SmCp-T SmYTail-Strt' => 'LgYHk-LftHk SmCp-T', 
    'Lit-T LpDiacs-T SlntItlc-T' => 'Lit-T LpDiacs-T', 
    'Lit-T LpDiacs-T SmCp-T' => 'LpDiacs-T SmCp-T', #above
	'Lit-T Ognk-Strt SlntItlc-T' => 'Lit-T Ognk-Strt', #new
	'Lit-T Ognk-Strt SmCp-T' => 'Ognk-Strt SmCp-T', 
    'Lit-T SlntItlc-T SmCp-T'=> 'SmCp-T', 
    'Lit-T SlntItlc-T VIEdiacs-T' => 'Lit-T VIEdiacs-T', 
    'Lit-T SmCp-T VIEdiacs-T' => 'SmCp-T VIEdiacs-T', 
    'LpDiacs-T Ognk-Strt SmCp-T' => 'Ognk-Strt SmCp-T', 
    'LpDiacs-T SlntItlc-T SmCp-T' => 'LpDiacs-T SmCp-T', #above
    'LpDiacs-T SmCp-T VIEdiacs-T' => 'SmCp-T VIEdiacs-T', 
	'Ognk-Strt SlntItlc-T SmCp-T' => 'Ognk-Strt SmCp-T', #new
    'Ognk-Strt SmCp-T SmITail-CrvTl' => 'Ognk-Strt SmCp-T', 
    'RONdiacs-T SmCp-T SmTTail-Strt' => 'RONdiacs-T SmCp-T',
    'SlntItlc-T SmCp-T VIEdiacs-T' => 'SmCp-T VIEdiacs-T', 
    'SlntItlc-T SmCp-T SmITail-CrvTl' => 'SmCp-T SmITail-CrvTl', #above
    'SlntItlc-T SmCp-T SmLTail-CrvTl' => 'SmCp-T SmLTail-CrvTl', #above
    #below line not needed with code to convert Lit-T to Lit-F for Andika processing
    #'Lit-F SlntItlc-T SmCp-T VIEdiacs-T' => 'SmCp-T VIEdiacs-T', #Lit-F is non-default value for Andika
    'Lit-T LpDiacs-T SlntItlc-T SmCp-T' => 'LpDiacs-T SmCp-T', #above
	'Lit-T LpDiacs-T SlntItlc-T VIEdiacs-T' => 'Lit-T LpDiacs-T VIEdiacs-T', 
    'Lit-T LpDiacs-T SmCp-T VIEdiacs-T' => 'LpDiacs-T SmCp-T VIEdiacs-T', #above
    'Lit-T SlntItlc-T SmCp-T VIEdiacs-T' => 'SmCp-T VIEdiacs-T', 
    'LpDiacs-T SlntItlc-T SmCp-T VIEdiacs-T' => 'LpDiacs-T SmCp-T VIEdiacs-T', #above
    'Lit-T LpDiacs-T SlntItlc-T SmCp-T VIEdiacs-T' => 'LpDiacs-T SmCp-T VIEdiacs-T', #above
	'Lit-T Ognk-Strt SlntItlc-T SmCp-T' => 'Lit-T Ognk-Strt SmCp-T', #new, above
);

#specify glyph variants which have a suffix but no corresponding non-default feature setting
# such LtnSmYHook.RtHook.* variants 
#  LtnSmYHook.RtHook is encoded, LtnSmYHook is selected by LgYHk-LftHk; LtnSmYHook.RtHook.SC is the small cap variant
#dflt specifies an implicit feature setting, which would be default setting
#if a feature is set to one the of the alts values, then the dflt featset is not used
my %glyph_to_featset = (
	'uni01B4' => {('dflt' => 'LgYHk-RtHk', 'alts' => [('LgYHk-LftHk')])}, #LtnSmYHook
	'uni01B3' => {('dflt' => 'LgYHk-RtHk', 'alts' => [('LgYHk-LftHk')])}, #LtnCapYHook
);

#add implicit Lit-T to literacy glyphs for Andika - {dft} & {alts} are merged with the above
#also add encoding info for literacy glyphs that are encoded in Andika (with no var_uid element)
# assumes literacy glyph name is built from key plus {lit}[1] and encoded as {lit}[0]
# no check is made against the actual data
# below uni01E5.BarBowl.SngBowl is the literacy form for uni01E5 (uni01E5.SngBowl doesn't exist)
my %glyph_to_featset_andika = (
	'a' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0061', 'SngStory'])}, 
	'aacute' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['00E1', 'SngStory'])}, 
	'abreve' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0103', 'SngStory'])}, 
	'acircumflex' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['00E2', 'SngStory'])}, 
	'adieresis' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['00E4', 'SngStory'])}, 
	'agrave' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['00E0', 'SngStory'])}, 
	'amacron' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0101', 'SngStory'])}, 
	'aogonek' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0105', 'SngStory'])}, 
	'aring' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['00E5', 'SngStory'])}, 
	'aringacute' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['01FB', 'SngStory'])}, 
	'atilde' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['00E3', 'SngStory'])}, 
	'g' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0067', 'SngBowl'])}, 
	'gbreve' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['011F', 'SngBowl'])}, 
	'gcaron' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['01E7', 'SngBowl'])}, 
	'gcircumflex' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['011D', 'SngBowl'])}, 
	'gcommaaccent' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0123', 'SngBowl'])}, 
	'gdotaccent' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0121', 'SngBowl'])}, 
	'uni01CE' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['01CE', 'SngStory'])}, 
	'uni01DF' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['01DF', 'SngStory'])}, 
	'uni01E1' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['01E1', 'SngStory'])}, 
	'uni01E5' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['01E5', 'BarBowl.SngBowl'])}, 
	'uni01F5' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['01F5', 'SngBowl'])}, 
	'uni0201' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0201', 'SngStory'])}, 
	'uni0203' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0203', 'SngStory'])}, 
	'uni0227' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0227', 'SngStory'])}, 
	'uni0363' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['0363', 'SngStory'])}, 	
	'uni1D43' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1D43', 'SngStory'])}, 
	'uni1D4D' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1D4D', 'SngBowl'])}, 
	'uni1E01' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1E01', 'SngStory'])}, 
	'uni1E21' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1E21', 'SngBowl'])}, 
	'uni1E9A' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1E9A', 'SngStory'])}, 
	'uni1EA1' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EA1', 'SngStory'])}, 
	'uni1EA3' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EA3', 'SngStory'])}, 
	'uni1EA5' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EA5', 'SngStory'])}, 
	'uni1EA7' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EA7', 'SngStory'])}, 
	'uni1EA9' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EA9', 'SngStory'])}, 
	'uni1EAB' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EAB', 'SngStory'])}, 
	'uni1EAD' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EAD', 'SngStory'])}, 
	'uni1EAF' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EAF', 'SngStory'])}, 
	'uni1EB1' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EB1', 'SngStory'])}, 
	'uni1EB3' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EB3', 'SngStory'])}, 
	'uni1EB5' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EB5', 'SngStory'])}, 
	'uni1EB7' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['1EB7', 'SngStory'])}, 
	'uni2090' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['2090', 'SngStory'])}, 
	'uni2C65' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['2C65', 'SngStory'])}, 
	'uniA7A1' => {('dflt' => 'Lit-T', 'alts' => [('Lit-F')], 'lit' => ['A7A1', 'SngBowl'])}, 
);

#adjust data structures for Andika processing
#necessary because Andika has the literacy feature on by default
sub Andika_adjust()
{
	if ($opt_a)
	{
		#change Lit-T to Lit-F in %reduced_featsets for Andika
		# since Lit-T is the default, "setting" the literacy feature means applying Lit-F
		#retain the Lit-T reduction rules to handle the Lit-T added to literacy glyphs
		foreach my $key (keys %reduced_featsets)
		{
			my $new_key = $key;
			$new_key =~ s/(.*?)(Lit-T)(.*?)/$1Lit-F$3/;
			my $new_value = $reduced_featsets{$key};
			$new_value =~ s/(.*?)(Lit-T)(.*?)/$1Lit-F$3/;
			
            #removing Lit-F from Andika implies a glyph with no literacy setting is wanted
            # which means one with Lit-T (since that's the default), so don't remove Lit-F
            #RFComposer sort of worked without this previously because
            # literacy suffixes are regarded as extras when searching candidate glyphs for a given USV
            # which avoids applying Lit-T as the default
            # (ie the candidate selection algo acted as if Lit-F was present)
			if ($new_key =~ /Lit-F/ and not $new_value =~ /Lit-F/)
			{
				my @new_value_lst = split(/ /, $new_value);
				push(@new_value_lst, 'Lit-F');
				@new_value_lst = sort @new_value_lst;
				$new_value = join(' ', @new_value_lst);
			}
			
			if ($new_key ne $key and $new_key ne $new_value)
			{
				$reduced_featsets{$new_key} = $new_value;
			}
	    }
	
		#implicitly apply Lit-T when 'a' and 'g' (and related chars) are being processed
		#add data from %glyph_to_featset_andika to %glyph_to_featset
		foreach my $key (keys %glyph_to_featset_andika)
		{
			$glyph_to_featset{$key} = $glyph_to_featset_andika{$key};
		}
	}
}

#### subroutines ####

my (%tags, $prev_feat_tag); #used only by two below sub
sub Tag_get($$)
#get a tag for a given string
#second arg indicates a feature (2) or a setting (1)
#assumes feature tags are created before setting tags
{
	my ($str, $cnt) = @_;
	my ($tmp);

	$tmp = $str;
	$tmp =~ s/\s//;
	$tmp = substr($tmp, 0, $cnt);
	
	if ($cnt == 1)
	{#setting tags
		$tmp = lc($tmp);
		while (defined($tags{$prev_feat_tag}{'settings'}{$tmp}))
			{substr($tmp, -1, 1, chr(ord(substr($tmp, -1, 1)) + 1));} #changes A to B
		$tags{$prev_feat_tag}{'settings'}{$tmp} = $str;
	}
	elsif ($cnt == 2)
	{#feature tags
		if ($tmp eq '9-') {$tmp = 'NI'} #kludge for '9-level pitches' feature
		$tmp = uc($tmp);
		while (defined($tags{$tmp}))
			{substr($tmp, -1, 1, chr(ord(substr($tmp, -1, 1)) + 1));} #changes AA to AB
		$tags{$tmp} = {'str' => $str}; #might as well store something useful
		$prev_feat_tag = $tmp;
	}
	else {die("invalid second arg to Tag_get: $cnt\n");}
	
	return $tmp;
}

sub Tag_lookup($\%)
#lookup name in name-to-tag map and return tag
#generate a new tag if name isn't in map
{
	my ($name, $nm_to_tag) = @_;
	if (defined $nm_to_tag->{$name})
	{
		$tags{$nm_to_tag->{$name}} = {'str' => $name}; #insures Tag_get tags are unique
		return $nm_to_tag->{$name};
	}
	else
	{
		print "*** new name found so generating a tag - name:$name\n";
		return Tag_get($name, 2); #always get two-letter tags
	}
}

sub Feats_get($\%\%)
#create the %feats structure based on the Feat table in the font
# 2012-10-26 AW: store four char GDL feature tags in %feats structure
#   instead of actual id from font
{
	my ($font_fn, $feats, $gdl_tag_to_feat_id) = @_;
	my ($font, $GrFeat_tbl);

	$font = Font::TTF::Font->open($font_fn) or die "Can't open font";
	$GrFeat_tbl = $font->{'Feat'}->read;
	#$GrFeat_tbl->print;
	
	my ($feat, $feat_id, $gdl_tag, $set_id, $feat_nm, $set_nm, $feat_tag, $set_tag);
	foreach $feat (@{$GrFeat_tbl->{'features'}})
	{
		$feat_id = $feat->{'feature'};
		foreach $set_id (sort keys %{$feat->{'settings'}})
		{
			if ($feat_id == 1) {next;} #skip over weird last feature in Feat table
			($feat_nm, $set_nm) = $GrFeat_tbl->settingName($feat_id, $set_id);
			$gdl_tag = Font::TTF::GrFeat->num_to_tag($feat_id);
			$gdl_tag_to_feat_id->{$gdl_tag} = $feat_id;
			
			if (not defined $feats->{$gdl_tag})
			{# this could go in the outer loop
			 #  but it is nice after the settingName call
				$feat_tag = Tag_lookup($feat_nm, %nm_to_tag); #$feat_tag is a TypeTuner tag
				$feats->{$gdl_tag}{'name'} = $feat_nm;
				$feats->{$gdl_tag}{'tag'} = $feat_tag;
				$feats->{$gdl_tag}{'default'} = $feat->{'default'};
				if (not defined($feats->{' ids'}))
					{$feats->{' ids'} = [];}
				push(@{$feats->{' ids'}}, $gdl_tag);
			}
			
			$set_tag = Tag_lookup($set_nm, %nm_to_tag);
			$feats->{$gdl_tag}{'settings'}{$set_id}{'name'} = $set_nm;
			$feats->{$gdl_tag}{'settings'}{$set_id}{'tag'} = $set_tag;
			if (not defined($feats->{$gdl_tag}{'settings'}{' ids'}))
				{$feats->{$gdl_tag}{'settings'}{' ids'} = [];}
			push(@{$feats->{$gdl_tag}{'settings'}{' ids'}}, $set_id);
		}
	}
	
	$font->release;
	
	if ($opt_d)
	{
		foreach $feat_id (@{$feats->{' ids'}})
		{
			my $feat_t = $feats->{$feat_id};
			my ($tag, $name, $default) = ($feat_t->{'tag'}, $feat_t->{'name'}, 
										  $feat_t->{'default'});
			print "feature: $feat_id tag: $tag name: $name default: $default\n";
			foreach $set_id (@{$feats->{$feat_id}{'settings'}{' ids'}})
			{
				my $set_t = $feat_t->{'settings'}{$set_id};
				($tag, $name) = ($set_t->{'tag'}, $set_t->{'name'});
				print "  setting: $set_id tag: $tag name: $name\n";
			}
		}
	}
}

sub Combos_get(@)
#input is an array of elements
#enumerate all combinations of the elements (with no repetition of an element in a combination)
#return an array of references to arrays where each array enumerates a combination
# eg [1,2,3] -> [[1],[2],[3],[1,2],[1,3],[2,3],[1,2,3]]
#the algorithm works by creating single combos from the input array
# then combining the first combo with each element of the input array skipping over the first
# then combining the second combo with each element of the input skipping over the first & second
# and repeating until all pair combos have been found
#then the same thing is done to combine all pair combos with elements of the input array to create triplets
#the index of the last input element to be added to a combination is kept to avoid creating combos
# that already exist
#then the same thing is done with all triplets to generate quads, and so on
{
	my (@element) = (@_);
	my ($u, $v, $w, $i, @combos, $combo_ix); 
	
	#each @combo element will be a ref to an array of refs to hashes
	# the hashes will contain a ref to 1) an array that contains a combination 
	# and 2) an ix that gives the index in the input array 
	# that was most recently added to the combination
	
	#initialize the first @combo element 
	$u = [];
	$i = 0;
	foreach (@element) {push(@$u, {'@' => [$_], 'ix' => $i++})};
	push (@combos, $u);
	$combo_ix = 1;
	
	#create all combinations with no input element duplicated
	while ($combo_ix < scalar @element)
	{
		$u = $combos[$combo_ix - 1];
		$w = [];
		my $h;
		foreach $h (@$u)
		{
			for ($i = $h->{'ix'} + 1; $i < scalar @element; $i++)
			{
				$v = {'@' => [@{$h->{'@'}}], 'ix' => $h->{'ix'}}; #don't really need ix
				push(@{$v->{'@'}}, $element[$i]);
				$v->{'ix'} = $i;
				push(@$w, $v);
			}
		}
		push(@combos, $w);
		$combo_ix++;
	}
	
	#flatten out @combo to only contain refs to arrays
	# (ie throw out the 'ix' element and the now unneeded hash)
	$w = [];
	foreach $u (@combos) { foreach (@$u) {push(@$w, $_->{'@'})} };
	return @$w;
}

sub Combos_filtered_get(@)
#input is an array of feature settings
#enumerate all combinations of the settings
#filter out combinations that contain multiple settings of the same feature
# (multi-valued feature settings are mutually exclusive)
#return an array of references to arrays where each array enumerates feature settings interactions
{
	my (@combos, $combo, @filtered);
	
	@combos = Combos_get(@_);
	foreach (@combos)
	{
		my @combo = @$_;
		my $valid = 1;	
		my $ct = scalar @combo;
		for (my $i = 0; ($i < $ct) && $valid; $i++)
		{
			my $feat_i = $combo[$i];
			$feat_i =~ s/(.*)-.*/$1/;
			for (my $j = $i + 1; ($j < $ct) && $valid; $j++)
			{
				my $feat_j = $combo[$j];
				$feat_j =~ s/(.*)-.*/$1/;
				if ($feat_i eq $feat_j)
				{
					$valid = 0;
				}
			}
		}
		if ($valid)
			{push(@filtered, $_);}
	}
	return @filtered;
}

sub Featset_combos_get($@)
#inputs are a new feature setting and an array of previous feature settings
#enumerate all valid combinations of the new setting with the previous ones
#return an array of references to arrays where each array enumerates a combination
{
	my ($feat_add, @feats) = @_;
	my (@combo, @feats_combo, $c);

	@combo = Combos_filtered_get((@feats, $feat_add));
	#skip over combinations containing one element or 
	# which don't contain the feature being added
	foreach $c (@combo)
		{if ((scalar @$c != 1) && (@$c[-1] eq $feat_add))
			{push(@feats_combo, join(' ', sort(@$c)));}}
	return @feats_combo;
}

#This code is now obsolete. I've left it here now for reference.
#sub Featset_combos_get($@)
##return an array of strings where each string indicates feature interactions
## handles multi-valued features whose settings should not interact
## mv = multi-valued feature. bv = binary-valued feature
## 		properly handle a bv setting interacting with mv settings
##		the bv setting should interact with each mv setting
##		but the mv settings should NOT interact with each other
##		currently the bv & mv features don't interact so this case isn't handled
#{
#	my ($feat_add, @feats) = @_;
#	my (@feats_combo);
#	
#	#prevent the various settings for a mv feature from interacting
#	foreach (@feats)
#		{if (substr($feat_add, 0, 2) eq substr($_, 0, 2))
#			{return @feats_combo;}} #@feats_combo is empty
#	
#	if (scalar @feats == 1)
#	{
#		push(@feats_combo, join(' ', sort($feats[0], $feat_add)));
#	}
#	elsif (scalar @feats == 2)
#	{
#		push (@feats_combo, join(' ', sort($feats[0], $feat_add)));
#		push (@feats_combo, join(' ', sort($feats[1], $feat_add)));
#		#push (@feats_combo, join(' ', sort($feats[0], $feats[1]))); should already be handled
#		push (@feats_combo, join(' ', sort($feats[0], $feats[1], $feat_add)));
#	}
#	else
#	{
#		die("too many features interacting: $feat_add, @feats\n");
#	}
#	
#	return @feats_combo;
#}

sub Gsi_xml_parse($\%\%\%)
#parse the GSI xml file to create the structures describing
# mapping to PS name for given USV and feature setting and
# mapping from feature settings to list of USVs affected
#
# The DepPUA feature ("Show deprecated PUA") has been removed
# The inverted glyphs are now encoded with PUA codepoints
# and named with a trailing Dep without a dot and with no var_uid
# so THE FOLLOWING COMMENTS ARE NO LONGER RELEVANT
# The DepPUA features don't interact with any other features because:
# The var_uid for *.Dep?? glyphs holds the PUA codepoint 
# (though the glyphs are double encoded in FL and named based on official USV).
# Because of this, interaction with other features is masked 
# since that is tracked using USVs in the MGI.
# The official USV for the deprecated glyphs could somehow be used 
# so these glyphs can be offered as choices in cmd elements.
# Note that the var_uid with the deprecated USV is needed for the DepPUA feature 
# (and font testing), so that they can be re-encoded properly (and rendered in testing).
# In the current scheme, this means any re-encoding specified by other feature settings 
# will be overridden by a .Dep?? glyph, 
# which should be OK since we don't want to create inverted glyphs for all features
# that effect deprecated USVs.
{
	my ($gsi_fn, $feats, $usv_feat_to_ps_name, $featset_to_usvs) = @_;
	
	my ($xml_parser, $active, $ps_name, $feat_found, $var_uid_capture, $var_uid);
	my ($lig_uids_capture, $lig_uids);
	$xml_parser = XML::Parser::Expat->new();
	$xml_parser->setHandlers('Start' => sub {
		my ($xml_parser, $tag, %attrs) = @_;
		if ($tag eq 'glyph')
		{
			if ($attrs{'active'} eq '0')
				{$active = 0;}
			else
				{$active = 1;}
		}
		#filter out inactive glyphs
		if (not $active) {return;}
		if ($tag eq 'ps_name')
		{
			$ps_name = $attrs{'value'};
			$feat_found = 0;
		}
		elsif ($tag eq 'var_uid')
		{
			$var_uid_capture = 1;
		}
		elsif ($tag eq 'lig_uids' and $opt_w)
		{
			$lig_uids_capture = 1;
		}
		elsif ($tag eq 'feature')
		{
			if (not defined($ps_name)) {die("no PS name for feature: $attrs{'category'}\n")};
			#if (not defined($var_uid))
			if ((!$opt_w and not defined($var_uid)) 
				or ($opt_w and (not defined($var_uid) and not defined($lig_uids))))
			{#glyphs w/o var_uid's can't be offered as choices in encode cmds
			 #should be: 1) variant for a ligature, 2) default glyph for a multivalued feature,
			 # 3) variant that is encoded --
			 # 3 - should be fixed up by Special_glyphs_handle()
			 # 2 - these probably should also be fixed up in Special_glyphs_handle()
			 # 1 - there's no way to handle this by re-encoding the cmap, so can't do anything
				if ($opt_d) {print "no var_uid for ps_name: $ps_name feat: $attrs{'category'}\n";}
				return;
			};
			#my $usv = substr($var_uid, 2);
			my $usv;
			if (!$opt_w) 
				{$usv = substr($var_uid, 2);}
			else
			{
				if ($var_uid) {$usv = substr($var_uid, 2);}
				if ($lig_uids)
				{
					my @usvs = split(/\s/, $lig_uids);
					foreach (@usvs) {$usv .= substr($_, 2) . ' '};
					chop($usv);
				}
			}
			
			my $feat = $attrs{'category'};
			if (not defined($feats->{$feat}))
				{if ($opt_d) {print "feature in GSI missing from font Feat table: $feat\n";} return;}
			my $set;
			if (defined ($attrs{'value'}))
				{$set = $attrs{'value'};}
			else #for binary valued features the GSI indicates 
				  #when they should be set the opposite of the default
				  #this will fail if setting ids 0 & 1 aren't used for binary features
				{$set = $feats->{$feat}{'default'} ? 0 : 1;}
			my $feat_tag = $feats->{$feat}{'tag'}; 
			my $set_tag = $feats->{$feat}{'settings'}{$set}{'tag'};
			if (!$feat_tag || !$set_tag)
				{die("feature or setting in GSI missing from font Feat table: $feat set: $set\n");}
			my $featset = "$feat_tag-$set_tag";
			
			if (not defined ($featset_to_usvs->{$featset}))
				{$featset_to_usvs->{$featset} = [];}
			if (scalar (grep {$_ eq $usv} @{$featset_to_usvs->{$featset}}) == 0)
				{push(@{$featset_to_usvs->{$featset}}, $usv);}
			
			#handle interacting features
			my @prev_feats;
			foreach (keys %{$usv_feat_to_ps_name->{$usv}})
				{if ($_ ne 'unk') {push(@prev_feats, $_);}} #nothing interacts with unk features
			if (scalar @prev_feats)
			{
				my @featset_combos = Featset_combos_get($featset, @prev_feats);
				foreach $featset (@featset_combos)
				{
					if (not defined($featset_to_usvs->{$featset}))
						{$featset_to_usvs->{$featset} = [];}
					if (scalar (grep {$_ eq $usv} @{$featset_to_usvs->{$featset}}) == 0)
						{push(@{$featset_to_usvs->{$featset}}, $usv);}
				}
			}
			
			if (not defined($usv_feat_to_ps_name->{$usv}{$featset}))
				{$usv_feat_to_ps_name->{$usv}{$featset} = [];}
			push(@{$usv_feat_to_ps_name->{$usv}{$featset}}, $ps_name);
			$feat_found = 1;
		}
		else
		{}
	}, 'End' => sub {
		my ($xml_parser, $tag) = @_;
		if ($tag eq 'glyph')
		{
			if (!$feat_found && defined($var_uid))
			{ #use 'unk' featset to store info on variant glyphs w/o features
				my $usv = substr($var_uid, 2);
				if (not defined($usv_feat_to_ps_name->{$usv}{'unk'}))
					{$usv_feat_to_ps_name->{$usv}{'unk'} = []}
				push(@{$usv_feat_to_ps_name->{$usv}{'unk'}}, $ps_name);
			} 
			$ps_name = undef;
			$var_uid = undef;
			if ($opt_w) {$lig_uids = undef;}
		}
		elsif ($tag eq 'ps_name')
		{}
		elsif ($tag eq 'var_uid')
		{
			$var_uid_capture = 0;
		}
		elsif ($tag eq 'lig_uids' and $opt_w)
		{
			$lig_uids_capture = 0;
		}
		elsif ($tag eq 'feature')
		{}
		else
		{}
	}, 'Char' => sub {
		my ($xml_parser, $str) = @_;
		if ($var_uid_capture)
			{if (not defined($var_uid))
				{$var_uid = $str;}
			else
				{$var_uid .= $str;}
			}
		if ($lig_uids_capture and $opt_w)
			{if (not defined($lig_uids))
				{$lig_uids = $str;}
			else
				{$lig_uids .= $str;}
			}
	});

	$xml_parser->parsefile($gsi_fn) or die "Can't read $gsi_fn";
}

sub Special_glyphs_handle($\%\%\%\%)
#add variant glyph info which isn't indicated in the GSI data to various hashes 
# this allows the glyph to offered as a choice in the cmd elements
{
	my ($gsi_supp_fn, $feats, $usv_feat_to_ps_name, $featset_to_usvs, $glyph_to_featset_andika) = @_;
	
	#add uni01B7.RevSigmaStyle as a variant for U+01B7 for feature Capital Ezh alternates (1042)
	# this is a variant glyph that is also encoded in the PUA (F217)
	# so there is no <var_uid> in the GSI data for it
	if (defined $feats->{'Ezhr'}) # Andika Basics does not support this feature
	{
		# the below code doesn't handle the case where 01B7 has more than one variant, so die if that occurs
		if (defined $usv_feat_to_ps_name->{'01B7'}) {die "status of 01B7 has changed\n";}
	#	my $feat_tag = $feats->{'1042'}{'tag'}; #use new four char GDL feat tag
	#	my $set_id = $feats->{'1042'}{'settings'}{' ids'}[1];
	#	my $set_tag = $feats->{'1042'}{'settings'}{$set_id}{'tag'};
		my $feat_tag = $feats->{'Ezhr'}{'tag'};
		my $set_id = $feats->{'Ezhr'}{'settings'}{' ids'}[1];
		my $set_tag = $feats->{'Ezhr'}{'settings'}{$set_id}{'tag'};
		my $featset = "$feat_tag-$set_tag";
		if (not defined $featset_to_usvs->{$featset})
			{$featset_to_usvs->{$featset} = [];}
		push(@{$featset_to_usvs->{$featset}}, '01B7');
		$usv_feat_to_ps_name->{'01B7'}{$featset} = ['uni01B7.RevSigmaStyle'];
	}

	#small cap support - handle lower case eng interacting with eng alternate feature
	if (defined $gsi_supp_fn)
		{Gsi_xml_parse($gsi_supp_fn, %$feats, %$usv_feat_to_ps_name, %$featset_to_usvs);}
		
	#add encoding info for literacy glyphs encoded in Andika
	# which therefore have no encoding or feature info in the GSI
	if ($opt_a)
	{	
		foreach my $glyph_base_name (keys %glyph_to_featset_andika)
		{
			if (not defined $glyph_to_featset_andika{$glyph_base_name}{'lit'})
				{next;}
			my $usv = $glyph_to_featset_andika{$glyph_base_name}{'lit'}[0];
			my $glyph_lit_suffix = $glyph_to_featset_andika{$glyph_base_name}{'lit'}[1];
			my $glyph_name = $glyph_base_name . '.' . $glyph_lit_suffix;
			if (defined $usv_feat_to_ps_name->{$usv}{'unk'})
				{push (@{$usv_feat_to_ps_name->{$usv}{'unk'}}, $glyph_name);}
			else
				{$usv_feat_to_ps_name->{$usv}{'unk'} = [$glyph_name];}
		}
	}
}

sub Dblenc_get($\%)
#parse the DblEnc.txt file which indicates deprecated PUA chars and their official USVs
{
	my ($dblenc_fn, $dblenc_usv) = @_;
	
	open FH, "<$dblenc_fn" or die("Could not open $dblenc_fn for reading\n");
	while (<FH>)
	{
		chomp;
		my @fields = split(/,/, $_);
		if (scalar @fields != 3) {die("file $dblenc_fn has corrupt line: $_\n");}
		my ($primary_usv, $deprecated_usv) = map {substr($_, 2)} ($fields[2], $fields[1]);
		$dblenc_usv->{$primary_usv} = $deprecated_usv;
	}
	close FH;
}

sub Featsets_add_default($\@\%)
#add a default featset to the featsets array
#based on the name of the base glyph and the current featsets
#needed to handle variant glyphs where a suffix should be used
# but there is no feature setting for that suffix
# such LtnSmYHook.RtHook.* variants 
#  (LtnSmYHook.RtHook is encoded, LtnSmYHook is selected by a featset; LtnSmYHook.RtHook.SC is the small cap variant)
#also used to add Lit-T to literacy glyphs if Lit-F is not set
{
	my ($ps_names, $featsets, $glyph_to_featset) = @_;

	#assumes all the space separated ps names have same base name
	#my $ps_name = $ps_names;
	#$ps_name =~ s/^(.*?)\..*$/$1/;  dooes not work because first ps name may not contain a '.'
	my @a = split(/\s/, $ps_names);
	my @b = split(/\./, $a[0]);
	my $ps_name = $b[0];

	#the below isn't needed because the GSI only specifies one glyph to use 
	# for 01E5 with literacy, no default setting is added, so no choosing of glyphs is done
	#handle very bizarre case of LtnSmGStrk with literacy on (for non-Andika fonts)
	# uni01E5.SngBowl doesn't exist; uni01E5.BarBowl.SngBowl is the literacy form
	#in Andika, Lit-T is always paired with other features. Lit-T only occurs solo in other fonts
	#if ($ps_name eq 'uni01E5' and scalar @$featsets == 1 and @$featsets[0] eq 'Lit-T')
	#	{ push (@$featsets, 'BarBowl-T'); @$featsets = sort @$featsets; return;}
	
	if (defined($glyph_to_featset->{$ps_name}))
	{
		my $alt_found = 0;
		foreach my $alt_featset (@{$glyph_to_featset->{$ps_name}{'alts'}})
			{foreach my $featset (@$featsets)
				{if ($alt_featset eq $featset) {$alt_found = 1;}}}
		
		if (not $alt_found)
		{
			push(@$featsets, $glyph_to_featset->{$ps_name}{'dflt'});
			@$featsets = sort @$featsets;
		}
	}
	return;
}

sub Suffixes_get(\@)
#get all the PS name suffixes for an array of feature settings
#return an empty array if any feature setting doesn't have a suffix
{
	my ($featsets) = @_;
	my @suffixes;
	foreach my $featset (@$featsets)
	{
		if (defined($featset_to_suffix{$featset}))
		{
			push(@suffixes, $featset_to_suffix{$featset});
		}
		else
		{
			print "*** no suffix found for $featset\n";
			@suffixes = ();
			return @suffixes;
		}
	}
	return @suffixes;
}

sub Suffixes_match_name(\@$)
#test if a PS name matches all of the suffixes in an array
# and that the correct number of suffixes are in the PS name
#(the suffixes are now reg exs and represent feature setings)
#a regex for a multi-value default glyph might match but have no suffix
# eg (uni01B2|028B)(?!\.StraightLftHighHook|\.StraightLft)
# if a negative look ahead match (as above) is used, 
# the number of suffixes needed in the name is reduced
#returns true if the suffix array is empty
{
	my ($suffixes, $name) = @_;
	
	return 1 if (scalar @$suffixes == 0);
	
	my @t = split(/\./, $name);
	my $name_suffix_ct = scalar @t - 1;
	my $suffix_ct = scalar @$suffixes;
#	if ($name_suffix_ct > $suffix_ct)
#		{return 0;} #return if more name suffixes than suffixes (regexs) being matched
		
	my $suffix_match_ct = 0;
	my $active_suffix_ct = $suffix_ct;
	foreach my $suffix (@$suffixes)
	{
		if ($name =~ /$suffix/) {$suffix_match_ct++;}
		if ($suffix =~ /\?\!/) {$active_suffix_ct--;} #no name suffix for negative look ahead matches
	}
		
	if (($suffix_match_ct == $suffix_ct) && ($active_suffix_ct == $name_suffix_ct))
		{return 1;}
	else
		{return 0;}
}

#forward declare this since it's a recursive subroutine to avoid a warning
sub PSName_select(\@$);

sub PSName_select(\@$)
#choose the first name in a space delimited string that matches the feature settings
#if no name is found, try simplifying the feature settings according to the %reduced_featsets hash
#return origial names if no match found
# if there is only one choice, it will be returned
{
	my ($featsets, $choices) = @_;
	
	my @suffixes = Suffixes_get(@$featsets);
	
	foreach my $choice (split(/\s/, $choices))
	{
		if (Suffixes_match_name(@suffixes, $choice))
			{return $choice;}
	}
	
	#if no choice was found, reduce feature settings to simpler form and search again
	my $featsets_old = join(' ', @$featsets);
	if (defined $reduced_featsets{$featsets_old})
	{
		my $featsets_new = $reduced_featsets{$featsets_old} ;
		my @featsets_new = split(/\s/, $featsets_new);
		return PSName_select(@featsets_new, $choices);
	}
	
	return $choices;
}

sub Features_output($\%\%\%\%)
#output the <feature>s elements
#all value elements contain at least a gr_feat cmd or a cmd="null" (if a default)
#output all of these even though a USV effected by both a binary-valued feature 
# and a multi-valued feature will always be handled by an interactions element
# the mv feature always has a setting, even if it's the default.
{
	my ($feat_all_fh, $feats, $featset_to_usvs, $usv_feat_to_ps_name, $dblenc_usv) = @_;
	my $fh = $feat_all_fh;
	my ($feat_id, $set_id);
	
	foreach $feat_id (@{$feats->{' ids'}}) #$feat_id is a gdl tag
	{
		my $feat = $feats->{$feat_id};
		my ($feat_nm, $feat_tag) = ($feat->{'name'}, $feat->{'tag'});
		my $feat_def_id = $feat->{'default'};
		my $feat_def_nm = $feat->{'settings'}{$feat_def_id}{'name'};
		
		#start feature element
		print $fh "\t<feature name=\"$feat_nm\" value=\"$feat_def_nm\" tag=\"$feat_tag\">\n";
		
		foreach $set_id (@{$feat->{'settings'}{' ids'}})
		{
			my $set = $feat->{'settings'}{$set_id};
			my ($set_nm, $set_tag) = ($set->{'name'}, $set->{'tag'});
			
			#start value element
			print $fh "\t\t<value name=\"$set_nm\" tag=\"$set_tag\">\n";
			
			#cmd elements
			
			if ($opt_g and $opt_q)
			{#null cmd if nothing to output
				print $fh "\t\t\t<cmd name=\"null\" args=\"null\"/>\n";
				goto cmd_end;
			}
			
			if ($set_id eq $feat_def_id)
			{#default feature and setting
				print $fh "\t\t\t<cmd name=\"null\" args=\"null\"/>\n";
				goto cmd_end;
			}
			
			my $flag = 0;
			
			### gr_feat cmd
			unless ($opt_q)
			{
				print $fh "\t\t\t<cmd name=\"gr_feat\" args=\"{$feat_id} $set_id\"/>\n";
				$flag = 1;
			}
			
			#### OT cmds that manipulate the script, language, feature, or lookup structures
			
			#I think that VIt and ROt should be handled the same way
			#Using feat_del & feat_add for both VIt and ROt has problems 
			# if both VIt and ROt are on since the second one processed can't delete ccmp_latin
			# because the first one will have already deleted it
			#Using a test select="VIt ROt" to solve this problem would create two features with 
			# the same OT name (ccmp) and redundant lookups
			#Using the lookup_add approach doesn't require testing for both VIt and ROt
			# and avoids the above problem
			#2013-08-26 AW: ROt processsing removed since variant glyphs are now encoded
			
			if ($vietnamese_style_diacs_feat =~ /$feat_id/ and not $opt_g)
			{#hard-coded
				print $fh "\t\t\t<cmd name=\"lookup_add\" args=\"GSUB {ccmp_latin} {viet_decomp}\"/>\n";
				print $fh "\t\t\t<cmd name=\"lookup_add\" args=\"GSUB {ccmp_latin} {viet_precomp}\"/>\n";
				#see comment on VIt and ROt in Interactions_output()
				#print $fh "\t\t\t<cmd name=\"feat_del\" args=\"GSUB latn {IPA} {ccmp_latin}\"/>\n";
				#print $fh "\t\t\t<cmd name=\"feat_add\" args=\"GSUB latn {IPA} {ccmp_vietnamese} 0\"/>\n";
				$flag = 1;
			}
			
			#### encode cmds
			# this code is similar to Test_output
			my $featset = "$feat_tag-$set_tag";
			if (defined($featset_to_usvs->{$featset}) and not $opt_g)
			{#write cmds for each variant glyph associated with this feature setting
				my @usvs = @{$featset_to_usvs->{$featset}};
				foreach my $usv (@usvs)
				{
					my @ps_names = @{$usv_feat_to_ps_name->{$usv}{$featset}};
					my $choices .= join(' ', @ps_names) . ' ';

					my @featsets = ($featset);
					#if Andika, below will add Lit-T for literacy glyphs
					Featsets_add_default($choices, @featsets, %glyph_to_featset);
					if (scalar @featsets > 1)
					{   
						#offer variants without feature info in the GSI as choices
						# Lit-T glyphs in Andika are encoded and hence have no <feature>
						# in the GSI. so they will be listed under the 'unk' feature
						if (defined($usv_feat_to_ps_name->{$usv}{'unk'}))
						{
							@ps_names = @{$usv_feat_to_ps_name->{$usv}{'unk'}};
							$choices .= join(' ', @ps_names) . ' ';
						}
					}
					chop($choices);
					if (index($choices, ' ') != -1)
						{$choices = PSName_select(@featsets, $choices);}
					
					if ($opt_t) #output legal args for testing TypeTuner
						{my @c = split(/\s/, $choices); $choices = $c[0];}
						
					if (index($choices, ' ') != -1) #if there was only one choice, it will be used w/o this comment
						{print $fh "\t\t\t<!-- edit below line(s) -->\n";}
						
					print $fh "\t\t\t<cmd name=\"encode\" args=\"$usv $choices\"/>\n";
					if (defined $dblenc_usv->{$usv})
						{print $fh "\t\t\t<cmd name=\"encode\" args=\"$dblenc_usv->{$usv} $choices\"/>\n";}
				}
				$flag = 1;
			}
			
			if (not $flag)
			{
				print $fh "\t\t\t<cmd name name=\"null\" args=\"null\"/>\n";
			};
			
			cmd_end:
			#end value element
			print $fh "\t\t</value>\n";
		}
		
		#end feature element
		print $fh "\t</feature>\n";
	}

	### deal with old features that have been eliminated
	### by outputing the same <feature> structure that was generated before
	### but with null cmds
	if (not defined $feats->{'dpua'})
	{ #be careful of tabs in section below for proper output
		print $fh <<END
	<feature name="Romanian-style diacritics" value="False" tag="RONdiacs">
		<!-- this feature has been removed from the font -->
		<!-- this feature element is needed for compatibility with old Settings -->
		<value name="False" tag="F">
			<cmd name="null" args="null"/>
		</value>
		<value name="True" tag="T">
			<cmd name="null" args="null"/>
		</value>
	</feature>
END
	}

	if (not defined $feats->{'dpua'})
	{ #be careful of tabs in section below for proper output
		print $fh <<END
	<feature name="Show deprecated PUA" value="None" tag="DepPUA">
		<!-- this feature has been removed from the font -->
		<!-- this feature element is needed for compatibility with old Settings -->
		<value name="None" tag="none">
			<cmd name="null" args="null"/>
		</value>
		<value name="Through Unicode 4.0" tag="40">
			<cmd name="null" args="null"/>
		</value>
		<value name="Through Unicode 4.1" tag="41">
			<cmd name="null" args="null"/>
		</value>
		<value name="Through Unicode 5.0" tag="50">
			<cmd name="null" args="null"/>
		</value>
		<value name="Through Unicode 5.1" tag="51">
			<cmd name="null" args="null"/>
		</value>
	</feature>
END
	}
	
	### output line spacing feature
	unless ($opt_g)
	{
		my $line_gap_tag = Tag_lookup('Line spacing', %nm_to_tag);
		my $tight_tag = Tag_lookup('Tight', %nm_to_tag);
		my $normal_tag = Tag_lookup('Normal', %nm_to_tag);
		my $loose_tag = Tag_lookup('Loose', %nm_to_tag);
		my $imported_tag = Tag_lookup('Imported', %nm_to_tag);
		if (not $opt_t)
		{ #be careful of tabs in section below for proper output
			print $fh <<END
	<feature name="Line spacing" value="Normal" tag="$line_gap_tag">
		<!-- edit the below lines to provide the correct line metrics -->
		<!-- Doulos -->
		<value name="Normal" tag="$normal_tag">
			<cmd name="null" args="2324 810"/>
		</value>
		<value name="Tight" tag="$tight_tag">
			<cmd name="line_metrics" args="1420 442 307 1825 443 1825 443 87"/>
		</value>
		<value name="Loose" tag="$loose_tag">
			<cmd name="line_gap" args="2800 1100"/>
		</value>
		<!-- Charis -->
		<value name="Normal" tag="$normal_tag">
			<cmd name="null" args="2450 900"/>
		</value>
		<value name="Tight" tag="$tight_tag">
			<cmd name="line_gap" args="1950 500"/>
		</value>
		<value name="Loose" tag="$loose_tag">
			<cmd name="line_gap" args="2900 1200"/>
		</value>
		<!-- Gentium -->
		<value name="Normal" tag="$normal_tag">
			<cmd name="null" args="2050 900"/>
		</value>
		<value name="Tight" tag="$tight_tag">
			<cmd name="line_gap" args="1750 550"/>
		</value>
		<value name="Loose" tag="$loose_tag">
			<cmd name="line_gap" args="2450 1200"/>
		</value>
		<!-- Andika -->
		<value name="Normal" tag="$normal_tag">
			<cmd name="null" args="2500 800"/>
		</value>
		<value name="Tight" tag="$tight_tag">
			<cmd name="line_gap" args="2100 550"/>
		</value>
		<value name="Loose" tag="$loose_tag">
			<cmd name="line_gap" args="2900 1100"/>
		</value>
		<!-- edit note: do _not_ delete the Imported value -->
		<value name="Imported" tag="$imported_tag">
			<cmd name="line_metrics_scaled" args="null"/>
		</value>
	</feature>
END
		}
		else
		{ #be careful of tabs in section below for proper output
			print $fh <<END
	<feature name="Line spacing" value="Normal" tag="$line_gap_tag">
		<!-- Doulos -->
		<value name="Normal" tag="$normal_tag">
			<cmd name="null" args="2324 810"/>
		</value>
		<value name="Tight" tag="$tight_tag">
			<cmd name="line_metrics" args="1420 442 307 1825 443 1825 443 87"/>
		</value>
		<value name="Loose" tag="$loose_tag">
			<cmd name="line_gap" args="2800 1100"/>
		</value>
		<value name="Imported" tag="$imported_tag">
			<cmd name="line_metrics_scaled" args="null"/>
		</value>
	</feature>
END
		}
	}
}

sub Test_output($$\%\%\%)
#output the <cmd> elements inside of a <test> element 
# for one set of feature interactions
{
	my ($feat_all_fh, $featset, $featset_to_usvs, $usv_feat_to_ps_name, $dblenc_usv) = @_;
	my(@usvs, $usv, @feats, $feat);
	my $fh = $feat_all_fh;
	
	# this code is similar to Features_output
	@usvs = @{$featset_to_usvs->{$featset}};
	@feats = split(/\s/, $featset);
	foreach $usv (@usvs)
	{
		#create string with all relevant ps_names separated by spaces
		my $choices = '';
		foreach $feat (@feats)
		{
			my @ps_names = @{$usv_feat_to_ps_name->{$usv}{$feat}};
			$choices .= join(' ', @ps_names) . ' ';
		}
		if (scalar @feats > 1)
		{   
			#offer variants without feature info in the GSI as choices
			if (defined($usv_feat_to_ps_name->{$usv}{'unk'}))
			{
				my @ps_names = @{$usv_feat_to_ps_name->{$usv}{'unk'}};
				$choices .= join(' ', @ps_names) . ' ';
			}
		}
		chop($choices);
		my @feats_add_def = @feats;
		Featsets_add_default($choices, @feats_add_def, %glyph_to_featset);
		$choices = PSName_select(@feats_add_def, $choices);
		
		if ($opt_t) #output legal args for testing TypeTuner
			{my @c = split(/\s/, $choices); $choices = $c[0];}
			
		if (index($choices, ' ') != -1)
			{print $fh "\t\t\t<!-- edit below line(s) -->\n";}
			
		print $fh "\t\t\t<cmd name=\"encode\" args=\"$usv $choices\"/>\n";
		if (defined $dblenc_usv->{$usv})
			{print $fh "\t\t\t<cmd name=\"encode\" args=\"$dblenc_usv->{$usv} $choices\"/>\n";}
	}
}

sub sort_tests($$)
#compare to <interaction> test attribute strings
#sort such that strings with fewer featsets come first
{
	#scalar split(/\s/, $a) causes many error msgs
	my ($a, $b) = @_;
	my @t = split(/\s/, $a);
	my $a_ct = scalar @t;
	@t = split(/\s/, $b);
	my $b_ct = scalar @t;
	
	if ($a_ct > $b_ct)
		{return 1;}
	elsif ($a_ct < $b_ct)
		{return -1;}
	else #$a_ct == $b_ct
		{return ($a cmp $b);}
}

sub Feats_to_ids($$\%)
#obtain feature & setting ids based on tags
{
	my  ($feat_tag, $set_tag, $feats) = @_;
	
	foreach my $fid (@{$feats->{' ids'}})
	{
		if ($feats->{$fid}{'tag'} eq $feat_tag)
		{
			foreach my $sid (@{$feats->{$fid}{'settings'}{' ids'}})
			{
				if ($feats->{$fid}{'settings'}{$sid}{'tag'} eq $set_tag)
				{
					return ($fid, $sid);
				}
			}	
		}
	}
	die("Ids for feature and setting couldn't be found: $feat_tag $set_tag\n");
}

sub Interactions_output($\%\%\%\%)
#output the <interactions> elements
{
	my ($feat_all_fh, $featset_to_usvs, $usv_feat_to_ps_name, $feats, $dblenc_usv) = @_;
	my $fh = $feat_all_fh;
	
	#start interactions element
	print $feat_all_fh "\t<interactions>\n";

	my $featset;
	foreach $featset (sort sort_tests keys %$featset_to_usvs)
	{
		my @featsets = split(/\s/, $featset);
		if (scalar @featsets == 1) {next;} #handled with <feature> elements
		
		#start test element
		print $fh "\t\t<test select=\"$featset\">\n";
		
		#null cmd if nothing to output
		if ($opt_g and $opt_q)
			{print $fh "\t\t\t<cmd name=\"null\" args=\"null\"/>\n";}
			
		#encode cmds for all affected usvs
		Test_output($feat_all_fh, $featset, %$featset_to_usvs, %$usv_feat_to_ps_name, 
						%$dblenc_usv) unless $opt_g;
		
		#end test element
		print $fh "\t\t</test>\n";
	}

	#end interactions element
	print $feat_all_fh "\t</interactions>\n";
}

sub Aliases_output($\%)
#output the <aliases> elements
{
	my ($feat_all_fh, $gdl_tag_to_feat_id) = @_;

	print $feat_all_fh "\t<aliases>\n";

	#<alias name="IPA" value="IPA "/> move up from below so not output to file
	print $feat_all_fh <<END;
		<alias name="IPA" value="IPPH"/>
		<alias name="VIT" value="VIT "/>
		<alias name="ccmp_latin" value="ccmp"/>
		<alias name="ccmp_vietnamese" value="ccmp _0"/>
		<alias name="viet_decomp" value="4"/>
		<alias name="viet_precomp" value="5"/>
END

	#output aliases to map four char GDL feat tags to integers actually in the font
	my ($gdl_tag);
	foreach $gdl_tag (sort keys %{$gdl_tag_to_feat_id})
	{
		my ($feat_id) = $gdl_tag_to_feat_id->{$gdl_tag};
		print $feat_all_fh "\t\t<alias name=\"$gdl_tag\" value=\"$feat_id\"/>\n";
	}

	print $feat_all_fh "\t</aliases>\n";
}

sub Old_names_output($)
#output the mappings from old feature & value names to current tags
#when revised feature values (created for OT char variants) were added
# map the old feature value strings to the new tags (which are the same as old tags)
{
	my ($feat_all_fh) = @_;

	print $feat_all_fh <<END;
	<old_names>
		<old_feature name="J stroke hook alternate" tag="JStrk"/>
		<old_feature name="Small v-hook alternate" tag="VHk"/>
		<old_value feature="Small v-hook alternate" name="Straight" tag="StrtLftLowHk"/>
		<old_feature name="Cyrillic E alternates" tag="CyrE"/>
		<old_value feature="Capital H-stroke alternate" name="Horizontal stroke" tag="Hrz"/>
		<old_value feature="Capital H-stroke alternate" name="Vertical stroke" tag="Vrt"/>
		<old_value feature="Cyrillic shha alternate" name="True" tag="Uc"/>
		<old_value feature="9-level pitches" name="Ligated" tag="Lgt"/>
		<old_value feature="9-level pitches" name="Show tramlines" tag="TrmLn"/>
		<old_value feature="9-level pitches" name="Non-ligated" tag="NoLgt"/>
		<old_value feature="9-level pitches" name="Show tramlines, non-ligated" tag="TrmLnNoLgt"/>
		<old_value feature="J-stroke hook alternate" name="No serif" tag="NoSrf"/>
		<old_value feature="V-hook alternates" name="Straight left" tag="StrtLftLowHk"/>
		<old_value feature="V-hook alternates" name="Straight left high hook" tag="StrtLftHk"/>
		<old_value feature="Modifier colon alternate" name="Wide" tag="Wd"/>
		<old_value feature="Capital B-hook alternate" name="F" tag="Uc"/>
		<old_value feature="Capital B-hook alternate" name="T" tag="Lc"/>
		<old_value feature="Capital D-hook alternate" name="F" tag="Uc"/>
		<old_value feature="Capital D-hook alternate" name="T" tag="Lc"/>
	</old_names>
END
}

sub Usage_print()
{
	print <<END;
RFComposer ver $version (c) SIL International 2007-2021.
usage: 
	RFComposer <switches> <font.ttf> <gsi.xml> <dblenc.txt> [<gsi_supp_fn.xml>]
	switches:
		-a - adjust processing for Andika
		-g - output no OpenType cmds (Graphite only)
		-q - output no Graphite cmds (OpenType only)
		-d - debug output
		-t - output a file that needs no editing 
			(for testing TypeTuner)
			
	output is to feat_all_composer.xml
END
	exit();
};

#### main processing ####

sub cmd_line_exec() #for UltraEdit function list
{}

my (%feats, %usv_feat_to_ps_name, %featset_to_usvs, %dblenc_usv, %gdl_tag_to_feat_id);
my ($font_fn, $gsi_fn, $dblenc_fn, $gsi_supp_fn, $feat_all_fn, $feat_all_fh);

getopts($opt_str); #sets $opt?'s & removes the switch from @ARGV

#build a file containing a hash of feature & setting names to tags
# to paste into this program for specifying tags
if ($opt_l)
{
	my ($font_fn) = ($ARGV[0]);

	Feats_get($font_fn, %feats, %gdl_tag_to_feat_id);
	
	open FILE, ">$featset_list_fn";
	print FILE 'my %nm_to_tag = (';
	print FILE "\n";
	
	my %tags;
	foreach my $feat_id (@{$feats{' ids'}})
	{
		my $feat_t = $feats{$feat_id};
		my ($tag, $name, $default) = ($feat_t->{'tag'}, $feat_t->{'name'}, 
									  $feat_t->{'default'});
		if (not defined $tags{$name})
			{print FILE "\t'$name' => '$tag',\n"; $tags{$name} = $tag;}
		foreach my $set_id (@{$feats{$feat_id}{'settings'}{' ids'}})
		{
			my $set_t = $feat_t->{'settings'}{$set_id};
			($tag, $name) = ($set_t->{'tag'}, $set_t->{'name'});
			if (not defined $tags{$name})
				{print FILE "\t'$name' => '$tag',\n"; $tags{$name} = $tag;}
		}
	}
	
	#my $line_gap_tag = Tag_get('Line spacing', 2);
	#print FILE "\t'Line spacing' => '$line_gap_tag',\n";
	
	foreach my $s ('Line spacing', 'Tight', 'Normal', 'Loose', 'Imported')
	{
		if (not defined $tags{$s})
		{
			my $tag = Tag_lookup($s, %nm_to_tag);
			print FILE "\t'$s' => '$tag',\n";
			$tags{$s} = $tag;
		}
	}
	
	print FILE ");\n";
	exit;	
}

if (scalar @ARGV == 3)
	{($font_fn, $gsi_fn, $dblenc_fn) = ($ARGV[0], $ARGV[1], $ARGV[2]); $gsi_supp_fn = undef;}
elsif (scalar @ARGV == 4)
	{($font_fn, $gsi_fn, $dblenc_fn, $gsi_supp_fn) = ($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3]);}
else
	{Usage_print;}

Andika_adjust();
Feats_get($font_fn, %feats, %gdl_tag_to_feat_id);
Gsi_xml_parse($gsi_fn, %feats, %usv_feat_to_ps_name, %featset_to_usvs);
Special_glyphs_handle($gsi_supp_fn, %feats, %usv_feat_to_ps_name, %featset_to_usvs, %glyph_to_featset_andika);

if ($opt_d)
{
	print "usvs with variant glyphs: ";
	foreach (sort keys %usv_feat_to_ps_name) {print "$_ "}; print "\n";
	print "featsets with variant glyphs: ";
	foreach (sort keys %featset_to_usvs) {print "($_)"}; print "\n";
}

if ($opt_z)
#analysis option for examining parsed glyph data
#find glyphs with multiple suffixes with a <feature> element in the GSI
{
	foreach my $usv (sort keys %usv_feat_to_ps_name)
	{
		foreach my $feat (sort keys %{$usv_feat_to_ps_name{$usv}})
		{
			if ($feat ne 'unk')
#			if ($feat eq 'unk')
			{
#				print "$usv,$feat";
#				my $first = 1;      
				foreach my $nm (@{$usv_feat_to_ps_name{$usv}{$feat}})
				{
#					print ",$nm";
					my @nms = split(/\./, $nm);
					if (scalar @nms > 2)
					{
#						if ($first) {print "$usv,$feat"; $first = 0}
						#if ($first) {print "$feat"; $first = 0}
						#print ",$nm";
						print "$feat,$nm\n";
					}
				}
				#if (not $first) {print "\n";}
#				print "\n";
			}
		}
	}
	exit;
}

Dblenc_get($dblenc_fn, %dblenc_usv);

if ($opt_d)
{
	print "double encoded usvs: ";
	foreach (sort values %dblenc_usv) {print "$_ ";}; print "\n";
}

if (!$opt_w)
{
$feat_all_fn = $feat_all_base_fn;
open $feat_all_fh, ">$feat_all_fn" or die("Could not open $feat_all_fn for writing\n");
print $feat_all_fh "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print $feat_all_fh "<!DOCTYPE all_features SYSTEM \"feat_all.dtd\">\n";
print $feat_all_fh "<all_features version=\"$xml_version\">\n";

Features_output($feat_all_fh, %feats, %featset_to_usvs, %usv_feat_to_ps_name, %dblenc_usv);
Interactions_output($feat_all_fh, %featset_to_usvs, %usv_feat_to_ps_name, %feats, %dblenc_usv);
unless ($opt_g)
{
	Aliases_output($feat_all_fh, %gdl_tag_to_feat_id);
}
Old_names_output($feat_all_fh);

print $feat_all_fh "</all_features>\n";
close $feat_all_fn;
}

else #opt_w
{
my ($wpfeatures_fn, $font_nm);

$wpfeatures_fn = "WPFeatures.wpx";
$font_nm = $opt_w;

open FH, ">$wpfeatures_fn" or die("Could not open $wpfeatures_fn for writing\n");
print FH <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE WpDoc SYSTEM "WorldPad.dtd">
<WpDoc wpxVersion="2.0">

<Languages>
  <LgWritingSystem id="xrfx" language="rfx - Roman" type="OTHER">
    <Name24>
      <AUni ws="en">Roman</AUni>
    </Name24>
    <RightToLeft24><Boolean val="false"/></RightToLeft24>
    <DefaultSerif24><Uni>Times New Roman</Uni></DefaultSerif24>
    <DefaultSansSerif24><Uni>Arial</Uni></DefaultSansSerif24>
    <DefaultBodyFont24><Uni>Times New Roman</Uni></DefaultBodyFont24>
    <DefaultMonospace24><Uni>Courier</Uni></DefaultMonospace24>
    <ICULocale24><Uni>xrfx</Uni></ICULocale24>
    <KeyboardType24><Uni>standard</Uni></KeyboardType24>
    <Collations24>
      <LgCollation>
        <Name30>
          <AUni ws="en">DefaultCollation</AUni>
        </Name30>
        <WinLCID30><Integer val="1078"/></WinLCID30>
        <WinCollation30><Uni>Latin1_General_CI_AI</Uni></WinCollation30>
      </LgCollation>
    </Collations24>
  </LgWritingSystem>
</Languages>

<Styles>
  <StStyle>
    <Name17><Uni>Normal</Uni></Name17>
    <Type17><Integer val="0"/></Type17>
    <BasedOn17><Uni></Uni></BasedOn17>
    <Next17><Uni>Normal</Uni></Next17>
    <Rules17>
      <Prop italic="off" bold="off" superscript="off" underline="none" fontsize="10000" fontsizeUnit="mpt" offset="0" offsetUnit="mpt" forecolor="black" backcolor="white" undercolor="black" align="leading" firstIndent="0" leadingIndent="0" trailingIndent="0" spaceBefore="0" spaceAfter="0" lineHeight="10000" lineHeightUnit="mpt" rightToLeft="0" borderTop="0" borderBottom="0" borderLeading="0" borderTrailing="0" borderColor="black" bulNumScheme="0" bulNumStartAt="1" fontFamily="&lt;default serif&gt;">
        <BulNumFontInfo backcolor="white" bold="off" fontsize="10000mpt" forecolor="black" italic="off" offset="0mpt" superscript="off" undercolor="black" underline="none" fontFamily="Times New Roman"/>
        <WsStyles9999>
          <WsProp ws="xrfx" fontFamily="$font_nm" fontsize="20000" fontsizeUnit="mpt" />
        </WsStyles9999>
      </Prop>
    </Rules17>
  </StStyle>
</Styles>

<Body docRightToLeft="false">
EOS

sub WP_test_output($$@)
#output a WorldPad test string
#arguments are a label, the WP feature activation string, 
# and an array of strings that contain space delimited USVs
{
	my ($featsets, $featsets_str, @usv_str) = @_;
	my $usvs_str = '';
	foreach my $usv_str (@usv_str)
	{
		my @usvs = split(/\s/,$usv_str);
		my $lig_str = '';
		foreach (@usvs)
			{$lig_str .= sprintf("&#x%04s;", lc($_));}
		$usvs_str .= "&#xf130;" . $lig_str . "&#xf131; ";
	}
	chop($usvs_str);
	
	print FH <<"EOS";  #FH is global
  <StTxtPara>
    <StyleRules15>
      <Prop namedStyle="Normal"/>
    </StyleRules15>
    <Contents16>
      <Str>
        <Run>$featsets [</Run>
        <Run ws="xrfx" forecolor="blue">$usvs_str</Run>
        <Run>]: </Run>
        <Run ws="xrfx" fontVariations="$featsets_str">$usvs_str</Run>
      </Str>
    </Contents16>
  </StTxtPara>
EOS
}

#special test cases for bridging diacritcs
my @bridging_diacritics_test = ('25CC 0311', '25CC 0361');
# Diaresis bridging LL with possible double macron below (occurring after diaresis)
my @bridging_diaresis_test = ('004C 0308 004C', '004C 0308 006C', '006C 0308 006C', '004C 0308 035F 004C', '004C 0308 035F 006C', '006C 0308 035F 006C');
# Inverted Breve bridging OU with possible double macron below (occurring before breve)
my @bridging_breve_test = ('004F 0311 0055', '004F 0311 0075', '006F 0311 0075', '004F 035F 0311 0055', '004F 035F 0311 0075', '006F 035F 0311 0075', '004F 0361 0055', '004F 0361 0075', '006F 0361 0075', '004F 035F 0361 0055', '004F 035F 0361 0075', '006F 035F 0361 0075');

push(@bridging_diacritics_test, @bridging_diaresis_test);
push(@bridging_diacritics_test, @bridging_breve_test);
#WP_test_output('bridging diacs', '1052=1', @bridging_diacritics_test);
my ($brig_feat_id) = Font::TTF::GrFeat->tag_to_num('brig');
WP_test_output('bridging diacs', "$brig_feat_id=1", @bridging_diacritics_test);
	
foreach my $featsets (sort sort_tests keys %featset_to_usvs)
{
	#TODO: should we process only feature interactions of interest? do all of them for now

	#create feature activation string ($featsets_str) for WorldPad
	my $featsets_str = '';
	my @featset = split(/\s/, $featsets);
	foreach my $featset (@featset)
	{
		my ($feat_tag, $set_tag);
		if ($featset =~ /(.*)-(.*)/)
			{($feat_tag, $set_tag) = ($1, $2);}
		else
			{die("feature-value pair is corrupt: $featset\n");}
		my ($gdl_tag, $set_id) = Feats_to_ids($feat_tag, $set_tag, %feats);
		my ($feat_id) = Font::TTF::GrFeat->tag_to_num($gdl_tag); #convert four char GDL feature tag
		$featsets_str .= "$feat_id=$set_id,";
	}
	$featsets_str = substr($featsets_str, 0, -1); #remove final ','
	
	my @usv_str = sort @{$featset_to_usvs{$featsets}};
	
	if ($featsets eq 'CmbBrvCyr-T')
	{
		foreach (@usv_str) {$_ = '25CC ' . $_};
	}
	WP_test_output($featsets, $featsets_str, @usv_str);
}
		
print FH <<"EOS";
</Body>

</WpDoc>
EOS

close FH;
}

exit;
