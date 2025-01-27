@echo off
setlocal enabledelayedexpansion
title Pong Flashable Firmware Repacker Script

:: ###################
:: Script Information
:: ###################
echo.
echo ###############################################################
echo # Pong Flashable Firmware Repacker                            #
echo # Firmware Repo: https://github.com/spike0en/nothing_archive  #
echo # Author: Spike (spike0en)                                    #
echo ###############################################################
echo.

:: ##########################
:: Ask if 7-Zip is installed 
:: ##########################
echo.
set /p install_7zip="Is 7-Zip installed on your system? (Y/N): "

if /i "%install_7zip%"=="Y" (
    echo Proceeding with the script...
) else (
    echo Please install 7-Zip and run the script again.
    echo You can download it from: https://www.7-zip.org/
    pause
    exit /b
)

:: #################################
:: Get the current script directory
:: #################################
echo.
set script_dir=%~dp0
echo Script Directory: %script_dir%
echo.

:: #############################
:: Prepare Required Directories
:: #############################
echo.
:: Check if the firmware-update directory exists, delete it if it does, 
:: and then create a new one.
if exist "%script_dir%firmware-update" (
    echo Deleting existing firmware-update directory...
    rd /s /q "%script_dir%firmware-update"
)
mkdir "%script_dir%firmware-update" || (
    echo Failed to create firmware-update directory. Exiting...
    pause
    exit /b
)

:: Check if the tmp directory exists, delete it if it does, and create a new one.
if exist "%script_dir%tmp" (
    echo Deleting existing tmp directory...
    rd /s /q "%script_dir%tmp"
)
mkdir "%script_dir%tmp" || (
    echo Failed to create tmp directory. Exiting...
    pause
    exit /b
)

:: ############################################
:: Ask for URL(s) (Boot & Firmware Categories)
:: ############################################
echo.
echo Please enter the URL for the boot category (-image-boot.7z).
echo Example: https://github.com/spike0en/nothing_archive/releases/download/3.0.0-pong.250113/Pong_V3.0-250113-1723-image-boot.7z
set /p boot_url="Enter the URL for the boot category: "

echo.

echo Please enter the URL for the firmware category (-image-firmware.7z).
echo Example: https://github.com/spike0en/nothing_archive/releases/download/3.0.0-pong.250113/Pong_V3.0-250113-1723-image-firmware.7z
set /p firmware_url="Enter the URL for the firmware category: "

echo.

:: ############################
:: Extract Filenames from URLs
:: ############################
for %%a in ("%boot_url%") do set boot_filename=%%~nxa
for %%a in ("%firmware_url%") do set firmware_filename=%%~nxa

echo Boot category file will be saved as: %boot_filename%
echo Firmware category file will be saved as: %firmware_filename%
echo.

:: ###############
:: Download Files
:: ###############
echo.
echo Downloading boot category file from: %boot_url%...
curl -L -o "%script_dir%tmp\%boot_filename%" %boot_url%

echo Downloading firmware category file from: %firmware_url%...
curl -L -o "%script_dir%tmp\%firmware_filename%" %firmware_url%

echo.

:: ############################
:: Extract downloaded 7z Files
:: ############################
echo.
echo Extracting boot category file...
"c:\Program Files\7-Zip\7z.exe" x "%script_dir%tmp\%boot_filename%" -o"%script_dir%tmp" -y >nul || (
    echo Failed to extract boot category file. Exiting...
    pause
    exit /b
)

echo Extracting firmware category file...
"c:\Program Files\7-Zip\7z.exe" x "%script_dir%tmp\%firmware_filename%" -o"%script_dir%tmp" -y >nul || (
    echo Failed to extract firmware category file. Exiting...
    pause
    exit /b
)

:: ########################################
:: Cleanup recovery and vbmeta image files
:: ########################################
echo.
echo Deleting unnecessary files (recovery.img and vbmeta.img)...
del "%script_dir%tmp\recovery.img" >nul 2>&1
del "%script_dir%tmp\vbmeta.img" >nul 2>&1

:: ############################
:: Remove Downloaded .7z Files
:: ############################
echo.
echo Cleaning up downloaded .7z files...
del "%script_dir%tmp\%boot_filename%"
del "%script_dir%tmp\%firmware_filename%"

:: ##############################################
:: Move image files to firmware-update directory
:: ##############################################
echo.
echo Moving .img files to firmware-update directory...
move /Y "%script_dir%tmp\*.img" "%script_dir%firmware-update\"

:: Cleanup temporary directory
rd /s /q "%script_dir%tmp"

:: ##############################
:: Set Build Number for Firmware
:: ##############################
echo.
set /p build_no="Enter the build number for the firmware (e.g., Pong-V3.0-250113-1723): "
echo You entered: %build_no%
echo.

:: #########################################################
:: Archiving firmware package into a recovery flashable zip
:: #########################################################
echo.
echo Compressing firmware-update and META-INF directories into a zip file...

:: Set the output zip file name based on the build number
set zip_name=FW_%build_no%.zip

:: Create the zip file containing the directories and their contents
"c:\Program Files\7-Zip\7z.exe" a -tzip -mx=6 "%script_dir%%zip_name%" "%script_dir%firmware-update" "%script_dir%META-INF"

if %errorlevel% neq 0 (
    echo Failed to create zip file. Exiting...
    pause
    exit /b
)

:: #############
:: Finishing up
:: #############
echo.
echo Firmware update files have been compressed and saved as %zip_name%!
pause
