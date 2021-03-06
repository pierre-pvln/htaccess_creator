:: Name:     _create_test_scripts.cmd
:: Purpose:  Create the testing script files for the various domains
:: Author:   pierre@pvln.nl
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: BASIC SETTINGS
:: ==============
:: Setting the name of the script
SET me=%~n0
:: Setting the name of the directory with this script
SET parent=%~p0
:: Setting the drive of this commandfile
SET drive=%~d0
:: Setting the directory and drive of this commandfile
SET cmd_dir=%~dp0

:: Retrieving build version parameters for default settings
::
IF NOT EXIST ".\settings\domains.txt" (
   SET ERROR_MESSAGE=[ERROR] File .\settings\domains.txt with domain parameters doesn't exist
   GOTO ERROR_EXIT
)
:: Read parameters file
:: Inspiration: http://www.robvanderwoude.com/battech_inputvalidation_commandline.php#ParameterFiles
::              https://ss64.com/nt/for_f.html
::
:: Remove comment lines
TYPE ".\settings\domains.txt" | FINDSTR /v # >".\settings\domains_clean.txt"
:: Check parameter file for unwanted characters
FINDSTR /R "( ) & ' ` \"" ".\settings\domains_clean.txt" > NUL
IF NOT ERRORLEVEL 1 (
    SET ERROR_MESSAGE=[ERROR] The parameter file contains unwanted characters, and cannot be parsed.
    GOTO ERROR_EXIT
)

:: Only parse the file if no unwanted characters were found
::
:: Create individual test script files
::
FOR /F "tokens=1,2 delims==" %%A IN ('FINDSTR /R /X /C:"[^=][^=]*=.*" ".\settings\domains_clean.txt" ') DO (
    FOR /F %%G IN ('DIR /b /A:D .\tests') DO (
        ECHO [INFO ] Creating .\tests\%%G\%%A.cmd ...
        ECHO :: Name:     %%A.cmd >.\tests\%%G\%%A.cmd
        ECHO :: Purpose:  Set required environment and run test script >>.\tests\%%G\%%A.cmd
        ECHO :: Author:   Generated by script create_test_scripts.cmd >>.\tests\%%G\%%A.cmd
        ECHO :: >>.\tests\%%G\%%A.cmd
        ECHO @ECHO off >>.\tests\%%G\%%A.cmd
        ECHO SETLOCAL ENABLEEXTENSIONS >>.\tests\%%G\%%A.cmd
        ECHO :: >>.\tests\%%G\%%A.cmd
        ECHO :: Setting required environment variables: >>.\tests\%%G\%%A.cmd
        ECHO :: >>.\tests\%%G\%%A.cmd
        ECHO SET site_name_base=%%B >>.\tests\%%G\%%A.cmd
        ECHO ECHO %%B >>.\tests\%%G\%%A.cmd
        ECHO CALL test_%%G.cmd >>.\tests\%%G\%%A.cmd
        ECHO. >>.\tests\%%G\%%A.cmd
    )
)
::
:: Create batch script files
::
FOR /F %%G IN ('DIR /b /A:D .\tests') DO (
    ECHO [INFO ] Creating .\tests\%%G\batch_test.cmd ...
    ECHO :: Name:     batch_test.cmd >.\tests\%%G\batch_test.cmd
    ECHO :: Purpose:  Set required environment and run test script >>.\tests\%%G\batch_test.cmd
    ECHO :: Author:   Generated by script create_test_scripts.cmd >>.\tests\%%G\batch_test.cmd
    ECHO :: >>.\tests\%%G\batch_test.cmd
    ECHO @ECHO off >>.\tests\%%G\batch_test.cmd
    ECHO SETLOCAL ENABLEEXTENSIONS >>.\tests\%%G\batch_test.cmd
    ECHO :: >>.\tests\%%G\batch_test.cmd
    ECHO :: Setting required environment variables: >>.\tests\%%G\batch_test.cmd
    FOR /F "tokens=1,2 delims==" %%A IN ('FINDSTR /R /X /C:"[^=][^=]*=.*" ".\settings\domains_clean.txt" ') DO (
        ECHO :: >>.\tests\%%G\batch_test.cmd
        ECHO SET site_name_base=%%B >>.\tests\%%G\batch_test.cmd
        ECHO ECHO %%B >>.\tests\%%G\batch_test.cmd
        ECHO CALL test_%%G.cmd >>.\tests\%%G\batch_test.cmd
    )
    ECHO :: >>.\tests\%%G\batch_test.cmd
)

DEL .\settings\domains_clean.txt

GOTO CLEAN_EXIT

:ERROR_EXIT
cd "%cmd_dir%" 
ECHO *******************
ECHO %ERROR_MESSAGE%
ECHO *******************

:CLEAN_EXIT   
timeout /T 10
