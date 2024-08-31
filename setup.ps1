# PowerShell Script for Cross-Platform Terminal Setup including WSL2

# Ensure the script is running with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script needs to be run as Administrator. Please restart PowerShell as an Administrator and try again."
    exit 1
}

# Global Variables
$GITHUB_USERNAME = if ($env:GITHUB_USERNAME) { $env:GITHUB_USERNAME } else { "geoffreygarrett" }
$REPO_NAME = "cross-platform-terminal-setup"
$REPO_URL = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
$SETUP_TAG = "setup"
$USE_LOCAL_REPO = $false
$WSL_DISTRO = "Ubuntu"

# Utility Functions
function Log {
    param (
        [string]$level,
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($level) {
        "INFO" { "Blue" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        "SUCCESS" { "Green" }
        "DEBUG" { "Gray" }
        default { "White" }
    }
    Write-Host "[$timestamp] $level`: " -NoNewline
    Write-Host "$message" -ForegroundColor $color
}

function RunCommand {
    param (
        [string]$command
    )
    try {
        Log "DEBUG" "Executing: $command"
        $output = Invoke-Expression $command
        if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code $LASTEXITCODE" }
        if ($output) {
            Write-Host $output -ForegroundColor DarkGray
        }
        return $output
    }
    catch {
        Log "WARNING" "Command failed: $command"
        Log "WARNING" $_.Exception.Message
        return $null
    }
}

# Main Functions
function ShowUsage {
    Log "INFO" "Usage: .\setup.ps1 [-Local] [-Distro <DistributionName>]"
    Log "INFO" "You can override the default GitHub username by setting the GITHUB_USERNAME environment variable."
    Log "INFO" "Use the -Local switch to use the local repository instead of cloning from GitHub."
    Log "INFO" "Use the -Distro parameter to specify a different Linux distribution (default is Ubuntu)."
}

function EnsureChocolatey {
    $chocoExePath = "C:\ProgramData\chocolatey\bin\choco.exe"
    
    if (Test-Path $chocoExePath) {
        $env:Path += ";C:\ProgramData\chocolatey\bin"
        Log "INFO" "Chocolatey found. Adding to PATH for this session."
    } else {
        Log "INFO" "Chocolatey not found. Installing..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        try {
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        } catch {
            Log "ERROR" "Failed to install Chocolatey: $_"
            exit 1
        }
    }
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Log "INFO" "Upgrading Chocolatey..."
        RunCommand "choco upgrade chocolatey -y"
    } else {
        Log "ERROR" "Chocolatey installation failed or not in PATH. Please install manually and try again."
        exit 1
    }
}

function InstallOrUpgradePackage {
    param (
        [string]$packageName
    )
    if (Get-Command $packageName -ErrorAction SilentlyContinue) {
        Log "INFO" "Upgrading $packageName..."
        RunCommand "choco upgrade $packageName -y"
    } else {
        Log "INFO" "Installing $packageName..."
        RunCommand "choco install $packageName -y"
    }
    
    if (-not (Get-Command $packageName -ErrorAction SilentlyContinue)) {
        Log "WARNING" "Failed to install or upgrade $packageName. Please install it manually."
    }
}

function InstallDependencies {
    Log "INFO" "Installing and updating dependencies..."
    EnsureChocolatey
    
    foreach ($pkg in @("git")) {
        InstallOrUpgradePackage $pkg
    }
    
    # Special handling for Ansible
    if (-not (Get-Command ansible -ErrorAction SilentlyContinue)) {
        Log "INFO" "Installing Ansible via pip..."
        RunCommand "pip install --user ansible"
        if (-not (Get-Command ansible -ErrorAction SilentlyContinue)) {
            Log "WARNING" "Failed to install Ansible. You may need to install it manually or add it to your PATH."
        }
    }
}

function CheckWindowsVersion {
    $osInfo = Get-WmiObject -Class Win32_OperatingSystem
    $buildNumber = [int]($osInfo.BuildNumber)
    
    if ($buildNumber -lt 19041) {
        Log "ERROR" "Your Windows version is not compatible with WSL2. Please update to Windows 10 version 2004 (Build 19041) or higher."
        exit 1
    }
}

