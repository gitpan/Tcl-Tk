#!perl -w

use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => "Tcl::Tk",
    VERSION_FROM => 'lib/Tcl/Tk.pm',
    PREREQ_PM => {
	Tcl => 0.80,
    },
);
