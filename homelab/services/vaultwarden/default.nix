
{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "http://192.168.1.190";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "warning";
    };
  };
  networking.firewall.allowedTCPPorts = [ 8222 ];
}
