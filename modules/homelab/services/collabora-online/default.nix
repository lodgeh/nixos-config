{ config, lib, ... }:
let
  cfg = config.homelab.services.collabora-online;
in
{
  options.homelab.services.collabora-online = {
    enable = lib.mkEnableOption {
      description = "Enable Collabora Online";
    };
    url = lib.mkOption {
      type = lib.types.str;
      description = "URL for Collabora Online. Will use the `office.` subdomain";
    };

  };

  config = lib.mkIf cfg.enable {
    services.collabora-online = {
      enable = true;
      port = 9980;
      settings = {
        ssl = {
          enable = false;
          termination = true;
        };

        net = {
          listen = "loopback";
          post_allow.host = [
            "127.0.0.1"
            "::1"
          ];
        };

        storage.wopi = {
          "@allow" = true;
          host = [ "cloud.${cfg.url}" ];
        };

        server_name = "office.${cfg.url}";
      };
    };
    services.caddy = {
      virtualHosts."office.${cfg.url}".extraConfig = ''
              reverse_proxy [::1]:${toString config.services.collabora-online.port}

              tls {
                dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        	resolvers 1.1.1.1 1.0.0.1
              }
      '';
    };
  };
}
