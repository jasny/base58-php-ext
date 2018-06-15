@echo off

setlocal enableextensions enabledelayedexpansion

	set TEST_PHP_EXECUTABLE=C:\projects\php-sdk\phpdev\vc14\x64\php-src\x64\Release_TS\php.exe
	%TEST_PHP_EXECUTABLE% C:\projects\php-sdk\phpdev\vc14\x64\php-src\run-tests.php C:\projects\php-sdk\phpdev\vc14\x64\php-src\ext\base58 -q --show-diff

endlocal
