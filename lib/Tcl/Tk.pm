package Tcl::Tk;

use strict;
use Tcl;
use Exporter;
use DynaLoader;
use vars qw(@ISA @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter DynaLoader);

$Tcl::Tk::VERSION = '0.76';

# For users that want to ensure full debugging from initial use call,
# including the checks for other Tk modules loading following Tcl::Tk
# loading, add the following code *after* 'use Tcl::Tk':
#
# BEGIN { $Tcl::Tk::DEBUG = 1; }
#
sub DEBUG() { $Tcl::Tk::DEBUG; }

if (DEBUG()) {
    # The gestapo throw warnings whenever Perl/Tk modules are requested.
    # It also hijacks such requests and returns an empty module in its
    # place.
    unshift @INC, \&tk_gestapo;
}

=head1 NAME

Tcl::Tk - Extension module for Perl giving access to Tk via the Tcl extension

=head1 SYNOPSIS

    use Tcl::Tk qw(:widgets :misc);
    $interp = new Tcl::Tk;
    label(".l", -text => "Hello world");
    tkpack ".l";
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

Unlike perl-tk extension (available on CPAN), where Tcl+Tk+Tix are embedded
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

    $i->call($$l, "configure", "-background", "green");

for execution in your Tcl/Tk interpreter. Notice that it simply dereferences
the object to find the widget name. There is no automagic conversion that
happens: if you use a Tcl command which wants a widget pathname and you
only have an object returned by C<label()> (or C<button()> or C<entry()>
or whatever) then you must dereference it yourself.

When widgets are created they are stored internally and could be retreiwed
by C<widget()> command:

    widget(".fram.butt")->configure(-text=>"new text");
   
Please note that this method will return to you a widget object even if it was
not created within this module, and check will not be performed whether a 
widget with given path exists, despite of fact that checking for existence of
a widget is an easy task (invoking $interp->Eval("info commands $path") will
do this). Instead, you will receive perl object that will try to operate with
widget that has given path even if such path do not exists. 

This approach allows to transparently access widgets created in Tcl way. So
variable $btn in following code will behave exactly as if it was created
with "button" method:

    $interp->Eval(<<'EOS');
    frame .f
    button .f.b
    pack .f
    pack .f.b
    EOS
    my $btn = widget(".f.b");

Note, that currently C<widget()> methods does not checks whether required 
widget actually exists in Tk. It just will return an object of type
Tcl::Tk::Widget and any method of this widget will just ask underlying Tcl/Tk
GUI system to do some action with a widget with a given path. In case it do
not actually exist you will receive an error from Tcl/Tk.

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

    use Tcl::Tk qw(:widgets :misc);
    $interp = new Tcl::Tk;

    # at next line interpreter object omited, but $interp is implicitly used
    label ".l", -text => "Hello world"; 
    
    tkpack ".l"; # $interp will be called to pack ".l"
    
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

=head2 Non-widget Tk commands

For convenience, the non-widget Tk commands (such as C<destroy>,
C<focus>, C<wm>, C<winfo> and so on) are also available for export as
Perl commands and translate into into their Tcl equivalents for
execution in your Tk/Tcl interpreter. The names of the Perl commands
are the same as their Tcl equivalents except for two: Tcl's C<pack>
command becomes C<tkpack> in Perl and Tcl's C<bind> command becomes
C<tkbind> in Perl. But those two commands are C<pack> and C<bind> when
used as method of interpreter, because this way we avoid confusion with
Perl internal C<pack> and C<bind>. The arguments you pass to any of these
Perl commands are not touched by the Tcl parser: each Perl argument is
passed as a separate argument to the Tcl command.

=head2 BUGS

Currently work is in progress, and some features could change in future
versions.

=head2 AUTHORS

Malcolm Beattie, mbeattie@sable.ox.ac.uk
Vadim Konovalov, vkonovalov@peterstar.ru, 19 May 2003.
Jeff Hobbs, jeffh _a_ activestate com, February 2004.

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
	      selection tk tkbind tkpack grid tkwait update winfo wm);
my @perlTk = qw(MainLoop MainWindow tkinit update);

@EXPORT_OK = (@widgets, @misc, @perlTk);
%EXPORT_TAGS = (widgets => \@widgets, misc => \@misc, perlTk => \@perlTk);

## TODO -- module's private $tkinterp should go away!
my $tkinterp = undef;		# this gets defined when "new" is done

