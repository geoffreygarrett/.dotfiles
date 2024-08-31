# PowerShell Script for Cross-Platform Terminal Setup including WSL2

# Global Variables
$GITHUB_USERNAME = if ($env:GITHUB_USERNAME) { $env:GITHUB_USERNAME } else { "geoffreygarrett" }
$REPO_NAME = "cross-platform-terminal-setup"
$REPO_URL = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
$SETUP_TAG = "setup"
$USE_LOCAL_REPO = $false
$WSL_DISTRO = "Ubuntu-20.04"

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
        if ($LASTEXITCODE -ne 0) { throw "Command failed: $command" }
        if ($output) {
            Write-Host $output -ForegroundColor DarkGray
        }
        return $output
    }
    catch {
        Log "WARNING" $_.Exception.Message
        if ($_.Exception.Message) {
            Write-Host $_.Exception.Message -ForegroundColor DarkGray
        }
        return $null
    }
}

# Main Functions
function ShowUsage {
    Log "INFO" "Usage: .\setup.ps1 [-Local]"
    Log "INFO" "You can override the default GitHub username by setting the GITHUB_USERNAME environment variable."
    Log "INFO" "Use the -Local switch to use the local repository instead of cloning from GitHub."
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
}

function InstallDependencies {
    Log "INFO" "Installing and updating dependencies..."
    EnsureChocolatey
    
    foreach ($pkg in @("git", "ansible")) {
        InstallOrUpgradePackage $pkg
    }
}

function EnableWindowsFeatures {
    Log "INFO" "Enabling necessary Windows features..."
    RunCommand "dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart"
    RunCommand "dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart"
}

function InstallWSL2Kernel {
    Log "INFO" "Downloading and installing WSL2 kernel update..."
    $url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $outPath = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $url -OutFile $outPath
    RunCommand "msiexec /i $outPath /qn"
    Remove-Item $outPath
}

function SetWSL2AsDefault {
    Log "INFO" "Setting WSL2 as the default version..."
    RunCommand "wsl --set-default-version 2"
}

function InstallWSLDistro {
    Log "INFO" "Installing WSL distribution: $WSL_DISTRO..."
    RunCommand "wsl --install -d $WSL_DISTRO"
}

function SetupWSL2 {
    EnableWindowsFeatures
    InstallWSL2Kernel
    SetWSL2AsDefault
    InstallWSLDistro
    Log "SUCCESS" "WSL2 setup completed successfully!"
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
    if ($USE_LOCAL_REPO) {
        if (-not (Test-Path "playbook.yml")) {
            Log "ERROR" "Error: playbook.yml not found in the current directory."
            exit 1
        }
        RunCommand "ansible-playbook playbook.yml --tags '$SETUP_TAG'"
    }
    else {
        Push-Location $REPO_NAME
        if (-not (Test-Path "playbook.yml")) {
            Log "ERROR" "Error: playbook.yml not found in the repository."
            exit 1
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
    Log "INFO" "Please restart your computer to complete the WSL2 installation."
}

# Script Execution
if ($args -contains "-help" -or $args -contains "--help") {
    ShowUsage
    exit 0
}

if ($args -contains "-Local" -or $args -contains "--local") {
    $USE_LOCAL_REPO = $true
}

try {
    Main
}
catch {
    Log "ERROR" "An error occurred. Setup failed: $_"
    exit 1
}
