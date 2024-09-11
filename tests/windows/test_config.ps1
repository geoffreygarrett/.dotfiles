# Config files to check
$configs = @("$env:USERPROFILE\.config\nvim\init.vim", "$env:USERPROFILE\.config\zellij\config.toml")

# Check each config file
foreach ($config in $configs) {
  if (-not (Test-Path $config)) {
    Write-Error "Configuration file $config is missing."
    exit 1
    } else {
    Write-Output "Configuration file $config is set up correctly."
  }
}