my $mwpath = ''; # path to main window is '.'
my $mainwindow = \$mwpath;
my %w; # hash to keep track on all created widgets
my %wint; # hash to keep track on tk interpreters associated with widgets

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
    if (!defined($tkinterp)) {
        $i->CreateMainWindow($display, $name, $sync);
        bless $mainwindow, 'Tcl::Tk::Widget::MainWindow';
	$wint{''} = $wint{'.'} = $i;
    }
    $i->SetVar2("env", "DISPLAY", $display, Tcl::GLOBAL_ONLY);
    $i->SetVar("argv0", $0, Tcl::GLOBAL_ONLY);
    $i->SetVar("argc", scalar(@main::ARGV), Tcl::GLOBAL_ONLY);
    if (defined $::tcl_library) {
      # hack to redefine search path for TCL installation
      $i->SetVar('tcl_library',$::tcl_library);
    }
    $i->ResetResult();
    push(@argv, "--", @ARGV);
    $i->AppendElement($_) for @argv;
    $i->SetVar("argv", $i->result(), Tcl::GLOBAL_ONLY);
    $i->SetVar("tcl_interactive", "0", Tcl::GLOBAL_ONLY);
    $i->Init();
    $i->Tk_Init();
    #'###???'&&   bless $i, 'Tcl::Tk';
    $tkinterp = $i;
    return $i;
}

sub tkinit {
    $tkinterp = new(@_);
    $mainwindow;
}
sub MainWindow {
    $tkinterp = new(@_);
    $mainwindow;
}

sub declare_widget {
    my $int = shift;
    my $path = shift;
    $wint{$path} = $int;
    return $w{$path} = bless \$path, 'Tcl::Tk::Widget';
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
    if (exists $w{$wpath}) {
        return $w{$wpath};
    }
    if ($wpath=~/^\.[.\w]+$/) {
        # It looks like widget path
	# We could ask Tcl about it by invoking
	# my @res = $int->Eval("info commands $wpath");
	# but we don't do it, as long as we allow any widget paths to
	# be used by user.
        return $int->declare_widget($wpath);
    }
}
sub Exists($) {
    return 0 if $#_<0;
    my $wid = shift;
    if (ref($wid)=~/^Tcl::Tk::Widget\b/) {
        my $wp = $wid->path;
        return $wint{$wp}->call('winfo','exists',$wp);
    }
    return $tkinterp->call('winfo','exists',$wid);
}
# do this only when tk_gestapo on? In normal case Tcl::Tk::Exists should be used...
*{Tk::Exists} = \&Tcl::Tk::Exists;

