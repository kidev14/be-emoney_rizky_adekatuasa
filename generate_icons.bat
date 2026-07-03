@echo off
echo ===================================================
echo   Dompet Kampus Global - Generate Launcher Icons   
echo ===================================================
echo.
echo Running "flutter pub get"...
call flutter pub get
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] "flutter pub get" failed. Please make sure Flutter is installed and in your PATH.
    pause
    exit /b %errorlevel%
)
echo.
echo Running "flutter pub run flutter_launcher_icons"...
call flutter pub run flutter_launcher_icons
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Launcher icon generation failed.
    pause
    exit /b %errorlevel%
)
echo.
echo [SUCCESS] Launcher icons generated successfully!
pause
