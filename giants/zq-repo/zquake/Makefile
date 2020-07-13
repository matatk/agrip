#
#===========================================================================
# vi: set filetype=make ts=4 sts=4 sw=4 noet ai:
#===========================================================================
#
# ZQuake Makefile
#
# GNU Make required
# GCC >= 2.95 required; >= 3 recommended
#
# Original by Tonik
# Updated by oldman and Massa
# With thanks to Fuh
#
#===========================================================================
# NOTE:
#   use "make help" to get information about possible targets and options!
#===========================================================================
# NOTE ABOUT COMPILATION WITH MINGW/MSYS (5 March 2005 - Massa):
# ----------------------------------------------------------------
# If you want to compile the stuff for Win32 inside the MingW/MSYS
#   environment, you have to install the MSYS environment of course
#   the MingW package itself and the w32api-package.
# For the GL clients the directx-includes and libraries for MingW are
#   also needed! A ready to use package which works for me can be
#   downloaded here:
#     http://www.libsdl.org/extras/win32/common/directx-devel.tar.gz
# After downloading the package open your MSYS environment and unpack
#   it to the mingw directory:
#   > cd /mingw
#   > tar xvfz /c/<dir_where_the_package_is>/directx-devel.tar.gz
# After that you should be able to build the GL-clients...
# ATTENTION: don't try to use the MS versions of the DirectX headers.
#   They suck totally and will produce a lot of compiler errors!
# BTW, the server compiles without the need of directx stuff...
#
# Here are the versions which I used to successfully compile zquake:
#   MSYS-1.0.11-2004.04.30-1
#   MingW-3.2.0-RC-3
#   w32api-3.2
#   binutils-2.13.90-20021006-2 (I had problems with assembler from
#                                newer binutils in different project)
#   http://www.libsdl.org/extras/win32/common/directx-devel.tar.gz
#
# What's missing?
# - the software clients are (currently) not compilable inside the MingW
#   environment (scitech libraries not included)!
# - I did not create rules to build the zqclient versions.
#   Are they needed?
#===========================================================================
#

# the name of our Makefile (don't know how to detect this automatically)
MAKEFILE		?=Makefile

# the source/object suffixes we use here:
.SUFFIXES:
.SUFFIXES:	.c .o .s

# detect pseudo rules which do not generate a file
.PHONY:	\
	help default \
	print_vars \
	targets \
	all all_debug all_release build_debug build_release \
	server server_debug server_release \
	soft soft_debug soft_release \
	console console_debug console_release \
	gl gl_debug gl_release \
	clean clean-debug clean_debug clean-release clean_release \
	clobber clobber-debug clobber_debug clobber-release clobber_release \
	distclean distclean-debug distclean_debug distclean-release distclean_release \
	clean2 clobber2

# compilation tool and detection of targets/achitecture
CC						:=gcc
CC_BASEVERSION			:=$(shell $(CC) -dumpversion | sed -e 's/\..*//g')
MACHINE					:=$(shell $(CC) -dumpmachine)
ARCH					:=$(shell echo $(MACHINE) | sed -e 's/.*mingw32.*/mingw32/g' -e 's/\-.*//g' -e 's/i.86/x86/g' -e 's/hppa.*/hppa/')
MODE_PROGS               =555
INSTALL         		 =install
INSTALL_PROGRAM    		 =$(INSTALL) -s -m $(MODE_PROGS)
INSTALL_FILE    		 =$(INSTALL) -m $(MODE_FILES)
INSTALL_DIR     		 =$(INSTALL) -m $(MODE_DIRS) -d

# in MingW environment we need to detect the version of
#   windres (part of binutils), versions prior to 2.15.x
#   have a problem with our client resource file...
WINDRES_CHECK			:=0
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	WINDRES				:=$(shell which windres)
	WINDRES_VERSION		:=$(shell $(WINDRES) -V | grep "GNU windres" | awk '{ print $$3 }')
	WINDRES_VER1		:=$(shell echo $(WINDRES_VERSION) | sed -e 's/^\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/g')
	WINDRES_VER2		:=$(shell echo $(WINDRES_VERSION) | sed -e 's/^\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/g')
	WINDRES_VER3		:=$(shell echo $(WINDRES_VERSION) | sed -e 's/^\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/g')

	WINDRES_CHECK		:=$(shell [ $(WINDRES_VER1) -eq 2 ] && [ $(WINDRES_VER2) -lt 15 ] && echo 0 || echo 1)
endif

# Mac OSX Tiger (and others) : powerpc -> ppc ; also consider intel macs
#ifeq ($(MACHINE),powerpc-apple-darwin8)	# MacOS-10.4/ppc
#	ARCH := ppc
#endif
#ifeq ($(MACHINE),powerpc-apple-darwin9)	# MacOS-10.5/ppc
#	ARCH := ppc
#endif
#ifeq ($(MACHINE),i686-apple-darwin9)
#	ARCH := intelmac
#endif

# We need to make universal binaries for all (current) MacOS X versions, so that we can have a nice setup program to, erm, set it up later and that our users don't need to care which release they're downloading (we're using Macs, here, people!)
ifneq (,$(findstring apple,$(MACHINE)))
	ARCH :=mac
endif

# add special architecture based flags
ifeq ($(ARCH),x86)		# Linux/x86
	DEST_ARCH			:=x86
	ARCH_CFLAGS			:=-march=$(shell echo $(MACHINE) | sed -e 's/\-.*//g')
endif
#ifeq ($(ARCH),ppc)		# MacOS-X/ppc
#	DEST_ARCH			:=ppc
#	ARCH_CFLAGS			:=-arch ppc -faltivec -maltivec -mcpu=7450 -mtune=7450 -mpowerpc -mpowerpc-gfxopt
#	ifeq ($(CC_BASEVERSION),4) # auto vectorize if we're using gcc4.0+
#		ARCH_CFLAGS			+= -ftree-vectorize
#	endif
#endif
#ifeq ($(ARCH),intelmac)		# MacOS-X/intel
#	DEST_ARCH			:=intelmac
#	ARCH_CFLAGS			:=-march=$(shell echo $(MACHINE) | sed -e 's/\-.*//g')
#endif
ifeq ($(ARCH),mac)
	# NB: we support Tiger and Leopard only.
	# NB2: we add all that stuff about OpenGL because of a bug in Leopard -- see http://wiki.finkproject.org/index.php/Fink:Packaging:Preparing_for_10.5#OpenGL_Bug
	# NB3: Add trick to disable security checks in Mavericks
	# NB4: Add include path for Yosemite
	ARCH_CFLAGS :=-I/opt/local/include/ -I/usr/local/include -D_FORTIFY_SOURCE=0
	LDFLAGS :=-Wl,-dylib_file,/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib:/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib
endif
ifeq ($(ARCH),hppa)		# HP-UX/PA-RISC
	DEST_ARCH			:=pa-risc
	ARCH_CFLAGS			:=-mpa-risc-$(shell echo $(MACHINE) | sed -e 's/hppa\([0-9]\).\([0-9]\).*/\1-\2/g')
endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	DEST_ARCH			:=x86
	ARCH_CFLAGS			:=-mwin32 -mno-cygwin
endif

#======================================================================
# Program Version
#======================================================================
VERSION					 =0.17

#======================================================================
# Output Directories
#======================================================================
# location of source relative to makefile
MAIN_DIR				:=.
CLIENT_DIR				?=$(MAIN_DIR)/source
SERVER_DIR				?=$(MAIN_DIR)/source

DEBUG_BUILD_DIR			 =$(MAIN_DIR)/debug-$(ARCH)
RELEASE_BUILD_DIR		 =$(MAIN_DIR)/release-$(ARCH)

# compiler flags
PRJ_FLAGS				 = -DVWEP_TEST #-DHALFLIFEBSP
MAUTH_FLAGS				 =-DMAUTH # the Master AUTHentication patch
BASE_CFLAGS				 =-Wall -Wno-format-y2k -DAGRIP $(PRJ_FLAGS) $(ARCH_CFLAGS) $(MAUTH_FLAGS)
BASE_RELEASE_CFLAGS		 =-ffast-math -fomit-frame-pointer -fexpensive-optimizations
ifneq ($(CC_BASEVERSION),4) # if we're not auto-vectorizing then we can unroll the loops (mdfour ahoy)
	BASE_RELEASE_CFLAGS  += -funroll-loops
endif

ifeq ($(CC_BASEVERSION),2)
	# gcc 2.95.x does not know about -falign-XXX optimizations...
	BASE_RELEASE_CFLAGS	+= -O3
else
	# NOTE: removed for clang on Mavericks
	#BASE_RELEASE_CFLAGS	+= -O6
ifeq ($(ARCH),ppc)
	BASE_RELEASE_CFLAGS	+= -falign-loops=16 -falign-jumps=16 -falign-functions=16
else
	# NOTE: Removed for clang on Mavericks
	#BASE_RELEASE_CFLAGS	+= -falign-loops=2 -falign-jumps=2 -falign-functions=2
endif
endif
BASE_DEBUG_CFLAGS		 =-g -D_DEBUG

ifeq ($(ARCH),x86)		# Linux/x86
	# use define for special assembly routines and usage for DGA based mousecode:
	BASE_CFLAGS			+= -Did386 -DUSE_DGA -DUSE_ALSA
	CL_DLFLAGS			+= -ldl
endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	# use define for special assembly routines:
	BASE_CFLAGS			+= -Did386 -DMINGW32
