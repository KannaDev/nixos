{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "CascadiaCode"
        "JetBrainsMono"
        "Ubuntu"
        "Terminus"
        "RobotoMono"
        "BigBlueTerminal"
      ];
    })
    roboto-mono
  ];
}
