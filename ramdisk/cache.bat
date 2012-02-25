
@echo off
:: ----------------------------------------------------------------------------------
:: USER SETTINGS [ set <name>=<variable>  ; Do not add spaces!! ]
:: ----------------------------------------------------------------------------------

:: Give the diskletter you want to use as ramdsik
:: Give a letter followed by a colon (T: by default)
set RamDrive=T:

:: Give the ramdisk size, [interger+suffix] M for MegaByte or G for GigaByte 
:: Default is 1500M (1.5GB) with trouble change to RamSize=2G (2GB ramdisk)
set RamSize=1500M

:: ----------------------------------------------------------------------------------
:: GET INSTALLPATH AND LOCALPATH
:: ----------------------------------------------------------------------------------
for /F "skip=2 tokens=3,*" %%i in ('reg query "HKEY_LOCAL_MACHINE\software\wow6432node\bioware\star wars-the old republic" /v "Install Dir" 2^>nul') do set InstallPath=%%j
for /F "skip=2 tokens=3,*" %%i in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Local AppData" 2^>nul') do set AppLocal=%%j
if not defined InstallPath goto ErrorPathFinding
if not defined AppLocal goto ErrorPathFinding

:: ----------------------------------------------------------------------------------
:: MENU
:: ----------------------------------------------------------------------------------
cls
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ                                                                            บ
echo  บ          RAMDISK SETUP OR REMOVAL FOR STAR WARS THE OLD REPUBLIC           บ
echo  บ                          ~ BASIC CACHE VERSION ~                           บ
echo  บ                                                                            บ
echo  บ                Created by: Ocmer_   Forumthread: Lemon_King                บ
echo  บ                                                                            บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
echo Script Settings:
echo     - Ramdisk driveletter:  %RamDrive%
echo     - Ramdisk size:         %RamSize%
echo.
echo Menu:
echo     [S] Setup and prepare SWTOR for a ramdisk.
echo     [R] Remove the ramdisk setup for SWTOR.
echo     [M] Mount a ramdrive for SWTOR (separate smaller script available!)
echo     [D] Dismount the ramdrive to free memory (Mount again if you want to play)
echo     [Q] Quit this script.
echo.
choice /c:srmdq /n /m "Press one of the menu items:"
if errorlevel 5 goto EOF
if errorlevel 4 goto DISMOUNT
if errorlevel 3 goto MOUNT
if errorlevel 2 goto REMOVE
if errorlevel 1 goto SETUP

:: ----------------------------------------------------------------------------------
:: SETUP RAMDISK
:: ----------------------------------------------------------------------------------
:SETUP
cls

:: Start off with dismounting the ramdrive if it exist, and remount it
:: This is also needed if people decide to change the size and add asset files
if exist %RamDrive% imdisk -D -m %RamDrive%
imdisk -a -s %RamSize% -m %RamDrive% -p "/v:SWTOR_RAM /fs:ntfs /q /y"
mkdir "%RamDrive%\SWTOR\swtor"

:: Check if local SWTOR is a junction already
for %%F in ("%applocal%\SWTOR") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l goto SkipBackup

:: Remove old backup and rename original current SWTOR folder
if exist "%AppLocal%\SWTOR_Original" rmdir "%AppLocal%\SWTOR_Original" /S /Q
ren "%applocal%\SWTOR" SWTOR_Original

:SkipBackup
:: If for some reason SWTOR_Original does not exist on this point, recreate it
:: Tho settings will be lost now if this line has to be executed!
if not exist "%AppLocal%\SWTOR_Original" mkdir "%AppLocal%\SWTOR_Original\swtor\settings"

:: Create local SWTOR junction to the SWTOR folder on the ramdisk
if exist "%AppLocal%\SWTOR" rmdir "%AppLocal%\SWTOR" /S /Q
mklink /J "%AppLocal%\SWTOR" "%RamDrive%\SWTOR"

:: Create settings junction to SWTOR_Original in local
mklink /J "%RamDrive%\SWTOR\swtor\settings" "%AppLocal%\SWTOR_Original\swtor\settings"

:: Create DiskCacheArena junction to the ramdrive
if exist "%InstallPath%\swtor\DiskCacheArena" del "%InstallPath%\swtor\DiskCacheArena"
mklink "%InstallPath%\swtor\DiskCacheArena" "%ramdrive%\DiskCacheArena"

:: End script
goto Success

:: ----------------------------------------------------------------------------------
:: REMOVE RAMDISK
:: ----------------------------------------------------------------------------------
:REMOVE
cls

:: If ramdisk exist dismount it
if exist %RamDrive% imdisk -D -m %RamDrive%

:: Delete DiskArenaCache
if exist "%InstallPath%\swtor\DiskCacheArena" del "%InstallPath%\swtor\DiskCacheArena"

:: Delete local SWTOR link
for %%F in ("%AppLocal%\SWTOR") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  rmdir "%AppLocal%\SWTOR" /S /Q
  if not exist "%AppLocal%\SWTOR_Original" mkdir "%AppLocal%\SWTOR\swtor\settings"
  if exist "%AppLocal%\SWTOR_Original" ren "%AppLocal%\SWTOR_Original" SWTOR
) else (
  if exist "%AppLocal%\SWTOR_Original" rmdir "%AppLocal%\SWTOR_Original" /S /Q
)

:: End script
goto Success

:: ----------------------------------------------------------------------------------
:: MOUNT RAMDISK FOR SWTOR (NEEDED AFTER REBOOT, SEPARATE SCRIPT AVAILABLE)
:: ----------------------------------------------------------------------------------
:MOUNT
cls

:: Prepair ramdisk, mount if needed
if not exist %RamDrive% imdisk -a -s %RamSize% -m %RamDrive% -p "/v:SWTOR_RAM /fs:ntfs /q /y"
if exist "%RamDrive%\SWTOR" rmdir "%RamDrive%\SWTOR" /S /Q
mkdir "%RamDrive%\SWTOR\swtor"

:: Create settings junction to SWTOR_Original in local
mklink /J "%RamDrive%\SWTOR\swtor\settings" "%AppLocal%\SWTOR_Original\swtor\settings"

:: End script 
goto EOF

:: ----------------------------------------------------------------------------------
:: DISMOUNT THE RAMDRIVE TO FREE MEMORY BETWEEN GAME SESSIONS
:: ----------------------------------------------------------------------------------
:DISMOUNT
cls

imdisk -D -m %RamDrive%
goto EOF

:: ----------------------------------------------------------------------------------
:: MESSAGES
:: ----------------------------------------------------------------------------------
:ErrorPathFinding
cls
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ                                                                            บ
echo  บ                                   ERROR                                    บ
echo  บ                                                                            บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
echo This script could not find the needed locations on your computer by reading out
echo the required registery. The needed locations that are needed are the
echo installation path of SWTOR and the path to the local application.
echo.
echo This error might occur aswell as you try to run this script on a non 64-bit
echo Windows as this script only looks in the 64-bit registery.
echo.
echo If this script fails and you are running a 64-bit version of windows please
echo follow the manual steps explained on the ramdisk thread by Lemon_King.
echo.
pause
goto EOF

:Success
cls
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ                                                                            บ
echo  บ                                  SUCCESS                                   บ
echo  บ                                                                            บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
pause
goto EOF

:: ----------------------------------------------------------------------------------
:: END OF SCRIPT
:: ----------------------------------------------------------------------------------
:EOF
exit