# bind.tcl --
#
# This demonstration script creates a text widget with bindings set
# up for hypertext-like effects.
#
# RCS: @(#) $Id: bind.pl,v 1.2 2004/03/22 23:59:57 hobbs2 Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.bind';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Text Demonstration - Tag Bindings");
wm('iconname', $w, "bind");
positionWindow($w);

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

my $tw = text "$w.text", -yscrollcommand=>"$w.scroll set", -setgrid=>'true',
	-width=>60, -height=>24, -wrap=>'word';
scrollbar "$w.scroll", -command=>"$w.text yview";
tkpack "$w.scroll", -side=>'right', -fill=>'y';
tkpack "$w.text", -expand=>'yes', -fill=>'both';

# Set up display styles.

my (@bold, @normal);
if ($interp->Eval("winfo depth $w.text") > 1) {
    @bold = qw/-background #43ce80 -relief raised -borderwidth 1/;
    @normal = (-background => '', -relief => 'flat');
} else {
    @bold = qw/-foreground white -background black/;
    @normal = (-foreground => '', -background => '');
}

# Add text to widget.

$tw->insert('0.0',
'The same tag mechanism that controls display styles in text widgets can also be used to associate Tcl commands with regions of text, so that mouse or keyboard actions on the text cause particular Tcl commands to be invoked.  For example, in the text below the descriptions of the canvas demonstrations have been tagged.  When you move the mouse over a demo description the description lights up, and when you press button 1 over a description then that particular demonstration is invoked.

');
$tw->insert('end',
'1. Samples of all the different types of items that can be created in canvas widgets.', 'd1');
$tw->insert('end', "\n\n");
$tw->insert('end',
'2. A simple two-dimensional plot that allows you to adjust the positions of the data points.', 'd2');
$tw->insert('end', "\n\n");
$tw->insert('end', 
'3. Anchoring and justification modes for text items.', 'd3');
$tw->insert('end', "\n\n");
$tw->insert('end',
'4. An editor for arrow-head shapes for line items.', 'd4');
$tw->insert('end', "\n\n");
$tw->insert('end', 
'5. A ruler with facilities for editing tab stops.', 'd5');
$tw->insert('end', "\n\n");
$tw->insert('end', 
'6. A grid that demonstrates how canvases can be scrolled.', 'd6');

# Create bindings for tags.

foreach my $tag (qw{d1 d2 d3 d4 d5 d6}) {
    $tw->tag('bind', $tag, '<Any-Enter>', sub{$tw->tag('configure', $tag, @bold)});
    $tw->tag('bind', $tag, '<Any-Leave>', sub{$tw->tag('configure', $tag, @normal)});
}
$tw->tag('bind','d1', '<1>', sub {do 'items.pl'});
$tw->tag('bind','d2', '<1>', sub {do 'plot.pl'});
$tw->tag('bind','d3', '<1>', sub {do 'ctext.pl'});
$tw->tag('bind','d4', '<1>', sub {do 'arrow.pl'});
$tw->tag('bind','d5', '<1>', sub {do 'ruler.pl'});
$tw->tag('bind','d6', '<1>', sub {do 'cscroll.pl'});

$tw->mark('set', 'insert', '0.0');
$tw->configure(-state=>'disabled');

