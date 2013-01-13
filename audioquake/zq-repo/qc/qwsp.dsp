# Microsoft Developer Studio Project File - Name="qwsp" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Generic Project" 0x010a

CFG=qwsp - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "qwsp.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "qwsp.mak" CFG="qwsp - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "qwsp - Win32 Release" (based on "Win32 (x86) Generic Project")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
MTL=midl.exe
# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "qwsp___Win32_Release"
# PROP BASE Intermediate_Dir "qwsp___Win32_Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# Begin Target

# Name "qwsp - Win32 Release"
# Begin Source File

SOURCE=.\qwsp\ai.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\boss.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\client.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\demon.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\dog.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\enforcer.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\fight.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\fish.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\hknight.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\knight.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\monsters.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\ogre.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\oldone.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\progs.src
# Begin Custom Build
InputPath=.\qwsp\progs.src

"spprogs.dat" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	.\zqcc -src qwsp

# End Custom Build
# End Source File
# Begin Source File

SOURCE=.\qwsp\shalrath.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\shambler.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\soldier.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\subs.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\tarbaby.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\wizard.qc
# End Source File
# Begin Source File

SOURCE=.\qwsp\zombie.qc
# End Source File
# End Target
# End Project
