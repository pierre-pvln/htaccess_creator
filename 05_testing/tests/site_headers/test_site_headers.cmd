:: Name:     test_site_headers.cmd
:: Purpose:  Checks the response headers from a site
:: Author:   pierre@pvln.nl
::
:: Revision: 2019-03-25 Test for subdomain added
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
   SET ERROR_MESSAGE=[ERROR] Environment variable site_name not set ...
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

::
:: Inspiration: https://stackoverflow.com/questions/44502909/batch-file-count-all-occurrences-of-a-character-within-a-string
::
:::: set test_string=%site_name_base%
:::: set domain_segments_count=0
:::: for %%a in (%test_string:.= %) do set /a domain_segments_count+=1

:: Add www to site_name_base if it doesn't contain a subdomain (example.com in stead of www.example.com) 
:: otherwise (subdomain included) use provided site_name_base 
::::IF %domain_segments_count% == 2 SET site_name_base=www.%site_name_base% 

:: Inspiration: https://stackoverflow.com/questions/3252851/how-to-display-request-headers-with-command-line-curl
::               (-o /dev/null in linux ; -o nul in windows)    
::

::  -s - Avoid showing progress bar
::  -D - - Dump headers to a file, but - sends it to stdout
::  -o /dev/null - Ignore response body (Linux)
::  -o nul       - Ignore response body (windows)

ECHO.
ECHO Requesting headers from site http://%site_name_base% ...
curl -sD - -o nul http://%site_name_base%

ECHO Requesting headers from site https://%site_name_base% ...
curl -sD - -o nul https://%site_name_base%

GOTO CLEAN_EXIT

:ERROR_EXIT
cd "%cmd_dir%" 

ECHO *******************
ECHO %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT
timeout /T 10
