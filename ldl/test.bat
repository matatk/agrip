@echo off
set mapname=%1
cd ..
perl start.pl rawlaunch +deathmatch 0 +map %mapname%
cd ldl