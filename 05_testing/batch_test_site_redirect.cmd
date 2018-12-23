:: Name:     batch_test_site_redirect.cmd
:: Purpose:  set required environment and run test script 
:: Author:   pierre@pvln.nl
:: Revision: 2018 12 23 - initial version
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Setting required environment variables:
::
SET site_name_base=pvln.nl
ECHO %site_name_base%
CALL test_site_redirect.cmd