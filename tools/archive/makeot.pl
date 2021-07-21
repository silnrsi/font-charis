# Overview:
#  parse the AP db and build glyph data structs
#  declare data structs for OT data (GSUB, GDEF, GPOS)
#  iterate over the glyph data structs and build OT data structs for lookups
#  build custom data structs for glyphs that are more complex variants
#  build GSUB lookups, including many-to-one rules for USVs with decompositions
#  build the whole GSUB table (scripts, features, lookups)
#  build the GPOS table

use strict;
use Font::TTF::Font;
use Font::TTF::Features::Cvar;
use Font::TTF::Features::Sset;
use XML::Parser::Expat;
use Getopt::Std;
use Unicode::Normalize;
use Unicode::UCD qw(charinfo casefold);
#use Unicode::MakeEquivalents qw(permuteCompositeChar);
use Text::Unicode::Equivalents qw(all_strings);
use Font::TTF::Coverage;
use Font::TTF::GSUB;
use Font::TTF::GPOS;
use Font::TTF::GDEF;

our ($opt_w, $opt_d, $opt_k);
getopts('wdk:');

#workaround a new feature in Font::TTF that causes all coverage tables to be modified
# so that the coverage indexes are reasssigned based on glyph id order
#$Font::TTF::Coverage::dontsort = 1;

my ($gentium_f) = (0); #flag set if Gentium is being processed (LP diacs & Greek needed)
my ($andika_f) = (0);
my ($andika_basics_f) = (0);

unless (defined $ARGV[2])
{
    die <<'EOT';
    makeot [-w] [-d] [-k kernfile.pl] infile.xml infile.ttf outfile.ttf
Creates OT tables from Attachment Point database (infile.xml) and
input font file (infile.ttf), writing resultant font file outfile.ttf.

    -w print warnings
    -d print debug information
    -k load kerning data for kern feature from kernfile.pl
EOT
}

#bookmark: glyph data
my @glyphs = (); #	array, by glyph ID, of structures containing:
#	'gnum'	glyph number
#	'uni'	USV
#	'post'	PSName (looked up from post table in font)
#	'glyph'	Font::TTF::Glyph structure from font
#	'props'	hash of interesting properties:
#		'drawn'	1 if glyph is a TT contour rather than a composite
#	'points' hash of attachment points, indexed by attachment point "type" (aka name) containing:
#		'name'	type (aka name) of point
#		'cont'	index of the contour that defines the point (must be single-point contour)
#		'x'		x value of point
#		'y'		y value of point
#	'typen'	Type of glyph:
#		1	base glyph
#		2..6 indicates (_U, _L, _H, _O, _R) points defined for glyph (if more than one, the highest value wins)
#	'typeb'	Type of AP's available: bit field:
#		x2 = U, x8 = L, x20 = H, x80 = O, x200 = R
# Other properties from Attachment Point database (do not use except in checking)
#	'GID'	Glyph number (as decimal digits)
#	'PSName' PSName
#	'UID'	USV (as hex digits)


my %gnames;	# hash indexed by PSName, returning glyph ID
my %gunis;	# hash indexed by Unicode, returning glyph ID

my @baseGIDs;	# array of GIDs of base glyphs

####### All hard coded glyphs are tested before inclusion in substitution lookups #######

# The following is now picked up from the attacment point database.  RMH
my %viet_comb;	# = (
#    'uni0302_acutecomb.VNStyle' => ['uni0302', 'acutecomb'],
#    'uni0302_gravecomb.VNStyle' => ['uni0302', 'gravecomb'],
#    'uni0302_hookabovecomb.VNStyle' => ['uni0302', 'hookabovecomb'],
#    'uni0302_tildecomb.VNStyle' => ['uni0302', 'tildecomb'],
#    'uni0306_acutecomb.VNStyle' => ['uni0306', 'acutecomb'],
#    'uni0306_gravecomb.VNStyle' => ['uni0306', 'gravecomb'],
#    'uni0306_hookabovecomb.VNStyle' => ['uni0306', 'hookabovecomb'],
#    'uni0306_tildecomb.VNStyle' => ['uni0306', 'tildecomb']
#    );

# We don't need to decompose these any more.
#my %viet_precomp # = (
#    'uni1EA4' => ['A', 'uni0302_acutecomb.VNStyle'],
#    'uni1EA6' => ['A', 'uni0302_gravecomb.VNStyle'],
#    'uni1EA7' => ['a', 'uni0302_gravecomb.VNStyle'],
#    'uni1EA8' => ['A', 'uni0302_hookabovecomb.VNStyle'],
#    'uni1EA9' => ['a', 'uni0302_hookabovecomb.VNStyle'],
#    'uni1EAA' => ['A', 'uni0302_tildecomb.VNStyle'],
#    'uni1EAB' => ['a', 'uni0302_tildecomb.VNStyle'],
#    'uni1EAE' => ['A', 'uni0306_acutecomb.VNStyle'],
#    'uni1EAF' => ['a', 'uni0306_acutecomb.VNStyle'],
#    'uni1EB0' => ['A', 'uni0306_gravecomb.VNStyle'],
#    'uni1EB1' => ['a', 'uni0306_gravecomb.VNStyle'],
#    'uni1EB2' => ['A', 'uni0306_hookabovecomb.VNStyle'],
#    'uni1EB3' => ['a', 'uni0306_hookabovecomb.VNStyle'],
#    'uni1EB4' => ['A', 'uni0306_tildecomb.VNStyle'],
#    'uni1EB5' => ['a', 'uni0306_tildecomb.VNStyle'],
#    'uni1EBE' => ['E', 'uni0302_acutecomb.VNStyle'],
#    'uni1EBF' => ['e', 'uni0302_acutecomb.VNStyle'],
#    'uni1EC0' => ['E', 'uni0302_gravecomb.VNStyle'],
#    'uni1EC1' => ['e', 'uni0302_gravecomb.VNStyle'],
#    'uni1EC2' => ['E', 'uni0302_hookabovecomb.VNStyle'],
#    'uni1EC3' => ['e', 'uni0302_hookabovecomb.VNStyle'],
#    'uni1EC4' => ['E', 'uni0302_tildecomb.VNStyle'],
#    'uni1EC5' => ['e', 'uni0302_tildecomb.VNStyle'],
#    'uni1ED0' => ['O', 'uni0302_acutecomb.VNStyle'],
#    'uni1ED1' => ['o', 'uni0302_acutecomb.VNStyle'],
#    );

# Dotted base chars that need dot removed (by decomposition):
#  key glyphs that don't exist in a given font will be excluded from the di_csub lookup
# TODO: are LtnSmI.Dotless.LP and LtnSmI.Dotless.SItal.LP glyphs needed?
my %special_dotted = (
	'uni1E2D' => ['i.Dotless', 'uni0330'],  #uni1E2D - LtnSmITildeBlw
	'uni1E2D.SItal' => ['i.Dotless.SItal', 'uni0330'],
	'uni1E2D.LP' => ['i.Dotless', 'uni0330'],
	'uni1E2D.SItal.LP' => ['i.Dotless.SItal', 'uni0330'],
	'uni1E2D.TailI' => ['dotlessi.TailI', 'uni0330'], #dotlessi.TailI used in composites
	'uni1ECB' => ['i.Dotless', 'dotbelowcomb'],  #uni1ECB - LtnSmIDotBlw
	'uni1ECB.SItal' => ['i.Dotless.SItal', 'dotbelowcomb'],
	'uni1ECB.SItal.LP' => ['i.Dotless.SItal', 'dotbelowcomb'],
	'uni1ECB.LP' => ['i.Dotless', 'dotbelowcomb'],
	'uni1ECB.TailI' => ['dotlessi.TailI', 'dotbelowcomb'],
	);

# Precomposed that require ligature rules:
# (G/g/K/k/L/l/N/n/R/r + cedilla *always* display as precomposed (base + commaaccent); we do this by forcing Unicode's composition)
my %required_comp = (map {$_ => 1} (qw(
		Gcommaaccent gcommaaccent Kcommaaccent kcommaaccent Lcommaaccent lcommaaccent
		Ncommaaccent ncommaaccent Rcommaaccent rcommaaccent)));

# Precomposed glyphs that should NOT have ligature rules
# CombGrDialTonos (only in Gentium) decomposes to CombDiaer & CombAcute
# but this looks quite bad (acute is between the dots, left overstriking glyph)
# The character (U+0344) is also discouraged in Unicode.
# It might be neeeded in Greek or for original Gentium compatibility.
# TODO: decide what to do with this glyph in the next full release
my %required_decomp = (map {$_ => 1} (qw(uni0344)));

my @fi = qw(f i l);

# miscellaneous single or multiple alts (for the aalt feature).
#	key = GID of nominal glyph (from cmap)
#	value = array of GIDs of alternates
my %misc_alts;

# list of superscript/modifier/subscript chars
# ordfeminine & ordmasculine do not have APs therefore removed from the list
# glyphs listed here which don't exist in a particular font will be filtered out later
my @superscript = qw(
	uni02B0 uni02B1 uni02B2 uni02B3 uni02B4 uni02B5 uni02B6 uni02B7 uni02B8
	uni02C0 uni02C1 uni02E0 uni02E1 uni02E2 uni02E3 uni02E4
	uni1D2C uni1D2D uni1D2E uni1D2F
	uni1D30 uni1D31 uni1D32 uni1D33 uni1D34 uni1D35 uni1D36 uni1D37
	uni1D38 uni1D39 uni1D3A uni1D3B uni1D3C uni1D3D uni1D3E uni1D3F
	uni1D40 uni1D41 uni1D42 uni1D43 uni1D44 uni1D45 uni1D46 uni1D47
	uni1D48 uni1D49 uni1D4A uni1D4B uni1D4C uni1D4D uni1D4E uni1D4F
	uni1D50 uni1D51 uni1D52 uni1D53 uni1D54 uni1D55 uni1D56 uni1D57
	uni1D58 uni1D59 uni1D5A uni1D5B uni1D5C uni1D5D uni1D5E uni1D5F
	uni1D60 uni1D61 uni1D78
	uni1D9B uni1D9C uni1D9D uni1D9E uni1D9F
	uni1DA0 uni1DA1 uni1DA2 uni1DA3 uni1DA4 uni1DA5 uni1DA6 uni1DA7
	uni1DA8 uni1DA9 uni1DAA uni1DAB uni1DAC uni1DAD uni1DAE uni1DAF
	uni1DB0 uni1DB1 uni1DB2 uni1DB3 uni1DB4 uni1DB5 uni1DB6 uni1DB7
	uni1DB8 uni1DB9 uni1DBA uni1DBB uni1DBC uni1DBD uni1DBE uni1DBF
	uni2071 uni207F

	uni1D62 uni1D63 uni1D64 uni1D65 uni1D66 uni1D67 uni1D68 uni1D69 uni1D6A
	uni2090 uni2091 uni2092 uni2093 uni2094

	uni02B2.Dotless uni1D62.Dotless uni1DA1.Dotless uni1DA4.Dotless uni1DA8.Dotless uni2071.Dotless
	uni1D43.SngStory uni1D4D.SngBowl uni2090.SngStory #single story glyphs are encoded in Andika
	);

# list of diacritics that have low profile variants. all these glyphs must have .LP variants
my @lowprof_diacs = qw(
	acutecomb gravecomb uni0302 uni030C tildecomb uni0304 uni0308 uni0307
	uni0302_acutecomb.VN uni0302_gravecomb.VN uni0302_tildecomb.VN uni0302_hookabovecomb.VN
	uni0306_acutecomb.VN uni0306_gravecomb.VN uni0306_tildecomb.VN uni0306_hookabovecomb.VN
	);

#bookmark: cs/ss data
# the below lists features and lookups that only exist in Gentium and Andika
my @gentium_cv_feat_lst = qw(cv14 cv78 ss07);
my @gentium_cv_lkup_lst = qw(srfb_sub pcx_sub lpv_sub);
my @andika_cv_feat_lst = qw(cv01 cv04 cv06 cv07 cv10 cv31 cv34 cv39 cv51 cv52 cv56 cv67);
my @andika_cv_lkup_lst = qw(1_sub 4_sub 69_sub 7_sub zero_sub itl_sub jsrf_sub ltl_sub 
	qtl_sub q_sub ttl_sub ytl_sub);

# the below lists the only features in Anidka Basics however they are not unique to that font
#  except for cv35 (for now)
my @andika_basics_feat_lst = qw(aalt ccmp cv01 cv04 cv06 cv07 
	cv10 cv31 cv34 cv35 cv39 cv43 cv44 cv46 cv51 cv52 cv56 cv67 cv68 cv70 cv71 cv75
	ss01 ss05);
push @andika_basics_feat_lst, "ccmp _1"; #doesn't work with qw syntax

# starting name id for cv & ss features
my $cv_ss_name_id_start = 4096;

# character variant feature data

# template for character variant
#  InDesign CC doesn't work with the 'Characters' array present [FTLS-120]
#   so the add_cv_feat() subroutine does NOT copy the 'characters' array specified below
# source cv   insert: _alts _sub cv
#my $_cv = {
#	'glyphs' => [{'base' => '', 'alts' => ['', ]}],
#	'feature_name' => '',
#	'tooltip' => '',
#	'sample_str' => "\x{}", 
#	'param_names' => ['', ],
#	'characters' => [0x, ],  
#	};

# Andika
# source cv done: one_no_base 1_sub cv01
my $one_no_base_cv = {
	'glyphs' => [{'base' => 'one', 'alts' => ['one.NoBase']}, 
		{'base' => 'uni2081', 'alts' => ['uni2081.NoBase']}, 
		{'base' => 'onesuperior', 'alts' => ['onesuperior.NoBase']}],
	'feature_name' => 'Digit One without base',
	'tooltip' => 'Dig One no base',
	'sample_str' => "\x{0031}\x{2081}\x{00B9}", 
	'param_names' => ['No base'],
	'characters' => [0x0031, 0x2081, 0x00B9],  
	};

# Andika
# source cv done: four_open_alts 4_sub cv04
my $four_open_alts_cv = {
	'glyphs' => [{'base' => 'four', 'alts' => ['four.Open']}, 
		{'base' => 'uni2084', 'alts' => ['uni2084.Open']}, 
		{'base' => 'uni2074', 'alts' => ['uni2074.Open']}],
	'feature_name' => 'Digit Four with open loop',
	'tooltip' => 'Dig Four open',
	'sample_str' => "\x{0034}\x{2084}\x{2074}", 
	'param_names' => ['Open'],
	'characters' => [0x0034, 0x2084, 0x2074],  
	};

# Andika
# source cv done: six_nine_alts 69_sub cv06
my $six_nine_alts_cv = {
	'glyphs' => [{'base' => 'six', 'alts' => ['six.Diag']}, 
		{'base' => 'uni2086', 'alts' => ['uni2086.Diag']}, 
		{'base' => 'uni2076', 'alts' => ['uni2076.Diag']}, 
		{'base' => 'nine', 'alts' => ['nine.Diag']}, 
		{'base' => 'uni2089', 'alts' => ['uni2089.Diag']}, 
		{'base' => 'uni2079', 'alts' => ['uni2079.Diag']}],
	'feature_name' => 'Digit Six and Nine alternates',
	'tooltip' => 'Dig Six & Nine alts',
	'sample_str' => "\x{0036}\x{2086}\x{2079}\x{0039}\x{2089}\x{2079}", 
	'param_names' => ['Diagonal stem'],
	'characters' => [0x0036, 0x2086, 0x2079, 0x0039, 0x2089, 0x2079],  
	};

# Andika
# source cv done: seven_bar 7_sub cv07
my $seven_bar_cv = {
	'glyphs' => [{'base' => 'seven', 'alts' => ['seven.Bar']}, 
		{'base' => 'uni2087', 'alts' => ['uni2087.Bar']}, 
		{'base' => 'uni2077', 'alts' => ['uni2077.Bar']}],
	'feature_name' => 'Digit Seven with bar',
	'tooltip' => 'Dig Seven bar',
	'sample_str' => "\x{0037}\x{2087}\x{2077}", 
	'param_names' => ['Bar'],
	'characters' => [0x0037, 0x2087, 0x2077],  
	};

# Andika
# source cv done: zero_slash zero_sub cv10
my $zero_slash_cv = {
	'glyphs' => [{'base' => 'zero', 'alts' => ['zero.Slash'], 
		{'base' => 'uni2070', 'alts' => ['uni2070.Slash']}}, 
		{'base' => 'uni2080', 'alts' => ['uni2080.Slash']}],
	'feature_name' => 'Digit Zero with slash',
	'tooltip' => 'Dig Zero slash',
	'sample_str' => "\x{0030}\x{2070}\x{2080}", 
	'param_names' => ['Slash'],
	'characters' => [0x0030, 0x2070, 0x2080],  
	};

# source cv done: cap_b_hk_alt bhk_sub cv13
my $cap_b_hk_alt_cv = {
	'glyphs' => [{'base' => 'uni0181', 'alts' => ['uni0181.TopBar']}, 
		{'base' => 'uni0253.sc', 'alts' => ['uni0253.TopBar.sc']}],
	'feature_name' => 'Capital B-hook alternate',
	'tooltip' => 'Cap B-hook alt',
	'sample_str' => "\x{0181}", 
	'param_names' => ['Lowercase style'],
	'characters' => [0x0181],  
	};

# Gentium
# source cv done: serif_b_alts srfb_sub cv14
my $serif_b_alts_cv = {
	'glyphs' => [{'base' => 'beta', 'alts' => ['beta.Serif']}, 
		{'base' => 'uni1D66', 'alts' => ['uni1D66.Serif']}, 
		{'base' => 'uni1D5D', 'alts' => ['uni1D5D.Serif']}],
	'feature_name' => 'Serif beta alternates',
	'tooltip' => 'Serif beta alt',
	'sample_str' => "\x{03B2}\x{1D66}\x{1D5D}}", 
	'param_names' => ['Serif'],
	'characters' => [0x03B2, 0x1D66, 0x1D5D],  
	};

# source cv done: cap_d_hook_alt dhk_sub cv17
my $cap_d_hook_alt_cv = {
	'glyphs' => [{'base' => 'uni018A', 'alts' => ['uni018A.TopBar']}, 
		{'base' => 'uni0257.sc', 'alts' => ['uni0257.TopBar.sc']}],
	'feature_name' => 'Capital D-hook alternate',
	'tooltip' => 'Cap D-hook alt',
	'sample_str' => "\x{018A}", 
	'param_names' => ['Lowercase style'],
	'characters' => [0x018A],  
	};

# source cv done: sm_ezh_curl_alt ezhcurl_sub cv19
my $sm_ezh_curl_alt_cv = {
	'glyphs' => [{'base' => 'uni0293', 'alts' => ['uni0293.LrgBowl']}],
	'feature_name' => 'Small ezh-curl alternate',
	'tooltip' => 'Sm ezh-curl alt',
	'sample_str' => "\x{0293}", 
	'param_names' => ['Large bowl'],
	'characters' => [0x0293],  
	};

# 01B7 & 0292 are Latin while 04E0 & 04E1 are Cyrillic
# source cv done: cap_ezh_alt ezh_sub cv20
my $cap_ezh_alt_cv = {
	'glyphs' => [{'base' => 'uni01B7', 'alts' => ['uni01B7.RevSigmaStyle']}, 
		{'base' => 'uni04E0', 'alts' => ['uni04E0.RevSigmaStyle']}, 
		{'base' => 'uni0292.sc', 'alts' => ['uni0292.RevSigmaStyle.sc']}, 
		{'base' => 'uni04E1.sc', 'alts' => ['uni04E1.RevSigmaStyle.sc']}],
	'feature_name' => 'Capital Ezh alternates', 
	'tooltip' => 'Cap Ezh alts',
	'sample_str' => "\x{01B7}\x{04E0}", 
	'param_names' => ['Reversed sigma'],
	'characters' => [0x01B7, 0x04E0],  
	};

# source cv done: rams_horn_alts rams_sub cv25
my $rams_horn_alts_cv = {
	'glyphs' => [{'base' => 'uni0264', 'alts' => ['uni0264.LrgBowl', 'uni0264.GammaStyle']}],
	'feature_name' => 'Rams horn alternates',
	'tooltip' => 'Rams horn alts',
	'sample_str' => "\x{0264}", 
	'param_names' => ['Large Bowl', 'Small gamma'],
	'characters' => [0x0264],  
	};

# source cv done: cap_h_strk_alt hstrk_sub cv28
my $cap_h_strk_alt_cv = {
	'glyphs' => [{'base' => 'Hbar', 'alts' => ['Hbar.VertStrk']}, 
		{'base' => 'hbar.sc', 'alts' => ['hbar.VertStrk.sc']}],
	'feature_name' => 'Capital H-stroke alternate',
	'tooltip' => 'Cap H-stroke alt',
	'sample_str' => "\x{0126}", 
	'param_names' => ['Vertical-stroke'], 
	'characters' => [0x0126],  
	};

# Andika
# glyphs determined from Features.xml file
#  previous feat interact: dot removal, f ligs lookups
#  previous feat interact: small caps (if applied) overrides this feature, so no sub happens
#  later features interact: ogonek straight
#  later features not interact: slant italic (i-tail overrides slant italic in Andika, for now)
# Did not generate w algorithm because of desire to sort by USV and keep data parallel
#  USV would have to determined by stripping off suffix and looking for non-variant glyph's USV
# source cv done: small_i_tail_alts itl_sub cv31
my $small_i_tail_alts_cv = {
	'glyphs' => [{'base' => 'i', 'alts' => ['i.TailI']}, 
		{'base' => 'igrave', 'alts' => ['igrave.TailI']}, 
		{'base' => 'iacute', 'alts' => ['iacute.TailI']}, 
		{'base' => 'icircumflex', 'alts' => ['icircumflex.TailI']}, 
		{'base' => 'idieresis', 'alts' => ['idieresis.TailI']}, 
		{'base' => 'itilde', 'alts' => ['itilde.TailI']}, 
		{'base' => 'imacron', 'alts' => ['imacron.TailI']}, 
		{'base' => 'ibreve', 'alts' => ['ibreve.TailI']}, 
		{'base' => 'iogonek', 'alts' => ['iogonek.TailI']}, 
		{'base' => 'dotlessi', 'alts' => ['dotlessi.TailI']}, 
		{'base' => 'uni01D0', 'alts' => ['uni01D0.TailI']}, 
		{'base' => 'uni0209', 'alts' => ['uni0209.TailI']}, 
		{'base' => 'uni020B', 'alts' => ['uni020B.TailI']}, 
		{'base' => 'uni0268', 'alts' => ['uni0268.TailI']}, 
		{'base' => 'uni0365', 'alts' => ['uni0365.TailI']}, 
		{'base' => 'uni1D62', 'alts' => ['uni1D62.TailI']}, 
		{'base' => 'uni1DA4', 'alts' => ['uni1DA4.TailI']}, 
		{'base' => 'uni1DA4.Dotless', 'alts' => ['uni1DA4.Dotless.TailI']}, 
		{'base' => 'uni1E2D', 'alts' => ['uni1E2D.TailI']}, 
		{'base' => 'uni1E2F', 'alts' => ['uni1E2F.TailI']}, 
		{'base' => 'uni1EC9', 'alts' => ['uni1EC9.TailI']}, 
		{'base' => 'uni1ECB', 'alts' => ['uni1ECB.TailI']}, 
		{'base' => 'uni2071', 'alts' => ['uni2071.TailI']}, 
		{'base' => 'fi', 'alts' => ['fi.TailI']}, 
		{'base' => 'ffi', 'alts' => ['ffi.TailI']}, 
		{'base' => 'f_i', 'alts' => ['f_i.TailI']}, 
		{'base' => 'f_f_i', 'alts' => ['f_f_i.TailI']}],
	'feature_name' => 'Small i-tail alternates',
	'tooltip' => 'Small i-tail alts',
	'sample_str' => "\x{0069}\x{00EC}\x{00ED}\x{00EE}\x{00EF}".
		"\x{0129}\x{012B}\x{012D}\x{012F}\x{0131}\x{01D0}\x{0209}\x{020B}\x{0268}\x{0365}".
		"\x{1D62}\x{1DA4}\x{1E2D}\x{1E2F}\x{1EC9}\x{1ECB}\x{2071}\x{FB01}\x{FB03}", 
	'param_names' => ['Curved tail'],
	'characters' => [0x0069, 0x00EC, 0x00ED, 0x00EE, 0x00EF, 
		0x0129, 0x012B, 0x012D, 0x012F, 0x0131, 0x01D0, 0x0209, 0x020B, 0x0268, 0x0365, 
		0x1D62, 0x1DA4, 0x1E2D, 0x1E2F, 0x1EC9, 0x1ECB, 0x2071, 0xFB01, 0xFB03],  
	};

