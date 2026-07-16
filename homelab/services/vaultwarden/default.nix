{

  services.vaultwarden = {
    enable = true;
    config = {
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      EXTENDED_LOGGING = true;
      LOG_LEVEL = "warn";
    };
  };

}
