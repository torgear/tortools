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
:: MOUNT RAMDISK FOR SWTOR
:: ----------------------------------------------------------------------------------

:: Prepair ramdisk, mount if needed
if not exist %RamDrive% imdisk -a -s %RamSize% -m %RamDrive% -p "/v:SWTOR_RAM /fs:ntfs /q /y"
if exist "%RamDrive%\SWTOR" rmdir "%RamDrive%\SWTOR" /S /Q
mkdir "%RamDrive%\SWTOR\swtor"
if exist "%RamDrive%\DiskCacheArena del "%RamDrive%\DiskCacheArena"

:: Create settings junction to SWTOR_Original in local
mklink /J "%RamDrive%\SWTOR\swtor\settings" "%AppLocal%\SWTOR_Original\swtor\settings"

:: End script
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

:: ----------------------------------------------------------------------------------
:: END OF SCRIPT
:: ----------------------------------------------------------------------------------
:EOF
exit