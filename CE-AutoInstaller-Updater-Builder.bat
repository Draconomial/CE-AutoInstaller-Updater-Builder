@Echo off
setlocal enabledelayedexpansion
echo HobGoblin's Fast Lazy Installer and Updater for Combat Extended :D

:: Check if winget is available
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo winget is not installed or not in PATH. Please install App Installer from the Microsoft Store.
    pause
    exit /b 1
)

:: Check if dotnet is installed
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo .NET SDK is not installed. Attempting to install it using winget...
    winget install --id Microsoft.DotNet.SDK.9 --source winget
    if %errorlevel% neq 0 (
        echo .NET SDK installation failed. Please install it manually from https://dotnet.microsoft.com/download/dotnet/9.0
        pause
        exit /b 1
    )
)

:: Check if Git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git is not installed. Attempting to install it using winget...
    winget install --id Git.Git -e --source winget
    if %errorlevel% neq 0 (
        echo Git installation failed. Please install it manually from https://git-scm.com/
        pause
        exit /b 1
    )
)

:: Check if we're inside the Mods folder
call :ModsFolderVerifier

:: Set this to true if you only want to update and not install new mods
set "DONTINSTALL=false"

:: Auto-install or update mods
call :GitUpdate CombatExtended https://github.com/CombatExtended-Continued/CombatExtended.git

echo.
echo If you're running this for the first time, run it again to build the assembly files!
echo After the first run, this will pull the latest dev files and rebuild automatically.
pause
exit /b 0

:GitUpdate
echo.
set "ModFolderName=%~1"
set "RepoURL=%~2"

if exist "%~1-master\" (
    set "ModFolderName=%~1-master"
)

if exist "%ModFolderName%\" (
    echo Updating %ModFolderName%...
    pushd "%ModFolderName%"
    if exist ".git" (
        git reset --hard HEAD
        git fetch
        git pull --rebase
        echo Building .sln files in the Source directory...
        for /r "Source" %%I in (*.sln) do (
            echo Building %%~nI...
            pushd "%%~dpI"
            dotnet build "%%~nxI" >> "build.log" 2>&1
            popd
        )
        popd
    ) else (
        popd
        if /I "%DONTINSTALL%"=="true" exit /b 0
        echo .git not found in "%ModFolderName%".
        set "INPUT="
        set /P INPUT=Would you like to DELETE "%ModFolderName%" and reinstall correctly for auto-update? [IAMSURE/n]: 
        call :GitRemoveInstall "%ModFolderName%" "%RepoURL%" "!INPUT!"
        set "INPUT="
    )
) else (
    if /I "%DONTINSTALL%"=="true" exit /b 0
    set "INPUT="
    set /P INPUT=Folder "%ModFolderName%" not found. Would you like to install it? [y/n]: 
    if /I "!INPUT!"=="y" (
        call :GitInstall "%RepoURL%"
    )
    echo Building .sln files in the Source directory...
    for /r "Source" %%I in (*.sln) do (
        echo Building %%~nI...
        pushd "%%~dpI"
        dotnet build "%%~nxI" >> "build.log" 2>&1
        popd
    )
    set "INPUT="
)

exit /b 0

:GitOnlyCheckInstalled
echo.
echo Checking if %~1 is installed...
set "FolderExists=N"
if exist "%~1" set "FolderExists=Y"
if exist "%~1-master" set "FolderExists=Y"
if /I "%FolderExists%"=="N" (
    set "INPUT="
    set /P INPUT=/Mods/%~1/ folder not found. Would you like to install? [y/n]: 
    if /I "!INPUT!"=="y" (
        call :GitInstall "%~2"
    )
    echo Building .sln files in the Source directory...
    for /r "Source" %%I in (*.sln) do (
        echo Building %%~nI...
        pushd "%%~dpI"
        dotnet build "%%~nxI" >> "build.log" 2>&1
        popd
    )
    set "INPUT="
) else (
    echo %~1 is installed.
)

exit /b 0

:GitInstall
git clone %~1
exit /b 0

:GitRemoveInstall
:: args: %~1 = folder, %~2 = repo URL, %~3 = confirmation input
if /I "%~3"=="IAMSURE" (
    echo Deleting and reinstalling mod %~1...
    rmdir /S /Q %~1
    git clone %~2
)
exit /b 0

:ModsFolderVerifier
for %%I in (.) do set "CurrDirName=%%~nxI"
if /I not "!CurrDirName!"=="Mods" (
    echo Please place this script inside your RimWorld/Mods/ folder.
    pause
    exit /b 1
)
exit /b 0
