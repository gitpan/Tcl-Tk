# widget --
# This script demonstrates the various widgets provided by Tk,
# along with many of the features of the Tk toolkit.  This file
# only contains code to generate the main window for the
# application, which invokes individual demonstrations.  The
# code for the actual demonstrations is contained in separate
# ".tcl" files is this directory, which are sourced by this script
# as needed.
#
# RCS: @(#) $Id: widget,v 1.9 2003/02/19 16:13:15 dkf Exp $

use strict;
use Tcl;
use Tcl::Tk qw(:widgets :misc);
use FindBin;

chdir $FindBin::RealBin;

my $interp = new Tcl::Tk;
$::interp=$interp;

wm('title', '.', "Widget Demonstration");
if ($interp->GetVar2('tcl_platform','platform') eq "unix") {
    # This won't work everywhere, but there's no other way in core Tk
    # at the moment to display a coloured icon.
    image(qw(create photo TclPowered -file),
          $interp->GetVar('tk_library') . "/images/logo64.gif");
    toplevel("._iconWindow");
    wm('iconwindow', '.', "._iconWindow");
    label("._iconWindow.i", -image=>"TclPowered")->pack;
    wm('iconname', '.', "tkWidgetDemo");
}
my %widgetFont = (
    main   => 'Helvetica 12',
    bold   => 'Helvetica 12 bold',
    title  => 'Helvetica 18 bold',
    status => 'Helvetica 10',
    vars   => 'Helvetica 14',
);

our $widgetDemo=1;
$::font = $widgetFont{main};

#----------------------------------------------------------------
# The code below create the main window, consisting of a menu bar
# and a text widget that explains how to use the program, plus lists
# all of the demos as hypertext items.
#----------------------------------------------------------------

my $menuBar = menu '.menuBar', -tearoff => 0;
$menuBar -> add ('cascade', -menu => '.menuBar.file', -label=> "File", -underline => 0);
menu '.menuBar.file', -tearoff => 0;


# On the Mac use the specia .apple menu for the about item
if (eval{$interp->Eval("tk windowingsystem")} eq "classic") {
    widget('.menuBar')->add('cascade', -menu=>".menuBar.apple");
    menu(".menuBar.apple", -tearoff=>0);
    widget('.menuBar.apple')->add('command', -label => "About...", -command => sub {&aboutBox});
} else {
  widget('.menuBar.file')->add('command', -label => "About...", -command => sub {&aboutBox},
	-underline => 0, -accelerator => "<F1>");
  widget('.menuBar.file')->add('sep');
}

widget('.menuBar.file')->add('command', -label => "Quit", -command => "exit", -underline => 0, -accelerator => "Meta-Q");

mainwindow->configure(-menu => '.menuBar');

$interp->call('bind', '.', '<F1>', sub{&aboutBox});

frame '.statusBar';
label '.statusBar.lab', -text => "   ", -relief=> 'sunken', -bd=>1, -font => $widgetFont{status}, -anchor=>'w';
label '.statusBar.foo', -width => 8, -relief => 'sunken', -bd => 1, -font => $widgetFont{status}, -anchor=>'w';
tkpack '.statusBar.lab', -side => 'left', -padx => 2, -expand => 'yes', -fill => 'both';
tkpack '.statusBar.foo', -side => 'left', -padx => 2;
tkpack '.statusBar', -side => 'bottom', -fill => 'x', -pady => 2;


frame '.textFrame';
scrollbar '.s', -orient => 'vertical', -command => '.t yview', -highlightthickness => 0, -takefocus => 1;
tkpack '.s', -in => '.textFrame', -side => 'right', -fill => 'y';
my $wtext = text '.t', -yscrollcommand=>'.s set', -wrap=>'word', -width=>70, -height=>30,
	-font=>$widgetFont{main},  -setgrid=>1,  -highlightthickness=>0,
	-padx=>4,  -pady=>2,  -takefocus=>0;
tkpack '.t', -in=>'.textFrame', -expand=>'y', -fill=>'both', -padx=>'1';
tkpack  '.textFrame', -expand=>'yes', -fill=>'both';

# Create a bunch of tags to use in the text widget, such as those for
# section titles and demo descriptions.  Also define the bindings for
# tags.

