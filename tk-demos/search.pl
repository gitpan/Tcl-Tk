# search.tcl --
#
# This demonstration script creates a collection of widgets that
# allow you to load a file into a text widget, then perform searches
# on that file.
#
# RCS: @(#) $Id: search.tcl,v 1.2 1998/09/14 18:23:30 stanton Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

# textLoadFile --
# This procedure below loads a file into a text widget, discarding
# the previous contents of the widget. Tags for the old widget are
# not affected, however.
#
# Arguments:
# w -		The window into which to load the file.  Must be a
#		text widget.
# file -	The name of the file to load.  Must be readable.

sub textLoadFile {
    my ($w, $file) = @_;
    open my $fh, "<$file";
    $w->delete('1.0', 'end');
    local $_;
    while (<$fh>) {
	$w->insert('end', $_);
    }
}

# textSearch --
# Search for all instances of a given string in a text widget and
# apply a given tag to each instance found.
#
# Arguments:
# w -		The window in which to search.  Must be a text widget.
# string -	The string to search for.  The search is done using
#		exact matching only;  no special characters.
# tag -		Tag to apply to each instance of a matching string.

sub textSearch {
    my ($w, $string, $tag) = @_;
    $w->tag('remove', 'search', '1.0', 'end');
    if ($string eq "") {
	return 1;
    }
    my $cur = '1.0';
    my $length=0;
    while (1) {
	$cur = $w->search(-count=>\$length, $string, $cur, 'end');
	if ($cur eq "") {
	    last;
	}
	$length||=0;
	$w->tag('add', $tag, $cur, "$cur + $length char");
	$cur = $w->index("$cur + $length char");
    }
    1;
}

# textToggle --
# This procedure is invoked repeatedly to invoke two commands at
# periodic intervals.  It normally reschedules itself after each
# execution but if an error occurs (e.g. because the window was
# deleted) then it doesn't reschedule itself.
#
# Arguments:
# cmd1 -	Command to execute when procedure is called.
# sleep1 -	Ms to sleep after executing cmd1 before executing cmd2.
# cmd2 -	Command to execute in the *next* invocation of this
#		procedure.
# sleep2 -	Ms to sleep after executing cmd2 before executing cmd1 again.

sub textToggle {
    my ($cmd1, $sleep1, $cmd2, $sleep2) = @_;
    eval {
	$cmd1->();
	after $sleep1, sub {textToggle($cmd2, $sleep2, $cmd1, $sleep1)};
    };
}

my $w = '.search';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Text Demonstration - Search and Highlight");
wm('iconname', $w, "search");
positionWindow($w);

frame("$w.buttons")
  ->pack("$w.buttons", qw/-side bottom -fill x -pady 2m/);
button("$w.buttons.dismiss", -text=>"Dismiss", -command=>"destroy $w");
button("$w.buttons.code", -text=>"See Code", -command=>"showCode $w");
tkpack("$w.buttons.dismiss", "$w.buttons.code", -side=>"left", -expand=>1);

my $fileName = "";
my $searchString = "";
my $tw;

frame "$w.file";
label "$w.file.label", -text=>"File name:", -width=>13, -anchor=>'w';
entry "$w.file.entry", -width=>40, -textvariable=>\$fileName;
button "$w.file.button", -text=>"Load File",
	-command=>sub{"textLoadFile $w.text \$fileName"};
tkpack "$w.file.label", "$w.file.entry", -side=>'left';
tkpack "$w.file.button", -side=>'left', -pady=>5, -padx=>10;
tkbind "$w.file.entry", "<Return>",
    sub {textLoadFile("$w.text", \$fileName);
    focus "$w.string.entry";
  };

focus "$w.file.entry";

frame "$w.string";
label "$w.string.label", -text=>"Search string:", -width=>13, -anchor=>'w';
entry "$w.string.entry", -width=>40, -textvariable=>\$searchString;
button "$w.string.button", -text=>"Highlight",
	-command=>sub{textSearch($tw, $searchString, "search")};
tkpack "$w.string.label", "$w.string.entry", -side=>'left';
tkpack "$w.string.button", -side=>'left', -pady=>5, -padx=>10;
tkbind "$w.string.entry", "<Return>", sub{textSearch($tw, $searchString, "search");};

$tw = text "$w.text", -yscrollcommand=>"$w.scroll set", -setgrid=>"true";
scrollbar "$w.scroll", -command=>"$w.text yview";
tkpack "$w.file", "$w.string", -side=>"top", -fill=>"x";
tkpack "$w.scroll", -side=>"right", -fill=>"y";
tkpack "$w.text", -expand=>"yes", -fill=>"both";

# Set up display styles for text highlighting.

if ($interp->Eval("winfo depth $w") > 1) {
    textToggle(sub{$tw->tag('configure', 'search', -background=>'#ce5555',
	   -foreground=>'white')}, 800, sub{$tw->tag('configure',
	    'search', -background=>'', -foreground=>'')}, 200);
} else {
    textToggle(sub{$tw->tag('configure', 'search', -background=>'black',
	   -foreground=>'white')}, 800, sub{$tw->tag('configure',
	    'search', -background=>'', -foreground=>'')}, 200);
}
$tw->insert('1.0',
'This window demonstrates how to use the tagging facilities in text
widgets to implement a searching mechanism.  First, type a file name
in the top entry, then type <Return> or click on "Load File".  Then
type a string in the lower entry and type <Return> or click on
"Load File".  This will cause all of the instances of the string to
be tagged with the tag "search", and it will arrange for the tag\'s
display attributes to change to make all of the strings blink.');
widget("$w.text")->mark('set', 'insert', '0.0');

