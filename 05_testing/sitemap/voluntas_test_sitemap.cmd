:: Name:     voluntas_test_sitemap.cmd
:: Purpose:  set required environment variable and run test script 
:: Author:   pierre@pvln.nl
:: Revision: 2018 12 23 - initial version
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Setting required environment variables:
::
SET site_name_base=voluntas.nl
ECHO %site_name_base%
CALL test_sitemap.cmd
