# Script to create a GDL class used to test for certain glyphs that need low profile diacritics
# placed above them by default (as opposed to using all LP diacs, which the LP feature will do).
# An included glyph should be: 1)Latin and 2)upper case and 3)have a U AP and 4)not be a deprecated glyph
# Variant glyphs may be unencoded, so strip off GDL glyph name suffixes 
# until the non-variant encoded glyph is found (g__eng_u_c_style -> g__eng).
#  This assumes that glyphs with multiple suffixes will not yield an encoded glyph
#  during the stripping process until the non-variant glyph is found. 
#  Using the GSI var_uid data would be better be we don't want to use that in this part of the build.
# PUA encoded glyphs are treated as unencoded glyphs.
# Much of this code was copied from make_gdl and GDL.pm
# 2010-05-07 AKW

use strict;
use Font::TTF::Scripts::GDL;
use Getopt::Std;
use Unicode::UCD qw(charinfo);

our ($opt_a);
getopts('a:');
my (%opts);

#read ttf and FL XML dump files
my $f = Font::TTF::Scripts::GDL->read_font($ARGV[0], $opt_a, %opts) || die "Can't read font information";
#add GDL names to structs
$f->make_names();

if (exists $f->{'WARNINGS'})
	{ warn $f->{'WARNINGS'}; }

my $outfh = IO::File->new("> $ARGV[1]") || die "Can't open $ARGV[1] for writing";

$f->start_gdl($outfh);
$outfh->print("\n/* cTakesLPDiac class includes non-deprecated, Latin, upper case glyphs with U APs */\n");
$outfh->print("\n/* Classes */\n");
$outfh->print("cTakesLPDiac = ("); #GDL class name

#create map between GDL names and glyph objects
my(%gdl_name);
foreach my $g (@{$f->{'glyphs'}}) {$gdl_name{$g->{'name'}} = $g};

# test each glyph
my ($add_glyph_f, $name);
my ($count, $sep) = (0, '');
foreach my $g (@{$f->{'glyphs'}})
{
	$name = $g->{'name'};
	$add_glyph_f = 2;
	while ($add_glyph_f == 2) 
	{ #continue searching for non-variant glyph while current glyph name is indeterminate 
		if (defined $gdl_name{$name}) #test if truncated glyph name matches a real glyph
		{
			my $g = $gdl_name{$name}; #this is redundant only on the first iteration
			$add_glyph_f = add_glyph($g);
		}
		if (rindex($name, '_') == -1)
			{ last; } #also end loop after last truncated name with no more variants is tested
		$name = substr($name, 0, rindex($name, '_')); #remove rightmost variant suffix
	}

	if ($add_glyph_f == 1)
    {
    	$outfh->print("$sep$g->{'name'}");
	    if (++$count % 8 == 0)
	    	{$sep = ",\n    ";}
	    else
	    	{$sep = ", ";}
    }
}

# subroutine that determines if a glyph should be added to the class
# can return: 0 - exclude; 1 - include; 2 - indeterminate
sub add_glyph(\$)
{
	my ($g) = @_;

#	Not needed now that there are no Dep## forms of variant glyphs
#	Also, deprecated glyph ps names now end in Dep without a dot and with no digits
#	if ($g->{'name'} =~ m/_dep\d{1,2}$/)
#		{ return 0; } # exclude deprecated glyphs (with ending like _dep51)
	
	# test USV
	my ($charinfo_ok) = (0);
	if (defined $g->{'uni'})
	{
		foreach my $u (@{$g->{'uni'}})
		{
			my $charinfo = charinfo($u);
			if ($charinfo->{'category'} eq 'Co') #PUA codepoint
				{ return 2; }
			if ($charinfo->{'category'} eq 'Lu' && $charinfo->{'script'} eq 'Latin')
				{ $charinfo_ok = 1; last; } # non-PUA USV should precede PUA one
		}
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

$outfh->print(");\n\n");
$f->endtable($outfh);
$outfh->close();