# Andika
# glyphs determined from Features.xml file
#  previous feat interact: dot removal
#  previous feat interact: small caps (if applied) overrides this feature, so no sub happens
#  later features interact: none
#  later features not interact: none
# TODO: should LtnSmJ.Dotless.TopLftSerif and LtnSmJStrk.*.* glyphs be created?
# source cv done: small_j_serif_alts jsrf_sub cv34
my $small_j_serif_alts_cv = {
	'glyphs' => [{'base' => 'j', 'alts' => ['j.TopLftSerif']}, 
		{'base' => 'jcircumflex', 'alts' => ['jcircumflex.TopLftSerif']}, 
		{'base' => 'uni01F0', 'alts' => ['uni01F0.TopLftSerif']}, 
		{'base' => 'uni0237', 'alts' => ['uni0237.TopLftSerif']}, 
		{'base' => 'uni0249', 'alts' => ['uni0249.TopLftSerif']}, 
		{'base' => 'uni025F', 'alts' => ['uni025F.TopLftSerif']}, 
		{'base' => 'uni029D', 'alts' => ['uni029D.TopLftSerif']}, 
		{'base' => 'uni029D.Dotless', 'alts' => ['uni029D.Dotless.TopLftSerif']}, 
		{'base' => 'uni02B2', 'alts' => ['uni02B2.TopLftSerif']}, 
		{'base' => 'uni02B2.Dotless', 'alts' => ['uni02B2.Dotless.TopLftSerif']}, 
		{'base' => 'uni1DA1', 'alts' => ['uni1DA1.TopLftSerif']}, 
		{'base' => 'uni1DA8', 'alts' => ['uni1DA8.TopLftSerif']}, 
		{'base' => 'uni1DA8.Dotless', 'alts' => ['uni1DA8.Dotless.TopLftSerif']}, 
		{'base' => 'uni2C7C', 'alts' => ['uni2C7C.TopLftSerif']}],
	'feature_name' => 'Small j-serif alternates',
	'tooltip' => 'Small j-serif alts',
	'sample_str' => "\x{006A}\x{0135}\x{01F0}\x{0237}\x{0249}\x{025F}\x{029D}\x{02B2}\x{1DA1}\x{1DA8}\x{2C7C}", 
	'param_names' => ['Top serif'],
	'characters' => [0x006A, 0x0135, 0x01F0, 0x0237, 0x0249, 0x025F, 0x029D, 0x02B2, 0x1DA1, 0x1DA8, 0x2C7C],  
	};

# Andika Basics
# TODO: Will affect more 'J' glyphs in the full glyph set in the future
#  but those glyphs do not exist yet in Andika Basics
# not built from template but would be:
#  cap_j_alt j_sub cv35
my $cap_j_alt_cv = {
	'glyphs' => [{'base' => 'J', 'alts' => ['J.BarTop']}],
	'feature_name' => 'Capital J alternate',
	'tooltip' => 'Cap J alt',
	'sample_str' => "\x{004A}", 
	'param_names' => ['Top bar'],
	'characters' => [0x004A],  
	};

# source cv done: j_strk_hook_alt jstrk_sub cv37
my $j_strk_hook_alt_cv = {
	'glyphs' => [{'base' => 'uni0284', 'alts' => ['uni0284.DblSerif']}],
	'feature_name' => 'J-stroke hook alternate',
	'tooltip' => 'J-strok alt',
	'sample_str' => "\x{0284}", 
	'param_names' => ['Top serif'],
	'characters' => [0x0284],  
	};

# Andika
# glyphs determined from Features.xml file
#  previous feat interact: fl ligs
#  previous feat interact: small caps (if applied) overrides this feature, so no sub happens
#  later features interact: non-eur caron
#  later features not interact: slant italic (l-tail overrides slant italic in Andika, for now)
# source cv done: small_l_tail_alts ltl_sub cv39
my $small_l_tail_alts_cv = {
	'glyphs' => [{'base' => 'l', 'alts' => ['l.TailL']}, 
		{'base' => 'lacute', 'alts' => ['lacute.TailL']}, 
		{'base' => 'lcommaaccent', 'alts' => ['lcommaaccent.TailL']}, 
		{'base' => 'lcaron', 'alts' => ['lcaron.TailL']}, 
		{'base' => 'ldot', 'alts' => ['ldot.TailL']}, 
		{'base' => 'lslash', 'alts' => ['lslash.TailL']}, 
		{'base' => 'uni019A', 'alts' => ['uni019A.TailL']}, 
		{'base' => 'uni026B', 'alts' => ['uni026B.TailL']}, 
		{'base' => 'uni026C', 'alts' => ['uni026C.TailL']}, 
		{'base' => 'uni02E1', 'alts' => ['uni02E1.TailL']}, 
		{'base' => 'uni1D85', 'alts' => ['uni1D85.TailL']}, 
		{'base' => 'uni1DAA', 'alts' => ['uni1DAA.TailL']}, 
		{'base' => 'uni1E37', 'alts' => ['uni1E37.TailL']}, 
		{'base' => 'uni1E39', 'alts' => ['uni1E39.TailL']}, 
		{'base' => 'uni1E3B', 'alts' => ['uni1E3B.TailL']}, 
		{'base' => 'uni1E3D', 'alts' => ['uni1E3D.TailL']}, 
		{'base' => 'uni2097', 'alts' => ['uni2097.TailL']}, 
		{'base' => 'uni2C61', 'alts' => ['uni2C61.TailL']}, 
		{'base' => 'uniA749', 'alts' => ['uniA749.TailL']}, 
		{'base' => 'fl', 'alts' => ['fl.TailL']}, 
		{'base' => 'ffl', 'alts' => ['ffl.TailL']}, 
		{'base' => 'f_l', 'alts' => ['f_l.TailL']}, 
		{'base' => 'f_f_l', 'alts' => ['f_f_l.TailL']}],
	'feature_name' => 'Small l-tailf alternates',
	'tooltip' => 'Small l-tail alts',
	'sample_str' => "\x{006C}\x{013A}\x{013C}\x{013E}\x{0140}\x{0142}\x{019A}".
		"\x{026B}\x{026C}\x{02E1}\x{1D85}\x{1DAA}\x{1E37}\x{1E39}\x{1E3B}\x{1E3D}".
		"\x{2097}\x{2C61}\x{A749}\x{FB02}\x{FB04}", 
	'param_names' => ['Curved tail'],
	'characters' => [0x006C, 0x013A, 0x013C, 0x013E, 0x0140, 0x0142, 0x019A, 
		0x026B, 0x026C, 0x02E1, 0x1D85, 0x1DAA, 0x1E37, 0x1E39, 0x1E3B, 0x1E3D, 
		0x2097, 0x2C61, 0xA749, 0xFB02, 0xFB04],  
	};

# source cv done: upper_eng_alts engs_sub cv43
my $upper_eng_alts_cv = {
	'glyphs' => [{'base' => 'Eng', 'alts' => ['Eng.BaselineHook', 'Eng.UCStyle', 'Eng.Kom']}, 
		{'base' => 'eng.sc', 'alts' => ['eng.BaselineHook.sc', 'eng.UCStyle.sc', 'eng.Kom.sc']}],
	'feature_name' => 'Uppercase Eng alternates',
	'tooltip' => 'Uppercase Eng alts',
	'sample_str' => "\x{014A}", 
#	'param_names' => ['Large eng with descender', 'Large eng on baseline', 'Capital N with tail', 'Large eng with short stem'],
	'param_names' => ['Large eng on baseline', 'Capital N with tail', 'Large eng with short stem'],
	'characters' => [0x014A],  
	};

# source cv done: cap_n_lft_hk_alt nhk_sub cv44
my $cap_n_lft_hk_alt_cv = {
	'glyphs' => [{'base' => 'uni019D', 'alts' => ['uni019D.LCStyle']}, 
		{'base' => 'uni0272.sc', 'alts' => ['uni0272.LCStyle.sc']}],
	'feature_name' => 'Capital N-left-hook alternate',
	'tooltip' => 'Cap N-left-hook alt',
	'sample_str' => "\x{019D}", 
	'param_names' => ['Lowercase style'],
	'characters' => [0x019D],  
	};

# source cv done: open_o_alt opno_sub cv46
my $open_o_alt_cv = {
	'glyphs' => [{'base' => 'uni0186', 'alts' => ['uni0186.TopSerif']}, 
		{'base' => 'uni0254', 'alts' => ['uni0254.TopSerif']}, 
		{'base' => 'uni1D10', 'alts' => ['uni1D10.TopSerif']}, 
		{'base' => 'uni1D53', 'alts' => ['uni1D53.TopSerif']}, 
		{'base' => 'uni1D97', 'alts' => ['uni1D97.TopSerif']}, 
		{'base' => 'uni0254.sc', 'alts' => ['uni0254.TopSerif.sc']}],
	'feature_name' => 'Open-O alternates',
	'tooltip' => 'Open-O alts',
	'sample_str' => "\x{0186}\x{0254}\x{1D10}\x{1D53}\x{1D97}", 
	'param_names' => ['Top serif'],
	'characters' => [0x0186, 0x0254, 0x1D10, 0x1D53, 0x1D97],  
	};

# source cv done: ou_alt ou_sub cv47
my $ou_alt_cv = {
	'glyphs' => [{'base' => 'uni0222', 'alts' => ['uni0222.OpenTop']}, 
		{'base' => 'uni0223', 'alts' => ['uni0223.OpenTop']}, 
		{'base' => 'uni1D15', 'alts' => ['uni1D15.OpenTop']}, 
		{'base' => 'uni1D3D', 'alts' => ['uni1D3D.OpenTop']}, 
		{'base' => 'uni0223.sc', 'alts' => ['uni0223.OpenTop.sc']}], 
	'feature_name' => 'OU alternates',
	'tooltip' => 'OU alts',
	'sample_str' => "\x{0222}\x{0223}\x{1D15}\x{1D3D}", 
	'param_names' => ['Open'],
	'characters' => [0x0222, 0x0223, 0x1D15, 0x1D3D], 
	};

# the small cap feature overrides the bowl hook
#  so applying this feature to the smcp glyph has no affect
# source cv done: sm_p_hk_alt phk_sub cv49
my $sm_p_hk_alt_cv = {
	'glyphs' => [{'base' => 'uni01A5', 'alts' => ['uni01A5.BowlHook']}],
	'feature_name' => 'Small p-hook alternate',
	'tooltip' => 'Sm p-hook alt',
	'sample_str' => "\x{01A5}", 
	'param_names' => ['Right hook'],
	'characters' => [0x01A5],  
	};

# Andika
# small caps overrides, so no sub done
# source cv done: small_q_tail_alts qtl_sub cv51
my $small_q_tail_alts_cv = {
	'glyphs' => [{'base' => 'q', 'alts' => ['q.Point']}, 
		{'base' => 'uni02A0', 'alts' => ['uni02A0.Point']}, 
		{'base' => 'uniA757', 'alts' => ['uniA757.Point']}, 
		{'base' => 'uniA759', 'alts' => ['uniA759.Point']}],
	'feature_name' => 'Small q-tail alternates',
	'tooltip' => 'Small q-tail alts',
	'sample_str' => "\x{0071}\x{02A0}\x{A757}\x{A759}", 
	'param_names' => ['Point'],
	'characters' => [0x0071, 0x02A0, 0xA757, 0xA759],  
	};

# Andika
# interacts with small caps, if applied
# source cv done: cap_q_alts q_sub cv52
my $cap_q_alts_cv = {
	'glyphs' => [{'base' => 'Q', 'alts' => ['Q.DiagTail']}, 
		{'base' => 'uniA756', 'alts' => ['uniA756.DiagTail']}, 
		{'base' => 'uniA758', 'alts' => ['uniA758.DiagTail']}, 
		{'base' => 'q.sc', 'alts' => ['q.DiagTail.sc']}, 
		{'base' => 'uniA757.sc', 'alts' => ['uniA757.DiagTail.sc']}, 
		{'base' => 'uniA759.sc', 'alts' => ['uniA759.DiagTail.sc']}], 
	'feature_name' => 'Capital Q alternates',
	'tooltip' => 'Cap Q alts',
	'sample_str' => "\x{0051}\x{A756}\x{A758}", 
	'param_names' => ['Tail across'],
	'characters' => [0x0051, 0xA756, 0xA758],  
	};

# The SIL names for the below glyphs do not follow the normal suffix conventions
#  but the PS names do
# source cv done: cap_r_tail_alt rtl_sub cv55
my $cap_r_tail_alt_cv = {
	'glyphs' => [{'base' => 'uni2C64', 'alts' => ['uni2C64.LCStyle']}, 
		{'base' => 'uni027D.sc', 'alts' => ['uni027D.LCStyle.sc']}],
	'feature_name' => 'Capital R-tail alternate',
	'tooltip' => 'Cap R-tail alt',
	'sample_str' => "\x{2C64}", 
	'param_names' => ['Lowercase style'],
	'characters' => [0x2C64],  
	};

# Andika
# small caps overrides, so no sub done
# non-eur caron interacts later
# source cv done: small_t_tail_alts ttl_sub cv56
my $small_t_tail_alts_cv = {
	'glyphs' => [{'base' => 't', 'alts' => ['t.NoTailT']}, 
	{'base' => 'uni0163', 'alts' => ['uni0163.NoTailT']}, 
	{'base' => 'tcaron', 'alts' => ['tcaron.NoTailT']}, 
	{'base' => 'tbar', 'alts' => ['tbar.NoTailT']}, 
	{'base' => 'uni01AB', 'alts' => ['uni01AB.NoTailT']}, 
	{'base' => 'uni01AD', 'alts' => ['uni01AD.NoTailT']}, 
	{'base' => 'uni021B', 'alts' => ['uni021B.NoTailT']}, 
	{'base' => 'uni0287', 'alts' => ['uni0287.NoTailT']}, 
	{'base' => 'uni02A6', 'alts' => ['uni02A6.NoTailT']}, 
	{'base' => 'uni02A7', 'alts' => ['uni02A7.NoTailT']}, 
	{'base' => 'uni02A8', 'alts' => ['uni02A8.NoTailT']}, 
	{'base' => 'uni036D', 'alts' => ['uni036D.NoTailT']}, 
	{'base' => 'uni1D57', 'alts' => ['uni1D57.NoTailT']}, 
	{'base' => 'uni1D75', 'alts' => ['uni1D75.NoTailT']}, 
	{'base' => 'uni1D7A', 'alts' => ['uni1D7A.NoTailT']}, 
	{'base' => 'uni1DB5', 'alts' => ['uni1DB5.NoTailT']}, 
	{'base' => 'uni1E6B', 'alts' => ['uni1E6B.NoTailT']}, 
	{'base' => 'uni1E6D', 'alts' => ['uni1E6D.NoTailT']}, 
	{'base' => 'uni1E6F', 'alts' => ['uni1E6F.NoTailT']}, 
	{'base' => 'uni1E71', 'alts' => ['uni1E71.NoTailT']}, 
	{'base' => 'uni1E97', 'alts' => ['uni1E97.NoTailT']}, 
	{'base' => 'uni209C', 'alts' => ['uni209C.NoTailT']}, 
	{'base' => 'uni2C66', 'alts' => ['uni2C66.NoTailT']}, 
	{'base' => 'uniA729', 'alts' => ['uniA729.NoTailT']}],
	'feature_name' => 'Small t-tail alternates',
	'tooltip' => 'Small t-tail alts',
	'sample_str' => "\x{0074}\x{0163}\x{0165}\x{0167}\x{01AB}\x{01AD}".
		"\x{021B}\x{0287}\x{02A6}\x{02A7}\x{02A8}\x{036D}".
		"\x{1D57}\x{1D75}\x{1D7A}\x{1DB5}\x{1E6B}\x{1E6D}\x{1E6F}\x{1E71}\x{1E97}".
		"\x{209C}\x{2C66}\x{A729}", 
	'param_names' => ['Straight'],
	'characters' => [0x0074, 0x0163, 0x0165, 0x0167, 0x01AB, 0x01AD, 
		0x021B, 0x0287, 0x02A6, 0x02A7, 0x02A8, 0x036D, 
		0x1D57, 0x1D75, 0x1D7A, 0x1DB5, 0x1E6B, 0x1E6D, 0x1E6F, 0x1E71, 0x1E97, 
		0x209C, 0x2C66, 0xA729],  
	};

# source cv done: cap_t_hk_alt thk_sub cv57
my $cap_t_hk_alt_cv = {
	'glyphs' => [{'base' => 'uni01AC', 'alts' => ['uni01AC.RtHook']}, 
		{'base' => 'uni01AD.sc', 'alts' => ['uni01AD.RtHook.sc']}],
	'feature_name' => 'Capital T-hook alternate',
	'tooltip' => 'Cap T-hook alt',
	'sample_str' => "\x{01AC}", 
	'param_names' => ['Right Hook'],
	'characters' => [0x01AC],  
	};

# source cv done: v_hook_alts vhk_sub cv62
my $v_hook_alts_cv = {
	'glyphs' => [{'base' => 'uni01B2', 'alts' => ['uni01B2.StraightLft', 'uni01B2.StraightLftHighHook']}, 
		{'base' => 'uni028B', 'alts' => ['uni028B.StraightLft', 'uni028B.StraightLftHighHook']}, 
		{'base' => 'uni1DB9', 'alts' => ['uni1DB9.StraightLft', 'uni1DB9.StraightLftHighHook']},
		{'base' => 'uni028B.sc', 'alts' => ['uni028B.StraightLft.sc', 'uni028B.StraightLftHighHook.sc']}],
	'feature_name' => 'V-hook alternates',
	'tooltip' => 'V-hook alts',
	'sample_str' => "\x{01B2}\x{028B}\x{1DB9}", 
	'param_names' => ['Straight with low hook', 'Straight with high hook'],
	'characters' => [0x01B2, 0x028B, 0x1DB9],  
	};

# Andika
# small caps overrides, so no sub done
# uni01B4.RtHook is encoded (instead of uni01B4 - LtnSmYHook)
#  the lower case glyphs are identical though with the hook on the right
# source cv done: small_y_tail_alts ytl_sub cv67
my $small_y_tail_alts_cv = {
	'glyphs' => [{'base' => 'y', 'alts' => ['y.NoTailY']}, 
		{'base' => 'yacute', 'alts' => ['yacute.NoTailY']}, 
		{'base' => 'ydieresis', 'alts' => ['ydieresis.NoTailY']}, 
		{'base' => 'ycircumflex', 'alts' => ['ycircumflex.NoTailY']}, 
		{'base' => 'uni01B4.RtHook', 'alts' => ['uni01B4.RtHook.NoTailY']}, 
		{'base' => 'uni0233', 'alts' => ['uni0233.NoTailY']}, 
		{'base' => 'uni024F', 'alts' => ['uni024F.NoTailY']}, 
		{'base' => 'uni028E', 'alts' => ['uni028E.NoTailY']}, 
		{'base' => 'uni02B8', 'alts' => ['uni02B8.NoTailY']}, 
		{'base' => 'uni1E8F', 'alts' => ['uni1E8F.NoTailY']}, 
		{'base' => 'uni1E99', 'alts' => ['uni1E99.NoTailY']}, 
		{'base' => 'ygrave', 'alts' => ['ygrave.NoTailY']}, 
		{'base' => 'uni1EF5', 'alts' => ['uni1EF5.NoTailY']}, 
		{'base' => 'uni1EF7', 'alts' => ['uni1EF7.NoTailY']}, 
		{'base' => 'uni1EF9', 'alts' => ['uni1EF9.NoTailY']}, 
		{'base' => 'uniF1CE', 'alts' => ['uniF1CE.NoTailY']}, 
		{'base' => 'uniF267', 'alts' => ['uniF267.NoTailY']}],
	'feature_name' => 'Small y-tail alternates',
	'tooltip' => 'Small y-tail alts',
	'sample_str' => "\x{0079}\x{00FD}\x{00FF}\x{0177}\x{01B4}".
		"\x{0233}\x{024F}\x{028E}\x{02B8}".
		"\x{1E8F}\x{1E99}\x{1EF3}\x{1EF5}\x{1EF7}\x{1EF9}\x{F1CE}\x{F267}", 
	'param_names' => ['Straight'],
	'characters' => [0x0079, 0x00FD, 0x00FF, 0x0177, 0x01B4, 
		0x0233, 0x024F, 0x028E, 0x02B8, 
		0x1E8F, 0x1E99, 0x1EF3, 0x1EF5, 0x1EF7, 0x1EF9, 0xF1CE, 0xF267],  
	};

#in Graphite, the LgYHk feature defaults to 'on' and settings turn it 'off', but OT can't do that
# RtHook variant is encoded, small cap feature also produces RtHook variant
# this feature must substitute the left hook form
# source cv done: cap_y_hook_alt yhk_sub cv68
my $cap_y_hook_alt_cv = {
	'glyphs' => [{'base' => 'uni01B3.RtHook', 'alts' => ['uni01B3']}, 
		{'base' => 'uni01B4.RtHook.sc', 'alts' => ['uni01B4.sc']}],
	'feature_name' => 'Capital Y-hook alternate',
	'tooltip' => 'Cap Y-hook alt',
	'sample_str' => "\x{01B4}", 
	'param_names' => ['Left hook'],
	'characters' => [0x01B3],  
	};

