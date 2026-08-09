{
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
        host = [ "cloud.homelab2.com" ];
      };

      server_name = "office.homelab2.com";
    };
  };
  services.caddy = {
    virtualHosts."office.homelab2.com".extraConfig = ''
            reverse_proxy [::1]:9980

            tls {
              dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      	resolvers 1.1.1.1 1.0.0.1
            }
    '';
  };

}
