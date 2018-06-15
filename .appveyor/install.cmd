@echo off

setlocal enableextensions enabledelayedexpansion

	cinst wget
	"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" %ARCH%

endlocal

