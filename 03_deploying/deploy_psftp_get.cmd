:: Name:     deploy_psftp_get.cmd
:: Purpose:  Transfer files to webserver using ftp
:: Author:   pierre@pvln.nl
::
:: Required environment variables
:: ==============================
:: - deploy_command	    		  command incl path that is used transfer files to staging/download server
:: - deploy_user_downloadserver   the username on the download server
:: - deploy_pw_downloadserver     the password for that user
:: - output_dir    DELETE         the folder with files that are transfered (on local machine)
:: - temporary_folder             the folder where temporary files are stored (on local machine)
:: - deploy_downloadserver        the name or ip-address of the staging/download server 
:: - deploy_folder                the folder where the files are stored in on the staging/download server
::
:: Remarks
:: ==============================
:: %~n0 = the name of this script
::
@ECHO off
::
:: Check if required environment variables are set. If not exit script.
::
IF "%deploy_command%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] deploy_command not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%deploy_user_downloadserver%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] deploy_user_downloadserver not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%deploy_pw_downloadserver%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] deploy_pw_downloadserver not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
::IF "%output_dir%" == "" (
::   SET ERROR_MESSAGE=[ERROR] [%~n0 ] output_dir not set ...
::   GOTO ERROR_EXIT_SUBSCRIPT
::)
IF "%deploy_downloadserver%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] deploy_downloadserver not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%temporary_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] temporary_folder not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%deploy_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] deploy_folder not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
::
:: remove any existing %temporary_folder%\_deploy_files.txt file
::
IF EXIST "%temporary_folder%\_deploy_files.txt" (del "%temporary_folder%\_deploy_files.txt")
::
:: Create %temporary_folder%\_deploy_files.txt
::
ECHO lcd %extension_folder%>>%temporary_folder%\_deploy_files.txt
ECHO cd %deploy_folder%>>%temporary_folder%\_deploy_files.txt
ECHO get .htaccess>>%temporary_folder%\_deploy_files.txt
ECHO bye>>%temporary_folder%\_deploy_files.txt

:: Run the script
"%deploy_command%" -b %temporary_folder%\_deploy_files.txt -be -l %deploy_user_downloadserver% -pw %deploy_pw_downloadserver% %deploy_downloadserver%
DEL %temporary_folder%\_deploy_files.txt
GOTO CLEAN_EXIT_SUBSCRIPT

:ERROR_EXIT_SUBSCRIPT
ECHO %ERROR_MESSAGE%
::timeout /T 5
EXIT /B 1

:CLEAN_EXIT_SUBSCRIPT   
::timeout /T 5
EXIT /B 0