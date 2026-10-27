{
  lib,
  mainUser,
  additionalTrusts,
  ...
}:
{
  system.stateVersion = "26.05";

  opinionated = {
    # Makes `nh os switch` read the git-ignored machine-specific files.
    system.flakePath = "path:/etc/nixos";

    users.${mainUser.username} = {
      roles = [
        "base"
        "ops"
        "dev"
        "llm"
      ];
      git = {
        userName = mainUser.gitUserName;
        userEmail = mainUser.gitUserEmail;
      };
    }
    // lib.optionalAttrs (mainUser ? homeDirectory) { inherit (mainUser) homeDirectory; };
  };

  security.pki.certificateFiles = lib.mkIf (additionalTrusts != null) [ additionalTrusts ];
}
