{
  inputs,
  lib,
  config,
  ...
}:
let
  service = "immich";
  cfg = config.services.${service};
in
{

  options.services.${service} = {
    enable = lib.mkEnableOption "Enable Immich";
    mediaLocation = lib.mkOption {
      type = lib.types.str;
      default = "var/lib/${service}";
      description = "Directory used to store media files";
    };
    url = lib.mkOption {
      type = lib.types.str;
      description = "Domain name for Immch ";
    };

  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.immich;
      mediaLocation = cfg.mediaLocation;
      port = 2283;
      host = "127.0.0.1";
      machine-learning.enable = true;
    };
    services.caddy = {
      virtualHosts."photos.${cfg.url}".extraConfig = ''
              reverse_proxy ${config.services.immich.host}:${toString config.services.immich.port}

              tls {
                dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        	resolvers 1.1.1.1 1.0.0.1
              }
      '';
    };

  };

}
