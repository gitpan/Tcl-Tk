# items.tcl --
#
# This demonstration script creates a canvas that displays the
# canvas item types.
#
# RCS: @(#) $Id: items.tcl,v 1.3 2001/06/14 10:56:58 dkf Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.items';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Canvas Item Demonstration");
wm('iconname', $w, "Items");
positionWindow($w);
my $c = "$w.frame.c";

label "$w.msg", -font=>$font, -wraplength=>'5i', -justify=>'left', -text=>"This window contains a canvas widget with examples of the various kinds of items supported by canvases.  The following operations are supported:\n  Button-1 drag:\tmoves item under pointer.\n  Button-2 drag:\trepositions view.\n  Button-3 drag:\tstrokes out area.\n  Ctrl+f:\t\tprints items under area.";
tkpack "$w.msg", -side=>'top';

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

frame "$w.frame";
tkpack "$w.frame", -side=>'top', -fill=>'both', -expand=>'yes';

my $canv = canvas $c, -scrollregion=>'0c 0c 30c 24c', -width=>'15c', -height=>'10c',
	-relief=>'sunken', -borderwidth=>2,
	-xscrollcommand=>"$w.frame.hscroll set",
	-yscrollcommand=>"$w.frame.vscroll set";
scrollbar "$w.frame.vscroll", -command=> "$c yview";
scrollbar "$w.frame.hscroll", -orient=>'horiz', -command=>"$c xview";

grid ($c, -in=>"$w.frame",
    qw/-row 0 -column 0 -rowspan 1 -columnspan 1 -sticky news/);
grid ("$w.frame.vscroll",
    qw/-row 0 -column 1 -rowspan 1 -columnspan 1 -sticky news/);
grid ("$w.frame.hscroll",
    qw/-row 1 -column 0 -rowspan 1 -columnspan 1 -sticky news/);
grid ( "rowconfig",    "$w.frame"=>0, qw/-weight 1 -minsize 0/);
grid ("columnconfig", "$w.frame"=>0, qw/-weight 1 -minsize 0/);

# Display a 3x3 rectangular grid.

$canv-> create (qw/rect 0c 0c 30c 24c -width 2/);
$canv-> create (qw/line 0c 8c 30c 8c -width 2/);
$canv-> create (qw/line 0c 16c 30c 16c -width 2/);
$canv-> create (qw/line 10c 0c 10c 24c -width 2/);
$canv-> create (qw/line 20c 0c 20c 24c -width 2/);

my $font1 = 'Helvetica 12';
my $font2 = 'Helvetica 24 bold';
if ($interp->Eval("winfo depth $c") > 1) {
    $blue = 'DeepSkyBlue3';
    $red = 'red';
    $bisque = 'bisque3';
    $green = 'SeaGreen3';
} else {
    $blue = 'black';
    $red = 'black';
    $bisque = 'black';
    $green = 'black';
}

# Set up demos within each of the areas of the grid.

$canv-> create (qw/text 5c .2c -text Lines -anchor n/);
$canv-> create (qw/line 1c 1c 3c 1c 1c 4c 3c 4c -width 2m -fill/, $blue, qw/
	-cap butt -join miter -tags item/);
$canv-> create (qw/line 4.67c 1c 4.67c 4c -arrow last -tags item/);
$canv-> create (qw/line 6.33c 1c 6.33c 4c -arrow both -tags item/);
$canv-> create (qw/line 5c 6c 9c 6c 9c 1c 8c 1c 8c 4.8c 8.8c 4.8c 8.8c 1.2c 
	8.2c 1.2c 8.2c 4.6c 8.6c 4.6c 8.6c 1.4c 8.4c 1.4c 8.4c 4.4c 
	-width 3 -fill/, $red, qw/-tags item/);
$canv-> create (qw/line 1c 5c 7c 5c 7c 7c 9c 7c -width .5c 
	-stipple/, "\@./images/gray25.bmp",
	-arrow=>'both', -arrowshape=>'15 15 7', -tags=>'item');
$canv-> create qw/line 1c 7c 1.75c 5.8c 2.5c 7c 3.25c 5.8c 4c 7c -width .5c 
	-cap round -join round -tags item/;

$canv-> create(qw/text 15c .2c -text/, "Curves (smoothed lines)", -anchor=>'n');
$canv-> create(qw/line 11c 4c 11.5c 1c 13.5c 1c 14c 4c -smooth on 
	-fill/, $blue, -tags=>'item');
$canv-> create qw/line 15.5c 1c 19.5c 1.5c 15.5c 4.5c 19.5c 4c -smooth on 
	-arrow both -width 3 -tags item/;
$canv-> create (qw|line 12c 6c 13.5c 4.5c 16.5c 7.5c 18c 6c 
	16.5c 4.5c 13.5c 7.5c 12c 6c -smooth on -width 3m -cap round 
	-stipple @./images/gray25.bmp
	-fill|, $red, -tags=>'item');

