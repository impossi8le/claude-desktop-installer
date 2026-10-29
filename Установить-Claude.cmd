@echo off
setlocal
chcp 65001 >nul
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-Claude.ps1"
set "exitCode=%ERRORLEVEL%"
echo.
if not "%exitCode%"=="0" (
  echo Installation failed. See the message above.
) else (
  echo Installation complete. Open Claude from the Start menu and sign in.
)
pause
exit /b %exitCode%
