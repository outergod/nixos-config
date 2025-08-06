{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@attrs:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      module-unstable = ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; });
      # home = { config, pkgs, lib, utils, home-manager, ... }: import home-manager.nixosModules.home-manager {
      #   inherit config;
      #   inherit pkgs;
      #   inherit lib;
      #   inherit utils;
      #   home-manager.useGlobalPkgs = true;
      #   home-manager.useUserPackages = true;
      #   home-manager.users.outergod = ./home/home.nix;
      #   home-manager.extraSpecialArgs = attrs;
      # };
    in
      {
        nixosConfigurations = {
          cunderthunt = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = attrs;
            modules = [
              module-unstable
              home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.outergod = ./home/home.nix;
                home-manager.extraSpecialArgs = attrs;
              }
              ./configuration.nix
              ./host/cunderthunt.nix
            ];
          };

          phoenix = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = attrs;
            modules = [ ./configuration.nix ./host/phoenix.nix ];
          };
        };
      };
}