$wtext->tag('configure', 'title', -font => $widgetFont{title});
$wtext->tag('configure', 'bold',  -font => $widgetFont{bold});

# We put some "space" characters to the left and right of each demo description
# so that the descriptions are highlighted only when the mouse cursor
# is right over them (but not when the cursor is to their left or right)
#
$wtext->tag('configure', 'demospace', -lmargin1=>'1c', -lmargin2=>'1c');

if ($interp->Eval('winfo depth .') == 1) {
    $wtext->tag('configure', qw/demo -lmargin1 1c -lmargin2 1c -underline 1/);
    $wtext->tag('configure', qw/visited -lmargin1 1c -lmargin2 1c -underline 1/);
    $wtext->tag('configure', qw/hot -background black -foreground white/);
} else {
    $wtext->tag('configure', qw/demo -lmargin1 1c -lmargin2 1c -foreground blue -underline 1/);
    $wtext->tag('configure', qw/visited -lmargin1 1c -lmargin2 1c -foreground #303080 -underline 1/);
    $wtext->tag('configure', qw/hot -foreground red -underline 1/);
}

$wtext->tag('bind', 'demo', '<ButtonRelease-1>', \\'xy',sub {
     invoke($wtext->index('@'.Tcl::Ev('x').','.Tcl::Ev('y')));
});
my $lastLine = "";
$wtext->tag('bind', 'demo', '<Enter>', \\'xy',sub {
       $lastLine = $wtext->index('@'.Tcl::Ev('x').','.Tcl::Ev('y')." linestart");
       $wtext->tag('add', 'hot', "$lastLine +1 chars", "$lastLine lineend -1 chars");
       $wtext->config(-cursor=>'hand2');
       showStatus ($wtext->index('@'.Tcl::Ev('x').','.Tcl::Ev('y')));
     }
  );
$wtext->tag('bind', 'demo', '<Leave>', sub {
    $wtext->tag(qw/remove hot 1.0 end/);
    $wtext->config(-cursor=>'xterm');
    widget('.statusBar.lab')->config(-text=>"");
});
$wtext->tag('bind', 'demo', '<Motion>', \\'xy', sub {
    my $newLine = $wtext->index('@'.Tcl::Ev('x').','.Tcl::Ev('y')." linestart");
    if ($newLine ne $lastLine) {
        $wtext->tag(qw/remove hot 1.0 end/);
        $lastLine = $newLine;
        my @tags = grep {/^demo-/} $wtext->tag('names', '@'.Tcl::Ev('x').','.Tcl::Ev('y'));
        if ($#tags >= 0) {
               $wtext->tag('add', 'hot', "$lastLine +1 chars", "$lastLine lineend -1 chars");
        }
    }
    showStatus ($wtext->index('@'.Tcl::Ev('x').','.Tcl::Ev('y')));
});

# Create the text for the text widget.

sub addDemoSection ($@) {
    my ($title,@demos) = @_;
    $wtext->insert('end', "\n", '', $title, 'title', " \n ", 'demospace');
    my ($num,$i) = (0,0);
    for (; $i<=$#demos; $i+=2) {
        my ($name, $description) = ($demos[$i],$demos[$i+1]);
	$wtext->insert('end', ++$num.". $description.", "demo demo-$name");
	$wtext->insert('end', " \n ", 'demospace');
    }
}

$wtext->insert('end',  "Tk Widget Demonstrations\n", 'title');
$wtext->insert('end',  "\nThis application provides a front end for several short scripts that demonstrate what you can do with Tk widgets.  Each of the numbered lines below describes a demonstration;  you can click on it to invoke the demonstration.  Once the demonstration window appears, you can click the ", '', "See Code", 'bold', " button to see the Tcl/Tk code that created the demonstration.  If you wish, you can edit the code and click the ", '', "Rerun Demo", 'bold', " button in the code window to reinvoke the demonstration with the modified code.\n");
$wtext->insert('end',  "\nOnly items marked with '***' are implemented in this demo. All other features are also available, they're just not expressed properly.\n");

addDemoSection "Labels, buttons, checkbuttons, and radiobuttons", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    label	"(***) Labels (text and bitmaps)"
    unicodeout	"(***) Labels and UNICODE text"
    button	"(***) Buttons"
    check	"(***) Check-buttons (select any of a group)"
    radio	"(***) Radio-buttons (select one of a group)"
    puzzle	"(***) A 15-puzzle game made out of buttons"
    icon	"(***) Iconic buttons that use bitmaps"
    image1	"(***) Two labels displaying images"
    image2	"(***) A simple user interface for viewing images"
    labelframe	"(***) Labelled frames"
EOS
addDemoSection "Listboxes", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    states	"(***) The 50 states"
    colors	"(***) Colors: change the color scheme for the application"
    sayings	"(***) A collection of famous and infamous sayings"
EOS
addDemoSection "Entries and Spin-boxes", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    entry1	"(***) Entries without scrollbars"
    entry2	"(***) Entries with scrollbars"
    entry3	"(***) Validated entries and password fields"
    spin	"(***) Spin-boxes"
    form	"(***) Simple Rolodex-like form"
EOS
addDemoSection "Text", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    text	"(***) Basic editable text"
    style	"(***) Text display styles"
    bind	"(***)(1-3 impl.) Hypertext (tag bindings)"
    twind	"(***) A text widget with embedded windows"
    search	"(***) A search tool built with a text widget"
EOS
addDemoSection "Canvases", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    items	"(***)The canvas item types"
    plot	"(***) A simple 2-D plot"
    ctext	"(***)Text items in canvases"
    arrow	"An editor for arrowheads on canvas lines"
    ruler	"A ruler with adjustable tab stops"
    floor	"A building floor plan"
    cscroll	"A simple scrollable canvas"
EOS
addDemoSection "Scales", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    hscale	"Horizontal scale"
    vscale	"Vertical scale"
EOS
addDemoSection "Paned Windows", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    paned1	"Horizontal paned window"
    paned2	"Vertical paned window"
EOS
addDemoSection "Menus", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    menu	"Menus and cascades (sub-menus)"
    menubu	"Menu-buttons"
EOS
addDemoSection "Common Dialogs", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    msgbox	"Message boxes"
    filebox	"File selection dialog"
    clrpick	"Color picker"
EOS
addDemoSection "Miscellaneous", <<EOS=~/^\s*(\S+)\s+"(.*?)"\n/gm;
    bitmap	"The built-in bitmaps"
    dialog1	"A dialog box with a local grab"
    dialog2	"A dialog box with a global grab"
EOS

$wtext->configure(-state=>'disabled');
focus '.s';


# positionWindow --
# This procedure is invoked by most of the demos to position a
# new demo window.
#
# Arguments:
# w -		The name of the window to position.

sub positionWindow ($) {
    wm('geometry', shift, '+300+300');
}

# showVars --
# Displays the values of one or more variables in a window, and
# updates the display whenever any of the variables changes.
#
# Arguments:
# w -		Name of new window to create for display.
# args -	Any number of names of variables.

$interp->Eval(<<'EOS');
proc showVars {w args} {
    global widgetFont
    catch {destroy $w}
    toplevel $w
    wm title $w "Variable values"
    label $w.title -text "Variable values:" -width 20 -anchor center \
	    -font {Helvetica 14}
	    #$widgetFont(vars)
    pack $w.title -side top -fill x
    set len 1
    foreach i $args {
	if {[string length $i] > $len} {
	    set len [string length $i]
	}
    }
    foreach i $args {
	frame $w.$i
	label $w.$i.name -text "$i: " -width [expr $len + 2] -anchor w
	label $w.$i.value -textvar $i -anchor w
	pack $w.$i.name -side left
	pack $w.$i.value -side left -expand 1 -fill x
	pack $w.$i -side top -anchor w -fill x
    }
    button $w.ok -text OK -command "destroy $w" -default active
    bind $w <Return> "tkButtonInvoke $w.ok"
    pack $w.ok -side bottom -pady 2
}
EOS

# invoke --
# This procedure is called when the user clicks on a demo description.
# It is responsible for invoking the demonstration.
#
# Arguments:
# index -	The index of the character that the user clicked on.

sub invoke ($) {
    my $index = shift;
    my @tags = grep {/^demo-/} $wtext->tag('names', $index);
    if ($#tags < 0) {
	return;
    }
    my $cursor = $wtext->cget('-cursor');
    $wtext->configure(-cursor=>'watch');
    update;
    my $demo = substr($tags[0],5);
    if (-e "$demo.pl") {
        do "$demo.pl"; ## TODO must create new independent thread?
	if ($@) {
	    $interp->call('tk_messageBox', -icon => 'info', -type => 'ok', -title => "error", -message =>"error in $demo.pl:\n[[$@]]");
	}
    }
    else {
        $interp->call('tk_messageBox', -icon => 'info', -type => 'ok', -title => "TODO", -message =>"invoke: uplevel [list source $demo.tcl]");
    }
    update;
    $wtext->configure(-cursor=>$cursor);

    $wtext->tag('add', 'visited', "$index linestart +1 chars", "$index lineend -1 chars");
}

# showStatus --
#
#	Show the name of the demo program in the status bar. This procedure
#	is called when the user moves the cursor over a demo description.
#
sub showStatus ($) {
    my $index = shift;
    my ($newcursor, $cursor);
    $cursor = $wtext->cget('-cursor');
    my @tags = grep {/^demo-/} $wtext->tag('names', $index);
    if ($#tags < 0) {
	widget('.statusBar.lab')->config(-text=>" ");
	$newcursor = 'xterm';
    } else {
	my $demo = substr($tags[0],5);
	widget('.statusBar.lab')->config(-text=>"Run the \"".$demo."\" sample program");
	$newcursor = 'hand2';
    }
    if ($cursor eq $newcursor) {
       $wtext->config(-cursor=>$newcursor);
    }
}

# showCode --
# This procedure creates a toplevel window that displays the code for
# a demonstration and allows it to be edited and reinvoked.
#
# Arguments:
# w -		The name of the demonstration's window, which can be
#		used to derive the name of the file containing its code.

# Yes, entire subroutine in TCL, and it works!
# And this is just that!
$interp->Eval(<<'EOS');
proc showCode w {
    global tk_library
    set file [string range $w 1 end].pl
    if ![winfo exists .code] {
	toplevel .code
	frame .code.buttons
	pack .code.buttons -side bottom -fill x
	button .code.buttons.dismiss -text Dismiss \
            -default active -command "destroy .code"
	button .code.buttons.rerun -text "Rerun Demo" -command {
	    eval [.code.text get 1.0 end]
	}
	pack .code.buttons.dismiss .code.buttons.rerun -side left \
 	    -expand 1 -pady 2
	frame .code.frame
	pack  .code.frame -expand yes -fill both -padx 1 -pady 1
	text .code.text -height 40 -wrap word\
	    -xscrollcommand ".code.xscroll set" \
	    -yscrollcommand ".code.yscroll set" \
	    -setgrid 1 -highlightthickness 0 -pady 2 -padx 3
	scrollbar .code.xscroll -command ".code.text xview" \
	    -highlightthickness 0 -orient horizontal
	scrollbar .code.yscroll -command ".code.text yview" \
	    -highlightthickness 0 -orient vertical

	grid .code.text -in .code.frame -padx 1 -pady 1 \
	    -row 0 -column 0 -rowspan 1 -columnspan 1 -sticky news
	grid .code.yscroll -in .code.frame -padx 1 -pady 1 \
	    -row 0 -column 1 -rowspan 1 -columnspan 1 -sticky news
#	grid .code.xscroll -in .code.frame -padx 1 -pady 1 \
#	    -row 1 -column 0 -rowspan 1 -columnspan 1 -sticky news
	grid rowconfig    .code.frame 0 -weight 1 -minsize 0
	grid columnconfig .code.frame 0 -weight 1 -minsize 0
    } else {
	wm deiconify .code
	raise .code
    }
    wm title .code "Demo code: $file"
    wm iconname .code $file
    set id [open $file]
    .code.text delete 1.0 end
    .code.text insert 1.0 [read $id]
    .code.text mark set insert 1.0
    close $id
}
EOS

# aboutBox --
#
#	Pops up a message box with an "about" message
#
sub aboutBox {
    $interp->call('tk_messageBox', -icon => 'info', -type => 'ok', -title => "About Widget Demo", -message =>
"Tk widget demonstration

Copyright (c) 1996-1997 Sun Microsystems, Inc.

Copyright (c) 1997-2000 Ajuba Solutions, Inc.

Copyright (c) 2001-2002 Donal K. Fellows")
}

MainLoop;

# Local Variables:
# mode: tcl
# End:

