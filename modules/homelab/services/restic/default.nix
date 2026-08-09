{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.restic;
in
{
  options.homelab.services.restic = {
    enable = lib.mkEnableOption "Enable restic backups to ";
    environmentFilePath = lib.mkOption {
      type = lib.types.path;
      description = ''
                  Path of file containing credentials for backup location.
                  The file must contain `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and
        	  `AWS_DEFAULT_REGION` variables.
        	  '';
      example = lib.literalExpression ''
                 AWS_ACCESS_KEY_ID="<YOUR_ACCESS_KEY>"
                 AWS_SECRET_ACCESS_KEY="<YOUR_SECRET_KEY>"
        	 AWS_DEFAULT_REGION="<REGION>"
      '';
    };
    repositoryFilePath = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path of file containg the backup server repository url.
      '';
      example = lib.literalExpression ''
        s3:https://s3.<REGION>.io.cloud.ovh.net/<BUCKET_NAME>
      '';
    };
    passwordFilePath = lib.mkOption {
      type = lib.types.path;
      description = ''
        	  Path of file containing encryption key for the repository.
        	'';
    };
    pathsToBackup = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        List of paths to backup.
      '';
      example = lib.literalExpression ''
                 [
        	   "/path/to/backup/"
        	   "/path/to/backup2/"
        	 ];
      '';
    };
    pruneOpts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        List of options to automatically prune old snapshots.
      '';
      example = lib.literalExpression ''
        	 [
        	   "--keep-daily 7"
        	   "--keep-weekly 5"
        	 ];
      '';
      default = [
        "--keep-daily 7"
        "--keep-daily 5"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
    };
    backupCleanupCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = ''
        Script to run after backup process finishes.
      '';
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      restic
    ];

    services.restic.backups.homelab = {
      initialize = true;
      environmentFile = cfg.environmentFilePath;
      repositoryFile = cfg.repositoryFilePath;
      passwordFile = cfg.passwordFilePath;

      paths = cfg.pathsToBackup;
      pruneOpts = cfg.pruneOpts;

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };

      backupCleanupCommand = lib.mkIf (cfg.backupCleanupCommand != null) cfg.backupCleanupCommand;

    };
  };
}
