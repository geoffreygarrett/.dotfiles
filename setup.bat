@echo off
setlocal

REM Default GitHub username (can be overridden by environment variable)
if "%GITHUB_USERNAME%"=="" set "GITHUB_USERNAME=geoffreygarrett"
set "REPO_NAME=cross-platform-terminal-setup"
set "REPO_URL=https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git"

REM Install Chocolatey if not installed
echo Installing dependencies...
if not exist "%ProgramData%\chocolatey\bin\choco.exe" (
    echo Chocolatey is not installed. Installing Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
)

REM Install Git if not installed
if not exist "%ProgramFiles%\Git" (
    echo Git is not installed. Installing Git...
    choco install git -y
)

REM Install Ansible if not installed
if not exist "%ProgramFiles%\Ansible" (
    echo Ansible is not installed. Installing Ansible...
    choco install ansible -y
)

REM Clone the playbook repository if it does not exist, otherwise update it
if not exist "%REPO_NAME%" (
    echo Cloning the repository...
    git clone "%REPO_URL%"
) else (
    echo Updating the repository...
    cd "%REPO_NAME%"
    git pull --rebase
    cd ..
)

REM Run the Ansible playbook
echo Running the Ansible playbook...
cd "%REPO_NAME%"
ansible-playbook playbook.yml --tags "setup"

REM Capture the exit code from the last command
set "exit_code=%errorlevel%"

REM Check if the playbook execution failed
if "%exit_code%" neq "0" (
    echo Setup failed. Please check the output above.
    exit /b %exit_code%
)

echo Setup completed successfully!
pause
