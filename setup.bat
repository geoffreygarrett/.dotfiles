@echo off
setlocal EnableDelayedExpansion

REM Default GitHub username (can be overridden by environment variable)
if "%GITHUB_USERNAME%"=="" set "GITHUB_USERNAME=geoffreygarrett"
set "REPO_NAME=cross-platform-terminal-setup"
set "REPO_URL=https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git"
set "SETUP_TAG=setup"
set "USE_LOCAL_REPO=false"

REM Parse command-line arguments
if "%~1"=="--local" set "USE_LOCAL_REPO=true"

echo Installing dependencies...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { ^
        Set-ExecutionPolicy Bypass -Scope Process -Force; ^
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; ^
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) ^
    }"
if %ERRORLEVEL% neq 0 goto :error

REM Install Git and Ansible if not installed
for %%p in (git ansible) do (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "if (-not (Get-Command %%p -ErrorAction SilentlyContinue)) { choco install %%p -y }"
    if !ERRORLEVEL! neq 0 goto :error
)

REM Clone or update the repository
if "%USE_LOCAL_REPO%"=="true" (
    echo Using local repository...
) else (
    echo Cloning or updating the repository...
    if not exist "%REPO_NAME%" (
        git clone "%REPO_URL%"
    ) else (
        pushd "%REPO_NAME%"
        git pull --rebase
        popd
    )
    if %ERRORLEVEL% neq 0 goto :error
)

REM Run the Ansible playbook
if "%USE_LOCAL_REPO%"=="true" (
    if not exist "playbook.yml" (
        echo Error: playbook.yml not found in the current directory.
        goto :error
    )
    ansible-playbook playbook.yml --tags "%SETUP_TAG%"
) else (
    pushd "%REPO_NAME%"
    if not exist "playbook.yml" (
        echo Error: playbook.yml not found in the repository.
        goto :error
    )
    ansible-playbook playbook.yml --tags "%SETUP_TAG%"
    popd
)

if %ERRORLEVEL% neq 0 goto :error

REM Cleanup if not using local repo
if "%USE_LOCAL_REPO%"=="false" (
    echo Cleaning up...
    rmdir /s /q "%REPO_NAME%"
)

echo Setup completed successfully!
exit /b 0

:error
echo An error occurred. Setup failed.
exit /b 1
