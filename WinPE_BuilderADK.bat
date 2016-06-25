:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::\ \    / (_)_ _ | _ \ __| | _ )_  _(_) |__| |___ _ _    /_\ |   \| |/ /::
:: \ \/\/ /| | ' \|  _/ _|  | _ \ || | | / _` / -_) '_|  / _ \| |) | ' < ::
::  \_/\_/ |_|_||_|_| |___| |___/\_,_|_|_\__,_\___|_|   /_/ \_\___/|_|\_\::
::HarveyTDixon2016:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CONFIGADK
cls
@echo off
ENDLOCAL
SET CURDIR=%~dp0\
title WinPE_BuilderADK
SETLOCAL ENABLEDELAYEDEXPANSION
IF NOT EXIST "%CURDIR%\WinPE_Temp" md "%CURDIR%\WinPE_Temp"
::-----------------------------------------------------------------------
"%WINDIR%\system32\cacls.exe" "%WINDIR%\system32\config\system" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (echo Elevating... & GOTO UAC1) else (GOTO UAC2)
:UAC1
echo SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\uac.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%TEMP%\uac.vbs"
"%TEMP%\uac.vbs"
del /q /f "%TEMP%\uac.vbs" & exit /b
:UAC2
IF EXIST "%TEMP%\uac.vbs" (del /q /f "%TEMP%\uac.vbs")
pushd %CD% & CD /d %CURDIR%
::-----------------------------------------------------------------------
IF NOT EXIST "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools" ^
echo. & echo Windows 10 ADK does not exist. & echo. & pause & GOTO EOF
IF NOT EXIST "%CURDIR%\WinPE_ADK10-DRIVERS" md "%CURDIR%\WinPE_ADK10-DRIVERS"
IF NOT EXIST "%CURDIR%\WinPE_ADK10-FILES" md "%CURDIR%\WinPE_ADK10-FILES"
IF NOT EXIST "%CURDIR%\WinPE_ADK10-REG" md "%CURDIR%\WinPE_ADK10-REG"
IF EXIST "%CURDIR%\WinPE_Temp\DELISOADK.txt" del /q /f "%CURDIR%\WinPE_Temp\DELISOADK.txt"
IF EXIST "%CURDIR%\WinPE_Temp\LISTVOLADK.txt" del /q /f "%CURDIR%\WinPE_Temp\LISTVOLADK.txt"
IF EXIST "%CURDIR%\WinPE_Temp\RegAddDirADK.txt" del /q /f "%CURDIR%\WinPE_Temp\RegAddDirADK.txt"
::-----------------------------------------------------------------------
:DandISetEnv
IF /I %PROCESSOR_ARCHITECTURE%==x86 (
IF NOT "%PROCESSOR_ARCHITEW6432%"=="" (
SET PROCESSOR_ARCHITECTURE=%PROCESSOR_ARCHITEW6432%
)
) ELSE IF /I NOT %PROCESSOR_ARCHITECTURE%==amd64 (
echo Not implemented for PROCESSOR_ARCHITECTURE of %PROCESSOR_ARCHITECTURE%.
echo Using "%ProgramFiles%"
SET NewPath="%ProgramFiles%"
GOTO SETPATH
)
SET regKeyPathFound=1
SET wowRegKeyPathFound=1
SET KitsRootRegValueName=KitsRoot10
REG QUERY "HKLM\Software\Wow6432Node\Microsoft\Windows Kits\Installed Roots" /v %KitsRootRegValueName% 1>NUL 2>NUL || SET wowRegKeyPathFound=0
REG QUERY "HKLM\Software\Microsoft\Windows Kits\Installed Roots" /v %KitsRootRegValueName% 1>NUL 2>NUL || SET regKeyPathFound=0
IF %wowRegKeyPathFound% EQU 0 (
IF %regKeyPathFound% EQU 0 (
echo KitsRoot not found, can't set common path for Deployment Tools
GOTO :EOF
) else (
SET regKeyPath=HKLM\Software\Microsoft\Windows Kits\Installed Roots
)
) else (
SET regKeyPath=HKLM\Software\Wow6432Node\Microsoft\Windows Kits\Installed Roots
)
FOR /F "skip=2 tokens=2*" %%i IN ('REG QUERY "%regKeyPath%" /v %KitsRootRegValueName%') DO (SET KitsRoot=%%j)
SET DandIRoot=%KitsRoot%Assessment and Deployment Kit\Deployment Tools
SET WinPERoot=%KitsRoot%Assessment and Deployment Kit\Windows Preinstallation Environment
SET DISMRoot=%DandIRoot%\%PROCESSOR_ARCHITECTURE%\DISM
SET BCDBootRoot=%DandIRoot%\%PROCESSOR_ARCHITECTURE%\BCDBoot
SET ImagingRoot=%DandIRoot%\%PROCESSOR_ARCHITECTURE%\Imaging
SET OSCDImgRoot=%DandIRoot%\%PROCESSOR_ARCHITECTURE%\Oscdimg
SET WdsmcastRoot=%DandIRoot%\%PROCESSOR_ARCHITECTURE%\Wdsmcast
SET HelpIndexerRoot=%DandIRoot%\HelpIndexer
SET WSIMRoot=%DandIRoot%\WSIM
SET ICDRoot=%KitsRoot%Assessment and Deployment Kit\Imaging and Configuration Designer\x86
SET NewPath=%DISMRoot%;%ImagingRoot%;%BCDBootRoot%;%OSCDImgRoot%;%WdsmcastRoot%;%HelpIndexerRoot%;%WSIMRoot%;%WinPERoot%;%ICDRoot%
:SETPATH
SET PATH=%NewPath:"=%;%PATH%
cd /d "%DandIRoot%"
::-------------------------------------------------------------------------------
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³WinPE Builder ADK³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo ----------------------------
IF EXIST "C:\WinPE_amd64" (
SET WRKDIRSTAT=1 & echo ^(x^) Working directory exists
) else (
SET WRKDIRSTAT=0 & echo ^( ^) Working directory exists
)
IF EXIST "C:\WinPE_amd64\mount\windows" (
SET MOUNTSTAT=1 & echo ^(x^) Image is Mounted
) else (
SET MOUNTSTAT=0 & echo ^( ^) Image is Mounted
)
REG QUERY "HKLM\WinPE-ADK_HKCU" 2>nul >nul
IF %ERRORLEVEL%==0 (
SET REGSTAT1=1 & echo ^(x^) REG hive loaded "HKLM\WinPE-ADK_HKCU"
) else (
SET REGSTAT1=0
)
REG QUERY HKLM\WinPE-ADK_HKLM_SOFTWARE 2>nul >nul
IF %ERRORLEVEL%==0 (
SET REGSTAT2=1 & echo ^(x^) REG hive loaded "HKLM\WinPE-ADK_HKLM_SOFTWARE"
) else (
SET REGSTAT2=0
)
REG QUERY HKLM\WinPE-ADK_HKLM_SYSTEM 2>nul >nul
IF %ERRORLEVEL%==0 (
SET REGSTAT3=1 & echo ^(x^) REG hive loaded "HKLM\WinPE-ADK_HKLM_SYSTEM"
) else (
SET REGSTAT3=0
)
IF %REGSTAT1%==0 IF %REGSTAT2%==0 IF %REGSTAT3%==0 (
SET REGSTAT0=1 & echo ^( ^) REG hives loaded & GOTO ISOCHECKADK
) else (
SET REGSTAT0=0
)

