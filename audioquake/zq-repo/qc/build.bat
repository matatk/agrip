@echo off

echo.
echo === Building QW ===
zqcc -src qw

echo.
echo.
echo === Building QWSP ===
zqcc -src qwsp
