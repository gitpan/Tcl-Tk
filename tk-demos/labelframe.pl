# labelframe.tcl --
#
# This demonstration script creates a toplevel window containing
# several labelframe widgets.
#
# RCS: @(#) $Id: labelframe.tcl,v 1.2 2001/10/30 11:21:50 dkf Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.labelframe';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Labelframe Demonstration");
wm('iconname', $w, "labelframe");
positionWindow($w);

# Some information

label "$w.msg", -font=>$font, -wraplength=>'4i', -justify=>'left', -text=>"Labelframes are used to group related widgets together.  The label may be either plain text or another widget.";
tkpack "$w.msg", -side=>'top';

# The bottom buttons

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

# Demo area

frame "$w.f";
tkpack "$w.f", qw/-side bottom -fill both -expand 1/;
$w = "$w.f";

# A group of radiobuttons in a labelframe

labelframe "$w.f", -text=>"Value", -padx=>2, -pady=>2;
grid "$w.f", qw/-row 0 -column 0 -pady 2m -padx 2m/;

my ($lfdummy,$lfdummy2);
foreach my $value (qw{1 2 3 4}) {
    radiobutton "$w.f.b$value", -text=>"This is value $value",
            -variable=>\$lfdummy, -value=>$value;
    tkpack "$w.f.b$value", qw/-side top -fill x -pady 2/;
}


# Using a label window to control a group of options.

sub lfEnableButtons ($) {
    my $w = shift;
    foreach my $child ($interp->Eval("winfo children $w")) {
        next if $child eq "$w.cb";
	my $wchild = widget($child);
        if ($lfdummy2) {
            $wchild->configure qw/-state normal/;
        } else {
            $wchild->configure qw/-state disabled/;
        }
    }
}

labelframe "$w.f2", -pady=>2, -padx=>2;
checkbutton "$w.f2.cb", -text=>"Use this option.", -variable=>\$lfdummy2,
        -command=>sub{lfEnableButtons "$w.f2"}, -padx=>0;

widget("$w.f2")->configure(-labelwidget=>"$w.f2.cb");
grid "$w.f2", qw/-row 0 -column 1 -pady 2m -padx 2m/;

my $t=0;
foreach my $str (qw{Option1 Option2 Option3}) {
    checkbutton "$w.f2.b$t", -text=>$str;
    tkpack "$w.f2.b$t", qw/-side top -fill x -pady 2/;
    $t++;
}
lfEnableButtons "$w.f2";

grid 'columnconfigure', $w, '0 1', -weight=>1;