:ISOCHECKADK
IF EXIST "C:\WinPE_amd64\WinPE_amd64.iso" (
echo ^(x^) ISO file exists
) else (
echo ^( ^) ISO file exists
)
echo ----------------------------
echo ----------------------------
echo [W] Create Working directory
echo [M] Mount/Unmount image
echo [F] Add FILES to image
echo [R] Load REG hives
echo [D] Add DRIVERS
echo [B] Batch mode
echo [I] Make ISO
echo [U] Make USB
echo [X] Exit
echo ----------------------------
echo.
choice /c WMFRDBIUX /N /M ">"
echo.
IF ERRORLEVEL 9 GOTO EOF
IF ERRORLEVEL 8 GOTO MAKEUSBADK1
IF ERRORLEVEL 7 GOTO MAKEISOADK1
IF ERRORLEVEL 6 GOTO BATCHMODEADK
IF ERRORLEVEL 5 GOTO ADDDRIVERSADK
IF ERRORLEVEL 4 GOTO LOADREGISTRYADK
IF ERRORLEVEL 3 GOTO ADDFILESADK
IF ERRORLEVEL 2 GOTO MOUNTUNMOUNTIMAGEADK
IF ERRORLEVEL 1 GOTO CREATEDIRECTORYADK1

:::::::::::::::::::::::::::::::::::::::
::|  \/  |__ _| |_____| | | / __| _ )::
::| |\/| / _` | / / -_) |_| \__ \ _ \::
::|_|  |_\__,_|_\_\___|\___/|___/___/::
:::::::::::::::::::::::::::::::::::::::
:MAKEUSBADK1
title WinPE_BuilderADK [Make USB]
IF NOT %WRKDIRSTAT%==1 echo WinPE working directory does not exist. & echo. & pause & GOTO CONFIGADK
IF %MOUNTSTAT%==1 echo Cannot make USB, image is currently Mounted. & echo. & pause & GOTO CONFIGADK
IF NOT %REGSTAT0%==1 echo Cannot make USB, REG hives are still loaded. & echo. & pause & GOTO CONFIGADK
cls
@echo off
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³WinPE Builder ADK³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo [Make USB]
echo.
IF NOT EXIST %CURDIR%\WinPE_Temp\LISTVOLADK.txt (
echo list vol
) > %CURDIR%\WinPE_Temp\LISTVOLADK.txt
for /F "delims=" %%D in ('diskpart /s %CURDIR%\WinPE_Temp\LISTVOLADK.txt ^| ^
 findstr /i /v /c:"microsoft" /c:"copyright" /c:"on computer"')  do echo(%%D
echo   ----------  ---  -----------  -----  ----------  -------  ---------  --------

:SELVOLNUMADK
echo.
SET "VNCHOICEADK=0123456789"
choice /c %VNCHOICEADK% /n /m "Select volume number [0-9]:"
SET /a "n=%ERRORLEVEL%-1"
SET "VOLNUMADK=!VNCHOICEADK:~%n%,1!"

:SELVOLLETADK
echo.
SET "VLCHOICEADK=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
choice /c %VLCHOICEADK% /n /m "Select volume letter [A-Z]:"
SET /a "n=%ERRORLEVEL%-1"
SET "VOLLETADK=!VLCHOICEADK:~%n%,1!"

:CONFIRMVOLUME
echo.
echo   Volume ###  Ltr
echo   ----------  ---
diskpart /s %CURDIR%\WinPE_Temp\LISTVOLADK.txt | findstr /i /c:"Volume %VOLNUMADK%     %VOLLETADK%"
IF %ERRORLEVEL% NEQ 0 ( 
echo   Volume %VOLNUMADK%     %VOLLETADK%
echo.
echo ^> ERROR^^! Selections do not match. & echo. & pause & GOTO CONFIGADK
)
echo.
for /f "tokens=2 delims==" %%S in ('wmic volume where "driveletter='%VOLLETADK%:'" ^
get capacity /value ^| find "=" ') do set "VOLSIZEADK=%%S"

for /f "tokens=2 delims==" %%T in ('wmic logicaldisk where "deviceid='%VOLLETADK%:'" ^
get description /value ^| find "=" ') do set "VOLTYPEADK=%%T"

SET "MAXSIZEADK=34359738368"
CALL :ADDZEROSADK VOLSIZEADK
CALL :ADDZEROSADK MAXSIZEADK

IF "%VOLTYPEADK%" EQU "CD-ROM Disc" echo ^> ERROR^^! Invalid volume - optical drive. & echo. & pause & GOTO CONFIGADK
IF 0%VOLSIZEADK% EQU 0 echo ^> ERROR^^! Invalid volume - no free space. & echo. & pause & GOTO CONFIGADK
IF 0%VOLSIZEADK% GTR %MAXSIZEADK% echo ^> ERROR^^! Volume size cannot exceed 32 GB. & echo. & pause & GOTO CONFIGADK

choice /c YN /N /M "Proceed with format? <Y/N>"
IF ERRORLEVEL 2 GOTO CONFIGADK
IF ERRORLEVEL 1 GOTO MAKEUSBADK2

:MAKEUSBADK2
echo.
call Makewinpemedia /ufd /f C:\WinPE_amd64 %VOLLETADK%:
echo.
pause
GOTO CONFIGADK

:ADDZEROSADK
SET "n=000000000000000!%~1!"
SET "n=!n:~-15!"
SET "%~1=%n%"
GOTO EOF

:::::::::::::::::::::::::::::::::::::::
::|  \/  |__ _| |_____|_ _/ __|/ _ \ ::
::| |\/| / _` | / / -_)| |\__ \ (_) |::
::|_|  |_\__,_|_\_\___|___|___/\___/ ::
:::::::::::::::::::::::::::::::::::::::
:MAKEISOADK1
title WinPE_BuilderADK [Make ISO]
IF NOT %WRKDIRSTAT%==1 echo WinPE working directory does not exist. & echo. & pause & GOTO CONFIGADK
IF %MOUNTSTAT%==1 echo Cannot make ISO, image is currently Mounted. & echo. & pause & GOTO CONFIGADK
IF NOT %REGSTAT0%==1 echo Cannot make ISO, REG hives are still loaded. & echo. & pause & GOTO CONFIGADK
IF EXIST "C:\WinPE_amd64\WinPE_amd64.iso" GOTO DELETEISOADK
GOTO MAKEISOADK2

