# image1.tcl --
#
# This demonstration script displays two image widgets.
#
# RCS: @(#) $Id: image1.tcl,v 1.2 1998/09/14 18:23:28 stanton Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.image1';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Image Demonstration #1");
wm('iconname', $w, "Image1");
positionWindow($w);

$interp->label("$w.msg", -font=>$font, -wraplength=>'4i', -justify=>'left', -text=>"This demonstration displays two images, each in a separate label widget.")
  ->pack(-side=>'top');

$interp->frame("$w.buttons")
  ->pack("$w.buttons", qw/-side bottom -fill x -pady 2m/);
$interp->button("$w.buttons.dismiss", -text=>"Dismiss", -command=>"destroy $w");
$interp->button("$w.buttons.code", -text=>"See Code", -command=>"showCode $w");
$interp->pack("$w.buttons.dismiss", "$w.buttons.code", -side=>"left", -expand=>1);


#catch {image delete image1a}
image('create', 'photo', 'image1a', -file=>'./images/earth.gif');
label("$w.l1", -image=>'image1a', -bd=>1, -relief=>'sunken');

#catch {image delete image1b}
image('create', 'photo', 'image1b',
  -file=>'./images/earthris.gif');
label("$w.l2", qw/-image image1b -bd 1 -relief sunken/);

tkpack("$w.l1", "$w.l2", qw/-side top -padx .5m -pady .5m/);
