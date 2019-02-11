:: Name:     05_transfer_files_to_server.cmd
:: Purpose:  Transfer files to downloadserver
:: Author:   pierre@pvln.nl
::
@ECHO off
::
:: inspiration: http://batcheero.blogspot.com/2007/06/how-to-enabledelayedexpansion.html
:: using ENABLEDELAYEDEXPANSION and !env-var! ensures correct operation of script 
::
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

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
CD ..\04_settings\

IF EXIST 04_folders.cmd (
   CALL 04_folders.cmd
) ELSE (
   SET ERROR_MESSAGE=File with folder settings doesn't exist
   GOTO ERROR_EXIT
)

::
:: Assume psftp should be used first. Then pscp. If not available choose ftp
::

:: !! Do not use " or ' at beginning or end of the list
::    Do not use sftp as the password can't be entered from batch files   
SET CHECK_PUT_LIST=psftpx pscpx ftp
::
:: Reset environment variables
::
SET WHICH_PUT_COMMAND=
SET staging_command=

FOR %%x IN (%CHECK_PUT_LIST%) DO (
    ECHO Checking for %%x ...
    where /Q %%x
    IF !ERRORLEVEL!==0 ( 
       FOR /F "tokens=*" %%G IN ( 'WHERE %%x' ) DO ( SET staging_command=%%G )
       SET WHICH_PUT_COMMAND=%%x
	   GOTO PUT_COMMAND_FOUND
    ) ELSE (
        ECHO %%x not possible ...		
    )
)
:PUT_COMMAND_NOT_FOUND
SET ERROR_MESSAGE=A staging transfer command from %CHECK_PUT_LIST% could not be set ...
GOTO ERROR_EXIT

:PUT_COMMAND_FOUND
ECHO Transfer using %WHICH_PUT_COMMAND% ...
CD "%cmd_dir%"
:: CALL %WHICH_PUT_COMMAND%_staging_htaccess.cmd
:: returns:
:: - staging_downloadserver
:: - staging_user_downloadserver
:: - staging_pw_downloadserver
::
CD ..\..\..\_secrets
IF EXIST %WHICH_PUT_COMMAND%_staging_htaccess.cmd (
    CALL %WHICH_PUT_COMMAND%_staging_htaccess.cmd
) ELSE (
    SET ERROR_MESSAGE=File %WHICH_PUT_COMMAND%_staging_htaccess.cmd with staging settings for .htaccess building blocks doesn't exist
    GOTO ERROR_EXIT
)
::
:: Put the files on the server
::
CD "%cmd_dir%"
IF EXIST %WHICH_PUT_COMMAND%_put_script.cmd (
   ECHO running %WHICH_PUT_COMMAND%_put_script.cmd ...
   CALL %WHICH_PUT_COMMAND%_put_script.cmd
   GOTO CLEAN_EXIT
) ELSE (
   SET ERROR_MESSAGE=File %WHICH_PUT_COMMAND%_put_script.cmd script doesn't exist
   GOTO ERROR_EXIT
)

:ERROR_EXIT
cd "%cmd_dir%" 
:: remove any existing _staging_files.txt file
IF EXIST "..\09_temporary\_staging_files.txt" (del "..\09_temporary\_staging_files.txt")
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT   
timeout /T 10
