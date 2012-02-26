@echo off
:: ----------------------------------------------------------------------------------
:: USER SETTINGS [ set <name>=<variable>  ; Do not add spaces!! ]
:: ----------------------------------------------------------------------------------

:: Give the diskletter you want to use as ramdisk
:: Give a letter followed by a colon (default is T:)
:: This has to be changed in the mountscript aswell
set RamDrive=T:

:: Give the ramdisk size, [interger+suffix] M for MegaByte or G for GigaByte
:: Default is 4G (4GB ramdisk) with trouble increase.
:: This has to be changed in the mountscript aswell
set RamSize=4G

:: Declare if you want to include any asset files onto the ramdisk
:: Warning with patching appies here. Use yes or no (default is yes)
:: This has to be changed in the mountscript aswell
set AddAssetFiles=yes

:: ----------------------------------------------------------------------------------
:: GET INSTALLPATH AND LOCALPATH
:: ----------------------------------------------------------------------------------
for /F "skip=2 tokens=3,*" %%i in ('reg query "HKEY_LOCAL_MACHINE\software\wow6432node\bioware\star wars-the old republic" /v "Install Dir" 2^>nul') do set InstallPath=%%j
for /F "skip=2 tokens=3,*" %%i in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Local AppData" 2^>nul') do set AppLocal=%%j
if not defined InstallPath goto ErrorPathFinding
if not defined AppLocal goto ErrorPathFinding

:: ----------------------------------------------------------------------------------
:: VARIABLE
:: ----------------------------------------------------------------------------------
:: Create variable for assetfile errors
set /a "AssetError=0x00"

:: ----------------------------------------------------------------------------------
:: MENU
:: ----------------------------------------------------------------------------------
cls
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ                                                                            บ
echo  บ          RAMDISK SETUP OR REMOVAL FOR STAR WARS THE OLD REPUBLIC           บ
echo  บ                          CACHE+FX+DYNAMIC VERSION                          บ
echo  บ                                                                            บ
echo  บ                Created by: Ocmer_   Forumthread: Lemon_King                บ
echo  บ                                                                            บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
echo Script Settings:
echo     - Ramdisk driveletter:  %RamDrive%
echo     - Ramdisk size:         %RamSize%
echo     - Include asset files:  %AddAssetFiles% (if yes, warning with patching applies)
echo.
echo Menu:
echo     [S] Setup and prepare SWTOR for a ramdisk.
echo     [R] Remove the ramdisk setup for SWTOR.
echo     [M] Mount a ramdrive for SWTOR (separate smaller script available!)
echo     [D] Dismount the ramdrive to free memory (Mount again if you want to play)
echo     [Q] Quit this script.
echo.
echo If everthing is executed correctly without any errors, this script will close.
echo This script only notifies the user when an error occurred.
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
:: This is also needed if people change settings without first removing
if exist %RamDrive% imdisk -D -m %RamDrive%
imdisk -a -s %RamSize% -m %RamDrive% -p "/v:SWTOR_RAM /fs:ntfs /q /y"
mkdir "%RamDrive%\SWTOR\swtor"

:: Check if local SWTOR is a junction already
for %%F in ("%AppLocal%\SWTOR") do set ATTRIBS=%%~aF
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

:: If there is no asset files to be included go to the remove part of the script
:: This is to check valid asset files, also to reduce code as it would be the same.
if not %AddAssetFiles% == yes goto RemoveAssetFiles

