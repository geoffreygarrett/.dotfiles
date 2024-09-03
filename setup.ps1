# PowerShell Script for WSL2 Installation and Setup

# Ensure the script is running with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script needs to be run as Administrator. Please restart PowerShell as an Administrator and try again."
    exit 1
}

# Variables
$WSL_DISTRO = "Ubuntu"  # Default distribution
$REPO_URL = "https://github.com/geoffreygarrett/cross-platform-terminal-setup.git"

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
}

function CloneAndRunSetup {
    # Clone the repository
    Log "Cloning the repository..."
    git clone $REPO_URL

    # Extract repository name from URL
    $repoName = Split-Path $REPO_URL -Leaf
    $repoName = $repoName.Replace('.git', '')

    # Run setup.sh within WSL
    Log "Running setup.sh within WSL..."
    wsl -- bash -c "cd /mnt/c/Users/$env:USERNAME/$repoName; ./setup.sh"
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
