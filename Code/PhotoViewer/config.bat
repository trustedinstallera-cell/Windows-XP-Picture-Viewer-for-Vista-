@echo off
setlocal enabledelayedexpansion
:: Use English to avoid encode issues

:: Initialize variables
set "OS_VERSION="
set "OS_FULL_NAME="
set "inputVersion=n"
set "MAJOR="
set "MINOR="
cd /d "%~dp0"

:: check system version
where reg.exe > nul
if %errorlevel% neq 0 (
    echo Cannot find reg command. 	
    echo Exiting...
    pause
    exit /b
)

:: Read version from regedit
set "CURRENT_VERSION="
set "CURRENT_BUILD="
set "PRODUCT_NAME="

for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion 2^>nul') do set "CURRENT_VERSION=%%b"
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul') do set "CURRENT_BUILD=%%b"
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "PRODUCT_NAME=%%b"

:: Try Windows 9x registry key if NT key doesn't exist
if not defined CURRENT_VERSION (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" /v VersionNumber 2^>nul') do set "WIN9X_VERSION=%%b"
    if defined WIN9X_VERSION (
        for /f "tokens=1-2 delims=." %%a in ("!WIN9X_VERSION!") do (
            set "MAJOR=%%a"
            set "MINOR=%%b"
        )
        if "!MAJOR!"=="4" (
            if "!MINOR!"=="0" (
                set "OS_FULL_NAME=Windows 95"
                set "OS_VERSION=Win95"
                echo Not supported.
                pause
                exit /b
            ) else if "!MINOR!"=="10" (
                set "OS_FULL_NAME=Windows 98"
                set "OS_VERSION=Win98"
                echo Not supported.
                pause
                exit /b
            ) else if "!MINOR!"=="90" (
                set "OS_FULL_NAME=Windows ME"
                set "OS_VERSION=WinME"
                echo Not supported.
                pause
                exit /b
            )
        )
    )
)

:: Resolve for NT versions
if defined CURRENT_VERSION (
    for /f "tokens=1-2 delims=." %%a in ("!CURRENT_VERSION!") do (
        set "MAJOR=%%a"
        set "MINOR=%%b"
    )

    :: Windows 2000 / XP / Server 2003 (5.x)
    if "!MAJOR!"=="5" (
        if "!MINOR!"=="0" set "OS_FULL_NAME=Windows 2000" & set "OS_VERSION=Win2000"
        if "!MINOR!"=="1" set "OS_FULL_NAME=Windows XP" & set "OS_VERSION=WinXP"
        if "!MINOR!"=="2" set "OS_FULL_NAME=Windows XP 64-Bit/Server 2003" & set "OS_VERSION=WinXP64"
        echo Not supported.
        pause
        exit /b
    )

    :: Windows Vista / Server 2008 (6.0)
    if "!MAJOR!"=="6" if "!MINOR!"=="0" set "OS_FULL_NAME=Windows Vista/Server 2008" & set "OS_VERSION=WinVista"

    :: Windows 7 / Server 2008 R2 (6.1)
    if "!MAJOR!"=="6" if "!MINOR!"=="1" (
        set "OS_FULL_NAME=Windows 7/Server 2008 R2"
        set "OS_VERSION=Win7"
    )

    :: Windows 8 / Server 2012 (6.2)
    if "!MAJOR!"=="6" if "!MINOR!"=="2" set "OS_FULL_NAME=Windows 8/Server 2012" & set "OS_VERSION=Win8"

    :: Windows 8.1 / Server 2012 R2 (6.3)
    if "!MAJOR!"=="6" if "!MINOR!"=="3" set "OS_FULL_NAME=Windows 8.1/Server 2012 R2" & set "OS_VERSION=Win8.1"

    :: Windows 10 / 11 / Server 2016/2019/2022 (10.0)
    if "!MAJOR!"=="10" if "!MINOR!"=="0" (
        if defined CURRENT_BUILD (
            :: Check for Windows 11 based on Build if >= 22000
            if !CURRENT_BUILD! geq 22000 (
                set "OS_FULL_NAME=Windows 11"
                set "OS_VERSION=Win11"
            ) else (
                set "OS_FULL_NAME=Windows 10/Server 2016/2019"
                set "OS_VERSION=Win10"
            )
        ) else (
            set "OS_FULL_NAME=Windows 10/11"
            set "OS_VERSION=Win10"
        )
    )
)

