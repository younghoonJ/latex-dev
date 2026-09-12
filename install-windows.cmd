@echo off
setlocal
cd /d "%~dp0"
echo Installing Windows Neovim + LaTeX environment from latex-dev...
echo MiKTeX is expected to be already installed.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-nvim-latex.ps1" -InstallDependencies
set EXITCODE=%ERRORLEVEL%
echo.
if not "%EXITCODE%"=="0" (
  echo Installation failed with exit code %EXITCODE%.
) else (
  echo Installation completed successfully.
)
echo.
pause
exit /b %EXITCODE%