:: Renaming asset files and creating links to the ramdisk
for %%F in ("%InstallPath%\Assets\swtor_main_art_fx_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  del "%InstallPath%\Assets\swtor_main_art_fx_1.tor"
  mklink "%InstallPath%\Assets\swtor_main_art_fx_1.tor" "%RamDrive%\swtor_main_art_fx_1.tor"
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor"
  ren "%InstallPath%\Assets\swtor_main_art_fx_1.tor" swtor_main_art_fx_1_ORIG.tor
  mklink "%InstallPath%\Assets\swtor_main_art_fx_1.tor" "%RamDrive%\swtor_main_art_fx_1.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_cape_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  del "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1.tor"
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1.tor" "%RamDrive%\swtor_main_art_dynamic_cape_1.tor"
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1_ORIG.tor"
  ren "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1.tor" swtor_main_art_dynamic_cape_1_ORIG.tor
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1.tor" "%RamDrive%\swtor_main_art_dynamic_cape_1.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_chest_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  del "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1.tor"
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1.tor" "%RamDrive%\swtor_main_art_dynamic_chest_1.tor"
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1_ORIG.tor"
  ren "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1.tor" swtor_main_art_dynamic_chest_1_ORIG.tor
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1.tor" "%RamDrive%\swtor_main_art_dynamic_chest_1.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  del "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1.tor"
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1.tor" "%RamDrive%\swtor_main_art_dynamic_chest_tight_1.tor"
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1_ORIG.tor"
  ren "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1.tor" swtor_main_art_dynamic_chest_tight_1_ORIG.tor
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1.tor" "%RamDrive%\swtor_main_art_dynamic_chest_tight_1.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_hand_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  del "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1.tor"
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1.tor" "%RamDrive%\swtor_main_art_dynamic_hand_1.tor"
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1_ORIG.tor"
  ren "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1.tor" swtor_main_art_dynamic_hand_1_ORIG.tor
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1.tor" "%RamDrive%\swtor_main_art_dynamic_hand_1.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_head_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  del "%InstallPath%\Assets\swtor_main_art_dynamic_head_1.tor"
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_head_1.tor" "%RamDrive%\swtor_main_art_dynamic_head_1.tor"
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_dynamic_head_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_head_1_ORIG.tor"
  ren "%InstallPath%\Assets\swtor_main_art_dynamic_head_1.tor" swtor_main_art_dynamic_head_1_ORIG.tor
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_head_1.tor" "%RamDrive%\swtor_main_art_dynamic_head_1.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_lower_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  del "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1.tor"
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1.tor" "%RamDrive%\swtor_main_art_dynamic_lower_1.tor"
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1_ORIG.tor"
  ren "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1.tor" swtor_main_art_dynamic_lower_1_ORIG.tor
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1.tor" "%RamDrive%\swtor_main_art_dynamic_lower_1.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_mags_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
  del "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1.tor"
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1.tor" "%RamDrive%\swtor_main_art_dynamic_mags_1.tor"
) else (
  if exist "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1_ORIG.tor"
  ren "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1.tor" swtor_main_art_dynamic_mags_1_ORIG.tor
  mklink "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1.tor" "%RamDrive%\swtor_main_art_dynamic_mags_1.tor"
)

:: Using mount part of the scrip as that has AssetErrorHandling
goto MOUNT

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

:: Check if the dynamic or fx asset files are links, reverse if needed.
:: Also a jumppoint from setup without asset files
:RemoveAssetFiles

for %%F in ("%InstallPath%\Assets\swtor_main_art_fx_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
    del "%InstallPath%\Assets\swtor_main_art_fx_1.tor"
    if not exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" set /a "AssetError|=0x01"
    ren "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" swtor_main_art_fx_1.tor
) else (
    if exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_cape_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
    del "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1.tor"
    if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1_ORIG.tor" set /a "AssetError|=0x02"
    ren "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1_ORIG.tor" swtor_main_art_dynamic_cape_1.tor
) else (
    if exist "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1_ORIG.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_chest_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
    del "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1.tor"
    if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1_ORIG.tor" set /a "AssetError|=0x04"
    ren "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1_ORIG.tor" swtor_main_art_dynamic_chest_1.tor
) else (
    if exist "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1_ORIG.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
    del "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1.tor"
    if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1_ORIG.tor" set /a "AssetError|=0x08"
    ren "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1_ORIG.tor" swtor_main_art_dynamic_chest_tight_1.tor
) else (
    if exist "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1_ORIG.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_hand_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
    del "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1.tor"
    if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1_ORIG.tor" set /a "AssetError|=0x10"
    ren "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1_ORIG.tor" swtor_main_art_dynamic_hand_1.tor
) else (
    if exist "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1_ORIG.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_head_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
    del "%InstallPath%\Assets\swtor_main_art_dynamic_head_1.tor"
    if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_head_1_ORIG.tor" set /a "AssetError|=0x20"
    ren "%InstallPath%\Assets\swtor_main_art_dynamic_head_1_ORIG.tor" swtor_main_art_dynamic_head_1.tor
) else (
    if exist "%InstallPath%\Assets\swtor_main_art_dynamic_head_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_head_1_ORIG.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_lower_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
    del "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1.tor"
    if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1_ORIG.tor" set /a "AssetError|=0x40"
    ren "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1_ORIG.tor" swtor_main_art_dynamic_lower_1.tor
) else (
    if exist "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1_ORIG.tor"
)
for %%F in ("%InstallPath%\Assets\swtor_main_art_dynamic_mags_1.tor") do set ATTRIBS=%%~aF
if %ATTRIBS:~8,1% == l (
    del "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1.tor"
    if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1_ORIG.tor" set /a "AssetError|=0x80"
    ren "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1_ORIG.tor" swtor_main_art_dynamic_mags_1.tor
) else (
    if exist "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1_ORIG.tor" del "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1_ORIG.tor"
)

