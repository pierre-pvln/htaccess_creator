:: Name:     batch_test_site_headers.cmd
:: Purpose:  set required environment and run test script 
:: Author:   pierre@pvln.nl
:: Revision: 2019 01 27 - initial version
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Setting required environment variables:
::
SET site_name_base=pvln.nl
ECHO %site_name_base%
CALL test_site_headers.cmd

SET site_name_base=2connect4u.nl
ECHO %site_name_base%
CALL test_site_headers.cmd

SET site_name_base=ver-bind.nl
ECHO %site_name_base%
CALL test_site_headers.cmd

SET site_name_base=voluntas.nl
ECHO %site_name_base%
CALL test_site_headers.cmd
