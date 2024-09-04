# config.nu - Add aliases, functions, and more

# Example: Custom alias
alias ll = "ls -la"

# Alias to use the system's open command on macOS
alias nu-open = open
alias open = ^open

# Remove welcome message
$env.config = ($env.config | upsert show_banner false)

# Customize the prompt (Optional, if not using PROMPT_COMMAND in env.nu)
$env.config = ($env.config | upsert prompt_indicator "〉")
$env.config = ($env.config | upsert prompt_multiline_indicator "::: ")
