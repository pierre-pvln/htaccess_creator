:: Name:     test_site_headers.cmd
:: Purpose:  Checks the response headers from a site
:: Author:   pierre@pvln.nl
::
::
:: Inspiration: https://stackoverflow.com/questions/3252851/how-to-display-request-headers-with-command-line-curl
::               (-o /dev/null in linux ; -o nul in windows)    
::
:: Requires environments variables to be set:
::  site_name
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Clear the screen
CLS

ECHO Check if required environment variables are set ...
IF "%site_name_base%" == "" (
   SET ERROR_MESSAGE=Environment variable site_name not set ...
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

::  -s - Avoid showing progress bar
::  -D - - Dump headers to a file, but - sends it to stdout
::  -o /dev/null - Ignore response body (Linux)
::  -o nul       - Ignore response body (windows)

ECHO.
ECHO Requesting headers form site http://www.%site_name_base% ...
curl -sD - -o nul http://www.%site_name_base%

ECHO Requesting headers form site https://www.%site_name_base% ...
curl -sD - -o nul https://www.%site_name_base%


GOTO CLEAN_EXIT
:ERROR_EXIT
cd "%cmd_dir%" 

ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT
timeout /T 10
