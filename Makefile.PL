#!perl -w

use strict;
use Getopt::Long qw(GetOptions);
use ExtUtils::MakeMaker;

my $tclsh = "tclsh";
if ($^O eq 'FreeBSD') {$tclsh.='8.4'}

GetOptions("tclsh=s", \$tclsh,
	  )
    || die <<EOT;

Usage: perl Makefile.PL [--tclsh <path>] [<makemaker opts>...]

EOT

open TCLSH, "$tclsh test-for-tk.tcl|";
my $res = join '', <TCLSH>;

unless ($res =~ /^ok/m) {
  die <<EOS;
your Tcl/Tk installation fails to find Tk package
one of possible reasons is missing file 'pkgIndex.tcl' in ..../tk8.4/
directory; please check if you can feed 'package require Tk' to tclsh
EOS
}

WriteMakefile(
    NAME => "Tcl::Tk",
    VERSION_FROM => 'lib/Tcl/Tk.pm',
    PREREQ_PM => {
	Tcl => 0.84,
    },
);