# below also include the Saltillo chars
# source cv done: mod_apos_alts apos_sub cv70
my $mod_apos_alts_cv = {
	'glyphs' => [{'base' => 'uni02BC', 'alts' => ['uni02BC.Lrg']}, 
		{'base' => 'uniA78B', 'alts' => ['uniA78B.Lrg']}, 
		{'base' => 'uniA78C', 'alts' => ['uniA78C.Lrg']}, 
		{'base' => 'uniA78C.sc', 'alts' => ['uniA78C.Lrg.sc']}],
	'feature_name' => 'Modifier apostrophe alternates',
	'tooltip' => 'Mod apostrophe alt',
	'sample_str' => "\x{02BC}\x{A78B}\x{A78C}", 
	'param_names' => ['Large'],
	'characters' => [0x02BC, 0xA78B, 0xA78C],  
	};

# source cv done: mod_colon_alt colon_sub cv71
my $mod_colon_alt_cv = {
	'glyphs' => [{'base' => 'uniA789', 'alts' => ['uniA789.Wide']}],
	'feature_name' => 'Modifier colon alternate',
	'tooltip' => 'Mod colon alt',
	'sample_str' => "\x{A789}", 
	'param_names' => ['Expanded'],
	'characters' => [0xA789],  
	};

# added by hand after other cv feats generated
# lookups (vd_sub, vc_sub) already exist for ccmp feature 
#  as used in 'latn-VIT ' script-language
#  so glyphs data not used to create lookups
#  vd_sub lookup is type 4, which isn't technically allowed in a cv
#   but we'll try it anyway
# use viet_diac_alts, vd_sub & vc_sub, cv75  
# characters determined from Features.xml file
# the USVs in the sample str and characters array are not parallel to the glyph data
#  but the spec does not require that so leave it for now
my $viet_diac_alts_cv = {
	'glyphs' => [], 
	'feature_name' => 'Vietnamese-style diacritics',
	'tooltip' => 'Viet diacritics',
	'sample_str' => "\x{1EA4}\x{1EA5}\x{1EA6}\x{1EA7}\x{1EA8}\x{1EA9}\x{1EAA}\x{1EAB}".
		"\x{1EAE}\x{1EAF}\x{1EB0}\x{1EB1}\x{1EB2}\x{1EB3}\x{1EB4}\x{1EB5}".
		"\x{1EBE}\x{1EBF}\x{1EC0}\x{1EC1}\x{1EC2}\x{1EC3}\x{1EC4}\x{1EC5}".
		"\x{1ED0}\x{1ED1}\x{1ED2}\x{1ED3}\x{1ED4}\x{1ED5}\x{1ED6}\x{1ED7}", 
	'param_names' => ['Vietnamese-style'],
	'characters' => [0x1EA4, 0x1EA5, 0x1EA6, 0x1EA7, 0x1EA8, 0x1EA9, 0x1EAA, 0x1EAB, 
		0x1EAE, 0x1EAF, 0x1EB0, 0x1EB1, 0x1EB2, 0x1EB3, 0x1EB4, 0x1EB5, 
		0x1EBE, 0x1EBF, 0x1EC0, 0x1EC1, 0x1EC2, 0x1EC3, 0x1EC4, 0x1EC5, 
		0x1ED0, 0x1ED1, 0x1ED2, 0x1ED3, 0x1ED4, 0x1ED5, 0x1ED6, 0x1ED7],  
	};

# did not add glyph data during suffix processing
#  because of interaction w literacy and small cap feats
# interacts w small-i tail feature in Andika
# source cv done: ogonek_alt ognk_sub cv76
my $ogonek_alt_cv = {
	'glyphs' => [
		{'base' => 'Aogonek', 'alts' => ['Aogonek.RetroHook']}, 
		{'base' => 'aogonek', 'alts' => ['aogonek.RetroHook']}, 
		{'base' => 'Eogonek', 'alts' => ['Eogonek.RetroHook']}, 
		{'base' => 'eogonek', 'alts' => ['eogonek.RetroHook']}, 
		{'base' => 'Iogonek', 'alts' => ['Iogonek.RetroHook']}, 
		{'base' => 'iogonek', 'alts' => ['iogonek.RetroHook']}, 
		{'base' => 'iogonek.TailI', 'alts' => ['iogonek.TailI.RetroHook']}, 
		{'base' => 'uni01EA', 'alts' => ['uni01EA.RetroHook']}, 
		{'base' => 'uni01EB', 'alts' => ['uni01EB.RetroHook']}, 
		{'base' => 'Uogonek', 'alts' => ['Uogonek.RetroHook']}, 
		{'base' => 'uogonek', 'alts' => ['uogonek.RetroHook']}, 
		{'base' => 'uni01EC', 'alts' => ['uni01EC.RetroHook']}, 
		{'base' => 'uni01ED', 'alts' => ['uni01ED.RetroHook']}, 
		{'base' => 'uni0328', 'alts' => ['uni0328.RetroHook']}, 
		{'base' => 'ogonek', 'alts' => ['ogonek.RetroHook']}, 
		{'base' => 'aogonek.SngStory', 'alts' => ['aogonek.SngStory.RetroHook']}, 
		{'base' => 'aogonek.sc', 'alts' => ['aogonek.RetroHook.sc']}, 
		{'base' => 'eogonek.sc', 'alts' => ['eogonek.RetroHook.sc']}, 
		{'base' => 'iogonek.sc', 'alts' => ['iogonek.RetroHook.sc']}, 
		{'base' => 'uni01EB.sc', 'alts' => ['uni01EB.RetroHook.sc']}, 
		{'base' => 'uogonek.sc', 'alts' => ['uogonek.RetroHook.sc']}, 
		{'base' => 'uni01ED.sc', 'alts' => ['uni01ED.RetroHook.sc']}, 
		], 
	'feature_name' => 'Ogonek alternate',
	'tooltip' => 'Ogonek alt',
	'sample_str' => "\x{0104}\x{0105}\x{0118}\x{0119}\x{012E}\x{012F}\x{01EB}\x{01EA}\x{0172}\x{0173}".
		"\x{01EC}\x{01ED}\x{0328}\x{02DB}", 
	'param_names' => ['Straight'],
	'characters' => [0x0104, 0x0105, 0x0118, 0x0119, 0x012E, 0x012F, 0x01EB, 0x01EA, 0x0172, 0x0173, 
		0x01EC, 0x01ED, 0x0328, 0x02DB], 
	};

# the small cap form for dcaron & tcaron already use the non-European caron,
#  so applying this feature to those smcp glyphs has no affect (lcaron is affected)
# interacts with small l-tail and small t-tail in Andika
# source cv done: noneur_caron_alt caron_sub cv77
my $noneur_caron_alt_cv = {
	'glyphs' => [{'base' => 'dcaron', 'alts' => ['dcaron.Caron']}, 
		{'base' => 'lcaron', 'alts' => ['lcaron.Caron']}, 
		{'base' => 'lcaron.TailL', 'alts' => ['lcaron.Caron.TailL']}, 
		{'base' => 'Lcaron', 'alts' => ['Lcaron.Caron']}, 
		{'base' => 'tcaron', 'alts' => ['tcaron.Caron']}, 
		{'base' => 'tcaron.NoTailT', 'alts' => ['tcaron.Caron.NoTailT']}, 
		{'base' => 'lcaron.sc', 'alts' => ['lcaron.Caron.sc']}],
	'feature_name' => 'Non-European caron alternates',
	'tooltip' => 'Non-Eur caron alts',
	'sample_str' => "\x{010F}\x{013E}\x{013D}\x{0165}", 
	'param_names' => ['Non-European style'],
	'characters' => [0x010F, 0x013E, 0x013D, 0x0165],  
	};

# Gentium
# 'glyphs' will be filled in below algorithmically
# characters determined from Features.xml file
# the USVs in the sample str and characters array are not parallel to the glyph data
#  but the spec does not require that so leave it for now
# source cv done: por_circum pcx_sub cv78
my $por_circum_cv = {
	'glyphs' => [{'base' => '', 'alts' => ['', ]}],
	'feature_name' => 'Porsonic circumflex',
	'tooltip' => 'Porsonic circumflex',
	'sample_str' => "\x{0342}\x{1F06}\x{1F07}\x{1F0E}\x{1F0F}\x{1F26}\x{1F27}".
		"\x{1F2E}\x{1F2F}\x{1F36}\x{1F37}\x{1F3E}\x{1F3F}\x{1F56}\x{1F57}\x{1F5F}".
		"\x{1F66}\x{1F67}\x{1F6E}\x{1F6F}\x{1F86}\x{1F87}\x{1F8E}\x{1F8F}".
		"\x{1F96}\x{1F97}\x{1F9E}\x{1F9F}\x{1FA6}\x{1FA7}\x{1FAE}\x{1FAF}\x{1FB6}\x{1FB7}".
		"\x{1FC0}\x{1FC1}\x{1FC6}\x{1FC7}\x{1FCF}\x{1FD6}\x{1FD7}\x{1FDF}\x{1FE6}\x{1FE7}\x{1FF6}\x{1FF7}", 
	'param_names' => ['Porsonic-style'],
	'characters' => [0x0342, 0x1F06, 0x1F07, 0x1F0E, 0x1F0F, 0x1F26, 0x1F27, 
		0x1F2E, 0x1F2F, 0x1F36, 0x1F37, 0x1F3E, 0x1F3F, 0x1F56, 0x1F57, 0x1F5F, 
		0x1F66, 0x1F67, 0x1F6E, 0x1F6F, 0x1F86, 0x1F87, 0x1F8E, 0x1F8F, 
		0x1F96, 0x1F97, 0x1F9E, 0x1F9F, 0x1FA6, 0x1FA7, 0x1FAE, 0x1FAF, 0x1FB6, 0x1FB7, 
		0x1FC0, 0x1FC1, 0x1FC6, 0x1FC7, 0x1FCF, 0x1FD6, 0x1FD7, 0x1FDF, 0x1FE6, 0x1FE7, 0x1FF6, 0x1FF7],  
	};

# source cv done: mongol_cyr_e mce_sub cv80
my $mongol_cyr_e_cv = {
	'glyphs' => [{'base' => 'uni042D', 'alts' => ['uni042D.MongolStyle']}, 
		{'base' => 'uni044D', 'alts' => ['uni044D.MongolStyle']}, 
		{'base' => 'uni044D.sc', 'alts' => ['uni044D.MongolStyle.sc']}],
	'feature_name' => 'Mongolian-style Cyrillic E',
	'tooltip' => 'Mongol-style Cyr E',
	'sample_str' => "\x{042D}\x{044D}", 
	'param_names' => ['Mongolian-style'],
	'characters' => [0x042D, 0x044D],  
	};

# the small cap feature overrides the Cyrillic Shha alt feature
#  so applying this feature to the smcp glyph has no affect
# source cv done: cyr_shha_alt shha_sub cv81
my $cyr_shha_alt_cv = {
	'glyphs' => [{'base' => 'uni04BB', 'alts' => ['uni04BB.UCStyle']}],
	'feature_name' => 'Cyrillic shha alternate',
	'tooltip' => 'Cyr shha alt',
	'sample_str' => "\x{04BB}", 
	'param_names' => ['Uppercase style'],
	'characters' => [0x04BB],  
	};

# pre-composed Cyr glyphs with breve are defined with the Cyr form
#  so there's nothing to substitute
# source cv done: breve_cyr brvc_sub cv82
my $breve_cyr_cv = {
	'glyphs' => [{'base' => 'uni0306', 'alts' => ['uni0306.CyShortMrkAlt']}],
	'feature_name' => 'Combining breve Cyrillic form',
	'tooltip' => 'Breve Cyr form',
	'sample_str' => "\x{0306}", 
	'param_names' => ['Cyrillic-style'],
	'characters' => [0x0306],  
	};

# source cv done: chnntc_tn chnntc_sub cv90
my $chnntc_tn_cv = {
	'glyphs' => [{'base' => 'uni02C8', 'alts' => ['uni02C8.ChinantecTn']}, 
		{'base' => 'uni02C9', 'alts' => ['uni02C9.ChinantecTn']}, 
		{'base' => 'uni02CA', 'alts' => ['uni02CA.ChinantecTn']}, 
		{'base' => 'uni02CB', 'alts' => ['uni02CB.ChinantecTn']}],
	'feature_name' => 'Chinantec tones',
	'tooltip' => 'Chinantec tones',
	'sample_str' => "\x{02C8}\x{02C9}\x{02CA}\x{02CB}", 
	'param_names' => ['Chinantec-style'],
	'characters' => [0x02C8, 0x02C9, 0x02CA, 0x02CB],  
	};

# should this be a char var? see how beta testers respond
#  other tone feature would be multi-valued, so that one would have to be a char var
# source cv done: tone_nums tn_sub cv91
my $tone_nums_cv = {
	'glyphs' => [{'base' => 'uni02E9', 'alts' => ['onesuperior']}, 
		{'base' => 'uni02E8', 'alts' => ['twosuperior']}, 
		{'base' => 'uni02E7', 'alts' => ['threesuperior']}, 
		{'base' => 'uni02E6', 'alts' => ['uni2074']}, 
		{'base' => 'uni02E5', 'alts' => ['uni2075']}, 
		{'base' => 'uniA716', 'alts' => ['onesuperior']}, 
		{'base' => 'uniA715', 'alts' => ['twosuperior']}, 
		{'base' => 'uniA714', 'alts' => ['threesuperior']}, 
		{'base' => 'uniA713', 'alts' => ['uni2074']}, 
		{'base' => 'uniA712', 'alts' => ['uni2075']}],
	'feature_name' => 'Tone numbers',
	'tooltip' => 'Tone numbers',
	'sample_str' => "\x{02E9}\x{02E8}\x{02E7}\x{02E6}\x{02E5}\x{A716}\x{A715}\x{A714}\x{A713}\x{A712}", 
	'param_names' => ['Numbers'],
	'characters' => [0x02E9, 0x02E8, 0x02E7, 0x02E6, 0x02E5, 0xA716, 0xA715, 0xA714, 0xA713, 0xA712],  
	};

# source cv done: empty_set_alt set_sub cv98
my $empty_set_alt_cv = {
	'glyphs' => [{'base' => 'emptyset', 'alts' => ['emptyset.SlashZero']}],
	'feature_name' => 'Empty set alternate',
	'tooltip' => 'Empty set alt',
	'sample_str' => "\x{2205}", 
	'param_names' => ['Zero'],
	'characters' => [0x2205],  
	};

# stylistic set feature data

# for Andika, the literacy feat should sub non-lit glyphs
# ss01
my $literacy_ss = {
	# 'glyphs' will be filled in algorithmically and with special handling for LtnSmGStrk
	'glyphs' => [], 
	'feature_name' => 'Literacy alternates',
	};

# ss04
# gstroke snglbowl form doesn't change if barred bowl applied (literacy has priority)
# gstroke small cap form doesn't change if barred bowl applied
my $barred_bowl_ss = {
	'glyphs' => [{'base' => 'uni0180', 'alt' => 'uni0180.BarBowl'}, 
		{'base' => 'dcroat', 'alt' => 'dcroat.BarBowl'}, 
		{'base' => 'uni01E5', 'alt' => 'uni01E5.BarBowl'}], 
	'feature_name' => 'Barred-bowl forms',
	};

# ss05
my $slant_italic_ss = {
	# 'glyphs' will be filled in below algorithmically
	'glyphs' => [], 
	'feature_name' => 'Slant italic specials',
	};

# ss06
my $show_inv_chars_ss = {
	# 'glyphs' will be filled in below algorithmically
	'glyphs' => [], 
	'feature_name' => 'Show invisible characters',
	};

# ss07
my $low_profile_diacs_ss = {
	# 'glyphs' will be filled in below algorithmically
	'glyphs' => [], 
	'feature_name' => 'Low profile diacritics',
	};

#bookmark: GPOS data
# tone letter system - Phase 2 (more than 3 segments long)
my @right_tone = qw(uni02E5 uni02E6 uni02E7 uni02E8 uni02E9);
my @right_staff = qw(uni02E5.rstaff uni02E6.rstaff uni02E7.rstaff uni02E8.rstaff uni02E9.rstaff);

my @right_tone1 = qw(uni02E9);
my @right_tone2 = qw(uni02E8);
my @right_tone3 = qw(uni02E7);
my @right_tone4 = qw(uni02E6);
my @right_tone5 = qw(uni02E5);

my @right_bar1 = qw(uni02E5.1 uni02E6.1 uni02E7.1 uni02E8.1 uni02E9.1);
my @right_bar2 = qw(uni02E5.2 uni02E6.2 uni02E7.2 uni02E8.2 uni02E9.2);
my @right_bar3 = qw(uni02E5.3 uni02E6.3 uni02E7.3 uni02E8.3 uni02E9.3);
my @right_bar4 = qw(uni02E5.4 uni02E6.4 uni02E7.4 uni02E8.4 uni02E9.4);
my @right_bar5 = qw(uni02E5.5 uni02E6.5 uni02E7.5 uni02E8.5 uni02E9.5);

my @right_levelbar = qw(uni02E9.1 uni02E8.2 uni02E7.3 uni02E6.4 uni02E5.5);

my @right_slantbar = qw(uni02E9.2 uni02E9.3 uni02E9.4 uni02E9.5
						uni02E8.1 uni02E8.3 uni02E8.4 uni02E8.5
						uni02E7.1 uni02E7.2 uni02E7.4 uni02E7.5
						uni02E6.1 uni02E6.2 uni02E6.3 uni02E6.5
						uni02E5.1 uni02E5.2 uni02E5.3 uni02E5.4);

my %right_tone_comp = (
	'uni02E5' => ['uni02E5.5', 'uni02E5.rstaff'],
	'uni02E6' => ['uni02E6.4', 'uni02E6.rstaff'],
	'uni02E7' => ['uni02E7.3', 'uni02E7.rstaff'],
	'uni02E8' => ['uni02E8.2', 'uni02E8.rstaff'],
	'uni02E9' => ['uni02E9.1', 'uni02E9.rstaff'],
	);


my @left_tone = qw(uniA712 uniA713 uniA714 uniA715 uniA716);
my @left_staff = qw(uniA712.lstaff uniA713.lstaff uniA714.lstaff uniA715.lstaff uniA716.lstaff);

my @left_tone1 = qw(uniA716.1 uniA716.2 uniA716.3 uniA716.4 uniA716.5 uniA716);
my @left_tone2 = qw(uniA715.1 uniA715.2 uniA715.3 uniA715.4 uniA715.5 uniA715);
my @left_tone3 = qw(uniA714.1 uniA714.2 uniA714.3 uniA714.4 uniA714.5 uniA714);
my @left_tone4 = qw(uniA713.1 uniA713.2 uniA713.3 uniA713.4 uniA713.5 uniA713);
my @left_tone5 = qw(uniA712.1 uniA712.2 uniA712.3 uniA712.4 uniA712.5 uniA712);


my @left_bar1 = qw(uniA712.1 uniA713.1 uniA714.1 uniA715.1 uniA716.1);
my @left_bar2 = qw(uniA712.2 uniA713.2 uniA714.2 uniA715.2 uniA716.2);
my @left_bar3 = qw(uniA712.3 uniA713.3 uniA714.3 uniA715.3 uniA716.3);
my @left_bar4 = qw(uniA712.4 uniA713.4 uniA714.4 uniA715.4 uniA716.4);
my @left_bar5 = qw(uniA712.5 uniA713.5 uniA714.5 uniA715.5 uniA716.5);

my @left_levelbar = qw(uniA716.1 uniA715.2 uniA714.3 uniA713.4 uniA712.5);

my @left_slantbar = qw(uniA715.1 uniA714.1 uniA713.1 uniA712.1
					   uniA716.2 uniA714.2 uniA713.2 uniA712.2
					   uniA716.3 uniA715.3 uniA713.3 uniA712.3
					   uniA716.4 uniA715.4 uniA714.4 uniA712.4
					   uniA716.5 uniA715.5 uniA714.5 uniA713.5);

my %left_tone_comp = (
	'uniA712' => ['uniA712.lstaff', 'uniA712.5'],
	'uniA713' => ['uniA713.lstaff', 'uniA713.4'],
	'uniA714' => ['uniA714.lstaff', 'uniA714.3'],
	'uniA715' => ['uniA715.lstaff', 'uniA715.2'],
	'uniA716' => ['uniA716.lstaff', 'uniA716.1'],
	);

# Names of glyphs that are expected to have no outlines
my %known_empty_glyphs;
map {$known_empty_glyphs{$_} = 1} qw (
	.null nonmarkingreturn space uni00A0 uni00AD
	uni02E5.rstaffno uni02E6.rstaffno uni02E7.rstaffno uni02E8.rstaffno uni02E9.rstaffno
	uni034F uni2000 uni2001 uni2002 uni2003 uni2004 uni2005 uni2006
	uni2007 uni2008 uni2009 uni200A uni200B uni200C uni200D uni200E
	uni200F uni2028 uni2029 uni202A uni202B uni202C uni202D uni202E
	uni202F uni2060 uni2061 uni2062 uni2063 uni206A uni206B uni206C
	uni206D uni206E uni206F
	uniA712.lstaffno uniA713.lstaffno uniA714.lstaffno uniA715.lstaffno uniA716.lstaffno
	uniFE00 uniFE01 uniFE02 uniFE03 uniFE04 uniFE05 uniFE06 uniFE07
	uniFE08 uniFE09 uniFE0A uniFE0B uniFE0C uniFE0D uniFE0E uniFE0F
	uniFEFF uniFFF9 uniFFFA uniFFFB uniFFFC
	compTnLtrSpcFlatLeft compTnLtrSpcFlatRight compTnLtrSpcPointLeft compTnLtrSpcPointRight
	compTnLtrSpcDotLeft compTnLtrSpcDotMiddle compTnLtrSpcDotRight
	compspace.attach
	);


my $f = Font::TTF::Font->open($ARGV[1]) || die "Can't open font $ARGV[1]";

my $t;
foreach $t (qw(post cmap loca name hmtx OS/2))
{ $f->{$t}->read; }

my $c = $f->{'cmap'}->find_ms->{'val'} || die "Can't find Unicode table in font $ARGV[1]";
if (lc (substr (scalar $f->{'name'}->find_name(1), 0, 7)) eq 'gentium') # name id 1 = Font Family name
	{ $gentium_f = 1; }

if (lc (substr (scalar $f->{'name'}->find_name(1), 0, 6)) eq 'andika') # name id 1 = Font Family name
	{ $andika_f = 1; }

#if (lc (substr (scalar $f->{'name'}->find_name(1), 0, 12)) eq 'andika basic') # name id 1 = Font Family name
if (lc (substr (scalar $f->{'name'}->find_name(1), 0, 13)) eq 'andika basics') # name id 1 = Font Family name
	{ $andika_basics_f = 1; }

#bookmark: process AP db
# XML parsing vars:
my ($xml, $cur_glyph, $cur_pt);
my ($psum, $pnum, $rsum, $rnum);

