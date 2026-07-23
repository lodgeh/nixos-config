{ config, inputs, ... }:
{
  services.opencloud = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.opencloud;
    url = "https://cloud.homelab2.com";
    address = "127.0.0.1";
    port = 9200;
    environment = {
      PROXY_TLS = "false";
    };
    environmentFile = config.age.secrets."opencloud/admin".path;
  };
  services.caddy = {
    virtualHosts."cloud.homelab2.com".extraConfig = ''
      reverse_proxy 127.0.0.1:9200

      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
	resolvers 1.1.1.1 1.0.0.1
      }
    '';
  };

}
