package Tcl::Tk;

use strict;
use Tcl;
use Exporter;
use vars qw(@ISA @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter Tcl);

$Tcl::Tk::VERSION = '0.84';

# For users that want to ensure full debugging from initial use call,
# including the checks for other Tk modules loading following Tcl::Tk
# loading, add the following code *after* 'use Tcl::Tk':
#
# BEGIN { $Tcl::Tk::DEBUG = 1; }
#
$Tcl::Tk::DEBUG ||= 0;
sub DEBUG {
    # Allow for optional debug level and message to be passed in.
    # If level is passed in, return true only if debugging is at
    # that level.
    # If message is passed in, output that message if the level
    # is appropriate (with any extra args passed to output).
    my $lvl = shift;
    return $Tcl::Tk::DEBUG unless defined $lvl;
    my $msg = shift;
    if (defined($msg) && ($Tcl::Tk::DEBUG >= $lvl)) { print STDERR $msg, @_; }
    return ($Tcl::Tk::DEBUG >= $lvl);
}

if (DEBUG()) {
    # The gestapo throw warnings whenever Perl/Tk modules are requested.
    # It also hijacks such requests and returns an empty module in its
    # place.
    unshift @INC, \&tk_gestapo;
}

=head1 NAME

Tcl::Tk - Extension module for Perl giving access to Tk via the Tcl extension

=head1 SYNOPSIS

    use Tcl::Tk qw(:widgets);
    $interp = new Tcl::Tk;
    label(".l", -text => "Hello world");
    $interp->pack(".l");
    MainLoop;

Or    

    use Tcl::Tk;
    $interp = new Tcl::Tk;
    $interp->label(".l", -text => "Hello world")->pack;
    $btn = $interp->button(".btn", -text => "test", -command => sub {
      $btn->configure(-text=>"[". $btn->cget('-text')."]");
    })->pack;
    $interp->MainLoop;

Or even perl/Tk compatible way:

    use Tcl::Tk qw(:perlTk);
    $mw = MainWindow->new;
    $mw->Label(-text => "Hello world")->pack;
    $btn = $mw->Button(-text => "test", -command => sub {
      $btn->configure(-text=>"[". $btn->cget('-text')."]");
    })->pack;
    MainLoop;

=head1 DESCRIPTION

The Tcl::Tk submodule of the Tcl module gives access to the Tk library.
It does this by creating a Tcl interpreter object (using the Tcl extension)
and binding in all of Tk into the interpreter (in the same way that
B<wish> or other Tcl/Tk applications do).

Unlike perlTk extension (available on CPAN), where Tk+Tix are embedded
into extension, this module connects to existing TCL installation. Such
approach allows to work with most up-to-date TCL, and this automatically gives
Unicode and pure TCL widgets available to application along with any widgets
existing in TCL installation. As an example, Windows user have possibility to
use ActiveX widgets provided by Tcl extension named "OpTcl", so to provide
native Windows widgets.

Please see and try to run demo scripts 'demo.pl', 'demo-w-tix.pl' and
'widgets.pl' in 'demo' directory of source tarball.

=head2 Access to the Tcl and Tcl::Tk extensions

To get access to the Tcl and Tcl::Tk extensions, put the commands
near the top of your program.

    use Tcl;
    use Tcl::Tk;

Another (and better) way is to use perlTk compatibility mode by writing:

    use Tcl::Tk qw(:perlTk);

=head2 Creating a Tcl interpreter for Tk

To create a Tcl interpreter initialised for Tk, use

    $i = new Tcl::Tk (DISPLAY, NAME, SYNC);

All arguments are optional. This creates a Tcl interpreter object $i,
and creates a main toplevel window. The window is created on display
DISPLAY (defaulting to the display named in the DISPLAY environment
variable) with name NAME (defaulting to the name of the Perl program,
i.e. the contents of Perl variable $0). If the SYNC argument is present
and true then an I<XSynchronize()> call is done ensuring that X events
are processed synchronously (and thus slowly). This is there for
completeness and is only very occasionally useful for debugging errant
X clients (usually at a much lower level than Tk users will want).

=head2 Entering the main event loop

The Perl method call

    $i->MainLoop;

on the Tcl::Tk interpreter object enters the Tk event loop. You can
instead do C<Tcl::Tk::MainLoop> or C<Tcl::Tk-E<gt>MainLoop> if you prefer.
You can even do simply C<MainLoop> if you import it from Tcl::Tk in
the C<use> statement. Note that commands in the Tcl and Tcl::Tk
extensions closely follow the C interface names with leading Tcl_
or Tk_ removed.

=head2 Creating widgets

As a general rule, you need to consult TCL man pages to realize how to
use a widget, and after that invoke perl command that creates it properly.

If desired, widgets can be created and handled entirely by Tcl/Tk code
evaluated in the Tcl interpreter object $i (created above). However,
there is an additional way of creating widgets in the interpreter
directly from Perl. The names of the widgets (frame, toplevel, label etc.)
can be imported as direct commands from the Tcl::Tk extension. For example,
if you have imported the C<label> command then

    $l = label(".l", -text => "Hello world");

executes the command

    $i->call("label", ".l", "-text", "Hello world");

and hence gets Tcl to create a new label widget .l in your Tcl/Tk
interpreter. You can either import such commands one by one with,
for example,

    use Tcl::Tk qw(label canvas MainLoop winfo);

or you can use the pre-defined Exporter tags B<:widgets> and B<:misc>.
The B<:widgets> tag imports all the widget commands and the B<:misc>
tag imports all non-widget commands (see the next section).

When creating a widget, you must specify its path as first argument.
Widget path is a string starting with a dot and consisting of several
names separated by dots. These names are widget names that comprise
widget's hierarchy. As an example, if there exists a frame with a path
".fram" and you want to create a button on it and name it "butt" then
you should specify name ".fram.butt". Widget paths are refered in
miscellaneous widget operations, and geometry management is one of them.
Once again, see Tcl/Tk documentation to get details.

Widget creation command returns a Perl object that could be used further
for operations with widget. Perl method calls on the object are translated
into commands for the Tcl/Tk interpreter in a very simplistic fashion.
For example, the Perl command

    $l->configure(-background => "green");

is translated into the command

    $i->call("$l", "configure", "-background", "green");

for execution in your Tcl/Tk interpreter. Notice that it simply stringifies
the object to find the widget name. There is no automagic conversion that
happens: if you use a Tcl command which wants a widget pathname and you
only have an object returned by C<label()> (or C<button()> or C<entry()>
or whatever) then you must stringify it yourself.

When widgets are created they are stored internally and could be retreived
by C<widget()> command:

    widget(".fram.butt")->configure(-text=>"new text");
   
Please note that this method will return to you a widget object even if it was
not created within this module, and check will not be performed whether a 
widget with given path exists, despite of fact that checking for existence of
a widget is an easy task (invoking $interp->Eval("info commands $path") will
do this). Instead, you will receive perl object that will try to operate with
widget that has given path even if such path do not exists. 

This approach allows to transparently access widgets created somewhere inside
Tcl/Tk processing. So variable $btn in following code will behave exactly as
if it was created with "button" method:

    $interp->Eval(<<'EOS');
    frame .f
    button .f.b
    pack .f
    pack .f.b
    EOS
    my $btn = widget(".f.b");

Note, that C<widget()> method does not checks whether required 
widget actually exists in Tk. It just will return an object of type
Tcl::Tk::Widget and any method of this widget will just ask underlying Tcl/Tk
GUI system to do some action with a widget with a given path. In case it do
not actually exist you will receive an error from Tcl/Tk.

To check if a widget with a given path exists use C<Tcl::Tk::Exists($widget)>
subroutine. It queries Tcl/Tk for existance of said widget.

=head3 C<awidget> method

If you know there exists a method that creates widget in Tcl/Tk but it
is not implemented as a part of this module, use C<awidget> method (mnemonic
- "a widget" or "any widget"). C<awidget>, as method of interpreter object,
creates a subroutine inside Tcl::Tk package and this subroutine could be
invoked as a method for creating desired widget. After such call any 
interpreter can create required widget.

If there are more than one arguments provided to C<awidget> method, then
newly created method will be invoked with remaining arguments:

  $interp->awidget('tixTList');
  $interp->tixTList('.f.tlist');

does same thing as

  $interp->awidget('tixTList', '.f.tlist');

=head3 C<awidgets> method

C<awidgets> method takes a list consisting of widget names and calls
C<awidget> method for each of them.

Widget creation commands are methods of Tcl::Tk interpreter object. But if
you want to omit interpreter for brevity, then you could do it, and in this
case will be used interpreter that was created first. Following examples
demonstrate this:

    use Tcl::Tk qw(:widgets);
    $interp = new Tcl::Tk;

    # at next line interpreter object omited, but $interp is implicitly used
    label ".l", -text => "Hello world"; 
    
    widget(".l")->pack; # $interp will be called to pack ".l"
    
    # OO way, we explicitly use methods of $interp to create button
    $btn = $interp->button(".btn", -text => "test", -command => sub {
      $btn->configure(-text=>"[". $btn->cget('-text')."]");
    });
    $btn->pack; # another way to pack a widget

    $interp->MainLoop;

=head3 C<Button>, C<Frame>, C<Text>, C<Canvas> and similar methods

If you do not feel like to invent a widget path name when creating new widget,
Tcl::Tk can automatically generate them for you. Each widget has methods
to create another widgets.

Suppose you have 'frame' in variable $f with a widget path '.f'.
Then $btn=$f->Button(-command => sub{\&useful}); will create a button with a
path like '.f.b02' and will assign this button into $btn.

This syntax is very similar to syntax for perlTk. Some perlTk program even
will run unmodified with use of Tcl::Tk module.

=head3 C<widget_data> method

If you need to associate any data with particular widget, you can do this with 
C<widget_data> method of either interpreter or widget object itself. This method
returns same anonymous hash and it should be used to hold any keys/values pairs.

