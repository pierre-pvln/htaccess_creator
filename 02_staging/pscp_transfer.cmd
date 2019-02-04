:: Name:     pscp_transfer.cmd
:: Purpose:  Transfer files to downloadserver using sftp
:: Author:   pierre@pvln.nl
::

:: Put it on download server
:: =========================
::

%staging_command% -l %staging_user_downloadserver% -pw %staging_pw_downloadserver% -r %output_dir%\* %staging_downloadserver%:%staging_folder%
