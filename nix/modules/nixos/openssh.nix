{
  # SSH Server
  services.openssh = {
    enable = true;

    # Use the new options for PermitRootLogin and PasswordAuthentication
    settings = {
      PermitRootLogin = "prohibit-password"; # Options: "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      PasswordAuthentication = false;
      UseDns = true;
    };

    allowSFTP = true;

    # These commands must be properly defined if used, otherwise, comment them out
    # authorizedKeysCommand = "/path/to/command"; # Define the command to retrieve authorized keys
    # authorizedKeysCommandUser = "nobody"; # Define the user under which the command runs

    # Example template for setting authorized keys files (can be null if not needed)
    # authorizedKeysFiles = [ "/path/to/authorized_keys" ]; 

    # authorizedKeysInHomedir = false; # Set to true if keys are located in the user's home directory

    # Optionally set a banner
    # banner = "/path/to/banner";

    # Additional SSH server configuration can be added here
    # extraConfig = ''
    #   # Additional options can be placed here
    # '';
    #
    # Define the host keys
    # hostKeys = [
    #   # "/path/to/host_key"
    # ];

    # Example template for known hosts (optional)
    # knownHosts = [ "host.example.com ssh-rsa AAAAB3Nza..." ];
  };
}
