# Microsoft Developer Studio Project File - Name="qw" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Generic Project" 0x010a

CFG=qw - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "qw.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "qw.mak" CFG="qw - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "qw - Win32 Release" (based on "Win32 (x86) Generic Project")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
MTL=midl.exe
# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# Begin Target

# Name "qw - Win32 Release"
# Begin Source File

SOURCE=.\qw\buttons.qc
# End Source File
# Begin Source File

SOURCE=.\qw\client.qc
# End Source File
# Begin Source File

SOURCE=.\qw\combat.qc
# End Source File
# Begin Source File

SOURCE=.\qw\commands.qc
# End Source File
# Begin Source File

SOURCE=.\qw\defs.qc
# End Source File
# Begin Source File

SOURCE=.\qw\doors.qc
# End Source File
# Begin Source File

SOURCE=.\qw\items.qc
# End Source File
# Begin Source File

SOURCE=.\qw\misc.qc
# End Source File
# Begin Source File

SOURCE=.\qw\models.qc
# End Source File
# Begin Source File

SOURCE=.\qw\plats.qc
# End Source File
# Begin Source File

SOURCE=.\qw\player.qc
# End Source File
# Begin Source File

SOURCE=.\qw\progs.src
# Begin Custom Build
InputPath=.\qw\progs.src

"qwprogs.dat" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	.\zqcc -src qw

# End Custom Build
# End Source File
# Begin Source File

SOURCE=.\qw\server.qc
# End Source File
# Begin Source File

SOURCE=.\qw\spectate.qc
# End Source File
# Begin Source File

SOURCE=.\qw\sprites.qc
# End Source File
# Begin Source File

SOURCE=.\qw\subs.qc
# End Source File
# Begin Source File

SOURCE=.\qw\triggers.qc
# End Source File
# Begin Source File

SOURCE=.\qw\weapons.qc
# End Source File
# Begin Source File

SOURCE=.\qw\world.qc
# End Source File
# End Target
# End Project
