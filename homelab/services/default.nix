{ config, pkgs, ... }:

{
  imports = [
    ./immich
    ./restic
    ./vaultwarden
    ./opencloud
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    servers = [ "1.1.1.1" "8.8.8.8" ];
    settings = {
      address = [
        "/photos.homelab2.com/192.168.1.190"
      ];
    };
};


  services.caddy = {
    enable = true;
    environmentFile = config.age.secrets."cloudflare/api".path;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
    };
  };


}
