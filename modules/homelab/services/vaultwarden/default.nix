{ config, lib, ... }:
let
  cfg = config.homelab.services.vaultwarden;
in
{

  options.homelab.services.vaultwarden = {

    enable = lib.mkEnableOption {
      description = "Enable Vaultwarden";
    };
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/vaultwarden";
    };
    url = lib.mkOption {
      type = lib.types.str;
      description = "URL for Vaultwarden. Will use the `pass.` subdomain";
    };

  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 8222 ];

    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://pass.${cfg.url}";
        SIGNUPS_ALLOWED = true;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "warning";
      };
    };

    services.caddy = {
      virtualHosts."pass.${cfg.url}".extraConfig = ''
                    encode zstd gzip

        	    reverse_proxy ${config.services.vaultwarden.config.ROCKET_ADDRESS}:${toString config.services.vaultwarden.config.ROCKET_PORT}

                    tls {
                      dns cloudflare {env.CLOUDFLARE_API_TOKEN}
              	resolvers 1.1.1.1 1.0.0.1
                    }
      '';
    };
  };
}
