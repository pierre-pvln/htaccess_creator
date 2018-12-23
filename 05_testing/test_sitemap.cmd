:: Name:     test_sitemap.cmd
:: Purpose:  Checks if sitemap.xml exists, and shows content
:: Author:   pierre.veelen@pvln.nl
::
:: Inspiration: https://ec.haxx.se/usingcurl-verbose.html (getting response info in variable)
::              https://stackoverflow.com/questions/313111/is-there-a-dev-null-on-windows 
::               (-o /dev/null in linux ; -o nul in windows)    
::
:: Requires environments variables to be set:
::  site_name_base
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Clear the screen
CLS

ECHO Check if required environment variables are set ...
IF "%site_name_base%" == "" (
   SET ERROR_MESSAGE=Environment variable site_name_base not set ...
   GOTO ERROR_EXIT
)

:: BASIC SETTINGS
:: ==============
:: Setting the name of the script
SET me=%~n0
:: Setting the name of the directory with this script
SET parent=%~p0
:: Setting the drive of this commandfile
SET drive=%~d0
:: Setting the directory and drive of this commandfile
SET cmd_dir=%~dp0

ECHO.
ECHO Checking https://www.%site_name_base%/sitemap.xml ...
FOR /f "tokens=*" %%G IN ('curl -LI https://www.%site_name_base%/sitemap.xml -o nul -w %%{http_code} -s') DO (
    SET CURL_RESPONSE_CODE=%%G
)

IF "%CURL_RESPONSE_CODE%" NEQ "200" (
   SET ERROR_MESSAGE=File https://www.%site_name_base%/sitemap.xml is not available ...
   GOTO ERROR_EXIT
)

ECHO Show contents of file ...
CURL https://www.%site_name_base%/sitemap.xml

GOTO CLEAN_EXIT
:ERROR_EXIT
cd "%cmd_dir%" 

ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT
timeout /T 10
