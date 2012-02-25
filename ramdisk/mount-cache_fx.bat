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
:: This has to be reflected in the mountscript aswell. Use yes or no (no by default) 
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
:: MOUNT RAMDISK FOR SWTOR
:: ----------------------------------------------------------------------------------

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

:ErrorAssetFx
cls
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ                                                                            บ
echo  บ                                   ERROR                                    บ
echo  บ                                                                            บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
echo This script could not find the original fx asset file on your computer. This is
echo needed to copy the file to the ramdisk so the game can find the fx file.
echo.
echo If you have the original fx asset file on a different location please place it 
echo back in the asset folder of the game with the name:
echo "swtor_main_art_fx_1_ORIG.tor"
echo.
pause
goto EOF

:: ----------------------------------------------------------------------------------
:: END OF SCRIPT
:: ----------------------------------------------------------------------------------
:EOF
exit