function EnableWindowsFeature {
    param (
        [string]$featureName
    )
    
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName
    if ($feature.State -eq "Enabled") {
        Log "INFO" "Windows feature $featureName is already enabled."
    } else {
        Log "INFO" "Enabling Windows feature: $featureName"
        $result = Enable-WindowsOptionalFeature -Online -FeatureName $featureName -NoRestart
        if ($result.RestartNeeded) {
            Log "WARNING" "A system restart is required to complete the installation of $featureName."
        }
    }
}

function InstallWSL {
    Log "INFO" "Checking WSL installation..."
    
    $wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue
    if ($wslInstalled) {
        Log "INFO" "WSL is already installed. Checking version..."
        $wslVersion = wsl --status
        if ($wslVersion -match "Default Version: 2") {
            Log "INFO" "WSL2 is already set as the default version."
            return
        }
    }
    
    Log "INFO" "Installing or updating WSL..."
    
    EnableWindowsFeature "Microsoft-Windows-Subsystem-Linux"
    EnableWindowsFeature "VirtualMachinePlatform"
    
    Log "INFO" "Downloading and installing WSL2 kernel update..."
    $url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $outPath = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $url -OutFile $outPath
    RunCommand "msiexec /i $outPath /qn"
    Remove-Item $outPath
    
    Log "INFO" "Setting WSL2 as the default version..."
    RunCommand "wsl --set-default-version 2"
    
    Log "INFO" "Installing WSL distribution: $WSL_DISTRO"
    RunCommand "wsl --install -d $WSL_DISTRO"
}

function SetupWSL2 {
    CheckWindowsVersion
    InstallWSL
    Log "SUCCESS" "WSL2 installation completed successfully!"
    Log "INFO" "You may need to restart your computer to finish the WSL setup."
    Log "INFO" "After restarting, the first launch of your Linux distribution may take a few minutes to complete the setup."
}

function CloneRepository {
    if ($USE_LOCAL_REPO) {
        Log "INFO" "Using local repository..."
    }
    else {
        Log "INFO" "Cloning or updating the repository..."
        if (-not (Test-Path $REPO_NAME)) {
            RunCommand "git clone $REPO_URL"
        }
        else {
            Push-Location $REPO_NAME
            RunCommand "git pull --rebase"
            Pop-Location
        }
    }
}

function RunPlaybook {
    Log "INFO" "Running the Ansible playbook..."
    if (-not (Get-Command ansible -ErrorAction SilentlyContinue)) {
        Log "ERROR" "Ansible is not installed or not in PATH. Skipping playbook execution."
        return
    }
    
    if ($USE_LOCAL_REPO) {
        if (-not (Test-Path "playbook.yml")) {
            Log "ERROR" "Error: playbook.yml not found in the current directory."
            return
        }
        RunCommand "ansible-playbook playbook.yml --tags '$SETUP_TAG'"
    }
    else {
        Push-Location $REPO_NAME
        if (-not (Test-Path "playbook.yml")) {
            Log "ERROR" "Error: playbook.yml not found in the repository."
            Pop-Location
            return
        }
        RunCommand "ansible-playbook playbook.yml --tags '$SETUP_TAG'"
        Pop-Location
    }
}

function Cleanup {
    if (-not $USE_LOCAL_REPO) {
        Log "INFO" "Cleaning up..."
        Remove-Item -Recurse -Force $REPO_NAME -ErrorAction SilentlyContinue
    }
}

function Main {
    Log "INFO" "Starting setup process..."
    InstallDependencies
    SetupWSL2
    CloneRepository
    RunPlaybook
    Cleanup
    Log "SUCCESS" "Setup completed successfully!"
    Log "INFO" "If you haven't already, please restart your computer to complete the WSL2 installation."
    Log "INFO" "After restarting, run 'wsl' in a new PowerShell window to complete the Linux distribution setup."
}

# Script Execution
if ($args -contains "-help" -or $args -contains "--help") {
    ShowUsage
    exit 0
}

if ($args -contains "-Local" -or $args -contains "--local") {
    $USE_LOCAL_REPO = $true
}

for ($i = 0; $i -lt $args.Count; $i++) {
    if ($args[$i] -eq "-Distro" -and $i+1 -lt $args.Count) {
        $WSL_DISTRO = $args[$i+1]
        $i++
    }
}

try {
    Main
}
catch {
    Log "ERROR" "An error occurred. Setup failed: $_"
    exit 1
}
