# env.nu - Set environment variables

# Example: Setting a custom path
$env.PATH = (
  $env.PATH
  | split row (char esep)
  | append /usr/local/bin
  | append ($env.CARGO_HOME | path join bin)
  | append ($env.HOME | path join .local bin)
  | uniq # filter so the paths are unique
)

# Setting XDG_CONFIG_HOME if you prefer a custom location
#$env.XDG_CONFIG_HOME = "/path/to/custom/config"

# Set colors for ls
$env.LS_COLORS = "di=1;34:ln=1;36"

# Set prompt
$env.PROMPT_COMMAND = { |args| "[$(pwd)]> " }

# Add any other environment variables here
