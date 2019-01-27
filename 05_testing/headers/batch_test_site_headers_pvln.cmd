:: Name:     batch_test_site_headers_pvln.cmd
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
