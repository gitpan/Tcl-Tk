# states.tcl --
#
# This demonstration script creates a listbox widget that displays
# the names of the 50 states in the United States of America.
#
# RCS: @(#) $Id: states.pl,v 1.2 2004/03/22 23:59:57 hobbs2 Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.states';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Listbox Demonstration (50 states)");
wm('iconname', $w, "states");
positionWindow($w);

label "$w.msg", -font=>$font, -wraplength=>'4i', -justify=>'left', -text=>"A listbox containing the 50 states is displayed below, along with a scrollbar.  You can scan the list either using the scrollbar or by scanning.  To scan, press button 2 in the widget and drag up or down.";
tkpack "$w.msg", -side=>'top';

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

frame "$w.frame", qw/-borderwidth .5c/;
tkpack "$w.frame", qw/-side top -expand yes -fill y/;

scrollbar "$w.frame.scroll", -command=>"$w.frame.list yview";
listbox "$w.frame.list", -yscroll=>"$w.frame.scroll set", qw/-setgrid 1 -height 12/;
tkpack "$w.frame.scroll", qw/-side right -fill y/;
tkpack "$w.frame.list", qw/-side left -expand 1 -fill both/;

widget("$w.frame.list")->insert(0, map {local $_=$_;s/_/ /g;$_}
  qw/Alabama Alaska Arizona Arkansas California
    Colorado Connecticut Delaware Florida Georgia Hawaii Idaho Illinois
    Indiana Iowa Kansas Kentucky Louisiana Maine Maryland
    Massachusetts Michigan Minnesota Mississippi Missouri
    Montana Nebraska Nevada New_Hampshire New_Jersey New_Mexico
    New_York North_Carolina North_Dakota
    Ohio Oklahoma Oregon Pennsylvania Rhode_Island
    South_Carolina South_Dakota
    Tennessee Texas Utah Vermont Virginia Washington
    West_Virginia Wisconsin Wyoming/);
