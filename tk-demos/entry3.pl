# entry2.tcl --
#
# This demonstration script creates several entry widgets whose
# permitted input is constrained in some way.  It also shows off a
# password entry.
#
# RCS: @(#) $Id$

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.entry3';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Constrained Entry Demonstration");
wm('iconname', $w, "entry3");
positionWindow($w);
$interp->label("$w.msg", -font=>$font, -wraplength=>'5i', -justify=>'left', -text=>"Four different entries are displayed below.  You can add characters by pointing, clicking and typing, though each is constrained in what it will accept.  The first only accepts integers or the empty string (checking when focus leaves it) and will flash to indicate any problem.  The second only accepts strings with fewer than ten characters and sounds the bell when an attempt to go over the limit is made.  The third accepts US phone numbers, mapping letters to their digit equivalent and sounding the bell on encountering an illegal character or if trying to type over a character that is not a digit.  The fourth is a password field that accepts up to eight characters (silently ignoring further ones), and displaying them as asterisk characters.")
  ->pack(-side=>'top');



$interp->frame("$w.buttons")
  ->pack("$w.buttons", qw/-side bottom -fill x -pady 2m/);
$interp->button("$w.buttons.dismiss", -text=>"Dismiss", -command=>"destroy $w");
$interp->button("$w.buttons.code", -text=>"See Code", -command=>"showCode $w");
$interp->pack("$w.buttons.dismiss", "$w.buttons.code", -side=>"left", -expand=>1);


# focusAndFlash --
# Error handler for entry widgets that forces the focus onto the
# widget and makes the widget flash by exchanging the foreground and
# background colours at intervals of 200ms (i.e. at approximately
# 2.5Hz).
#
# Arguments:
# W -		Name of entry widget to flash
# fg -		Initial foreground colour
# bg -		Initial background colour
# count -	Counter to control the number of times flashed

$interp->Eval(<<'EOS');
proc focusAndFlash {W fg bg {count 9}} {
    focus -force $W
    if {$count<1} {
	$W configure -foreground $fg -background $bg
    } else {
	if {$count%2} {
	    $W configure -foreground $bg -background $fg
	} else {
	    $W configure -foreground $fg -background $bg
	}
	after 200 [list focusAndFlash $W $fg $bg [expr {$count-1}]]
    }
}
EOS

labelframe("$w.l1", -text=>"Integer Entry");
entry("$w.l1.e", -validate=>"focus", -vcmd=>"string is integer %P");
widget("$w.l1.e")->configure(-invalidcommand=>
	"focusAndFlash %W [$w.l1.e cget -fg] [$w.l1.e cget -bg]");
widget("$w.l1.e")->pack(qw/-fill x -expand 1 -padx 1m -pady 1m/);

labelframe("$w.l2", -text=>"Length-Constrained Entry");
entry("$w.l2.e", -validate=>'key', -invcmd=>'bell', -vcmd=>"expr {[string length %P]<10}")
  ->pack(qw/-fill x -expand 1 -padx 1m -pady 1m/);

### PHONE NUMBER ENTRY ###
# Note that the source to this is quite a bit longer as the behaviour
# demonstrated is a lot more ambitious than with the others.

# Initial content for the third entry widget
my $entry3content = "1-(000)-000-0000";
# Mapping from alphabetic characters to numbers.  This is probably
# wrong, but it is the only mapping I have; the UK doesn't really go
# for associating letters with digits for some reason.
my %phoneNumberMap;
my %vt = qw(abc 2 def 3 ghi 4 jkl 5 mno 6 pqrs 7 tuv 8 wxyz 9);
for (keys %vt) {
    for my $s (split '', $_) {
        $phoneNumberMap{uc($s)} = $vt{$_};
    }
}

# validatePhoneChange --
# Checks that the replacement (mapped to a digit) of the given
# character in an entry widget at the given position will leave a
# valid phone number in the widget.
#
# W -	  The entry widget to validate
# vmode - The widget's validation mode
# idx -	  The index where replacement is to occur
# char -  The character (or string, though that will always be
#	  refused) to be overwritten at that point.

