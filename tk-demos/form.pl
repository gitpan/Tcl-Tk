# form.tcl --
#
# This demonstration script creates a simple form with a bunch
# of entry widgets.
#
# RCS: @(#) $Id: form.tcl,v 1.2 1998/09/14 18:23:28 stanton Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.form';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Form Demonstration");
wm('iconname', $w, "form");
positionWindow($w);
$interp->label("$w.msg", -font=>$font, -wraplength=>'5i', -justify=>'left', -text=>"This window contains a simple form where you can type in the various entries and use tabs to move circularly between the entries.")
  ->pack(-side=>'top');


$interp->frame("$w.buttons")
  ->pack("$w.buttons", qw/-side bottom -fill x -pady 2m/);
$interp->button("$w.buttons.dismiss", -text=>"Dismiss", -command=>"destroy $w");
$interp->button("$w.buttons.code", -text=>"See Code", -command=>"showCode $w");
$interp->pack("$w.buttons.dismiss", "$w.buttons.code", -side=>"left", -expand=>1);

foreach my $i (qw{f1 f2 f3 f4 f5}) {
    frame "$w.$i", -bd=>2;
    entry "$w.$i.entry", -relief=>'sunken', -width=>40;
    label "$w.$i.label";
    tkpack "$w.$i.entry", -side=>'right';
    tkpack "$w.$i.label", -side=>'left';
}
widget("$w.f1.label")->config(qw/-text Name:/);
widget("$w.f2.label")->config(qw/-text Address:/);
widget("$w.f5.label")->config(qw/-text Phone:/);
tkpack("$w.msg", "$w.f1", "$w.f2", "$w.f3", "$w.f4", "$w.f5", qw/-side top -fill x/);
tkbind($w, "<Return>", "destroy $w");
$interp->focus("$w.f1.entry");
