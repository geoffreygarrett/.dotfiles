@echo off
setlocal EnableDelayedExpansion

REM ==========================================================================
REM Global Variables
REM ==========================================================================
if "%GITHUB_USERNAME%"=="" set "GITHUB_USERNAME=geoffreygarrett"
set "REPO_NAME=cross-platform-terminal-setup"
set "REPO_URL=https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git"
set "SETUP_TAG=setup"
set "USE_LOCAL_REPO=false"

REM ==========================================================================
REM Utility Functions
REM ==========================================================================
:log
set "level=%~1"
set "message=%~2"
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2% %dt:~8,2%:%dt:~10,2%:%dt:~12,2%"
set "color="
if "%level%"=="INFO" set "color=[94m"
if "%level%"=="WARNING" set "color=[93m"
if "%level%"=="ERROR" set "color=[91m"
if "%level%"=="SUCCESS" set "color=[92m"
if "%level%"=="DEBUG" set "color=[90m"
echo [1m[%timestamp%][0m %color%%level%[0m: %message%
exit /b

:error
call :log "ERROR" "%~1"
exit /b 1

:run_command
set "command=%~1"
set "temp_file=%temp%\output_%random%.txt"
%command% > "%temp_file%" 2>&1
if %errorlevel% neq 0 (
    call :log "ERROR" "Command failed: %command%"
    type "%temp_file%"
    del "%temp_file%"
    exit /b 1
)
del "%temp_file%"
exit /b 0

REM ==========================================================================
REM Main Functions
REM ==========================================================================
:usage
call :log "INFO" "Usage: setup.bat [--local]"
call :log "INFO" "You can override the default GitHub username by setting the GITHUB_USERNAME environment variable."
call :log "INFO" "Use the --local flag to use the local repository instead of cloning from GitHub."
exit /b

:install_dependencies
call :log "INFO" "Installing dependencies..."
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { ^
        Set-ExecutionPolicy Bypass -Scope Process -Force; ^
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; ^
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) ^
    }"
if %errorlevel% neq 0 exit /b 1

for %%p in (git ansible) do (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "if (-not (Get-Command %%p -ErrorAction SilentlyContinue)) { choco install %%p -y }"
    if !errorlevel! neq 0 exit /b 1
)
exit /b 0

:clone_repository
if "%USE_LOCAL_REPO%"=="true" (
    call :log "INFO" "Using local repository..."
) else (
    call :log "INFO" "Cloning or updating the repository..."
    if not exist "%REPO_NAME%" (
        call :run_command "git clone %REPO_URL%"
    ) else (
        pushd "%REPO_NAME%"
        call :run_command "git pull --rebase"
        popd
    )
)
exit /b

:run_playbook
call :log "INFO" "Running the Ansible playbook..."
if "%USE_LOCAL_REPO%"=="true" (
    if not exist "playbook.yml" (
        call :error "Error: playbook.yml not found in the current directory."
        exit /b 1
    )
    ansible-playbook playbook.yml --tags "%SETUP_TAG%"
) else (
    pushd "%REPO_NAME%"
    if not exist "playbook.yml" (
        call :error "Error: playbook.yml not found in the repository."
        exit /b 1
    )
    ansible-playbook playbook.yml --tags "%SETUP_TAG%"
    popd
)
exit /b

:cleanup
if "%USE_LOCAL_REPO%"=="false" (
    call :log "INFO" "Cleaning up..."
    rmdir /s /q "%REPO_NAME%"
)
exit /b

:main
call :log "INFO" "Starting setup process..."

call :install_dependencies
if %errorlevel% neq 0 exit /b 1

call :clone_repository
if %errorlevel% neq 0 exit /b 1

call :run_playbook
if %errorlevel% neq 0 exit /b 1

call :cleanup
if %errorlevel% neq 0 exit /b 1

call :log "SUCCESS" "Setup completed successfully!"
exit /b 0

REM ==========================================================================
REM Script Execution
REM ==========================================================================
if "%~1"=="--help" (
    call :usage
    exit /b 0
)

if "%~1"=="--local" set "USE_LOCAL_REPO=true"

call :main
if %errorlevel% neq 0 (
    call :log "ERROR" "An error occurred. Setup failed."
    exit /b 1
)
