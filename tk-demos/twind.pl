# twind.tcl --
#
# This demonstration script creates a text widget with a bunch of
# embedded windows.
#
# RCS: @(#) $Id: twind.tcl,v 1.3 2001/06/14 10:56:58 dkf Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.twind';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Text Demonstration - Embedded Windows");
wm('iconname', $w, "Embedded Windows");
positionWindow($w);

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

frame "$w.f", qw/-highlightthickness 2 -borderwidth 2 -relief sunken/;
my $t = "$w.f.text";
my $tw = text $t, -yscrollcommand=>"$w.scroll set", -setgrid=>'true', -font=>$font, -width=>70,
	-height=>35, -wrap=>'word', -highlightthickness=>0, -borderwidth=>0;
tkpack $t, -expand=>'yes', -fill=>'both';
scrollbar "$w.scroll", -command=>"$t yview";
tkpack "$w.scroll", -side=>"right", -fill=>"y";
tkpack "$w.f", -expand=>"yes", -fill=>"both";
$tw->tag(qw/configure center -justify center -spacing1 5m -spacing3 5m/);
$tw->tag(qw/configure buttons -lmargin1 1c -lmargin2 1c -rmargin 1c
	-spacing1 3m -spacing2 0 -spacing3 0/);

button "$t.on", -text=>"Turn On", -command=>sub{textWindOn($w)},
	-cursor=>'top_left_arrow';
button "$t.off", -text=>"Turn Off", -command=>sub{textWindOff($w)},
	-cursor=>'top_left_arrow';
button "$t.click", -text=>"Click Here", -command=>sub{textWindPlot($t)},
	-cursor=>'top_left_arrow';
button "$t.delete", -text=>"Delete", -command=>sub{textWindDel($w)},
	-cursor=>'top_left_arrow';

$tw-> insert ('end', "A text widget can contain other widgets embedded ");
$tw-> insert ('end', "it.  These are called \"embedded windows\", ");
$tw-> insert ('end', "and they can consist of arbitrary widgets.  ");
$tw-> insert ('end', "For example, here are two embedded button ");
$tw-> insert ('end', "widgets.  You can click on the first button to ");
$tw-> window ('create', 'end', -window=>"$t.on");
$tw-> insert ('end', " horizontal scrolling, which also turns off ");
$tw-> insert ('end', "word wrapping.  Or, you can click on the second ");
$tw-> insert ('end', "button to\n");
$tw-> window ('create', 'end', -window=>"$t.off");
$tw-> insert ('end', " horizontal scrolling and turn back on word wrapping.\n\n");

$tw-> insert ('end', "Or, here is another example.  If you ");
$tw-> window ('create', 'end', -window=>"$t.click");
$tw-> insert ('end', " a canvas displaying an x-y plot will appear right here.");
$tw-> mark ('set', 'plot', 'insert');
$tw-> mark ('gravity', 'plot', 'left');
$tw-> insert ('end', "  You can drag the data points around with the mouse, ");
$tw-> insert ('end', "or you can click here to ");
$tw-> window ('create', 'end', -window=>"$t.delete");
$tw-> insert ('end', " the plot again.\n\n");

$tw-> insert ('end', "You may also find it useful to put embedded windows in ");
$tw-> insert ('end', "a text without any actual text.  In this case the ");
$tw-> insert ('end', "text widget acts like a geometry manager.  For ");
$tw-> insert ('end', "example, here is a collection of buttons laid out ");
$tw-> insert ('end', "neatly into rows by the text widget.  These buttons ");
$tw-> insert ('end', "can be used to change the background color of the ");
$tw-> insert ('end', "text widget (\"Default\" restores the color to ");
$tw-> insert ('end', "its default).  If you click on the button labeled ");
$tw-> insert ('end', "\"Short\", it changes to a longer string so that ");
$tw-> insert ('end', "you can see how the text widget automatically ");
$tw-> insert ('end', "changes the layout.  Click on the button again ");
$tw-> insert ('end', "to restore the short string.\n");

button "$t.default", -text=>Default, -command=>sub{embDefBg($t)},
	-cursor=>'top_left_arrow';