:DELETEISOADK
choice /c YN /N /M "ISO already exists, overwrite file? <Y/N>"
echo.
IF ERRORLEVEL 2 GOTO CONFIGADK
IF ERRORLEVEL 1 GOTO MAKEISOADK2

:MAKEISOADK2
IF EXIST "C:\WinPE_amd64\WinPE_amd64.iso" del /q /f "C:\WinPE_amd64\WinPE_amd64.iso" > nul 2> %CURDIR%\WinPE_Temp\DELISOADK.txt
findstr /i /c:"process cannot access the file" %CURDIR%\WinPE_Temp\DELISOADK.txt > nul 2> nul (
IF %ERRORLEVEL%==0 echo Can't overwrite file, ISO is in use by another process. & echo. & pause & GOTO CONFIGADK
)
echo Making ISO...
echo -------------
IF EXIST "C:\WinPE_amd64\WinPE_amd64.iso" del /f /q "C:\WinPE_amd64\WinPE_amd64.iso" 
call MakeWinPEMedia /iso /f C:\WinPE_amd64 C:\WinPE_amd64\WinPE_amd64.iso
echo.
pause
GOTO CONFIGADK

::::::::::::::::::::::::::::::::::::::::::::::::
::| _ ) __ _| |_ __| |_ |  \/  |___  __| |___ ::
::| _ \/ _` |  _/ _| ' \| |\/| / _ \/ _` / -_)::
::|___/\__,_|\__\__|_||_|_|  |_\___/\__,_\___|::
::::::::::::::::::::::::::::::::::::::::::::::::
:BATCHMODEADK
title WinPE_BuilderADK [Batch Mode]
IF NOT EXIST "C:\WinPE_amd64" GOTO BMCONFIRMADK
echo Existing image will be deleted...