sub validatePhoneChange {
    my ($W, $vmode, $idx, $char) = @_;
    my $w = widget($W);
    return 1 if $idx == -1;
    $interp->Eval("after idle [list $W configure -validate $vmode -invcmd bell]");
    0 and     $interp->after('idle', # FIX-ME BUG! Why this crashes?
      sub{$w->configure(-validate=>$vmode,-invcmd=>'bell')}
    );
    if (
	!($idx<3 || $idx==6 || $idx==7 || $idx==11 || $idx>15) &&
	($char=~/^[\da-z]$/i)
      )  {
	$w->delete($idx);
	$w->insert($idx, $phoneNumberMap{uc($char)}||$char);
        $interp->Eval("after idle [list phoneSkipRight $W -1]");
	return 1;
    }
    return 0;
}

# phoneSkipLeft --
# Skip over fixed characters in a phone-number string when moving left.
#
# Arguments:
# W -	The entry widget containing the phone-number.

sub phoneSkipLeft {
    my $W = shift;
    my $w = widget($W);
    my $idx = $w->index('insert');
    if ($idx == 8) {
	# Skip back two extra characters
	$w->icursor($idx-2);
    } elsif ($idx == 7 || $idx == 12) {
	# Skip back one extra character
	$w->icursor($idx-1);
    } elsif ($idx <= 3) {
	# Can't move any further
	$interp->bell;
	return -code=>'break';
    }
}

# phoneSkipRight --
# Skip over fixed characters in a phone-number string when moving right.
#
# Arguments:
# W -	The entry widget containing the phone-number.
# add - Offset to add to index before calculation (used by validation.)

sub phoneSkipRight {
    my $W = shift;
    my $w = widget($W);
    my $add = shift||0;
    my $idx = $w->index('insert');
    if ($idx+$add == 5) {
	# Skip forward two extra characters
	$w->icursor($idx+2);
    } elsif ($idx+$add == 6 || $idx+$add == 10) {
	# Skip forward one extra character
	$w->icursor($idx+1);
    } elsif ($idx+$add == 15 && !$add) {
	# Can't move any further
        $interp->bell;
	return -code=>'break';
    }
}
$interp->create_tcl_sub(sub{phoneSkipRight(@_[3..$#_])},'',"phoneSkipRight");

labelframe("$w.l3", -text=>"US Phone-Number Entry");
entry("$w.l3.e", -validate=>'key',  -invcmd=>'bell',  -textvariable=>\$entry3content,
  -vcmd=>\\"WviS",sub{
      validatePhoneChange(Tcl::Ev('W'),Tcl::Ev('v'),Tcl::Ev('i'),Tcl::Ev('S'))
  });
# Click to focus goes to the first editable character...
$interp->bind("$w.l3.e", "<FocusIn>", '
    if {"%d" ne "NotifyAncestor"} {
	%W icursor 3
	after idle {%W selection clear}
    }
');
$interp->bind("$w.l3.e", "<Left>",  \\"W",sub{phoneSkipLeft(Tcl::Ev('W'))});
$interp->bind("$w.l3.e", "<Right>", \\"W",sub{phoneSkipRight(Tcl::Ev('W'))});
tkpack("$w.l3.e", qw/-fill x -expand 1 -padx 1m -pady 1m/);

labelframe("$w.l4", -text=>"Password Entry");
entry("$w.l4.e", qw/-validate key -show "*" -vcmd/, 'expr {[string length %P]<=8}');
tkpack("$w.l4.e", qw/-fill x -expand 1 -padx 1m -pady 1m/);

frame "$w.mid";
lower "$w.mid";
grid("$w.l1", "$w.l2", -in=>"$w.mid", qw/-padx 3m -pady 1m -sticky ew/);
grid("$w.l3", "$w.l4", -in=>"$w.mid", qw/-padx 3m -pady 1m -sticky ew/);
grid("columnconfigure", "$w.mid", '0 1', -uniform=>1);
tkpack("$w.msg", qw/-side top/);
tkpack("$w.buttons", qw/-side bottom -fill x -pady 2m/);
tkpack("$w.mid", qw/-fill both -expand 1/);
