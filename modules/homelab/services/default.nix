{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homelab.services;
in

{
  options.homelab.services = {
    enable = lib.mkEnableOption "Enable homelab services";
    caddyEnvironmentFilePath = lib.mkOption {
      type = lib.types.path;
      default = config.age.secrets."cloudflare/api".path;
      description = ''
                Environment variable file path for Cloudflare api token.
        	The file must define the variable shown in the example.
      '';
      example = lib.literalExpression ''
        CLOUDFLARE_API_TOKEN=your_token
      '';

    };
  };
  imports = [
    ./immich
    ./vaultwarden
    ./opencloud
    ./collabora-online
  ];

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services.caddy = {
      enable = true;
      environmentFile = cfg.caddyEnvironmentFilePath;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
        hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
      };
    };
  };
}
