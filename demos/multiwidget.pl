
use strict;
use Tcl::Tk qw/:perlTk/;
#BEGIN {$::Tcl::Tk::DEBUG=1}

my $mw = MainWindow->new;


my $w1 = $mw->Label->pack;
my $w2 = $mw->Label->pack;
my $w3 = $mw->Entry->pack;
my $w4 = $mw->Entry->pack;

my $mmw = new Tcl::Tk::Widget::MultipleWidget (
   $mw->interp,
   $w1, ['-labtext1=-text',''],
   $w2, ['-labtext2=-text'],
   $w3, ['-labtext3=-text','&'],
   $w4, ['&get2=get'],
);

$mmw->configure(-labtext1=>'labtext1',-labtext2=>'labtext2xx');


$mw->Button(-text=>'test', -command=>sub{
  print $mmw->get,',',$mmw->get2,
})->pack;

MainLoop;
