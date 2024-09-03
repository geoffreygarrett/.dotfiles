# PowerShell Script for WSL2 Installation and Setup

# Parameters (can be overridden when calling the script)
param (
    [string]$WSL_DISTRO = "Ubuntu-20.04",
    [string]$GITHUB_USERNAME = "geoffreygarrett",
    [string]$REPO_NAME = "celestial-blueprint"
)

# Ensure the script is running with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script needs to be run as Administrator. Please restart PowerShell as an Administrator and try again."
    exit 1
}

# Variables
$REPO_URL = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# Utility Functions
function Log {
    param ([string]$message)
    Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") : $message"
}

function InstallWSL {
    # Check if WSL is already installed and skip if it is
    if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online).State -eq 'Enabled') {
        Log "WSL is already installed."
    } else {
        # Enable WSL
        Log "Enabling WSL..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    }

    # Check if Virtual Machine Platform is enabled and enable if not
    if ((Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online).State -eq 'Enabled') {
        Log "Virtual Machine Platform is already enabled."
    } else {
        Log "Enabling Virtual Machine Platform..."
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    }

    # Set WSL 2 as the default
    Log "Setting WSL 2 as the default version..."
    wsl --set-default-version 2

    # Install the specified Linux distribution
    Log "Installing $WSL_DISTRO..."
    wsl --install -d $WSL_DISTRO

    # Wait for WSL to finish setting up
    Start-Sleep -Seconds 30
}

function CloneAndRunSetup {
    # Clone the repository
    Log "Cloning the repository..."
    git clone $REPO_URL

    # Run setup.sh within WSL
    Log "Running setup.sh within WSL..."
    wsl -d $WSL_DISTRO -- bash -c "cd /mnt/c/Users/$env:USERNAME/$REPO_NAME && bash setup.sh"
}

# Script Execution
try {
    InstallWSL
    CloneAndRunSetup
    Log "Setup completed successfully!"
} catch {
    Log "An error occurred: $_"
    exit 1
}

# Prompt user to restart
$restart = Read-Host "A system restart is recommended. Would you like to restart now? (y/n)"
if ($restart -eq 'y') {
    Restart-Computer
}