$xml = XML::Parser::Expat->new();
$xml->setHandlers('Start' => sub {
    my ($xml, $tag, %attrs) = @_;

    if ($tag eq 'glyph')
    {
        my ($ug, $pg, $ig, $glyph); # ?g - gids from cmap, post table, or AP db
        $cur_glyph = {%attrs};
        undef $cur_pt;

        if (defined $attrs{'UID'})
        {
            my ($uni) = hex($attrs{'UID'});
            $ug = $c->{$uni};
            error($xml, "No glyph associated with UID $attrs{'UID'}") unless (defined $ug);
            $cur_glyph->{'gnum'} = $ug; # gnum set from various sources using a priority scheme (below)
            $cur_glyph->{'uni'} = $uni;
        }
        if (defined $attrs{'PSName'})
        {
            $pg = $f->{'post'}{'STRINGS'}{$attrs{'PSName'}};
            error($xml, "No glyph associated with postscript name $attrs{'PSName'}") unless (defined $pg);
            error($xml, "Postscript name: $attrs{'PSName'} resolves to different glyph to Unicode ID: $attrs{'UID'}")
                    if (defined $attrs{'UID'} && $pg != $ug);
            $cur_glyph->{'gnum'} ||= $pg;
        }
        if (defined $attrs{'GID'})
        {
            $ig = $attrs{'GID'};
            error($xml, "Specified glyph id $attrs{'GID'} different to glyph of Unicode ID: $attrs{'UID'}")
                    if (defined $attrs{'UID'} && $ug != $ig);
            error($xml, "Specified glyph id $attrs{'GID'} different to glyph of postscript name $attrs{'PSName'}")
                    if (defined $attrs{'PSName'} && $pg != $ig);
            $cur_glyph->{'gnum'} ||= $ig;
        }

        unless ($glyph = $f->{'loca'}{'glyphs'}[$cur_glyph->{'gnum'}])
        {
            error ($xml, "No glyph outline in font") unless $known_empty_glyphs{$f->{'post'}{'VAL'}[$cur_glyph->{'gnum'}]};
        }
        else
        {
	        $cur_glyph->{'glyph'} = $glyph;
	        $cur_glyph->{'glyph'}->read_dat;
	        if ($cur_glyph->{'glyph'}{'numberOfContours'} > 0)
	        { $cur_glyph->{'props'}{'drawn'} = 1; }
	        $cur_glyph->{'glyph'}->get_points;
	    }
        $glyphs[$cur_glyph->{'gnum'}] = $cur_glyph;
        $cur_glyph->{'post'} = $f->{'post'}{'VAL'}[$cur_glyph->{'gnum'}];
 		# v0.09: Added 'unless' condition to following:
        $gnames{$cur_glyph->{'post'}} = $cur_glyph->{'gnum'} unless ($cur_glyph->{'post'} eq '.notdef' and $cur_glyph->{'gnum'} > 0) ;
        $gunis{$cur_glyph->{'uni'}} = $cur_glyph->{'gnum'} if (defined $cur_glyph->{'uni'});

    } elsif ($tag eq 'point')
    {
        $cur_pt = {'name' => $attrs{'type'}};
        $cur_glyph->{'points'}{$attrs{'type'}} = $cur_pt;
    } elsif ($tag eq 'contour')
    {
        my ($cont) = $attrs{'num'};
        my ($g) = $cur_glyph->{'glyph'} || return;

        error($xml, "Specified contour of $cont different from calculated contour of $cur_pt->{'cont'}")
                if (defined $cur_pt->{'cont'} && $cur_pt->{'cont'} != $attrs{'num'});

        if (($cont == 0 && $g->{'endPoints'}[0] != 0)
            || ($cont > 0 && $g->{'endPoints'}[$cont-1] + 1 != $g->{'endPoints'}[$cont]))
        { error($xml, "Contour $cont not a single point path"); }
        else
        { $cur_pt->{'cont'} = $cont; }

        $cur_pt->{'x'} = $g->{'x'}[$g->{'endPoints'}[$cont]];
        $cur_pt->{'y'} = $g->{'y'}[$g->{'endPoints'}[$cont]];
    } elsif ($tag eq 'location')
    {
        my ($x) = $attrs{'x'};
        my ($y) = $attrs{'y'};
        my ($g) = $cur_glyph->{'glyph'};
        my ($cont, $i);

        error($xml, "Specified location of ($x, $y) different from calculated location ($cur_pt->{'x'}, $cur_pt->{'y'})")
                if (defined $cur_pt->{'x'} && ($cur_pt->{'x'} != $x || $cur_pt->{'y'} != $y));
        if ($g)
        {
	        for ($i = 0; $i < $g->{'numPoints'}; $i++)
	        {
	            if ($g->{'x'}[$i] == $x && $g->{'y'}[$i] == $y)
	            {
	                for ($cont = 0; $cont <= $#{$g->{'endPoints'}}; $cont++)
	                { # find contour that contains point
	                    last if ($g->{'endPoints'}[$cont] > $i);
	                }
	            }
	        }
	        if ($g->{'x'}[$i] != $x || $g->{'y'}[$i] != $y)
	        { error($xml, "No glyph point at specified location ($x, $y)") if ($opt_w); }
	        if (($cont == 0 && $g->{'endPoints'}[0] != 0)
	            || $g->{'endPoints'}[$cont-1] + 1 != $g->{'endPoints'}[$cont])
	        { error($xml, "Calculated contour $cont not a single point path") if ($opt_w); }
	        else
	        { $cur_pt->{'cont'} = $cont; }
	    }
	    else
	    { error($xml, "No glyph point at specified location ($x, $y)") if ($opt_w); }

        $cur_pt->{'x'} = $x unless defined $cur_pt->{'x'};
        $cur_pt->{'y'} = $y unless defined $cur_pt->{'y'};
    } elsif ($tag eq 'property')
    {
        $cur_glyph->{'props'}{$attrs{'name'}} = $attrs{'value'};
    }
},
'End' => sub {
    my ($xml, $tag) = @_;
    my ($i, $p);

    if ($tag eq 'glyph')
    {
        if (defined $cur_glyph->{'points'}{'U'})
        {
            if (defined $cur_glyph->{'points'}{'L'} && !grep {m/^_/o} keys %{$cur_glyph->{'points'}})
            { #base glyph, set H and O APs to same point a L if not defined; add to list of base glyphs
                $cur_glyph->{'typen'} = 1;           # base glyph
                $cur_glyph->{'points'}{'H'} ||= $cur_glyph->{'points'}{'L'};
                $cur_glyph->{'points'}{'O'} ||= $cur_glyph->{'points'}{'L'};
                push @baseGIDs, $cur_glyph->{'gnum'};
            }
        }
    }
    elsif ($tag eq 'point')
    {
	if ($cur_pt->{'name'} eq 'R')
        {
            $rsum += $cur_pt->{'y'};
            $rnum++;
        }
    }
});

$xml->parsefile($ARGV[0]) || die "Failed to parse Attachment Point database $ARGV[0]";

#bookmark: OT data structs
# GSUB variables

my $simple_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $simple_action = [];
my $alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $alt_action = [];
my $viet_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $viet_action = [];
my $serb_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $serb_action = [];
my $dotless_context_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $dotless_context_class = Font::TTF::Coverage->new(0);	# (class definition)
my $dotless_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $dotless_action = [];
my $superscript_context_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $superscript_context_class = Font::TTF::Coverage->new(0);	# (class definition)
my $superscript_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $superscript_action = [];
my $rtone_context_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $rtone1_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $rtone2_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $rtone3_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $rtone4_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $rtone5_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $rlevelbar_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $rslantbar_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $ltone_context_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $ltone1_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $ltone2_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $ltone3_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $ltone4_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $ltone5_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $llevelbar_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $lslantbar_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $smallcaps_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $smallcaps_action = [];
my $c2sc_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $c2sc_action = [];
my $lowprof_context_cover = Font::TTF::Coverage->new(1);
my $lowprof_context_class = Font::TTF::Coverage->new(0);
my $lowprof_cover = Font::TTF::Coverage->new(1);
my $lowprof_action = [];

# OT cv structs
my $one_no_base_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $one_no_base_action = [];
my $one_no_base_parms = Font::TTF::Features::Cvar->new();
my $four_open_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $four_open_alts_action = [];
my $four_open_alts_parms = Font::TTF::Features::Cvar->new();
my $six_nine_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $six_nine_alts_action = [];
my $six_nine_alts_parms = Font::TTF::Features::Cvar->new();
my $seven_bar_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $seven_bar_action = [];
my $seven_bar_parms = Font::TTF::Features::Cvar->new();
my $zero_slash_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $zero_slash_action = [];
my $zero_slash_parms = Font::TTF::Features::Cvar->new();
my $cap_b_hk_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_b_hk_alt_action = [];
my $cap_b_hk_alt_parms = Font::TTF::Features::Cvar->new();
my $serif_b_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $serif_b_alts_action = [];
my $serif_b_alts_parms = Font::TTF::Features::Cvar->new();
my $cap_d_hook_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_d_hook_alt_action = [];
my $cap_d_hook_alt_parms = Font::TTF::Features::Cvar->new();
my $sm_ezh_curl_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $sm_ezh_curl_alt_action = [];
my $sm_ezh_curl_alt_parms = Font::TTF::Features::Cvar->new();
my $cap_ezh_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_ezh_alt_action = [];
my $cap_ezh_alt_parms = Font::TTF::Features::Cvar->new();
my $rams_horn_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $rams_horn_alts_action = [];
my $rams_horn_alts_parms = Font::TTF::Features::Cvar->new();
my $cap_h_strk_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_h_strk_alt_action = [];
my $cap_h_strk_alt_parms = Font::TTF::Features::Cvar->new();
my $small_i_tail_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $small_i_tail_alts_action = [];
my $small_i_tail_alts_parms = Font::TTF::Features::Cvar->new();
my $small_j_serif_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $small_j_serif_alts_action = [];
my $small_j_serif_alts_parms = Font::TTF::Features::Cvar->new();
my $cap_j_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_j_alt_action = [];
my $cap_j_alt_parms = Font::TTF::Features::Cvar->new();
my $j_strk_hook_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $j_strk_hook_alt_action = [];
my $j_strk_hook_alt_parms = Font::TTF::Features::Cvar->new();
my $small_l_tail_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $small_l_tail_alts_action = [];
my $small_l_tail_alts_parms = Font::TTF::Features::Cvar->new();
my $upper_eng_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $upper_eng_alts_action = [];
my $upper_eng_alts_parms = Font::TTF::Features::Cvar->new();
my $cap_n_lft_hk_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_n_lft_hk_alt_action = [];
my $cap_n_lft_hk_alt_parms = Font::TTF::Features::Cvar->new();
my $open_o_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $open_o_alt_action = [];
my $open_o_alt_parms = Font::TTF::Features::Cvar->new();
my $ou_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $ou_alt_action = [];
my $ou_alt_parms = Font::TTF::Features::Cvar->new();
my $sm_p_hk_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $sm_p_hk_alt_action = [];
my $sm_p_hk_alt_parms = Font::TTF::Features::Cvar->new();
my $small_q_tail_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $small_q_tail_alts_action = [];
my $small_q_tail_alts_parms = Font::TTF::Features::Cvar->new();
my $cap_q_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_q_alts_action = [];
my $cap_q_alts_parms = Font::TTF::Features::Cvar->new();
my $cap_r_tail_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_r_tail_alt_action = [];
my $cap_r_tail_alt_parms = Font::TTF::Features::Cvar->new();
my $small_t_tail_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $small_t_tail_alts_action = [];
my $small_t_tail_alts_parms = Font::TTF::Features::Cvar->new();
my $cap_t_hk_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_t_hk_alt_action = [];
my $cap_t_hk_alt_parms = Font::TTF::Features::Cvar->new();
my $v_hook_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $v_hook_alts_action = [];
my $v_hook_alts_parms = Font::TTF::Features::Cvar->new();
my $small_y_tail_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $small_y_tail_alts_action = [];
my $small_y_tail_alts_parms = Font::TTF::Features::Cvar->new();
my $cap_y_hook_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cap_y_hook_alt_action = [];
my $cap_y_hook_alt_parms = Font::TTF::Features::Cvar->new();
my $mod_apos_alts_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $mod_apos_alts_action = [];
my $mod_apos_alts_parms = Font::TTF::Features::Cvar->new();
my $mod_colon_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $mod_colon_alt_action = [];
my $mod_colon_alt_parms = Font::TTF::Features::Cvar->new();
my $ogonek_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $ogonek_alt_action = [];
my $ogonek_alt_parms = Font::TTF::Features::Cvar->new();
my $noneur_caron_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $noneur_caron_alt_action = [];
my $noneur_caron_alt_parms = Font::TTF::Features::Cvar->new();
my $por_circum_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $por_circum_action = [];
my $por_circum_parms = Font::TTF::Features::Cvar->new();
my $mongol_cyr_e_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $mongol_cyr_e_action = [];
my $mongol_cyr_e_parms = Font::TTF::Features::Cvar->new();
my $cyr_shha_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $cyr_shha_alt_action = [];
my $cyr_shha_alt_parms = Font::TTF::Features::Cvar->new();
my $breve_cyr_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $breve_cyr_action = [];
my $breve_cyr_parms = Font::TTF::Features::Cvar->new();
my $chnntc_tn_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $chnntc_tn_action = [];
my $chnntc_tn_parms = Font::TTF::Features::Cvar->new();
my $tone_nums_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $tone_nums_action = [];
my $tone_nums_parms = Font::TTF::Features::Cvar->new();
my $empty_set_alt_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $empty_set_alt_action = [];
my $empty_set_alt_parms = Font::TTF::Features::Cvar->new();
# insert OT cv structs
my $viet_diac_alts_parms = Font::TTF::Features::Cvar->new();

my $literacy_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $literacy_action = [];
my $literacy_parms = Font::TTF::Features::Sset->new();
my $barred_bowl_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $barred_bowl_action = [];
my $barred_bowl_parms = Font::TTF::Features::Sset->new();
my $slant_italic_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $slant_italic_action = [];
my $slant_italic_parms = Font::TTF::Features::Sset->new();
my $show_inv_chars_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $show_inv_chars_action = [];
my $show_inv_chars_parms = Font::TTF::Features::Sset->new();
my $low_profile_diacs_cover = Font::TTF::Coverage->new(1);	# (coverage table)
my $low_profile_diacs_action = [];
my $low_profile_diacs_parms = Font::TTF::Features::Sset->new();

# additional vars
my $precomp_dotless_lkup;
my $comp_lkup;
my $viet_lkup;
my $fi_lkup;

# GDEF variables
my $gd = Font::TTF::GDEF->new(PARENT => $f, 'read' => 1);
$f->{'GDEF'} = $gd;
$gd->dirty;
my $gdm = Font::TTF::Coverage->new(0);	# GDEF Mark class definition
my $gda = Font::TTF::Coverage->new(1);	# GDEF AttachmentList table
my $gdc = Font::TTF::Coverage->new(0);	# GDEF Class definition, per spec:
#		1 = Base, 2 = Ligature, 3 = Mark, 4 = component
$gd->{'Version'} = 1.0;
$gd->{'ATTACH'}{'COVERAGE'} = $gda;
$gd->{'GLYPH'} = $gdc;
$gd->{'MARKS'} = $gdm;

# GPOS variables
# (naming convention: $mkb* are mark-to-base vars, $mkm* are mark-to-mark vars; next char
#  in name is m=mark or b=base.)
my $mkbm_cover = Font::TTF::Coverage->new(1);
my $mkbb1_cover = Font::TTF::Coverage->new(1);
my $mkbb2_cover = Font::TTF::Coverage->new(1);
my $mkmmU_cover = Font::TTF::Coverage->new(1);
my $mkmbU_cover = Font::TTF::Coverage->new(1);
my $mkmmL_cover = Font::TTF::Coverage->new(1);
my $mkmbL_cover = Font::TTF::Coverage->new(1);
# additional vars
my @mkbm_marks = [];
my @mkmmU_marks = [];
my @mkmmL_marks = [];
my @mkbb1_rules = [];
my @mkbb2_rules = [];
my @mkmbU_rules = [];
my @mkmbL_rules = [];
# marks with R attachment
my $mkR_cover = Font::TTF::Coverage->new(1);
my @mkR_rules = [];
# tone letters phase 2
my $tone_cover = Font::TTF::Coverage->new(1);
my @tone_entryexit_rules = [];
# kerning
my $kern_pair_cover = Font::TTF::Coverage->new(1);
my @kern_pair_rules = [];
my $kern_class_cover = Font::TTF::Coverage->new(1);
my $kern_class_class1 = Font::TTF::Coverage->new(0);
my $kern_class_class2 = Font::TTF::Coverage->new(0);
my @kern_class_rules = [];

# Load coverage and class structs from constant arrays
my ($n);
foreach $n (@superscript)
	{if (glyphs_exist(($n))) {$superscript_context_cover->add($gnames{$n})}};

# tone context coverage
foreach $n (@right_tone)
	{$rtone_context_cover->add($gnames{$n})};
foreach $n (@right_tone1)
	{$rtone1_cover->add($gnames{$n})};
foreach $n (@right_tone2)
	{$rtone2_cover->add($gnames{$n})};
foreach $n (@right_tone3)
	{$rtone3_cover->add($gnames{$n})};
foreach $n (@right_tone4)
	{$rtone4_cover->add($gnames{$n})};
foreach $n (@right_tone5)
	{$rtone5_cover->add($gnames{$n})};
foreach $n (@right_levelbar)
	{$rlevelbar_cover->add($gnames{$n})};
foreach $n (@right_slantbar)
	{$rslantbar_cover->add($gnames{$n})};

foreach $n (@left_tone)
	{$ltone_context_cover->add($gnames{$n})};
foreach $n (@left_tone1)
	{$ltone1_cover->add($gnames{$n})};
foreach $n (@left_tone2)
	{$ltone2_cover->add($gnames{$n})};
foreach $n (@left_tone3)
	{$ltone3_cover->add($gnames{$n})};
foreach $n (@left_tone4)
	{$ltone4_cover->add($gnames{$n})};
foreach $n (@left_tone5)
	{$ltone5_cover->add($gnames{$n})};
foreach $n (@left_levelbar)
	{$llevelbar_cover->add($gnames{$n})};
foreach $n (@left_slantbar)
	{$lslantbar_cover->add($gnames{$n})};


# Have had to split the mark-to-base lookup as it is >65K in size. The idea is to divide the
# base glyphs into two groups and build two lookups. Division is based on GID, and median GID
# is computed:

my $midGID = (sort {$a <=> $b} @baseGIDs)[$#baseGIDs / 2];

#bookmark: process glyphs
# process glyphs in gnum order so that the coverage tables might come out sorted
#  to produce a more efficient table (with either no ranges or longer ranges)
# glyphs in substitution tables will be added in gnum order
#  since the coverage and substitution glyphs could be in parallel orders in the font
#  glyphs in the coverage table might also be in gnum order
my (@gnames_sorted_by_gnum) = sort {$gnames{$a} <=> $gnames{$b}} keys %gnames;
foreach $n (@gnames_sorted_by_gnum) # iterate based on PS names building GDEF, GPOS & GSUB data
#foreach $n (keys %gnames) # order of keys is random
{
    my $glyph = $glyphs[$gnames{$n}];
    my ($gnum) = $glyph->{'gnum'}; # gnum is a glyph id set based on priorities
    my ($i, $j, $ps, $p, %dat);

    if ($glyph->{'typen'} == 1)
    {
        $gdc->{'val'}{$glyph->{'gnum'}} = 1;
        unless (defined $glyph->{'points'}{'R'})
        { # add R AP for base glyphs
            $glyph->{'points'}{'R'}{'x'} = $f->{'hmtx'}{'advance'}[$gnum];
            $glyph->{'points'}{'R'}{'y'} = $rsum / $rnum;
        }
    }

    #bookmark: process position data
    $i = 2; $j = 2; $ps = [];
    foreach $p (qw(U L H O R TL))
    {
        if (defined $glyph->{'points'}{"_$p"})
        { # process glyphs that attach to other glyphs (GPOS)
            $glyph->{'typeb'} |= $i;
            $glyph->{'typen'} = $j;
            # fill in GDEF data
            $gdc->{'val'}{$gnum} = 3 unless ($p eq 'TL');
            $gdm->{'val'}{$gnum} = $j - 1 unless ($p eq 'TL');	# _U is class 1, _L is class 2, ...
            # only mark-type glyphs are added below, there is no similar code for base-type glyphs below
            $gda->add($gnum) unless (defined $gda->{'val'}{$gnum});
            %dat = ();
            if (defined $glyph->{'points'}{"_$p"}{'x'})
            {
                $dat{'x'} = $glyph->{'points'}{"_$p"}{'x'};
                $dat{'y'} = $glyph->{'points'}{"_$p"}{'y'};
            }
            if (defined $glyph->{'points'}{"_$p"}{'cont'})
            { $dat{'p'} = $glyph->{'glyph'}{'endPoints'}[$glyph->{'points'}{"_$p"}{'cont'}]; }
            # fill in GPOS data
            $mkbm_marks[$mkbm_cover->add($gnum)] = [$glyph->{'typen'}-2, Font::TTF::Anchor->new(%dat)] if ($p ne 'TL');
            if ($p eq 'U')
            { $mkmmU_marks[$mkmmU_cover->add($gnum)] = [0, Font::TTF::Anchor->new(%dat)]; }
            elsif ($p eq 'L')
            { $mkmmL_marks[$mkmmL_cover->add($gnum)] = [0, Font::TTF::Anchor->new(%dat)]; }
            elsif ($p eq 'R')
            {$mkR_rules[$mkR_cover->add($gnum)][0]{'ACTION'}[0] = { 'XAdvance' => $f->{'hmtx'}{'advance'}[$gnum] }; }
            elsif ($p eq 'TL')
            { $tone_entryexit_rules[$tone_cover->add($gnum)] [0]{'ACTION'}[0] = Font::TTF::Anchor->new(%dat); }
		}

        if (defined $glyph->{'points'}{$p})
        { # process glyphs other glyphs attach too (GPOS)
            $glyph->{'typeb'} |= ($i << 1);
            %dat = ();
            if (defined $glyph->{'points'}{$p}{'x'})
            {
                $dat{'x'} = $glyph->{'points'}{$p}{'x'};
                $dat{'y'} = $glyph->{'points'}{$p}{'y'};
            }
            if (defined $glyph->{'points'}{$p}{'cont'})
            { $dat{'p'} = $glyph->{'glyph'}{'endPoints'}[$glyph->{'points'}{$p}{'cont'}]; }
            # fill in GPOS data
            $mkbb1_rules[$mkbb1_cover->add($gnum)][0]{'ACTION'}[$j-2] = Font::TTF::Anchor->new(%dat)
                    if ($glyph->{'typen'} == 1 && $glyph->{'gnum'} < $midGID);
            $mkbb2_rules[$mkbb2_cover->add($gnum)][0]{'ACTION'}[$j-2] = Font::TTF::Anchor->new(%dat)
                    if ($glyph->{'typen'} == 1 && $glyph->{'gnum'} >= $midGID);
            $mkmbU_rules[$mkmbU_cover->add($gnum)][0]{'ACTION'}[0] = Font::TTF::Anchor->new(%dat)
                    if ($p eq 'U' && ($glyph->{'typeb'} & 2) != 0);
            $mkmbL_rules[$mkmbL_cover->add($gnum)][0]{'ACTION'}[0] = Font::TTF::Anchor->new(%dat)
                    if ($p eq 'L' && ($glyph->{'typeb'} & 8) != 0);
            $tone_entryexit_rules[$tone_cover->add($gnum)] [0]{'ACTION'}[1] = Font::TTF::Anchor->new(%dat)
            		if $p eq 'TL';
        }

        # no APs are added to the GDEF attach list because no glyphs use contour-based APs
        # todo: Possible bug: This code doesn't insure that the AP data is in parallel with the gid being processed
        #  Since only gids are added ($gda->add($gnum)) for mark-type glyphs,
        #  if a base-type glyph had an AP, it's AP data would be added without first adding the gid
        #  No bug occurs though because no AP data is ever added
        push (@{$ps}, $glyph->{'glyph'}{'endPoints'}[$glyph->{'points'}{$p}{'cont'}])
            if (defined $glyph->{'glyph'} && defined $glyph->{'points'}{$p}
                    && defined $glyph->{'points'}{$p}{'cont'});
        push (@{$ps}, $glyph->{'glyph'}{'endPoints'}[$glyph->{'points'}{"_$p"}{'cont'}])
            if (defined $glyph->{'glyph'} && defined $glyph->{'points'}{"_$p"}
                    && defined $glyph->{'points'}{"_$p"}{'cont'});

        $i <<= 2; $j++;
    }
    push (@{$gd->{'ATTACH'}{'POINTS'}}, $ps) if (scalar @{$ps} > 0);

	#bookmark: process substitution data
    # dotless context
    if ($glyph->{'typen'} > 2 && $glyph->{'typen'} != 7) # 7 - exclude TL
    { $dotless_context_class->{'val'}{$gnames{$n}} = 1; }
    elsif ($glyph->{'typen'} == 2)
    { $dotless_context_class->{'val'}{$gnames{$n}} = 2; }
    elsif (exists $special_dotted{$glyph->{'post'}} && glyphs_exist(@{$special_dotted{$n}}))
    {
		$dotless_context_cover->add($gnames{$n});
    	$dotless_context_class->{'val'}{$gnames{$n}} = 3;
    }

	# superscript context
    if ($glyph->{'typen'} > 2 && $glyph->{'typen'} != 7) # 7 - exclude TL
    { $superscript_context_class->{'val'}{$gnames{$n}} = 1; }
    elsif ($glyph->{'typen'} == 2)
    { $superscript_context_class->{'val'}{$gnames{$n}} = 2; }
    # see above for superscript_context_cover

	# c2sc
	#todo: are all cases covered by this algorithm?
#	if (defined $glyph->{'UID'})
#		my $casefold = casefold($glyph->{'UID'}); #casefold seems to only work with upper case USVs
#		if (defined $casefold)                    # and also with things like 'fi' -> 'f' 'i'
#		{
#			my $lc_uni = $casefold->{'mapping'};

	if (defined $glyph->{'uni'})
	{
		my $charinfo = charinfo($glyph->{'uni'});
		if (defined $charinfo && $charinfo->{'lower'} ne '')
		{
			my $lc_gid = $gunis{hex($charinfo->{'lower'})}; #assumes that the lc char has a glyph id
			my $lc_sc_name = $glyphs[$lc_gid]->{'post'} . '.sc';
			if (defined $gnames{$lc_sc_name})
			{
				my $lc_sc_gid = $gnames{$lc_sc_name};

				$c2sc_cover->add($glyph->{'gnum'});
				push (@{$c2sc_action}, [{'ACTION' => [$lc_sc_gid]}]);
			}
		}
	}

	#lowprofile substitution & context
	if (grep /^$n$/, @lowprof_diacs)
	{   #must handle .VN to .VNLP suffixes
		my ($lp_suffix) = lc(substr($n, -3)) ne '.vn' ? '.LP' : 'LP';
		if (defined $gnames{$n . $lp_suffix})
		{
			$lowprof_cover->add($gnames{$n});
			push (@{$lowprof_action}, [{'ACTION' => [$gnames{$n . $lp_suffix}]}]);
			$lowprof_context_class->{'val'}{$gnames{$n}} = 2;
		}
		else
			{ print "Glyph '$n' doesn't have corresponding .LP variant glyph\n" if ($gentium_f); }
	}

	#test usv - class 0: Latin, upper case, U AP, not deprecated (including variants)
	# similar to make_LP_context_class.pl but using PS names instead of GDL names
	# TODO BUG: do NOT use class 0 because all glyphs not in a class are considered to be in class 0
	#           not too serious though since the context's coverage table only matches the above glyphs
	# class 1: all diacs w/o LP variant
	# class 2: diacs w LP variant; should match $lowprof_cover, assigned above
	# coverage - only class 0
    if ($glyph->{'typen'} >= 2 && $glyph->{'typen'} != 7 && not grep /^$n$/, @lowprof_diacs) # 7 - exclude TL
    { $lowprof_context_class->{'val'}{$gnames{$n}} = 1; }

    # add gids for class 0 to $lowprof_context_cover & $lowprof_context_class;
	my $name = $n;
	my $add_glyph_f = 2;
	while ($add_glyph_f == 2)
	{ #continue searching for non-variant glyph while current glyph name is indeterminate
		if (defined $gnames{$name}) #test if truncated glyph name matches a real glyph
		{
			my $g = $glyphs[$gnames{$name}]; #this is redundant only on the first iteration
			$add_glyph_f = glyph_in_lowprof_context_cover($g);
		}
		if (rindex($name, '.') == -1)
			{ last; } #also end loop after last truncated name with no more variants is tested
		$name = substr($name, 0, rindex($name, '.')); #remove rightmost variant suffix
	}

	if ($add_glyph_f == 1)
    {
		$lowprof_context_cover->add($gnames{$n});
		$lowprof_context_class->{'val'}{$gnames{$n}} = 0;
    }

    # Processing glyphs which are variants:
    # create GSUB data to substitute a variant glyph for a base glyph
    #  assuming a base.var form for the post name
    #if ($n =~ m/^([^.]+)\.(.+)$/o)
    #  assuming a name followed by multiple dot separated suffixes
    #  TODO: this only expresses variants from single features applied to a base glyph
    #   (aacute -> aacute.sngstory, aacute.sngstory -> aacute.sngstory.viet)
    #  what about multiples features on a base glyph? (aacute -> aacute.sngstory.viet)
    #   the user has to "climb the tree" of variant glyphs (e.g. using a glyph palette of variant glyphs)
    #   to get to the desired one - effectively picking one feature, then the next, etc.

	#bookmark: process suffixes
	my @suffixes = $n =~ m/(\..*?)(?=\.|$)/og; # /g does repeated matching
	foreach my $suffix (@suffixes) {
        if ($suffix eq ".notdef" or $suffix eq ".null") {next;}
        # if ($suffix =~ m/Dep\d{2,3}/) {next;} #no Dep## suffixes exist anymore
        if ($suffix =~ m/\.(1|2|3|4|5|rstaff|rstaffno|lstaff|lstaffno)$/) {next}; #exclude tone glyphs
        my ($type) = substr($suffix, 1);
        my ($base) = $n;
        $base =~ s/\.$type//;
        # TODO: below specifies SngStory.SlantItalic variant has 2StorySlantItalic base
        #   but former glyphs don't exist
        #if ($type eq 'SngStory') #if SngStory feature is removed, then SlantItalic becomes 2StorySlantItalic
        #	{$base =~ s/SlantItalic/2StorySlantItalic/;}
        my ($bgid) = $gnames{$base};

	    # Process only VNStyle (now .VN) glyphs with underscores.
	    # Other VNStyle glyphs are done below.
	    # These are pre-composed diacritic combos with no base (which are unencoded)
	    # Assumes that only these type of .VN glyphs will have '_' in the PS name
	    #  and that there is only one suffix
        if (lc($type) eq 'vn' and $base =~ /_/)
        {
        	$viet_comb{$n} = [split('_', $base)];
        	next;
    	}

    	# All the rest need $bgid defined
    	# This finds variants that are missing from all possible feature combinations
    	#  That is, a group of features interact but a subgrouping is missing
    	#  The subgrouping may not really make sense, 
    	#   such as an upper case feature not being available for a lower case glyph
    	#  (though the upper case feature would apply to a small cap glyph)
        # unless (defined $bgid || $n =~ /.Sophia/) # Sophia glyphs should now have comp* PS names
        unless (defined $bgid)
        {
        	print "Glyph '$n' doesn't have corresponding nominal glyph '$base'\n";
        	next;
        }

        if (lc($type) eq 'dotless')
        {
            $dotless_context_cover->add($bgid);
            $dotless_cover->add($bgid);
            push (@{$dotless_action}, [{'ACTION' => [$gnames{$n}]}]);
        }

    	elsif (lc($type) eq 'vn')
    	{
			$viet_cover->add($bgid);
			push (@{$viet_action}, [{'ACTION' => [$gnames{$n}]}]);
    	}

    	elsif (lc($type) eq 'serb')
    	{
			$serb_cover->add($bgid);
			push (@{$serb_action}, [{'ACTION' => [$gnames{$n}]}]);
    		push @{$misc_alts{$bgid}}, $gnames{$n}; # also include Serbian glpyhs in aalt feat
    	}

    	elsif (lc($type) eq 'sup')
    	{
			$superscript_cover->add($bgid);
			push (@{$superscript_action}, [{'ACTION' => [$gnames{$n}]}]);
    	}

    	elsif (lc($type) eq 'sc')
    	{
			$smallcaps_cover->add($bgid);
			push (@{$smallcaps_action}, [{'ACTION' => [$gnames{$n}]}]);
    	}
    	
		# lookup structs being populated from here need to handle glyphs 
		#  substituted by prior lookups or provided by Andika encodings with the following suffixes:
		#  dotless, vn, sup, sc, lp (diacs), vnlp (diacs), sngstory, sngbowl
		#  liga feature (f,i,l) could have been applied
		#  aalt feature (single and multiple alternates) could have been applied - many & multiple suffixes
        #  char var features could have been applied - many & multiple suffixes
        #  SO handle all glyphs with suffixes of interest for a feature regardless of other suffixes
        
		# glyphs used in character variant & stylistic set features
		#  should also remain in the aalt feature
		
    	# glyphs with por suffix only have that suffix (Porsonic circumflex - Gentium only)
    	elsif (lc($type) eq 'por')
    	{                           
    		push (@{$por_circum_cv->{'glyphs'}}, {'base' => $base, 'alts' => [$n]});
    		push @{$misc_alts{$bgid}}, $gnames{$n};
    	}

    	# literacy (a,g) (Andika has literacy glyphs encoded)
    	#  interacts w barred bowl (b,d,g) cv thru 'g' (LtnSmGStrk, uni01E5), viet diacs thru 'a'
    	#  small caps has priority over literacy so do not replace .sc glyphs
    	#   though it doesn't really matter since any .sng(story|sngbowl).sc glyphs would look correct anyway
    	#   also sc is processed above
    	# for Andika, the literacy feat should sub non-lit glyphs
		# special handling for LtnSmGStrk is further below
    	#elsif (scalar @suffixes == 1 && (lc($type) eq 'sngstory' || lc($type) eq 'sngbowl'))
    	elsif ((lc($type) eq 'sngstory' || lc($type) eq 'sngbowl') && $n !~ /\.sc(\.|$)/)
    	{
    		if (!$andika_f || scalar @suffixes > 1)
    		{
	    		push (@{$literacy_ss->{'glyphs'}}, {'base' => $base, 'alt' => $n});
	    		push @{$misc_alts{$bgid}}, $gnames{$n};
	    	}
	    	else # for Andika, need to map literacy variants to non-lit form (<a>.SngStory -> <a>)
	    	{ # <a>.SngStory -> <a>.SngStory.sc handled ok with normal glyph processing if needed glyphs exist
	    		push (@{$literacy_ss->{'glyphs'}}, {'base' => $n, 'alt' => $base});
	    		push @{$misc_alts{$gnames{$n}}}, $bgid;
	    	}
    	}

    	# slant italic (a,f,i,l,v,z) - glyphs exist in italic and non-italic fonts
    	#  possibly interacts with literacy (& Andika encoded glyphs) thru 'a', viet diacs thru 'a', 
    	#   dotless (i), f ligs (f,i,l), i-tail (i-tail overrides), l-tail (l-tail overrides)
    	#  small caps and literacy has priority over slant italic so don't replace such glyphs
    	#   though it doesn't really matter since any glyphs with such suffixes would look correct anyway
    	elsif ((lc($type) eq 'sital' || lc($type) eq '2storysital') && $n !~ /\.sc(\.|$)/ && $n !~ /\.SngStory(\.|$)/)
    	{                           
    		push (@{$slant_italic_ss->{'glyphs'}}, {'base' => $base, 'alt' => $n});
     		push @{$misc_alts{$bgid}}, $gnames{$n};
   		}

    	# glyphs with showinv suffix only have that suffix
    	elsif (lc($type) eq 'showinv')
    	{                           
    		push (@{$show_inv_chars_ss->{'glyphs'}}, {'base' => $base, 'alt' => $n});
    		push @{$misc_alts{$bgid}}, $gnames{$n};
    	}

    	# glyphs with lp suffix (low profile)
    	#  interacts with many other features, some user specified
    	elsif (lc($type) eq 'lp')
    	{                           
    		push (@{$low_profile_diacs_ss->{'glyphs'}}, {'base' => $base, 'alt' => $n});
    		push @{$misc_alts{$bgid}}, $gnames{$n};
    	}

    	else
    	{
    		# Miscellaneous alternate -- just keep track of them for now:
    		push @{$misc_alts{$bgid}}, $gnames{$n};
    	}
    }
}

#bookmark: finish substitution processing
# Build substitution rules for miscellaneous alternates:
# special handling for LtnSmGStrk for Andika
if ($andika_f && !$andika_basics_f)
	{ push @{$misc_alts{$gnames{'uni01E5.BarBowl.SngBowl'}}}, $gnames{'uni01E5'}; };
my $bgid;
for $bgid (sort keys %misc_alts)
{
	if (@{$misc_alts{$bgid}} == 1)
	{
		# single alternate:
		$simple_cover->add($bgid);
		push @{$simple_action}, [{'ACTION' => [$misc_alts{$bgid}[0]]}];
	}
	else
	{
		# multiple alternates:
		$alt_cover->add($bgid);
		push @{$alt_action}, [{'ACTION' => [sort @{$misc_alts{$bgid}}]}];
	}
}

# Build decomposition rules for precomposed dotted glyphs
$precomp_dotless_lkup = {
    'FORMAT' => 1,
    'ACTION_TYPE' => 'g',
    'COVERAGE' => Font::TTF::Coverage->new(1),
    'RULES' => []
};
foreach my $k (sort keys %special_dotted)
{
	if (glyphs_exist(($k, @{$special_dotted{$k}})))
	{
		$precomp_dotless_lkup->{'COVERAGE'}->add($gnames{$k});
		push @{$precomp_dotless_lkup->{'RULES'}}, [{'ACTION', [map {$gnames{$_}} @{$special_dotted{$k}}]}];
	}
}

# Build ligature rules for all glyphs based on Unicode decompositions:
$comp_lkup = {
    'FORMAT' => 1,
    'MATCH_TYPE' => 'g',
    'ACTION_TYPE' => 'g',
    'COVERAGE' => Font::TTF::Coverage->new(1),
};
normal_rules(\@glyphs, $c, $comp_lkup);

# Build ligature rules for Vietnamese diacritic ligatures:
$viet_lkup = {
    'FORMAT' => 1,
    'MATCH_TYPE' => 'g',
    'ACTION_TYPE' => 'g',
    'COVERAGE' => Font::TTF::Coverage->new(1),
};
foreach $n (keys %viet_comb)
	{add_rule($viet_lkup, $gnames{$n}, $gnames{$viet_comb{$n}[0]}, $gnames{$viet_comb{$n}[1]});}

# Build ligature rules for fi ligatures:
$fi_lkup = {
    'FORMAT' => 1,
    'MATCH_TYPE' => 'g',
    'ACTION_TYPE' => 'g',
    'COVERAGE' => Font::TTF::Coverage->new(1)
};
# length first
foreach $n (qw(i l))
{
	if (glyphs_exist(("f_f_$n", "f", "$n")))
		{add_rule($fi_lkup, $gnames{"f_f_$n"}, $gnames{'f'}, $gnames{'f'}, $gnames{$n});}
}
foreach $n (@fi)
{
	if (glyphs_exist("f_$n", "f", "$n"))
		{add_rule($fi_lkup, $gnames{"f_$n"}, $gnames{'f'}, $gnames{$n});}
}

# process kerning data, if it exists
if (defined $opt_k)
{
	our ($kern_classes, $kern_glyph_pair_data, $kern_class_pair_data);
	do $opt_k; #creates above data structs
#	foreach (keys %{$kern_classes}) {print "$_\n";}
#	print "$kern_glyph_pair_data->[3][1]\n";
#	print "$kern_class_pair_data->[3][1]\n";

#	$kern_pair_cover->add(36);
#	$kern_pair_rules[0] = [{'MATCH' => [58], 'ACTION' => [{'XAdvance' => -1000}]}];

	my ($glyph_post_1, $glyph_post_2, $gnum_1, $gnum_2, $kern_val, $cover_ix);
	foreach my $kern_pair_data (@{$kern_glyph_pair_data})
	{
		  ($glyph_post_1, $glyph_post_2, $kern_val) = @{$kern_pair_data};
		  ($gnum_1, $gnum_2) = ($gnames{$glyph_post_1}, $gnames{$glyph_post_2});
		  $cover_ix = $kern_pair_cover->add($gnum_1);
		  if (not defined $kern_pair_rules[$cover_ix])
		  	{$kern_pair_rules[$cover_ix] = [{'MATCH' => [$gnum_2], 'ACTION' => [{'XAdvance' => $kern_val}]}];}
		  else
		  	{push @{$kern_pair_rules[$cover_ix]}, {'MATCH' => [$gnum_2], 'ACTION' => [{'XAdvance' => $kern_val}]}};
	}
	foreach my $rule (@kern_pair_rules)
		{$rule = [sort {$a->{'MATCH'}[0] <=> $b->{'MATCH'}[0]} @{$rule}];}

#	$kern_class_cover->add(38);
#	$kern_class_cover->add(39);
#	#only glyphs in the coverage table will be given class value, so class 0 is ok here
#	$kern_class_class1->add(38, 0);
#	$kern_class_class1->add(39, 0);
#	#avoid using class 0 in second slot because any glyph not in a class is given class 0
#	$kern_class_class2->add(40, 1);
#	$kern_class_class2->add(41, 1);
#	$kern_class_rules[0] = [{}, {'ACTION' => [{'XAdvance' => -1000}]}];

	my ($class_nm_1, $class_nm_2, $kern_val);
	my (%class1_class_id, $class1_ct, $class1_id, %class2_class_id, $class2_ct, $class2_id);
	($class1_ct, $class2_ct)  = (0, 1);
	foreach my $kern_class_data (@{$kern_class_pair_data})
	{
		($class_nm_1, $class_nm_2, $kern_val) = @{$kern_class_data};

		if (not defined $class1_class_id{$class_nm_1})
		{
			$class1_id = $class1_ct++;
			$class1_class_id{$class_nm_1} = $class1_id;
			foreach my $n (@{$kern_classes->{$class_nm_1}})
			{
				$kern_class_cover->add($gnames{$n});
				$kern_class_class1->add($gnames{$n}, $class1_id);
			}
		}
		else
			{$class1_id = $class1_class_id{$class_nm_1};}

		if (not defined $class2_class_id{$class_nm_2})
		{
			$class2_id = $class2_ct++;
			$class2_class_id{$class_nm_2} = $class2_id;
			foreach my $n (@{$kern_classes->{$class_nm_2}})
			{
				$kern_class_class2->add($gnames{$n}, $class2_id);
			}
		}
		else
			{$class2_id = $class2_class_id{$class_nm_2};}

        if (not defined $kern_class_rules[$class1_id])
        	{$kern_class_rules[$class1_id] = [{}];}
        $kern_class_rules[$class1_id][$class2_id] = {'ACTION' => [{'XAdvance' => $kern_val}]};
	}
}

#bookmark: combine cv/ss data & OT structs
# character variant and stylistic features
my $nid = $cv_ss_name_id_start;

# cv features
add_cv_feat($one_no_base_cv, \$nid, $one_no_base_cover, $one_no_base_action, $one_no_base_parms);
add_cv_feat($four_open_alts_cv, \$nid, $four_open_alts_cover, $four_open_alts_action, $four_open_alts_parms);
add_cv_feat($six_nine_alts_cv, \$nid, $six_nine_alts_cover, $six_nine_alts_action, $six_nine_alts_parms);
add_cv_feat($seven_bar_cv, \$nid, $seven_bar_cover, $seven_bar_action, $seven_bar_parms);
add_cv_feat($zero_slash_cv, \$nid, $zero_slash_cover, $zero_slash_action, $zero_slash_parms);
add_cv_feat($cap_b_hk_alt_cv, \$nid, $cap_b_hk_alt_cover, $cap_b_hk_alt_action, $cap_b_hk_alt_parms);
add_cv_feat($serif_b_alts_cv, \$nid, $serif_b_alts_cover, $serif_b_alts_action, $serif_b_alts_parms);
add_cv_feat($cap_d_hook_alt_cv, \$nid, $cap_d_hook_alt_cover, $cap_d_hook_alt_action, $cap_d_hook_alt_parms);
add_cv_feat($sm_ezh_curl_alt_cv, \$nid, $sm_ezh_curl_alt_cover, $sm_ezh_curl_alt_action, $sm_ezh_curl_alt_parms);
add_cv_feat($cap_ezh_alt_cv, \$nid, $cap_ezh_alt_cover, $cap_ezh_alt_action, $cap_ezh_alt_parms);
add_cv_feat($rams_horn_alts_cv, \$nid, $rams_horn_alts_cover, $rams_horn_alts_action, $rams_horn_alts_parms);
add_cv_feat($cap_h_strk_alt_cv, \$nid, $cap_h_strk_alt_cover, $cap_h_strk_alt_action, $cap_h_strk_alt_parms);
add_cv_feat($small_i_tail_alts_cv, \$nid, $small_i_tail_alts_cover, $small_i_tail_alts_action, $small_i_tail_alts_parms);
add_cv_feat($small_j_serif_alts_cv, \$nid, $small_j_serif_alts_cover, $small_j_serif_alts_action, $small_j_serif_alts_parms);
add_cv_feat($cap_j_alt_cv, \$nid, $cap_j_alt_cover, $cap_j_alt_action, $cap_j_alt_parms);
add_cv_feat($j_strk_hook_alt_cv, \$nid, $j_strk_hook_alt_cover, $j_strk_hook_alt_action, $j_strk_hook_alt_parms);
add_cv_feat($small_l_tail_alts_cv, \$nid, $small_l_tail_alts_cover, $small_l_tail_alts_action, $small_l_tail_alts_parms);
add_cv_feat($upper_eng_alts_cv, \$nid, $upper_eng_alts_cover, $upper_eng_alts_action, $upper_eng_alts_parms);
add_cv_feat($cap_n_lft_hk_alt_cv, \$nid, $cap_n_lft_hk_alt_cover, $cap_n_lft_hk_alt_action, $cap_n_lft_hk_alt_parms);
add_cv_feat($open_o_alt_cv, \$nid, $open_o_alt_cover, $open_o_alt_action, $open_o_alt_parms);
add_cv_feat($ou_alt_cv, \$nid, $ou_alt_cover, $ou_alt_action, $ou_alt_parms);
add_cv_feat($sm_p_hk_alt_cv, \$nid, $sm_p_hk_alt_cover, $sm_p_hk_alt_action, $sm_p_hk_alt_parms);
add_cv_feat($small_q_tail_alts_cv, \$nid, $small_q_tail_alts_cover, $small_q_tail_alts_action, $small_q_tail_alts_parms);
add_cv_feat($cap_q_alts_cv, \$nid, $cap_q_alts_cover, $cap_q_alts_action, $cap_q_alts_parms);
add_cv_feat($cap_r_tail_alt_cv, \$nid, $cap_r_tail_alt_cover, $cap_r_tail_alt_action, $cap_r_tail_alt_parms);
add_cv_feat($small_t_tail_alts_cv, \$nid, $small_t_tail_alts_cover, $small_t_tail_alts_action, $small_t_tail_alts_parms);
add_cv_feat($cap_t_hk_alt_cv, \$nid, $cap_t_hk_alt_cover, $cap_t_hk_alt_action, $cap_t_hk_alt_parms);
add_cv_feat($v_hook_alts_cv, \$nid, $v_hook_alts_cover, $v_hook_alts_action, $v_hook_alts_parms);
add_cv_feat($small_y_tail_alts_cv, \$nid, $small_y_tail_alts_cover, $small_y_tail_alts_action, $small_y_tail_alts_parms);
add_cv_feat($cap_y_hook_alt_cv, \$nid, $cap_y_hook_alt_cover, $cap_y_hook_alt_action, $cap_y_hook_alt_parms);
add_cv_feat($mod_apos_alts_cv, \$nid, $mod_apos_alts_cover, $mod_apos_alts_action, $mod_apos_alts_parms);
add_cv_feat($mod_colon_alt_cv, \$nid, $mod_colon_alt_cover, $mod_colon_alt_action, $mod_colon_alt_parms);
add_cv_feat($ogonek_alt_cv, \$nid, $ogonek_alt_cover, $ogonek_alt_action, $ogonek_alt_parms);
add_cv_feat($noneur_caron_alt_cv, \$nid, $noneur_caron_alt_cover, $noneur_caron_alt_action, $noneur_caron_alt_parms);
add_cv_feat($por_circum_cv, \$nid, $por_circum_cover, $por_circum_action, $por_circum_parms);
add_cv_feat($mongol_cyr_e_cv, \$nid, $mongol_cyr_e_cover, $mongol_cyr_e_action, $mongol_cyr_e_parms);
add_cv_feat($cyr_shha_alt_cv, \$nid, $cyr_shha_alt_cover, $cyr_shha_alt_action, $cyr_shha_alt_parms);
add_cv_feat($breve_cyr_cv, \$nid, $breve_cyr_cover, $breve_cyr_action, $breve_cyr_parms);
add_cv_feat($chnntc_tn_cv, \$nid, $chnntc_tn_cover, $chnntc_tn_action, $chnntc_tn_parms);
add_cv_feat($tone_nums_cv, \$nid, $tone_nums_cover, $tone_nums_action, $tone_nums_parms);
add_cv_feat($empty_set_alt_cv, \$nid, $empty_set_alt_cover, $empty_set_alt_action, $empty_set_alt_parms);
# insert add_cv_feat calls
add_cv_feat($viet_diac_alts_cv, \$nid, undef, undef, $viet_diac_alts_parms);
# ss features
if (not $andika_f) # special handling for LtnSmGStrk
	{ push @{$literacy_ss->{'glyphs'}}, {'base' => 'uni01E5', 'alt' => 'uni01E5.BarBowl.SngBowl'}; } 
else
	{ push @{$literacy_ss->{'glyphs'}}, {'base' => 'uni01E5.BarBowl.SngBowl', 'alt' => 'uni01E5'}; }
add_ss_feat($literacy_ss, \$nid, $literacy_cover, $literacy_action, $literacy_parms);
add_ss_feat($barred_bowl_ss, \$nid, $barred_bowl_cover, $barred_bowl_action, $barred_bowl_parms);
add_ss_feat($slant_italic_ss, \$nid, $slant_italic_cover, $slant_italic_action, $slant_italic_parms);
add_ss_feat($show_inv_chars_ss, \$nid, $show_inv_chars_cover, $show_inv_chars_action, $show_inv_chars_parms);
add_ss_feat($low_profile_diacs_ss, \$nid, $low_profile_diacs_cover, $low_profile_diacs_action, $low_profile_diacs_parms);

# OK, now we can build the gsub table:
# labels in below array must be parallel to lookups in @gsubs array
#  used by lk() to find index of a given lookup. so index numbers are not hard-coded
my @gsub_lkups = qw(di_ctx di_sub di_csub c_sub vd_sub vc_sub srb_sub ma_sub sa_sub ss_ctx ss_sub 
	sc1_sub sc2_sub f_sub 
	tn_ctx tnr1_sub tnr2_sub tnr3_sub tnr4_sub tnr5_sub 
	tnl1_sub tnl2_sub tnl3_sub tnl4_sub tnl5_sub 
	tne_ctx tnsr_dcmp tnsr_sub tnsl_dcmp tnsl_sub 
	lp_ctx lp_sub
	1_sub 4_sub 69_sub 7_sub zero_sub bhk_sub srfb_sub dhk_sub ezhcurl_sub ezh_sub 
	rams_sub hstrk_sub itl_sub jsrf_sub j_sub jstrk_sub ltl_sub engs_sub nhk_sub opno_sub ou_sub 
	phk_sub qtl_sub q_sub rtl_sub ttl_sub thk_sub vhk_sub ytl_sub yhk_sub 
	apos_sub colon_sub ognk_sub caron_sub 
	pcx_sub mce_sub shha_sub brvc_sub chnntc_sub tn_sub set_sub
	lit_sub bbwl_sub sital_sub inv_sub lpv_sub
	);

# for add_cvs_makeot.py to work
#  the "insert cv" comment below must be moved above the line containing inv_sub in the above array
#   (or before the first stylistic set lookup label)
#  it can't be left there because the qw() construct does not ignore comments
# insert cv lookup tags (format later by hand)

sub lk {my ($id) = (@_); my @ix = grep { $gsub_lkups[$_] eq $id } 0..$#gsub_lkups; return $ix[0]};

#bookmark: GSUB lookups	
my @gsubs;
@gsubs = ({
        'TYPE' => 5,                            # di_ctx: context for dotless i
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'c',
            'CLASS' => $dotless_context_class,
            'COVERAGE' => $dotless_context_cover,
            'RULES' => [ # glyphs that are in the context but with no class assigned
              [		# Sequences starting with something in class 0 (most base chars):
                {'MATCH' => [1, 2], 'ACTION' => [[0, lk('di_sub')]]},
                {'MATCH' => [1, 1, 2], 'ACTION' => [[0, lk('di_sub')]]},
                {'MATCH' => [1, 1, 1, 2], 'ACTION' => [[0, lk('di_sub')]]},
                {'MATCH' => [1, 1, 1, 1, 2], 'ACTION' => [[0, lk('di_sub')]]},
                {'MATCH' => [2], 'ACTION' => [[0, lk('di_sub')]]}
              ],
              [		# Sequences starting with something in class 1 (diacs other than upper):
              	{}
              ],
              [		# Sequences starting with something in class 2 (upper diacs):
              	{}
              ],
              [		# Sequences starting with something in class 3 (composites made from 'i' and lower diac):
                {'MATCH' => [1, 2], 'ACTION' => [[0, lk('di_csub')]]},
                {'MATCH' => [1, 1, 2], 'ACTION' => [[0, lk('di_csub')]]},
                {'MATCH' => [1, 1, 1, 2], 'ACTION' => [[0, lk('di_csub')]]},
                {'MATCH' => [1, 1, 1, 1, 2], 'ACTION' => [[0, lk('di_csub')]]},
                {'MATCH' => [2], 'ACTION' => [[0, lk('di_csub')]]},
              ]
             ]
	}]}, {

        'TYPE' => 1,                            # di_sub: replacement for dotless i
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $dotless_cover,
            'RULES' => $dotless_action
    }]}, {

        'TYPE' => 2,                            # di_csub: replacement for dotless i when precomposed w/ lower diac
        'FLAG' => 0,
        'SUB' => [{
			%{$precomp_dotless_lkup}
    }]}, {

        'TYPE' => 4,                            # c_sub: precomposed replacements
        'FLAG' => 0,
        'SUB' => [{
            %{$comp_lkup}
    }]}, {

        'TYPE' => 4,                            # vd_sub: Vietnamese overstrikes (ligate to .VNStyle - now .VN)
        'FLAG' => 0x100,
        'SUB' => [{
            %{$viet_lkup}
    }]}, {

        'TYPE' => 1,                            # vc_sub: Vietnamese precomposed
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $viet_cover,
            'RULES' => $viet_action,
   }]}, {

        'TYPE' => 1,                            # srb_sub: Serbian replacements
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $serb_cover,
            'RULES' => $serb_action,
   }]}, {

        'TYPE' => 3,                            # ma_sub: multi-way alternates (Eng, ramshorn)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $alt_cover,
            'RULES' => $alt_action
    }]}, {

        'TYPE' => 1,                            # sa_sub: single alternates (miscellaneous)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,                          # others
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $simple_cover,
            'RULES' => $simple_action,
    }]}, {

        'TYPE' => 5,                            # ss_ctx: context for superscript/modifier/subscript diacs
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'c',
            'CLASS' => $superscript_context_class,
            'COVERAGE' => $superscript_context_cover,
            'RULES' => [
              [		# Sequences starting with something in class 0 (restricted to superscript, etc.):
              	{'MATCH' => [1], 'ACTION' => [[1, lk('ss_sub')]]},
              	{'MATCH' => [2], 'ACTION' => [[1, lk('ss_sub')]]},
              ],		#pad the lookup with 2 empty rules to meet the OT spec for Pango
              [		# Sequences starting with something in class 1 (diacs other than upper):
              	{}
              ],
              [		# Sequences starting with something in class 2 (upper diacs):
              	{}
              ]
	     	]
    }]}, {

        'TYPE' => 1,                            # ss_sub: replacement for superscript/modifier/subscript diacs
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $superscript_cover,
            'RULES' => $superscript_action,
    }]}, {

       'TYPE' => 1,                            # sc1_sub: small caps substitution
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $smallcaps_cover,
            'RULES' => $smallcaps_action,
    }]}, {

       'TYPE' => 1,                            # sc2_sub: c2sc substitution
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $c2sc_cover,
            'RULES' => $c2sc_action,
    }]}, {

        'TYPE' => 4,                            # f_sub: ffi replacement (no context, yet)
        'FLAG' => 0,
        'SUB' => [{
            %{$fi_lkup}
    }]}, {

#bookmark: before tone
        'TYPE' => 6,                            # tn_ctx: context for right and left tonebars
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'MATCH' => [$rtone_context_cover], 'POST' => [$rtone1_cover], 'ACTION' => [[0, lk('tnr1_sub')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'MATCH' => [$rtone_context_cover], 'POST' => [$rtone2_cover], 'ACTION' => [[0, lk('tnr2_sub')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'MATCH' => [$rtone_context_cover], 'POST' => [$rtone3_cover], 'ACTION' => [[0, lk('tnr3_sub')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'MATCH' => [$rtone_context_cover], 'POST' => [$rtone4_cover], 'ACTION' => [[0, lk('tnr4_sub')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'MATCH' => [$rtone_context_cover], 'POST' => [$rtone5_cover], 'ACTION' => [[0, lk('tnr5_sub')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'PRE' => [$ltone1_cover], 'MATCH' => [$ltone_context_cover], 'ACTION' => [[0, lk('tnl1_sub')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'PRE' => [$ltone2_cover], 'MATCH' => [$ltone_context_cover], 'ACTION' => [[0, lk('tnl2_sub')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'PRE' => [$ltone3_cover], 'MATCH' => [$ltone_context_cover], 'ACTION' => [[0, lk('tnl3_sub')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'PRE' => [$ltone4_cover], 'MATCH' => [$ltone_context_cover], 'ACTION' => [[0, lk('tnl4_sub')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'PRE' => [$ltone5_cover], 'MATCH' => [$ltone_context_cover], 'ACTION' => [[0, lk('tnl5_sub')]]}]]
	}]}, {

        'TYPE' => 1,                            # tnr1_sub: right tone(1) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @right_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @right_bar1]
    }]}, {

        'TYPE' => 1,                            # tnr2_sub: right tone(2) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @right_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @right_bar2]
    }]}, {

        'TYPE' => 1,                            # tnr3_sub: right tone(3) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @right_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @right_bar3]
    }]}, {

        'TYPE' => 1,                            # tnr4_sub: right tone(4) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @right_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @right_bar4]
    }]}, {

        'TYPE' => 1,                            # tnr5_sub: right tone(5) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @right_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @right_bar5]
    }]}, {

        'TYPE' => 1,                            # tnl1_sub: left tone(1) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @left_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @left_bar1]
    }]}, {

        'TYPE' => 1,                            # tnl2_sub: left tone(2) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @left_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @left_bar2]
    }]}, {

        'TYPE' => 1,                            # tnl3_sub: left tone(3) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @left_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @left_bar3]
    }]}, {

        'TYPE' => 1,                            # tnl4_sub: left tone(4) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @left_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @left_bar4]
    }]}, {

        'TYPE' => 1,                            # tnl5_sub: left tone(5) replacement contours
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @left_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @left_bar5]
    }]}, {

        'TYPE' => 6,                            # tne_ctx: context to process the ends of right and left tone bars
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'PRE' => [$rlevelbar_cover], 'MATCH' => [$rtone_context_cover], 'ACTION' => [[0, lk('tnsr_dcmp')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'PRE' => [$rslantbar_cover], 'MATCH' => [$rtone_context_cover], 'ACTION' => [[0, lk('tnsr_sub')]]}]]}, {

            'FORMAT' => 3,			# added to process 2 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'PRE' => [$rslantbar_cover],
            	'MATCH' => [$rlevelbar_cover, $rtone_context_cover],
            	'ACTION' => [[1, lk('tnsr_sub')]]}
            ]]}, {

            'FORMAT' => 3,			# added to process 3 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'PRE' => [$rslantbar_cover],
            	'MATCH' => [$rlevelbar_cover, $rlevelbar_cover, $rtone_context_cover],
            	'ACTION' => [[2, lk('tnsr_sub')]]}
            ]]}, {

            'FORMAT' => 3,			# added to process 4 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'PRE' => [$rslantbar_cover],
            	'MATCH' => [$rlevelbar_cover, $rlevelbar_cover, $rlevelbar_cover, $rtone_context_cover],
            	'ACTION' => [[3, lk('tnsr_sub')]]}
            ]]}, {

            'FORMAT' => 3,			# added to process 5 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'PRE' => [$rslantbar_cover],
            	'MATCH' => [$rlevelbar_cover, $rlevelbar_cover, $rlevelbar_cover, $rlevelbar_cover, $rtone_context_cover],
            	'ACTION' => [[4, lk('tnsr_sub')]]}
            ]]}, {

            'FORMAT' => 3,			# added to process 6 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'PRE' => [$rslantbar_cover],
            	'MATCH' => [$rlevelbar_cover, $rlevelbar_cover, $rlevelbar_cover, $rlevelbar_cover, $rlevelbar_cover, $rtone_context_cover],
            	'ACTION' => [[5, lk('tnsr_sub')]]}
            ]]}, {

            'FORMAT' => 3,			# added to process 2 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'MATCH' => [$ltone_context_cover, $llevelbar_cover],
            	'POST' => [$lslantbar_cover],
            	'ACTION' => [[0, lk('tnsl_sub')]]}
            ]]}, {

            'FORMAT' => 3,			# added to process 3 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'MATCH' => [$ltone_context_cover, $llevelbar_cover, $llevelbar_cover],
            	'POST' => [$lslantbar_cover],
            	'ACTION' => [[0, lk('tnsl_sub')]]}
			]]}, {

            'FORMAT' => 3,			# added to process 4 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'MATCH' => [$ltone_context_cover, $llevelbar_cover, $llevelbar_cover, $llevelbar_cover],
            	'POST' => [$lslantbar_cover],
            	'ACTION' => [[0, lk('tnsl_sub')]]}
			]]}, {

            'FORMAT' => 3,			# added to process 5 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'MATCH' => [$ltone_context_cover, $llevelbar_cover, $llevelbar_cover, $llevelbar_cover, $llevelbar_cover],
            	'POST' => [$lslantbar_cover],
            	'ACTION' => [[0, lk('tnsl_sub')]]}
			]]}, {

            'FORMAT' => 3,			# added to process 6 identical tones between slanted segment and staff
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[
            	{'MATCH' => [$ltone_context_cover, $llevelbar_cover, $llevelbar_cover, $llevelbar_cover, $llevelbar_cover, $llevelbar_cover],
            	'POST' => [$lslantbar_cover],
            	'ACTION' => [[0, lk('tnsl_sub')]]}
            ]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'MATCH' => [$ltone_context_cover], 'POST' => [$llevelbar_cover], 'ACTION' => [[0, lk('tnsl_dcmp')]]}]]}, {

            'FORMAT' => 3,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'o',
            'RULES' => [[{'MATCH' => [$ltone_context_cover], 'POST' => [$lslantbar_cover], 'ACTION' => [[0, lk('tnsl_sub')]]}]] #}, {
	}]}, {

        'TYPE' => 2,                            # tnsr_dcmp: replacement for right level tone bars (decompose so attachment works)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} sort keys %right_tone_comp),
            'RULES' => [map {[{'ACTION' => [map {$gnames{$_}} @{$right_tone_comp{$_}}]}]} sort keys %right_tone_comp]
    }]}, {

        'TYPE' => 1,                            # tnsr_sub: right tone replacement staff
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @right_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @right_staff]

    }]}, {

        'TYPE' => 2,                            # tnsl_dcmp: replacement for left level tone bars (decompose so attachment works)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} sort keys %left_tone_comp),
            'RULES' => [map {[{'ACTION' => [map {$gnames{$_}} @{$left_tone_comp{$_}}]}]} sort keys %left_tone_comp]
    }]}, {

        'TYPE' => 1,                            # tnsl_sub: left tone replacement staff
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => Font::TTF::Coverage->new(1, map {$gnames{$_}} @left_tone),
            'RULES' => [map {[{'ACTION' => [$gnames{${_}}]}]} @left_staff]
    }]}, {

#bookmark: after tone
### lookups below this point may be deleted!!! ####
###  so lookups that refer to lookups after the first deletion will contain the wrong index ###

		# only for Gentium - deleted later for other fonts
		'TYPE' => 5,                            # lp_ctx: context for low profile diacritics
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'l',
            'MATCH_TYPE' => 'c',
            'CLASS' => $lowprof_context_class,  #upper, diacs w/o LP, diacs w LP
            'COVERAGE' => $lowprof_context_cover,
            'RULES' => [ # support 1 O or H + 1 R + 2 L + 2 U (one or both could have LP variant)
              [		# Sequences starting with something in class 0 (latin, upper case):
                {'MATCH' => [1, 1, 1, 1, 1, 2], 'ACTION' => [[6, lk('lp_sub')]]},
                {'MATCH' => [2, 1, 1, 1, 1, 2], 'ACTION' => [[1, lk('lp_sub')], [6, lk('lp_sub')]]},
                {'MATCH' => [1, 2, 1, 1, 1, 2], 'ACTION' => [[2, lk('lp_sub')], [6, lk('lp_sub')]]},
                {'MATCH' => [1, 1, 2, 1, 1, 2], 'ACTION' => [[3, lk('lp_sub')], [6, lk('lp_sub')]]},
                {'MATCH' => [1, 1, 1, 2, 1, 2], 'ACTION' => [[4, lk('lp_sub')], [6, lk('lp_sub')]]},
                {'MATCH' => [1, 1, 1, 1, 2, 2], 'ACTION' => [[5, lk('lp_sub')], [6, lk('lp_sub')]]},
                {'MATCH' => [1, 1, 1, 1, 2], 'ACTION' => [[5, lk('lp_sub')]]},
                {'MATCH' => [2, 1, 1, 1, 2], 'ACTION' => [[1, lk('lp_sub')], [5, lk('lp_sub')]]},
                {'MATCH' => [1, 2, 1, 1, 2], 'ACTION' => [[2, lk('lp_sub')], [5, lk('lp_sub')]]},
                {'MATCH' => [1, 1, 2, 1, 2], 'ACTION' => [[3, lk('lp_sub')], [5, lk('lp_sub')]]},
                {'MATCH' => [1, 1, 1, 2, 2], 'ACTION' => [[4, lk('lp_sub')], [5, lk('lp_sub')]]},
                {'MATCH' => [1, 1, 1, 2], 'ACTION' => [[4, lk('lp_sub')]]},
                {'MATCH' => [2, 1, 1, 2], 'ACTION' => [[1, lk('lp_sub')], [4, lk('lp_sub')]]},
                {'MATCH' => [1, 2, 1, 2], 'ACTION' => [[2, lk('lp_sub')], [4, lk('lp_sub')]]},
                {'MATCH' => [1, 1, 2, 2], 'ACTION' => [[3, lk('lp_sub')], [4, lk('lp_sub')]]},
                {'MATCH' => [1, 1, 2], 'ACTION' => [[3, lk('lp_sub')]]},
                {'MATCH' => [2, 1, 2], 'ACTION' => [[1, lk('lp_sub')], [3, lk('lp_sub')]]},
                {'MATCH' => [1, 2, 2], 'ACTION' => [[2, lk('lp_sub')], [3, lk('lp_sub')]]},
                {'MATCH' => [1, 2], 'ACTION' => [[2, lk('lp_sub')]]},
                {'MATCH' => [2, 2], 'ACTION' => [[1, lk('lp_sub')], [2, lk('lp_sub')]]},
                {'MATCH' => [2], 'ACTION' => [[1, lk('lp_sub')]]},
              ],
              [		# Sequences starting with something in class 1 (diacs w/o LP variants):
              	{}
              ],
              [		# Sequences starting with something in class 2 (diacs with LP variants):
              	{}
              ],
             ]
	}]}, {

		# only for Gentium - deleted later for other fonts
        'TYPE' => 1,                            # lp_sub: replacement for low profile diacritics
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $lowprof_cover,
            'RULES' => $lowprof_action
	}]}, {

#bookmark: char vars
        'TYPE' => 3,                            # 1_sub: digit one with base
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $one_no_base_cover,
            'RULES' => $one_no_base_action
    }]}, {

        'TYPE' => 3,                            # 4_sub: digit four with open top
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $four_open_alts_cover,
            'RULES' => $four_open_alts_action
    }]}, {

        'TYPE' => 3,                            # 69_sub: digit six and nine alternates
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $six_nine_alts_cover,
            'RULES' => $six_nine_alts_action
    }]}, {

        'TYPE' => 3,                            # 7_sub: digit seven with bar
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $seven_bar_cover,
            'RULES' => $seven_bar_action
    }]}, {

        'TYPE' => 3,                            # zero_sub: digit zero w slash
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $zero_slash_cover,
            'RULES' => $zero_slash_action
    }]}, {

        'TYPE' => 3,                            # bhk_sub: capital B-hook alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_b_hk_alt_cover,
            'RULES' => $cap_b_hk_alt_action
    }]}, {

        'TYPE' => 3,                            # srfb_sub: serif beta alts (Gentium)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $serif_b_alts_cover,
            'RULES' => $serif_b_alts_action
    }]}, {

        'TYPE' => 3,                            # dhk_sub: capital D-hook alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_d_hook_alt_cover,
            'RULES' => $cap_d_hook_alt_action
    }]}, {

        'TYPE' => 3,                            # ezhcurl_sub: small ezh-curl alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $sm_ezh_curl_alt_cover,
            'RULES' => $sm_ezh_curl_alt_action
    }]}, {

        'TYPE' => 3,                            # ezh_sub: capital Ezh alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_ezh_alt_cover,
            'RULES' => $cap_ezh_alt_action
    }]}, {

        'TYPE' => 3,                            # rams_sub: rams horn alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $rams_horn_alts_cover,
            'RULES' => $rams_horn_alts_action
    }]}, {

        'TYPE' => 3,                            # hstrk_sub: capital H-strok alt
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_h_strk_alt_cover,
            'RULES' => $cap_h_strk_alt_action
    }]}, {

        'TYPE' => 3,                            # itl_sub: small i-tail alts (Andika)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $small_i_tail_alts_cover,
            'RULES' => $small_i_tail_alts_action
    }]}, {

        'TYPE' => 3,                            # jsrf_sub: small j-serif alts (Andika)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $small_j_serif_alts_cover,
            'RULES' => $small_j_serif_alts_action
    }]}, {

        'TYPE' => 3,                            # j_sub: capital J alt (Andika Basics)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_j_alt_cover,
            'RULES' => $cap_j_alt_action
    }]}, {

        'TYPE' => 3,                            # jstrk_sub: J-stroke hook alt
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $j_strk_hook_alt_cover,
            'RULES' => $j_strk_hook_alt_action
    }]}, {

        'TYPE' => 3,                            # ltl_sub: small l-tail alts (Andika)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $small_l_tail_alts_cover,
            'RULES' => $small_l_tail_alts_action
    }]}, {

        'TYPE' => 3,                            # engs_sub: uppercase Eng alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $upper_eng_alts_cover,
            'RULES' => $upper_eng_alts_action
    }]}, {

        'TYPE' => 3,                            # nhk_sub: capital N-left-hook alt
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_n_lft_hk_alt_cover,
            'RULES' => $cap_n_lft_hk_alt_action
    }]}, {

        'TYPE' => 3,                            # opno_sub: open-o alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $open_o_alt_cover,
            'RULES' => $open_o_alt_action
    }]}, {

        'TYPE' => 3,                            # ou_sub: ou alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $ou_alt_cover,
            'RULES' => $ou_alt_action
    }]}, {

        'TYPE' => 3,                            # phk_sub: small p-hook alt
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $sm_p_hk_alt_cover,
            'RULES' => $sm_p_hk_alt_action
    }]}, {

        'TYPE' => 3,                            # qtl_sub: small q-tail alts (Andika)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $small_q_tail_alts_cover,
            'RULES' => $small_q_tail_alts_action
    }]}, {

        'TYPE' => 3,                            # q_sub: capital Q alts (Andika)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_q_alts_cover,
            'RULES' => $cap_q_alts_action
    }]}, {

        'TYPE' => 3,                            # rtl_sub: capital R-tail alt
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_r_tail_alt_cover,
            'RULES' => $cap_r_tail_alt_action
    }]}, {

        'TYPE' => 3,                            # ttl_sub: small t-tail alts (Andika)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $small_t_tail_alts_cover,
            'RULES' => $small_t_tail_alts_action
    }]}, {

        'TYPE' => 3,                            # thk_sub: capital T-hook alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_t_hk_alt_cover,
            'RULES' => $cap_t_hk_alt_action
    }]}, {

        'TYPE' => 3,                            # vhk_sub: V-hook alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $v_hook_alts_cover,
            'RULES' => $v_hook_alts_action
    }]}, {

        'TYPE' => 3,                            # ytl_sub: small y-tail alts (Andika)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $small_y_tail_alts_cover,
            'RULES' => $small_y_tail_alts_action
    }]}, {

        'TYPE' => 3,                            # yhk_sub: capital Y-hook alt
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cap_y_hook_alt_cover,
            'RULES' => $cap_y_hook_alt_action
    }]}, {

        'TYPE' => 3,                            # apos_sub: modifier apostrophe alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $mod_apos_alts_cover,
            'RULES' => $mod_apos_alts_action
    }]}, {

        'TYPE' => 3,                            # colon_sub: modifier colon alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $mod_colon_alt_cover,
            'RULES' => $mod_colon_alt_action
    }]}, {

        'TYPE' => 3,                            # ognk_sub: ogonek alt
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $ogonek_alt_cover,
            'RULES' => $ogonek_alt_action
    }]}, {

        'TYPE' => 3,                            # caron_sub: non-european caron alts
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $noneur_caron_alt_cover,
            'RULES' => $noneur_caron_alt_action
    }]}, {

        'TYPE' => 3,                            # pcx_sub: porsonic circumflex (Gentium)
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $por_circum_cover,
            'RULES' => $por_circum_action
    }]}, {

        'TYPE' => 3,                            # mce_sub: mongolian-style cyrillic E
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $mongol_cyr_e_cover,
            'RULES' => $mongol_cyr_e_action
    }]}, {

        'TYPE' => 3,                            # shha_sub: cyrillic shha alt
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $cyr_shha_alt_cover,
            'RULES' => $cyr_shha_alt_action
    }]}, {

        'TYPE' => 3,                            # brvc_sub: combining breve cyrillic form
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $breve_cyr_cover,
            'RULES' => $breve_cyr_action
    }]}, {

        'TYPE' => 3,                            # chnntc_sub: chinantec tones
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $chnntc_tn_cover,
            'RULES' => $chnntc_tn_action
    }]}, {

        'TYPE' => 3,                            # tn_sub: tone numbers
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $tone_nums_cover,
            'RULES' => $tone_nums_action
    }]}, {

        'TYPE' => 3,                            # set_sub: empty set alt
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 1,
            'ACTION_TYPE' => 'a',
            'COVERAGE' => $empty_set_alt_cover,
            'RULES' => $empty_set_alt_action
    }]}, {

# insert cv lookups
        'TYPE' => 1,                            # lit_sub: literacy replacements
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $literacy_cover,
            'RULES' => $literacy_action
    }]}, {

        'TYPE' => 1,                            # bbwl_sub: barred bowl replacements
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $barred_bowl_cover,
            'RULES' => $barred_bowl_action
    }]}, {

        'TYPE' => 1,                            # sital_sub: slant italic replacements
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $slant_italic_cover,
            'RULES' => $slant_italic_action
    }]}, {

        'TYPE' => 1,                            # inv_sub: show invisible replacements
        'FLAG' => 0,
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $show_inv_chars_cover,
            'RULES' => $show_inv_chars_action
    }]}, {

        'TYPE' => 1,                            # lpv_sub: low profile replacements
        'FLAG' => 0,                            #  for lower case and diacritic variants
        'SUB' => [{
            'FORMAT' => 2,
            'ACTION_TYPE' => 'g',
            'COVERAGE' => $low_profile_diacs_cover,
            'RULES' => $low_profile_diacs_action
     }]}	);