endif
#ifeq ($(ARCH),ppc)		# MacOS-X/ppc
#	BASE_CFLAGS			+= -DHAVE_STRLCAT -DHAVE_STRLCPY -DBIGENDIAN -Ddarwin -DSDL -I/Library/Frameworks/SDL.framework/Versions/A/Headers/
#endif
#ifeq ($(ARCH),intelmac)		# MacOS-X/intel
#	BASE_CFLAGS			+= -DHAVE_STRLCAT -DHAVE_STRLCPY -Ddarwin -DSDL -I/Library/Frameworks/SDL.framework/Versions/A/Headers/
#endif
ifeq ($(ARCH),mac)
	BASE_CFLAGS			+= -DHAVE_STRLCAT -DHAVE_STRLCPY -Ddarwin -DSDL
endif
ifeq ($(ARCH),powerpc)	# Linux/PPC
	BASE_CFLAGS			+= -DBIGENDIAN -DUSE_ALSA
	CL_DLFLAGS			+= -ldl
endif
ifeq ($(ARCH),hppa)		# HP-UX/PA-RISC
	BASE_CFLAGS			+= -DBIGENDIAN -Dhpux
endif

RELEASE_CFLAGS			 =$(BASE_CFLAGS) $(BASE_RELEASE_CFLAGS)
DEBUG_CFLAGS			 =$(BASE_CFLAGS) $(BASE_DEBUG_CFLAGS)

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

ifndef BUILD_DIR
ifneq ($(_DEBUG),0)
	BUILD_DIR		 =$(DEBUG_BUILD_DIR)
else
	BUILD_DIR		 =$(RELEASE_BUILD_DIR)
endif
endif

# software and console (svga) builds
DO_CC					 =$(CC) -DUSE_VMODE $(CFLAGS)
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	DO_CC				+= -D_WINDOWS -mwindows
endif
DO_CC					+= -o $@ -c $<

DO_O_CC					 =$(CC) -O $(CFLAGS) -o $@ -c $<
DO_AS					 =$(CC) $(CFLAGS) -x assembler-with-cpp
ifeq ($(ARCH),x86)		# Linux/x86
	DO_AS				+= -DELF
endif
DO_AS					+= -o $@ -c $<

# opengl builds
BASE_GLCFLAGS			 =-DGLQUAKE -I/usr/include
ifeq ($(ARCH),x86)		# Linux/x86
	ARCH_GLCFLAGS		 =-DUSE_VMODE -I/usr/X11R6/include
endif
#ifeq ($(ARCH),ppc)		# MacOS-X/ppc
#	ARCH_GLCFLAGS        =`sdl-config --cflags`
#endif
#ifeq ($(ARCH),intelmac)		# MacOS-X/inteal
#	ARCH_GLCFLAGS        =`sdl-config --cflags`
#endif
ifeq ($(ARCH),mac)
	ARCH_GLCFLAGS        =`sdl-config --cflags`
endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	ARCH_GLCFLAGS		 =-mwindows
endif
ifeq ($(ARCH),hppa)		# HP-UX/PA-RISC
	ARCH_GLCFLAGS		 =-DHPOGL_SUPPRESS_FAST_API -I/opt/graphics/OpenGL/include
endif
GLCFLAGS				 =$(ARCH_GLCFLAGS) $(BASE_GLCFLAGS)

DO_GL_CC				 =$(CC) $(CFLAGS) $(GLCFLAGS) -o $@ -c $<
DO_GL_AS				 =$(CC) $(CFLAGS) $(GLCFLAGS) -x assembler-with-cpp
ifeq ($(ARCH),x86)		# Linux/x86
	DO_GL_AS			+= -DELF
endif
DO_GL_AS				+= -o $@ -c $<


# linker flags
LDFLAGS					 +=-lm
CONSOLE_LDFLAGS			 =-lvga
X11_LDFLAGS				 =-L/usr/X11R6/lib -lX11 -lXext -lXxf86dga -lXxf86vm
SDL_LDFLAGS          	 =`sdl-config --static-libs`
#ifeq ($(ARCH),ppc)		# MacOS-X/ppc
#	LDFLAGS				 =-framework "CoreAudio"
#endif
#ifeq ($(ARCH),intelmac)		# MacOS-X/intel
#	LDFLAGS				 =-framework "CoreAudio"
#endif
ifeq ($(ARCH),mac)
	LDFLAGS				 +=-framework CoreAudio
endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	LDFLAGS				+= -lws2_32 -luser32 -lwinmm
endif
ifeq ($(ARCH),hppa)		# HP-UX/PA-RISC
	LDFLAGS				+= -lhppa
endif

# opengl build
#BASE_GL_LDFLAGS			 =-L/usr/X11R6/lib -lGL -lm -lX11 -lXext
ARCH_GL_LDFLAGS			 =
ifeq ($(ARCH),x86)		# Linux/x86
	ARCH_GL_LDFLAGS		 =-lXxf86dga -lXxf86vm
endif
ifeq ($(ARCH),hppa)		# HP-UX/PA-RISC
	ARCH_GL_LDFLAGS		 =-L/opt/graphics/OpenGL/lib
endif
#ifeq ($(ARCH),ppc)		# MacOS-X/ppc
#	BASE_GL_LDFLAGS		 =
#endif
#ifeq ($(ARCH),intelmac)		# MacOS-X/intel
#	BASE_GL_LDFLAGS		 =
#endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	BASE_GL_LDFLAGS		 =
	ARCH_GL_LDFLAGS		 =-mwindows -lopengl32 -ldxguid -lgdi32
endif
GL_LDFLAGS				 =$(ARCH_GL_LDFLAGS) $(BASE_GL_LDFLAGS)

# dedicated server build
DO_SERVER_CC			 =$(CC) -DSERVERONLY $(CFLAGS)
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	DO_SERVER_CC		+= -D_CONSOLE -mconsole
endif
DO_SERVER_CC			+= -o $@ -c $<

#======================================================================
# setup and build rules:
#======================================================================
ifdef MAKEFILE
	MYMAKEFLAGS			:=-f $(MAKEFILE)
endif
MYMAKEFLAGS				+= $(MAKEFLAGS)

SERVER_TARGETS			 =$(BUILD_DIR)/zqds
GL_TARGETS				 =$(BUILD_DIR)/zquake-glx
SOFT_TARGETS			 =$(BUILD_DIR)/zquake-x11
CONSOLE_TARGETS			 =
SDL_TARGETS              =$(BUILD_DIR)/zquake-sdl $(BUILD_DIR)/zquake-glsdl
ifeq ($(ARCH),x86)		# Linux/x86
	CONSOLE_TARGETS		 = $(BUILD_DIR)/zquake-svga
endif
#ifeq ($(ARCH),ppc)		# MacOS-X/ppc
#	GL_TARGETS			 =$(BUILD_DIR)/zquake-glsdl
#	SOFT_TARGETS		 =$(BUILD_DIR)/zquake-sdl
#endif
#ifeq ($(ARCH),intelmac)		# MacOS-X/intel
#	GL_TARGETS			 =$(BUILD_DIR)/zquake-glsdl
#	SOFT_TARGETS		 =$(BUILD_DIR)/zquake-sdl
#endif
ifeq ($(ARCH),mac)		# MacOS X
	GL_TARGETS			 =$(BUILD_DIR)/zquake-glsdl
	SOFT_TARGETS		 =$(BUILD_DIR)/zquake-sdl
endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	GL_TARGETS			 =$(BUILD_DIR)/zquake-gl
	#SOFT_TARGETS		 =$(BUILD_DIR)/zquake
	SOFT_TARGETS		 =
endif
TARGETS					?=$(SERVER_TARGETS) $(SOFT_TARGETS) $(GL_TARGETS)


#-----------------------
# building everything
#-----------------------
all targets:			$(BUILD_DIR) print_vars $(TARGETS) striptargets
	@echo "*** Targets $(TARGETS) have been built"

