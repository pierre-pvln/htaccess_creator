:: Name:     ftp_put_file.cmd
:: Purpose:  Transfer files to webserver using ftp
:: Author:   pierre@pvln.nl
::

:: Put it on webserver
:: ===================
::
:: remove any existing %secrets_folder%\_ftp_files.txt file
IF EXIST "%secrets_folder%\_ftp_files.txt" (del "%secrets_folder%\_ftp_files.txt")
::
:: Create %secrets_folder%\_ftp_files.txt
echo %deploy_user%>%secrets_folder%\_ftp_files.txt
echo %deploy_pw%>>%secrets_folder%\_ftp_files.txt
:: switch to binary mode
echo binary>>%secrets_folder%\_ftp_files.txt
:: disable prompt; process the mput or mget without requiring any reply
echo prompt>>%secrets_folder%\_ftp_files.txt
:: change the local directory so input comes from there
echo lcd %extension_folder%>>%secrets_folder%\_ftp_files.txt
echo cd %deploy_folder%>>%secrets_folder%\_ftp_files.txt
echo put .htaccess>>%secrets_folder%\_ftp_files.txt
echo bye>>%secrets_folder%\_ftp_files.txt

:: run the actual FTP commandfile
%ftp_deploy_command% -s:%secrets_folder%\_ftp_files.txt %deploy_server%
del %secrets_folder%\_ftp_files.txt
