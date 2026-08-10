{ config, pkgs, ... }:
let
  homelabDomain = "homelab2.com";
in
{
  imports = [
    ./hardware-configuration.nix
    ./secrets
  ];

  homelab.services = {
    enable = true;
    caddyEnvironmentFilePath = config.age.secrets."cloudflare/api".path;

    immich = {
      enable = true;
      url = homelabDomain;
    };

    vaultwarden = {
      enable = true;
      url = homelabDomain;
    };

    opencloud = {
      enable = true;
      environmentFilePath = config.age.secrets."opencloud/admin".path;
      url = homelabDomain;
    };
  };

  homelab.backups.restic = {
    enable = true;
    environmentFilePath = config.age.secrets."restic/env".path;
    repositoryFilePath = config.age.secrets."restic/repo".path;
    passwordFilePath = config.age.secrets."restic/password".path;
    pathsToBackup = [
      config.services.immich.mediaLocation
      config.services.opencloud.stateDir
      config.homelab.services.vaultwarden.directory
    ];
    backupCleanupCommand = ''
      /run/current-system/sw/bin/shutdown -h now
    '';
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";

  environment.systemPackages = with pkgs; [
    git
    neovim
    nixfmt
    powertop
    smartmontools
    wget
    zfs
  ];

  powerManagement.powertop.enable = true;

  users.users."homelab" = {
    isNormalUser = true;
    description = "homelab";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [ ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
      AllowUsers = [ "homelab" ];
    };
  };

  hardware.enableRedistributableFirmware = true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages;
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    zfs.extraPools = [ "tank" ];
  };

  networking = {
    hostName = "homelab";
    hostId = "be4775d2";
    wireless.enable = true;
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/London";

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "us";

}