all_debug build_debug:		$(DEBUG_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 _DEBUG=1 BUILD_DIR="$(DEBUG_BUILD_DIR)" CFLAGS="$(DEBUG_CFLAGS)" all

all_release build_release:	$(RELEASE_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 BUILD_DIR="$(RELEASE_BUILD_DIR)" CFLAGS="$(RELEASE_CFLAGS)" all

striptargets:				$(TARGETS)
ifneq ($(_RELEASE),0)
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	strip $(addsuffix .exe,$(TARGETS))
else
	strip $(TARGETS)
endif
endif

#-----------------------
# building server only
#-----------------------
ifneq ($(SERVER_TARGETS),)
server_debug:				$(DEBUG_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 _DEBUG=1 BUILD_DIR="$(DEBUG_BUILD_DIR)" CFLAGS="$(DEBUG_CFLAGS)" server

server_release:				$(RELEASE_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 BUILD_DIR="$(RELEASE_BUILD_DIR)" CFLAGS="$(RELEASE_CFLAGS)" server

server:						$(BUILD_DIR) print_vars $(SERVER_TARGETS)
	@echo "*** Targets $(SERVER_TARGETS) have been built"
endif

#-----------------------
# building software only
#-----------------------
ifneq ($(SOFT_TARGETS),)
soft_debug:				$(DEBUG_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 _DEBUG=1 BUILD_DIR="$(DEBUG_BUILD_DIR)" CFLAGS="$(DEBUG_CFLAGS)" soft

soft_release:				$(RELEASE_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 BUILD_DIR="$(RELEASE_BUILD_DIR)" CFLAGS="$(RELEASE_CFLAGS)" soft

soft:						$(BUILD_DIR) print_vars $(SOFT_TARGETS)
	@echo "*** Targets $(SOFT_TARGETS) have been built"

swbundle_contents = zquake-sdl.app/Contents
swbundle: $(SOFT_TARGETS)
	mkdir -p $(swbundle_contents)/MacOS
	mkdir -p $(swbundle_contents)/Resources
	echo "APPL????" > $(swbundle_contents)/PkgInfo
	cp swzquake.icns $(swbundle_contents)/Resources/
	cp swInfo.plist $(swbundle_contents)/Info.plist
	$(INSTALL_PROGRAM) $< $(swbundle_contents)/MacOS/
endif

#-----------------------
# building console only
#-----------------------
ifneq ($(CONSOLE_TARGETS),)
console_debug:			$(DEBUG_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 _DEBUG=1 BUILD_DIR="$(DEBUG_BUILD_DIR)" CFLAGS="$(DEBUG_CFLAGS)" console

console_release:		$(RELEASE_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 BUILD_DIR="$(RELEASE_BUILD_DIR)" CFLAGS="$(RELEASE_CFLAGS)" console

console:				$(BUILD_DIR) print_vars $(CONSOLE_TARGETS)
	@echo "*** Targets $(CONSOLE_TARGETS) have been built"
endif

#-----------------------
# building sdl only
#-----------------------
ifneq ($(SDL_TARGETS),)
sdl_debug:			$(DEBUG_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 _DEBUG=1 BUILD_DIR="$(DEBUG_BUILD_DIR)" CFLAGS="$(DEBUG_CFLAGS)" sdl

sdl_release:		$(RELEASE_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 BUILD_DIR="$(RELEASE_BUILD_DIR)" CFLAGS="$(RELEASE_CFLAGS)" sdl

sdl:				$(BUILD_DIR) print_vars $(SDL_TARGETS)
	@echo "*** Targets $(SDL_TARGETS) have been built"
endif

#-----------------------
# building gl only
#-----------------------
ifneq ($(GL_TARGETS),)
gl_debug:					$(DEBUG_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 _DEBUG=1 BUILD_DIR="$(DEBUG_BUILD_DIR)" CFLAGS="$(DEBUG_CFLAGS)" gl

gl_release:					$(RELEASE_BUILD_DIR)
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 BUILD_DIR="$(RELEASE_BUILD_DIR)" CFLAGS="$(RELEASE_CFLAGS)" gl

gl:							$(BUILD_DIR) print_vars $(GL_TARGETS)
	@echo "*** Targets $(GL_TARGETS) have been built"

glbundle_contents = zquake-glsdl.app/Contents
glbundle: $(GL_TARGETS)
	mkdir -p $(glbundle_contents)/MacOS
	mkdir -p $(glbundle_contents)/Resources
	echo "APPL????" > $(glbundle_contents)/PkgInfo
	cp glzquake.icns $(glbundle_contents)/Resources/
	cp glInfo.plist $(glbundle_contents)/Info.plist
	$(INSTALL_PROGRAM) $< $(glbundle_contents)/MacOS/
endif


#-----------------------
# help
#-----------------------
help:
	@echo "To compile ZQuake, do one of the following:"
	@echo ""
	@echo "  $(MAKE) clean             - remove generated objects"
	@echo "  $(MAKE) distclean         - remove generated directories"
	@echo ""
ifneq ($(SERVER_TARGETS),)
	@echo "  $(MAKE) server            - build server release only"
endif
ifneq ($(SOFT_TARGETS),)
	@echo "  $(MAKE) soft              - build software release only"
endif
ifneq ($(CONSOLE_TARGETS),)
	@echo "  $(MAKE) console           - build console (e.g. svga) release only"
endif
ifneq ($(SDL_TARGETS),)
	@echo "  $(MAKE) sdl               - build sdl release only"
endif
ifneq ($(GL_TARGETS),)
	@echo "  $(MAKE) gl                - build opengl release only"
endif
	@echo "  $(MAKE) all               - build server, soft and opengl."
	@echo ""
	@echo "  $(MAKE) _DEBUG=1 <target> - build <target> as debug version."
	@echo ""
ifneq ($(SERVER_TARGETS),)
	@echo "  $(MAKE) server_debug      - build server debug only (synonym to $(MAKE) _DEBUG=1 server)"
endif
ifneq ($(SOFT_TARGETS),)
	@echo "  $(MAKE) soft_debug        - build software debug only (synonym to $(MAKE) _DEBUG=1 soft)"
endif
ifneq ($(CONSOLE_TARGETS),)
	@echo "  $(MAKE) console_debug     - build console (e.g. svga) debug only (synonym to $(MAKE) _DEBUG=1 gl)"
endif
ifneq ($(GL_TARGETS),)
	@echo "  $(MAKE) gl_debug          - build opengl debug only (synonym to $(MAKE) _DEBUG=1 gl)"
endif
	@echo "  $(MAKE) all_debug         - build server,soft and opengl debug (synonym to $(MAKE) _DEBUG=1 all)"
	@echo ""

#-----------------------
# printing of rules
#-----------------------
print_vars:
	@echo "************************************************"
	@echo "*** NOTE: USE \"$(MAKE) help\" for informations!"
	@echo "************************************************"
	@echo "MACHINE       = $(MACHINE)"
ifneq ($(MACHINE),$(ARCH))
	@echo "ARCH          = $(ARCH)"
endif
	@echo "DEST_ARCH     = $(DEST_ARCH)"
	@echo ""
	@echo "MAIN_DIR      = $(MAIN_DIR)"
ifneq ($(CLIENT_DIR),$(SERVER_DIR))
	@echo "CLIENT_DIR    = $(CLIENT_DIR)"
	@echo "SERVER_DIR    = $(SERVER_DIR)"
else
	@echo "SOURCE_DIR    = $(SERVER_DIR)"
endif
	@echo ""
	@echo "CFLAGS        = $(CFLAGS)"
	@echo "LDFLAGS       = $(LDFLAGS)"
	@echo "CL_LDFLAGS    = $(CL_LDFLAGS)"
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	@echo "WINDRES_CHECK = $(WINDRES_CHECK)"
endif
	@echo ""
	@echo "BUILD_DIR     = $(BUILD_DIR)"
	@echo "TARGETS       = $(notdir $(TARGETS))"
	@echo "************************************************"
	@echo ""


#-----------------------
# cleanup the stuff
#-----------------------
clean_debug clean-debug:
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 _DEBUG=1 clean2 BUILD_DIR=$(DEBUG_BUILD_DIR) CFLAGS="$(DEBUG_CFLAGS)"

clean_release clean-release:
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 clean2 BUILD_DIR=$(RELEASE_BUILD_DIR) CFLAGS="$(RELEASE_CFLAGS)"

clean:						clean_debug clean_release

clean2:
	@echo "*** Removing object files in dir structure \"$(BUILD_DIR)\""
	@-(rm -f $(QWSV_OBJS) \
		$(QWSV_AS_OBJS) \
		$(QWCL_COMMON_OBJS) \
		$(QWCL_AS_OBJS) \
		$(QWCL_PLATFORM_OBJS) \
		$(QWCL_CONSOLE_OBJS) \
		$(QWCL_X11_OBJS) \
		$(GLQWCL_COMMON_OBJS) \
		$(GLQWCL_AS_OBJS) \
		$(GLQWCL_PLATFORM_OBJS) \
		$(GLQWCL_WIN_OBJS) \
		$(GLQWCL_X11_OBJS) 2>/dev/null || true)

clobber_debug distclean_debug clobber-debug distclean-debug:	clean_debug
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=0 _DEBUG=1 clobber2 BUILD_DIR=$(DEBUG_BUILD_DIR) CFLAGS="$(DEBUG_CFLAGS)"

clobber_release distclean_release clobber-releae distclean-release:	clean_release
	@$(MAKE) $(MYMAKEFLAGS) _RELEASE=1 clobber2 BUILD_DIR=$(RELEASE_BUILD_DIR) CFLAGS="$(RELEASE_CFLAGS)"

clobber distclean:					clobber_debug clobber_release

clobber2:
	@echo "*** Removing directory structure \"$(BUILD_DIR)\""
	@-(rm -rf $(BUILD_DIR) 2>/dev/null || true)


#-----------------------
# empty rule for nothing
#-----------------------
$(MAKEFILE):


#======================================================================
# rules for "real" files and dirs:
#======================================================================

#-----------------------
# directories
#-----------------------
$(DEBUG_BUILD_DIR) $(RELEASE_BUILD_DIR) :
	@echo "Creating build-directory structure... ($@)"
	@-(mkdir -p $@/client \
				$@/glclient \
				$@/server 2>/dev/null || true)

#-----------------------
# server objects
#-----------------------
QWSV_OBJS = \
	 $(BUILD_DIR)/server/cl_null.o \
	 $(BUILD_DIR)/server/cmd.o \
	 $(BUILD_DIR)/server/cmodel.o \
	 $(BUILD_DIR)/server/common.o \
	 $(BUILD_DIR)/server/com_msg.o \
	 $(BUILD_DIR)/server/crc.o \
	 $(BUILD_DIR)/server/cvar.o \
	 $(BUILD_DIR)/server/host.o \
	 $(BUILD_DIR)/server/mathlib.o \
	 $(BUILD_DIR)/server/mdfour.o \
	 $(BUILD_DIR)/server/net_chan.o \
	 $(BUILD_DIR)/server/pmove.o \
	 $(BUILD_DIR)/server/pmovetst.o \
	 $(BUILD_DIR)/server/pr_cmds.o \
	 $(BUILD_DIR)/server/pr_edict.o \
	 $(BUILD_DIR)/server/pr_exec.o \
	 $(BUILD_DIR)/server/q_shared.o \
	 $(BUILD_DIR)/server/sv_bot.o \
	 $(BUILD_DIR)/server/sv_ccmds.o \
	 $(BUILD_DIR)/server/sv_ents.o \
	 $(BUILD_DIR)/server/sv_init.o \
	 $(BUILD_DIR)/server/sv_main.o \
	 $(BUILD_DIR)/server/sv_master.o \
	 $(BUILD_DIR)/server/sv_move.o \
	 $(BUILD_DIR)/server/sv_nchan.o \
	 $(BUILD_DIR)/server/sv_phys.o \
	 $(BUILD_DIR)/server/sv_send.o \
	 $(BUILD_DIR)/server/sv_user.o \
	 $(BUILD_DIR)/server/sv_world.o \
	 $(BUILD_DIR)/server/version.o \
	 $(BUILD_DIR)/server/zone.o

ifdef MAUTH_FLAGS
	QWSV_OBJS += \
		$(BUILD_DIR)/server/sv_authlists.o
endif

ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
    # Note: the server resource file is compileable with windres < v2.15.xx
	QWSV_OBJS += \
		$(BUILD_DIR)/server/net_wins.o \
		$(BUILD_DIR)/server/sys_win.o \
		$(BUILD_DIR)/server/win_res.o
else
	QWSV_OBJS += \
		$(BUILD_DIR)/server/net_udp.o \
		$(BUILD_DIR)/server/sv_sys_unix.o
endif

QWSV_AS_OBJS =
ifeq ($(ARCH),x86)		# Linux/x86
	QWSV_AS_OBJS = \
		$(BUILD_DIR)/server/math.o \
		$(BUILD_DIR)/server/sys_x86.o
endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	QWSV_AS_OBJS = \
		$(BUILD_DIR)/server/math.o
endif

#-----------------------
# server executable
#-----------------------
zqds : $(BUILD_DIR)/zqds

$(BUILD_DIR)/zqds : $(BUILD_DIR) $(QWSV_OBJS) $(QWSV_AS_OBJS)
	$(CC) $(CFLAGS) -o $@ $(QWSV_OBJS) $(QWSV_AS_OBJS) $(LDFLAGS)

$(BUILD_DIR)/server/cl_null.o :   $(SERVER_DIR)/cl_null.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/cmd.o :       $(CLIENT_DIR)/cmd.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/cmodel.o :    $(CLIENT_DIR)/cmodel.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/com_msg.o :   $(CLIENT_DIR)/com_msg.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/common.o :    $(CLIENT_DIR)/common.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/crc.o :       $(CLIENT_DIR)/crc.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/cvar.o :      $(CLIENT_DIR)/cvar.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/host.o :      $(SERVER_DIR)/host.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/mathlib.o :   $(CLIENT_DIR)/mathlib.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/mdfour.o :    $(CLIENT_DIR)/mdfour.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/net_chan.o :  $(CLIENT_DIR)/net_chan.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/net_udp.o :   $(CLIENT_DIR)/net_udp.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/net_wins.o :  $(CLIENT_DIR)/net_wins.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/pmove.o :     $(CLIENT_DIR)/pmove.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/pmovetst.o :  $(CLIENT_DIR)/pmovetst.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/pr_cmds.o :   $(SERVER_DIR)/pr_cmds.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/pr_edict.o :  $(SERVER_DIR)/pr_edict.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/pr_exec.o :   $(SERVER_DIR)/pr_exec.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/q_shared.o :  $(CLIENT_DIR)/q_shared.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_bot.o :    $(SERVER_DIR)/sv_bot.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_ccmds.o :  $(SERVER_DIR)/sv_ccmds.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_ents.o :   $(SERVER_DIR)/sv_ents.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_init.o :   $(SERVER_DIR)/sv_init.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_main.o :   $(SERVER_DIR)/sv_main.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_master.o : $(SERVER_DIR)/sv_master.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_move.o :   $(SERVER_DIR)/sv_move.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_nchan.o :  $(SERVER_DIR)/sv_nchan.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_phys.o :   $(SERVER_DIR)/sv_phys.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_send.o :   $(SERVER_DIR)/sv_send.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_sys_unix.o : $(SERVER_DIR)/sv_sys_unix.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_user.o :   $(SERVER_DIR)/sv_user.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sv_world.o :  $(SERVER_DIR)/sv_world.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/sys_win.o :   $(SERVER_DIR)/sys_win.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/version.o :   $(CLIENT_DIR)/version.c
	$(DO_SERVER_CC)
$(BUILD_DIR)/server/zone.o :      $(CLIENT_DIR)/zone.c
	$(DO_SERVER_CC)

$(BUILD_DIR)/server/sv_authlists.o : $(SERVER_DIR)/sv_authlists.c
	$(DO_SERVER_CC)

$(BUILD_DIR)/server/math.o :      $(CLIENT_DIR)/math.s
	$(DO_AS)
$(BUILD_DIR)/server/sys_x86.o :   $(CLIENT_DIR)/sys_x86.s
	$(DO_AS)

$(BUILD_DIR)/server/win_res.o :   $(SERVER_DIR)/zqds.rc $(CLIENT_DIR)/zqds_resource.h
	cd $(SERVER_DIR) && \
	windres $(filter -D%,$(DO_SERVER_CC)) -i zqds.rc -o $(shell cd $(BUILD_DIR) && pwd)/server/win_res.o

#-----------------------
# client objects
#-----------------------
QWCL_COMMON_OBJS		 = \
	$(BUILD_DIR)/client/cl_cam.o \
	$(BUILD_DIR)/client/cl_cmd.o \
	$(BUILD_DIR)/client/cl_demo.o \
	$(BUILD_DIR)/client/cl_draw.o \
	$(BUILD_DIR)/client/cl_effects.o \
	$(BUILD_DIR)/client/cl_ents.o \
	$(BUILD_DIR)/client/cl_input.o \
	$(BUILD_DIR)/client/cl_main.o \
	$(BUILD_DIR)/client/cl_nqdemo.o \
	$(BUILD_DIR)/client/cl_parse.o \
	$(BUILD_DIR)/client/cl_pred.o \
	$(BUILD_DIR)/client/cl_sbar.o \
	$(BUILD_DIR)/client/cl_screen.o \
	$(BUILD_DIR)/client/cl_tent.o \
	$(BUILD_DIR)/client/cl_view.o \
	$(BUILD_DIR)/client/cmd.o \
	$(BUILD_DIR)/client/cmodel.o \
	$(BUILD_DIR)/client/com_msg.o \
	$(BUILD_DIR)/client/common.o \
	$(BUILD_DIR)/client/console.o \
	$(BUILD_DIR)/client/crc.o \
	$(BUILD_DIR)/client/cvar.o \
	$(BUILD_DIR)/client/d_edge.o \
	$(BUILD_DIR)/client/d_fill.o \
	$(BUILD_DIR)/client/d_init.o \
	$(BUILD_DIR)/client/d_modech.o \
	$(BUILD_DIR)/client/d_polyse.o \
	$(BUILD_DIR)/client/d_sky.o \
	$(BUILD_DIR)/client/d_sprite.o \
	$(BUILD_DIR)/client/d_surf.o \
	$(BUILD_DIR)/client/d_vars.o \
	$(BUILD_DIR)/client/d_zpoint.o \
	$(BUILD_DIR)/client/host.o \
	$(BUILD_DIR)/client/keys.o \
	$(BUILD_DIR)/client/mathlib.o \
	$(BUILD_DIR)/client/mdfour.o \
	$(BUILD_DIR)/client/menu.o \
	$(BUILD_DIR)/client/net_chan.o \
	$(BUILD_DIR)/client/nonintel.o \
	$(BUILD_DIR)/client/pmove.o \
	$(BUILD_DIR)/client/pmovetst.o \
	$(BUILD_DIR)/client/pr_cmds.o \
	$(BUILD_DIR)/client/pr_edict.o \
	$(BUILD_DIR)/client/pr_exec.o \
	$(BUILD_DIR)/client/q_shared.o \
	$(BUILD_DIR)/client/r_aclip.o \
	$(BUILD_DIR)/client/r_alias.o \
	$(BUILD_DIR)/client/r_bsp.o \
	$(BUILD_DIR)/client/r_draw.o \
	$(BUILD_DIR)/client/r_edge.o \
	$(BUILD_DIR)/client/r_efrag.o \
	$(BUILD_DIR)/client/r_light.o \
	$(BUILD_DIR)/client/r_main.o \
	$(BUILD_DIR)/client/r_misc.o \
	$(BUILD_DIR)/client/r_model.o \
	$(BUILD_DIR)/client/r_part.o \
	$(BUILD_DIR)/client/r_rast.o \
	$(BUILD_DIR)/client/r_scan.o \
	$(BUILD_DIR)/client/r_sky.o \
	$(BUILD_DIR)/client/r_sprite.o \
	$(BUILD_DIR)/client/r_surf.o \
	$(BUILD_DIR)/client/r_vars.o \
	$(BUILD_DIR)/client/rc_image.o \
	$(BUILD_DIR)/client/rc_wad.o \
	$(BUILD_DIR)/client/skin.o \
	$(BUILD_DIR)/client/snd_dma.o \
	$(BUILD_DIR)/client/snd_mem.o \
	$(BUILD_DIR)/client/snd_mix.o \
	$(BUILD_DIR)/client/sv_bot.o \
	$(BUILD_DIR)/client/sv_ccmds.o \
	$(BUILD_DIR)/client/sv_ents.o \
	$(BUILD_DIR)/client/sv_init.o \
	$(BUILD_DIR)/client/sv_main.o \
	$(BUILD_DIR)/client/sv_master.o \
	$(BUILD_DIR)/client/sv_move.o \
	$(BUILD_DIR)/client/sv_nchan.o \
	$(BUILD_DIR)/client/sv_phys.o \
	$(BUILD_DIR)/client/sv_save.o \
	$(BUILD_DIR)/client/sv_send.o \
	$(BUILD_DIR)/client/sv_user.o \
	$(BUILD_DIR)/client/sv_world.o \
	$(BUILD_DIR)/client/teamplay.o \
	$(BUILD_DIR)/client/version.o \
	$(BUILD_DIR)/client/zone.o

ifdef MAUTH_FLAGS
	# This is only useful for running listen servers.  It also
	# stops make errors.  I wouldn't actually want to use this...
	QWCL_COMMON_OBJS	+= \
		$(BUILD_DIR)/client/sv_authlists.o
endif

ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	QWCL_COMMON_OBJS	+= \
		$(BUILD_DIR)/client/in_win.o \
		$(BUILD_DIR)/client/net_wins.o \
		$(BUILD_DIR)/client/sys_win.o
else
	QWCL_COMMON_OBJS	+= \
		$(BUILD_DIR)/client/net_udp.o \
		$(BUILD_DIR)/client/sys_linux.o
endif


QWCL_AS_OBJS			 =
ifeq ($(DEST_ARCH),x86)	# Linux/x86 & Win32/x86
	QWCL_AS_OBJS		 = \
		$(BUILD_DIR)/client/cl_math.o \
		$(BUILD_DIR)/client/d_polysa.o \
		$(BUILD_DIR)/client/d_spr8.o \
		$(BUILD_DIR)/client/d_varsa.o \
		$(BUILD_DIR)/client/math.o \
		$(BUILD_DIR)/client/r_aclipa.o \
		$(BUILD_DIR)/client/r_aliasa.o \
		$(BUILD_DIR)/client/r_draw16.o \
		$(BUILD_DIR)/client/r_draw8.o \
		$(BUILD_DIR)/client/r_drawa.o \
		$(BUILD_DIR)/client/r_edgea.o \
		$(BUILD_DIR)/client/r_parta.o \
		$(BUILD_DIR)/client/r_scana.o \
		$(BUILD_DIR)/client/r_varsa.o \
		$(BUILD_DIR)/client/snd_mixa.o \
		$(BUILD_DIR)/client/surf16.o \
		$(BUILD_DIR)/client/surf8.o \
		$(BUILD_DIR)/client/sys_x86.o
endif

QWCL_PLATFORM_OBJS		 = \
	$(BUILD_DIR)/client/cd_null.o \
	$(BUILD_DIR)/client/snd_osnull.o
ifeq ($(ARCH),x86)		# Linux/x86
	QWCL_PLATFORM_OBJS	 = \
		$(BUILD_DIR)/client/cd_linux.o \
		$(BUILD_DIR)/client/snd_linux.o \
		$(BUILD_DIR)/client/snd_oss.o \
		$(BUILD_DIR)/client/snd_alsa.o
endif
ifeq ($(ARCH),powerpc)	# Linux/ppc
	QWCL_PLATFORM_OBJS	 = \
		$(BUILD_DIR)/client/cd_linux.o \
		$(BUILD_DIR)/client/snd_linux.o \
		$(BUILD_DIR)/client/snd_oss.o \
		$(BUILD_DIR)/client/snd_alsa.o
endif
#ifeq ($(ARCH),ppc)		# MacOS-X/ppc
#	QWCL_PLATFORM_OBJS	 = \
#		$(BUILD_DIR)/client/cd_null.o \
#		$(BUILD_DIR)/client/snd_osx.o
#endif
#ifeq ($(ARCH),intelmac)		# MacOS-X/intel
#	QWCL_PLATFORM_OBJS	 = \
#		$(BUILD_DIR)/client/cd_null.o \
#		$(BUILD_DIR)/client/snd_osx.o
#endif
ifeq ($(ARCH),mac)		# MacOS X
	QWCL_PLATFORM_OBJS	 = \
		$(BUILD_DIR)/client/cd_null.o \
		$(BUILD_DIR)/client/snd_osx.o
endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	QWCL_PLATFORM_OBJS	 = \
		$(BUILD_DIR)/client/cd_win.o
ifeq ($(WINDRES_CHECK),1) # it's only compilable with windres >= v2.15.xx
	QWCL_PLATFORM_OBJS	+= \
		$(BUILD_DIR)/client/win_res.o
endif
endif

QWCL_CONSOLE_OBJS		 = \
		$(BUILD_DIR)/client/vid_svgalib.o \
		$(BUILD_DIR)/client/d_copy.o

QWCL_X11_OBJS			 = \
		$(BUILD_DIR)/client/vid_x.o

QWCL_SDL_OBJS			 = \
		$(BUILD_DIR)/client/vid_sdl.o

QWCL_WIN_OBJS			 = \
		$(BUILD_DIR)/client/vid_win.o

#-----------------------
# client executables
#-----------------------
zquake-svga:	$(BUILD_DIR)/zquake-svga

$(BUILD_DIR)/zquake-svga : $(QWCL_COMMON_OBJS) $(QWCL_AS_OBJS) $(QWCL_PLATFORM_OBJS) $(QWCL_CONSOLE_OBJS)
	$(CC) $(CFLAGS) -o $@ \
		$(QWCL_COMMON_OBJS) \
		$(QWCL_AS_OBJS) \
		$(QWCL_PLATFORM_OBJS) \
		$(QWCL_CONSOLE_OBJS) \
		$(CL_LDFLAGS) $(LDFLAGS) $(CONSOLE_LDFLAGS)

zquake-x11:	$(BUILD_DIR)/zquake-x11

$(BUILD_DIR)/zquake-x11 : $(QWCL_COMMON_OBJS) $(QWCL_AS_OBJS) $(QWCL_PLATFORM_OBJS) $(QWCL_X11_OBJS)
	$(CC) $(CFLAGS) -o $@ \
		$(QWCL_COMMON_OBJS) \
		$(QWCL_AS_OBJS) \
		$(QWCL_PLATFORM_OBJS) \
		$(QWCL_X11_OBJS) \
		$(CL_LDFLAGS) $(LDFLAGS) $(X11_LDFLAGS)

zquake-sdl:	$(BUILD_DIR)/zquake-sdl

$(BUILD_DIR)/zquake-sdl : $(QWCL_COMMON_OBJS) $(QWCL_AS_OBJS) $(QWCL_PLATFORM_OBJS) $(QWCL_SDL_OBJS)
	$(CC) $(CFLAGS) -o $@ \
		$(QWCL_COMMON_OBJS) \
		$(QWCL_AS_OBJS) \
		$(QWCL_PLATFORM_OBJS) \
		$(QWCL_SDL_OBJS) \
		$(LDFLAGS) $(SDL_LDFLAGS)

zquake:	$(BUILD_DIR)/zquake

$(BUILD_DIR)/zquake : $(BUILD_DIR) $(QWCL_COMMON_OBJS) $(QWCL_AS_OBJS) $(QWCL_PLATFORM_OBJS) $(QWCL_WIN_OBJS)
	$(CC) $(CFLAGS) -o $@ \
		$(QWCL_COMMON_OBJS) \
		$(QWCL_AS_OBJS) \
		$(QWCL_PLATFORM_OBJS) \
		$(QWCL_WIN_OBJS) \
		$(CL_LDFLAGS) $(LDFLAGS)

$(BUILD_DIR)/client/cd_null.o :      $(CLIENT_DIR)/cd_null.c
	$(DO_CC)
$(BUILD_DIR)/client/cd_linux.o :     $(CLIENT_DIR)/cd_linux.c
	$(DO_CC)
$(BUILD_DIR)/client/cd_win.o :       $(CLIENT_DIR)/cd_win.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_cam.o :       $(CLIENT_DIR)/cl_cam.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_cmd.o :       $(CLIENT_DIR)/cl_cmd.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_demo.o :      $(CLIENT_DIR)/cl_demo.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_draw.o :      $(CLIENT_DIR)/cl_draw.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_effects.o :   $(CLIENT_DIR)/cl_effects.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_ents.o :      $(CLIENT_DIR)/cl_ents.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_input.o :     $(CLIENT_DIR)/cl_input.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_main.o :      $(CLIENT_DIR)/cl_main.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_nqdemo.o :    $(CLIENT_DIR)/cl_nqdemo.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_parse.o :     $(CLIENT_DIR)/cl_parse.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_pred.o :      $(CLIENT_DIR)/cl_pred.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_sbar.o :      $(CLIENT_DIR)/cl_sbar.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_screen.o :    $(CLIENT_DIR)/cl_screen.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_tent.o :      $(CLIENT_DIR)/cl_tent.c
	$(DO_CC)
$(BUILD_DIR)/client/cl_view.o :      $(CLIENT_DIR)/cl_view.c
	$(DO_CC)
$(BUILD_DIR)/client/cmd.o :          $(CLIENT_DIR)/cmd.c
	$(DO_CC)
$(BUILD_DIR)/client/cmodel.o :       $(CLIENT_DIR)/cmodel.c
	$(DO_CC)
$(BUILD_DIR)/client/com_msg.o :      $(CLIENT_DIR)/com_msg.c
	$(DO_CC)
$(BUILD_DIR)/client/common.o :       $(CLIENT_DIR)/common.c
	$(DO_CC)
$(BUILD_DIR)/client/console.o :      $(CLIENT_DIR)/console.c
	$(DO_CC)
$(BUILD_DIR)/client/crc.o :          $(CLIENT_DIR)/crc.c
	$(DO_CC)
$(BUILD_DIR)/client/cvar.o :         $(CLIENT_DIR)/cvar.c
	$(DO_CC)
$(BUILD_DIR)/client/d_edge.o :       $(CLIENT_DIR)/d_edge.c
	$(DO_CC)
$(BUILD_DIR)/client/d_fill.o :       $(CLIENT_DIR)/d_fill.c
	$(DO_CC)
$(BUILD_DIR)/client/d_init.o :       $(CLIENT_DIR)/d_init.c
	$(DO_CC)
$(BUILD_DIR)/client/d_modech.o :     $(CLIENT_DIR)/d_modech.c
	$(DO_CC)
$(BUILD_DIR)/client/d_polyse.o :     $(CLIENT_DIR)/d_polyse.c
	$(DO_CC)
$(BUILD_DIR)/client/d_scan.o :       $(CLIENT_DIR)/d_scan.c
	$(DO_CC)
$(BUILD_DIR)/client/d_sky.o :        $(CLIENT_DIR)/d_sky.c
	$(DO_CC)
$(BUILD_DIR)/client/d_sprite.o :     $(CLIENT_DIR)/d_sprite.c
	$(DO_CC)
$(BUILD_DIR)/client/d_surf.o :       $(CLIENT_DIR)/d_surf.c
	$(DO_CC)
$(BUILD_DIR)/client/d_vars.o :       $(CLIENT_DIR)/d_vars.c
	$(DO_CC)
$(BUILD_DIR)/client/d_zpoint.o :     $(CLIENT_DIR)/d_zpoint.c
	$(DO_CC)
$(BUILD_DIR)/client/host.o :         $(CLIENT_DIR)/host.c
	$(DO_CC)
$(BUILD_DIR)/client/in_win.o :       $(CLIENT_DIR)/in_win.c
	$(DO_CC)
$(BUILD_DIR)/client/keys.o :         $(CLIENT_DIR)/keys.c
	$(DO_CC)
$(BUILD_DIR)/client/mathlib.o :      $(CLIENT_DIR)/mathlib.c
	$(DO_CC)
$(BUILD_DIR)/client/mdfour.o :       $(CLIENT_DIR)/mdfour.c
	$(DO_CC)
$(BUILD_DIR)/client/menu.o :         $(CLIENT_DIR)/menu.c
	$(DO_CC)
$(BUILD_DIR)/client/net_chan.o :     $(CLIENT_DIR)/net_chan.c
	$(DO_CC)
$(BUILD_DIR)/client/net_udp.o :      $(CLIENT_DIR)/net_udp.c
	$(DO_CC)
$(BUILD_DIR)/client/net_wins.o :     $(CLIENT_DIR)/net_wins.c
	$(DO_CC)
$(BUILD_DIR)/client/nonintel.o :     $(CLIENT_DIR)/nonintel.c
	$(DO_CC)
$(BUILD_DIR)/client/pmove.o :        $(CLIENT_DIR)/pmove.c
	$(DO_CC)
$(BUILD_DIR)/client/pmovetst.o :     $(CLIENT_DIR)/pmovetst.c
	$(DO_CC)
$(BUILD_DIR)/client/pr_cmds.o :      $(SERVER_DIR)/pr_cmds.c
	$(DO_CC)
$(BUILD_DIR)/client/pr_edict.o :     $(SERVER_DIR)/pr_edict.c
	$(DO_CC)
$(BUILD_DIR)/client/pr_exec.o :      $(SERVER_DIR)/pr_exec.c
	$(DO_CC)
$(BUILD_DIR)/client/q_shared.o :     $(CLIENT_DIR)/q_shared.c
	$(DO_CC)
$(BUILD_DIR)/client/r_aclip.o :      $(CLIENT_DIR)/r_aclip.c
	$(DO_CC)
$(BUILD_DIR)/client/r_alias.o :      $(CLIENT_DIR)/r_alias.c
	$(DO_CC)
$(BUILD_DIR)/client/r_bsp.o :        $(CLIENT_DIR)/r_bsp.c
	$(DO_CC)
$(BUILD_DIR)/client/r_draw.o :       $(CLIENT_DIR)/r_draw.c
	$(DO_CC)
$(BUILD_DIR)/client/r_edge.o :       $(CLIENT_DIR)/r_edge.c
	$(DO_CC)
$(BUILD_DIR)/client/r_efrag.o :      $(CLIENT_DIR)/r_efrag.c
	$(DO_CC)
$(BUILD_DIR)/client/r_light.o :      $(CLIENT_DIR)/r_light.c
	$(DO_CC)
$(BUILD_DIR)/client/r_main.o :       $(CLIENT_DIR)/r_main.c
	$(DO_CC)
$(BUILD_DIR)/client/r_misc.o :       $(CLIENT_DIR)/r_misc.c
	$(DO_CC)
$(BUILD_DIR)/client/r_model.o :      $(CLIENT_DIR)/r_model.c
	$(DO_CC)
$(BUILD_DIR)/client/r_part.o :       $(CLIENT_DIR)/r_part.c
	$(DO_CC)
$(BUILD_DIR)/client/r_rast.o :       $(CLIENT_DIR)/r_rast.c
	$(DO_CC)
$(BUILD_DIR)/client/r_scan.o :       $(CLIENT_DIR)/r_scan.c
	$(DO_CC)
$(BUILD_DIR)/client/r_sky.o :        $(CLIENT_DIR)/r_sky.c
	$(DO_CC)
$(BUILD_DIR)/client/r_sprite.o :     $(CLIENT_DIR)/r_sprite.c
	$(DO_CC)
$(BUILD_DIR)/client/r_surf.o :       $(CLIENT_DIR)/r_surf.c
	$(DO_CC)
$(BUILD_DIR)/client/r_vars.o :       $(CLIENT_DIR)/r_vars.c
	$(DO_CC)
$(BUILD_DIR)/client/rc_image.o :     $(CLIENT_DIR)/rc_image.c
	$(DO_CC)
$(BUILD_DIR)/client/rc_wad.o :       $(CLIENT_DIR)/rc_wad.c
	$(DO_CC)
$(BUILD_DIR)/client/skin.o :         $(CLIENT_DIR)/skin.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_dma.o :      $(CLIENT_DIR)/snd_dma.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_alsa.o :      $(CLIENT_DIR)/snd_alsa.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_linux.o :    $(CLIENT_DIR)/snd_linux.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_mem.o :      $(CLIENT_DIR)/snd_mem.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_mix.o :      $(CLIENT_DIR)/snd_mix.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_null.o :     $(CLIENT_DIR)/snd_null.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_osnull.o :   $(CLIENT_DIR)/snd_osnull.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_oss.o :      $(CLIENT_DIR)/snd_oss.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_osx.o :      $(CLIENT_DIR)/snd_osx.c
	$(DO_CC)
$(BUILD_DIR)/client/snd_win.o :      $(CLIENT_DIR)/snd_win.c
	$(DO_GL_CC)
$(BUILD_DIR)/client/sv_bot.o :       $(SERVER_DIR)/sv_bot.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_ccmds.o :     $(SERVER_DIR)/sv_ccmds.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_ents.o :      $(SERVER_DIR)/sv_ents.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_init.o :      $(SERVER_DIR)/sv_init.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_main.o :      $(SERVER_DIR)/sv_main.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_master.o :    $(SERVER_DIR)/sv_master.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_move.o :      $(SERVER_DIR)/sv_move.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_nchan.o :     $(SERVER_DIR)/sv_nchan.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_null.o :      $(CLIENT_DIR)/sv_null.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_phys.o :      $(SERVER_DIR)/sv_phys.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_save.o :      $(SERVER_DIR)/sv_save.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_send.o :      $(SERVER_DIR)/sv_send.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_user.o :      $(SERVER_DIR)/sv_user.c
	$(DO_CC)
$(BUILD_DIR)/client/sv_world.o :     $(SERVER_DIR)/sv_world.c
	$(DO_CC)
$(BUILD_DIR)/client/sys_linux.o :    $(CLIENT_DIR)/sys_linux.c
	$(DO_CC)
$(BUILD_DIR)/client/sys_win.o :      $(CLIENT_DIR)/sys_win.c
	$(DO_CC)
$(BUILD_DIR)/client/teamplay.o :     $(CLIENT_DIR)/teamplay.c
	$(DO_CC)
$(BUILD_DIR)/client/version.o :      $(CLIENT_DIR)/version.c
	$(DO_CC)
$(BUILD_DIR)/client/zone.o :         $(CLIENT_DIR)/zone.c
	$(DO_CC)

$(BUILD_DIR)/client/sv_authlists.o : $(SERVER_DIR)/sv_authlists.c
	$(DO_CC)

$(BUILD_DIR)/client/d_copy.o :       $(CLIENT_DIR)/d_copy.s
	$(DO_AS)
$(BUILD_DIR)/client/d_polysa.o :     $(CLIENT_DIR)/d_polysa.s
	$(DO_AS)
$(BUILD_DIR)/client/d_spr8.o :       $(CLIENT_DIR)/d_spr8.s
	$(DO_AS)
$(BUILD_DIR)/client/d_varsa.o :      $(CLIENT_DIR)/d_varsa.s
	$(DO_AS)
$(BUILD_DIR)/client/cl_math.o :      $(CLIENT_DIR)/cl_math.s
	$(DO_AS)
$(BUILD_DIR)/client/math.o :         $(CLIENT_DIR)/math.s
	$(DO_AS)
$(BUILD_DIR)/client/r_aclipa.o :     $(CLIENT_DIR)/r_aclipa.s
	$(DO_AS)
$(BUILD_DIR)/client/r_aliasa.o :     $(CLIENT_DIR)/r_aliasa.s
	$(DO_AS)
$(BUILD_DIR)/client/r_draw16.o :     $(CLIENT_DIR)/r_draw16.s
	$(DO_AS)
$(BUILD_DIR)/client/r_draw8.o :      $(CLIENT_DIR)/r_draw8.s
	$(DO_AS)
$(BUILD_DIR)/client/r_drawa.o :      $(CLIENT_DIR)/r_drawa.s
	$(DO_AS)
$(BUILD_DIR)/client/r_edgea.o :      $(CLIENT_DIR)/r_edgea.s
	$(DO_AS)
$(BUILD_DIR)/client/r_parta.o :      $(CLIENT_DIR)/r_parta.s
	$(DO_AS)
$(BUILD_DIR)/client/r_scana.o :      $(CLIENT_DIR)/r_scana.s
	$(DO_AS)
$(BUILD_DIR)/client/r_varsa.o :      $(CLIENT_DIR)/r_varsa.s
	$(DO_AS)
$(BUILD_DIR)/client/snd_mixa.o :     $(CLIENT_DIR)/snd_mixa.s
	$(DO_AS)
$(BUILD_DIR)/client/surf16.o :       $(CLIENT_DIR)/surf16.s
	$(DO_AS)
$(BUILD_DIR)/client/surf8.o :        $(CLIENT_DIR)/surf8.s
	$(DO_AS)
$(BUILD_DIR)/client/sys_x86.o :      $(CLIENT_DIR)/sys_x86.s
	$(DO_AS)

$(BUILD_DIR)/client/win_res.o :      $(CLIENT_DIR)/winquake.rc $(CLIENT_DIR)/resource.h
	cd $(CLIENT_DIR) && \
	windres $(filter -D%,$(DO_CC)) -i winquake.rc -o $(shell cd $(BUILD_DIR) && pwd)/client/win_res.o

$(BUILD_DIR)/client/vid_svgalib.o :  $(CLIENT_DIR)/vid_svgalib.c
	$(DO_O_CC)
$(BUILD_DIR)/client/vid_x.o :        $(CLIENT_DIR)/vid_x.c
	$(DO_CC)
$(BUILD_DIR)/client/vid_sdl.o :      $(CLIENT_DIR)/vid_sdl.c
	$(DO_CC)
$(BUILD_DIR)/client/vid_win.o :      $(CLIENT_DIR)/vid_win.c
	$(DO_CC)

#-----------------------
# GL client
#-----------------------
GLQWCL_COMMON_OBJS = \
	$(BUILD_DIR)/glclient/cl_cam.o \
	$(BUILD_DIR)/glclient/cl_cmd.o \
	$(BUILD_DIR)/glclient/cl_demo.o \
	$(BUILD_DIR)/glclient/cl_draw.o \
	$(BUILD_DIR)/glclient/cl_effects.o \
	$(BUILD_DIR)/glclient/cl_ents.o \
	$(BUILD_DIR)/glclient/cl_input.o \
	$(BUILD_DIR)/glclient/cl_main.o \
	$(BUILD_DIR)/glclient/cl_nqdemo.o \
	$(BUILD_DIR)/glclient/cl_parse.o \
	$(BUILD_DIR)/glclient/cl_pred.o \
	$(BUILD_DIR)/glclient/cl_sbar.o \
	$(BUILD_DIR)/glclient/cl_screen.o \
	$(BUILD_DIR)/glclient/cl_tent.o \
	$(BUILD_DIR)/glclient/cl_view.o \
	$(BUILD_DIR)/glclient/cmd.o \
	$(BUILD_DIR)/glclient/cmodel.o \
	$(BUILD_DIR)/glclient/com_msg.o \
	$(BUILD_DIR)/glclient/common.o \
	$(BUILD_DIR)/glclient/console.o \
	$(BUILD_DIR)/glclient/crc.o \
	$(BUILD_DIR)/glclient/cvar.o \
	$(BUILD_DIR)/glclient/gl_draw.o \
	$(BUILD_DIR)/glclient/gl_mesh.o \
	$(BUILD_DIR)/glclient/gl_model.o \
	$(BUILD_DIR)/glclient/gl_ngraph.o \
	$(BUILD_DIR)/glclient/gl_ralias.o \
	$(BUILD_DIR)/glclient/gl_refrag.o \
	$(BUILD_DIR)/glclient/gl_rlight.o \
	$(BUILD_DIR)/glclient/gl_rmain.o \
	$(BUILD_DIR)/glclient/gl_rmisc.o \
	$(BUILD_DIR)/glclient/gl_rsprite.o \
	$(BUILD_DIR)/glclient/gl_rsurf.o \
	$(BUILD_DIR)/glclient/gl_texture.o \
	$(BUILD_DIR)/glclient/gl_warp.o \
	$(BUILD_DIR)/glclient/host.o \
	$(BUILD_DIR)/glclient/keys.o \
	$(BUILD_DIR)/glclient/mathlib.o \
	$(BUILD_DIR)/glclient/mdfour.o \
	$(BUILD_DIR)/glclient/menu.o \
	$(BUILD_DIR)/glclient/net_chan.o \
	$(BUILD_DIR)/glclient/nonintel.o \
	$(BUILD_DIR)/glclient/pmove.o \
	$(BUILD_DIR)/glclient/pmovetst.o \
	$(BUILD_DIR)/glclient/pr_cmds.o \
	$(BUILD_DIR)/glclient/pr_edict.o \
	$(BUILD_DIR)/glclient/pr_exec.o \
	$(BUILD_DIR)/glclient/q_shared.o \
	$(BUILD_DIR)/glclient/rc_image.o \
	$(BUILD_DIR)/glclient/rc_wad.o \
	$(BUILD_DIR)/glclient/skin.o \
	$(BUILD_DIR)/glclient/snd_dma.o \
	$(BUILD_DIR)/glclient/snd_mem.o \
	$(BUILD_DIR)/glclient/snd_mix.o \
	$(BUILD_DIR)/glclient/sv_bot.o \
	$(BUILD_DIR)/glclient/sv_ccmds.o \
	$(BUILD_DIR)/glclient/sv_ents.o \
	$(BUILD_DIR)/glclient/sv_init.o \
	$(BUILD_DIR)/glclient/sv_main.o \
	$(BUILD_DIR)/glclient/sv_master.o \
	$(BUILD_DIR)/glclient/sv_move.o \
	$(BUILD_DIR)/glclient/sv_nchan.o \
	$(BUILD_DIR)/glclient/sv_phys.o \
	$(BUILD_DIR)/glclient/sv_save.o \
	$(BUILD_DIR)/glclient/sv_send.o \
	$(BUILD_DIR)/glclient/sv_user.o \
	$(BUILD_DIR)/glclient/sv_world.o \
	$(BUILD_DIR)/glclient/teamplay.o \
	$(BUILD_DIR)/glclient/version.o \
	$(BUILD_DIR)/glclient/zone.o

ifdef MAUTH_FLAGS
	# This is only useful for running listen servers.  It also
	# stops make errors.  I wouldn't actually want to use this...
	GLQWCL_COMMON_OBJS	+= \
		$(BUILD_DIR)/client/sv_authlists.o
endif

ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	GLQWCL_COMMON_OBJS	+= \
		$(BUILD_DIR)/glclient/in_win.o \
		$(BUILD_DIR)/glclient/net_wins.o \
		$(BUILD_DIR)/glclient/sys_win.o
else
	GLQWCL_COMMON_OBJS	+= \
		$(BUILD_DIR)/glclient/net_udp.o \
		$(BUILD_DIR)/glclient/sys_linux.o
endif

GLQWCL_AS_OBJS			 =
ifeq ($(DEST_ARCH),x86)	# Linux/x86	& Win32/x86 in MingW environment
	GLQWCL_AS_OBJS		 = \
		$(BUILD_DIR)/glclient/cl_math.o \
		$(BUILD_DIR)/glclient/math.o \
		$(BUILD_DIR)/glclient/snd_mixa.o \
		$(BUILD_DIR)/glclient/sys_x86.o
endif

GLQWCL_PLATFORM_OBJS	 =\
		$(BUILD_DIR)/glclient/cd_null.o \
		$(BUILD_DIR)/glclient/snd_osnull.o
ifeq ($(ARCH),x86)		# Linux/x86
	GLQWCL_PLATFORM_OBJS = \
		$(BUILD_DIR)/glclient/cd_linux.o \
		$(BUILD_DIR)/glclient/snd_linux.o \
		$(BUILD_DIR)/glclient/snd_alsa.o \
		$(BUILD_DIR)/glclient/snd_oss.o
endif
ifeq ($(ARCH),powerpc)	# Linux/ppc
	GLQWCL_PLATFORM_OBJS = \
		$(BUILD_DIR)/glclient/cd_linux.o \
		$(BUILD_DIR)/glclient/snd_linux.o \
		$(BUILD_DIR)/glclient/snd_oss.o \
		$(BUILD_DIR)/glclient/snd_alsa.o
endif
#ifeq ($(ARCH),ppc)		# MacOS-X/ppc
#	GLQWCL_PLATFORM_OBJS = \
#		$(BUILD_DIR)/glclient/cd_null.o \
#		$(BUILD_DIR)/glclient/snd_osx.o
#endif
#ifeq ($(ARCH),intelmac)		# MacOS-X/intel
#	GLQWCL_PLATFORM_OBJS = \
#		$(BUILD_DIR)/glclient/cd_null.o \
#		$(BUILD_DIR)/glclient/snd_osx.o
#endif
ifeq ($(ARCH),mac)		# MacOS X
	GLQWCL_PLATFORM_OBJS = \
		$(BUILD_DIR)/glclient/cd_null.o \
		$(BUILD_DIR)/glclient/snd_osx.o
endif
ifeq ($(ARCH),mingw32)	# Win32/x86 in MingW environment
	GLQWCL_PLATFORM_OBJS = \
		$(BUILD_DIR)/glclient/cd_win.o \
		$(BUILD_DIR)/glclient/snd_win.o
ifeq ($(WINDRES_CHECK),1) # it's only compilable with windres >= v2.15.xx
	GLQWCL_PLATFORM_OBJS+= \
		$(BUILD_DIR)/client/win_res.o
endif
endif

GLQWCL_X11_OBJS			 = \
		$(BUILD_DIR)/glclient/vid_glx.o

GLQWCL_SDL_OBJS			 = \
		$(BUILD_DIR)/glclient/vid_glsdl.o

GLQWCL_WIN_OBJS			 = \
		$(BUILD_DIR)/glclient/vid_wgl.o

#-----------------------
# GL executables
#-----------------------
zquake-glx:	$(BUILD_DIR)/zquake-glx

$(BUILD_DIR)/zquake-glx : $(BUILD_DIR) $(GLQWCL_COMMON_OBJS) $(GLQWCL_PLATFORM_OBJS) $(GLQWCL_X11_OBJS) $(GLQWCL_AS_OBJS)
	$(CC) $(CFLAGS) -o $@ \
		$(GLQWCL_COMMON_OBJS) \
		$(GLQWCL_AS_OBJS) \
		$(GLQWCL_PLATFORM_OBJS) \
		$(GLQWCL_X11_OBJS) \
		$(CL_LDFLAGS) $(LDFLAGS) $(GL_LDFLAGS)

zquake-gl:	$(BUILD_DIR)/zquake-gl

$(BUILD_DIR)/zquake-gl : $(BUILD_DIR) $(GLQWCL_COMMON_OBJS) $(GLQWCL_PLATFORM_OBJS) $(GLQWCL_WIN_OBJS) $(GLQWCL_AS_OBJS)
	$(CC) $(CFLAGS) -o $@ \
		$(GLQWCL_COMMON_OBJS) \
		$(GLQWCL_AS_OBJS) \
		$(GLQWCL_PLATFORM_OBJS) \
		$(GLQWCL_WIN_OBJS) \
		$(CL_LDFLAGS) $(LDFLAGS) $(GL_LDFLAGS)

zquake-glsdl:	$(BUILD_DIR)/zquake-glsdl

$(BUILD_DIR)/zquake-glsdl : $(BUILD_DIR) $(GLQWCL_COMMON_OBJS) $(GLQWCL_PLATFORM_OBJS) $(GLQWCL_SDL_OBJS) $(GLQWCL_AS_OBJS)
	$(CC) $(CFLAGS) -o $@ \
		$(GLQWCL_COMMON_OBJS) \
		$(GLQWCL_AS_OBJS) \
		$(GLQWCL_PLATFORM_OBJS) \
		$(GLQWCL_SDL_OBJS) \
		$(LDFLAGS) $(GL_LDFLAGS) $(SDL_LDFLAGS)

$(BUILD_DIR)/glclient/cd_null.o :        $(CLIENT_DIR)/cd_null.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cd_linux.o :       $(CLIENT_DIR)/cd_linux.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cd_win.o :         $(CLIENT_DIR)/cd_win.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_cam.o :         $(CLIENT_DIR)/cl_cam.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_cmd.o :         $(CLIENT_DIR)/cl_cmd.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_demo.o :        $(CLIENT_DIR)/cl_demo.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_draw.o :        $(CLIENT_DIR)/cl_draw.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_effects.o :     $(CLIENT_DIR)/cl_effects.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_ents.o :        $(CLIENT_DIR)/cl_ents.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_input.o :       $(CLIENT_DIR)/cl_input.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_main.o :        $(CLIENT_DIR)/cl_main.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_nqdemo.o :      $(CLIENT_DIR)/cl_nqdemo.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_parse.o :       $(CLIENT_DIR)/cl_parse.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_pred.o :        $(CLIENT_DIR)/cl_pred.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_sbar.o :        $(CLIENT_DIR)/cl_sbar.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_screen.o :      $(CLIENT_DIR)/cl_screen.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_tent.o :        $(CLIENT_DIR)/cl_tent.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cl_view.o :        $(CLIENT_DIR)/cl_view.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cmd.o :            $(CLIENT_DIR)/cmd.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cmodel.o :         $(CLIENT_DIR)/cmodel.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/com_msg.o :        $(CLIENT_DIR)/com_msg.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/common.o :         $(CLIENT_DIR)/common.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/console.o :        $(CLIENT_DIR)/console.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/crc.o :            $(CLIENT_DIR)/crc.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/cvar.o :           $(CLIENT_DIR)/cvar.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_draw.o :        $(CLIENT_DIR)/gl_draw.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_mesh.o :        $(CLIENT_DIR)/gl_mesh.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_model.o :       $(CLIENT_DIR)/gl_model.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_ngraph.o :      $(CLIENT_DIR)/gl_ngraph.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_ralias.o :      $(CLIENT_DIR)/gl_ralias.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_refrag.o :      $(CLIENT_DIR)/gl_refrag.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_rlight.o :      $(CLIENT_DIR)/gl_rlight.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_rmain.o :       $(CLIENT_DIR)/gl_rmain.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_rmisc.o :       $(CLIENT_DIR)/gl_rmisc.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_rsprite.o :     $(CLIENT_DIR)/gl_rsprite.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_rsurf.o :       $(CLIENT_DIR)/gl_rsurf.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_texture.o :     $(CLIENT_DIR)/gl_texture.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/gl_warp.o :        $(CLIENT_DIR)/gl_warp.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/host.o :           $(SERVER_DIR)/host.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/in_win.o :         $(CLIENT_DIR)/in_win.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/keys.o :           $(CLIENT_DIR)/keys.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/mathlib.o :        $(CLIENT_DIR)/mathlib.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/mdfour.o :         $(CLIENT_DIR)/mdfour.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/menu.o :           $(CLIENT_DIR)/menu.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/net_chan.o :       $(CLIENT_DIR)/net_chan.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/net_udp.o :        $(CLIENT_DIR)/net_udp.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/net_wins.o :       $(CLIENT_DIR)/net_wins.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/nonintel.o :       $(CLIENT_DIR)/nonintel.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/pmove.o :          $(CLIENT_DIR)/pmove.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/pmovetst.o :       $(CLIENT_DIR)/pmovetst.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/pr_cmds.o :        $(SERVER_DIR)/pr_cmds.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/pr_edict.o :       $(SERVER_DIR)/pr_edict.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/pr_exec.o :        $(SERVER_DIR)/pr_exec.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/q_shared.o :       $(CLIENT_DIR)/q_shared.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/rc_image.o :       $(CLIENT_DIR)/rc_image.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/rc_wad.o :         $(CLIENT_DIR)/rc_wad.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/skin.o :           $(CLIENT_DIR)/skin.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_dma.o :        $(CLIENT_DIR)/snd_dma.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_alsa.o :        $(CLIENT_DIR)/snd_alsa.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_linux.o :      $(CLIENT_DIR)/snd_linux.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_mem.o :        $(CLIENT_DIR)/snd_mem.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_mix.o :        $(CLIENT_DIR)/snd_mix.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_null.o :       $(CLIENT_DIR)/snd_null.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_osnull.o :     $(CLIENT_DIR)/snd_osnull.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_oss.o :        $(CLIENT_DIR)/snd_oss.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_osx.o :        $(CLIENT_DIR)/snd_osx.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/snd_win.o :        $(CLIENT_DIR)/snd_win.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_bot.o :         $(SERVER_DIR)/sv_bot.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_ccmds.o :       $(SERVER_DIR)/sv_ccmds.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_ents.o :        $(SERVER_DIR)/sv_ents.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_init.o :        $(SERVER_DIR)/sv_init.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_main.o :        $(SERVER_DIR)/sv_main.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_master.o :      $(SERVER_DIR)/sv_master.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_move.o :        $(SERVER_DIR)/sv_move.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_nchan.o :       $(SERVER_DIR)/sv_nchan.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_phys.o :        $(SERVER_DIR)/sv_phys.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_save.o :        $(SERVER_DIR)/sv_save.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_send.o :        $(SERVER_DIR)/sv_send.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_user.o :        $(SERVER_DIR)/sv_user.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sv_world.o :       $(SERVER_DIR)/sv_world.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sys_linux.o :      $(CLIENT_DIR)/sys_linux.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/sys_win.o :        $(CLIENT_DIR)/sys_win.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/teamplay.o :       $(CLIENT_DIR)/teamplay.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/version.o :        $(CLIENT_DIR)/version.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/zone.o :           $(CLIENT_DIR)/zone.c
	$(DO_GL_CC)

$(BUILD_DIR)/glclient/cl_math.o :        $(CLIENT_DIR)/cl_math.s
	$(DO_GL_AS)
$(BUILD_DIR)/glclient/math.o :           $(CLIENT_DIR)/math.s
	$(DO_GL_AS)
$(BUILD_DIR)/glclient/snd_mixa.o :       $(CLIENT_DIR)/snd_mixa.s
	$(DO_GL_AS)
$(BUILD_DIR)/glclient/sys_x86.o :        $(CLIENT_DIR)/sys_x86.s
	$(DO_GL_AS)

$(BUILD_DIR)/glclient/win_res.o :        $(CLIENT_DIR)/winquake.rc $(CLIENT_DIR)/resource.h
	cd $(CLIENT_DIR) && \
	windres $(filter -D%,$(DO_GL_CC)) -i winquake.rc -o $(shell cd $(BUILD_DIR) && pwd)/client/win_res.o

$(BUILD_DIR)/glclient/gl_vidlinux.o :    $(CLIENT_DIR)/gl_vidlinux.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/vid_glx.o :        $(CLIENT_DIR)/vid_glx.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/vid_glsdl.o :      $(CLIENT_DIR)/vid_glsdl.c
	$(DO_GL_CC)
$(BUILD_DIR)/glclient/vid_wgl.o :        $(CLIENT_DIR)/vid_wgl.c
	$(DO_GL_CC)