#bookmark: GSUB table
my $gsub = Font::TTF::GSUB->new(PARENT => $f, 'read' => 1);
$f->{'GSUB'} = $gsub;
$gsub->dirty;
$gsub->{'Version'} = 1.0;
$gsub->{'SCRIPTS'} = {
'DFLT' => { #DFLT script needed where no script is specified, eg InDesign with no language selected
	'DEFAULT' => {
    	'DEFAULT' => -1,			# no required feature
    	'FEATURES' => ['ccmp', 'aalt', 'smcp', 'c2sc', 'liga', 
			'cv01', 'cv04', 'cv06', 'cv07', 'cv10', 'cv13', 'cv14', 'cv17', 'cv19', 
			'cv20', 'cv25', 'cv28', 'cv31', 'cv34', 'cv35', 'cv37', 'cv39', 
			'cv43', 'cv44', 'cv46', 'cv47', 'cv49', 'cv51', 'cv52', 'cv55', 'cv56', 'cv57', 
			'cv62', 'cv67', 'cv68', 'cv70', 'cv71', 'cv75', 'cv76', 'cv77', 'cv78', 
			'cv80', 'cv81', 'cv82', 'cv90', 'cv91', 'cv98', 
# insert cv feature tags in features list
    		'ss01', 'ss04', 'ss05', 'ss06', 'ss07']}
},
'latn' => {
    'DEFAULT' => {' REFTAG' => 'IPPH'},
#    'LANG_TAGS' => ['dflt', 'IPPH', 'VIT '],
    'LANG_TAGS' => ['IPPH', 'VIT '],
#    'dflt' => {' REFTAG' => 'IPPH'},
    'IPPH' => {
        'DEFAULT' => -1,			# no required feature
        'FEATURES' => ['ccmp', 'aalt', 'smcp', 'c2sc', 'liga', 
			'cv01', 'cv04', 'cv06', 'cv07', 'cv10', 'cv13', 'cv14', 'cv17', 'cv19', 
			'cv20', 'cv25', 'cv28', 'cv31', 'cv34', 'cv35', 'cv37', 'cv39', 
			'cv43', 'cv44', 'cv46', 'cv47', 'cv49', 'cv51', 'cv52', 'cv55', 'cv56', 'cv57', 
			'cv62', 'cv67', 'cv68', 'cv70', 'cv71', 'cv75', 'cv76', 'cv77', 'cv78', 
			'cv80', 'cv81', 'cv82', 'cv90', 'cv91', 'cv98', 
# insert cv feature tags in features list
        	'ss01', 'ss04', 'ss05', 'ss06', 'ss07']},
    'VIT ' => {
        'DEFAULT' => -1,			# no required feature
        'FEATURES' => ['ccmp _1', 'aalt', 'smcp', 'c2sc', 'liga',  
			'cv01', 'cv04', 'cv06', 'cv07', 'cv10', 'cv13', 'cv14', 'cv17', 'cv19', 
			'cv20', 'cv25', 'cv28', 'cv31', 'cv34', 'cv35', 'cv37', 'cv39', 
			'cv43', 'cv44', 'cv46', 'cv47', 'cv49', 'cv51', 'cv52', 'cv55', 'cv56', 'cv57', 
			'cv62', 'cv67', 'cv68', 'cv70', 'cv71', 'cv75', 'cv76', 'cv77', 'cv78', 
			'cv80', 'cv81', 'cv82', 'cv90', 'cv91', 'cv98', 
# insert cv feature tags in features list
        	'ss01', 'ss04', 'ss05', 'ss06', 'ss07']}
},
'cyrl' => {
    'DEFAULT' => {
    	'DEFAULT' => -1,			# no required feature
    	'FEATURES' => ['ccmp', 'aalt', 'smcp', 'c2sc', 'liga', 
			'cv01', 'cv04', 'cv06', 'cv07', 'cv10', 'cv13', 'cv14', 'cv17', 'cv19', 
			'cv20', 'cv25', 'cv28', 'cv31', 'cv34', 'cv35', 'cv37', 'cv39', 
			'cv43', 'cv44', 'cv46', 'cv47', 'cv49', 'cv51', 'cv52', 'cv55', 'cv56', 'cv57', 
			'cv62', 'cv67', 'cv68', 'cv70', 'cv71', 'cv75', 'cv76', 'cv77', 'cv78', 
			'cv80', 'cv81', 'cv82', 'cv90', 'cv91', 'cv98', 
# insert cv feature tags in features list
    		'ss01', 'ss04', 'ss05', 'ss06', 'ss07']}, 
    'LANG_TAGS' => ['SRB '],
    'SRB ' => { # Serbian, add a locl feature
        'DEFAULT' => -1,			# no required feature
        'FEATURES' => ['ccmp', 'aalt', 'smcp', 'c2sc', 'liga', 'locl', 
			'cv01', 'cv04', 'cv06', 'cv07', 'cv10', 'cv13', 'cv14', 'cv17', 'cv19', 
			'cv20', 'cv25', 'cv28', 'cv31', 'cv34', 'cv35', 'cv37', 'cv39', 
			'cv43', 'cv44', 'cv46', 'cv47', 'cv49', 'cv51', 'cv52', 'cv55', 'cv56', 'cv57', 
			'cv62', 'cv67', 'cv68', 'cv70', 'cv71', 'cv75', 'cv76', 'cv77', 'cv78', 
			'cv80', 'cv81', 'cv82', 'cv90', 'cv91', 'cv98', 
# insert cv feature tags in features list
        	'ss01', 'ss04', 'ss05', 'ss06', 'ss07']}
},
'grek' => { # only for Gentium - deleted later for other fonts
    'DEFAULT' => {
    	'DEFAULT' => -1,			# no required feature
    	'FEATURES' => ['ccmp', 'aalt', 'smcp', 'c2sc', 'liga', 
			'cv01', 'cv04', 'cv06', 'cv07', 'cv10', 'cv13', 'cv14', 'cv17', 'cv19', 
			'cv20', 'cv25', 'cv28', 'cv31', 'cv34', 'cv35', 'cv37', 'cv39', 
			'cv43', 'cv44', 'cv46', 'cv47', 'cv49', 'cv51', 'cv52', 'cv55', 'cv56', 'cv57', 
			'cv62', 'cv67', 'cv68', 'cv70', 'cv71', 'cv75', 'cv76', 'cv77', 'cv78', 
			'cv80', 'cv81', 'cv82', 'cv90', 'cv91', 'cv98', 
# insert cv feature tags in features list
    		'ss01', 'ss04', 'ss05', 'ss06', 'ss07']}
},
};