:BMCONFIRMADK
echo.
choice /c YN /N /M "Proceed with batch mode? <Y/N>"
echo.
IF ERRORLEVEL 2 GOTO CONFIGADK
IF ERRORLEVEL 1 GOTO BMUNLOADREGADK

:BMUNLOADREGADK
IF NOT %REGSTAT0%==1 (
echo.
echo Unloading WinPE REG hives...
echo ----------------------------
echo ^> Unloading {HKLM\WinPE-ADK_HKCU}
reg unload HKLM\WinPE-ADK_HKCU
echo.
echo ^> Unloading {HKLM\WinPE-ADK_HKLM_SOFTWARE}
reg unload HKLM\WinPE-ADK_HKLM_SOFTWARE
echo.
echo ^> Unloading {HKLM\WinPE-ADK_HKLM_SYSTEM}
reg unload HKLM\WinPE-ADK_HKLM_SYSTEM
echo.
) else (
echo.
)

:BMCREATEDIRECTORYADK
IF EXIST "C:\WinPE_amd64\WinPE_amd64.iso" del /q /f "C:\WinPE_amd64\WinPE_amd64.iso" > nul 2> %CURDIR%\WinPE_Temp\DELISOADK.txt
findstr /i /c:"process cannot access the file" %CURDIR%\WinPE_Temp\DELISOADK.txt > nul 2> nul (
IF %ERRORLEVEL%==0 echo Can't overwrite files, ISO is in use by another process. & echo. & pause & GOTO CONFIGADK
)
IF %MOUNTSTAT%==1 (
Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /discard
)
IF EXIST "C:\WinPE_amd64" rd /s /q "C:\WinPE_amd64"
call copype.cmd amd64 C:\WinPE_amd64

