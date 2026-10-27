{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    opinionated = {
      url = "path:/home/pierre/NixOs-opinionated";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    user-provided-config = {
      url = "path:///etc/nixos-config";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      opinionated,
      user-provided-config,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          mainUser = import "${user-provided-config}/mainUser.nix";
          additionalTrusts = "${user-provided-config}/additional-trusts.crt";
        };
        modules = [
          opinionated.nixosModules.wsl
          ./configuration.nix
        ];
      };
    };
}
