:: Name:     pscp_put_script.cmd
:: Purpose:  Transfer files to staging/downloadserver using pscp
:: Author:   pierre@pvln.nl
::
@ECHO off
::
:: Put it on staging/download server
:: =================================
::
:: Check if required environment variables are set. If not exit script.
::
IF "%staging_command%" == "" (
   SET ERROR_MESSAGE=[ERROR] staging_command not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%staging_user_downloadserver%" == "" (
   SET ERROR_MESSAGE=[ERROR] staging_user_downloadserver not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%staging_pw_downloadserver%" == "" (
   SET ERROR_MESSAGE=[ERROR] staging_pw_downloadserver not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%output_dir%" == "" (
   SET ERROR_MESSAGE=[ERROR] output_dir not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%staging_downloadserver%" == "" (
   SET ERROR_MESSAGE=[ERROR] staging_downloadserver not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%staging_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] staging_folder not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
:: Run the script
"%staging_command%" -l %staging_user_downloadserver% -pw %staging_pw_downloadserver% -r %output_dir%\* %staging_downloadserver%:%staging_folder%
GOTO CLEAN_EXIT_SUBSCRIPT

:ERROR_EXIT_SUBSCRIPT
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT_SUBSCRIPT   
timeout /T 5
