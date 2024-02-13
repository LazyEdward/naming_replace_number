@ECHO OFF
REM CHCP 65001

TITLE Rename to numbers

ECHO This program rename windows file in numbers align with linux/android file ordering.
ECHO Renamed content is saved in new sub directory 'Renamed'

ECHO -----------------------------------------------------------------------------------
ECHO:

SET dir="%~1"

SET /A offset=-1
SET /A count=0
SET /A digits=1

SET /A num=0

:START
IF %dir%=="" SET /p "dir=Press "Y" to exit, Enter directory to start replacing: "
IF %dir%==Y GOTO :END

CD /D %dir%

SET total=0
FOR /F %%f IN ('dir /a:-d-h-s ^| FIND "File(s)"') DO (
	IF %ERRORLEVEL% EQU 0 (
		SET /a total=%%f
	) ELSE (
		SET /a total=0
	)
)

IF %total% LEQ 0 (
	SET dir=""
	GOTO :START
)

ECHO %total% files found

IF %offset%==-1 SET /P "offset=Enter file start number: "

REM hide output with NUL
ECHO %offset% | FINDSTR /R "^[0-9][0-9]*" >NUL

IF %ERRORLEVEL% EQU 0 (
	SET /A offset+=0
) ELSE (
	ECHO Invalid number, using file start number 0
	SET /A offset=0
)

IF %count% EQU 0 (
	SET /A "num=%num%+%offset%"
	SET /A "count=%count%+%offset%"
)

ECHO:
ECHO making %dir:"=%\Renamed
ECHO:
MD Renamed

SET renamed_dir=%dir%
SET "renamed_dir=%renamed_dir%\Renamed"

REM add padding to avoid sorting issue with linux system
SET zero_prefix=0

SET /A "count=%count%+%total%"
SET /A ucount=%count%
SET /A digits=1

:COUNT_DIGITS
SET /A "ucount=%ucount%/10"

IF %ucount% GTR 0 (
	SET /a "digits=%digits%+1"
	SET "zero_prefix=%zero_prefix%0"
	GOTO :COUNT_DIGITS
)

IF %count% LEQ 0 GOTO :RENAME

:RENAME
REM With loop commands like FOR, compound or bracketed expressions, Delayed Expansion will allow you to always read the current value of the variable.
SETLOCAL enabledelayedexpansion

FOR /F "tokens=1-3 delims=." %%f IN ('dir /a:-d-h-s /b') DO (
	SET name=%%f
	SET name_or_ext=%%g
	SET ext=%%h

	SET new_name=!zero_prefix!!num!
	SET new_name=!new_name:~-%digits%!

	IF [%%h] == [] (
		ECHO renaming !name!.!name_or_ext! to !new_name!.!name_or_ext!

		COPY /y !dir!\!name!.!name_or_ext! !renamed_dir!\!new_name!.!name_or_ext! 1>NUL
	) ELSE (
		ECHO renaming !name!.!name_or_ext!.!ext! to !new_name!.!ext!

		COPY /y !dir!\!name!.!name_or_ext!.!ext! !renamed_dir!\!new_name!.!ext! 1>NUL
	)

	SET /a "num=!num!+1"
)

SETLOCAL disabledelayedexpansion

ECHO:
ECHO rename all %total% files 
ECHO:

SET dir=""
GOTO :START

:END