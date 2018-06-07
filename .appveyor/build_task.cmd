@echo off
setlocal enableextensions enabledelayedexpansion

	cd /D %APPVEYOR_BUILD_FOLDER%
	if %errorlevel% neq 0 exit /b 3

	set STABILITY=staging
	set DEPS_DIR=%PHP_BUILD_CACHE_BASE_DIR%\deps-%PHP_REL%-%PHP_SDK_VC%-%PHP_SDK_ARCH%
	rem SDK is cached, deps info is cached as well
	echo Updating dependencies in %DEPS_DIR%
	cmd /c phpsdk_deps --update --no-backup --branch %PHP_REL% --stability %STABILITY% --deps %DEPS_DIR%
	if %errorlevel% neq 0 exit /b 3

	rem Something went wrong, most likely when concurrent builds were to fetch deps
	rem updates. It might be, that some locking mechanism is needed.
	if not exist "%DEPS_DIR%" (
		cmd /c phpsdk_deps --update --force --no-backup --branch %PHP_REL% --stability %STABILITY% --deps %DEPS_DIR%
	)
	if %errorlevel% neq 0 exit /b 3

	if "%ZTS_STATE%"=="enable" set ZTS_SHORT=ts
	if "%ZTS_STATE%"=="disable" set ZTS_SHORT=nts
	if "%ZTS_STATE%"=="enable" set ZTS_IN_FILENAME=
	if "%ZTS_STATE%"=="disable" set ZTS_IN_FILENAME=-nts
	if "%PHP_SDK_ARCH%"=="x86" set ARCH_IN_FILENAME=
	if "%PHP_SDK_ARCH%"=="x64" set ARCH_IN_FILENAME=-x86_64

  rem Build libbas58
	cd /d C:\projects\libbase58

	cl /W4 /c base58.c

	rem create static library
	lib /out:libbase58.lib base58.obj

	rem create DLL
	rem link /dll /export:b58_sha256_impl /export:b58tobin /export:b58check /export:b58enc /export:b58check_enc /implib:libbase58.lib /out:libbase58.dll base58.obj
	rem copy /v libbase58.dll C:\projects\php-src\ext\base58\

	echo copy /v libbase58.lib %DEPS_DIR%\lib\
	copy /v libbase58.lib %DEPS_DIR%\lib\
	echo copy /v libbase58.h %DEPS_DIR%\include\
	copy /v libbase58.h %DEPS_DIR%\include\
  
  rem Build PHP
rem  	cd /d C:\projects\php-src
  rem Build extension
	cd /d C:\projects\php-src\ext\base58

	cmd /c buildconf.bat --force

	if %errorlevel% neq 0 exit /b 3

	cmd /c configure.bat --disable-all --with-base58=shared --with-mp=auto --enable-cli --%ZTS_STATE%-zts --enable-object-out-dir=%PHP_BUILD_OBJ_DIR% --with-config-file-scan-dir=%APPVEYOR_BUILD_FOLDER%\build\modules.d --with-prefix=%APPVEYOR_BUILD_FOLDER%\build --with-php-build=%DEPS_DIR%

	if %errorlevel% neq 0 exit /b 3

rem TODO: Adding /D /P for diagnostics only -- remove before merge
	nmake /NOLOGO
rem	if %errorlevel% neq 0 exit /b 3

	nmake install

rem	if %errorlevel% neq 0 exit /b 3


	rem **********************************************************************
	rem TODO -- 06/07/2018:MAB
	rem
	rem There is no php_base58.dll found following the build. I know the build
	rem is successful and that a linkage against libbase58.lib occurs, but it
	rem appears that everything is linked into php7.dll. I'm not sure why that
	rem is happening. This needs to be resolved in order for the tests and
	rem publishing steps can succeed.
	rem **********************************************************************
	echo ""
	echo "-------------------------------------------"
	echo "dir /s %APPVEYOR_BUILD_FOLDER%\*base58*"
	dir /s %APPVEYOR_BUILD_FOLDER%\*base58*
	echo "-------------------------------------------"
	echo "dir /s C:\projects\php-src\*base58*"
	dir /s C:\projects\php-src\*base58*
	echo "-------------------------------------------"
	echo "dir /s C:\obj\*base58*"
	dir /s C:\obj\*base58*
	echo "-------------------------------------------"
	echo ""


  rem Run tests
	mkdir c:\tests_tmp
	set TEST_PHP_EXECUTABLE=%APPVEYOR_BUILD_FOLDER%\build\php.exe
	set TEST_PHP_DLL=%APPVEYOR_BUILD_FOLDER%\build\php7.dll
	set TEST_PHP_JUNIT=c:\tests_tmp\tests-junit.xml
