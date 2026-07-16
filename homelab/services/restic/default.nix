{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    restic
  ];

  services.restic.backups.homelab = {
    initialize = true;
    environmentFile = config.age.secrets."restic/env".path;
    repositoryFile = config.age.secrets."restic/repo".path;
    passwordFile = config.age.secrets."restic/password".path;

    paths = [
      "/var/lib/immich"
    ];

    pruneOpts = [
      "--keep-daily 7"
      "--keep-daily 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };

    backupCleanupCommand = ''
      /run/current-system/sw/bin/shutdown -h now
    '';
  };
}
