use strict;
use utf8;
use Tcl;
use Tcl::Tk qw(:widgets :misc);

my $interp = new Tcl::Tk;

$interp->Eval('package require Tix');
label(".l", -text => "Hello world")
  ->form(-left=>'%0',-right=>'%100',-top=>'%0');
my $t = text(".t", -font => "-*-Arial Unicode MS--R---*-350-*-*-*-*-*-*", -width => 25, -height=>8)
  ->form(-left=>'%0',-right=>'%100 -20',-top=>'.l',-bottom=>'%100 -20');
$t->insert('end',"qwerty\x{0431}\x{0432}\x{0432}\x{5678}\x{5ab3}");
$|=1;
button(".b", -text => "test", -command=>sub {print "uahaha! It worked!"})
  ->form(-left=>'%0',-right=>'%50',-top=>'.t',-bottom=>'%100');
my $r="aaaa";
button(".d", -textvariable => \$r, -command=>sub {$r++})
  ->form(-left=>'%50',-right=>'%100',-top=>'.t',-bottom=>'%100');
MainLoop;
