@echo off

set REPO_URL=https://github.com/geoffreygarrett/cross-platform-terminal-setup.git
set REPO_DIR=%USERPROFILE%\cross-platform-terminal-setup

REM Clone or pull the repository
if exist "%REPO_DIR%" (
    cd /d "%REPO_DIR%"
    git pull
) else (
    git clone %REPO_URL% "%REPO_DIR%"
    cd /d "%REPO_DIR%"
)

REM Run the installation script
call install.bat