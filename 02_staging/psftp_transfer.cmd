:: Name:     psftp_transfer.cmd
:: Purpose:  Transfer files to downloadserver using psftp
:: Author:   pierre@pvln.nl
::

:: Put it on download server
:: =========================
::
:: remove any existing ..\09_temporary\_ftp_files.txt file
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

:: run the actual PSFTP commandfile
%staging_command% -b ..\09_temporary\_staging_files.txt -be -l %staging_user_downloadserver% -pw %staging_pw_downloadserver% %staging_downloadserver%
del ..\09_temporary\_staging_files.txt
