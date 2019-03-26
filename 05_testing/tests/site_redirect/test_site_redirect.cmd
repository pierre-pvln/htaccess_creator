:: Name:     test_site_redirect.cmd
:: Purpose:  Checks if various site requests end up at site https://www.<<site_name_base>>
:: Author:   pierre@pvln.nl
::
:: Revision: 2019-03-25 Test for xx.yy.nn or yy.nn added
::
:: Inspiration: https://ec.haxx.se/usingcurl-verbose.html (getting response info in variable)
::              https://stackoverflow.com/questions/313111/is-there-a-dev-null-on-windows 
::               (-o /dev/null in linux ; -o nul in windows)    
::
:: Requires environments variables to be set:
::  site_name_base
::

@ECHO off
::
:: inspiration: http://batcheero.blogspot.com/2007/06/how-to-enabledelayedexpansion.html
:: using ENABLEDELAYEDEXPANSION and !env-var! ensures correct operation of script 
::
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

:: Clear the screen
CLS

ECHO Check if required environment variables are set ...
IF "%site_name_base%" == "" (
   SET ERROR_MESSAGE=[ERROR] Environment variable site_name_base not set ...
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
SET test_string=%site_name_base%
SET domain_segments_count=0
FOR %%a IN (%test_string:.= %) DO SET /a domain_segments_count+=1

ECHO.
ECHO Checking http://%site_name_base% ...
SET "CURL_RESPONSE_CODE=" 
SET "CURL_REDIRECT_URL="
FOR /f "tokens=*" %%G IN ('curl -I http://%site_name_base% -o nul -w %%{http_code} -s') DO (
	SET CURL_RESPONSE_CODE=%%G
)
FOR /f "tokens=*" %%G IN ('curl -I http://%site_name_base% -o nul -w %%{redirect_url} -s') DO (
    SET CURL_REDIRECT_URL=%%G
)
ECHO Server responds with code: %CURL_RESPONSE_CODE% and location: %CURL_REDIRECT_URL% 

:: Add www to site_name_base if it doesn't contain a subdomain (example.com in stead of www.example.com) 
:: otherwise (subdomain included) use provided site_name_base 
IF %domain_segments_count% == 2 (
   ECHO.
   ECHO Checking http://www.%site_name_base% ...
   SET "CURL_RESPONSE_CODE=" 
   SET "CURL_REDIRECT_URL="
   FOR /f "tokens=*" %%G IN ('curl -I http://www.%site_name_base% -o nul -w %%{http_code} -s') DO (
      SET CURL_RESPONSE_CODE=%%G
   )
   FOR /f "tokens=*" %%G IN ('curl -I http://www.%site_name_base% -o nul -w %%{redirect_url} -s') DO (
       SET CURL_REDIRECT_URL=%%G
   )
   ECHO Server responds with code: !CURL_RESPONSE_CODE! and location: !CURL_REDIRECT_URL! 
)

ECHO.
ECHO Checking https://%site_name_base% ...
SET "CURL_RESPONSE_CODE=" 
SET "CURL_REDIRECT_URL="
FOR /f "tokens=*" %%G IN ('curl -I https://%site_name_base% -o nul -w %%{http_code} -s') DO (
    SET CURL_RESPONSE_CODE=%%G
)
FOR /f "tokens=*" %%G IN ('curl -I https://%site_name_base% -o nul -w %%{redirect_url} -s') DO (
    SET CURL_REDIRECT_URL=%%G
)
ECHO Server responds with code: %CURL_RESPONSE_CODE% and location: %CURL_REDIRECT_URL% 

:: Add www to site_name_base if it doesn't contain a subdomain (example.com in stead of www.example.com) 
:: otherwise (subdomain included) use provided site_name_base 
IF %domain_segments_count% == 2 (
   ECHO.
   ECHO Checking https://www.%site_name_base% ...
   SET "CURL_RESPONSE_CODE=" 
   SET "CURL_REDIRECT_URL="
   FOR /f "tokens=*" %%G IN ('curl -I https://www.%site_name_base% -o nul -w %%{http_code} -s') DO (
      SET CURL_RESPONSE_CODE=%%G
   )
   FOR /f "tokens=*" %%G IN ('curl -I https://www.%site_name_base% -o nul -w %%{redirect_url} -s') DO (
       SET CURL_REDIRECT_URL=%%G
   )
   ECHO Server responds with code: !CURL_RESPONSE_CODE! and location: !CURL_REDIRECT_URL! 
)

GOTO CLEAN_EXIT
:ERROR_EXIT
cd "%cmd_dir%" 

ECHO *******************
ECHO %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT
timeout /T 10
