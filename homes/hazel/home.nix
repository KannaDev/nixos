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
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    opera
    niri
  ];
  programs.home-manager.enable = true;
  programs.git.enable = true;
#  programs.waybar.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