$gsub->{'FEATURES'} = {
    'FEAT_TAGS' => ['aalt', 'c2sc', 'ccmp', 'ccmp _1', 
		'cv01', 'cv04', 'cv06', 'cv07', 'cv10', 'cv13', 'cv14', 'cv17', 'cv19', 
		'cv20', 'cv25', 'cv28', 'cv31', 'cv34', 'cv35', 'cv37', 'cv39', 
		'cv43', 'cv44', 'cv46', 'cv47', 'cv49', 'cv51', 'cv52', 'cv55', 'cv56', 'cv57', 
		'cv62', 'cv67', 'cv68', 'cv70', 'cv71', 'cv75', 'cv76', 'cv77', 'cv78', 
		'cv80', 'cv81', 'cv82', 'cv90', 'cv91', 'cv98', 
# insert cv feature tags in features list
    	'liga', 'locl', 'smcp', 'ss01', 'ss04', 'ss05', 'ss06', 'ss07'],
    'aalt' => {'LOOKUPS' => [lk('ma_sub'), lk('sa_sub')]},
    'c2sc' => {'LOOKUPS' => [lk('sc2_sub')]},
    'ccmp' => {'LOOKUPS' => [lk('di_ctx'), lk('c_sub'), lk('ss_ctx'), lk('tn_ctx'), lk('tne_ctx'), 
    	lk('lp_ctx')]}, # lp_ctx deleted for non-Gentium fonts
    'ccmp _1' => {'LOOKUPS' => [lk('di_ctx'), lk('c_sub'), lk('vd_sub'), lk('vc_sub'), lk('ss_ctx'), 
    	lk('tn_ctx'), lk('tne_ctx'), lk('lp_ctx')]}, # lp_ctx deleted for non-Gentium fonts
    'cv01' => {'PARMS' => $one_no_base_parms, 'LOOKUPS' => [lk('1_sub')]},
    'cv04' => {'PARMS' => $four_open_alts_parms, 'LOOKUPS' => [lk('4_sub')]},
    'cv06' => {'PARMS' => $six_nine_alts_parms, 'LOOKUPS' => [lk('69_sub')]},
    'cv07' => {'PARMS' => $seven_bar_parms, 'LOOKUPS' => [lk('7_sub')]},
    'cv10' => {'PARMS' => $zero_slash_parms, 'LOOKUPS' => [lk('zero_sub')]},
    'cv13' => {'PARMS' => $cap_b_hk_alt_parms, 'LOOKUPS' => [lk('bhk_sub')]},
    'cv14' => {'PARMS' => $serif_b_alts_parms, 'LOOKUPS' => [lk('srfb_sub')]},
    'cv17' => {'PARMS' => $cap_d_hook_alt_parms, 'LOOKUPS' => [lk('dhk_sub')]},
    'cv19' => {'PARMS' => $sm_ezh_curl_alt_parms, 'LOOKUPS' => [lk('ezhcurl_sub')]},
    'cv20' => {'PARMS' => $cap_ezh_alt_parms, 'LOOKUPS' => [lk('ezh_sub')]},
    'cv25' => {'PARMS' => $rams_horn_alts_parms, 'LOOKUPS' => [lk('rams_sub')]},
    'cv28' => {'PARMS' => $cap_h_strk_alt_parms, 'LOOKUPS' => [lk('hstrk_sub')]},
    'cv31' => {'PARMS' => $small_i_tail_alts_parms, 'LOOKUPS' => [lk('itl_sub')]},
    'cv34' => {'PARMS' => $small_j_serif_alts_parms, 'LOOKUPS' => [lk('jsrf_sub')]},
    'cv35' => {'PARMS' => $cap_j_alt_parms, 'LOOKUPS' => [lk('j_sub')]},
    'cv37' => {'PARMS' => $j_strk_hook_alt_parms, 'LOOKUPS' => [lk('jstrk_sub')]},
    'cv39' => {'PARMS' => $small_l_tail_alts_parms, 'LOOKUPS' => [lk('ltl_sub')]},
    'cv43' => {'PARMS' => $upper_eng_alts_parms, 'LOOKUPS' => [lk('engs_sub')]},
    'cv44' => {'PARMS' => $cap_n_lft_hk_alt_parms, 'LOOKUPS' => [lk('nhk_sub')]},
    'cv46' => {'PARMS' => $open_o_alt_parms, 'LOOKUPS' => [lk('opno_sub')]},
    'cv47' => {'PARMS' => $ou_alt_parms, 'LOOKUPS' => [lk('ou_sub')]},
    'cv49' => {'PARMS' => $sm_p_hk_alt_parms, 'LOOKUPS' => [lk('phk_sub')]},
    'cv51' => {'PARMS' => $small_q_tail_alts_parms, 'LOOKUPS' => [lk('qtl_sub')]},
    'cv52' => {'PARMS' => $cap_q_alts_parms, 'LOOKUPS' => [lk('q_sub')]},
    'cv55' => {'PARMS' => $cap_r_tail_alt_parms, 'LOOKUPS' => [lk('rtl_sub')]},
    'cv56' => {'PARMS' => $small_t_tail_alts_parms, 'LOOKUPS' => [lk('ttl_sub')]},
    'cv57' => {'PARMS' => $cap_t_hk_alt_parms, 'LOOKUPS' => [lk('thk_sub')]},
    'cv62' => {'PARMS' => $v_hook_alts_parms, 'LOOKUPS' => [lk('vhk_sub')]},
    'cv67' => {'PARMS' => $small_y_tail_alts_parms, 'LOOKUPS' => [lk('ytl_sub')]},
    'cv68' => {'PARMS' => $cap_y_hook_alt_parms, 'LOOKUPS' => [lk('yhk_sub')]},
    'cv70' => {'PARMS' => $mod_apos_alts_parms, 'LOOKUPS' => [lk('apos_sub')]},
    'cv71' => {'PARMS' => $mod_colon_alt_parms, 'LOOKUPS' => [lk('colon_sub')]},
    'cv75' => {'PARMS' => $viet_diac_alts_parms, 'LOOKUPS' => [lk('vd_sub'), lk('vc_sub')]},
    'cv76' => {'PARMS' => $ogonek_alt_parms, 'LOOKUPS' => [lk('ognk_sub')]},
    'cv77' => {'PARMS' => $noneur_caron_alt_parms, 'LOOKUPS' => [lk('caron_sub')]},
    'cv78' => {'PARMS' => $por_circum_parms, 'LOOKUPS' => [lk('pcx_sub')]},
    'cv80' => {'PARMS' => $mongol_cyr_e_parms, 'LOOKUPS' => [lk('mce_sub')]},
    'cv81' => {'PARMS' => $cyr_shha_alt_parms, 'LOOKUPS' => [lk('shha_sub')]},
    'cv82' => {'PARMS' => $breve_cyr_parms, 'LOOKUPS' => [lk('brvc_sub')]},
    'cv90' => {'PARMS' => $chnntc_tn_parms, 'LOOKUPS' => [lk('chnntc_sub')]},
    'cv91' => {'PARMS' => $tone_nums_parms, 'LOOKUPS' => [lk('tn_sub')]},
    'cv98' => {'PARMS' => $empty_set_alt_parms, 'LOOKUPS' => [lk('set_sub')]},
# insert cv features
    'liga' => {'LOOKUPS' => [lk('f_sub')]},
    'locl' => {'LOOKUPS' => [lk('srb_sub')]},
    'smcp' => {'LOOKUPS' => [lk('sc1_sub')]},
	'ss01' => {'PARMS' => $literacy_parms, 'LOOKUPS' => [lk('lit_sub')]},
	'ss04' => {'PARMS' => $barred_bowl_parms, 'LOOKUPS' => [lk('bbwl_sub')]},
	'ss05' => {'PARMS' => $slant_italic_parms, 'LOOKUPS' => [lk('sital_sub')]},
	'ss06' => {'PARMS' => $show_inv_chars_parms, 'LOOKUPS' => [lk('inv_sub')]},
	'ss07' => {'PARMS' => $low_profile_diacs_parms, 'LOOKUPS' => [lk('lpv_sub')]},
    };

