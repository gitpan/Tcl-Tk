# This is WinCE Makefile.PL
#
# invoke this as
#    perl -MCross=[your-cross-name] ceMakefile.pl PERL_CORE=1 PERL_SRC=[your-perl-distribution-for-wince-crosscompiling]
# All appropriate environment variables shoult be set properly, such
# as OSVERSION, PLATFORM, WCEROOT, SDKROOT. This is usually done with
# appropriate 'bat' file. such as WCEMIPS.BAT
#

#
# edit following two paths to reflect your situation
# when editing please note that there should be tcl84.lib and tk84.lib
# libraries at "$tcldir\\wince\\$Cross::platform-release" and
# "$tkdir\\wince\\$Cross::platform-release" appropriately
#
my $tcldir='D:\personal\pocketPC\tcltk\84a2\tcl8.4a2';
my $tkdir='D:\personal\pocketPC\tcltk\84a2\tk8.4a2';

use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => "Tcl::Tk",
	DISTNAME => "TclTk",
	VERSION_FROM => 'Tk.pm',
	PREREQ_PM => {
	},
    LIBS => [
      "-l$tcldir\\wince\\$Cross::platform-release\\tcl84.lib -l$tkdir\\wince\\$Cross::platform-release\\tk84.lib",
      ],
    INC => "-I$tcldir\\generic -I$tkdir\\generic  -I$tkdir\\xlib",
      );
