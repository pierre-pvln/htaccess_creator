:: Name:     05_stage_files.cmd
:: Purpose:  Transfer files to staging/downloadserver
:: Author:   pierre@pvln.nl
::
:: Required environment variables
:: ==============================
:: extension_name                 the name of the extension
:: staging_folder                 the folder where the files are stored in on the staging/download server
:: secrets_folder                 the folder where the secrets are stored
:: output_dir                     the folder with files that are transfered (on local machine)
::
@ECHO off
::
:: inspiration: http://batcheero.blogspot.com/2007/06/how-to-enabledelayedexpansion.html
:: using ENABLEDELAYEDEXPANSION and !env-var! ensures correct operation of script 
::
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
::
:: Check if required environment variables are set. If not exit script ...
::
IF "%extension_name%" == "" (
   SET ERROR_MESSAGE=[ERROR] [05_stage_file.cmd] extension_name not set ...
   GOTO ERROR_EXIT
)
IF "%staging_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [05_stage_file.cmd] staging_folder not set ...
   GOTO ERROR_EXIT
)
IF "%secrets_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [05_stage_file.cmd] secrets_folder not set ...
   GOTO ERROR_EXIT
)
IF "%output_dir%" == "" (
   SET ERROR_MESSAGE=[ERROR] [05_stage_file.cmd] output_dir not set ...
   GOTO ERROR_EXIT
)
::IF "%extension_folder%" == "" (
::   SET ERROR_MESSAGE=[ERROR] extension_folder not set ...
::   GOTO ERROR_EXIT
::)

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

::IF EXIST 04_folders.cmd (
::   CALL 04_folders.cmd
::) ELSE (
::   SET ERROR_MESSAGE=File with folder settings doesn't exist
::   GOTO ERROR_EXIT
::)

::
:: Assume psftp should be used first. Then pscp. If not available choose ftp
::

:: !! Do not use " or ' at beginning or end of the list
::    Do not use sftp as the password can't be entered from batch files   
SET CHECK_PUT_LIST=psftp pscp ftp
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
SET ERROR_MESSAGE=[ERROR] [05_stage_file.cmd] A staging transfer command from %CHECK_PUT_LIST% could not be set ...
GOTO ERROR_EXIT

:PUT_COMMAND_FOUND
ECHO Transfer using %WHICH_PUT_COMMAND% ...
CD "%cmd_dir%"
:: CALL stage_%extension_name%_%WHICH_PUT_COMMAND%.cmd
:: returns:
:: - staging_downloadserver
:: - staging_user_downloadserver
:: - staging_pw_downloadserver
::
CD %secrets_folder%
IF EXIST stage_%extension_name%_%WHICH_PUT_COMMAND%.cmd (
    CALL stage_%extension_name%_%WHICH_PUT_COMMAND%.cmd
) ELSE (
    SET ERROR_MESSAGE=[ERROR] [05_stage_file.cmd] File stage_%extension_name%_%WHICH_PUT_COMMAND%.cmd with staging settings for %extension_name% building blocks doesn't exist
    GOTO ERROR_EXIT
)
::
:: Put the files on the server
::
CD "%cmd_dir%"
::
:: For some put actions temporary files are needed. Set a foldername for that.
::
SET temporary_folder=%secrets_folder%
IF EXIST stage_%WHICH_PUT_COMMAND%_put.cmd (
   ECHO running stage_%WHICH_PUT_COMMAND%_put.cmd ...
   CALL stage_%WHICH_PUT_COMMAND%_put.cmd
   GOTO CLEAN_EXIT
) ELSE (
   SET ERROR_MESSAGE=[ERROR] [05_stage_file.cmd] File stage_%WHICH_PUT_COMMAND%_put.cmd script doesn't exist
   GOTO ERROR_EXIT
)

:ERROR_EXIT
cd "%cmd_dir%" 
:: remove any existing _staging_files.txt file
IF EXIST "%temporary_folder%\_staging_files.txt" (del "%temporary_folder%\_staging_files.txt")
ECHO *******************
ECHO %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT
timeout /T 10
