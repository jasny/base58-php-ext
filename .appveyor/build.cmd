@echo off

setlocal enableextensions enabledelayedexpansion

	REM pull and build bitcoin/libbase58
	
	echo Cloning Bitcoin libbase58 repository ...
	git clone -q --depth=1 https://github.com/bitcoin/libbase58.git C:\projects\libbase58
	pushd C:\projects\libbase58
	git fetch origin pull/7/head:holland-windows-build
	git checkout holland-windows-build

	echo Building Bitcoin libbase58 ...
	cl /W4 /c base58.c
	lib /out:libbase58.lib base58.obj
	popd

	REM set up PHP
	mkdir C:\projects\php-sdk >NUL 2>NUL
	cd C:\projects\php-sdk
    wget %PHP_SDK_BINARY_TOOLS_URL%/%PHP_SDK_BINARY_TOOLS_PACKAGE% --no-check-certificate -q -O %PHP_SDK_BINARY_TOOLS_PACKAGE%
    7z x -y %PHP_SDK_BINARY_TOOLS_PACKAGE%
	cmd /c bin\phpsdk_buildtree.bat phpdev
	pushd phpdev
	ren vc9 vc14
	pushd vc14\x64
    git clone https://git.php.net/repository/php-src.git
	cd php-src
	git checkout PHP-%PHP_REL%
	cd ..
	wget %PHP_DEPS_URL%/%PHP_DEPS_PACKAGE% --no-check-certificate -q -O %PHP_DEPS_PACKAGE%
	7z x -y %PHP_DEPS_PACKAGE%
	popd
	popd

	REM copy the extension into the PHP tree
	mkdir c:\projects\php-sdk\phpdev\vc14\x64\php-src\ext\base58
	xcopy c:\projects\base58-php-ext\*.* c:\projects\php-sdk\phpdev\vc14\x64\php-src\ext\base58 /s/e/v
	pushd c:\projects\php-sdk\phpdev\vc14\x64\php-src\ext\base58
	del /q CREDITS
	popd
	
	REM The bison utility is needed for the PHP build, so add MSYS to the path.
	REM Note: Add to the end to ensure MSVC tools are found firts.
	set PATH=%PATH%;c:\MinGW\msys\1.0\bin

	REM perform the build
	cmd /c bin\phpsdk_setvars.bat
	pushd phpdev\vc14\x64\php-src
	cmd /c buildconf --force
	cmd /c configure --disable-all --enable-cli --with-extra-includes=c:\projects\libbase58 --with-extra-libs=c:\projects\libbase58 --with-base58=shared
	nmake
	popd

	REM TODO:debugging
	dir php_base58.dll /s
	dir php.exe /s
	dir php*.dll /s

endlocal

exit /b 0
