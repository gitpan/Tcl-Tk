use strict;
use utf8;
use Tcl::Tk qw(:widgets :misc);

my $interp = new Tcl::Tk;

label(".l", -text => "Hello world");
tkpack ".l";
my $t = text(".t", -font => "-*-Arial Unicode MS--R---*-350-*-*-*-*-*-*", -width => 25, -height=>8);
tkpack ".t";
$t->insert('end',"qwerty\x{0431}\x{0432}\x{0432}\x{5678}\x{5ab3}");
$|=1;
button(".b", -text => "test", -command=>sub {print "uahaha! It worked!"});
tkpack ".b";
my $r="aaaa";
button(".d", -textvariable => \$r, -command=>sub {$r++});
tkpack ".d";
MainLoop;