$canv-> create qw/text 25c .2c -text Polygons -anchor n/;
$canv-> create(qw/polygon 21c 1.0c 22.5c 1.75c 24c 1.0c 23.25c 2.5c 
	24c 4.0c 22.5c 3.25c 21c 4.0c 21.75c 2.5c -fill/, $green,
	qw/-outline black -width 4 -tags item/);
$canv-> create(qw/polygon 25c 4c 25c 4c 25c 1c 26c 1c 27c 4c 28c 1c 
	29c 1c 29c 4c 29c 4c -fill/, $red, qw/-smooth on -tags item/);
$canv-> create qw|polygon 22c 4.5c 25c 4.5c 25c 6.75c 28c 6.75c 
	28c 5.25c 24c 5.25c 24c 6.0c 26c 6c 26c 7.5c 22c 7.5c 
	-stipple @./images/gray25.bmp
	-outline black -tags item|;

$canv-> create qw/text 5c 8.2c -text Rectangles -anchor n/;
$canv-> create(qw/rectangle 1c 9.5c 4c 12.5c -outline/, $red, qw/-width 3m -tags item/);
$canv-> create(qw/rectangle 0.5c 13.5c 4.5c 15.5c -fill/, $green, -tags=>'item');
$canv-> create(rectangle=>'6c 10c 9c 15c', -outline=>'',
	-stipple=>'@./images/gray25.bmp',
	-fill=>$blue, -tags=>'item');

$canv-> create qw/text 15c 8.2c -text Ovals -anchor n/;
$canv-> create(qw/oval 11c 9.5c 14c 12.5c -outline/, $red, qw/-width 3m -tags item/);
$canv-> create(qw/oval 10.5c 13.5c 14.5c 15.5c -fill/, $green, -tags=>'item');
$canv-> create(oval=>'16c 10c 19c 15c', -outline=>'',
	-stipple=>'@./images/gray25.bmp',
	-fill=>$blue, -tags=>'item');

$canv-> create qw/text 25c 8.2c -text Text -anchor n/;
$canv-> create qw/rectangle 22.4c 8.9c 22.6c 9.1c/;
$canv-> create(qw/text 22.5c 9c -anchor n -font $font1 -width 4c/, 
	-text=>"A short string of text, word-wrapped, justified left, and anchored north (at the top).  The rectangles show the anchor points for each piece of text.", -tags=>'item');
$canv-> create qw/rectangle 25.4c 10.9c 25.6c 11.1c/;
$canv-> create(qw/text 25.5c 11c -anchor w -font $font1 -fill/, $blue,
	-text=>"Several lines,\n each centered\nindividually,\nand all anchored\nat the left edge.",
	qw/-justify center -tags item/);
$canv-> create qw/rectangle 24.9c 13.9c 25.1c 14.1c/;
$canv-> create('text','25c', '14c', -font=>$font2, -anchor=>'c', -fill=>$red, -stipple=>'gray50',
	-text=>"Stippled characters", -tags=>'item');

$canv-> create qw/text 5c 16.2c -text Arcs -anchor n/;
$canv-> create(qw/arc 0.5c 17c 7c 20c -fill/, $green, qw/-outline black
	-start 45 -extent 270 -style pieslice -tags item/);
$canv-> create(qw|arc 6.5c 17c 9.5c 20c -width 4m -style arc
	-outline|, $blue, qw|-start -135 -extent 270 -tags item
	-outlinestipple @./images/gray25.bmp|);
$canv-> create(qw/arc 0.5c 20c 9.5c 24c -width 4m -style pieslice
	-fill/, '', -outline=>$red, qw/-start 225 -extent -90 -tags item/);
$canv-> create(qw/arc 5.5c 20.5c 9.5c 23.5c -width 4m -style chord
	-fill/, $blue, -outline=>'', qw/-start 45 -extent 270  -tags item/);

$canv-> create qw/text 15c 16.2c -text Bitmaps -anchor n/;
$canv-> create qw|bitmap 13c 20c -tags item 
	-bitmap @./images/face.bmp|;
$canv-> create qw|bitmap 17c 18.5c -tags item 
	-bitmap @./images/noletter.bmp|;
$canv-> create qw|bitmap 17c 21.5c -tags item
	-bitmap @./images/letters.bmp|;

$canv-> create qw/text 25c 16.2c -text Windows -anchor n/;
button "$c.button", -text=>"Press Me", -command=>"butPress $c $red";
$canv-> create('window', '21c', '18c', -window=>"$c.button", qw/-anchor nw -tags item/);
my $entr = entry "$c.entry", -width=>20, -relief=>'sunken';
$entr->insert ('end', "Edit this text");
$canv-> create ('window', '21c', '21c', -window=>"$c.entry", -anchor=>'nw', -tags=>'item');
my $scale = scale "$c.scale", qw/-from 0 -to 100 -length 6c -sliderlength .4c
	-width .5c -tickinterval 0/;