Examples:

  $interp->widget_data('.fram1.label2')->{var} = 'value';
  $label->widget_data()->{var} = 'value';

=head2 Non-widget Tk commands

For convenience, the non-widget Tk commands (such as C<destroy>,
C<focus>, C<wm>, C<winfo> and so on) are also available for export as
Perl commands and translate into into their Tcl equivalents for
execution in your Tk/Tcl interpreter. The names of the Perl commands
are the same as their Tcl equivalents.

=head2 BUGS

Currently work is in progress, and some features could change in future
versions.

=head2 AUTHORS

Malcolm Beattie, mbeattie@sable.ox.ac.uk
Vadim Konovalov, vkonovalov@peterstar.ru, 19 May 2003.
Jeff Hobbs, jeffh _a_ activestate com, February 2004.
Gisle Aas, gisle _a_ activestate . com, 14 Apr 2004.

=head2 COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

my @widgets = 
    qw(frame toplevel label labelframe button checkbutton radiobutton scale
       mainwindow message listbox scrollbar spinbox entry menu menubutton 
       canvas text panedwindow
       widget awidget awidgets
     );
my @misc = qw(MainLoop after destroy focus grab lower option place raise
              image font
	      selection tk grid tkwait update winfo wm);
my @perlTk = qw(MainLoop MainWindow tkinit update);

@EXPORT_OK = (@widgets, @misc, @perlTk);
%EXPORT_TAGS = (widgets => \@widgets, misc => \@misc, perlTk => \@perlTk);

## TODO -- module's private $tkinterp should go away!
my $tkinterp = undef;		# this gets defined when "new" is done

# Path to main window is '.'.  Be careful when concatenating other widget
# names that you don't end up with '..btn01', which is invalid.
my $mwpath = '.';
my $mainwindow = \$mwpath;

# Hash to keep track of all created widgets and related instance data
# Tcl::Tk will maintain PATH (Tk widget pathname) and INT (Tcl interp)
# and the user can create other info.
my %W = (
    INT => {},
    PATH => {},
    RPATH => {},
    DATA => {},
    MWID => {},
);
# few shortcuts for %W to be faster
my $Wint = $W{INT};
my $Wpath = $W{PATH};
my $Wdata = $W{DATA};

# hash to keep track on preloaded Tcl/Tk modules, such as Tix, BWidget
my %preloaded_tk; # (interpreter independent thing. is this right?)

#
sub new {
    my ($class, $name, $display, $sync) = @_;
    Carp::croak 'Usage: $interp = new Tcl::Tk([$name [, $display [, $sync]]])'
	if @_ > 4;
    my($i, $arg, @argv);

    if (defined($display)) {
	push(@argv, -display => $display);
    } else {
	$display = $ENV{DISPLAY} || '';
    }
    if (defined($name)) {
	push(@argv, -name => $name);
    } else {
	($name = $0) =~ s{.*/}{};
    }
    if (defined($sync)) {
	push(@argv, "-sync");
    } else {
	$sync = 0;
    }
    $i = new Tcl;
    bless $i, $class;
    $i->SetVar2("env", "DISPLAY", $display, Tcl::GLOBAL_ONLY);
    $i->SetVar("argv0", $0, Tcl::GLOBAL_ONLY);
    if (defined $::tcl_library) {
	# hack to redefine search path for TCL installation
	$i->SetVar('tcl_library',$::tcl_library);
    }
    push(@argv, "--", @ARGV) if scalar(@ARGV);
    $i->SetVar("argv", [@argv], Tcl::GLOBAL_ONLY);
    # argc is just the values after the --, if any.
    # The other args are consumed by Tk.
    $i->SetVar("argc", scalar(@ARGV), Tcl::GLOBAL_ONLY);
    $i->SetVar("tcl_interactive", 0, Tcl::GLOBAL_ONLY);
    $i->SUPER::Init();
    $i->need_tk('Tk');
    my $mwid;
    if (!defined($tkinterp)) {
	$mwid = $i->invoke('winfo','id','.');
	$W{PATH}->{$mwid} = '.';
	$W{INT}->{$mwid} = $i;
	$W{MWID}->{'.'} = $mwid;
	$mainwindow = \$mwid;
	bless($mainwindow, 'Tcl::Tk::Widget::MainWindow');
    }
    $i->call('trace', 'add', 'command', '.', 'delete',
	     sub { for (keys %W) {$W{$_}->{$mwid} = undef; }});
    $i->ResetResult();
    $Tcl::Tk::TK_VERSION = $i->GetVar("tk_version");
    # Only do this for DEBUG() ?
    $Tk::VERSION = $Tcl::Tk::TK_VERSION;
    $Tk::VERSION =~ s/^(\d)\.(\d)/${1}0$2/;
    DEBUG(1, "USING Tk $Tcl::Tk::TK_VERSION ($Tk::VERSION)\n");
    $tkinterp = $i;
    return $i;
}

sub tkinit {
    $tkinterp = Tcl::Tk->new(@_);
    $mainwindow;
}
sub MainWindow {
    $tkinterp = Tcl::Tk->new(@_);
    $mainwindow;
}

sub MainLoop {
    # This perl-based mainloop differs from Tk_MainLoop in that it
    # relies on the traced deletion of '.' instead of using the
    # Tk_GetNumMainWindows C API.
    # This could optionally be implemented with 'vwait' on a specially
    # named variable that gets set when '.' is destroyed.
    my $int = (ref $_[0]?shift:$tkinterp);
    my $mwid = $W{MWID}->{'.'};
    while (defined $Wpath->{$mwid}) {
	$int->DoOneEvent(0);
    }
}

sub declare_widget {
    my $int = shift;
    my $path = shift;
    # JH: This is all SOOO wrong, but works for the simple case.
    # Issues that need to be addressed:
    #  1. You can create multiple interpreters, each containing identical
    #     pathnames.  This var should be better scoped.
    #   VK: this is no longer true, as %W has reworked to base on window id
    #     and this window id is uniq within OS
    #  2. There is NO cleanup going on.  We should somehow detect widget
    #     destruction (trace add command delete ... in 8.4) and interp
    #     destruction to clean up package variables.
    #     At the moment, you can delete widgets, but this package never
    #     notices that they are no long valid.
    my $id = $path=~/^\./ ? $int->invoke('winfo','id',$path) : $path;
    my $w = bless(\$id, 'Tcl::Tk::Widget');
    $Wpath->{$id} = $path; # widget pathname
    $Wint->{$id}  = $int; # Tcl interpreter
    $W{RPATH}->{$path} = $w;
    # TODO find a better way to avoid repeated names
    return $w;
}
# widget_data return anonymous hash that could be used to hold any 
# user-specific data
sub widget_data {
    my $int = shift;
    my $path = shift;
    $Wdata->{$path} ||= {};
    return $Wdata->{$path};
}

sub frame($@) {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("frame", @_);
    return $int->declare_widget($path);
}
sub toplevel {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("toplevel", @_);
    return $int->declare_widget($path);
}
sub mainwindow {
    # this is a window with path '.'
    $mainwindow;
}
sub label {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("label", @_);
    return $int->declare_widget($path);
}
sub labelframe {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("labelframe", @_);
    return $int->declare_widget($path);
}
sub button {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("button", @_);
    return $int->declare_widget($path);
}
sub checkbutton {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("checkbutton", @_);
    return $int->declare_widget($path);
}
sub radiobutton {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("radiobutton", @_);
    return $int->declare_widget($path);
}
sub scale {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("scale", @_);
    return $int->declare_widget($path);
}
sub spinbox {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("spinbox", @_);
    return $int->declare_widget($path);
}
sub message {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("message", @_);
    return $int->declare_widget($path);
}
sub listbox {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("listbox", @_);
    return $int->declare_widget($path);
}
sub image {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("image", @_);
    return $int->declare_widget($path);
}
sub font {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("font", @_);
    return $int->declare_widget($path);
}
sub scrollbar {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("scrollbar", @_);
    return $int->declare_widget($path);
}
sub entry {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("entry", @_);
    return $int->declare_widget($path);
}
sub menu {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("menu", @_);
    return $int->declare_widget($path);
}
sub menubutton {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("menubutton", @_);
    return $int->declare_widget($path);
}
sub canvas {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("canvas", @_);
    return $int->declare_widget($path);
}
sub text {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("text", @_);
    return $int->declare_widget($path);
}
# subroutine awidget used to create [a]ny [widget]. Nothing complicated here,
# mainly needed for keeping track of this new widget and blessing it to right
# package
sub awidget {
    my $int = (ref $_[0]?shift:$tkinterp);
    my $wclass = shift;
    # Following is a suboptimal way of autoloading, there should exist a way
    # to Improve it.
    my $sub = sub {
        my $int = (ref $_[0]?shift:$tkinterp);
        my ($path) = $int->call($wclass, @_);
        return $int->declare_widget($path);
    };
    unless ($wclass=~/^\w+$/) {
	die "widget name '$wclass' contains not allowed characters";
    }
    # create appropriate method ...
    no strict 'refs';
    *{"Tcl::Tk::$wclass"} = $sub;
    # ... and call it (if required)
    if ($#_>-1) {
	return $sub->($int,@_);
    }
}
sub awidgets {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->awidget($_) for @_;
}
sub widget($@) {
    my $int = (ref $_[0]?shift:$tkinterp);
    my $wpath = shift;
    if (exists $W{RPATH}->{$wpath}) {
        return $W{RPATH}->{$wpath};
    }
    # We could ask Tcl about it by invoking
    # my @res = $int->Eval("winfo exists $wpath");
    # but we don't do it, as long as we allow any widget paths to
    # be used by user.
    my $w = $int->declare_widget($wpath);
    return $w;
}
sub Exists($) {
    my $wid = shift;
    return 0 unless defined($wid);
    if (ref($wid)=~/^Tcl::Tk::Widget\b/) {
        my $wp = $wid->path;
        return $wid->interp->icall('winfo','exists',$wp);
    }
    return $tkinterp->icall('winfo','exists',$wid);
}
# do this only when tk_gestapo on?
# In normal case Tcl::Tk::Exists should be used.
#*{Tk::Exists} = \&Tcl::Tk::Exists;