$gsub->{'LOOKUP'} = \@gsubs;

#bookmark: delete font specific items from GSUB
if (not $gentium_f)
{
	delete $gsub->{'SCRIPTS'}{'grek'};
	gsub_lookup_del("lp_ctx");
	gsub_lookup_del("lp_sub");

	foreach my $feat (@gentium_cv_feat_lst)
		{gsub_feature_del($feat);}
	foreach my $lkup (@gentium_cv_lkup_lst)
		{gsub_lookup_del($lkup);}
}

if (not $andika_f)
{
	foreach my $feat (@andika_cv_feat_lst)
		{gsub_feature_del($feat);}
	foreach my $lkup (@andika_cv_lkup_lst)
		{gsub_lookup_del($lkup);}
}

if (not $andika_basics_f)
{
	gsub_feature_del('cv35');
	gsub_lookup_del('j_sub');
}

if ($andika_basics_f)
#if (0) #if uncommented, build font with all features where some have empty (but clean) coverage tbls
{
	#delete features which aren't supported
	my @feats_del;
	foreach my $feat (@{$gsub->{'FEATURES'}{'FEAT_TAGS'}})
	{
		my $found_f = 0;
		foreach my $a_feat (@andika_basics_feat_lst)
		{
			if ($feat eq $a_feat)
				{$found_f = 1; last}
		}
		if (not $found_f)
			{push @feats_del, $feat;}
	}
	foreach (@feats_del)
		{gsub_feature_del($_);}
	
	#remove lookups that aren't support from features that use them
	# other lookups in the features are supported
	my @lkup_ix_del = map {lk($_)} ('ss_ctx', 'tn_ctx', 'tne_ctx');

	my $lkup = $gsub->{'FEATURES'}{'ccmp'}{'LOOKUPS'};
	foreach my $ix (@lkup_ix_del)
		{splice (@{$lkup}, index(@{$lkup}, $ix), 1);}
		
	$lkup = $gsub->{'FEATURES'}{'ccmp _1'}{'LOOKUPS'};
	foreach my $ix (@lkup_ix_del)
		{splice (@{$lkup}, index(@{$lkup}, $ix), 1);}
		
	#delete Serbian language from Cyrillic script
	delete $gsub->{'SCRIPTS'}{'cyrl'}{'SRB '};
	delete $gsub->{'SCRIPTS'}{'cyrl'}{'LANG_TAGS'};
}

