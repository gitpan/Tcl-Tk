# unicodeout.tcl --
#
# This demonstration script shows how you can produce output (in label
# widgets) using many different alphabets.
#
# RCS: @(#) $Id: unicodeout.tcl,v 1.2 2003/02/21 13:05:06 dkf Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.unicodeout';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Unicode Label Demonstration");
wm('iconname', $w, "unicodeout");
positionWindow($w);

label "$w.msg", -font=>$::font, -justify=>'left', -text => <<'EOS';
This is a sample of Tk's support for languages that use
non-Western character sets.  However, what you will actually see
below depends largely on what character sets you have installed,
and what you see for characters that are not present varies greatly
between platforms as well.  The strings are written in Tcl using
UNICODE characters using the \x{XXXX} escape so as to do so in a
portable fashion.
EOS
tkpack "$w.msg", -side=>'top';

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

label "$w.wait", -text=>"Please wait while loading fonts...",
	-font=>'Helvetica 12 italic';
tkpack "$w.wait";
frame "$w.f";
tkpack ("$w.f", -expand=>1, -fill=>'both', -padx=>'2m', -pady=>'1m');
$interp->call('grid','columnconfigure', "$w.f", 1, -weight=>1);

my $i=0;
sub addSample ($$$) {
    my ($w, $language, @rest) = @_;
    my $sample = join "", @rest;
    my $j = ++$i;
    label "$w.f.l$j", -font=>$::font, -text=>"$language:", -anchor=>'nw', -pady=>0;
    label "$w.f.s$j", -font=>$::font, -text=>$sample, -anchor=>'nw', -width=>'30', -pady=>0;
    $interp->call('grid',"$w.f.l$j", "$w.f.s$j", -sticky=>'ew', -pady=>0);
    $interp->call('grid','configure',"$w.f.l$j", -padx=>'1m');
}

# Processing when some characters are missing might take a while, so make
# sure we're displaying something in the meantime...

my $oldCursor = widget($w)->cget('-cursor');
widget($w)->conf(-cursor=>'watch');
update;

addSample $w, 'Arabic',
	 "\x{FE94}\x{FEF4}\x{FE91}\x{FEAE}\x{FECC}\x{FEDF}\x{FE8D}\x{FE94}" .
	 "\x{FEE4}\x{FEE0}\x{FEDC}\x{FEDF}\x{FE8D}";
addSample $w, "Trad. Chinese", "\x{4E2D}\x{570B}\x{7684}\x{6F22}\x{5B57}";
addSample $w, "Simpl. Chinese", "\x{6C49}\x{8BED}";
addSample $w, 'Greek',
         "\x{0395}\x{03BB}\x{03BB}\x{03B7}\x{03BD}\x{03B9}\x{03BA}\x{03AE} " .
	 "\x{03B3}\x{03BB}\x{03CE}\x{03C3}\x{03C3}\x{03B1}";
addSample $w, 'Hebrew', 
	 "\x{05DD}\x{05D9}\x{05DC}\x{05E9}\x{05D5}\x{05E8}\x{05D9} " .
	 "\x{05DC}\x{05D9}\x{05D0}\x{05E8}\x{05E9}\x{05D9}";
addSample $w, 'Japanese', 
	 "\x{65E5}\x{672C}\x{8A9E}\x{306E}\x{3072}\x{3089}\x{304C}\x{306A}, " .
	 "\x{6F22}\x{5B57}\x{3068}\x{30AB}\x{30BF}\x{30AB}\x{30CA}";
addSample $w, 'Korean', "\x{B300}\x{D55C}\x{BBFC}\x{AD6D}\x{C758} \x{D55C}\x{AE00}";
addSample $w, 'Russian', 
	"\x{0420}\x{0443}\x{0441}\x{0441}\x{043A}\x{0438}\x{0439} \x{044F}\x{0437}\x{044B}\x{043A}";

# We're done processing, so change things back to normal running...
$interp->call('destroy', "$w.wait");
widget($w)->conf(-cursor=>$oldCursor);

