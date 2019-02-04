:: Name:     05_transfer_files_to_server.cmd
:: Purpose:  Transfer files to downloadserver
:: Author:   pierre@pvln.nl
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

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
:CHECK_PSFTP_COMMAND
SET PSFTP_STAGING_COMMAND=
ECHO Checking for psftp ...
WHERE psftp.exe >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
   ECHO psftp not possible ...
   GOTO CHECK_PSCP_COMMAND
)
FOR /F "tokens=*" %%G IN ('where psftp.exe') do (SET PSFTP_STAGING_COMMAND=%%G)
IF NOT ["%PSFTP_STAGING_COMMAND%"] EQU [] (
   ECHO Using psftp ...
   SET staging_command="%PSFTP_STAGING_COMMAND%"
   GOTO PSFTP_TRANSFER_SCRIPT
) ELSE (
   ECHO psftp not possible ...
)

:CHECK_PSCP_COMMAND
SET PSCP_STAGING_COMMAND=
ECHO Checking for pscp ...
WHERE pscp.exe >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
   ECHO pscp not possible ...
   GOTO CHECK_FTP_COMMAND
) 
FOR /F "tokens=*" %%G IN ('where pscp.exe') do (SET PSCP_STAGING_COMMAND=%%G)
IF NOT ["%PSCP_STAGING_COMMAND%"] EQU [] (
   ECHO Using pscp ...
   SET staging_command="%PSCP_STAGING_COMMAND%"
   GOTO PSCP_TRANSFER_SCRIPT
) ELSE (
   ECHO pscp not possible ...
)

:CHECK_FTP_COMMAND
SET FTP_STAGING_COMMAND=
ECHO Checking for ftp ...
WHERE ftp.exe >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
   ECHO ftp not possible ...
   SET ERROR_MESSAGE=Staging transfer command, psftp, pscp or ftp, could not be set
   GOTO ERROR_EXIT
)
FOR /F "tokens=*" %%G IN ('where ftp.exe') do (SET FTP_STAGING_COMMAND=%%G)
IF NOT ["%FTP_STAGING_COMMAND%"] EQU [] (
   ECHO Using ftp ...
   SET staging_command="%FTP_STAGING_COMMAND%"
   ECHO -%staging_command%- ...
   GOTO FTP_TRANSFER_SCRIPT
) ELSE (
   ECHO ftp not possible ...
   SET ERROR_MESSAGE=Staging transfer command, psftp, pscp or ftp, could not be set
   GOTO ERROR_EXIT
)

:FTP_TRANSFER_SCRIPT
Echo Transfer using ftp ...

PAUSE

CD "%cmd_dir%"
:: CALL ftp_staging_htaccess.cmd
:: returns:
:: - staging_downloadserver
:: - staging_user_downloadserver
:: - staging_pw_downloadserver
::
CD ..\..\..\_secrets
IF EXIST ftp_staging_htaccess.cmd (
    CALL ftp_staging_htaccess.cmd
) ELSE (
    SET ERROR_MESSAGE=File with ftp staging settings for .htaccess building blocks doesn't exist
    GOTO ERROR_EXIT
)
CD "%cmd_dir%"
IF EXIST ftp_transfer.cmd (
   CALL ftp_transfer.cmd
   GOTO CLEAN_EXIT
) ELSE (
   SET ERROR_MESSAGE=File ftp_transfer.cmd script doesn't exist
   GOTO ERROR_EXIT
)

:PSCP_TRANSFER_SCRIPT
ECHO Transfer using pscp ...

PAUSE

CD "%cmd_dir%"
CD ..\..\..\_secrets
IF EXIST pscp_staging_htaccess.cmd (
    CALL pscp_staging_htaccess.cmd
) ELSE (
    SET ERROR_MESSAGE=File with pscp staging settings for .htaccess building blocks doesn't exist
    GOTO ERROR_EXIT
)
CD "%cmd_dir%"
IF EXIST pscp_transfer.cmd (
   CALL pscp_transfer.cmd
   GOTO CLEAN_EXIT
) ELSE (
   SET ERROR_MESSAGE=File psftp_transfer.cmd script doesn't exist
   GOTO ERROR_EXIT
)

:PSFTP_TRANSFER_SCRIPT
ECHO Transfer using psftp ...

PAUSE

CD "%cmd_dir%"
CD ..\..\..\_secrets
IF EXIST psftp_staging_htaccess.cmd (
    CALL psftp_staging_htaccess.cmd
) ELSE (
    SET ERROR_MESSAGE=File with psftp staging settings for .htaccess building blocks doesn't exist
    GOTO ERROR_EXIT
)
CD "%cmd_dir%"
IF EXIST psftp_transfer.cmd (
   CALL psftp_transfer.cmd
   GOTO CLEAN_EXIT
) ELSE (
   SET ERROR_MESSAGE=File psftp_transfer.cmd script doesn't exist
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
