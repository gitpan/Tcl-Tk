# plot.tcl --
#
# This demonstration script creates a canvas widget showing a 2-D
# plot with data points that can be dragged with the mouse.
#
# RCS: @(#) $Id: plot.tcl,v 1.3 2001/06/14 10:56:58 dkf Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.plot';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Plot Demonstration");
wm('iconname', $w, "Plot");
positionWindow($w);
my $c = "$w.c";

label "$w.msg", -font=>$font, -wraplength=>'4i', -justify=>'left', -text=>"This window displays a canvas widget containing a simple 2-dimensional plot.  You can doctor the data by dragging any of the points with mouse button 1.";
tkpack "$w.msg", -side=>'top';

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

my $cw = canvas $c, qw/-relief raised -width 450 -height 300/;
tkpack "$w.c", qw/-side top -fill x/;

my $plotFont = 'Helvetica 18';

$cw-> create (qw/line 100 250 400 250 -width 2/);
$cw-> create (qw/line 100 250 100 50 -width 2/);
$cw-> create (qw/text 225 20/, -text=>"A Simple Plot", -font=>$font, -fill=>'brown');

for ($i=0; $i <= 10; $i++) {
    my $x = 100 + ($i*30);
    $cw-> create ('line', $x, 250, $x, 245, -width=>2);
    $cw-> create ('text', $x, 254, -text => 10*$i, -anchor=>'n', -font=>$plotFont);
}
for ($i=0; $i <= 5; $i++) {
    my $y = 250 - ($i*40);
    $cw-> create ('line', 100, $y, 105, $y, -width=>2);
    $cw-> create ('text', 96, $y, -text=>($i*50).".0", -anchor=>'e', -font=>$plotFont);
}

foreach my $point (
    ([12, 56], [20, 94], [33, 98], [32, 120], [61, 180], [75, 160], [98, 223])
) {
    my $x =100 + (3*$point->[0]);
    my $y =250 - (4*$point->[1]/5);
    my $item = $cw-> create ('oval', $x-6, $y-6,
    	$x+6, $y+6, -width=>1, -outline=>'black',
    	-fill => 'SkyBlue2');
    $cw->addtag ('point', withtag=>$item);
}

$cw->bind('point', '<Any-Enter>', sub{$cw->itemconfig(qw/current -fill red/)});
$cw->bind('point', '<Any-Leave>', sub{$cw->itemconfig(qw/current -fill SkyBlue2/)});
$cw->bind('point', '<1>', \\'xy', sub {embPlotDown($c)});
$cw->bind('point', '<ButtonRelease-1>', sub {$cw->dtag("selected");});
tkbind $c, '<B1-Motion>', \\'xy', sub {embPlotMove($c)};

my %embPlot;
$embPlot{lastX} = 0;
$embPlot{lastY} = 0;

# plotDown --
# This procedure is invoked when the mouse is pressed over one of the
# data points.  It sets up state to allow the point to be dragged.
#
# Arguments:
# w -		The canvas window.
# x, y -	The coordinates of the mouse press.

sub embPlotDown {
    my $w = shift;
    my $tw = widget($w);
    my ($x,$y) = (Tcl::Ev('x'),Tcl::Ev('y'));
    $tw->dtag('selected');
    $tw->addtag('selected', 'withtag', 'current');
    $tw->raise('current');
    $embPlot{lastX} = $x;
    $embPlot{lastY} = $y;
}

# plotMove --
# This procedure is invoked during mouse motion events.  It drags the
# current item.
#
# Arguments:
# w -		The canvas window.
# x, y -	The coordinates of the mouse.

sub embPlotMove {
    my $w = shift;
    my $tw = widget($w);
    my ($x,$y) = (Tcl::Ev('x'),Tcl::Ev('y'));
    $tw->move('selected', $x-$embPlot{lastX}, $y-$embPlot{lastY});
    $embPlot{lastX} = $x;
    $embPlot{lastY} = $y;
}