sub widgets {
    \%W;
}

sub after { 
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("after", @_) }
sub bell { 
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("bell", @_) }
sub bindtags {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("bindtags", @_) }
sub clipboard { 
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("clipboard", @_) }
sub destroy { 
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("destroy", @_) }
sub exit { 
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("exit", @_) }
sub fileevent {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("fileevent", @_) }
sub focus {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("focus", @_) }
sub grab {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("grab", @_) }
sub lower {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("lower", @_) }
sub option {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("option", @_) }
sub place {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("place", @_) }
sub raise {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("raise", @_) }
sub selection {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("selection", @_) }
sub tk {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("tk", @_) }
sub tkwait {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("tkwait", @_) }
sub update {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("update", @_) }
sub winfo {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("winfo", @_) }
sub wm {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("wm", @_) }
sub property {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("property", @_);
}

sub grid {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("grid", @_);
}
sub bind {
    my $int = shift;
    $int->call("bind", @_);
}
sub pack {
    my $int = shift;
    $int->call("pack", @_);
}

sub need_tk {
    my $int = shift;
    my $what = shift;
    my $cmd  = shift;

    $cmd = '' unless defined $cmd;
    return if $preloaded_tk{$what}{$cmd};

    DEBUG(1, "PKG REQUIRE $what ++ $cmd\n");
    if ($what eq 'pure-perl-Tk') {
        require Tcl::Tk::Widget;
    }
    elsif ($what eq 'ptk-Table') {
        require Tcl::Tk::Table;
    }
    else {
	# Only require the actual package once
	$int->icall("package", "require", $what)
	    unless keys %{$preloaded_tk{$what}};
	$int->Eval($cmd) if $cmd;
    }

    $preloaded_tk{$what}{$cmd}++;
}

sub tk_gestapo {
    # When placed first on the INC path, this will allow us to hijack
    # any requests for 'use Tk' and any Tk::* modules and replace them
    # with our own stuff.
    my ($coderef, $module) = @_;  # $coderef is to myself
    return undef unless $module =~ m!^Tk(/|\.pm$)!;

    my ($package, $callerfile, $callerline) = caller;

    my $fakefile;
    open(my $fh, '<', \$fakefile) || die "oops";

    $module =~ s!/!::!g;
    $module =~ s/\.pm$//;
    $fakefile = <<EOS;
package $module;
warn "### $callerfile:$callerline not really loading $module ###";
sub foo { 1; }
1;
EOS
    return $fh;
}
# subroutine findINC copied from perlTk/Tk.pm
sub findINC {
    my $file = join('/',@_);
    my $dir;
    $file  =~ s,::,/,g;
    foreach $dir (@INC) {
	my $path;
	return $path if (-e ($path = "$dir/$file"));
    }
    return undef;
}

##
## Switch to Widget namespace
##

package Tcl::Tk::Widget;

use overload
    '""' => \&path,
    'eq' => sub {my $self = shift; return $self->path eq shift},
    'ne' => sub {my $self = shift; return $self->path ne shift};

sub DEBUG { Tcl::Tk::DEBUG(@_); }	# do not let AUTOLOAD catch this method

sub iconimage {
    # this should set the wm iconimage/iconbitmap with an image
    warn "NYI: iconimage";
};

sub path {
    return $Wpath->{${$_[0]}};
}
# returns interpreter that is associated with widget
sub interp {
    unless (exists $Wint->{${$_[0]}}) {
	print caller;
	die "do not exist: ",${$_[0]};
    }
    return $Wint->{${$_[0]}};
}
# returns (and optionally creates) data hash assotiated with widget
sub widget_data {
    my $self = shift;
    return ($Wdata->{$self->path} || ($Wdata->{$self->path}={}));
}

