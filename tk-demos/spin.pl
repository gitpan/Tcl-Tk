# spin.tcl --
#
# This demonstration script creates several spinbox widgets.
#
# RCS: @(#) $Id: spin.pl,v 1.2 2004/03/22 23:59:57 hobbs2 Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.spin';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Spinbox Demonstration");
wm('iconname', $w, "spin");
positionWindow($w);
$interp->label("$w.msg", -font=>$font, -wraplength=>'5i', -justify=>'left', -text=>"Three different spin-boxes are displayed below.  You can add characters by pointing, clicking and typing.  The normal Motif editing characters are supported, along with many Emacs bindings.  For example, Backspace and Control-h delete the character to the left of the insertion cursor and Delete and Control-d delete the chararacter to the right of the insertion cursor.  For values that are too large to fit in the window all at once, you can scan through the value by dragging with mouse button2 pressed.  Note that the first spin-box will only permit you to type in integers, and the third selects from a list of Australian cities.")
  ->pack(-side=>'top');

$interp->frame("$w.buttons")
  ->pack("$w.buttons", qw/-side bottom -fill x -pady 2m/);
$interp->button("$w.buttons.dismiss", -text=>"Dismiss", -command=>"destroy $w");
$interp->button("$w.buttons.code", -text=>"See Code", -command=>"showCode $w");
$interp->pack("$w.buttons.dismiss", "$w.buttons.code", -side=>"left", -expand=>1);


my @australianCities = (qw{
    Canberra Sydney Melbourne Perth Adelaide Brisbane
    Hobart Darwin}, "Alice\\ Springs");

spinbox("$w.s1", qw/-from 1 -to 10 -width 10 -validate key/,
	-vcmd=>'string is integer %P');
spinbox("$w.s2", qw/-from 0 -to 3 -increment .5 -format %05.2f -width 10/);
spinbox("$w.s3", -values=>join(' ',@australianCities), -width=>10);

tkpack("$w.s1", "$w.s2", "$w.s3", qw/-side top -pady 5 -padx 10/) ;#-fill x

