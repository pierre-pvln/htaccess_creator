:: Name:     ftp_transfer.cmd
:: Purpose:  Transfer files to downloadserver using ftp
:: Author:   pierre@pvln.nl
::

:: Put it on download server
:: =========================
::
:: remove any existing ..\09_temporary\_ftp_files.txt file
IF EXIST "..\09_temporary\_staging_files.txt" (del "..\09_temporary\_staging_files.txt")
::
:: Create ..\09_temporary\_staging_files.txt
echo %staging_user_downloadserver%>>..\09_temporary\_staging_files.txt
echo %staging_pw_downloadserver%>>..\09_temporary\_staging_files.txt
:: switch to binary mode
echo binary>>..\09_temporary\_staging_files.txt
:: disable prompt; process the mput or mget without requiring any reply
echo prompt>>..\09_temporary\_staging_files.txt
:: copy files from top level folder
echo cd %staging_folder%>>..\09_temporary\_staging_files.txt
echo mput %output_dir%\*>>..\09_temporary\_staging_files.txt
:: copy files from all sub folders
FOR /f %%G in ('dir /b /A:D "%output_dir%"') DO (
	echo mkdir %%G>>..\09_temporary\_staging_files.txt
    echo cd %%G>>..\09_temporary\_staging_files.txt
	echo mput %output_dir%\%%G\*>>..\09_temporary\_staging_files.txt
	echo put %output_dir%\index.html>>..\09_temporary\_staging_files.txt
	echo cd ..>>..\09_temporary\_staging_files.txt
    )
echo bye>>..\09_temporary\_staging_files.txt

:: run the actual FTP commandfile
%staging_command% -s:..\09_temporary\_staging_files.txt %staging_downloadserver%
del ..\09_temporary\_staging_files.txt
