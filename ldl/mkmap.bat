@echo off
set mapname=%1
set p=c:\python25\python.exe

echo Transforming your XML file into a .map file...

type %mapname%.xml | %p% 05-d-3dconlevel.py > %mapname%_level04.xml
if not %errorlevel%==0 goto badcondition

type %mapname%_level04.xml | %p% 04-d-buildermac.py > %mapname%_level03.xml
if not %errorlevel%==0 goto badcondition

type %mapname%_level03.xml | %p% 03-d-lightingst.py > %mapname%_level02.xml
if not %errorlevel%==0 goto badcondition

type %mapname%_level02.xml | %p% 02-d-roomsnstuf.py > %mapname%_level01.xml
if not %errorlevel%==0 goto badcondition

type %mapname%_level01.xml | %p% 01-d-brushsizes.py > %mapname%_level00.xml
if not %errorlevel%==0 goto badcondition

type %mapname%_level00.xml | %p% 00-d-map2mapxml.py > %mapname%.map
if not %errorlevel%==0 goto badcondition

echo Compiling into a .bsp file...

qbsp %mapname% >nul
if not %errorlevel%==0 goto bspfail
light -extra %mapname% >nul
if not %errorlevel%==0 goto lightfail
vis -level 4 %mapname% >nul
if not %errorlevel%==0 goto visfail
copy %mapname%.bsp ..\id1\maps >nul
echo Map compiled successfully and copied to id1\maps!

del %mapname%_level*xml %mapname%.h* %mapname%.prt %mapname%.lit %mapname%.pts %mapname%.map %mapname%.bsp >nul

goto :finished

:badcondition
echo Oops, there was an error!  Please review the messages above and contact the AGRIP-discuss mailing list if you need help.
echo Remember that you must not type the ".xml" after the map file's name.
goto finished

:bspfail
echo compiling the map into a bsp file failed.  I'll run the program with output turned on so you can read the error messages.  Please copy the entire console output to the AGRIP-discuss mailing list so we can fix the bug.
pause
qbsp %mapname%
goto finished

:lightfail
echo lighting the map failed.  I'll run the program with output turned on so you can read the error messages.  Please copy the entire console output to the AGRIP-discuss mailing list so we can fix the bug.
pause
light -extra %mapname%
goto finished

:visfail
echo vising the map a failed.  I'll run the program with output turned on so you can read the error messages.  Please copy the entire console output to the AGRIP-discuss mailing list so we can fix the bug.
pause
vis -level 4 %mapname%
goto finished

:finished
pause
