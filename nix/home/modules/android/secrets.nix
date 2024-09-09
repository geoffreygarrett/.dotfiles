{ config, pkgs, user, ... }: {

  sops = {
    # Define the default options for all secrets
    defaultSopsFile = ../../global/secrets.yaml;
    age.sshKeyPaths = [ "/${config.user.home}/.ssh/id_ed25519" ];
    # Permission modes are in octal representation (same as chmod),
    # the digits represent: user|group|others
    # 7 - full (rwx)
    # 6 - read and write (rw-)
    # 5 - read and execute (r-x)
    # 4 - read only (r--)
    # 3 - write and execute (-wx)
    # 2 - write only (-w-)
    # 1 - execute only (--x)
    # 0 - none (---)
    secrets = {
      # GITHUB_TOKEN
      "github-token" = {
        # mode "0400": read permission for owner only
        mode = "0400";
        #        owner = config.users.users.${user}.name;
        #        group = config.users.users.${user}.group;
        # Description: Used for GitHub API authentication
      };

      # OPENAI_API_KEY
      "openai-api-key" = {
        # mode "0400": read permission for owner only
        mode = "0400";
        #        owner = config.users.users.${user}.name;
        #        group = config.users.users.${user}.group;
        # Description: Required for OpenAI API access
      };
      #
      #      # SYNCTHING_CERT
      #      "syncthing-cert" = {
      #        # mode "0644": read for owner, read for group, read for others
      #        mode = "0644";
      ##        owner = config.users.users.${user}.name;
      ##        group = "staff";
      ##        path = "/Users/${user}/Library/Application Support/Syncthing/cert.pem";
      #        # Description: Syncthing TLS certificate
      #      };
      #
      #      # SYNCTHING_KEY
      #      "syncthing-key" = {
      #        # mode "0600": read and write for owner only
      #        mode = "0600";
      ##        owner = config.users.users.${user}.name;
      ##        group = "staff";
      ##        path = "/Users/${user}/Library/Application Support/Syncthing/key.pem";
      #        # Description: Syncthing private key
      #      };
      #
      #      # TAILSCALE_AUTH_KEY
      #      "tailscale-auth-key" = {
      #        # mode "0400": read permission for owner only
      #        mode = "0400";
      ##        owner = config.users.users.${user}.name;
      ##        group = config.users.users.${user}.group;
      #        # Description: Used for Tailscale node authentication
      #      };
    };
  };
}
