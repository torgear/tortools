@echo off
:: ----------------------------------------------------------------------------------
:: USER SETTINGS [ set <name>=<variable>  ; Do not add spaces!! ]
:: ----------------------------------------------------------------------------------

:: Give the diskletter you want to use as ramdsik
:: Give a letter followed by a colon (T: by default)
set RamDrive=T:

:: Give the ramdisk size, [interger+suffix] M for MegaByte or G for GigaByte 
:: Increase size of the ramdisk if you want to add more asset files.
:: Default is 1500M (1.5GB) this can hold the cache and fx asset file.
set RamSize=1500M

:: Declare if you want to include any asset files onto the ramdisk
:: This has to be reflected in the mountscript aswell. Use yes or no.
:: WARNING: if set to yes, you might get an error while patching SWTOR if so
:: to continue the patch remove the ramdisk setup, patch the game, reapply ramdisk
set AddFxFile=yes

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
echo  บ                                                                            บ
echo  บ                Created by: Ocmer_   Forumthread: Lemon_King                บ
echo  บ                                                                            บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
echo Script Settings:
echo     - Ramdisk driveletter:  %RamDrive%
echo     - Ramdisk size:         %RamSize%
echo     - Include Fx asset:     %AddFxFile% (if yes, warning with patching applies)
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

:: Check if user wants to have the fx asset file to be included
if %AddFxFile% == yes goto AddAssetFiles

:: Check if the fx asset file is a link or not (if so repair is needed)
for %%F in ("%InstallPath%\Assets\swtor_main_art_fx_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  if not exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" goto ErrorAssetFx
  del "%InstallPath%\Assets\swtor_main_art_fx_1.tor"
  ren "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" swtor_main_art_fx_1.tor
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor"
)
goto Success

:AddAssetFiles
for %%F in ("%InstallPath%\Assets\swtor_main_art_fx_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  if not exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" goto ErrorAssetFx
  del "%InstallPath%\Assets\swtor_main_art_fx_1.tor"
  mklink "%InstallPath%\Assets\swtor_main_art_fx_1.tor" "%RamDrive%\swtor_main_art_fx_1.tor"
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor"
  ren "%InstallPath%\Assets\swtor_main_art_fx_1.tor" swtor_main_art_fx_1_ORIG.tor
  mklink "%InstallPath%\Assets\swtor_main_art_fx_1.tor" "%RamDrive%\swtor_main_art_fx_1.tor"
)

:CopyFxAsset
:: Check if the fx asset file is already on the ramdrive, else copy it
if exist "%RamDrive%\swtor_main_art_fx_1.tor" goto Success
copy "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_fx_1_ORIG.tor" swtor_main_art_fx_1.tor

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

:: Check if fx needs a repair
for %%F in ("%InstallPath%\Assets\swtor_main_art_fx_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  if not exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" goto ErrorAssetFx
  del "%InstallPath%\Assets\swtor_main_art_fx_1.tor"
  ren "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" swtor_main_art_fx_1.tor
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor"
)

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

:: Copy fx asset file to the ramdisk if needed
if not %AddFxFile% == yes goto EOF
if exist "%RamDrive%\swtor_main_art_fx_1.tor" goto EOF
if not exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" goto ErrorAssetFx
copy "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_fx_1_ORIG.tor" swtor_main_art_fx_1.tor 
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

:ErrorAssetFx
cls
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ                                                                            บ
echo  บ                                   ERROR                                    บ
echo  บ                                                                            บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
echo This script could not find the original fx asset file on your computer. This is
echo needed for both removing the fx asset file from the setup or be able to copy
echo it to the ramdisk to set it up.
echo.
echo As this error only occurs when the filename that is been used by SWTOR is a
echo link already and then this script (and the mountscript) will look for a renamed
echo original fx asset file, that is located in the same asset folder.
echo.
echo Note: if used with [M]ount, make sure you used [S]etup first again with the
echo if you changed usersettings AddFxFile to yes, else the files are not made yet.
echo.
echo If you have the original fx asset file on a different location please place it 
echo back in the asset folder of the game with the name:
echo "swtor_main_art_fx_1_ORIG.tor"
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