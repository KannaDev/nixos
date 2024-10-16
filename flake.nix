{
  description = "Hazel flake :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    nix-index-database.url = "github:nix-community/nix-index-database";
    niri.url = "github:sodiboo/niri-flake";
    waybar.url = "github:Alexays/waybar";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      formatter.x86_64-linux = pkgs.nixfmt-rfc-style;
      nixosConfigurations = {
        willow-hazel = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
      modules = [
        ./hosts/willow-hazel/configuration.nix
      ];
        };
      };
      homeConfigurations = {
        hazel = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./homes/hazel/home.nix
          ];
        };
      };
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          zellij
          helix
          nixd
          nixfmt-rfc-style
        ];
        shellHook = ''
          export EDITOR=hx
        '';
      };
    };
}
