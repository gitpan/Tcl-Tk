# puzzle.tcl --
#
# This demonstration script creates a 15-puzzle game using a collection
# of buttons.
#
# RCS: @(#) $Id: puzzle.tcl,v 1.4 2002/08/31 06:12:28 das Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my (@xpos, @ypos);
sub space(){0}
# puzzleSwitch --
# This procedure is invoked when the user clicks on a particular button;
# if the button is next to the empty space, it moves the button into the
# empty space.

sub puzzleSwitch ($$) {
    my ($w, $num) = @_;
    if ((($ypos[$num] >= ($ypos[space] - .01))
	    && ($ypos[$num] <= ($ypos[space] + .01))
	    && ($xpos[$num] >= ($xpos[space] - .26))
	    && ($xpos[$num] <= ($xpos[space] + .26)))
	    || (($xpos[$num] >= ($xpos[space] - .01))
	    && ($xpos[$num] <= ($xpos[space] + .01))
	    && ($ypos[$num] >= ($ypos[space] - .26))
	    && ($ypos[$num] <= ($ypos[space] + .26)))) {
        ($xpos[$num], $xpos[space]) = ($xpos[space], $xpos[$num]);
	($ypos[$num], $ypos[space]) = ($ypos[space], $ypos[$num]);
        place "$w.frame.$num", -relx=>$xpos[$num], -rely=>$ypos[$num];
    }
}

my $w = '.puzzle';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "15-Puzzle Demonstration");
wm('iconname', $w, "15-Puzzle");
positionWindow($w);

label "$w.msg", -font=>$font, -wraplength=>"4i", -justify=>"left", -text=>"A 15-puzzle appears below as a collection of buttons.  Click on any of the pieces next to the space, and that piece will slide over the space.  Continue this until the pieces are arranged in numerical order from upper-left to lower-right.";
tkpack "$w.msg", -side=>'top';

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

# Special trick: select a darker color for the space by creating a
# scrollbar widget and using its trough color.

my $ws = scrollbar "$w.s";

# The button metrics are a bit bigger in Aqua, and since we are
# using place which doesn't autosize, then we need to have a 
# slightly larger frame here...

my $frameSize;
if ($interp->call('tk','windowingsystem') eq 'aqua') {
    $frameSize = 160;
} else {
    $frameSize = 120;
}

frame "$w.frame", -width=>$frameSize, -height=>$frameSize, -borderwidth=>2,
	-relief=>'sunken', -bg=>$ws->cget('-troughcolor');
tkpack "$w.frame", qw/-side top -pady 1c -padx 1c/;
$interp->call('destroy', "$w.s");

my @order = qw(3 1 6 2 5 7 15 13 4 11 8 9 14 10 12);
for (my $i=0; $i < 15; $i++) {
    my $num = $order[$i];
    $xpos[$num] = ($i%4)*.25;
    $ypos[$num] = int($i/4)*.25;
    button "$w.frame.$num", -relief=>'raised', -text=>$num, -highlightthickness=>0,
	    -command=> sub {puzzleSwitch($w, $num)};
    place "$w.frame.$num", -relx=>$xpos[$num], -rely=>$ypos[$num],
	-relwidth=>.25, -relheight=>.25;
}
$xpos[space] = .75;
$ypos[space] = .75;

