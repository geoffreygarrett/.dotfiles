# Tools to check
$tools = @("nvim", "zellij")

# Check each tool
foreach ($tool in $tools) {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
    Write-Error "$tool is not installed"
    exit 1
  } else {
    Write-Output "$tool is installed correctly"
  }
}
