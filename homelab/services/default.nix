{ config, pkgs, ... }:

{
  imports = [
    ./immich
    ./restic
    ./vaultwarden
    ./opencloud
    ./collabora-online
  ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.caddy = {
    enable = true;
    environmentFile = config.age.secrets."cloudflare/api".path;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
    };
  };

}