#
# few geometry methods here
sub pack {
    my $self = shift;
    $self->interp->call("pack",$self,@_);
    $self;
}
sub grid {
    my $self = shift;
    $self->interp->call("grid",$self,@_);
    $self;
}
sub gridSlaves {
    # grid slaves returns widget names, so map them to their objects
    my $self = shift;
    my $int  = $self->interp;
    my @wids = $int->call("grid","slaves",$self,@_);
    map($int->widget($_), @wids);
}
sub place {
    my $self = shift;
    $self->interp->call("place",$self,@_);
    $self;
}
sub lower {
    my $self = shift;
    $self->interp->call("lower",$self,@_);
    $self;
}
# helper sub _bind_widget_helper inserts into subroutine callback
# widget as parameter
sub _bind_widget_helper {
    my $self = shift;
    my $sub = shift;
    if (ref($sub) eq 'ARRAY') {
	if ($#$sub>0) {
	    if (ref($sub->[1]) eq 'Tcl::Ev') {
		$sub = [$sub->[0],$sub->[1],$self,@$sub[2..$#$sub]];
	    }
	    else {
		$sub = [$sub->[0],$self,@$sub[1..$#$sub]];
	    }
	}
	else {
	    $sub = [$sub->[0], $self];
	}
	return $sub;
    }
    else {
	return sub{$sub->($self,@_)};
    }
}
sub bind {
    my $self = shift;
    # 'text' and 'canvas' binding could be different compared to common case
    # as long as Text uses 'tag bind' then we do not need to process it here
    if (ref($self) =~ /^Tcl::Tk::Widget::(?:Canvas|Text)$/) {
	if ($#_==2) {
	    my ($tag, $seq, $sub) = @_;
	    $sub = $self->_bind_widget_helper($sub);
	    $self->interp->call($self,'bind',$tag,$seq,$sub);
	}
	elsif ($#_==1 && ref($_[1]) =~ /^(?:ARRAY|CODE)$/) {
	    my ($seq, $sub) = @_;
	    $sub = $self->_bind_widget_helper($sub);
	    $self->interp->call($self,'bind',$seq,$sub);
	}
	else {
	    $self->interp->call($self,'bind',@_);
	}
    }
    elsif (ref($self) =~ /^Tcl::Tk::Widget::(?:Listbox)$/) {
	if ($#_=1 && ref($_[1]) =~ /^(?:ARRAY|CODE)$/) {
	    my ($seq, $sub) = @_;
	    $sub = $self->_bind_widget_helper($sub);
	    $self->interp->call('bind',$self->path,$seq,$sub);
	}
	else {
	    $self->interp->call('bind',$self->path,@_);
	}
    }
    else {
	if ($_[0] =~ /^</) {
	    # A sequence was specified - assume path from widget instance
	    $self->interp->call("bind",$self->path,@_);
	} else {
	    # Not a sequence as first arg - don't assume path
	    $self->interp->call("bind",@_);
	}
    }
}
sub tag {
    my ($self,$verb,$tag, @rest) = @_;
    if ($verb eq 'bind') {
	return $self->tagBind($tag,@rest);
    }
    $self->interp->call($self, 'tag', $verb, $tag, @rest);
}
sub tagBind {
    my ($self,$tag, $seq, $sub) = @_;
    # 'text'
    # following code needs only to insert widget as a first argument to 
    # subroutine
    $sub = $self->_bind_widget_helper($sub);
    $self->interp->call($self, 'tag', 'bind', $tag, $seq, $sub);
}

# TODO - creating package/method in package only when needed
# move to separate file?
create_method_in_widget_package ('Canvas', 
    raise => sub {
	my $self = shift;
	my $wp = $self->path;
	$self->interp->call($wp,'raise',@_);
    },
    CanvasBind => sub {
	my $self = shift;
	$self->bind('item',@_);
    },
    CanvasFocus => sub {
	my $self = shift;
	$self->interp->call($self->path,'focus',@_);
    },
);

sub form {
    my $self = shift;
    my $int = $self->interp;
    $int->need_tk("Tix");
    my @arg = @_;
    for (@arg) {
	if (ref && ref eq 'ARRAY') {
	    $_ = join ' ', map {
		  (ref && (ref =~ /^Tcl::Tk::Widget\b/))?
		    $_->path  # in this case there is form geometry relative
		              # to widget; substitute its path
		  :$_} @$_;
	    s/^& /&/;
	}
    }
    $int->call("tixForm",$self,@arg);
    $self;
}

# TODO -- these methods could be AUTOLOADed
sub focus {
    my $self = shift;
    my $wp = $self->path;
    $self->interp->call('focus',$wp,@_);
}
sub destroy {
    my $self = shift;
    my $wp = $self->path;
    $self->interp->call('destroy',$wp,@_);
}

# for compatibility (TODO -- more methods could be AUTOLOADed)
sub GeometryRequest {
    my $self = shift;
    my $wp = $self->path;
    my ($width,$height) = @_;
    $self->interp->call('wm','geometry',$wp,"=${width}x$height");
}
sub OnDestroy {
    my $self = shift;
    my $wp = $self->path;
    $self->interp->call('bind','<Destroy>',$wp,@_);
}
sub grab {
    my $self = shift;
    my $wp = $self->path;
    $self->interp->call('grab',$wp,@_);
}
sub grabRelease {
    my $self = shift;
    my $wp = $self->path;
    $self->interp->call('grab','release',$wp,@_);
}
sub packAdjust {
    # old name, becomes pack configure
    my $self = shift;
    my $wp = $self->path;
    $self->interp->call('pack','configure',$wp,@_);
}
sub optionGet {
    my $self = shift;
    my $wp = $self->path;
    $self->interp->call('option','get',$wp,@_);
}
sub raise {
    my $self = shift;
    my $wp = $self->path;
    $self->interp->call('raise',$wp,@_);
}

sub update {
    my $self = shift;
    $self->interp->update;
}
sub ItemStyle {
    my $self = shift;
    my $styl = shift;
    my $wp   = $self->path;
    my $int  = $self->interp;
    $int->need_tk('Tix');
    my %args = @_;
    $args{'-refwindow'} = $wp unless exists $args{'-refwindow'};
    $int->call('tixDisplayStyle', $styl, %args);
}
sub getOpenFile {
    my $self = shift;
    my %args = @_;
    $args{'-parent'} = $self->path unless defined $args{'-parent'};
    $self->interp->call('tk_getOpenFile', %args);
}
sub getSaveFile {
    my $self = shift;
    my %args = @_;
    $args{'-parent'} = $self->path unless defined $args{'-parent'};
    $self->interp->call('tk_getSaveFile', %args);
}
sub chooseDirectory {
    my $self = shift;
    my %args = @_;
    $args{'-parent'} = $self->path unless defined $args{'-parent'};
    $self->interp->call('tk_chooseDirectory', %args);
}
sub messageBox {
    my $self = shift;
    my %args = @_;
    $args{'-parent'} = $self->path unless defined $args{'-parent'};
    # messageBox should handle pTk's "YesNo" and return "Yes" in
    # addition to Tk's standard all-lc in/out.
    #$args{'-type'} = lc $args{'-type'} if defined $args{'-type'};
    $self->interp->call('tk_messageBox', %args);
}

# TODO all Busy subs
sub Busy {
    my $self = shift;
    print STDERR "Busy = TODO\n";
    $self;
}
sub Unbusy {
    my $self = shift;
    print STDERR "Unbusy = TODO\n";
    $self;
}

# subroutine Darken copied from perlTk/Widget.pm
# tkDarken --
# Given a color name, computes a new color value that darkens (or
# brightens) the given color by a given percent.
#
# Arguments:
# color - Name of starting color.
# perecent - Integer telling how much to brighten or darken as a
# percent: 50 means darken by 50%, 110 means brighten
# by 10%.
sub Darken
{
    my ($w,$color,$percent) = @_;
    my @l = $w->rgb($color);
    my $red = $l[0]/256;
    my $green = $l[1]/256;
    my $blue = $l[2]/256;
    $red = int($red*$percent/100);
    $red = 255 if ($red > 255);
    $green = int($green*$percent/100);
    $green = 255 if ($green > 255);
    $blue = int($blue*$percent/100);
    $blue = 255 if ($blue > 255);
    sprintf('#%02x%02x%02x',$red,$green,$blue);
}

sub PathName {
    my $wid = shift;
    return $wid->path;
}
sub Exists {
    my $wid = shift;
    my $wp = $wid->path;
    return $wid->interp->icall('winfo','exists',$wp);
}
sub toplevel {
    my $wid = shift;
    my $int = $wid->interp;
    my $tlp = $int->icall('winfo','toplevel',$wid->path);
    if ($tlp eq '.') {return $mainwindow}
    return $int->widget($tlp);
}
sub parent {
    my $wid = shift;
    my $int = $wid->interp;
    my $res = $int->icall('winfo','parent',$wid->path);
    if ($res eq '') {return ''}
    if ($res eq '.') {return $mainwindow}
    return $int->widget($res);
}

sub bell {
    my $self = shift;
    my $int = $self->interp;
    my $ret = $int->call('bell', @_);
}

# althought this is not the case, we'll think of object returned by 'after'
# as a widget.
sub after {
    my $self = shift;
    my $int = $self->interp;
    my $ret = $int->call('after', @_);
    return $int->declare_widget($ret);
}
sub cancel {
    my $self = shift;
    return $self->interp->call('after','cancel',$self);
}

#
# Getimage compatability routine
#

my %image_formats =
    (
     xpm => 'photo',
     gif => 'photo',
     ppm => 'photo',
     xbm => 'bitmap'
     );

sub Getimage {
    my $self = shift;
    my $name = shift;
    my $images;

    return $images->{$name} if $images->{$name};

    my $int = $self->interp;
    foreach my $ext (keys %image_formats) {
	my $path;
	foreach my $dir (@INC) {
	    $path = "$dir/Tk/$name.$ext";
	    last if -f $path;
	}
	next unless -f $path;
	DEBUG(2, "Getimage: FOUND IMAGE $path\n");
	if ($ext eq "xpm") {
	    $int->need_tk('img::xpm');
	}
	my @args = ('image', 'create', $image_formats{$ext}, -file => $path);
	if ($image_formats{$ext} ne "bitmap") {
	    push @args, -format => $ext;
	}
	$images->{$name} = $int->call(@args);
	return $images->{$name};
    }

    # Try built-in bitmaps from Tix
    #$images->{$name} = $w->Pixmap( -id => $name );
    #return $images->{$name};
    DEBUG(1, "Getimage: MISSING IMAGE $name\n");
    return;
}

#
# some class methods to provide same syntax as perlTk do
# In this case all widget names are autogenerated, and
# global interpreter instance $tkinterp is used
#

# global widget counter, only for autogenerated widget names.
my $gwcnt = '01'; 

sub w_uniq {
    my ($self, $type) = @_;
    # create unique widget id with path "$self.$type<uniqid>"
    if (!defined($type)) {
	my ($package, $callerfile, $callerline) = caller;
	warn "$callerfile:$callerline called w_uniq(@_)";
	$type = "unk";
    }
    my $wp = $self->path;
    # Ensure that we don't end up with '..btn01' as a widget name
    $wp = '' if $wp eq '.';
    my $h = $W{RPATH};
    $gwcnt++ while exists $h->{"$wp.$type$gwcnt"};
    return "$wp.$type$gwcnt";
}

# perlTk<->Tcl::Tk mapping in form [widget, wprefix, ?package?]
# These will be looked up 1st in AUTOLOAD
my %ptk2tcltk =
    (
     Button      => ['button', 'btn',],
     Checkbutton => ['checkbutton', 'cb',],
     Canvas      => ['canvas', 'can',],
     Entry       => ['entry', 'ent',],
     Frame       => ['frame', 'f',],
     LabelFrame  => ['labelframe', 'lf',],
     #LabFrame    => ['labelframe', 'lf',],
     Label       => ['label', 'lbl',],
     Listbox     => ['listbox', 'lb',],
     Message     => ['message', 'msg',],
     Menu        => ['menu', 'mnu',],
     Menubutton  => ['menubutton', 'mbtn',],
     Panedwindow => ['panedwindow', 'pw',],
     Bitmap	 => ['image', 'bmp',],
     Photo	 => ['image', 'pht',],
     Radiobutton => ['radiobutton', 'rb',],
     ROText	 => ['text', 'rotext',],
     Text        => ['text', 'text',],
     Scrollbar   => ['scrollbar','sb',],
     Scale       => ['scale','scl',],
     TextUndo    => ['text', 'utext',],
     Toplevel    => ['toplevel', 'top',],

     #Table       => ['*perlTk/Table',]
     Table       => ['table', 'tbl', 'Tktable'],

     BrowseEntry => ['ComboBox', 'combo', 'BWidget'],
     ComboBox    => ['ComboBox', 'combo', 'BWidget'],
     ListBox     => ['ListBox', 'lb', 'BWidget'],
     BWTree      => ['Tree', 'bwtree', 'BWidget'],
     ScrolledWindow => ['ScrolledWindow', 'sw', 'BWidget'],

     TileNoteBook => ['tile::notebook', 'tnb', 'tile'],

     Treectrl    => ['treectrl', 'treectrl', 'treectrl'],

     Balloon     => ['tixBalloon', 'bl', 'Tix'],
     DirTree     => ['tixDirTree', 'dirtr', 'Tix'],
     HList       => ['tixHList', 'hlist', 'Tix'],
     TList       => ['tixTList', 'tlist', 'Tix'],
     NoteBook    => ['tixNoteBook', 'nb', 'Tix'],
     );

# Mapping of pTk camelCase names to Tcl commands.
# These do not require the actual widget name.
# These will be looked up 2nd in AUTOLOAD
# $w->mapCommand(...) => @qwargs ...
my %ptk2tcltk_mapper =
    (
     "optionAdd"        => [ qw(option add) ],
     "font"             => [ qw(font) ],
     "fontCreate"       => [ qw(font create) ],
     "fontNames"        => [ qw(font names) ],
     "waitVariable"     => [ qw(vwait) ], # was tkwait variable
     "idletasks"        => [ qw(update idletasks) ],
     );

# wm or winfo subroutines, to be checked 4th in AUTOLOAD
# $w->wmcommand(...) => wm|winfo wmcommand $w ...
my %ptk2tcltk_wm =
    (
     "deiconify"     => 'wm',
     "geometry"      => 'wm', # note 'winfo geometry' isn't included
     "group"         => 'wm',
     "iconify"       => 'wm',
     "iconname"      => 'wm',
     "minsize"       => 'wm',
     "maxsize"       => 'wm',
     "protocol"      => 'wm',
     "resizable"     => 'wm',
     "stackorder"    => 'wm',
     "state"         => 'wm',
     "title"         => 'wm',
     "transient"     => 'wm',
     "withdraw"      => 'wm',
     ( 
	 # list of widget pTk methods mapped to 'winfo' Tcl/Tk methods
	 # following lines result in pairs  'method' => 'winfo'
	 map {$_=>'winfo'} qw(
	     atom atomname
	     cells children class colormapfull containing
	     depth
	     fpixels
	     height
	     id interps ismapped
	     manager
	     name
	     pathname pixels pointerx pointery
	     reqheight reqwidth  rgb  rootx rooty
	     screen screencells screendepth screenvisual
	     screenheight screenwidth screenmmheight screenmmwidth server
	     viewable visual visualid visualsavailable vrootheight vrootwidth
	     vrootx vrooty
	     width
	     x y
         ),
     )
     );

my $ptk_w_names = join '|', sort keys %ptk2tcltk;


#  create_ptk_widget_sub creates subroutine similar to following:
#sub Button {
#  my $self = shift; # this will be a parent widget for newer button
#  my $int = $self->interp;
#  my $w    = w_uniq($self, "btn");
#  # create 'button' widget with a unique path
#  return $int->button($w,@_);
#}
my %replace_options =
    (
     tixHList   => {separator=>'-separator'},
     ComboBox   => {-choices=>'-values'},
     table      => {-columns=>'-cols'},
     toplevel   => {-title=>sub{shift->title(@_)},OnDestroy=>sub{},-overanchor=>undef},
     labelframe => {-label=>'-text', -labelside => undef},
     );
my %pure_perl_tk = (); # hash to keep track of pure-perl widgets

sub create_ptk_widget_sub {
    my ($wtype) = @_;
    my ($ttktype,$wpref,$tpkg,$tcmd) = @{$ptk2tcltk{$wtype}};
    $wpref ||= lcfirst $wtype;

    if ($tpkg) { $tkinterp->need_tk($tpkg,$tcmd); }

    if ($ttktype =~ s/^\*perlTk\///) {
	# should create pure-perlTk widget and bind it to Tcl variable so that
	# anytime a method invoked it will be redirected to Perl
	return sub {
	  my $self = shift; # this will be a parent widget for newer widget
	  my $int = $self->interp;
          my $w    = w_uniq($self, $wpref); # create uniq pref's widget id
	  die "pure-perlTk widgets are not implemented";
	};
    }
    if (exists $replace_options{$ttktype}) {
	return sub {
	    my $self = shift; # this will be a parent widget for newer widget
	    my $int = $self->interp;
	    my $w    = w_uniq($self, $wpref); # create uniq pref's widget id
	    my %args = @_;
	    my @code_todo;
	    for (keys %{$replace_options{$ttktype}}) {
		if (defined($replace_options{$ttktype}->{$_})) {
		    if (exists $args{$_}) {
		        if (ref($replace_options{$ttktype}->{$_}) eq 'CODE') {
			    push @code_todo, [$replace_options{$ttktype}->{$_}, delete $args{$_}];
			}
			else {
			    $args{$replace_options{$ttktype}->{$_}} =
			        delete $args{$_};
			}
		    }
		} else {
		    delete $args{$_} if exists $args{$_};
		}
	    }
	    my $wid = $int->declare_widget($int->call($ttktype,$w,%args));
	    bless $wid, "Tcl::Tk::Widget::$wtype";
	    $_->[0]->($wid,$_->[1]) for @code_todo;
	    return $wid;
	};
    }
    return sub {
	my $self = shift; # this will be a parent widget for newer widget
	my $int  = $self->interp;
        my $w    = w_uniq($self, $wpref); # create uniq pref's widget id
	my $wid  = $int->declare_widget($int->call($ttktype,$w,@_));
	bless $wid, "Tcl::Tk::Widget::$wtype";
	return $wid;
    };
}
my %special_widget_abilities = ();
sub LabFrame {
    my $self = shift; # this will be a parent widget for newer labframe
    my $int  = $self->interp;
    my $w    = w_uniq($self, "lf"); # create uniq pref's widget id
    my $ttktype = "labelframe";
    my %args = @_;
    for (keys %{$replace_options{$ttktype}}) {
	if (defined($replace_options{$ttktype}->{$_})) {
	    $args{$replace_options{$ttktype}->{$_}} =
		delete $args{$_} if exists $args{$_};
	} else {
	    delete $args{$_} if exists $args{$_};
	}
    }
    my $lf = $int->declare_widget($int->call($ttktype, $w, %args));
    my $wtype = 'LabFrame';
    create_widget_package($wtype);
    create_method_in_widget_package($wtype,
	Subwidget => sub {
	    my $lf = shift;
	    DEBUG(1, "LabFrame $lf ignoring Subwidget(@_)\n");
	    return $lf;
	},
    );
    bless $lf, "Tcl::Tk::Widget::$wtype";
    return $lf;
}
sub ROText {
    # Read-only text
    # This just needs to intercept the programmatic insert/delete
    # and reenable the text widget for that duration.
    my $self = shift; # this will be a parent widget for newer ROText
    my $int  = $self->interp;
    my $w    = w_uniq($self, "rotext"); # create uniq pref's widget id
    my $text = $int->declare_widget($int->call('text', $w, @_));
    my $wtype = 'ROText';
    create_widget_package($wtype);
    create_method_in_widget_package($wtype,
	insert => sub {
	    my $wid = shift;
	    my $int = $self->interp;
	    $wid->configure(-state => "normal");
	    # avoid recursive call by going directly to interp
	    $int->call($wid, 'insert', @_);
	    $wid->configure(-state => "disabled");
	},
	delete => sub {
	    my $wid = shift;
	    my $int = $self->interp;
	    $wid->configure(-state => "normal");
	    # avoid recursive call by going directly to interp
	    $int->call($wid, 'delete', @_);
	    $wid->configure(-state => "disabled");
	}
    );
    $text->configure(-state => "disabled");
    bless $text, "Tcl::Tk::Widget::$wtype";
    return $text;
}

# menu compatibility
sub _process_menuitems;
sub _process_underline {
    # Suck out "~" which represents the char to underline
    my $args = shift;
    if (defined($args->{'-label'}) && $args->{'-label'} =~ /~/) {
	my $und = index($args->{'-label'}, '~');
	$args->{'-underline'} = $und;
	$args->{'-label'} =~ s/~//;
    }
};
# internal sub helper for menu
sub _addcascade {
    my $mnu = shift;
    my $mnup = $mnu->path;
    my $int = $mnu->interp;
    my $smnu = $mnu->Menu; # return unique widget id
    my %args = @_;
    my $tearoff = delete $args{'-tearoff'};
    if (defined($tearoff)) {
        $smnu->configure(-tearoff => $tearoff);
    }
    $args{'-menu'} = $smnu;
    my $mis = delete $args{'-menuitems'};
    _process_menuitems($int,$smnu,$mis);
    _process_underline(\%args);
    #$int->call("$mnu",'add','cascade', %args);
    $mnu->add('cascade',%args);
    return $smnu;
}
# internal helper sub to process perlTk's -menuitmes option
sub _process_menuitems {
    my ($int,$mnu,$mis) = @_;
    for (@$mis) {
	if (ref) {
	    my $label = $_->[1];
	    my %a = @$_[2..$#$_];
	    $a{'-state'} = delete $a{state} if exists $a{state};
	    $a{'-label'} = $label;
	    my $cmd = lc($_->[0]);
	    if ($cmd eq 'separator') {$int->call($mnu->path,'add','separator');}
	    elsif ($cmd eq 'cascade') {
		_process_underline(\%a);
	        _addcascade($mnu, %a);
	    }
	    else {
		$cmd=~s/^button$/command/;
		_process_underline(\%a);
	        $int->call($mnu->path,'add',$cmd, %a);
	    }
	}
	else {
	    if ($_ eq '-' or $_ eq '') {
		$int->call($mnu->path,'add','separator');
	    }
	    else {
		die "in menubutton: '$_' not implemented";
	    }
	}
    }
}
sub Menubutton {
    my $self = shift; # this will be a parent widget for newer menubutton
    my $int = $self->interp;
    my $w    = w_uniq($self, "mb"); # create uniq pref's widget id
    my %args = @_;
    my $mcnt = '01';
    my $mis = delete $args{'-menuitems'};
    my $tearoff = delete $args{'-tearoff'};
    $args{'-state'} = delete $args{state} if exists $args{state};

    create_widget_package('Menu');
    create_widget_package('Menubutton');
    create_method_in_widget_package('Menubutton',
	command=>sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    my %args = @_;
	    _process_underline(\%args);
	    $int->call("$wid.m",'add','command',%args);
	},
	checkbutton => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    $int->call("$wid.m",'add','checkbutton',@_);
	},
	radiobutton => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    $int->call("$wid.m",'add','radiobutton',@_);
	},
	separator => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    $int->call("$wid.m",'add','separator',@_);
	},
	menu => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    return $int->widget("$wid.m");
	},
	cget => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    if ($_[0] eq "-menu") {
		return $int->widget($int->invoke("$wid",'cget','-menu'));
	    } else {
		DEBUG(2, "CALL $wid cget @_\n");
		die "Finish cget implementation for Menubutton";
	    }
	});
    my $mnub = $int->menubutton($w, -menu => "$w.m", %args);
    my $mnu  = $int->menu("$w.m");
    bless $mnub, "Tcl::Tk::Widget::Menubutton";
    bless $mnu, "Tcl::Tk::Widget::Menu";
    _process_menuitems($int,$mnu,$mis);
    $int->update if DEBUG();
    if (defined($tearoff)) {
        $mnu->configure(-tearoff => $tearoff);
    }
    return $mnub;
}
sub Menu {
    my $self = shift; # this will be a parent widget for newer menu
    my $int  = $self->interp;
    my $w    = w_uniq($self, "menu"); # return unique widget id
    my %args = @_;

    my $mis         = delete $args{'-menuitems'};
    $args{'-state'} = delete $args{state} if exists $args{state};

    DEBUG(2, "MENU (@_), creating $w\n");

    create_widget_package('Menu');
    create_method_in_widget_package('Menu',
	command => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    my %args = @_;
	    _process_underline(\%args);
	    $int->call("$wid",'add','command',%args);
	},
	checkbutton => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    $int->call("$wid",'add','checkbutton',@_);
	},
	radiobutton => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    $int->call("$wid",'add','radiobutton',@_);
	},
	cascade => sub {
	    my $wid = shift;
	    _addcascade($wid, @_);
	},
	separator => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    $int->call("$wid",'add','separator',@_);
	},
	menu => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    return $int->widget("$wid");
	},
	cget => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    if ($_[0] eq "-menu") {
		return $int->widget("$wid");
	    } else {
		DEBUG(1, "CALL $wid cget @_\n");
		die "Finish cget implementation for Menu";
	    }
	},
	entryconfigure => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    my $label = shift;
	    $label =~ s/~//;
	    $int->call("$wid", 'entryconfigure', $label, @_);
	},
    );
    my $mnu = $int->menu($w, %args);
    $int->update if DEBUG();
    bless $mnu, "Tcl::Tk::Widget::Menu";
    _process_menuitems($int,$mnu,$mis);
    return $mnu;
}
# Balloon widget's method are in Tcl/Tk/Widget/Balloon.pm
sub Balloon {
    my $self = shift; # this will be a parent widget for newer balloon
    my $int = $self->interp;
    my $w    = w_uniq($self, "bln"); # return unique widget id
    $int->need_tk('Tix');
    my $bw = $int->declare_widget($int->call('tixBalloon', $w, @_));
    my $wtype = 'Balloon';
    require "Tcl/Tk/Widget/$wtype.pm";
    return bless $bw, "Tcl::Tk::Widget::$wtype";
}
sub NoteBook {
    my $self = shift; # this will be a parent widget for newer notebook
    my $int = $self->interp;
    my $w    = w_uniq($self, "nb"); # return unique widget id
    $int->need_tk('Tix');
    my %args = @_;
    delete $args{'-tabpady'};
    delete $args{'-inactivebackground'};
    my $bw = $int->declare_widget($int->call('tixNoteBook', $w, %args));
    my $wtype = 'NoteBook';
    create_widget_package($wtype);
    create_method_in_widget_package($wtype,
	add=>sub {
	    my $bw = shift;
	    my $int = $bw->interp;
	    my $wp = $int->call($bw,'add',@_);
	    my $ww = $int->declare_widget($wp);
	    return $ww;
	},
    );
    bless $bw, "Tcl::Tk::Widget::$wtype";
    return $bw;
}
sub DialogBox {
    # pTk DialogBox compat sub
    # XXX: This is not complete, needs to handle additional options
    my $self = shift; # this will be a parent widget for newer DialogBox
    my $int  = $self->interp;
    my $wn    = w_uniq($self, "dlgbox"); # return unique widget id
    my %args = @_;
    my $dlg  = $int->declare_widget($int->call('toplevel', $wn,
					       -class => "Dialog"));
    $dlg->withdraw();
    $dlg->title($args{'-title'} || "Dialog Box");
    my $topparent = $int->call('winfo', 'toplevel', $self);
    $dlg->transient($topparent);
    $dlg->group($topparent);
    my $bot  = $dlg->Frame();
    $bot->pack(-side => "bottom", -fill => "x", -expand => 0);
    my $btn;
    my $defbtn;
    foreach (reverse @{$args{'-buttons'}}) {
	$btn = $bot->Button(-text => $_,
			    -command => ['set', '::tk::Priv(button)', "$_"]);
	if ($args{'-default_button'} && $_ eq $args{'-default_button'}) {
	    $defbtn = $btn;
	    $btn->configure(-default => "active");
	    # Add <Return> binding to invoke the default button
	    $dlg->bind('<Return>', ["$btn", "invoke"]);
	}
	if ($^O eq "MSWin32") {
	    # should be done only on Tk >= 8.4
	    $btn->configure(-width => "-11");
	}
	$btn->pack(-side => "right", -padx => 4, -pady => 5);
    }
    # We need to create instance methods for dialogs to handle their
    # perl-side instance variables -popover and -default_button
    $dlg->widget_data->{'-popover'} = $args{'-popover'} || "cursor";
    $dlg->widget_data->{'-default'} = $defbtn;
    # Add Escape and Destroy bindings to trigger vwait
    # XXX Remove special hash items as well
    $dlg->bind('<Destroy>', 'set ::tk::Priv(button) {}');
    $dlg->bind('<Escape>', 'set ::tk::Priv(button) {}');
    my $wtype = 'DialogBox';
    create_widget_package($wtype);
    create_method_in_widget_package($wtype,
	add => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    my $wtype = shift;
	    my %args  = @_;
	    my $subw;
	    {
		no strict 'refs';
		$subw = &{"Tcl::Tk::Widget::$wtype"}($wid, %args);
	    }
	    $subw->pack(-side => "top", -fill => "x", -expand => 1);
	    return $subw;
	},
	Show => sub {
	    my $wid = shift;
	    my $int = $wid->interp;
	    my $grabtype = shift;
	    # Grab pertinent instance data
	    my $defbtn  = $wid->widget_data->{'-default'};
	    my $popover = $wid->widget_data->{'-popover'};

	    # ::tk::PlaceWindow is Tk 8.4+
	    if ($popover eq "cursor") {
		$int->call('::tk::PlaceWindow', $wid, 'pointer', 'center');
	    } elsif (Tcl::Tk::Exists($popover)) {
		$int->call('::tk::PlaceWindow', $wid, 'widget', $popover);
	    } else {
		$int->call('::tk::PlaceWindow', $wid);
	    }
	    $int->grab($wid);
	    $int->focus($defbtn) if $defbtn;
	    $int->call('vwait', '::tk::Priv(button)');
	    my $val = $int->GetVar2('::tk::Priv', 'button');
	    eval {
		# Window may have been destroyed
		$int->call('grab', 'release', $wid);
		$int->call('wm', 'withdraw', $wid);
	    };
	    return $val;
	},
	Hide => sub {
	    # This will trigger grab release and withdraw
	    $int->SetVar2('::tk::Priv', 'button', '');
	},
    );
    return bless $dlg, "Tcl::Tk::Widget::$wtype";
}
sub Dialog {DialogBox(@_)}
sub Photo {
    my $self = shift; # this will be a parent widget for newer Photo
    my $int = $self->interp;
    my $w    = w_uniq($self, "pht"); # return unique widget id
    # XXX Do we really want to require all of 'Img' here?  Perhaps the
    # XXX requirement on Img should be pushed to the user level, or only
    # XXX require those formats that Perl/Tk auto-supported (jpeg, ???)
    # VK how differents format should be differentiated? TBD
    #$int->need_tk('Img');
    my $bw = $int->declare_widget($int->call('image','create', 'photo', @_));
    create_widget_package('Photo');
    bless $bw, "Tcl::Tk::Widget::Photo";
    return $bw;
}
sub Bitmap {
    my $self = shift; # this will be a parent widget for newer Bitmap
    my $int = $self->interp;
    my $w    = w_uniq($self, "bmp"); # return unique widget id
    my $bw = $int->declare_widget($int->call('image','create', 'bitmap', @_));
    create_widget_package('Bitmap');
    bless $bw, "Tcl::Tk::Widget::Bitmap";
    return $bw;
}