:BMMOUNTIMAGEADK
echo.
echo Mounting image...
echo -----------------
Dism /Mount-Image /ImageFile:"C:\WinPE_amd64\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE_amd64\mount"

:BMADDFILESADK
takeown /f "C:\WinPE_amd64\mount\Windows\System32\winpe.jpg" >nul
IF NOT %ERRORLEVEL%==0 echo Failed to take ownership of "winpe.jpg" & echo.
icacls "C:\WinPE_amd64\mount\Windows\System32\winpe.jpg" /grant:r %USERNAME%:(F) >nul
IF NOT %ERRORLEVEL%==0 echo Failed to apply permissions to "winpe.jpg" & echo.

:COPYWINPEADDADK
echo Adding files to \mount\Windows\System32
echo ---------------------------------------
xcopy "%CURDIR%\WinPE_ADK10-FILES\*.*" "C:\WinPE_amd64\mount\Windows\System32" /e /y
echo.

:BMLOADHIVESADK
echo.
echo Loading WinPE REG hives...
echo --------------------------
echo ^> Loading {HKLM\WinPE-ADK_HKCU}
reg load HKLM\WinPE-ADK_HKCU C:\WinPE_amd64\mount\Windows\System32\config\DEFAULT
echo.
echo ^> Loading {HKLM\WinPE-ADK_HKLM_SOFTWARE}
reg load HKLM\WinPE-ADK_HKLM_SOFTWARE C:\WinPE_amd64\mount\Windows\System32\config\SOFTWARE
echo.
echo ^> Loading {HKLM\WinPE-ADK_HKLM_SYSTEM}
reg load HKLM\WinPE-ADK_HKLM_SYSTEM C:\WinPE_amd64\mount\Windows\System32\config\SYSTEM
echo.
echo.

:BMIMPORTREGADK
echo Importing WinPE REG keys...
echo ---------------------------
dir /b "%CURDIR%\WinPE_ADK10-REG" > %CURDIR%\WinPE_Temp\RegAddDirADK.txt
SET COUNTER=0
for /F "tokens=*" %%A in (%CURDIR%\WinPE_Temp\RegAddDirADK.txt) do (
SET /A COUNTER=!COUNTER! + 1
SET !COUNTER!=%%A
echo ^> Importing {%%A}
REG IMPORT "%CURDIR%\WinPE_ADK10-REG\%%A"
)
echo.
echo.

:BMUNLOADHIVESADK
echo Unloading WinPE REG hives...
echo ----------------------------
echo ^> Unloading {HKLM\WinPE-ADK_HKCU}
reg unload HKLM\WinPE-ADK_HKCU
echo.
echo ^> Unloading {HKLM\WinPE-ADK_HKLM_SOFTWARE}
reg unload HKLM\WinPE-ADK_HKLM_SOFTWARE
echo.
echo ^> Unloading {HKLM\WinPE-ADK_HKLM_SYSTEM}
reg unload HKLM\WinPE-ADK_HKLM_SYSTEM
echo.
echo.

