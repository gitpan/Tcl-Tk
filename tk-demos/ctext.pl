# ctext.tcl --
#
# This demonstration script creates a canvas widget with a text
# item that can be edited and reconfigured in various ways.
#
# RCS: @(#) $Id: ctext.pl,v 1.2 2004/03/22 23:59:57 hobbs2 Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.ctext';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Canvas Text Demonstration");
wm('iconname', $w, "Text");
positionWindow($w);
my $c = "$w.c";

label "$w.msg", -font=>$font, -wraplength=>'5i', -justify=>'left', -text=>"This window displays a string of text to demonstrate the text facilities of canvas widgets.  You can click in the boxes to adjust the position of the text relative to its positioning point or change its justification.  The text also supports the following simple bindings for editing:
  1. You can point, click, and type.
  2. You can also select with button 1.
  3. You can copy the selection to the mouse position with button 2.
  4. Backspace and Control+h delete the selection if there is one;
     otherwise they delete the character just before the insertion cursor.
  5. Delete deletes the selection if there is one; otherwise it deletes
     the character just after the insertion cursor.";
tkpack "$w.msg", -side=>'top';

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

my $cw = canvas $c, qw/-relief flat -borderwidth 0 -width 500 -height 350/;
tkpack "$w.c", qw/-side top -expand yes -fill both/;

my $textFont = 'Helvetica 24';

$cw->create qw/rectangle 245 195 255 205 -outline black -fill red/;

# First, create the text item and give it bindings so it can be edited.

$cw-> addtag ('text', 'withtag', $cw->create('text', 250, 200, -text=>"This is just a string of text to demonstrate the text facilities of canvas widgets. Bindings have been been defined to support editing (see above).", -width=>440, -anchor=>'n', -font=>"Helvetica 24", -justify=>'left') );
$cw-> bind ('text', '<1>', \\'xy', sub {textB1Press($c,Tcl::Ev('x'),Tcl::Ev('y'))});
$cw-> bind ('text', '<B1-Motion>', \\'xy', sub {textB1Move($c,Tcl::Ev('x'),Tcl::Ev('y'))} );
$cw-> bind ('text', '<Shift-1>', "$c select adjust current \@%x,%y");
$cw-> bind ('text', '<Shift-B1-Motion>', \\'xy', sub {textB1Move ($c,Tcl::Ev('x'),Tcl::Ev('y'))});
$cw-> bind ('text', '<KeyPress>', \\'A', sub {textInsert($c,Tcl::Ev('A'))});
$cw-> bind ('text', '<Return>', sub{textInsert($c, "\n")});
$cw-> bind ('text', '<Control-h>', sub{textBs($c)});
$cw-> bind ('text', '<BackSpace>', sub{textBs($c)});
$cw-> bind ('text', '<Delete>', sub{textDel($c)});
$cw-> bind ('text', '<2>', \\'xy', sub {textPaste ($c,Tcl::Ev('x'),Tcl::Ev('y'))} );

# Next, create some items that allow the text's anchor position
# to be edited.

sub mkTextConfig ($$$$$$) {
    my ($w, $x, $y, $option, $value, $color) = @_;
    my $cw = widget($w);
    my $item = $cw->create('rect', $x, $y, $x+30, $y+30,
	    -outline=>'black', -fill=>$color, -width=>1);
    $cw->bind($item, "<1>", "$w itemconf text $option $value");
    $cw->addtag('config', 'withtag', $item);
}

my ($x,$y) = (50,50);
my $color = 'LightSkyBlue1';
mkTextConfig $c, $x   ,  $y   , -anchor =>'se',     $color;
mkTextConfig $c, $x+30,  $y   , -anchor =>'s',      $color;
mkTextConfig $c, $x+60,  $y   , -anchor =>'sw',     $color;
mkTextConfig $c, $x   ,  $y+30, -anchor =>'e',      $color;
mkTextConfig $c, $x+30,  $y+30, -anchor =>'center', $color;
mkTextConfig $c, $x+60,  $y+30, -anchor =>'w',      $color;
mkTextConfig $c, $x   ,  $y+60, -anchor =>'ne',     $color;
mkTextConfig $c, $x+30,  $y+60, -anchor =>'n',      $color;
mkTextConfig $c, $x+60,  $y+60, -anchor =>'nw',     $color;
my $item = $cw->create('rect',
	$x+40, $y+40, $x+50, $y+50, -outline=>'black', -fill=>'red');
$cw->bind($item, '<1>', "$c itemconf text -anchor center");
$cw->create('text', $x+45, $y-5,
	-text=>'Text Position',  -anchor=>'s', -font=>'Times 24', -fill=>'brown');

# Lastly, create some items that allow the text's justification to be
# changed.

($x,$y) = (350,50);
$color = 'SeaGreen2';
mkTextConfig $c, $x, $y, -justify=>'left', $color;
mkTextConfig $c, $x+30, $y, -justify=>'center', $color;
mkTextConfig $c, $x+60, $y, -justify=>'right', $color;
$cw->create('text', $x+45, $y-5,
	-text=>'Justification',  -anchor=>'s',  -font=>'Times 24',  -fill=>'brown');

my $textConfigFill = '';

$cw->bind('config', '<Enter>', sub{textEnter($c)});
$cw->bind('config', '<Leave>', sub{$cw->itemconf('current', -fill=>$textConfigFill)});

sub textEnter {
    my $w = shift;
    my $cw = widget($w);
    $textConfigFill = [$cw->itemconfig('current', '-fill')]->[4];
    $cw->itemconfig(qw/current -fill black/);
}

sub textInsert {
    my $w = shift;
    my $string = shift;
    my $cw = widget($w);
    return 1 if (!defined($string) or $string eq "");
    eval {
      $cw->dchars('text', 'sel.first', 'sel.last');
    };
    $cw->insert('text', 'insert', $string);
}

sub textPaste {
    my ($w,$x,$y) = @_;
    eval {
        widget($w)->insert('text', "\@$x,$y", $interp->Eval('selection get'));
    };
}

sub textB1Press {
    my $w = shift;
    my ($x,$y) = @_;
    my $cw = widget($w);
    $cw->icursor('current', "\@$x,$y");
    $cw->focus('current');
    focus($w);
    $cw->select('from', 'current', "\@$x,$y");
}

sub textB1Move {
    my $w = shift;
    my ($x,$y) = @_;
    my $cw = widget($w);
    $cw->select('to', 'current', "\@$x,$y");
}

sub textBs {
    my $w = shift;
    my $cw = widget($w);
    eval {
      $cw->dchars('text', 'sel.first', 'sel.last');
    };
    if ($@) {
      my $char = $cw->index('text', 'insert')-1;
      if ($char >= 0) {$cw->dchar('text', $char);}
      $@ = '';
    }
}

sub textDel {
    my $w = shift;
    my $cw = widget($w);
    eval {
      $cw->dchars('text', 'sel.first', 'sel.last');
    };
    if ($@) {
      $cw->dchars('text', 'insert');
      $@ = '';
    }
}