set "AUTO_MAJOR=!MAJOR!"
set "AUTO_MINOR=!MINOR!"

:: Display results
echo ========================================
echo OS Version Detection Results:
echo Full Name: !OS_FULL_NAME!
echo Short Code: !OS_VERSION!
if defined CURRENT_BUILD echo Build Number: !CURRENT_BUILD!
if defined PRODUCT_NAME echo Product Name: !PRODUCT_NAME!
echo Current Version: !CURRENT_VERSION!
echo ========================================

set /p resetVersion="Correct? (Y/N): "
if /i "!resetVersion!" == "n" (
    set "inputVersion=y"
) else (
    set "MAJOR=!AUTO_MAJOR!"
    set "MINOR=!AUTO_MINOR!"
    goto ApplyLayer
)

if "!inputVersion!" == "y" (
    echo [0] Unchanged ^(Use detected version: !AUTO_MAJOR!.!AUTO_MINOR!^)
    echo [1] Windows XP or before (Not supported^)
    echo [2] Windows Vista
    echo [3] Windows 7
    echo [4] Windows 8
    echo [5] Windows 8.1
    echo [6] Windows 10
    echo [7] Windows 11
    
    :SetValue
    set /p "version=Select OS version: "
    
    if not defined version goto SetValue
    
    if !version! gtr 7 (
        echo ERROR: Value out of range.
        echo Try again.
        goto SetValue
    )
    
    if "!version!" == "0" (
        echo Using detected version.
        set "MAJOR=!AUTO_MAJOR!"
        set "MINOR=!AUTO_MINOR!"
    ) else if "!version!" == "1" (
        echo Unsupported version. Exiting.
        pause
        exit /b
    ) else if "!version!" == "2" (
        set "MAJOR=6"
        set "MINOR=0"
    ) else if "!version!" == "3" (
        set "MAJOR=6"
        set "MINOR=1"
    ) else if "!version!" == "4" (
        set "MAJOR=6"
        set "MINOR=2"
    ) else if "!version!" == "5" (
        set "MAJOR=6"
        set "MINOR=3"
    ) else if "!version!" == "6" (
        set "MAJOR=10"
        set "MINOR=0"
    ) else if "!version!" == "7" (
        set "MAJOR=10"
        set "MINOR=0"
    ) else (
        echo Input Out of range. Try again.
        goto SetValue
    )
    
    echo MAJOR=!MAJOR!, MINOR=!MINOR!
)

:ApplyLayer

:: Set layer settings
echo.
echo Applying compatibility layer settings for MAJOR=%MAJOR%, MINOR=%MINOR%...

if %MAJOR% == 6 (
    if %MINOR% == 0 (
        reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%~dp0rundll32.exe" /t REG_SZ /d "WINXPSP2" /f
    ) else if %MINOR% == 1 (
        reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%~dp0rundll32.exe" /t REG_SZ /d "WINXPSP2" /f		
    ) else if %MINOR% == 2 (
        reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%~dp0rundll32.exe" /t REG_SZ /d "~ WIN7RTM" /f
    ) else if %MINOR% == 3 (
        reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%~dp0rundll32.exe" /t REG_SZ /d "~ WIN7RTM" /f		
    ) else (
        reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%~dp0rundll32.exe" /t REG_SZ /d "~ WIN8RTM" /f
    )
) else (
    reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%~dp0rundll32.exe" /t REG_SZ /d "~ WIN8RTM" /f
)

echo You can set opening method to PhotoViewer.exe manually now. (Optional)
pause