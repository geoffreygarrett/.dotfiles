{
  # SSH Server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      UseDns = true;
    };
    allowSFTP = true;

    # Generate host keys if they don't exist
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    # Optionally set a banner
    # banner = "/path/to/banner";

    # Additional SSH server configuration can be added here
    # extraConfig = ''
    #   # Additional options can be placed here
    # '';

    # Example template for known hosts (optional)
    # knownHosts = [ 
    #   {
    #     hostNames = [ "host.example.com" ];
    #     publicKey = "ssh-rsa AAAAB3Nza...";
    #   }
    # ];
  };
}
