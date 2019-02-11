:: Name:     psftp_put_script.cmd
:: Purpose:  Transfer files to staging/downloadserver using psftp
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
::
:: Remove any existing ..\09_temporary\_ftp_files.txt file
::
IF EXIST "..\09_temporary\_staging_files.txt" (del "..\09_temporary\_staging_files.txt")
::
:: Create ..\09_temporary\_staging_files.txt
::
ECHO cd %staging_folder%>>..\09_temporary\_staging_files.txt
ECHO lcd %output_dir%>>..\09_temporary\_staging_files.txt
FOR /f %%G in ('dir /b /A:D "%output_dir%"') DO (
	ECHO mkdir %%G>>..\09_temporary\_staging_files.txt
	ECHO cd %%G>>..\09_temporary\_staging_files.txt
	ECHO lcd %%G>>..\09_temporary\_staging_files.txt
    FOR /f %%H in ('dir /b /A:-D "%output_dir%\%%G"') DO (
   	    ECHO put %%H>>..\09_temporary\_staging_files.txt
    )
	ECHO cd ..>>..\09_temporary\_staging_files.txt
	ECHO lcd ..>>..\09_temporary\_staging_files.txt
)	
ECHO bye>>..\09_temporary\_staging_files.txt

:: Run the script
"%staging_command%" -b ..\09_temporary\_staging_files.txt -be -l %staging_user_downloadserver% -pw %staging_pw_downloadserver% %staging_downloadserver%
del ..\09_temporary\_staging_files.txt
GOTO CLEAN_EXIT_SUBSCRIPT

:ERROR_EXIT_SUBSCRIPT
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT_SUBSCRIPT   
timeout /T 5
