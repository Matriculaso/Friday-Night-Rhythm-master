@ECHO OFF

set /P c=export type [debug/release/etc]:
set curPath=%~dp0
set daPath=%curPath:~0,-1%\export\%c%\windows\bin
del /s /q %daPath%
echo %daPath%
exit