use Tcl;

my %tclcfg;
my ($libpath, $incpath) = ('','');
my $libpref = '';

my $interp = new Tcl;
$interp->Init();

#$interp->SetVar('tcl_libPath','/usr/lib');
my $tcl_libPath = $interp->GetVar('tcl_libPath');
my $tcl_library = $interp->GetVar('tcl_library');
my $tcl_version = $interp->GetVar('tcl_version');
print STDERR "tcl_library=$tcl_library; tcl_libPath=$tcl_libPath\n";
eval {
    $interp->Eval('package require Tk');
};
if ($@) {
    print STDERR "Warning: could not load Tk from tclsh; please edit and check".
            " Makefile.PL manually to reflect your system.";
    $interp->SetVar('tk_version','8.3');
}
my $tk_version = $interp->GetVar('tk_version');
print STDERR "tcl_version=$tcl_version; tk_version=$tk_version\n";

if ($^O =~ /^(MSWin32|freebsd)$/) {
    $incpath = "-I/usr/local/include/tcl$tcl_version -I/usr/local/include/tk$tk_version";
    s/\.// for $tcl_version, $tk_version;
    $tcl_library =~ /^(.*)[\\\/]lib[\\\/]/;
    $libpath = "-L$1/lib";
    $incpath .= " -I$1/include";
}
else {
    $libpref = '';
    $_='' for $tcl_version, $tk_version;
}

if ($^O ne 'MSWin32') {
    $incpath .= " -I/usr/X11R6/include";
}

use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => "Tcl::Tk",
	VERSION_FROM => 'lib/Tcl/Tk.pm',
	PL_FILES => {},
	PM => {'lib/Tcl/Tk.pm'=>'$(INST_LIBDIR)/Tk.pm'},
	PREREQ_PM => {
		Tcl => 0.6,
	},
	LIBS => ["$libpath -l${libpref}tcl$tcl_version -l${libpref}tk$tk_version"],
	INC => "$incpath",
      );
