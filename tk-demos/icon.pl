# icon.tcl --
#
# This demonstration script creates a toplevel window containing
# buttons that display bitmaps instead of text.
#
# RCS: @(#) $Id: icon.tcl,v 1.2 1998/09/14 18:23:28 stanton Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.icon';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Iconic Button Demonstration");
wm('iconname', $w, "icon");
positionWindow($w);

$interp->label("$w.msg", -font=>$font, -wraplength=>'5i', -justify=>'left', -text=>"This window shows three ways of using bitmaps or images in radiobuttons and checkbuttons.  On the left are two radiobuttons, each of which displays a bitmap and an indicator.  In the middle is a checkbutton that displays a different image depending on whether it is selected or not.  On the right is a checkbutton that displays a single bitmap but changes its background color to indicate whether or not it is selected.")
  ->pack(-side=>'top');

$interp->frame("$w.buttons")
  ->pack("$w.buttons", qw/-side bottom -fill x -pady 2m/);
$interp->button("$w.buttons.dismiss", -text=>"Dismiss", -command=>"destroy $w");
$interp->button("$w.buttons.code", -text=>"See Code", -command=>"showCode $w");
$interp->pack("$w.buttons.dismiss", "$w.buttons.code", -side=>"left", -expand=>1);

$interp->image('create', 'bitmap', 'flagup',
	-file => "./images/flagup.bmp",
	-maskfile => "./images/flagup.bmp");
$interp->image('create', 'bitmap', 'flagdown',
	-file => "./images/flagdown.bmp",
	-maskfile => "./images/flagdown.bmp");
frame("$w.frame", -borderwidth=>10)->pack(-side=>'top');

checkbutton("$w.frame.b1", qw/-image flagdown -selectimage flagup
	-indicatoron 0/)
  ->configure(-selectcolor=>widget("$w.frame.b1")->cget('-background'));
checkbutton("$w.frame.b2",
	-bitmap => '@./images/letters.bmp',
	-indicatoron=>0, -selectcolor=>'SeaGreen1');
frame("$w.frame.left");
tkpack("$w.frame.left", "$w.frame.b1", "$w.frame.b2", qw/-side left -expand yes -padx 5m/);

my $letters='';
radiobutton("$w.frame.left.b3",
	-bitmap => '@./images/letters.bmp',
	-variable=>\$letters, -value=>'full');
radiobutton("$w.frame.left.b4",
	-bitmap => '@./images/noletter.bmp',
	-variable=>\$letters, -value=>'empty');
tkpack("$w.frame.left.b3", "$w.frame.left.b4", -side=>'top', -expand=>'yes');

