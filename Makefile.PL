#!perl -w

use strict;
use Getopt::Long qw(GetOptions);
use ExtUtils::MakeMaker;

my $tclsh = 'tclsh';
my $tclconfig;
my $tkconfig;
my $buildspec;
my $libpath;
my $incpath;

GetOptions("tclsh=s", \$tclsh,
	   "tclconfig=s", \$tclconfig,
	   "buildspec", \$buildspec,
	  )
    || die <<EOT;

Usage: perl Makefile.PL [--tclsh <path>] [--tclconfig <path>]
                        [--buildspec] [<makemaker opts>...]

or for WinCE cross-compilation:

       perl -MCross=[your-cross-name] Makefile.PL PERL_CORE=1
             PERL_SRC=[your-perl-distribution-for-wince-crosscompiling]

EOT

if (defined $Cross::platform) {
    # All appropriate environment variables shoult be set properly, such
    # as OSVERSION, PLATFORM, WCEROOT, SDKROOT. This is usually done with
    # appropriate 'bat' file. such as WCEMIPS.BAT
    #
    # edit following two paths to reflect your situation
    # when editing please note that there should be tcl84.lib and tk84.lib
    # libraries at "$tcldir\\wince\\$Cross::platform-release" and
    # "$tkdir\\wince\\$Cross::platform-release" appropriately
    #
    my $tcldir = 'V:\Work\TCLCompile\tcl8.4.6-ce';
    my $tkdir = 'V:\Work\TCLCompile\tk8.4.6-ce';

    WriteMakefile(
        NAME => "Tcl::Tk",
        VERSION_FROM => 'lib/Tcl/Tk.pm',
        LIBS => ["-l$tcldir\\win\\Release\\tcl84.lib -l$tkdir\\win\\Release\\tk84.lib"],
	INC => "-I$tcldir\\generic -I$tkdir\\generic  -I$tkdir\\xlib",
    );
    exit;
}

if ($tclconfig) {
    die "Tcl config file '$tclconfig' not found\n" unless (-f $tclconfig);
    my $libspecvar = "TCL_LIB_SPEC";
    $libspecvar    = "TCL_BUILD_LIB_SPEC" if $buildspec;
    ($libpath, $incpath) = process_tclconfig($tclconfig, $libspecvar);
    if (!$tkconfig) {
	$tkconfig = $tclconfig;
	$tkconfig =~ s/tclConfig/tkConfig/;
    }
    $libspecvar = "TK_LIB_SPEC";
    $libspecvar = "TK_BUILD_LIB_SPEC" if $buildspec;
    my ($tklibpath, $tkincpath) =
	process_tclconfig($tkconfig, $libspecvar, "TK_INCLUDE_SPEC");
    $libpath .= " $tklibpath";
    $incpath .= " $tkincpath";
} else {
    my %tclcfg;
    require Tcl;
    my $interp = new Tcl;
    $interp->Init();

    #$interp->SetVar('tcl_libPath','/usr/lib');
    my $tcl_libPath = $interp->GetVar('tcl_libPath');
    my $tcl_library = $interp->GetVar('tcl_library');
    my $tcl_version = $interp->GetVar('tcl_version');
    print "tcl_library=$tcl_library\ntcl_libPath=$tcl_libPath\n";
    eval {
	$interp->Eval('package require Tk');
    };
    if ($@) {
	print STDERR "Warning: could not load Tk from tclsh; please edit and" .
	    " check Makefile.PL manually to reflect your system.";
	$interp->SetVar('tk_version','8.3');
    }
    my $tk_version = $interp->GetVar('tk_version');
    print "tcl_version=$tcl_version\ntk_version=$tk_version\n";

    if ($^O =~ /^(MSWin32|freebsd)$/) {
	$tcl_library =~ /^(.*)[\\\/]lib[\\\/]/;
	$libpath = "-L$1/lib";
	$incpath = "-I$1/include";
	if (-d "/usr/local/include/tcl$tcl_version") {
	    $incpath .= " -I/usr/local/include/tcl$tcl_version -I/usr/local/include/tk$tk_version";
	}
	s/\.// for $tcl_version, $tk_version;
    }
    else {
	$_='' for $tcl_version, $tk_version;
    }

    if ($^O ne 'MSWin32') {
	$incpath .= " -I/usr/X11R6/include";
    }
    $libpath .= " -ltcl$tcl_version -ltk$tk_version";
}
print "LIBS = $libpath\n";
print "INC  = $incpath\n";

WriteMakefile(
    NAME => "Tcl::Tk",
    VERSION_FROM => 'lib/Tcl/Tk.pm',
    PREREQ_PM => {
	Tcl => 0.76,
    },
    LIBS => [$libpath],
    INC => $incpath,
);

sub process_tclconfig {
    # Process a tclConfig.sh file for build info
    my $tclconfig = shift;
    my $libspecvar = shift || "TCL_LIB_SPEC";
    my $incspecvar = shift || "TCL_INCLUDE_SPEC";

    open(TCLSH, $tclconfig)
	or die "error opening file '$tclconfig': $!\n";
    print "Using config data in $tclconfig\n";
    my $tclcfg = join '', <TCLSH>;
    close(TCLSH);
    my %tclcfg = $tclcfg =~ /^(\w+)=['"]?(.*?)["']?\n/gm;

    # Handle sh subs like ${TCL_DBGX}
    $tclcfg{$libspecvar} =~ s/\$\{(\w+)\}/$tclcfg{$1}/g;
    # Handle any cygdrive-style paths
    $tclcfg{$libspecvar} =~ s,/cygdrive/(\w)/,$1:/,ig;
    return $tclcfg{$libspecvar}, $tclcfg{$incspecvar};
}
