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
	Tk_Window	mainWindow = NO_INIT
    CODE:
#if TK_MAJOR_VERSION < 4 || TK_MAJOR_VERSION == 4 && TK_MINOR_VERSION < 1
	mainWindow = Tk_CreateMainWindow(interp, display, name, "Tk");
	if (!mainWindow)
	    croak(interp->result);
	Tk_GeometryRequest(mainWindow, 200, 200);
	if (sync)
	    XSynchronize(Tk_Display(mainWindow), True);
#endif

void
Tk_Init(interp)
	Tcl	interp
    CODE:
	if (Tk_Init(interp) != TCL_OK)
	    croak(interp->result);
