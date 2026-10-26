{
  lib,
  mainUser,
  additionalTrusts,
  ...
}:
{
  system.stateVersion = "26.05";

  opinionated = {
    system.enable = true;
    wsl.enable = true;

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

  security.pki.certificateFiles = lib.mkIf (builtins.pathExists additionalTrusts) [
    additionalTrusts
  ];
}
