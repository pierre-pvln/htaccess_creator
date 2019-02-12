:: Name:     05_deploy_files.cmd
:: Purpose:  Deploy files to server
:: Author:   pierre.veelen@pvln.nl
::
::
:: Requires environments variables to be set:
::  site_name
::  extension_name
::  deploy_folder
::  secrets_folder
::  extension_folder
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

ECHO Check if required environment variables are set. If not exit script ...
IF "%site_name%" == "" (
   SET ERROR_MESSAGE=Environment variable site_name not set ...
   GOTO ERROR_EXIT
)
IF "%extension_name%" == "" (
   SET ERROR_MESSAGE=Environment variable extension_name not set ...
   GOTO ERROR_EXIT
)
IF "%deploy_folder%" == "" (
   SET ERROR_MESSAGE=Environment variable deploy_folder not set ...
   GOTO ERROR_EXIT
)
IF "%secrets_folder%" == "" (
   SET ERROR_MESSAGE=Environment variable secrets_folder not set ...
   GOTO ERROR_EXIT
)
IF "%extension_folder%" == "" (
   SET ERROR_MESSAGE=Environment variable extension_folder not set ...
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

::call deploy_%extension_name%_%sitename%.cmd
cd %secrets_folder%
IF EXIST deploy_%extension_name%_%site_name%.cmd (
   CALL deploy_%extension_name%_%site_name%.cmd
) ELSE (
   SET ERROR_MESSAGE=File with deployment settings deploy_%extension_name%_%site_name%.cmd for %extension_name% doesn't exist in %secrets_folder%
   GOTO ERROR_EXIT
)

CD "%cmd_dir%" 
IF NOT EXIST "%extension_folder%" (MD "%extension_folder%")
CD "%extension_folder%"

ECHO Check if any .htaccess files exists and if so move it to history folder ... 
::
:: check for specific files without producing output 
:: inspiration: https://stackoverflow.com/questions/1262708/suppress-command-line-output
::
:: For the previous versions
dir ".htaccess_*" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO NO_RELEVANT_OLD_TYPE_FILES
FOR /f %%G in ('dir /b /A:-D ".htaccess_*"') DO (
    ECHO Moving %%G to history folder ...
    MOVE "%%G" ".\_history\"
)
:NO_RELEVANT_OLD_TYPE_FILES
ECHO No .htaccess_* file found. Continueing ...

:: For the new versions
dir "htaccess_*" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO NO_RELEVANT_NEW_TYPE_FILES
FOR /f %%G in ('dir /b /A:-D "htaccess_*"') DO (
    ECHO Moving %%G to history folder ...
    MOVE "%%G" ".\_history\"
) 
:NO_RELEVANT_NEW_TYPE_FILES
ECHO No htaccess_* file found. Continueing ...

:: Sets the proper date and time stamp with 24Hr Time for log file naming convention
:: inspiration: http://stackoverflow.com/questions/1192476/format-date-and-time-in-a-windows-batch-script
::
SET HOUR=%time:~0,2%
SET dtStamp9=%date:~9,4%%date:~6,2%%date:~3,2%_0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%date:~9,4%%date:~6,2%%date:~3,2%_%time:~0,2%%time:~3,2%%time:~6,2%
IF "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) ELSE (SET dtStamp=%dtStamp24%)

ECHO Download current version of .htaccess from website using ftp ...
CD "%cmd_dir%" 
CALL ftp_get_script.cmd

ECHO Check if .htaccess. was downloaded then rename it ...
CD "%extension_folder%"
IF EXIST .htaccess. ( 
   ECHO Renaming .htaccess to htaccess_from_site_%dtStamp%.txt
   rename .htaccess. htaccess_from_site_%dtStamp%.txt
)

:: Inspiration: https://ec.haxx.se/usingcurl-verbose.html (getting response info in variable)
::              https://stackoverflow.com/questions/313111/is-there-a-dev-null-on-windows 
::               (-o /dev/null in linux ; -o nul in windows)    
::
ECHO Check if htaccess.txt for %site_name% exists at staging area ...
FOR /f "tokens=*" %%G IN ('curl -LI http://download.pvln.nl/joomla/baselines/htaccess/%site_name%/htaccess.txt -o nul -w %%{http_code} -s') DO (
    SET CURL_RESPONSE=%%G
)
IF "%CURL_RESPONSE%" NEQ "200" (
   SET ERROR_MESSAGE=File htaccess.txt for %site_name% is not available at staging area ...
   GOTO ERROR_EXIT
)

ECHO Get the htaccess.txt file for %site_name% from staging area ...
CURL http://download.pvln.nl/joomla/baselines/htaccess/%site_name%/htaccess.txt --output .htaccess.
COPY .htaccess. htaccess_to_site_%dtStamp%.txt

CD "%cmd_dir%" 
CALL ftp_put_script.cmd

ECHO File deployed ...
GOTO CLEAN_EXIT

:ERROR_EXIT
cd "%cmd_dir%" 
:: remove any existing _ftp_files.txt file
IF EXIST "%secrets_folder%\_ftp_files.txt" (del "%secrets_folder%\_ftp_files.txt")
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT
timeout /T 10
