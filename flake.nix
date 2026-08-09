{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/lodgeh/nixos-private.git";
      flake = false;
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      agenix,
      secrets,
    }@inputs:
    let
      variables = {
        domain = "homelab2.com";
      };
    in
    {

      nixosConfigurations = {
        homelab = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs variables; };
          modules = [
            ./modules
            ./hosts/homelab/configuration.nix
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
            }
          ];
        };
      };
    };

}
