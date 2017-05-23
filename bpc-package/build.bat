@echo off
setlocal ENABLEDELAYEDEXPANSION

set _argcActual=0
for %%i in (%*) do set /A _argcActual+=1

if %_argcActual% GTR 1 (
	echo "Usage: %0 [source dir]"
	goto :EOF
)

set mydir=%~dp0
set workd=%cd%

rem echo mydir: %mydir%
rem echo workd: %workd%
	
if %_argcActual% EQU 1 (
	echo ** Building CMakeLists.txt at %1 in %workd%
	cmake.exe -DBUILD_ARGS:STRING="BUILD_PREFIX;%workd%;SOURCE_DIR;%1" -P %mydir%/bpc_build.cmake
)

if %_argcActual% EQU 0  (
	echo ** Building in %workd%
	cmake.exe -DBUILD_ARGS:STRING="BUILD_PREFIX;%workd%" -P %mydir%/bpc_build.cmake
)
