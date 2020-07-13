#
#======================================================================
# vi: set filetype=make ts=4 sts=4 sw=4 noet ai:
#======================================================================
#
# zqcc Makefile
#
# GNU Make required
# GCC >= 2.95 required; >= 3 recommended
#
# Original by Tonik
# Updated by oldman and Massa
#
#======================================================================

# the name of our Makefile (don't know how to detect this automatically)
MAKEFILE		?=Makefile

# the source/object suffixes we use here:
.SUFFIXES:
.SUFFIXES:	.c .o .c.o .cpp .cpp.o .rc

# detect pseudo rules which does not generate a file
.PHONY:	\
	help default \
	target \
	all debug release \
	clean clobber distclean

# compilation tool and detection of targets/achitecture
CC						:=gcc
CC_BASEVERSION			:=$(shell $(CC) -dumpversion | sed -e 's/\..*//g')
CXX						:=g++
CXX_BASEVERSION			:=$(shell $(CXX) -dumpversion | sed -e 's/\..*//g')
MACHINE					:=$(shell $(CC) -dumpmachine)
ARCH					:=$(shell echo $(MACHINE) | sed -e 's/.*mingw32.*/mingw32/g' -e 's/\-.*//g' -e 's/i.86/x86/g' -e 's/hppa.*/hppa/')

ifeq ($(ARCH),x86)		# Linux/x86
	DEST_ARCH			:=x86
	#ARCH_CFLAGS			:=-march=$(shell echo $(MACHINE) | sed -e 's/\-.*//g')
endif
ifeq ($(ARCH),ppc)		# MacOS-X/ppc
	DEST_ARCH			:=ppc
	ARCH_CFLAGS			:=-arch ppc
endif
ifeq ($(ARCH),hppa)		# HP-UX/PA-RISC
	DEST_ARCH			:=pa-risc
	ARCH_CFLAGS			:=-mpa-risc-$(shell echo $(MACHINE) | sed -e 's/hppa\([0-9]\).\([0-9]\).*/\1-\2/g')
endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	DEST_ARCH			:=x86
	ARCH_CFLAGS			:=-mwin32 -mno-cygwin -D_CONSOLE -mconsole
endif

#======================================================================
# Program Version
#======================================================================
VERSION					 =0.16dev

#======================================================================
# Compiler Flags
#======================================================================
PRJ_FLAGS				 =
BASE_CFLAGS				 =-Wall -Wno-format-y2k $(PRJ_FLAGS) $(ARCH_CFLAGS)
BASE_RELEASE_CFLAGS		 =-ffast-math -funroll-loops \
						  -fomit-frame-pointer -fexpensive-optimizations

ifeq ($(CC_BASEVERSION),2)
	# gcc 2.95.x does not know about -falign-XXX optimizations...
	BASE_RELEASE_CFLAGS	+= -O3
else
	# NOTE: Removed for clang on OS X
	#BASE_RELEASE_CFLAGS	+= -O6
ifeq ($(ARCH),ppc)
	BASE_RELEASE_CFLAGS	+= -falign-loops=16 -falign-jumps=16 -falign-functions=16
else
	# NOTE: Removed for clang on Mavericks
	#BASE_RELEASE_CFLAGS	+= -falign-loops=2 -falign-jumps=2 -falign-functions=2
endif
endif
BASE_DEBUG_CFLAGS		 =-g -D_DEBUG

ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	BASE_CFLAGS			+= -DMINGW32
endif
ifeq ($(ARCH),ppc)		# MacOS-X/ppc
	BASE_CFLAGS			+= -DHAVE_STRLCAT -DHAVE_STRLCPY -DBIGENDIAN -Ddarwin
endif
ifeq ($(ARCH),powerpc)	# Linux/PPC
	BASE_CFLAGS			+= -DBIGENDIAN
endif
ifeq ($(ARCH),hppa)		# HP-UX/PA-RISC
	BASE_CFLAGS			+= -DBIGENDIAN -Dhpux
endif

RELEASE_CFLAGS			 =$(BASE_CFLAGS) $(BASE_RELEASE_CFLAGS)
DEBUG_CFLAGS			 =$(BASE_CFLAGS) $(BASE_DEBUG_CFLAGS)

# linker flags
LDFLAGS					 =
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	LDFLAGS				+= -lkernel32
endif
ifeq ($(ARCH),hppa)		# HP-UX/PA-RISC
	LDFLAGS				+= -lhppa
endif

# target executables
TARGETS					?=zqcc
DEBUG_TARGETS			?=zqcc_debug


# just to make sure everything is on it's right place...
_DEBUG					?=0
_RELEASE				?=0