my %subwidget_options =
    (
     Tree => [
	 '-columns', '-drawbranch', '-gap', '-header', '-height',
	 '-indent', '-indicator', '-indicatorcmd', '-itemtype',
	 '-padx', '-pady', '-sizecmd', '-separator', '-width',
     ],
     );
sub Tree {
    my $self = shift; # this will be a parent widget for newer tree
    my $int = $self->interp;
    my $w    = w_uniq($self, "tree"); # return unique widget id
    $int->need_tk('Tix');
    my %args = @_;
    my %sub_args;
    foreach (@{$subwidget_options{'Tree'}}) {
	$sub_args{$_} = delete $args{$_} if exists $args{$_};
    }
    # The hlist options must be passed in -options are creation time
    # as a Tcl list.  Build a Perl array that will be auto-converted
    # to a Tcl list in 'call'.
    my @opts;
    foreach my $opt (keys %sub_args) {
	my $cname = $opt;
	$cname =~ s/^-//;
	push @opts, "hlist.$cname", $sub_args{$opt};
    }
    $args{'-options'} = \@opts;
    my $tree = $int->declare_widget($int->call('tixTree', $w, %args));
    my $wtype = 'Tree';
    create_widget_package($wtype);
    # We don't need special_widget_abilities as long as a recent Tix
    # is used that passes the HList method calls to its subwidget
    # automatically.
    return bless $tree, "Tcl::Tk::Widget::$wtype";
}