:BMADDDRIVERSADK
echo Adding drivers to image...
echo --------------------------
Dism.exe /image:C:\WinPE_amd64\mount /Add-Driver /Driver:"%CURDIR%\WinPE_ADK10-DRIVERS" /Recurse /ForceUnsigned
echo.
echo.

:BMUNMOUNTCOMMITIMAGEADK
echo Saving and Unmounting image...
echo ------------------------------
Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /commit
IF %ERRORLEVEL%==-1052638953 (
echo.
echo ^> Mount status is in an error state.
echo.
echo ^> CLOSE ALL EXPLORER WINDOWS, then...
GOTO BMCLEANUPZ
) else (
GOTO ENDBATCHMODEADK
)
:BMCLEANUPZ
echo ^> Attempting mount cleanup...
Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /discard
IF NOT %ERRORLEVEL%==0 echo. & echo ^> Mount status is in an ERROR state... & GOTO ENDMOUNTUNMOUNTIMAGEADK
Dism /Cleanup-Mountpoints

:ENDBATCHMODEADK
echo.
echo.
echo ^> Ready to make ISO or USB^^!
echo.
echo.
pause
GOTO CONFIGADK

:::::::::::::::::::::::::::::::::::::::::::::::
::  /_\  __| |__| |   \ _ _(_)_ _____ _ _ ___::
:: / _ \/ _` / _` | |) | '_| \ V / -_) '_(_-<::
::/_/ \_\__,_\__,_|___/|_| |_|\_/\___|_| /__/::
:::::::::::::::::::::::::::::::::::::::::::::::
:ADDDRIVERSADK
title WinPE_BuilderADK [Mount/Unmount image]
IF NOT %WRKDIRSTAT%==1 echo WinPE working directory does not exist. & echo. & pause & GOTO CONFIGADK
IF %MOUNTSTAT%==0 echo Cannot add drivers, image is NOT Mounted. & echo. & pause & GOTO CONFIGADK

echo Adding drivers to image...
echo --------------------------
Dism.exe /image:C:\WinPE_amd64\mount /Add-Driver /Driver:"%CURDIR%\WinPE_ADK10-DRIVERS" /Recurse /ForceUnsigned
echo.
pause
GOTO CONFIGADK

::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::| |   ___  __ _ __| | _ \___ __ _(_)__| |_ _ _ _  _ ::
::| |__/ _ \/ _` / _` |   / -_) _` | (_-<  _| '_| || |::
::|____\___/\__,_\__,_|_|_\___\__, |_/__/\__|_|  \_, |::
::::::::::::::::::::::::::::::|___/::::::::::::::|__/:::
:LOADREGISTRYADK
title WinPE_Builder ADK [Load Registry]
IF NOT %WRKDIRSTAT%==1 echo WinPE working directory does not exist. & echo. & pause & GOTO CONFIGADK
IF NOT %REGSTAT0%==1 GOTO LOADHIVESADK1
IF %MOUNTSTAT%==0 echo Can't load REG hives, image is not mounted. & echo. & pause & GOTO CONFIGADK

:LOADHIVESADK1
cls
@echo off
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³WinPE Builder ADK³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF NOT %REGSTAT0%==1 echo. & echo REG hives already loaded... & GOTO UNLOADHIVESADK1
echo.
echo Loading WinPE REG hives...
echo --------------------------
echo ^> Loading {HKLM\WinPE-ADK_HKCU}
reg load HKLM\WinPE-ADK_HKCU C:\WinPE_amd64\mount\Windows\System32\config\DEFAULT
echo.
echo ^> Loading {HKLM\WinPE-ADK_HKLM_SOFTWARE}
reg load HKLM\WinPE-ADK_HKLM_SOFTWARE C:\WinPE_amd64\mount\Windows\System32\config\SOFTWARE
echo.
echo ^> Loading {HKLM\WinPE-ADK_HKLM_SYSTEM}
reg load HKLM\WinPE-ADK_HKLM_SYSTEM C:\WinPE_amd64\mount\Windows\System32\config\SYSTEM
echo.

:UNLOADHIVESADK1
echo --------------------
echo [I] Import reg files
echo [U] Unload reg hives
echo [X] Cancel
echo --------------------
echo.
choice /c IUX /N /M ">"
echo.
IF ERRORLEVEL 3 GOTO CONFIGADK
IF ERRORLEVEL 2 GOTO UNLOADHIVESADK2
IF ERRORLEVEL 1 GOTO IMPORTREGADK

:UNLOADHIVESADK2
echo Unloading WinPE REG hives...
echo ----------------------------
echo ^> Unloading {HKLM\WinPE-ADK_HKCU}
reg unload HKLM\WinPE-ADK_HKCU
echo.
echo ^> Unloading {HKLM\WinPE-ADK_HKLM_SOFTWARE}
reg unload HKLM\WinPE-ADK_HKLM_SOFTWARE
echo.
echo ^> Unloading {HKLM\WinPE-ADK_HKLM_SYSTEM}
reg unload HKLM\WinPE-ADK_HKLM_SYSTEM
echo.
pause
GOTO CONFIGADK

:IMPORTREGADK
dir /b "%CURDIR%\WinPE_ADK10-REG" > %CURDIR%\WinPE_Temp\RegAddDirADK.txt
SET COUNTER=0
for /F "tokens=*" %%A in (%CURDIR%\WinPE_Temp\RegAddDirADK.txt) do (
SET /A COUNTER=!COUNTER! + 1
SET !COUNTER!=%%A
echo ^> Importing {%%A}
REG IMPORT "%CURDIR%\WinPE_ADK10-REG\%%A"
echo.
)
GOTO UNLOADHIVESADK1

::::::::::::::::::::::::::::::::::::
::  /_\  __| |__| | __(_) |___ ___::
:: / _ \/ _` / _` | _|| | / -_|_-<::
::/_/ \_\__,_\__,_|_| |_|_\___/__/::
::::::::::::::::::::::::::::::::::::
:ADDFILESADK
title WinPE_BuilderADK [Add Files]
IF NOT %WRKDIRSTAT%==1 echo WinPE working directory does not exist. & echo. & pause & GOTO CONFIGADK
IF NOT %MOUNTSTAT%==1 echo Can't add files, image is not mounted. & echo. & pause & GOTO CONFIGADK

takeown /f "C:\WinPE_amd64\mount\Windows\System32\winpe.jpg" >nul
IF NOT %ERRORLEVEL%==0 echo Failed to take ownership of "winpe.jpg" & echo.
icacls "C:\WinPE_amd64\mount\Windows\System32\winpe.jpg" /grant:r %USERNAME%:(F) >nul
IF NOT %ERRORLEVEL%==0 echo Failed to apply permissions to "winpe.jpg" & echo.

:COPYWINPEADDADK
echo Adding files to \mount\Windows\System32
echo ---------------------------------------
xcopy "%CURDIR%\WinPE_ADK10-FILES\*.*" "C:\WinPE_amd64\mount\Windows\System32" /e /y
echo.
pause
GOTO CONFIGADK

:::::::::::::::::::::::::::::::::::::::::::::::::::::
::|  \/  |___ _  _ _ _| |_|_ _|_ __  __ _ __ _ ___ ::
::| |\/| / _ \ || | ' \  _|| || '  \/ _` / _` / -_)::
::|_|  |_\___/\_,_|_||_\__|___|_|_|_\__,_\__, \___|::
::::::::::::::::::::::::::::::::::::::::::|___/::::::
:MOUNTUNMOUNTIMAGEADK
title WinPE_BuilderADK [Mount/Unmount image]
IF NOT %WRKDIRSTAT%==1 echo WinPE working directory does not exist. & echo. & pause & GOTO CONFIGADK
IF NOT %REGSTAT0%==1 echo Cannot unmount image, REG hives are still loaded. & echo. & pause & GOTO CONFIGADK
IF %MOUNTSTAT%==1 GOTO CONFIRMUNMOUNTADK

:CONFIRMMOUNTADK
choice /c YN /N /M "Image is UNMOUNTED. Do you want to MOUNT it? <Y/N>"
IF ERRORLEVEL 2 GOTO CONFIGADK
IF ERRORLEVEL 1 GOTO MOUNTIMAGEADK

:MOUNTIMAGEADK
Dism /Mount-Image /ImageFile:"C:\WinPE_amd64\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE_amd64\mount"
IF %ERRORLEVEL%==-1052638937 (
echo.
echo ^> Mount status is in an error state.
echo.
echo ^> CLOSE ALL EXPLORER WINDOWS, then...
GOTO CLEANUPY
) else (
GOTO ENDMOUNTUNMOUNTIMAGEADK
)
:CLEANUPY
echo.
pause
echo.
echo ^> Attempting mount cleanup...
Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /discard
IF NOT %ERRORLEVEL%==0 echo. & echo ^> Mount status is in an ERROR state... & GOTO ENDMOUNTUNMOUNTIMAGEADK
Dism /Cleanup-Mountpoints
echo.
pause
GOTO CONFIGADK

:CONFIRMUNMOUNTADK
choice /c YN /N /M "Image is MOUNTED. Do you want to save and UNMOUNT it? <Y/N>"
IF ERRORLEVEL 2 GOTO CONFIGADK
IF ERRORLEVEL 1 GOTO UNMOUNTCOMMITIMAGEADK

:UNMOUNTCOMMITIMAGEADK
Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /commit
IF %ERRORLEVEL%==-1052638953 (
echo.
echo ^> Mount status is in an error state.
echo.
echo ^> CLOSE ALL EXPLORER WINDOWS, then...
GOTO CLEANUPZ
) else (
GOTO ENDMOUNTUNMOUNTIMAGEADK
)
:CLEANUPZ
echo.
pause
echo.
echo ^> Attempting mount cleanup...
Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /discard
IF NOT %ERRORLEVEL%==0 echo. & echo ^> Mount status is in an ERROR state... & GOTO ENDMOUNTUNMOUNTIMAGEADK
Dism /Cleanup-Mountpoints

:ENDMOUNTUNMOUNTIMAGEADK
echo.
pause
GOTO CONFIGADK

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::\ \    / /__ _ _| |_(_)_ _  __ _|   \(_)_ _ ___ __| |_ ___ _ _ _  _ ::
:: \ \/\/ / _ \ '_| / / | ' \/ _` | |) | | '_/ -_) _|  _/ _ \ '_| || |::
::  \_/\_/\___/_| |_\_\_|_||_\__, |___/|_|_| \___\__|\__\___/_|  \_, |::
:::::::::::::::::::::::::::::|___/:::::::::::::::::::::::::::::::|__/:::
:CREATEDIRECTORYADK1
title WinPE_BuilderADK [Create working directory]
IF NOT %REGSTAT0%==1 echo Cannot create working directory, REG hives are still loaded. & echo. & pause & GOTO CONFIGADK
IF %WRKDIRSTAT%==1 GOTO DELETEDIRECTORYADK
GOTO CREATEDIRECTORYADK2

:DELETEDIRECTORYADK
choice /c YN /N /M "Working directory already exists, overwrite files? <Y/N>"
echo.
IF ERRORLEVEL 2 GOTO CONFIGADK
IF ERRORLEVEL 1 GOTO CREATEDIRECTORYADK2

:CREATEDIRECTORYADK2
IF EXIST "C:\WinPE_amd64\WinPE_amd64.iso" del /q /f "C:\WinPE_amd64\WinPE_amd64.iso" > nul 2> %CURDIR%\WinPE_Temp\DELISOADK.txt
findstr /i /c:"process cannot access the file" %CURDIR%\WinPE_Temp\DELISOADK.txt > nul 2> nul (
IF %ERRORLEVEL%==0 echo Can't overwrite files, ISO is in use by another process. & echo. & pause & GOTO CONFIGADK
)
IF %MOUNTSTAT%==1 (
Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /discard
)
IF EXIST "C:\WinPE_amd64" rd /s /q "C:\WinPE_amd64"
call copype.cmd amd64 C:\WinPE_amd64
echo.
pause
GOTO CONFIGADK

:EOF
