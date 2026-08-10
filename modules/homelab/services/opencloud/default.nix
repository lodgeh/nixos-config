{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.homelab.services.opencloud;
in
{
  imports = [ ../collabora-online ];

  options.homelab.services.opencloud = {
    enable = lib.mkEnableOption {
      description = "Enable OpenCloud";
    };
    environmentFilePath = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path of file containing the initial admin password.
        The file must contain the `IDM_ADMIN_PASSWORD` variable.
      '';
      example = lib.literalExpression ''
        IDM_ADMIN_PASSWORD=<PASSWORD>
      '';
    };
    url = lib.mkOption {
      type = lib.types.str;
      description = "URL for OpenCloud service. Will use the `cloud.` subdomain.";
    };
    directory = lib.mkOption {
      type = lib.types.str;
      description = "OpenCloud data directory";
      default = "/var/lib/opencloud";
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.services.collabora-online = {
      enable = true;
      url = cfg.url;
    };

    services.opencloud = {
      enable = true;
      package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.opencloud;
      url = "https://cloud.${cfg.url}";
      address = "127.0.0.1";
      port = 9200;
      environmentFile = cfg.environmentFilePath;
      stateDir = cfg.directory;

      # for collabora online integration
      environment = {
        PROXY_TLS = "false";
      };
      environment = {
        OC_ADD_RUN_SERVICES = "collaboration";
        COLLABORATION_APP_NAME = "Office";
        COLLABORATION_APP_PRODUCT = "Collabora";
        COLLABORATION_APP_ADDR = "http://[::1]:9980";
        COLLABORATION_APP_INSECURE = "true";
        COLLABORATION_WOPI_SRC = "https://cloud.${cfg.url}";
        COLLABORATION_APP_PROOF_DISABLE = "true";
      };
      settings = {
        csp = {
          directives = {
            child-src = [
              "'self'"
            ];
            connect-src = [
              "'self'"
              "blob:"
              "https://\${COMPANION_DOMAIN|companion.opencloud.test}\${TRAEFIK_PORT_HTTPS}/"
              "wss://\${COMPANION_DOMAIN|companion.opencloud.test}\${TRAEFIK_PORT_HTTPS}/"
              "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
              "https://\${IDP_DOMAIN|keycloak.opencloud.test}\${TRAEFIK_PORT_HTTPS}/"
              "https://update.opencloud.eu/"
            ];
            default-src = [
              "'none'"
            ];
            font-src = [
              "'self'"
            ];
            frame-ancestors = [
              "'self'"
            ];
            frame-src = [
              "'self'"
              "blob:"
              "https://embed.diagrams.net"
              "https://office.${cfg.url}"
              "https://docs.opencloud.eu"
            ];
            img-src = [
              "'self'"
              "data:"
              "blob:"
              "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
              "https://tile.openstreetmap.org/"
            ];
            manifest-src = [
              "'self'"
            ];
            media-src = [
              "'self'"
            ];
            object-src = [
              "'self'"
              "blob:"
            ];
            script-src = [
              "'self'"
              "'unsafe-inline'"
              "https://\${IDP_DOMAIN|keycloak.opencloud.test}\${TRAEFIK_PORT_HTTPS}/"
            ];
            style-src = [
              "'self'"
              "'unsafe-inline'"
            ];
          };
        };

        proxy = {
          csp_config_file_location = "/etc/opencloud/csp.yaml";
        };
      };
    };
    services.caddy = {
      virtualHosts."cloud.${cfg.url}".extraConfig = ''
              reverse_proxy ${config.services.opencloud.address}:${toString config.services.opencloud.port}

              tls {
                dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        	resolvers 1.1.1.1 1.0.0.1
              }
      '';
    };
  };
}
