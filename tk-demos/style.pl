# style.tcl --
#
# This demonstration script creates a text widget that illustrates the
# various display styles that may be set for tags.
#
# RCS: @(#) $Id: style.tcl,v 1.2 1998/09/14 18:23:30 stanton Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.style';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Text Demonstration - Display Styles");
wm('iconname', $w, "style");
positionWindow($w);

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

my $tw = text "$w.text", -yscrollcommand=>"$w.scroll set", -setgrid=>'true',
	-width=>70, -height=>32, -wrap=>'word';
scrollbar "$w.scroll", -command=>"$w.text yview";
tkpack "$w.scroll", -side=>'right', -fill=>'y';
tkpack "$w.text", -expand=>'yes', -fill=>'both';

sub nonl ($) {local $_=shift; s/\n/ /g;$_}

# Set up display styles

$tw->tag('configure', 'bold', -font=>'Courier 12 bold italic');
$tw->tag('configure', 'big', -font=>'Courier 14 bold');
$tw->tag('configure', 'verybig', -font=>'Helvetica 24 bold');
if ($interp->Eval("winfo depth $w.text") > 1) {
    $tw->tag('configure', 'color1', -background=>'#a0b7ce');
    $tw->tag('configure', 'color2', -foreground=>'red');
    $tw->tag('configure', 'raised', -relief=>'raised', -borderwidth=>1);
    $tw->tag('configure', 'sunken', -relief=>'sunken', -borderwidth=>1);
} else {
    $tw->tag('configure', 'color1', -background=>'black', -foreground=>'white');
    $tw->tag('configure', 'color2', -background=>'black', -foreground=>'white');
    $tw->tag('configure', 'raised', -background=>'white', -relief=>'raised',
           -borderwidth=>1);
    $tw->tag('configure', 'sunken', -background=>'white', -relief=>'sunken',
           -borderwidth=>1);
}
$tw->tag('configure', 'bgstipple', -background=>'black', -borderwidth=>0,
	-bgstipple=>'gray12');
$tw->tag('configure', 'fgstipple', -fgstipple=>'gray50');
$tw->tag('configure', 'underline', -underline=>'on');
$tw->tag('configure', 'overstrike', -overstrike=>'on');
$tw->tag('configure', 'right', -justify=>'right');
$tw->tag('configure', 'center', -justify=>'center');
$tw->tag('configure', 'super', -offset=>'4p', -font=>'Courier 10');
$tw->tag('configure', 'sub', -offset=>'-2p', -font=>'Courier 10');
$tw->tag('configure', 'margins', -lmargin1=>'12m', -lmargin2=>'6m', -rmargin=>'10m');
$tw->tag('configure', 'spacing', -spacing1=>'10p', -spacing2=>'2p',
	-lmargin1=>'12m', -lmargin2=>'6m', -rmargin=>'10m');

