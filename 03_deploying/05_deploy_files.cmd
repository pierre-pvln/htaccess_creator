:: Name:     05_deploy_files.cmd
:: Purpose:  Deploy files to server
:: Author:   pierre@pvln.nl
::
:: Required environment variables
:: ==============================
:: site_name                      the name of the site
:: extension_name                 the name of the extension
:: deploy_folder
:: secrets_folder                 the folder where the secrets are stored
:: extension_folder               the folder where the old and the newly deployed files are stored
:: CHECK_TRANSFER_LIST            list off commands which could be used to transfer the files
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
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] extension_name not set ...
   GOTO ERROR_EXIT
)
IF "%deploy_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] deploy_folder not set ...
   GOTO ERROR_EXIT
)
IF "%secrets_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] secrets_folder not set ...
   GOTO ERROR_EXIT
)
IF "%extension_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] extension_folder not set ...
   GOTO ERROR_EXIT
)
IF "%site_name%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] site_name not set ...
   GOTO ERROR_EXIT
)
IF "%CHECK_TRANSFER_LIST%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] CHECK_TRANSFER_LIST not set ...
   GOTO ERROR_EXIT
)
::
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
:: Reset environment variables
::
SET TRANSFER_COMMAND=
SET deploy_command=

FOR %%x IN (%CHECK_TRANSFER_LIST%) DO (
    ECHO [INFO ] Checking for %%x ...
    where /Q %%x
    IF !ERRORLEVEL!==0 ( 
       FOR /F "tokens=*" %%G IN ( 'WHERE %%x' ) DO ( SET deploy_command=%%G )
       SET TRANSFER_COMMAND=%%x
	   GOTO TRANSFER_COMMAND_FOUND
    ) ELSE (
        ECHO [INFO ] %%x not possible ...		
    )
)
:TRANSFER_COMMAND_NOT_FOUND
SET ERROR_MESSAGE=[ERROR] [%~n0 ] A deploy command from %CHECK_TRANSFER_LIST% could not be set ...
GOTO ERROR_EXIT

:TRANSFER_COMMAND_FOUND
ECHO Transfer using %TRANSFER_COMMAND% ...
::
CD "%cmd_dir%"
:: call deploy_%extension_name%_%sitename%.cmd
:: returns:
:: - deploy_downloadserver
:: - deploy_user_downloadserver
:: - deploy_pw_downloadserver
::
CD %secrets_folder%
IF EXIST deploy_%extension_name%_%TRANSFER_COMMAND%.cmd (
   CALL deploy_%extension_name%_%TRANSFER_COMMAND%.cmd
) ELSE (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] File with deployment settings deploy_%extension_name%_%TRANSFER_COMMAND%.cmd for %extension_name% doesn't exist in %secrets_folder%
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
    ECHO [INFO ] Moving %%G to history folder ...
    MOVE "%%G" ".\_history\"
)
:NO_RELEVANT_OLD_TYPE_FILES
ECHO [INFO ] No .htaccess_* file found. Continueing ...

:: For the new versions
dir "htaccess_*" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO NO_RELEVANT_NEW_TYPE_FILES
FOR /f %%G in ('dir /b /A:-D "htaccess_*"') DO (
    ECHO [INFO ] Moving %%G to history folder ...
    MOVE "%%G" ".\_history\"
) 
:NO_RELEVANT_NEW_TYPE_FILES
ECHO [INFO ] No htaccess_* file found. Continueing ...

:: Sets the proper date and time stamp with 24Hr Time for log file naming convention
:: inspiration: http://stackoverflow.com/questions/1192476/format-date-and-time-in-a-windows-batch-script
::
SET HOUR=%time:~0,2%
SET dtStamp9=%date:~9,4%%date:~6,2%%date:~3,2%_0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%date:~9,4%%date:~6,2%%date:~3,2%_%time:~0,2%%time:~3,2%%time:~6,2%
IF "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) ELSE (SET dtStamp=%dtStamp24%)

ECHO [INFO ] Download current version of .htaccess from website using %TRANSFER_COMMAND% ...
CD "%cmd_dir%" 
SET temporary_folder=%secrets_folder%
CALL deploy_%TRANSFER_COMMAND%_get.cmd

ECHO Check if .htaccess. was downloaded then rename it ...
CD "%extension_folder%"
IF EXIST .htaccess. ( 
   ECHO [INFO ] Renaming .htaccess to htaccess_from_site_%dtStamp%.txt
   RENAME .htaccess. htaccess_from_site_%dtStamp%.txt
)

:: Inspiration: https://ec.haxx.se/usingcurl-verbose.html (getting response info in variable)
::              https://stackoverflow.com/questions/313111/is-there-a-dev-null-on-windows 
::               (-o /dev/null in linux ; -o nul in windows)    
::
ECHO [INFO ] Check if htaccess.txt for %site_name% exists at staging area ...
FOR /f "tokens=*" %%G IN ('curl -LI http://download.pvln.nl/joomla/baselines/htaccess/%site_name%/htaccess.txt -o nul -w %%{http_code} -s') DO (
    SET CURL_RESPONSE=%%G
)
IF "%CURL_RESPONSE%" NEQ "200" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] File htaccess.txt for %site_name% is not available at staging area ...
   GOTO ERROR_EXIT
)

ECHO [INFO ] Get the htaccess.txt file for %site_name% from staging area ...
curl http://download.pvln.nl/joomla/baselines/htaccess/%site_name%/htaccess.txt --output .htaccess.
COPY .htaccess. htaccess_to_site_%dtStamp%.txt
::
:: Put the files on the server
::
CD "%cmd_dir%" 
::
:: For some put actions temporary files are needed. Set a foldername for that.
::
SET temporary_folder=%secrets_folder%
IF EXIST deploy_%TRANSFER_COMMAND%_put.cmd (
   ECHO [INFO ] Running deploy_%TRANSFER_COMMAND%_put.cmd ...
   CALL deploy_%TRANSFER_COMMAND%_put.cmd
   ECHO [INFO ] File deployed ...
   GOTO CLEAN_EXIT
) ELSE (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] File deploy_%TRANSFER_COMMAND%_put.cmd script doesn't exist
   GOTO ERROR_EXIT
)

:ERROR_EXIT
cd "%cmd_dir%" 
:: remove any existing _deploy_files.txt file
IF EXIST "%temporary_folder%\_deploy_files.txt" (del "%temporary_folder%\_deploy_files.txt")
ECHO *******************
ECHO %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT
timeout /T 10
