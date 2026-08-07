{ variables, ... }:
{
  networking.firewall.allowedTCPPorts = [ 8222 ];

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "http://192.168.1.190";
      SIGNUPS_ALLOWED = true;
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "warning";
    };
  };
  services.caddy = {
    virtualHosts."pass.${variables.domain}".extraConfig = ''
            encode zstd gzip

	    reverse_proxy 127.0.0.1:8222

            tls {
              dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      	resolvers 1.1.1.1 1.0.0.1
            }
    '';
  };
}
