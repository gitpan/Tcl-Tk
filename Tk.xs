/* 
 * Tk.xs --
 *
 *	This file contains XS code for the Perl's Tcl/Tk bridge module.
 *
 * Copyright (c) 1994-1997, Malcolm Beattie
 * Copyright (c) 2004 ActiveState Corp., a division of Sophos PLC
 *
 * RCS: @(#) $Id: Tk.xs,v 1.2 2004/04/09 19:25:18 hobbs2 Exp $
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <tcl.h>
#include <tk.h>

typedef Tcl_Interp *Tcl;

MODULE = Tcl::Tk		PACKAGE = Tcl::Tk	PREFIX = Tk_

void
Tk_MainLoop(...)

MODULE = Tcl::Tk		PACKAGE = Tcl

void
CreateMainWindow(interp, display, name, sync = 0)
	Tcl		interp
	char *		display
	char *		name
	int		sync
    CODE:
	/*
	 * This function was needed for Tk pre-8 and sticks around
	 * for compatability reasons.
	 */


void
Tk_Init(interp)
	Tcl	interp
    CODE:
	if (Tk_Init(interp) != TCL_OK)
	    croak(interp->result);
