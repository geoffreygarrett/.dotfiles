# config.nu - Add aliases, functions, and more

# Alias to use the system's open command on macOS
alias nu-open = open
alias open = ^open
$env.config = {}

# Remove welcome message
$env.config = ($env.config | upsert show_banner false)