$tw->insert('end', nonl 'Text widgets like this one allow you to display information in a
variety of styles.  Display styles are controlled using a mechanism
called ');
$tw->insert('end', 'tags', 'bold');
$tw->insert('end', nonl '. Tags are just textual names that you can apply to one
or more ranges of characters within a text widget.  You can configure
tags with various display styles.  If you do this, then the tagged
characters will be displayed with the styles you chose.  The
available display styles are:
');
$tw->insert('end', "\n1. Font.", 'big');
$tw->insert('end', "  You can choose any X font, ");
$tw->insert('end', 'large', 'verybig');
$tw->insert('end', " or ");
$tw->insert('end', "small.\n");
$tw->insert('end', "\n2. Color.", 'big');
$tw->insert('end', "  You can change either the ");
$tw->insert('end', 'background', 'color1');
$tw->insert('end', " or ");
$tw->insert('end', 'foreground', 'color2');
$tw->insert('end', "\ncolor, or ");
$tw->insert('end', 'both', 'color1 color2');
$tw->insert('end', ".\n");
$tw->insert('end', "\n3. Stippling.", 'big');
$tw->insert('end', "  You can cause either the ");
$tw->insert('end', 'background', 'bgstipple');
$tw->insert('end', " or ");
$tw->insert('end', 'foreground', 'fgstipple');
$tw->insert('end', '
information to be drawn with a stipple fill instead of a solid fill.
');
$tw->insert('end', "\n4. Underlining.", 'big');
$tw->insert('end', "  You can ");
$tw->insert('end', 'underline', 'underline');
$tw->insert('end', " ranges of text.\n");
$tw->insert('end', "\n5. Overstrikes.", 'big');
$tw->insert('end', "  You can ");
$tw->insert('end', "draw lines through", 'overstrike');
$tw->insert('end', " ranges of text.\n");
$tw->insert('end', "\n6. 3-D effects.", 'big');
$tw->insert('end', nonl '  You can arrange for the background to be drawn
with a border that makes characters appear either ');
$tw->insert('end', 'raised', 'raised');
$tw->insert('end', " or ");
$tw->insert('end', 'sunken', 'sunken');
$tw->insert('end', ".\n");
$tw->insert('end', "\n7. Justification.", 'big');
$tw->insert('end', " You can arrange for lines to be displayed\n");
$tw->insert('end', "left-justified,\n");
$tw->insert('end', "right-justified, or\n", 'right');
$tw->insert('end', "centered.\n", 'center');
$tw->insert('end', "\n8. Superscripts and subscripts.", 'big');
$tw->insert('end', " You can control the vertical\n");
$tw->insert('end', "position of text to generate superscript effects like 10");
$tw->insert('end', "n", 'super');
$tw->insert('end', " or\nsubscript effects like X");
$tw->insert('end', "i", 'sub');
$tw->insert('end', ".\n");
$tw->insert('end', "\n9. Margins.", 'big');
$tw->insert('end', " You can control the amount of extra space left");
$tw->insert('end', " on\neach side of the text:\n");
$tw->insert('end', "This paragraph is an example of the use of ", 'margins');
$tw->insert('end', "margins.  It consists of a single line of text ", 'margins');
$tw->insert('end', "that wraps around on the screen.  There are two ", 'margins');
$tw->insert('end', "separate left margin values, one for the first ", 'margins');
$tw->insert('end', "display line associated with the text line, ", 'margins');
$tw->insert('end', "and one for the subsequent display lines, which ", 'margins');
$tw->insert('end', "occur because of wrapping.  There is also a ", 'margins');
$tw->insert('end', "separate specification for the right margin, ", 'margins');
$tw->insert('end', "which is used to choose wrap points for lines.\n", 'margins');
$tw->insert('end', "\n10. Spacing.", 'big');
$tw->insert('end', " You can control the spacing of lines with three\n");
$tw->insert('end', "separate parameters.  \"Spacing1\" tells how much ");
$tw->insert('end', "extra space to leave\nabove a line, \"spacing3\" ");
$tw->insert('end', "tells how much space to leave below a line,\nand ");
$tw->insert('end', "if a text line wraps, \"spacing2\" tells how much ");
$tw->insert('end', "space to leave\nbetween the display lines that ");
$tw->insert('end', "make up the text line.\n");
$tw->insert('end', "These indented paragraphs illustrate how spacing ", 'spacing');
$tw->insert('end', "can be used.  Each paragraph is actually a ", 'spacing');
$tw->insert('end', "single line in the text widget, which is ", 'spacing');
$tw->insert('end', "word-wrapped by the widget.\n", 'spacing');
$tw->insert('end', "Spacing1 is set to 10 points for this text, ", 'spacing');
$tw->insert('end', "which results in relatively large gaps between ", 'spacing');
$tw->insert('end', "the paragraphs.  Spacing2 is set to 2 points, ", 'spacing');
$tw->insert('end', "which results in just a bit of extra space ", 'spacing');
$tw->insert('end', "within a pararaph.  Spacing3 isn't used ", 'spacing');
$tw->insert('end', "in this example.\n", 'spacing');
$tw->insert('end', "To see where the space is, select ranges of ", 'spacing');
$tw->insert('end', "text within these paragraphs.  The selection ", 'spacing');
$tw->insert('end', "highlight will cover the extra space.", 'spacing');

