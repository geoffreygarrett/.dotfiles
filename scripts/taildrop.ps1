# Configuration
$DEFAULT_TAILDROP_PATH = "$env:USERPROFILE\Downloads"
$NEW_TAILDROP_PATH = "C:\Path\To\Your\New\Location"
$BACKUP_SUFFIX = ".bak-$(Get-Date -Format 'yyyyMMddHHmmss')"

# Function to print usage
function Print-Usage {
  Write-Host "Usage: .\taildrop.ps1 [change|rollback]"
  Write-Host "  change   - Change Taildrop folder to the new location"
  Write-Host "  rollback - Revert Taildrop folder to the original location"
}

# Function to change Taildrop folder
function Change-TaildropFolder {
  if (-not (Test-Path $DEFAULT_TAILDROP_PATH)) {
    Write-Host "Error: Default Taildrop folder not found."
    exit 1
  }

  # Create new directory if it doesn't exist
  New-Item -ItemType Directory -Force -Path $NEW_TAILDROP_PATH | Out-Null

  # Move contents and create symlink
  Move-Item $DEFAULT_TAILDROP_PATH "${DEFAULT_TAILDROP_PATH}${BACKUP_SUFFIX}"
  New-Item -ItemType SymbolicLink -Path $DEFAULT_TAILDROP_PATH -Target $NEW_TAILDROP_PATH

  Write-Host "Taildrop folder changed to $NEW_TAILDROP_PATH"
  Write-Host "Original folder backed up to ${DEFAULT_TAILDROP_PATH}${BACKUP_SUFFIX}"
}

# Function to rollback changes
function Rollback-Changes {
  if (-not (Get-Item $DEFAULT_TAILDROP_PATH -ErrorAction SilentlyContinue).LinkType -eq "SymbolicLink") {
    Write-Host "Error: No symlink found at $DEFAULT_TAILDROP_PATH. Nothing to rollback."
    exit 1
  }

  # Find the most recent backup
  $LATEST_BACKUP = Get-ChildItem -Path "${DEFAULT_TAILDROP_PATH}.bak-*" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

  if ($null -eq $LATEST_BACKUP) {
    Write-Host "Error: No backup found to rollback to."
    exit 1
  }

  # Remove symlink and restore original folder
  Remove-Item $DEFAULT_TAILDROP_PATH -Force
  Move-Item $LATEST_BACKUP.FullName $DEFAULT_TAILDROP_PATH

  Write-Host "Taildrop folder rolled back to original location: $DEFAULT_TAILDROP_PATH"
}

# Main script logic
if ($args.Count -ne 1) {
  Print-Usage
  exit 1
}

Write-Host "Default Taildrop path: $DEFAULT_TAILDROP_PATH"

switch ($args[0]) {
  "change" { Change-TaildropFolder }
  "rollback" { Rollback-Changes }
  default { Print-Usage; exit 1 }
}