# image2.tcl --
#
# This demonstration script creates a simple collection of widgets
# that allow you to select and view images in a Tk label.
#
# RCS: @(#) $Id: image2.pl,v 1.2 2004/03/22 23:59:57 hobbs2 Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}


# loadDir --
# This procedure reloads the directory listbox from the directory
# named in the demo's entry.
#
# Arguments:
# w -			Name of the toplevel window of the demo.

my $dirName = './images';
sub loadDir {
    my $w = shift;

    widget("$w.f.list")->delete(0, 'end');
    opendir DIR, $dirName;
    foreach (grep {-f "$dirName/$_"} sort readdir DIR) {
        /([^\\\/]+)$/;
	widget("$w.f.list")->insert('end', $_);
    }
}

# selectAndLoadDir --
# This procedure pops up a dialog to ask for a directory to load into
# the listobx and (if the user presses OK) reloads the directory
# listbox from the directory named in the demo's entry.
#
# Arguments:
# w -			Name of the toplevel window of the demo.

sub selectAndLoadDir {
    my $w = shift;
    my $dir = $interp->call("tk_chooseDirectory", -initialdir=>$dirName, -parent=>$w, -mustexist=>1);
    if ($dir ne '') {
	$dirName = $dir;
	loadDir($w);
    }
}

# loadImage --
# Given the name of the toplevel window of the demo and the mouse
# position, extracts the directory entry under the mouse and loads
# that file into a photo image for display.
#
# Arguments:
# w -			Name of the toplevel window of the demo.
# x, y-			Mouse position within the listbox.

sub loadImage {
    my ($w,$x,$y) = @_;

    my $file = "$dirName/". widget("$w.f.list")->get("\@$x,$y");
    return unless -e $file;
    widget("image2a")->configure(-file=>$file);
}

my $w = '.image2';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Image Demonstration #2");
wm('iconname', $w, "Image2");
positionWindow($w);

$interp->label("$w.msg", -font=>$font, -wraplength=>'4i', -justify=>'left', -text=>"This demonstration allows you to view images using a Tk \"photo\" image.  First type a directory name in the listbox, then type Return to load the directory into the listbox.  Then double-click on a file name in the listbox to see that image.")
  ->pack(-side=>'top');

$interp->frame("$w.buttons")
  ->pack("$w.buttons", qw/-side bottom -fill x -pady 2m/);
$interp->button("$w.buttons.dismiss", -text=>"Dismiss", -command=>"destroy $w");
$interp->button("$w.buttons.code", -text=>"See Code", -command=>"showCode $w");
$interp->pack("$w.buttons.dismiss", "$w.buttons.code", -side=>"left", -expand=>1);

frame "$w.mid";
tkpack "$w.mid", -fill=>'both', -expand=>1;

labelframe "$w.dir", -text=>"Directory:";
entry "$w.dir.e", -width=>30, -textvariable=>\$dirName;
button "$w.dir.b", -pady=>0, -padx=>'2m', -text=>"Select Dir.",
	-command=>sub{selectAndLoadDir($w)};
tkbind "$w.dir.e", "<Return>", sub{loadDir($w)};
tkpack "$w.dir.e", qw/-side left -fill both -padx 2m     -pady 2m -expand true/;
tkpack("$w.dir.b", qw/-side left -fill y    -pady 2m/, -padx=>'0 2m');
labelframe("$w.f", -text=>"File:", qw/-padx 2m -pady 2m/);

listbox "$w.f.list", -width=>20, -height=>10, -yscrollcommand=>"$w.f.scroll set";
scrollbar "$w.f.scroll", -command=>"$w.f.list yview";
tkpack "$w.f.list", "$w.f.scroll", qw/-side left -fill y -expand 1/;
widget("$w.f.list")->insert(0, qw/earth.gif earthris.gif teapot.ppm/);
tkbind("$w.f.list", "<Double-1>", \\"xy",sub{loadImage($w,Tcl::Ev('x'),Tcl::Ev('y'))});

#catch {image delete image2a}
image('create', 'photo', 'image2a');
labelframe("$w.image", -text=>"Image:");
label("$w.image.image", -image=>"image2a");
tkpack("$w.image.image", qw/-padx 2m -pady 2m/);

grid("$w.dir", '-', qw/-sticky ew -padx 1m -pady 1m -in/, "$w.mid");
grid("$w.f",   "$w.image", qw/-sticky nw -padx 1m -pady 1m -in/, "$w.mid");
grid("columnconfigure", "$w.mid", 1, -weight=>1);

