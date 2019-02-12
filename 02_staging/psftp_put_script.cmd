:: Name:     psftp_put_script.cmd
:: Purpose:  Transfer files to staging/downloadserver using psftp
:: Author:   pierre@pvln.nl
::
:: Required environment variables
:: ==============================
:: - staging_command			  command incl path that is used transfer files to staging/download server
:: - staging_user_downloadserver  the username on the download server
:: - staging_pw_downloadserver    the password for that user
:: - output_dir                   the folder with files that are transfered (on local machine)
:: - secrets_folder               the folder where temporary files are stored (on local machine)
:: - staging_downloadserver       the name or ip-address of the staging/download server 
:: - staging_folder               the folder where the files are stored in on the staging/download server
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
IF "%secrets_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] secrets_folder not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
::
:: Remove any existing %secrets_folder%\_ftp_files.txt file
::
IF EXIST "%secrets_folder%\_staging_files.txt" (del "%secrets_folder%\_staging_files.txt")
::
:: Create %secrets_folder%\_staging_files.txt
::
ECHO cd %staging_folder%>>%secrets_folder%\_staging_files.txt
ECHO lcd %output_dir%>>%secrets_folder%\_staging_files.txt
FOR /f %%G in ('dir /b /A:D "%output_dir%"') DO (
	ECHO mkdir %%G>>%secrets_folder%\_staging_files.txt
	ECHO cd %%G>>%secrets_folder%\_staging_files.txt
	ECHO lcd %%G>>%secrets_folder%\_staging_files.txt
    FOR /f %%H in ('dir /b /A:-D "%output_dir%\%%G"') DO (
   	    ECHO put %%H>>%secrets_folder%\_staging_files.txt
    )
	ECHO cd ..>>%secrets_folder%\_staging_files.txt
	ECHO lcd ..>>%secrets_folder%\_staging_files.txt
)	
ECHO bye>>%secrets_folder%\_staging_files.txt

:: Run the script
"%staging_command%" -b %secrets_folder%\_staging_files.txt -be -l %staging_user_downloadserver% -pw %staging_pw_downloadserver% %staging_downloadserver%
del %secrets_folder%\_staging_files.txt
GOTO CLEAN_EXIT_SUBSCRIPT

:ERROR_EXIT_SUBSCRIPT
ECHO *******************
ECHO %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT_SUBSCRIPT   
timeout /T 5