$canv-> create('window', '28.5c', '17.5c', -window=>"$c.scale", -anchor=>'n', -tags=>'item');
$canv-> create qw/text 21c 17.9c -text Button: -anchor sw/;
$canv-> create qw/text 21c 20.9c -text Entry: -anchor sw/;
$canv-> create qw/text 28.5c 17.4c -text Scale: -anchor s/;

#
# Following line defines all other subroutines in Tcl.
# This was done only to prove the concept and not mandatory: all those code
# should be written in Perl. Samples how to do that could be seen in other demo code.
# The only difficulty could be vith events, see samples in "Text/Hypertext tag bindings"
# demo.
#

$interp->Eval(<<'EOS');
set w .items
set c "$w.frame.c"

# Set up event bindings for canvas:

$c bind item <Any-Enter> "itemEnter $c"
$c bind item <Any-Leave> "itemLeave $c"
bind $c <2> "$c scan mark %x %y"
bind $c <B2-Motion> "$c scan dragto %x %y"
bind $c <3> "itemMark $c %x %y"
bind $c <B3-Motion> "itemStroke $c %x %y"
bind $c <Control-f> "itemsUnderArea $c"
bind $c <1> "itemStartDrag $c %x %y"
bind $c <B1-Motion> "itemDrag $c %x %y"

# Utility procedures for highlighting the item under the pointer:

proc itemEnter {c} {
    global restoreCmd

    if {[winfo depth $c] == 1} {
	set restoreCmd {}
	return
    }
    set type [$c type current]
    if {$type == "window"} {
	set restoreCmd {}
	return
    }
    if {$type == "bitmap"} {
	set bg [lindex [$c itemconf current -background] 4]
	set restoreCmd [list $c itemconfig current -background $bg]
	$c itemconfig current -background SteelBlue2
	return
    }
    set fill [lindex [$c itemconfig current -fill] 4]
    if {(($type == "rectangle") || ($type == "oval") || ($type == "arc"))
	    && ($fill == "")} {
	set outline [lindex [$c itemconfig current -outline] 4]
	set restoreCmd "$c itemconfig current -outline $outline"
	$c itemconfig current -outline SteelBlue2
    } else {
	set restoreCmd "$c itemconfig current -fill $fill"
	$c itemconfig current -fill SteelBlue2
    }
}

proc itemLeave {c} {
    global restoreCmd

    eval $restoreCmd
}

# Utility procedures for stroking out a rectangle and printing what's
# underneath the rectangle's area.

proc itemMark {c x y} {
    global areaX1 areaY1
    set areaX1 [$c canvasx $x]
    set areaY1 [$c canvasy $y]
    $c delete area
}

proc itemStroke {c x y} {
    global areaX1 areaY1 areaX2 areaY2
    set x [$c canvasx $x]
    set y [$c canvasy $y]
    if {($areaX1 != $x) && ($areaY1 != $y)} {
	$c delete area
	$c addtag area withtag [$c create rect $areaX1 $areaY1 $x $y \
		-outline black]
	set areaX2 $x
	set areaY2 $y
    }
}

proc itemsUnderArea {c} {
    global areaX1 areaY1 areaX2 areaY2
    set area [$c find withtag area]
    set items ""
    foreach i [$c find enclosed $areaX1 $areaY1 $areaX2 $areaY2] {
	if {[lsearch [$c gettags $i] item] != -1} {
	    lappend items $i
	}
    }
    puts stdout "Items enclosed by area: $items"
    set items ""
    foreach i [$c find overlapping $areaX1 $areaY1 $areaX2 $areaY2] {
	if {[lsearch [$c gettags $i] item] != -1} {
	    lappend items $i
	}
    }
    puts stdout "Items overlapping area: $items"
}

set areaX1 0
set areaY1 0
set areaX2 0
set areaY2 0

# Utility procedures to support dragging of items.

proc itemStartDrag {c x y} {
    global lastX lastY
    set lastX [$c canvasx $x]
    set lastY [$c canvasy $y]
}

proc itemDrag {c x y} {
    global lastX lastY
    set x [$c canvasx $x]
    set y [$c canvasy $y]
    $c move current [expr {$x-$lastX}] [expr {$y-$lastY}]
    set lastX $x
    set lastY $y
}

# Procedure that's invoked when the button embedded in the canvas
# is invoked.

proc butPress {w color} {
    set i [$w create text 25c 18.1c -text "Ouch!!" -fill $color -anchor n]
    after 500 "$w delete $i"
}

EOS