# Scrolled is implemented via BWidget ScrolledWindow using MultipleWidget
sub Scrolled {
    DEBUG(1, "SCROLLED (@_)\n");
    my $self = shift; # this will be a parent widget for newer Scrolled
    my $int = $self->interp;
    my $wtype = shift; # what type of scrolled widget
    die "wrong 'scrolled' type $wtype" unless $wtype =~ /^\w+$/;

    # translate Scrolled parameter
    my %args = @_;
    my $sb = delete $args{'-scrollbars'};
    if ($sb) {
	# TODO (easy one) -- really process parameters to scrollbar. 
	# Now let them be just like 'osoe'
    }

    # We need to create a list of widgets that do their own scrolling
    if ($wtype eq 'Tree') {
	$args{'-scrollbar'} = "auto";
	return Tree($self, %args);
    }

    # Use BWidget ScrolledWindow as wrapper widget
    $int->need_tk('BWidget');
    my $w  = w_uniq($self, "sc"); # return unique widget id
    my $sw = $int->call('ScrolledWindow', $w,
			-auto=>'both', -scrollbar=>'both');
    $sw = $int->declare_widget($sw);
    my $subw;
    {
	no strict 'refs';  # another option would be hash with values as subroutines
	$subw = &{"Tcl::Tk::Widget::$wtype"}($sw, %args);
    }
    $sw->setwidget($subw);
    my $mmw = new Tcl::Tk::Widget::MultipleWidget (
	$int,
	$subw, ['&','-'], # all methods and options redirected to $subw
	$sw, ['*'],       # all geometry methods redirected to $sw
    );
    return $mmw;
}

