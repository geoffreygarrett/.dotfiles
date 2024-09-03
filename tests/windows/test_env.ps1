# Environment variables to check
$envVars = @{
  "EDITOR" = "nvim"
  "SHELL" = "zsh"
}

# Check each environment variable
foreach ($var in $envVars.Keys) {
  if ($env:$var -ne $envVars[$var]) {
    Write-Error "Environment variable $var is not set correctly."
    exit 1
  } else {
    Write-Output "Environment variable $var is set correctly."
  }
}
