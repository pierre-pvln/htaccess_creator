:: Name:     01_deploy_to_pvln.cmd
:: Purpose:  set enviroment and run deploy script 
:: Author:   pierre.veelen@pvln.nl
:: Revision: 2018 12 10 - initial version
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Required environment variables:
::
::
SET site_name=pvln
SET extension_name=htaccess
SET deploy_folder=/joomla01/
SET secrets_folder=..\..\..\_secrets

CALL 05_transfer_files_to_server.cmd
