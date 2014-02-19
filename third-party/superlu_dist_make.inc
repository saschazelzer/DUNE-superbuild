############################################################################
#
#  Program:         SuperLU_DIST
#
#  Module:          make.inc
#
#  Purpose:         Top-level Definitions
#
#  Creation date:   February 4, 1999   version alpha
#
#  Modified:        September 1, 1999  version 1.0
#                   March 15, 2003     version 2.0
#                   November 1, 2007   version 2.1
#                   September 1, 2011   version 3.0
#
############################################################################
#
#  The machine (platform) identifier to append to the library names
#
PLAT         = _i386

#
#  The name of the libraries to be created/linked to
#
DSuperLUroot = @SuperLU_DIST_INSTALL_DIR@
DSUPERLULIB  = $(DSuperLUroot)/lib/libsuperlu_dist.a
#
BLASDEF      = -DUSE_VENDOR_BLAS
BLASLIB      = -lblas
METISLIB     = -L@METIS_LIBRARY_DIR@ -lmetis
PARMETISLIB  = -L@ParMETIS_LIBRARY_DIR@ -lparmetis

# Define the required Fortran libraries, if you use C compiler to link
FLIBS        = 

# Define all the libraries
LIBS         = $(DSUPERLULIB) $(BLASLIB) $(PARMETISLIB) $(METISLIB) $(FLIBS)

#
#  The archiver and the flag(s) to use when building archive (library)
#  If your system has no ranlib, set RANLIB = echo.
#
ARCH         = ar
ARCHFLAGS    = cr
RANLIB       = ranlib

############################################################################
# C compiler setup
CC           = @MPI_C_COMPILER@
# CFLAGS should be set to be the C flags that include optimization
CFLAGS       = -O3 \
               -DDEBUGlevel=0 -DPRNTlevel=0 -DPROFlevel=0 \
              # -D_LONGINT
#
# NOOPTS should be set to be the C flags that turn off any optimization
NOOPTS       = -O0
############################################################################
# FORTRAN compiler setup
FORTRAN      = mpif77
F90FLAGS     = 
############################################################################
LOADER       = mpif77
LOADOPTS     = 
############################################################################
#  C preprocessor defs for compilation (-DNoChange, -DAdd_, or -DUpCase)
#
#  Need follow the convention of how C calls a Fortran routine.
#
CDEFS        = -DAdd__
