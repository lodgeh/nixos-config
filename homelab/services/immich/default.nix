{ inputs, ... }:
{
  services.immich = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.immich;
    mediaLocation = "/var/lib/immich";
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    machine-learning.enable = true;
  };
  services.caddy = {
    virtualHosts."photos.homelab2.com".extraConfig = ''
            reverse_proxy 127.0.0.1:2283

            tls {
              dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      	resolvers 1.1.1.1 1.0.0.1
            }
    '';
  };

}
