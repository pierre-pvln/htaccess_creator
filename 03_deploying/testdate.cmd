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

:: Sets the proper date and time stamp with 24Hr Time for log file naming convention
:: inspiration: http://stackoverflow.com/questions/1192476/format-date-and-time-in-a-windows-batch-script
::
SET HOUR=%time:~0,2%
SET dtStamp9=%date:~9,4%%date:~6,2%%date:~3,2%_0%time:~1,1%%time:~3,2%%time:~6,2%
SET dtStamp24=%date:~9,4%%date:~6,2%%date:~3,2%_%time:~0,2%%time:~3,2%%time:~6,2%
IF "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) ELSE (SET dtStamp=%dtStamp24%)

time
ECHO Delen dtStamp9
ECHO date:~9,4 :-%date:~9,4%-
ECHO date:~6,2 :-%date:~6,2%-
ECHO date:~3,2 :-%date:~3,2%-
ECHO time:~1,1 :-%time:~1,1%-
ECHO time:~3,2 :-%time:~3,2%-
ECHO time:~6,2 :-%time:~6,2%-

ECHO Delen dtStamp24
ECHO date:~9,4 :-%date:~9,4%-
ECHO date:~6,2 :-%date:~6,2%-
ECHO date:~3,2 :-%date:~3,2%-
ECHO time:~1,1 :-%time:~0,2%-
ECHO time:~3,2 :-%time:~3,2%-
ECHO time:~6,2 :-%time:~6,2%-

ECHO HOUR      :-%HOUR%-
ECHO dtStamp9  :-%dtStamp9%-
ECHO dtStamp24 :-%dtStamp24%-
ECHO dtStamp   :-%dtStamp%- 

pause