:: Checking/repairing is done
:: If an asset error occurred go to asset error, else end script
if %AssetError% == 0 goto EOF
goto ErrorAssetMsg

:: ----------------------------------------------------------------------------------
:: MOUNT RAMDISK FOR SWTOR (NEEDED AFTER REBOOT, SEPARATE SCRIPT AVAILABLE)
:: ----------------------------------------------------------------------------------
:MOUNT
cls

:: Dismount ramdrive if exist, starting clean
if exist %RamDrive% imdisk -D -m %RamDrive%

:: Mount a clean ramdrive
imdisk -a -s %RamSize% -m %RamDrive% -p "/v:SWTOR_RAM /fs:ntfs /q /y"

:: Create ramdisk folders
mkdir "%RamDrive%\SWTOR\swtor"

:: Create settings junction to SWTOR_Original in local
mklink /J "%RamDrive%\SWTOR\swtor\settings" "%AppLocal%\SWTOR_Original\swtor\settings"

:: Copy fx asset file to the ramdisk if needed
if not %AddAssetFiles% == yes goto EOF

:: Copy fx asset to ramdisk
if not exist "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" set /a "AssetError|=0x01"
copy "%InstallPath%\Assets\swtor_main_art_fx_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_fx_1_ORIG.tor" swtor_main_art_fx_1.tor

:: Copy dynamic cape asset to ramdisk
if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1_ORIG.tor" set /a "AssetError|=0x02"
copy "%InstallPath%\Assets\swtor_main_art_dynamic_cape_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_dynamic_cape_1_ORIG.tor" swtor_main_art_dynamic_cape_1.tor

:: Copy dynamic chest asset to ramdisk
if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1_ORIG.tor" set /a "AssetError|=0x04"
copy "%InstallPath%\Assets\swtor_main_art_dynamic_chest_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_dynamic_chest_1_ORIG.tor" swtor_main_art_dynamic_chest_1.tor

:: Copy dynamic chest tight asset to ramdisk
if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1_ORIG.tor" set /a "AssetError|=0x08"
copy "%InstallPath%\Assets\swtor_main_art_dynamic_chest_tight_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_dynamic_chest_tight_1_ORIG.tor" swtor_main_art_dynamic_chest_tight_1.tor

:: Copy dynamic hand asset to ramdisk
if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1_ORIG.tor" set /a "AssetError|=0x10"
copy "%InstallPath%\Assets\swtor_main_art_dynamic_hand_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_dynamic_hand_1_ORIG.tor" swtor_main_art_dynamic_hand_1.tor

:: Copy dynamic head asset to ramdisk
if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_head_1_ORIG.tor" set /a "AssetError|=0x20"
copy "%InstallPath%\Assets\swtor_main_art_dynamic_head_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_dynamic_head_1_ORIG.tor" swtor_main_art_dynamic_head_1.tor

:: Copy dynamic lower asset to ramdisk
if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1_ORIG.tor" set /a "AssetError|=0x40"
copy "%InstallPath%\Assets\swtor_main_art_dynamic_lower_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_dynamic_lower_1_ORIG.tor" swtor_main_art_dynamic_lower_1.tor

:: Copy dynamic mags asset to ramdisk
if not exist "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1_ORIG.tor" set /a "AssetError|=0x80"
copy "%InstallPath%\Assets\swtor_main_art_dynamic_mags_1_ORIG.tor" %RamDrive%
ren "%RamDrive%\swtor_main_art_dynamic_mags_1_ORIG.tor" swtor_main_art_dynamic_mags_1.tor

:: If an asset error occurred go to asset error, else end script
if %AssetError% == 0 goto EOF
goto ErrorAssetMsg

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
echo
echo If this script fails and you are running a 64-bit version of windows please
echo follow the manual steps explained on the ramdisk thread by Lemon_King.
echo.
pause
goto EOF

:ErrorAssetMsg
cls
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ                                                                            บ
echo  บ                                   ERROR                                    บ
echo  บ                                                                            บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
echo This script could not find an original asset file on your computer. This is
echo needed for both removing the asset file from the setup or be able to copy
echo it to the ramdisk at mounting a ramdisk for SWTOR.
echo.
echo As this error only occurs when the filename that is been used by SWTOR is a
echo link already and then this script (and the mountscript) will look for a renamed
echo original asset file, that is located in the same asset folder.
echo.
echo If you have the original fx asset file on a different location please place it 
echo back in the asset folder of the game with the name:
echo "swtor_main_art_*_1_ORIG.tor"
echo.
echo Asset error information: %AssetError%
echo.
pause
goto EOF

:: ----------------------------------------------------------------------------------
:: END OF SCRIPT
:: ----------------------------------------------------------------------------------
:EOF
exit