ifneq ($(_RELEASE),0)
	_DEBUG				 =0
endif

ifeq ($(_DEBUG),0)
	_RELEASE			 =1
endif

ifndef CFLAGS
ifneq ($(_DEBUG),0)
	CFLAGS			 =$(DEBUG_CFLAGS)
else
	CFLAGS			 =$(RELEASE_CFLAGS)
endif
endif

#======================================================================
# setup and build rules:
#======================================================================
ifdef MAKEFILE
	MYMAKEFLAGS			:=-f $(MAKEFILE)
endif
MYMAKEFLAGS				+= $(MAKEFLAGS)


#-----------------------
# building everything
#-----------------------
all:
	@echo "*** Generating $(TARGETS) (release version)..."
	@$(MAKE) $(MYMAKEFLAGS) clean
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 BUILD_DIR="$(RELEASE_BUILD_DIR)" CFLAGS="$(RELEASE_CFLAGS)" target
	@echo "*** Generating $(DEBUG_TARGETS) (debug version)..."
	@$(MAKE) $(MYMAKEFLAGS) clean
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 DEBUG=1 CFLAGS="$(DEBUG_CFLAGS)" TARGETS="$(DEBUG_TARGETS)" target

debug:
	@echo "*** Generating $(DEBUG_TARGETS) (debug version)..."
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 DEBUG=1 CFLAGS="$(DEBUG_CFLAGS)" TARGETS="$(DEBUG_TARGETS)" target

release:
	@echo "*** Generating $(TARGETS) (release version)..."
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 BUILD_DIR="$(RELEASE_BUILD_DIR)" CFLAGS="$(RELEASE_CFLAGS)" target

target:					 $(TARGETS) striptargets
	@echo "*** Target(s) $(TARGETS) have been built"

striptargets:			 $(TARGETS)
ifneq ($(_RELEASE),0)
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	strip $(addsuffix .exe,$(TARGETS))
else
	strip $(TARGETS)
endif
	@echo "*** Release target(s) $(TARGETS) have been stripped"
endif


#-----------------------
# help
#-----------------------
help:
	@echo "To compile zqcc, do one of the following:"
	@echo ""
	@echo "  $(MAKE) clean               - remove generated objects."
	@echo "  $(MAKE) distclean           - remove generated objects and executable."
	@echo ""
	@echo "  $(MAKE) all                 - build zqcc release and debug version."
	@echo "  $(MAKE) _DEBUG=1 <target>   - build <target> as debug version."
	@echo "  $(MAKE) debug               - build zqcc debug (synonym to $(MAKE) _DEBUG=1 target)."
	@echo "  $(MAKE) release             - build zqcc release (synonym to $(MAKE) target)."
	@echo ""


#-----------------------
# cleanup the stuff
#-----------------------
clean:
	@echo "*** Removing object files"
	@-(rm -f *.o 2>/dev/null || true)

clobber distclean:		clean
	@echo "*** Removing Executable(s) \"$(TARGETS) $(DEBUG_TARGETS)\""
	@-(rm -rf $(TARGETS) $(DEBUG_TARGETS) 2>/dev/null || true)


#-----------------------
# objects
#-----------------------
ZQCC_OBJS				 = cmdlib.o pr_comp.o pr_lex.o qcc.o
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	ZQCC_OBJS			+=winres.o
endif

#-----------------------
# empty rule for nothing
#-----------------------
$(MAKEFILE):

#======================================================================
# rules for "real" files and dirs:
#======================================================================

#-----------------------
# common rules
#-----------------------
.c.o:
		$(CXX) -c $(CFLAGS) -o $@ $*.c
.cpp.o:
		$(CXX) -c $(CFLAGS) -o $@ $*.cpp

#-----------------------
# executables
#-----------------------
zqcc:					 $(ZQCC_OBJS)
	$(CXX) $(RELEASE_CFLAGS) -o $@ \
		$(ZQCC_OBJS) \
		$(LDFLAGS)

zqcc_debug:				 $(ZQCC_OBJS)
	$(CXX) $(DEBUG_CFLAGS) -o $@ \
		$(ZQCC_OBJS) \
		$(LDFLAGS)

winres.o:				 zqcc.rc resource.h
	windres $(filter -D%,$(CFLAGS)) -i zqcc.rc -o $@

#-----------------------
# dependencies
#-----------------------
cmdlib.o:				 cmdlib.cpp cmdlib.h

pr_comp.:				 pr_comp.cpp qcc.h pr_comp.h cmdlib.h

pr_lex.o:				 pr_lex.cpp qcc.h pr_comp.h cmdlib.h

qcc.o:					 qcc.cpp qcc.h pr_comp.h cmdlib.h