# substitute Tk's "tk_optionMenu" for this
sub Optionmenu {
    my $self = shift; # this will be a parent widget for newer Optionmenu
    my $int = $self->interp;

    # translate parameters
    my %args = @_;

    my $w  = w_uniq($self, "om"); # return unique widget id
    my $vref = \do{my $r};
    $vref = delete $args{'-variable'} if exists $args{'-variable'};
    my $options = delete $args{'-options'} if exists $args{'-options'};
    my $replopt = {};
    for (@$options) {
	if (ref) {
	    # anon array [lab=>val]
	    $replopt->{$_->[0]} = $_->[1];
	    $_ = $_->[0];
	}
    }
    my $mnu = $int->call('tk_optionMenu', $w, $vref, @$options);
    $mnu = $int->declare_widget($mnu);
    $w = $int->declare_widget($w);
    my $mmw;
    $mmw = new Tcl::Tk::Widget::MultipleWidget (
        $int,
        $w, ['&','-','*','-variable'=>\$vref,
	    '-textvariable'=>sub {
		my ($w,$optnam,$optval) = @_;
		if (exists $mmw->{_replopt}->{$$vref}) {
		    return \$mmw->{_replopt}->{$$vref};
		}
		return $vref;
	    },
	    '-menu'=> \$mnu,
	    '-options'=>sub {
		print STDERR "***options: {@_}\n";
		my ($w,$optnam,$optval) = @_;
		for (@$optval) {
		    $w->add('command',$_);
		}
	    },
         ],
	 $mnu, ['&entrycget',],
    );
    $mmw->{_replopt} = $replopt if defined $replopt;
    #for (keys %args) {$mmw->configure($_=>$args{$_})}
    return $mmw;
}

# TODO -- document clearly how to use this subroutine
sub Declare {
    my $w       = (ref $_[0]?shift:$mainwindow);
    my $wtype   = shift;
    my $ttktype = shift;
    my %args    = @_;

    # Allow overriding of existing widgets.
    # XXX This should still die if we have created any single instance
    # XXX of this widget already.
    #die "$wtype already created\n" if defined $ptk2tcltk{$wtype};
    $args{'-prefix'} ||= lcfirst $ttktype;
    $ptk2tcltk{$wtype} = [$ttktype, $args{'-prefix'}, $args{'-require'},
			  $args{'-command'}];
    $ptk_w_names .= "|$wtype";
}

# here we create Widget package, used for both standard cases like
# 'Button', 'Label', and so on, and for all other widgets like Baloon
# TODO : document better and provide as public way of doing things?
my %created_w_packages; # (may be look in global stash %:: ?)
sub create_widget_package {
    my $widgetname = shift;
    DEBUG(2, "AUTOCREATE widget $widgetname (@_)\n");
    unless (exists $created_w_packages{$widgetname}) {
        DEBUG(1, "c-PACKAGE $widgetname (@_)\n");
	$created_w_packages{$widgetname} = {};
	die "not allowed widg name $widgetname" unless $widgetname=~/^\w+$/;
	# here we create Widget package
	my $package = $Tcl::Tk::VTEMP;
	$package =~ s/\[\[widget-repl\]\]/$widgetname/g;
	eval "$package";
	die $@ if $@;
	# Add this widget class to ptk_w_names so the AUTOLOADer properly
	# identifies it for creating class methods
	$ptk_w_names .= "|$widgetname";
    }
}
# this subroutine creates a method in widget's package
sub create_method_in_widget_package {
    my $widgetname = shift;
    create_widget_package($widgetname);
    while ($#_>0) {
	my $widgetmethod = shift;
	my $sub = shift;
	next if exists $created_w_packages{$widgetname}->{$widgetmethod};
	$created_w_packages{$widgetname}->{$widgetmethod}++; #(look in global stash?)
	no strict 'refs';
	my $package = "Tcl::Tk::Widget::$widgetname";
	*{"${package}::$widgetmethod"} = $sub;
    }
}

sub DESTROY {}			# do not let AUTOLOAD catch this method

#
# Let Tcl/Tk process required method via AUTOLOAD mechanism
#

sub AUTOLOAD {
    #DEBUG(3, "(($_[0]|$Tcl::Tk::Widget::AUTOLOAD|@_))\n");
    my $w = shift;
    my $wp = $w->path;
    my $method = $Tcl::Tk::Widget::AUTOLOAD;
    # Separate method to autoload from (sub)package
    $method =~ s/^(Tcl::Tk::Widget::((MainWindow|$ptk_w_names)::)?)//
	or die "weird inheritance ($method)";
    my $package = $1;

    DEBUG(3, "AUTOLOAD $method IN $package\n");

    # Precedence ordering is important

    # 1. Check to see if it is a known widget method
    if (exists $ptk2tcltk{$method}) {
	create_widget_package($method);
	my $sub = create_ptk_widget_sub($method);
	no strict 'refs';
	*{"$package$method"} = $sub;
	return $sub->($w,@_);
    }
    # 2. Check to see if it is a known mappable sub (widget unused)
    if (exists $ptk2tcltk_mapper{$method}) {
        DEBUG(2, "AUTOCREATE $package$method mapped (@_)\n");
	my $sub = sub {
	    my $self = shift;
	    $self->interp->call(@{$ptk2tcltk_mapper{$method}},@_);
	};
	no strict 'refs';
	*{"$package$method"} = $sub;
	return $sub->($w,@_);
    }
    # 3. Check to see if it is a known special widget ability (subcommand)
    # (now this is commented out and probably will go away, as long as a 
    # widget should just create method in its package. But probably such 
    # method could be used for something else)
    #if (exists $special_widget_abilities{$wp} 
    #    && exists $special_widget_abilities{$wp}->{$method}) {
    #    no strict 'refs';
    #    return $special_widget_abilities{$wp}->{$method}->(@_);
    #}
    # 4. Check to see if it is a known 'wm' command
    # XXX: What about toplevel vs. inner widget checking?
    if (exists $ptk2tcltk_wm{$method}) {
        DEBUG(2, "AUTOCREATE $package$method $ptk2tcltk_wm{$method} (@_)\n");
	my $sub;
	if ($method eq "children") {
	    # winfo children returns widget paths, so map them to objects
	    $sub = sub {
		my $self = shift;
		my $wp   = $self->path;
		my $int  = $self->interp;
		my @wids = $int->call($ptk2tcltk_wm{$method}, $method, $wp, @_);
		map($int->widget($_), @wids);
	    };
	} else {
	    $sub = sub {
		my $self = shift;
		my $wp = $self->path;
		$self->interp->call($ptk2tcltk_wm{$method}, $method, $wp, @_);
	    };
	}
	no strict 'refs';
	*{"$package$method"} = $sub;
	return $sub->($w,@_);
    }
    # 5. Check to see if it is a camelCase method.  If so, split it apart.
    # code below will always create subroutine that calls a method.
    # This could be changed to create only known methods and generate error
    # if method is, for example, misspelled.
    # so following check will be like 
    #    if (exists $knows_method_names{$method}) {...}
    my $sub;
    if ($method =~ /^([a-z]+)([A-Z][a-z]+)$/) {
        my ($meth, $submeth) = ($1, lc($2));
	if ($meth eq "grid" || $meth eq "pack") {
	    # grid/pack commands reorder $wp in the call
	    DEBUG(2, "AUTOCREATE $package$method $meth $submeth $wp (@_)\n");
	    $sub = sub {
		my $w = shift;
		my $wp = $w->path;
		$w->interp->call($meth, $submeth, $wp, @_);
	    };
	} elsif ($meth eq "after") {
	    # after commands don't include $wp in the call
	    DEBUG(2, "AUTOCREATE $package$method $meth $submeth $wp (@_)\n");
	    $sub = sub {
		my $w = shift;
		my $wp = $w->path;
		$w->interp->call($meth, $submeth, @_);
	    };
	} else {
	    # Default case, break into $wp $method $submethod and call
	    DEBUG(2, "AUTOCREATE $package$method $wp $meth $submeth (@_)\n");
	    $sub = sub {
		my $w = shift;
		my $wp = $w->path;
		$w->interp->call($wp, $meth, $submeth, @_);
	    };
	}
    }
    else {
	# Default case, call as submethod of $wp
	DEBUG(2, "AUTOCREATE $package$method $wp $method (@_)\n");
	$sub = sub {
	    my $w = shift;
	    my $wp = $w->path;
	    $w->interp->call($wp, $method, @_);
	};
    }
    #DEBUG(2, "creating ($package)$method (@_)\n");
    no strict 'refs';
    *{"$package$method"} = $sub;
    return $sub->($w,@_);
}

BEGIN {
# var to generate pTk package from
#(test implementation, will be implemented l8r better)
$Tcl::Tk::VTEMP = <<'EOWIDG';
package Tcl::Tk::Widget::[[widget-repl]];

use vars qw/@ISA/;
@ISA = qw(Tcl::Tk::Widget);

sub DESTROY {}			# do not let AUTOLOAD catch this method

sub AUTOLOAD {
    print STDERR "<<@_>>\n" if $Tcl::Tk::DEBUG > 2;
    $Tcl::Tk::Widget::AUTOLOAD = $Tcl::Tk::Widget::[[widget-repl]]::AUTOLOAD;
    return &Tcl::Tk::Widget::AUTOLOAD;
}
1;
print STDERR "<<starting [[widget-repl]]>>\n" if $Tcl::Tk::DEBUG > 2;
EOWIDG
}

package Tcl::Tk::Widget::MultipleWidget;
# multiple widget is an object that for each option has a path
# to refer in Tcl/Tk and for method has corresponding method in Tcl/Tk

my %geometries;
BEGIN {%geometries = map {$_=>1} qw(grid pack form place);}

