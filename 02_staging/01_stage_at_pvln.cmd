:: Name:     01_stage_at_pvln.cmd
:: Purpose:  set enviroment and run deploy script 
:: Author:   pierre.veelen@pvln.nl
:: Revision: 2019 02 11 - initial version
::

@ECHO off

:: Setting required environment variables:
::
SET extension_name=htaccess
:: Where to put the files on the staging/download server
SET staging_folder=/download/joomla/baselines/htaccess/
:: Where to find the secrets
SET secrets_folder=..\..\..\_secrets

:: -OUTPUT DIRECTORY FOR BUILD = INPUT DIRECTORY FOR STAGING
:: do not start with \ , and do not end with \
SET output_dir=..\06_output\staging

CALL 05_stage_files.cmd
