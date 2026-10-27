{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    opinionated = {
      url = "path:/home/pierre/NixOs-opinionated";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, opinionated, ... }:
    let
      # Machine-specific and git-ignored: only visible when the flake is
      # referenced as `path:/etc/nixos`, which makes Nix copy untracked files.
      mainUserFile = ./. + "/mainUser.nix";
      additionalTrusts = ./. + "/additional-trusts.crt";

      mainUser =
        if builtins.pathExists mainUserFile then
          import mainUserFile
        else
          throw ''
            /etc/nixos/mainUser.nix not found. Create it from exemple_profile.nix,
            then build with `nh os switch` or
            `nixos-rebuild switch --flake path:/etc/nixos#nixos`
            (a plain /etc/nixos reference ignores git-ignored files).
          '';
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit mainUser;
          additionalTrusts = if builtins.pathExists additionalTrusts then additionalTrusts else null;
        };
        modules = [
          opinionated.nixosModules.wsl
          ./configuration.nix
        ];
      };
    };
}