rem	if "%OPCACHE%" equ "1" set TEST_PHP_ARGS=!TEST_PHP_ARGS! -d extension=%APPVEYOR_BUILD_FOLDER%\build\ext\php_opcache.so -d opcache.enable=1 -d opcache.enable_cli=1
	set TEST_PHP_ARGS=-n -d -foo=1 -d extension=%TEST_PHP_DLL% -dxdebug.remote_enable=1
	set SKIP_SLOW_TESTS=1
	set SKIP_DBGP_TESTS=1
	set SKIP_IPV6_TESTS=1
	set REPORT_EXIT_STATUS=1
	echo !TEST_PHP_EXECUTABLE! !TEST_PHP_ARGS! -v
	echo !TEST_PHP_EXECUTABLE! -n run-tests.php -q -x --show-diff --show-slow 1000 --set-timeout 120 -g FAIL,XFAIL,BORK,WARN,LEAK,SKIP --temp-source c:\tests_tmp --temp-target c:\tests_tmp %APPVEYOR_BUILD_FOLDER%\tests
	!TEST_PHP_EXECUTABLE! !TEST_PHP_ARGS! -v
	!TEST_PHP_EXECUTABLE! -n run-tests.php -q -x --show-diff %APPVEYOR_BUILD_FOLDER%\tests

	set EXIT_CODE=%errorlevel%
	powershell -Command "$wc = New-Object 'System.Net.WebClient'; $wc.UploadFile('https://ci.appveyor.com/api/testresults/junit/%APPVEYOR_JOB_ID%', 'c:\tests_tmp\tests-junit.xml')"

	rem We have run the tests, but we're *not* making that fail the build — yet
	rem if %EXIT_CODE% neq 0 exit /b 3

	cd /d %APPVEYOR_BUILD_FOLDER%

	if not exist "%APPVEYOR_BUILD_FOLDER%\build\php7.dll" exit /b 3

	xcopy %APPVEYOR_BUILD_FOLDER%\LICENSE %APPVEYOR_BUILD_FOLDER%\php_base58-%PHP_REL%-!ZTS_SHORT!-%PHP_BUILD_CRT%-%PHP_SDK_ARCH%\ /y /f
	echo F|xcopy %APPVEYOR_BUILD_FOLDER%\build\php7.dll %APPVEYOR_BUILD_FOLDER%\php_base58-%PHP_REL%-!ZTS_SHORT!-%PHP_BUILD_CRT%-%PHP_SDK_ARCH%\php_base58-%APPVEYOR_REPO_TAG_NAME%-%PHP_REL%-%PHP_BUILD_CRT%!ZTS_IN_FILENAME!!ARCH_IN_FILENAME!.dll /y /f
	7z a php_base58-%APPVEYOR_REPO_TAG_NAME%-%PHP_REL%-%PHP_BUILD_CRT%!ZTS_IN_FILENAME!!ARCH_IN_FILENAME!.zip %APPVEYOR_BUILD_FOLDER%\php_base58-%PHP_REL%-!ZTS_SHORT!-%PHP_BUILD_CRT%-%PHP_SDK_ARCH%\*
	appveyor PushArtifact php_base58-%APPVEYOR_REPO_TAG_NAME%-%PHP_REL%-%PHP_BUILD_CRT%!ZTS_IN_FILENAME!!ARCH_IN_FILENAME!.zip -FileName php_base58-%APPVEYOR_REPO_TAG_NAME%-%PHP_REL%-%PHP_BUILD_CRT%!ZTS_IN_FILENAME!!ARCH_IN_FILENAME!.zip
endlocal
