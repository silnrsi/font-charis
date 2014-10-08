use Font::TTF::Font;
use Font::TTF::Table;

$f = Font::TTF::Font->open($ARGV[0]) || die "Unable to open font $ARGV[0]";
$f->{'DSIG'} = Font::TTF::Table->new('dat' => pack("Nnn", 1, 0, 0), 'read' => 1, 'PARENT' => $f);
$f->out($ARGV[1]);
