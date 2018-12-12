:: Name:     05_deploy_files_to_server.cmd
:: Purpose:  FTP file to server
:: Author:   pierre.veelen@pvln.nl
::
::
:: Requires environments vaiables to be set:
::  site_name
::  extension_name
::  deploy_folder
::  secrets_folder
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Check if required environment variables are set
IF "%site_name%" == "" (
   SET ERROR_MESSAGE=Environment variable site_name not set.
   GOTO ERROR_EXIT
)
IF "%extension_name%" == "" (
   SET ERROR_MESSAGE=Environment variable extension_name not set.
   GOTO ERROR_EXIT
)
IF "%deploy_folder%" == "" (
   SET ERROR_MESSAGE=Environment variable deploy_folder not set.
   GOTO ERROR_EXIT
)
IF "%secrets_folder%" == "" (
   SET ERROR_MESSAGE=Environment variable secrets_folder not set.
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

:: STATIC VARIABLES
:: ================
::CD ..\04_settings\

::IF EXIST 00_name.cmd (
::   CALL 00_name.cmd
::) ELSE (
::   SET ERROR_MESSAGE=File with baseline name settings doesn't exist
::   GOTO ERROR_EXIT
::)

::IF EXIST 04_folders.cmd (
::   CALL 04_folders.cmd
::) ELSE (
::   SET ERROR_MESSAGE=File with folder settings doesn't exist
::   GOTO ERROR_EXIT
::)

::call deploy_%extension_name%_%sitename%.cmd
cd %secrets_folder%
IF EXIST deploy_%extension_name%_%sitename%.cmd (
   CALL deploy_%extension_name%_%sitename%.cmd
) ELSE (
   SET ERROR_MESSAGE=File with deployment settings for the %extension_name% doesn't exist in %secrets_folder%
   GOTO ERROR_EXIT
)

echo xxxxxxxxxxxx 1 xx
cd
pause


cd "%cmd_dir%" 
IF NOT EXIST "_history" (MD "_history")
IF EXIST ".history_*" (MOVE .htaccess_* _history\)

echo xxxxxxxxxxxx 2 xx
dir
pause

:: Sets the proper date and time stamp with 24Hr Time for log file naming convention
:: inspiration: http://stackoverflow.com/questions/1192476/format-date-and-time-in-a-windows-batch-script
::
SET HOUR=%time:~0,2%
SET dtStamp9=%date:~9,4%%date:~6,2%%date:~3,2%_0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%date:~9,4%%date:~6,2%%date:~3,2%_%time:~0,2%%time:~3,2%%time:~6,2%
IF "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) ELSE (SET dtStamp=%dtStamp24%)

:: download current version from website
echo %deploy_user%>>..\09_temporary\_ftp_files.txt
echo %deploy_pw%>>..\09_temporary\_ftp_files.txt
:: switch to binary mode
echo binary>>..\09_temporary\_ftp_files.txt
:: disable prompt; process the mput or mget without requiring any reply
echo prompt>>..\09_temporary\_ftp_files.txt
echo cd %deploy_folder%>>..\09_temporary\_ftp_files.txt
echo get .htaccess>>..\09_temporary\_ftp_files.txt
echo bye>>..\09_temporary\_ftp_files.txt

:: run the actual FTP commandfile
ftp -s:..\09_temporary\_ftp_files.txt %deploy_server%

del ..\09_temporary\_ftp_files.txt

echo xxxxxxxxxxxx 3 xx

rename .htaccess. .htacces_from_site_%dtStamp%.

:: get the latest version of the file
CURL http://download.pvln.nl/joomla/baselines/htaccess/pvln/.htacces --output .htacces.
COPY .htaccess. .htaccess_to_site_%dtStamp%.

:: put the new version on the website
echo %deploy_user%>>..\09_temporary\_ftp_files.txt
echo %deploy_pw%>>..\09_temporary\_ftp_files.txt
:: switch to binary mode
echo binary>>..\09_temporary\_ftp_files.txt
:: disable prompt; process the mput or mget without requiring any reply
echo prompt>>..\09_temporary\_ftp_files.txt
echo cd %deploy_folder%>>..\09_temporary\_ftp_files.txt
::echo put .htaccess>>..\09_temporary\_ftp_files.txt
echo bye>>..\09_temporary\_ftp_files.txt


echo xxxxxxxxxxxx 4 xx


pause


:: run the actual FTP commandfile
ftp -s:..\09_temporary\_ftp_files.txt %deploy_server%

del ..\09_temporary\_ftp_files.txt

GOTO CLEAN_EXIT

:ERROR_EXIT
cd "%cmd_dir%" 
:: remove any existing _ftp_files.txt file
IF EXIST "..\09_temporary\_ftp_files.txt" (del "..\09_temporary\_ftp_files.txt")
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT   
timeout /T 10
