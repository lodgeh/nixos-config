{
  config,
  inputs,
  variables,
  ...
}:
{
  services.opencloud = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.opencloud;
    url = "https://cloud.${variables.domain}";
    address = "127.0.0.1";
    port = 9200;
    environment = {
      PROXY_TLS = "false";
    };
    environmentFile = config.age.secrets."opencloud/admin".path;
    environment = {
      OC_ADD_RUN_SERVICES = "collaboration";
      COLLABORATION_APP_NAME = "Office";
      COLLABORATION_APP_PRODUCT = "Collabora";
      COLLABORATION_APP_ADDR = "http://[::1]:9980";
      COLLABORATION_APP_INSECURE = "true";
      COLLABORATION_WOPI_SRC = "https://cloud.${variables.domain}";
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
            "https://office.${variables.domain}"
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
        # Tell your proxy to look at that CSP file you created
        csp_config_file_location = "/etc/opencloud/csp.yaml";
      };
    };
  };
  services.caddy = {
    virtualHosts."cloud.${variables.domain}".extraConfig = ''
            reverse_proxy 127.0.0.1:9200

            tls {
              dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      	resolvers 1.1.1.1 1.0.0.1
            }
    '';
  };

}
