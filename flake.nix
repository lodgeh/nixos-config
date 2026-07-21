{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

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
      agenix,
      secrets,
    }@inputs:
    {

      nixosConfigurations = {
        nixos-homelab = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./homelab/configuration.nix
	    agenix.nixosModules.default
            {
	      environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
            }
          ];
        };
      };
    };

}
