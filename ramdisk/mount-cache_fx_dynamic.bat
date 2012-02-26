@echo off
:: ----------------------------------------------------------------------------------
:: USER SETTINGS [ set <name>=<variable>  ; Do not add spaces!! ]
:: ----------------------------------------------------------------------------------

:: Give the diskletter you want to use as ramdsik
:: Give a letter followed by a colon (default is T:)
set RamDrive=T:

:: Give the ramdisk size, [interger+suffix] M for MegaByte or G for GigaByte
:: Default is 4G (4GB ramdisk) with trouble increase.
set RamSize=4G

:: Declare if you want to include any asset files onto the ramdisk
:: Warning with patching appies here. Use yes or no (default is yes)
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
:: MOUNT RAMDISK FOR SWTOR
:: ----------------------------------------------------------------------------------

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