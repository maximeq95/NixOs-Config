# revim: Neovim configured with nixvim (nvim.nix), and the `revim` command that
# turns it into an IDE, side by side with yazi in a zellij tab (revim.sh).
{
  pkgs,
  evalNixvim, # nixvim's `lib.evalNixvim`
  symlinkJoin,
  writeShellApplication,
  bat,
  fd,
  fzf,
  jq,
  lazygit,
  ripgrep,
  yazi,
  zellij,
  # Overridable, e.g. `revim.override { flavor = "latte"; }`:
  flavor ? "mocha", # Catppuccin flavor
  clipboard ? "osc52", # Neovim's `g:clipboard`: "osc52", "pbcopy", "wl-copy" or null
  extraConfig ? { }, # a nixvim module
}:
let
  neovim =
    (evalNixvim {
      modules = [
        { nixpkgs.pkgs = pkgs; } # this nixpkgs, with its unfree allowances
        ./nvim.nix
        extraConfig
      ];
      extraSpecialArgs = { inherit flavor clipboard; };
    }).config.build.package;
in
symlinkJoin {
  name = "revim";
  paths = [
    neovim
    (writeShellApplication {
      name = "revim";
      runtimeInputs = [
        neovim
        bat
        fd
        fzf
        jq
        lazygit
        ripgrep
        yazi
        zellij
      ];
      runtimeEnv.REVIM_LAYOUT = ./layout.kdl;
      text = builtins.readFile ./revim.sh;
    })
  ];
  passthru = { inherit neovim; };
  meta = {
    description = "Neovim (nixvim), and an IDE around it: yazi and Neovim side by side in zellij";
    mainProgram = "revim";
  };
}
