# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./niri.nix
    ./helix.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "hazel";
    homeDirectory = "/home/hazel";
    stateVersion = "24.05";
  };

  home.packages = with pkgs; [
    wget
    git
    waybar
    _1password-gui
    bemenu
    firefox
    kitty
    fastfetch
    alacritty
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    prismlauncher
    cider
    steam
    vscode
    kdePackages.kleopatra
    termius
  ];
  programs.home-manager.enable = true;
  programs.git.enable = true;
  systemd.user.startServices = "sd-switch";
}
