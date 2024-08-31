# PowerShell Script for Cross-Platform Terminal Setup

# Global Variables
$GITHUB_USERNAME = if ($env:GITHUB_USERNAME) { $env:GITHUB_USERNAME } else { "geoffreygarrett" }
$REPO_NAME = "cross-platform-terminal-setup"
$REPO_URL = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
$SETUP_TAG = "setup"
$USE_LOCAL_REPO = $false

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
        $output = Invoke-Expression $command
        if ($LASTEXITCODE -ne 0) { throw "Command failed: $command" }
        return $output
    }
    catch {
        Log "ERROR" $_.Exception.Message
        exit 1
    }
}

# Main Functions
function ShowUsage {
    Log "INFO" "Usage: .\setup.ps1 [-Local]"
    Log "INFO" "You can override the default GitHub username by setting the GITHUB_USERNAME environment variable."
    Log "INFO" "Use the -Local switch to use the local repository instead of cloning from GitHub."
}

function InstallDependencies {
    Log "INFO" "Installing dependencies..."
    
    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        # Check if Chocolatey is installed but not in PATH
        if (Test-Path "C:\ProgramData\chocolatey\bin\choco.exe") {
            $env:Path += ";C:\ProgramData\chocolatey\bin"
            Log "INFO" "Added Chocolatey to PATH for this session."
        }
        else {
            # Install Chocolatey
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            
            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        }
    }

    # Verify Chocolatey installation
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Log "ERROR" "Failed to install or locate Chocolatey. Please install it manually and try again."
        exit 1
    }

    foreach ($pkg in @("git", "ansible")) {
        if (-not (Get-Command $pkg -ErrorAction SilentlyContinue)) {
            RunCommand "choco install $pkg -y"
        }
    }
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
    CloneRepository
    RunPlaybook
    Cleanup
    Log "SUCCESS" "Setup completed successfully!"
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