#syntax
# my $ww = new Tcl::Tk::Widget::MultipleWidget(
#   $int,
#   $w1, [qw(-opt1 -opt2 ...), '-optn=-opttcltk', -optm=>sub{...}],
#   $w2, [qw(-opt1 -opt2 ...), -optk=>\$scalar],
#   ...
# );
# methods are specified like options with starting '&' with optional
# list of replacement options after slash.
#
# specifying '&' without method name will result in declaring said widget
# to be used for all methods that are not listed
# 
# specifying '-' without method name will result in declaring said widget
# to be used for all options that are not listed
# 
# specifying '*' alone will result in declaring said widget
# to be used for all geometry methods
# 
# Example:
# my $ww = new Tcl::Tk::Widget::MultipleWidget($int,
#   $w1, ['-opt1', '-opt2', '-opt3=opttcltk', -opt4=>sub{print 'opt4'}],
#   $w2, ['-opt2=-tkopt2', '-opt5', 
#         '&meth=tkmethod/-opt7=-tkopt7,-opt8,-opt9'],
# );
# In this example:
#   * changing '-opt2' for widget will cause changing '-opt2' for $w1 and
#     changing '-tkopt2' for $w2
#   * changing '-opt1' for widget will cause changing '-opt1' for $w1
#   * invoking method 'meth' for widget will cause invoking 'tkmethod'
#     for $w2 and with options renamed appropriately
#   
# $w1, $w2, ... must be path of a widget or Tcl::Tk::Widget objects
# Also could be called as $int->MultipleWidget(...); TODO
sub new {
    my $package = shift;
    my $int = shift;
    my $self = {
        _int => $int,  # interpreter
	_subst => {},  # hash to hold replacement of option names for pTk=>Tcl/Tk
		       # keys are perlTk option/method, values are array refs 
		       # describing behaviour
	               # "-opt2"=>[$w1,'-opt2',{},$w2,'-tkopt2',{}],
		       # "&meth"=>[$w2,'tkmethod',{-opt7=>'-tkopt7',-opt8=>'-opt8',-opt9=>'-tkopt9'}]
	_def_opt => undef,  # widget to accept unrecognized options
	_def_meth => undef, # widget to accept unrecognized methods
	_def_geom => undef, # widget to accept geometry requests
	_w => {},      # hash of all subwidgets
    };
    my @args = @_;
    for (my $i=0; $i<$#args; $i+=2) {
        my $w = $args[$i];
        $w = $int->declare_widget($w) unless ref $w;
	$self->{_w}->{$w}++;
        my @a = @{$args[$i+1]};
        for (my $j=0; $j<=$#a; $j++) {
            my ($p, $prepl) = ($a[$j]);
	    if ($p eq '-') {
		$self->{_def_opt} = $w;
		next;
	    }
	    elsif ($p eq '&') {
		$self->{_def_meth} = $w;
		next;
	    }
	    elsif ($p eq '*') {
		$self->{_def_geom} = $w;
		$self->{_path} = $w->path;
		next;
	    }
	    my $meth = ($p=~s/^&// ? "&":"");
	    my $hsubst = {};
	    if ($p=~s/\/(.*)$//) {
		$hsubst = {map {m/^(.*)=(.*)$/? ($1=>$2) : ($_=>$_)} split /,/, $1};
	    }
            if ($p=~/^(.*)=(.*)$/) {
                ($p, $prepl) = ($1,$2);
            }
            else {$prepl = $p}
            if ($j+1<=$#a) {
		if (ref($a[$j+1])) {
		    $prepl = $a[$j+1];
		    splice @a, $j+1, 1;
		}
            }
	    $self->{_subst}->{"$meth$p"} ||= []; # create empty array if not exists
	    push @{$self->{_subst}->{"$meth$p"}}, $w, $prepl, $hsubst;
        }
    }
    $self->{_path} ||= ($self->{_def_geom} || $self->{_def_meth} || $args[0])->path;
    return bless $self, $package;
}
sub path {
  $_[0]->{_path};
}

#
# 'configure' and 'cget' could not be processed using common AUTOLOAD
# so must process separatedly
sub configure {
    my $w = shift;
    if ($#_>0) {
	# more than 1 argument, this is setting of many configure options
	my %args = @_;
	my @res;
	for my $optname (keys %args) {
	    if (exists $w->{_subst}->{$optname}) {
		my $mdo = $w->{_subst}->{$optname};
		for my $i (0 .. ($#$mdo-2)/3) {
		    my ($replwid, $replnam, $replopt) = 
		       ($mdo->[3*$i],$mdo->[3*$i+1],$mdo->[3*$i+2]);
		    if (ref($replnam)) {
			if (ref($replnam) eq 'CODE') {
			    @res = $replnam->($replwid,$optname,$args{$optname});
			}
			else {
			    # suppose it's scalar ref to operate with
			    $$replnam = $args{$optname};
			}
		    }
		    else {
		    	@res = $replwid->configure($replnam,$args{$optname});
		    }
		}
	    }
	    elsif (exists $w->{_def_opt}) {
		# default options receiver
		@res = $w->{_def_opt}->configure($optname,$args{$optname});
	    }
	    else {
		die "this MultipleWidget is not able to process $optname";
	    }
	}
	return @res;
    }
    elsif ($#_==0) {
	# 1 argument, in array context return a list of five or two elements
	die "NYI MultipleWidget configure 1";
    }
    else {
	# here $#_==-1, no arguments given
	# Returns a list of lists for all the options supported by widget
	die "NYI MultipleWidget configure 2";
    }
    die "NYI MultipleWidget configure 3";
}
sub cget {
    my $w = shift;
    my $optname = shift;
    if (exists $w->{_subst}->{$optname}) {
	my $mdo = $w->{_subst}->{$optname};
	for my $i (0 .. ($#$mdo-2)/3) {
	    my ($replwid, $replnam, $replopt) = 
	       ($mdo->[3*$i],$mdo->[3*$i+1],$mdo->[3*$i+2]);
	    if (ref($replnam)) {
		if (ref($replnam) eq 'CODE') {
		    return $replnam->($replwid,$optname);
		}
		else {
		    # suppose it's scalar ref to operate with
		    return $$replnam;
		}
	    }
	    if (ref($replnam) && ref($replnam) eq 'CODE') {
	    }
	    else {
		return $replwid->cget($replnam);
	    }
	}
    }
    elsif (exists $w->{_def_opt}) {
	# default options receiver
	return $w->{_def_opt}->cget($optname);
    }
    else {
	die "this MultipleWidget is not able to process CGET $optname";
    }
}
sub Subwidget {
    my ($self,$name) = @_;
    return $self;
}

sub DESTROY {}			# do not let AUTOLOAD catch this method

#
# Unlike for Tcl::Tk::Widget::Button and similar, does not autovivify
# required method; instead it uses autoloading every time, because
# otherwise methods from different MultipleWidgets will mix
sub AUTOLOAD {
    # print STDERR "##@_($Tcl::Tk::Widget::MultipleWidget::AUTOLOAD)##\n";
    # first look into substitute hash
    # if not found - call that method from "default" widget ...->{_def_meth}
    my $wmeth = $Tcl::Tk::Widget::MultipleWidget::AUTOLOAD;
    $wmeth=~s/::MultipleWidget\b//;
    my ($pmeth) = ($wmeth=~/::([^:]+)$/);
    my $self = $_[0];
    my @res;
    if (exists $self->{_subst}->{"&$pmeth"}) {
	my $mdo = $self->{_subst}->{"&$pmeth"};
	my @args = @_[1..$#_];
	my %args = @args;
	for my $i (0 .. ($#$mdo-2)/3) {
	    my ($replwid, $replnam, $replopt) = ($mdo->[3*$i],$mdo->[3*$i+1],$mdo->[3*$i+2]);
	    my %opts;
	    for my $opt (keys %args) {
		if (exists $replopt->{$opt}) {
		    $opts{$replopt->{$opt}} = $args{$opt};
		}
	    }
	    # TODO - when same method should be invoked on several widgets
	    if (wantarray) {
	        @res = $replwid->$replnam(%opts);
	    } else {
	        $res[0] = $replwid->$replnam(%opts);
	    }
	    ## this is not very strict place, but there's no 100% solution.
	    ## if a function returns our sub-widget, then we must return our self.
	    my $_w = $self->{_w};
	    @res = map {exists $_w->{$_} ? $self : $_} @res;
	    return @res if wantarray;
	    return $res[0];
	}
    }
    elsif (exists $geometries{$pmeth} && exists $self->{_def_geom}) {
	if (wantarray) {
	    @res = $self->{_def_geom}->$pmeth(@_[1..$#_]);
	} else {
	    $res[0] = $self->{_def_geom}->$pmeth(@_[1..$#_]);
	}
	## this is not very strict place, but there's no 100% solution.
	## if a function returns our sub-widget, then we must return our self.
	my $_w = $self->{_w};
	@res = map {exists $_w->{$_} ? $self : $_} @res;
	return @res if wantarray;
	return $res[0];
    }
    elsif (exists $self->{_def_meth}) {
	my $replwid = $self->{_def_meth};
	# print STDERR "_def_meth: $replwid $pmeth (@_[1..$#_])\n";
	if (wantarray) {
	    @res = $replwid->$pmeth(@_[1..$#_]);
	} else {
	    $res[0] = $replwid->$pmeth(@_[1..$#_]);
	}
	## this is not very strict place, but there's no 100% solution.
	## if a function returns our sub-widget, then we must return our self.
	my $_w = $self->{_w};
	@res = map {exists $_w->{$_} ? $self : $_} @res;
	return @res if wantarray;
	return $res[0];
    }
    die "this MultipleWidget is not able to process $wmeth";
    # currently not reached
    $Tcl::Tk::Widget::AUTOLOAD = $Tcl::Tk::Widget::MultipleWidget::AUTOLOAD;
    return &Tcl::Tk::Widget::AUTOLOAD;
}

package Tcl::Tk::Widget::MainWindow;

use vars qw/@ISA/;
@ISA = qw(Tcl::Tk::Widget);

sub DESTROY {}			# do not let AUTOLOAD catch this method

sub AUTOLOAD {
    $Tcl::Tk::Widget::AUTOLOAD = $Tcl::Tk::Widget::MainWindow::AUTOLOAD;
    return &Tcl::Tk::Widget::AUTOLOAD;
}

sub path {'.'}

# subroutine for compatibility with perlTk
my $invcnt=0;
sub new {
    my $self = shift;
    if ($invcnt==0) {
        $invcnt++;
        return $self;
    }
    return $self->Toplevel(@_);
}

1;
