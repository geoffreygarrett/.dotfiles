@echo off
setlocal

REM Default GitHub username (can be overridden by environment variable)
set "GITHUB_USERNAME=%GITHUB_USERNAME:geoffreygarrett%"
set "REPO_NAME=cross-platform-terminal-setup"
set "REPO_URL=https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git"

REM Install Ansible and Git using Chocolatey
echo Installing dependencies...
if not exist "%ProgramFiles%\Git" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    choco install git -y
)
if not exist "%ProgramFiles%\Ansible" (
    choco install ansible -y
)

REM Clone the playbook repository
if not exist "%REPO_NAME%" (
    git clone "%REPO_URL%"
) else (
    cd "%REPO_NAME%"
    git pull
    cd ..
)

REM Run the Ansible playbook
cd "%REPO_NAME%"
ansible-playbook playbook.yml --tags "setup"
if %errorlevel% neq 0 (
    echo Setup failed. Please check the output above.
    exit /b 1
)

echo Setup completed successfully!