# the below was a simplisitic approach to handling Andika Basics
if (0)
{
	# delete lookups that do not have coverage tables
	#  (since next step won't detect them)
	foreach my $lkup (qw(tn_ctx tne_ctx))
		{gsub_lookup_del($lkup);}
	
	# find lookups that have emtpy coverage tables and delete them
	my $lkup_ix = -1;
	my @empty_lkup;
	foreach my $lkup (@gsubs)
	{
		++$lkup_ix;
		my $empty_sub_ct = 0;
		foreach my $sub (@{$lkup->{'SUB'}})
		{
			if ($sub->{'COVERAGE'}{'count'} == 0)
				{++$empty_sub_ct;}
		}
		if (scalar @{$lkup->{'SUB'}} == $empty_sub_ct)
			{push @empty_lkup, $lkup_ix;}
	}
	
	print "empty lookup list: ";
	foreach my $lkup_ix (@empty_lkup)
		{print "$lkup_ix, ";}
	print "\n";

	foreach my $lkup_ix (@empty_lkup)
		{gsub_lookup_del($gsub_lkups[$lkup_ix]);} #convert index to identifier
		
	# find features where all lookups have been deleted and delete them
	my @empty_feat;
	foreach my $feat (@{$gsub->{'FEATURES'}{'FEAT_TAGS'}})
	{
		if (scalar @{$gsub->{'FEATURES'}{$feat}{'LOOKUPS'}} == 0)
			{push @empty_feat, $feat;}
 	}

	print "empty feature list: ";
	foreach my $feat (@empty_feat)
		{print "$feat, ";}
	print "\n";

	foreach my $feat (@empty_feat)
		{gsub_feature_del($feat);}
}

#bookmark: GPOS table
my $gpos = Font::TTF::GPOS->new(PARENT => $f, 'read' => 1);
$f->{'GPOS'} = $gpos;
$gpos->dirty;
$gpos->{'Version'} = 1.0;
$gpos->{'SCRIPTS'} = {
'DFLT' => {
	'DEFAULT' => {
    	'DEFAULT' => -1,			# no required feature
    	'FEATURES' => ['kern', 'mark', 'mkmk']}
},
'latn' => {
    'DEFAULT' => {' REFTAG' => 'IPPH'},
#    'LANG_TAGS' => ['dflt', 'IPPH'],
    'LANG_TAGS' => ['IPPH', 'VIT '],
#    'dflt' => {' REFTAG' => 'IPPH'},
    'IPPH' => {
        'DEFAULT' => -1,			# no required feature
        'FEATURES' => ['kern', 'mark', 'mkmk']},
    'VIT ' => {
        'DEFAULT' => -1,			# no required feature
        'FEATURES' => ['kern', 'mark', 'mkmk']}
},
'cyrl' => {
	'DEFAULT' => {
		'DEFAULT' => -1,
		'FEATURES' => ['kern', 'mark', 'mkmk']}, 
    'LANG_TAGS' => ['SRB '],
    'SRB ' => { # Serbian, parallel to GSUB
        'DEFAULT' => -1,			# no required feature
		'FEATURES' => ['kern', 'mark', 'mkmk']}, 
},
};

# only for Gentium
my ($gpos_grek_script);
$gpos_grek_script = {
#'grek' => {
    'DEFAULT' => {
    'DEFAULT' => -1,			# no required feature
    'FEATURES' => ['kern', 'mark', 'mkmk']}
#},
};

$gpos->{'FEATURES'} = {
    'FEAT_TAGS' => ['kern', 'mark', 'mkmk'],
    'kern' => { 'LOOKUPS' => [4] }, 	# gpos(5) added below if -k specified
    'mark' => { 'LOOKUPS' => [0, 1] },
    'mkmk' => { 'LOOKUPS' => [2, 3] }};

$gpos->{'LOOKUP'} = [{
    'TYPE' => 1,                            # gpos(0): single adjustment for advancewidth
    'FLAG' => 2,
    'SUB' => [{
        'FORMAT' => 2,				# array of Value Records
        'COVERAGE' => $mkR_cover,
        'ACTION_TYPE' => 'v',
        'RULES' => \@mkR_rules}]},  {

    'TYPE' => 4,                            # gpos(1): mark
    'FLAG' => 4,
    'SUB' => [{
        'FORMAT' => 1,							# subtable 1
        'COVERAGE' => $mkbb1_cover,
        'MATCH' => [$mkbm_cover],
        'ACTION_TYPE' => 'a',
        'MARKS' => \@mkbm_marks,
        'RULES' => \@mkbb1_rules},  {

        'FORMAT' => 1,							# subtable 2
        'COVERAGE' => $mkbb2_cover,
        'MATCH' => [$mkbm_cover],
        'ACTION_TYPE' => 'a',
        'MARKS' => \@mkbm_marks,
        'RULES' => \@mkbb2_rules}]}, {

    'TYPE' => 6,                            # gpos(2): mkmk UDia
    'FLAG' => 0x100,
    'SUB' => [{
        'FORMAT' => 1,
        'COVERAGE' => $mkmbU_cover,
        'MATCH' => [$mkmmU_cover],
        'ACTION_TYPE' => 'a',
        'MARKS' => \@mkmmU_marks,
        'RULES' => \@mkmbU_rules}]}, {

    'TYPE' => 6,                            # gpos(3): mkmk LDia
    'FLAG' => 0x200,
    'SUB' => [{
        'FORMAT' => 1,
        'COVERAGE' => $mkmbL_cover,
        'MATCH' => [$mkmmL_cover],
        'ACTION_TYPE' => 'a',
        'MARKS' => \@mkmmL_marks,
        'RULES' => \@mkmbL_rules}]}, {

    'TYPE' => 3,                            # gpos(4): cursive attachment for tonebars
    'FLAG' => 0,
    'SUB' => [{
        'FORMAT' => 1,
        'COVERAGE' => $tone_cover,
        'ACTION_TYPE' => 'e',
        'RULES' => \@tone_entryexit_rules}]}
    ];

#this lookup should only be added to the font if -k specified
my ($kern_pair_lkups);
$kern_pair_lkups = {
    'TYPE' => 2,                            # gpos(5): pair adjustment for kerning
    'FLAG' => 8, # ignore combining marks (as specified in GDEF table)
    'SUB' => [{
        'FORMAT' => 1,
        'ACTION_TYPE' => 'p',
        'MATCH_TYPE' => 'g',
        'COVERAGE' => $kern_pair_cover,
        'RULES' => \@kern_pair_rules}, {

        'FORMAT' => 2,
        'ACTION_TYPE' => 'p',
        'MATCH_TYPE' => 'g',
        'COVERAGE' => $kern_class_cover,
        'CLASS' => $kern_class_class1,
        'MATCH' => [$kern_class_class2],
        'RULES' => \@kern_class_rules}
		]};

#bookmark: modify GPOS table for specific fonts or kerning data
if ($gentium_f)
{
	$gpos->{'SCRIPTS'}{'grek'} = $gpos_grek_script;
}

if ($andika_basics_f)
#if (0)
{
	#delete Serbian language from Cyrillic script
	delete $gpos->{'SCRIPTS'}{'cyrl'}{'SRB '};
	delete $gpos->{'SCRIPTS'}{'cyrl'}{'LANG_TAGS'};
    
	#delete items in GPOS related to tone
	splice(@{$gpos->{'LOOKUP'}}, 4, 1); # lookup 4 - cursive attachment for tonebars
	delete $gpos->{'FEATURES'}{'kern'}; # kern feat only contains lookup 4
	splice(@{$gpos->{'FEATURES'}{'FEAT_TAGS'}}, 0, 1); # 0 - 'kern'
	splice(@{$gpos->{'SCRIPTS'}{'DFLT'}{'DEFAULT'}{'FEATURES'}}, 0, 1); # 0 - kern
	splice(@{$gpos->{'SCRIPTS'}{'latn'}{'IPPH'}{'FEATURES'}}, 0, 1); # 0 - kern
	splice(@{$gpos->{'SCRIPTS'}{'latn'}{'VIT '}{'FEATURES'}}, 0, 1); # 0 - kern
	splice(@{$gpos->{'SCRIPTS'}{'cyrl'}{'DEFAULT'}{'FEATURES'}}, 0, 1); # 0 - kern
}

if ($opt_k)
{
	push (@{$gpos->{'FEATURES'}{'kern'}{'LOOKUPS'}}, 5);
	push (@{$gpos->{'LOOKUP'}}, $kern_pair_lkups);
}

# OS/2 will already be dirty because we dirtied the GPOS and GSUB
#$f->{'OS/2'}->dirty; #maxLookups needs to be recalculated after GSUB and GPOS are built
foreach (qw ( GDEF GPOS GSUB OS/2 ) )
	{ $f->{$_}->update; }

$f->out($ARGV[2]);

#bookmark: subroutines
sub error
{
    my ($xml, $str) = @_;

    if (defined $cur_glyph->{'uni'})
    { printf "U+%04X: ", $cur_glyph->{'uni'}; }
    elsif (defined $cur_glyph->{'PSName'})
    { print "$cur_glyph->{'PSName'}: "; }
    elsif (defined $cur_glyph->{'GID'})
    { print "$cur_glyph->{'GID'}: "; }
    else
    { print "Undefined: "; }

    print $str;

    if (defined $cur_pt)
    { print " in point $cur_pt->{'name'}"; }

    print " at line " . $xml->current_line . ".\n";
}

# subroutine that determines if a glyph should be added to the class
# can return: 0 - exclude; 1 - include; 2 - indeterminate
sub glyph_in_lowprof_context_cover(\$)
{
	my ($g) = @_;

#	Not needed now that there are no Dep## forms of variant glyphs
#	Also, deprecated glyph ps names now end in Dep without a dot and with no digits
#	The below test should have been against /.Dep\d{1,2}$/ anyway
#	if ($g->{'name'} =~ m/_dep\d{1,2}$/) # BUG: code borrowed from make_LP_context_class.pl
#		{ return 0; } # exclude deprecated glyphs (with ending like _dep51)


	# test USV
	my ($charinfo_ok) = (0);
	if (defined $g->{'uni'})
	{
		my $u = $g->{'uni'};
		my $charinfo = charinfo($u);
		if ($charinfo->{'category'} eq 'Co') #PUA codepoint
			{ return 2; }
		if ($charinfo->{'category'} eq 'Lu' && $charinfo->{'script'} eq 'Latin')
			{ $charinfo_ok = 1;}
	}
	else
		{ return 2; } #glyph is unencoded

	# test APs
	my ($ap_ok) = (0);
	foreach my $ap_nm (keys %{$g->{'points'}})
	{
		if ($ap_nm eq 'U')
			{ $ap_ok = 1; last; }
	}

	return $charinfo_ok && $ap_ok;
}

# Sub to find all possible decompositions of each of a set of glyphs, and
# add a ligature rule for each such decomposition to a given lookup.
sub normal_rules
{
    my ($glyphs, $c, $lkup) = @_;
    my ($g, $struni, $seq, $dseq, $dcomb, @decomp, $ar, $r, @temp, $d);

    foreach $g (@{$glyphs})
    {
 		# In the following line, the {'drawn'} term prevents ligature rules being built for
 		# precomposed unicode characters whose *glyph* was actually a TrueType composite
 		# (as opposed to a TrueType contour). I assume one might want to re-enable this
 		# line if your project makes a assumptions such as that contour-based glyphs are
 		# more likely to be hand-tuned than TT composites and thus are to be preferred.
 		# Current (2003-05-01) decision in Encore project is that pre-composed Unicode
 		# characters are *always* preferred, whether implemented as TT composites or
 		# as contours as they avoid the performance hit of GPOS positioning of the pieces.
 		# MH suggested (2003-07-14) that the performance gain isn't enough to compensate for
 		# the much larger font produced. Until we have test data, I'm re-enabling this:

        next unless ($g->{'props'}{'drawn'} or exists $required_comp{$g->{'post'}});
        next if (exists $required_decomp{$g->{'post'}});

        # Don't make ligatures unless this is the nominal glyph for this Unicode value:
        next unless (exists $g->{'uni'} and $c->{$g->{'uni'}} == $g->{'gnum'});

        # Special exception: Don't build rules to compose sequences to U+1E2D or U+1ECB as these
        # would then have to be decomposed again to remove the dot from the i.
        next if exists $special_dotted{$g->{'post'}};

if (1)
{
	# This is my version of the algorithm. RMH 2003-05-06

#        my $list = permuteCompositeChar(pack('U', $g->{'uni'}), 1);
        my $list = all_strings(pack('U', $g->{'uni'}), 1);
        foreach $struni (@{$list})
        {
        	# unpack this canonically-equivalent sequence to an array
        	@decomp = unpack('U*', $struni);
        	# Don't need to make ligatures if there are no decompositions:
        	next if $#decomp == 0 and $decomp[0] == $g->{'uni'};
        	printf ('Unexpected singleton decomposition of U+%04X to U+%04X\n', $c->{$g->{'uni'}}, $decomp[0]) if $#decomp == 0 and $opt_w;

	        # Verify the font has all the components.
	        my ($dok) = 1;
	        foreach $d (@decomp)
	        { $dok = 0 unless $c->{$d}; }
	        next unless $dok;

	        # Finally, build  ligature rule for the fully decomposed sequence
	        add_rule($lkup, $g->{'gnum'}, map {$gunis{$_}} @decomp);
	    }

} else {

    # Martin's original code
        $struni = pack('U', $g->{'uni'});

        # Create NFD for this char and build array @decomp holding the decomposed sequence
        $seq = NFD($struni);
        # Don't need to make ligatures if there are no decompositions:
        next if ($seq eq $struni);
        @decomp = unpack('U*', $seq);
        # Verify the font has all the components.
        my ($dok) = 1;
        foreach $d (@decomp)
        { $dok = 0 unless $c->{$d}; }
        next unless $dok;

        # Finally, build  ligature rule for the fully decomposed sequence
        add_rule($lkup, $g->{'gnum'}, map {$gunis{$_}} @decomp);

        # Build ligature rules for cannonically equivalent sequences.
        if (scalar @decomp > 2)
        {
            # The following appears to ASSUME that if a single character decomposes
            # to a sequence of more than three, that the sequence will be exactly 3
            # in length AND the last two of the sequence may be interchanged.
            # Neither assumption is valid (e.g., U+01D5)

            #print sprintf('%04X', $g->{'uni'}) . " = " . join('+', map {sprintf ('%04X', $_)} @decomp) . "\n";
            add_rule($lkup, $g->{'gnum'}, map {$gunis{$_}} @decomp[0, 2, 1]);

            $dseq = pack('U*', @decomp[0, 1]);
            $dcomb = NFC($dseq);
            if ($dcomb ne $dseq)
            { add_rule($lkup, $g->{'gnum'}, $gunis{unpack('U', $dcomb)}, $gunis{$decomp[2]}); }

            $dseq = pack('U*', @decomp[0, 2]);
            $dcomb = NFC($dseq);
            if ($dcomb ne $dseq)
            { add_rule($lkup, $g->{'gnum'}, $gunis{unpack('U', $dcomb)}, $gunis{$decomp[1]}); }
        }
    }
}

# sort rules into match length first
    foreach $r (@{$lkup->{'RULES'}})
    {
        # no strict "refs";
        $ar = [sort {scalar @{$b->{'MATCH'}} <=> scalar @{$a->{'MATCH'}}} @{$r}];
        push (@temp, $ar);
    }
    $lkup->{'RULES'} = \@temp;

# dump rules:
	if ($opt_d)
	{
		my ($init, $lig, $r, $index, @rlist);
		print "Dump of normal_rules result:\n";
		foreach $init (keys %{$lkup->{'COVERAGE'}{'val'}})
		{
			$index = $lkup->{'COVERAGE'}{'val'}{$init};
			foreach $lig (@{$lkup->{'RULES'}[$index]})
			{
				if (0)
				{
					# Print Unicode values:
					$r = sprintf '%04X < %04X', $glyphs[$lig->{'ACTION'}[0]]->{'uni'}, $glyphs[$init]->{'uni'};
					map {$r .= sprintf(' %04X', $glyphs[$_]->{'uni'})} @{$lig->{'MATCH'}};
				} else {
					# Print PSNames
					$r = "$glyphs[$lig->{'ACTION'}[0]]->{'post'} < $glyphs[$init]->{'post'}";
					map {$r .= " $glyphs[$_]->{'post'}"} @{$lig->{'MATCH'}};
				}
				$r .= "\n";
				push @rlist, $r;
			}
		}
		print sort @rlist;
	}
}

sub glyphs_exist
{
	my (@glyphs) = @_;
	foreach my $g (@glyphs)
    {
    	if (not exists $gnames{$g})
    		{return 0;}
    }
    return 1;
}

sub add_rule
{
    my ($lkup, $lig, $init, @seq) = @_;
    my ($index);

    if (defined $lkup->{'COVERAGE'}{'val'}{$init})
    	{ $index = $lkup->{'COVERAGE'}{'val'}{$init}; }
    else
    	{ $index = $lkup->{'COVERAGE'}->add($init); }

    push (@{$lkup->{'RULES'}[$index]}, {'ACTION' => [$lig], 'MATCH' => [@seq]});
}

# subroutine to add ss feature specific data ($ss_data) to OT structures
# skips over glyphs in cv_data that don't exist in font
# updates name_id to next available value (must be passed by reference)
# todo: handle empty keys in $ss_data
sub add_ss_feat
{
	my ($ss_data, $name_id, $coverage, $action, $params) = @_;

	foreach my $g (@{$ss_data->{'glyphs'}})
	{
		if (glyphs_exist(($g->{'base'}, $g->{'alt'})))
		{
			$coverage->add($gnames{$g->{'base'}});
			push @{$action}, [{'ACTION' => [$gnames{$g->{'alt'}}]}];
		}
	}

	$params->{'Version'} = 0;
	name_tbl_add($$name_id, $ss_data->{'feature_name'});
	$params->{'UINameID'} = $$name_id++;
}

# subroutine to add cv feature specific data ($cv_data) to OT structures
# skips over glyphs in cv_data that don't exist in font
# updates name_id to next available value (must be passed by reference)
# todo: handle empty keys in $cv_data
sub add_cv_feat
{
	my ($cv_data, $name_id, $coverage, $action, $params) = @_;
	
	foreach my $g (@{$cv_data->{'glyphs'}}) 
	{
		if (glyphs_exist(($g->{'base'}, @{$g->{'alts'}})))
		{
			$coverage->add($gnames{$g->{'base'}});
			push @{$action}, [{'ACTION' => [map {$gnames{$_}} @{$g->{'alts'}}]}];
		}
	}
	
	$params->{'Format'} = 0;
	name_tbl_add($$name_id, $cv_data->{'feature_name'});
	$params->{'UINameID'} = $$name_id++;
	name_tbl_add($$name_id, $cv_data->{'tooltip'});
	$params->{'TooltipNameID'} = $$name_id++;
	name_tbl_add($$name_id, $cv_data->{'sample_str'});
	$params->{'SampleTextNameID'} = $$name_id++;
	
	$params->{'NumNamedParms'} = scalar @{$cv_data->{'param_names'}};
	$params->{'FirstNamedParmID'} = $$name_id;
	foreach $n (@{$cv_data->{'param_names'}}) {name_tbl_add($$name_id++, $n);}

# InDesign CC doesn't work with the 'Characters' array present
#	$params->{'Characters'} = $cv_data->{'characters'};
}

# add strings to the name table in english for platform and encodings 1 0 and 3 1
sub name_tbl_add
{
	my ($name_id, $string) = @_;
	$f->{'name'}->set_name($name_id, $string, 'en', @{[[1, 0]]});
	$f->{'name'}->set_name($name_id, $string, 'en-US', @{[[3, 1]]});
}

# delete a lookup from the array of all lookups
#  and from any feature that references it
#  and correct references in features to lookups that come after the deleted one
#  does NOT adjust other lookups which may reference the deleted lookups or lookups after it
sub gsub_lookup_del
{
	my ($lkup_lbl) = @_;
	my ($lkup_ix) = lk($lkup_lbl);

	# remove the lookup from the main array of lookups
	splice (@gsubs, $lkup_ix, 1);
	splice (@gsub_lkups, $lkup_ix, 1);
	
	# remove the lookup from the list of lookup indexes for any feature
	#  lookup may not be present in any given feature
	# also decrement the lookup indexes that are greater than the one being removed
	foreach my $feat (@{$gsub->{'FEATURES'}{'FEAT_TAGS'}})
	{
		my $lookups = $gsub->{'FEATURES'}{$feat}{'LOOKUPS'};
		my ($lookups_ix, $found_ix) = (-1, -1);
		foreach my $ix (@{$lookups})
		{
			++$lookups_ix;
			if ($ix == $lkup_ix) 
			{
				$found_ix = $lookups_ix;
			}
			if ($ix > $lkup_ix)
			{
				@{$lookups}[$lookups_ix]--;
			}
		}
		if ($found_ix != -1)
			{ splice (@{$lookups}, $found_ix, 1); }
	}
}

# delete a feature from the array of all features
#  and from the langs that references it
sub gsub_feature_del
{
	my ($feat_tag) = @_;
	
	# delete from Feature List table
	my $feat_tag_ix = -1;
	foreach my $feat (@{$gsub->{'FEATURES'}{'FEAT_TAGS'}})
	{
		++$feat_tag_ix;
		if ($feat eq $feat_tag)
		{
			splice (@{$gsub->{'FEATURES'}{'FEAT_TAGS'}}, $feat_tag_ix, 1);
			delete $gsub->{'FEATURES'}{$feat_tag};
			last;
		}
	}
	
	# delete from Script List table
	foreach my $script (keys %{$gsub->{'SCRIPTS'}})
	{
		my @lang_key_lst;
		if (exists $gsub->{'SCRIPTS'}{$script}{'LANG_TAGS'})
			{ push @lang_key_lst, @{$gsub->{'SCRIPTS'}{$script}{'LANG_TAGS'}}; }
		if (exists $gsub->{'SCRIPTS'}{$script}{'DEFAULT'}{'FEATURES'})
			{ push @lang_key_lst, ('DEFAULT'); }
		foreach my $lang (@lang_key_lst)
		{
			my $feat_lst = $gsub->{'SCRIPTS'}{$script}{$lang}{'FEATURES'};
			my $feat_ix = -1;
			foreach my $feat (@{$feat_lst})
			{
				++$feat_ix;
				if ($feat eq $feat_tag)
				{
					splice (@{$feat_lst}, $feat_ix, 1);
					last;
				}
			}
		}
	}
}
