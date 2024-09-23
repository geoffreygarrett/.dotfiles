{ }:
{
  # SSH Server
  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    passwordAuthentication = false;
    allowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
    useDns = true;
    x11Forwarding = false;
  };
}