sub widgets {
    \%w;
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

sub tkbind {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("bind", @_);
}
sub tkpack {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("pack", @_);
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
    return if $preloaded_tk{$what};
    if ($what eq 'Tix') {
	$int->call("package", "require", "Tix");
    }
    elsif ($what eq 'Img') {
	$int->call("package", "require", "Img");
    }
    elsif ($what eq 'BWidget') {
	$int->Eval("package require BWidget;ScrolledWindow::use"); # TODO
    }
    elsif ($what eq 'Balloon') {
	$int->call("package", "require", "Tix") unless $preloaded_tk{'Tix'};
	$int->Eval("destroy [tixBalloon .___ptk_bln]"); #TODO
    }
    elsif ($what eq 'NoteBook') {
	$int->call("package", "require", "Tix") unless $preloaded_tk{'Tix'};
	$int->Eval("destroy [tixNoteBook .___ptk_nb]"); #TODO
    }
    elsif ($what eq 'HList') {
	$int->call("package", "require", "Tix") unless $preloaded_tk{'Tix'};
	$int->Eval("destroy [tixHList .___ptk_hlist]"); #TODO
    }
    elsif ($what eq 'Tree') {
	$int->call("package", "require", "Tix") unless $preloaded_tk{'Tix'};
	$int->Eval("destroy [tixTree .___ptk_tree]"); #TODO
    }
    elsif ($what eq 'tktable') {
	$int->call("package", "require", "Tktable"); #TODO
    }
    elsif ($what eq 'pure-perl-Tk') {
        eval <<"EOS";
use Tcl::Tk::Widget;
EOS
    }
    elsif ($what eq 'ptk-Table') {
        eval <<"EOS";
use Tcl::Tk::Table;
EOS
    }
    else {
	die "need_tk do not recognize resource $what";
    }
    $preloaded_tk{$what}++;
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

##
## Switch to Widget namespace
##

package Tcl::Tk::Widget;

sub DEBUG { Tcl::Tk::DEBUG(); }	# do not let AUTOLOAD catch this method

sub iconimage {
    # this should set the wm iconimage/iconbitmap with an image
    warn "iconimage not yet implemented";
};

sub path {${$_[0]}}
# returns interpreter that is associated with widget
sub interp {
    my $self = shift;
    return $wint{$$self};
}

#
# few geometry methods here, as syntax sugar to do
#  button(...)->pack;
#assume here that OO is reference to widget's path
#
sub pack {
    my $self = shift;
    $wint{$$self}->call("pack",$$self,@_);
    $self;
}
sub grid {
    my $self = shift;
    $wint{$$self}->call("grid",$$self,@_);
    $self;
}
sub place {
    my $self = shift;
    $wint{$$self}->call("place",$$self,@_);
    $self;
}
sub bind {
    my $self = shift;
    # 'text' and 'canvas' binding could be different compared to common case
    # as long as Text uses 'tag bind' then we do not need to process it here
    if (ref($self) eq 'Tcl::Tk::Widget::Canvas') {
        $wint{$$self}->call($$self,'bind',@_);
    }
    else {
	$wint{$$self}->call("bind",$self->path,@_);
    }
}
sub form {
    my $self = shift;
    my $int = $wint{$self->path};
    $int->need_tk("Tix");
    my @arg = @_;
    for (@arg) {
	if (ref && ref eq 'ARRAY') {
	    $_ = join ' ', map {
		  (ref && (ref =~ /^Tcl::Tk::Widget\b/))?
		    $_->path  # in this case there is form geometry relative
		              # to widget; substitute its path
		  :$_} @$_;
	}
    }
    $int->call("tixForm",$self,@arg);
    $self;
}

# TODO -- these methods could be AUTOLOADed
sub focus {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('focus',$wp,@_);
}
sub destroy {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('destroy',$wp,@_);
}

# for compatibility (TODO -- these 'wm/winfo' methods could be AUTOLOADed)
sub geometry {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('wm','geometry',$wp,@_);
}
sub GeometryRequest {
    my $self = shift;
    my $wp = $self->path;
    my ($width,$height) = @_;
    $wint{$$self}->call('wm','geometry',$wp,"=${width}x$height");
}
sub OnDestroy {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('bind','Destroy',$wp,@_);
}
sub grab {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('grab',$wp,@_);
}
sub grabRelease {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('grab','release',$wp,@_);
}
sub protocol {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('wm','protocol',$wp,@_);
}
sub title {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('wm','title',$wp,@_);
}
sub reqwidth {
    my $self = shift;
    my $wp = $self->path;
    return $wint{$$self}->call('winfo','reqwidth',$wp,@_);
}
sub reqheight {
    my $self = shift;
    my $wp = $self->path;
    return $wint{$$self}->call('winfo','reqheight',$wp,@_);
}
sub screenheight {
    my $self = shift;
    my $wp = $self->path;
    return $wint{$$self}->call('winfo','screenheight',$wp,@_);
}
sub screenwidth {
    my $self = shift;
    my $wp = $self->path;
    return $wint{$$self}->call('winfo','screenwidth',$wp,@_);
}
sub height {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('winfo', 'height', $wp, @_);
}
sub width {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('winfo', 'width', $wp, @_);
}
sub rgb {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('winfo', 'rgb', $wp, @_);
}
sub children {
    my $self = shift;
    my $wp = $self->path;
    return $wint{$$self}->call('winfo','children',$wp,@_);
}
sub packPropagate {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('pack','propagate',$wp,@_);
}
sub packAdjust {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('pack','configure',$wp,@_);
}
sub optionGet {
    my $self = shift;
    my $wp = $self->path;
    $wint{$$self}->call('option','get',$wp,@_);
}
sub fontNames {
    my $self = shift;
    $wint{$$self}->call('font','names',@_);
}
sub idletasks {
    my $self = shift;
    $wint{$$self}->call('update','idletasks',@_);
}
sub update {
    my $self = shift;
    $wint{$$self}->update;
}
sub font {
    my $self = shift;
    $wint{$$self}->call('font', @_);
}
sub waitVariable {
    my $self = shift;
    $wint{$$self}->call('tkwait', 'variable', @_);
}
sub ItemStyle {
    my $self = shift;
    my $styl = shift;
    my $wp   = $self->path;
    my $int  = $wint{$wp};
    $int->need_tk('Tix');
    my %args = @_;
    $args{'-refwindow'} = $wp unless exists $args{'-refwindow'};
    $int->call('tixDisplayStyle', $styl, %args);
}
sub getOpenFile {
    my $self = shift;
    my %args = @_;
    $args{'-parent'} = $self->path unless defined $args{'-parent'};
    $wint{$$self}->call('tk_getOpenFile', %args);
}
sub getSaveFile {
    my $self = shift;
    my %args = @_;
    $args{'-parent'} = $self->path unless defined $args{'-parent'};
    $wint{$$self}->call('tk_getSaveFile', %args);
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
 sprintf('#%02x%02x%02x',$red,$green,$blue)
}


# althought this is not the case, we'll think of object returned by 'after'
# as a widget.
sub after {
    my $self = shift;
    my $int = $wint{$$self};
    my $ret = $int->call('after', @_);
    return $int->declare_widget($ret);
}
sub cancel {
    my $self = shift;
    return $wint{$$self}->call('after','cancel',$$self);
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

    my $int = $wint{$$self};
    foreach my $ext (keys %image_formats) {
	my $path;
	foreach my $dir (@INC) {
	    $path = "$dir/Tk/$name.$ext";
	    last if -f $path;
	}
	next unless -f $path;
	print STDERR "Getimage: FOUND IMAGE $path\n" if DEBUG();
	if ($ext eq "xpm") {
	    $int->need_tk('Img');
	}
	$images->{$name} = $int->call('image', 'create', $image_formats{$ext},
				      -format => $ext, -file => $path);
	return $images->{$name};
    }

    # Try built-in bitmaps from Tix
    #$images->{$name} = $w->Pixmap( -id => $name );
    #return $images->{$name};
    print STDERR "Getimage: MISSING IMAGE $name\n" if DEBUG();
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
    # create unique widget id with path "$$self.$type<uniqid>"
    if (!defined($type)) {
	my ($package, $callerfile, $callerline) = caller;
	warn "$callerfile:$callerline called w_uniq(@_)";
    }
    $gwcnt++ while exists $wint{"$$self.$type$gwcnt"};
    return "$$self.$type$gwcnt";
}

# perlTk<->Tcl::Tk names
my %ptk2tcltk = (
    #Table => '*perlTk/Table',
    Table => 'table',
    Button => 'button',
    Checkbutton => 'checkbutton',
    Radiobutton => 'radiobutton',
    Menubutton => 'menubutton',
    Panedwindow => 'panedwindow',
    Text => 'text',
    ROText => 'text',
    TextUndo => 'text',
    Canvas => 'canvas',
    #LabFrame => 'labelframe',
    Label => 'label',
    Listbox => 'listbox',
    Entry => 'entry',
    Message => 'message',
    Frame => 'frame',
    Toplevel => 'toplevel',
    NoteBook => 'tixNoteBook',
    HList => 'tixHList',
);
my %ptk2tcltk_wm =
    (
     "minsize" => 1,
     "geometry" => 1
     );
my %ptk2tcltk_pref =
    qw(
       Button		b
       Canvas		can
       Checkbutton	cb
       Entry		ent
       Frame		f
       HList		hlist
       Label		lbl
       Listbox		lb
       LabFrame		lf
       Menubutton	mb
       Message		msg
       NoteBook		nb
       Panedwindow	pw
       Radiobutton	rb
       ROText		rt
       Table		tbl
       Text		txt
       TextUndo		utxt
       Toplevel		top
       Tree		tree
       ); #prefix for autogen. name
my $ptk_w_names = join '|', sort keys %ptk2tcltk;

#  create_ptk_widget_sub creates subroutine similar to following:
#sub Button {
#  my $self = shift; # this will be a parent widget for newer button
#  my $int = $wint{$$self};
#  my $w    = w_uniq($self, "btn");
#  # create 'button' widget with a unique path
#  return $int->button($w,@_);
#}
my %replace_options =
    (
     tixHList => {separator=>'-separator'},
     table => {-columns=>'-cols'},
     toplevel => {-title=>sub{shift->title(@_)},OnDestroy=>sub{}},
     labelframe => {-label=>'-text', -labelside => undef},
     );
my %pure_perl_tk = (); # hash to keep track of pure-perl widgets

sub create_ptk_widget_sub {
    my ($wtype) = @_;
    my ($ttktype,$wpref) = ($ptk2tcltk{$wtype},$ptk2tcltk_pref{$wtype});

    if ($wtype eq 'HList') {$tkinterp->need_tk('HList')}
    elsif ($wtype eq 'Tree') {$tkinterp->need_tk('Tree')}
    elsif ($ttktype =~ /^tix/) {$tkinterp->need_tk('Tix');}
    elsif ($wtype eq 'Photo') {$tkinterp->need_tk('Img')}
    elsif ($wtype eq 'Table') {
	#$tkinterp->need_tk('pure-perl-Tk');
	#$tkinterp->need_tk('ptk-Table');
	$tkinterp->need_tk('tktable');
    }
    if ($ttktype=~s/^\*perlTk\///) {
	# should create pure-perlTk widget and bind it to Tcl variable so that
	# anytime a method invoked it will be redirected to Perl
	return sub {
	  my $self = shift; # this will be a parent widget for newer widget
	  my $int = $wint{$$self};
          my $w    = w_uniq($self, $wpref); # create uniq pref's widget id
	  die "pure-perlTk widgets are not implemented";
	  $pure_perl_tk{$wint{$w}} = Tcl::Tk::Widget::new('Tcl::Tk::Widget');
	  return $int->declare_widget($int->call($ttktype,$w,@_));
	};
    }
    if (exists $replace_options{$ttktype}) {
	return sub {
	    my $self = shift; # this will be a parent widget for newer widget
	    my $int = $wint{$$self};
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
	my $int = $wint{$$self};
        my $w    = w_uniq($self, $wpref); # create uniq pref's widget id
	#print STDERR "CREATE $ttktype $w @_\n" if DEBUG();
	my $wid=$int->declare_widget($int->call($ttktype,$w,@_));
	bless $wid, "Tcl::Tk::Widget::$wtype";
	return $wid;
    };
}
my %special_widget_abilities = ();
sub LabFrame {
    my $self = shift; # this will be a parent widget for newer labframe
    my $int  = $wint{$$self};
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
    $special_widget_abilities{$$lf} = {
	Subwidget => sub {
	    print STDERR "LabFrame $$lf ignoring Subwidget(@_)\n" if DEBUG();
	    return $lf;
	},
    };
    return $lf;
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
    my $int = $wint{$$mnu};
    my $smnu = Menu($mnu); # return unique widget id
    print STDERR "cascade(@_) of $$mnu is $$smnu\n" if DEBUG();
    my %args = @_;
    my $tearoff = delete $args{'-tearoff'};
    if (defined($tearoff)) {
        $smnu->configure(-tearoff => $tearoff);
    }
    $args{'-menu'} = $smnu;
    my $mis = delete $args{'-menuitems'};
    _process_menuitems($int,$mnu,$mis);
    _process_underline(\%args);
    $int->call("$$mnu",'add','cascade', %args);
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
	    my $cmd = $_->[0];
	    if ($cmd eq 'Separator') {$int->call($mnu,'add','separator');}
	    elsif ($cmd eq 'Cascade') {
		# XXX do we need to check for ~ here?
	        _addcascade($mnu,-label=>$label, %a);
	    }
	    else {
		$cmd=~s/^Button$/command/;
		$cmd=~s/^Checkbutton$/checkbutton/;
		# XXX do we need to check for ~ here?
	        $int->call($mnu,'add',$cmd,'-label',"$label", %a);
	    }
	}
	else {
	    if ($_ eq '-') {
		$int->call($mnu,'add','separator');
	    }
	    else {
		die "in menubutton: '$_' not implemented";
	    }
	}
    }
}
sub Menubutton {
    my $self = shift; # this will be a parent widget for newer menubutton
    my $int = $wint{$$self};
    my $w    = w_uniq($self, "mb"); # create uniq pref's widget id
    my %args = @_;
    my $mcnt = '01';
    my $mis = delete $args{'-menuitems'};
    my $tearoff = delete $args{'-tearoff'};
    $args{'-state'} = delete $args{state} if exists $args{state};
    my $mnub = $int->menubutton($w, -menu=>,"$w.m", %args);
    my $mnu  = $int->menu($w . ".m");
    _process_menuitems($int,$mnu,$mis);
    $int->update if DEBUG();

    # TODO implement better:
    $special_widget_abilities{$$mnub} = {
	command=>sub {
	    my %args = @_;
	    _process_underline(\%args);
	    $int->call("$$mnub.m",'add','command',%args);
	},
	separator=>sub {
	    $int->call("$$mnub.m",'add','separator',@_);
	},
	menu=>sub {
	    return $int->widget("$$mnub.m");
	},
	cget => sub {
	    if ($_[0] eq "-menu") {
		return $int->widget("$$mnub");
	    } else {
		print STDERR "CALL $$mnu cget @_\n" if DEBUG();
		die "Finish cget implementation for Menubutton";
	    }
	}
    };
    return $mnub;
}
sub Menu {
    my $self = shift; # this will be a parent widget for newer menu
    my $int  = $wint{$$self};
    my $w    = w_uniq($self, "menu"); # return unique widget id
    my %args = @_;

    my $mis         = delete $args{'-menuitems'};
    $args{'-state'} = delete $args{state} if exists $args{state};

    print STDERR "MENU (@_), creating $w\n" if DEBUG();

    my $mnu = $int->menu($w, %args);
    _process_menuitems($int,$mnu,$mis);
    $int->update if DEBUG();

    # TODO implement better:
    $special_widget_abilities{$$mnu} = {
	command => sub {
	    my %args = @_;
	    _process_underline(\%args);
	    $int->call("$$mnu",'add','command',%args);
	},
	checkbutton => sub {
	    $int->call("$$mnu",'add','checkbutton',@_);
	},
	cascade => sub {
	    _addcascade($mnu, @_);
	},
	separator => sub {
	    $int->call("$$mnu",'add','separator',@_);
	},
	menu => sub {
	    return $int->widget("$$mnu");
	},
	cget => sub {
	    if ($_[0] eq "-menu") {
		return $int->widget("$$mnu");
	    } else {
		print STDERR "CALL $$mnu cget @_\n" if DEBUG();
		die "Finish cget implementation for Menu";
	    }
	}
    };
    my $wname = $self->path;
    if ($wname eq '.'
	|| ($int->call('winfo', 'toplevel', $wname) eq $wname
	    && $int->call('winfo', 'class', $wname) ne "Menu")) {
	# This is the toplevel ... so make this the toplevel's menu
	print STDERR "CONFIGURE $$self -menu $$mnu\n" if DEBUG();
	$self->configure(-menu => $mnu);
    } else {
	print STDERR "DO NOT CONFIGURE $$self -menu $$mnu\n" if DEBUG();
    }
    return $mnu;
}
sub Balloon {
    my $self = shift; # this will be a parent widget for newer balloon
    my $int = $wint{$$self};
    my $w    = w_uniq($self, "bln"); # return unique widget id
    $int->need_tk('Balloon');
    my $bw = $int->declare_widget($int->call('tixBalloon', $w, @_));
    $special_widget_abilities{$w} = {
	attach=>sub {
	    my $w = shift;
	    my %args=@_;
	    delete $args{$_} for qw(-postcommand -motioncommand -balloonposition); # TODO!
	    for (qw(-initwait)) {
		if (exists $args{$_}) {
		    $bw->configure($_,delete $args{$_});
		}
	    }
	    $int->call($bw,'bind',$w,%args);
	},
	detach=>sub {
	    my $w = shift;
	    $int->call($bw,'unbind',$w,@_);
	},
    };
    return $bw;
}
sub NoteBook {
    my $self = shift; # this will be a parent widget for newer notebook
    my $int = $wint{$$self};
    my $w    = w_uniq($self, "nb"); # return unique widget id
    $int->need_tk('NoteBook');
    my $bw = $int->declare_widget($int->call('tixNoteBook', $w, @_));
    $special_widget_abilities{$w} = {
	add=>sub {
	    my $wp = $int->call($bw,'add',@_);
	    my $ww = $int->declare_widget($wp);
	    return $ww;
	},
    };
    return $bw;
}
sub Photo {
    my $self = shift; # this will be a parent widget for newer Photo
    my $int = $wint{$$self};
    my $w    = w_uniq($self, "pht"); # return unique widget id
    $int->need_tk('Img');
    my $bw = $int->declare_widget($int->call('image','create', 'photo', @_));
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
    my $int = $wint{$$self};
    my $w    = w_uniq($self, "tree"); # return unique widget id
    $int->need_tk('Tix');
    my %args = @_;
    my %sub_args;
    foreach (@{$subwidget_options{'Tree'}}) {
	$sub_args{$_} = delete $args{$_} if exists $args{$_};
    }
    # The hlist options must be passed in -options are creation time
    foreach my $opt (keys %sub_args) {
	my $cname = $opt;
	$cname =~ s/^-//;
	$args{'-options'} .= "\nhlist.$cname \"$sub_args{$opt}\""
    }
    my $tree = $int->declare_widget($int->call('tixTree', $w, %args));
    $special_widget_abilities{$w} = {
	headerCreate=>sub {
	    return $int->call($tree, 'subwidget', 'hlist',
			      'header', 'create', @_);
	},
    };
    return $tree;
}

my %scrolls; # How avoid this? Creating package would help, but this would be overkill.
sub Scrolled {
    print STDERR "(S)[[@_]]\n" if DEBUG();
    my $self = shift; # this will be a parent widget for newer button
    my $int = $wint{$$self};
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
    $int->need_tk("BWidget");
    my $w  = w_uniq($self, "sc"); # return unique widget id
    my $sw = $int->declare_widget($int->call('ScrolledWindow', $w,
					     -auto=>'both',
					     -scrollbar=>'both'));
    my $subw;
    {
	no strict 'refs';  # another option would be hash with values as subroutines
	$subw = &{"Tcl::Tk::Widget::$wtype"}($sw,%args);
    }
    $sw->setwidget($$subw);
    $scrolls{$$sw}=$$subw;
    return $sw;
}
=ignore
# attempt to implement 'Scrolled' a bit another way
sub not_Scrolled {
  print STDERR "(S)[[@_]]\n" if DEBUG();
  my $self = shift; # this will be a parent widget for newer button
  my $int = $wint{$$self};
  my $wtype = shift; # what type of scrolled widget
  die "wrong 'scrolled' type $wtype" unless $wtype =~ /^\w+$/;
  $int->need_tk("BWidget");
  $gwcnt++ while exists $wint{"$$self.sc$gwcnt"};
  # translate Scrolled parameter
  my %args = @_;
  my $sb = delete $args{'-scrollbars'};
  if ($sb) {
    # TODO (easy one) -- really process parameters to scrollbar. 
    # Now let them be just like 'osoe'
  }
  my $sw = $int->declare_widget($int->call('ScrolledWindow',"$$self.sc$gwcnt",-auto=>'both', -scrollbar=>'both')); # assumes existance of BWidget package
  my $w;
  {
    no strict 'refs';  # another option would be hash with values as subroutines
    $w = &{"Tcl::Tk::Widget::$wtype"}($sw,%args);
  }
  $sw->setwidget($$w);
  my $widg = new Tcl::Tk::Widget::MultipleWidget($int,$sw,[],$w,[]);
  return $widg;
}
=cut


sub DESTROY {}			# do not let AUTOLOAD catch this method

#
# Let Tcl/Tk/Tix process required method via AUTOLOAD mechanism
#
my %ptk2tcltk_mapper =
    (
     "optionAdd" => [ qw(option add) ],
     "fontCreate" => [ qw(font create) ],
     );
#     "fontNames" => [ qw(font names) ],

my %created_w_packages;
sub AUTOLOAD {
    print STDERR "((${$_[0]}|$::Tcl::Tk::Widget::AUTOLOAD|@_))\n" if DEBUG();
    my $w = shift;
    my $wp = $$w;
    my $method = $::Tcl::Tk::Widget::AUTOLOAD;
    $method =~ s/^(Tcl::Tk::Widget::((MainWindow|$ptk_w_names)::)?)//o or die "weird inheritance ($method)";
    my $package = $1;
    if (exists $ptk2tcltk{$method}) {
        print STDERR "creating $method (@_)\n" if DEBUG();
	unless (exists $created_w_packages{$method}) {
	    print STDERR "c-PACKAGE $method (@_)\n" if DEBUG();
	    $created_w_packages{$method}++;
	    die "not allowed widg name $method" unless $method=~/^\w+$/;
	    # here we create Widget package
	    my $package = $::VTEMP;
	    $package =~ s/\[\[widget-repl\]\]/$method/g;
	    eval "$package";
	    die $@ if $@;
	}
	my $sub = create_ptk_widget_sub($method);
	no strict 'refs';
	*{"$package$method"} = $sub;
	return $sub->($w,@_);
    }
    if (exists $ptk2tcltk_wm{$method}) {
        print STDERR "creating $method (@_)\n" if DEBUG();
	my $sub = sub {
	    my $self = shift;
	    my $wp = $$self;
	    $wp = '.' if $wp eq ''; # TODO -- optimize this away!
	    $wint{$$self}->call('wm',$method,$wp,@_);
	};
	no strict 'refs';
	*{"$package$method"} = $sub;
	return $sub->($w,@_);
    }
    if (exists $ptk2tcltk_mapper{$method}) {
        print STDERR "creating $method (@_)\n" if DEBUG();
	my $sub = sub {
	    my $self = shift;
	    $wint{$$self}->call(@{$ptk2tcltk_mapper{$method}},@_);
	};
	no strict 'refs';
	*{"$package$method"} = $sub;
	return $sub->($w,@_);
    }
    $wp = '.' if $package eq 'Tcl::Tk::Widget::MainWindow::';
    if (exists $special_widget_abilities{$wp} 
       && exists $special_widget_abilities{$wp}->{$method}) {
	no strict 'refs';
        return $special_widget_abilities{$wp}->{$method}->(@_);
    }
    # code below will always create subroutine that calls a method.
    # This could be changed to create only known methods and generate error
    # if method is, for example, misspelled.
    # so following check will be like 
    #    if (exists $knows_method_names{$method}) {...}
    my $sub;
    if ($method =~ /^([a-z]+)([A-Z][a-z]+)$/) {
        my ($meth, $submeth) = ($1, lc($2));
	if ($meth eq "grid") {
	    $sub = sub {
		my $w = shift;
		my $wp = $w->path;
		# TODO get rid of such "Scrollable" solution, reimplement
		if (exists $scrolls{$wp}) {$wp=$scrolls{$wp};}
		$wint{$wp}->call($meth, $submeth, $wp, @_);
	    };
	} elsif ($meth eq "after") {
	    $sub = sub {
		my $w = shift;
		my $wp = $w->path;
		# TODO get rid of such "Scrollable" solution, reimplement
		if (exists $scrolls{$wp}) {$wp=$scrolls{$wp};}
		$wint{$wp}->call($meth, $submeth, @_);
	    };
	} else {
	    $sub = sub {
		my $w = shift;
		my $wp = $w->path;
		# TODO get rid of such "Scrollable" solution, reimplement
		if (exists $scrolls{$wp}) {$wp=$scrolls{$wp};}
		$wint{$wp}->call($wp, $meth, $submeth, @_);
	    };
	}
    }
    else {
	$sub = sub {
	    my $w = shift;
	    my $wp = $w->path;
	    # TODO get rid of such "Scrollable" solution, reimplement
	    if (exists $scrolls{$wp}) {$wp=$scrolls{$wp};}
	    $wint{$wp}->call($wp, $method, @_);
	};
    }
    print STDERR "creating ($package)$method (@_)\n" if DEBUG();
    no strict 'refs';
    *{"$package$method"} = $sub;
    return $sub->($w,@_);
}

BEGIN {
# var to generate pTk package from
#(test implementation, will be implemented l8r better)
$::VTEMP = <<'EOWIDG';
package Tcl::Tk::Widget::[[widget-repl]];

use vars qw/@ISA/;
@ISA = qw(Tcl::Tk::Widget);

sub DESTROY {}			# do not let AUTOLOAD catch this method

sub AUTOLOAD {
    print STDERR "<<@_>>\n" if $Tcl::Tk::DEBUG;
    $::Tcl::Tk::Widget::AUTOLOAD = $::Tcl::Tk::Widget::[[widget-repl]]::AUTOLOAD;
    return &Tcl::Tk::Widget::AUTOLOAD;
}
1;
print STDERR "<<starting [[widget-repl]]>>\n" if $Tcl::Tk::DEBUG;
EOWIDG
}

package Tcl::Tk::Widget::Scrolled;
#TODO

package Tcl::Tk::Widget::MultipleWidget;
# multiple widget is an object that for each option has a path
# to refer in Tcl/Tk and for method has corresponding method in Tcl/Tk

#syntax
# my $ww = new Tcl::Tk::Widget::MultipleWidget(
#   $int,
#   $w1, [qw(-opt1 -opt2 ...), '-optn=-opttcltk', -optm=>sub{...}],
#   $w2, [qw(-opt1 -opt2 ...)],
#   ...
# );
# methods are specified like options with starting '&' with optional
# list of replacement options after slash.
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
	               # "opt2"=>[$w1,'opt2',{},$w2,'tkopt2',{}],
		       # "&meth"=>[$w2,'tkmethod',{opt7=>tkopt7,opt8=>opt8,opt9=>tkopt9}]
	_def_opt => undef,  # widget to accept unrecognized options
	_def_meth => undef, # widget to accept unrecognized methods
    };
    my @args = @_;
    for (my $i=0; $i<$#args; $i+=2) {
        my $w = $args[$i];
        $w = $int->declare_widget($w) unless ref $w;
        my @a = @{$args[$i+1]};
        for (my $j=0; $j<=$#a; $j++) {
            my ($p, $prepl) = ($a[$j]);
	    if ($p eq '-') {
		$self->{_def_opt} = $w;
	    }
	    elsif ($p eq '&') {
		$self->{_def_meth} = $w;
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
            if ($j+1<=$#a && ref ($a[$j+1]) eq 'CODE') {
                $prepl = $a[$j+1];
                splice @a, $j+1, 1;
            }
	    $self->{_subst}->{"$meth$p"} ||= []; # create empty array if not exists
	    push @{$self->{_subst}->{"$meth$p"}}, $w, $prepl, $hsubst;
        }
    }
    $self->{_path} = $args[0]->path;
    return bless $self, $package;
}
sub path {${$_[0]->{_path}}}

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
		    @res = $replwid->configure($replnam,$args{$optname});
		    #$w->{_int}->MainLoop;
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
	die "NYI configure 1";
    }
    else {
	# here $#_==-1, no arguments given
	# Returns a list of lists for all the options supported by widget
	die "NYI configure 2";
    }
    die "NYI configure 3";
}
sub cget {
    die "NYI cget";
}

