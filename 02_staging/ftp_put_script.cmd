:: Name:     ftp_put_script.cmd
:: Purpose:  Transfer files to staging/downloadserver using ftp
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
echo %staging_user_downloadserver%>>..\09_temporary\_staging_files.txt
echo %staging_pw_downloadserver%>>..\09_temporary\_staging_files.txt
:: switch to binary mode
echo binary>>..\09_temporary\_staging_files.txt
:: disable prompt; process the mput or mget without requiring any reply
echo prompt>>..\09_temporary\_staging_files.txt
:: copy files from top level folder
ECHO cd %staging_folder%>>..\09_temporary\_staging_files.txt
ECHO mput %output_dir%\*>>..\09_temporary\_staging_files.txt
:: copy files from all sub folders
FOR /f %%G in ('dir /b /A:D "%output_dir%"') DO (
	ECHO mkdir %%G>>..\09_temporary\_staging_files.txt
    ECHO cd %%G>>..\09_temporary\_staging_files.txt
	ECHO mput %output_dir%\%%G\*>>..\09_temporary\_staging_files.txt
	ECHO put %output_dir%\index.html>>..\09_temporary\_staging_files.txt
	ECHO cd ..>>..\09_temporary\_staging_files.txt
    )
ECHO bye>>..\09_temporary\_staging_files.txt

:: Run the script
"%staging_command%" -s:..\09_temporary\_staging_files.txt %staging_downloadserver%
del ..\09_temporary\_staging_files.txt
GOTO CLEAN_EXIT_SUBSCRIPT

:ERROR_EXIT_SUBSCRIPT
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT_SUBSCRIPT   
timeout /T 5