$tw-> window ('create', 'end', -window=>"$t.default", -padx=>3);
my $embToggle = 'Short';
checkbutton "$t.toggle", -textvariable=>\$embToggle, -indicatoron=>0,
	-variable=>\$embToggle, -onvalue=>"A much longer string",
	-offvalue=>"Short", -cursor=>'top_left_arrow', -pady=>5, -padx=>2;
$tw-> window ('create', 'end', -window=>"$t.toggle", -padx=>3, -pady=>2);
my $i=1;
foreach my $color (qw{AntiqueWhite3 Bisque1 Bisque2 Bisque3 Bisque4
	SlateBlue3 RoyalBlue1 SteelBlue2 DeepSkyBlue3 LightBlue1
	DarkSlateGray1 Aquamarine2 DarkSeaGreen2 SeaGreen1
	Yellow1 IndianRed1 IndianRed2 Tan1 Tan4}) {
    button "$t.color$i", -text=>$color, -cursor=>'top_left_arrow',
            -command=>sub{$tw->configure(-bg=>$color)};
    $tw-> window ('create', 'end', -window=>"$t.color$i", -padx=>3, -pady=>2);
    $i++;
}
$tw-> tag ('add', "buttons", "$t.default", "end");


sub textWindOn {
    my $w = shift;
    my $t = "$w.f.text";
    eval{destroy "$w.scroll2"};
    scrollbar "$w.scroll2", -orient=>'horizontal', -command=>"$t xview";
    tkpack "$w.scroll2", -after=>"$w.buttons", qw/-side bottom -fill x/;
    widget($t)->configure(-xscrollcommand=>"$w.scroll2 set", -wrap=>'none');
}

sub textWindOff {
    my $w = shift;
    my $t = "$w.f.text";
    eval{destroy "$w.scroll2"};
    widget($t)->configure(-xscrollcommand=>'', -wrap=>'word');
}

sub textWindPlot ($) {
    my $t = shift;
    my $tw = widget($t);
    my $c = "$t.c";
    if (winfo('exists', $c)) {
	return;
    }
    my $cw = canvas $c, -relief=>'sunken', -width=>450, -height=>300, -cursor=>'top_left_arrow';

    my $font = 'Helvetica 18';

    $cw-> create (qw/line 100 250 400 250 -width 2/);
    $cw-> create (qw/line 100 250 100 50 -width 2/);
    $cw-> create (qw/text 225 20/, -text=>"A Simple Plot", -font=>$font, -fill=>'brown');
    
    for ($i=0; $i <= 10; $i++) {
	my $x = 100 + ($i*30);
	$cw-> create ('line', $x, 250, $x, 245, -width=>2);
	$cw-> create ('text', $x, 254, -text => 10*$i, -anchor=>'n', -font=>$font);
    }
    for ($i=0; $i <= 5; $i++) {
        my $y = 250 - ($i*40);
	$cw-> create ('line', 100, $y, 105, $y, -width=>2);
	$cw-> create ('text', 96, $y, -text=>($i*50).".0", -anchor=>'e', -font=>$font);
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
    while (index($tw->get ('plot'), " \t\n") >= 0) {
	$tw ->delete ('plot');
    }
    $tw-> insert ('plot', "\n");
    $tw-> window ('create', 'plot', -window=>$c);
    $tw-> tag ('add', 'center', 'plot');
    $tw-> insert ('plot', "\n");
}

my %embPlot;
$embPlot{lastX} = 0;
$embPlot{lastY} = 0;

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

sub embPlotMove {
    my $w = shift;
    my $tw = widget($w);
    my ($x,$y) = (Tcl::Ev('x'),Tcl::Ev('y'));
    $tw->move('selected', $x-$embPlot{lastX}, $y-$embPlot{lastY});
    $embPlot{lastX} = $x;
    $embPlot{lastY} = $y;
}

sub textWindDel {
    my $w = shift;
    my $t = "$w.f.text";
    my $tw = widget("$t");
    if (winfo ('exists', "$t.c")) {
	$tw->delete("$t.c");
        while (index($tw->get ('plot'), " \t\n") >= 0) {
            $tw-> delete ('plot');
	}
	$tw->insert('plot', "  ");
    }
}

sub embDefBg {
    my $tw = widget(shift);
    $tw->configure(-background=> [$tw->configure('-background')]->[3]);
}