#
# Unlike for Tcl::Tk::Widget::Button and similar, does not autovivify
# required method; instead it uses autoloading every time, because
# otherwise methods from different MultipleWidgets will mix
sub AUTOLOAD {
    #print STDERR "##@_($::Tcl::Tk::Widget::MultipleWidget::AUTOLOAD)##\n";
    # first look into substitute hash
    # if not found - call that method from "default" widget ...->{_def_meth}
    my $wmeth = $::Tcl::Tk::Widget::MultipleWidget::AUTOLOAD;
    $wmeth=~s/::MultipleWidget\b//;
    my ($pmeth) = ($wmeth=~/::([^:]+)$/);
    if (exists $_[0]->{_subst}->{"&$pmeth"}) {
	my $mdo = $_[0]->{_subst}->{"&$pmeth"};
	my @args = @_[1..$#$_];
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
	    no strict 'refs';
	    return eval "\$replwid->$replnam(%opts)";
	    #return &{$replnam}($replwid,%opts);
	}
    }
    elsif (exists $_[0]->{_def_meth}) {
	no strict 'refs';
	return &{$wmeth}($_[0]->{_def_meth},@_[1..$#_]);
    }
    die "this MultipleWidget is not able to process $wmeth";
    # currently not reached
    $::Tcl::Tk::Widget::AUTOLOAD = $::Tcl::Tk::Widget::MultipleWidget::AUTOLOAD;
    return &Tcl::Tk::Widget::AUTOLOAD;
}

package Tcl::Tk::Widget::MainWindow;

use vars qw/@ISA/;
@ISA = qw(Tcl::Tk::Widget);

sub DESTROY {}			# do not let AUTOLOAD catch this method

sub AUTOLOAD {
    $::Tcl::Tk::Widget::AUTOLOAD = $::Tcl::Tk::Widget::MainWindow::AUTOLOAD;
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

bootstrap Tcl::Tk;

1;

