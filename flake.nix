{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@attrs:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      module-unstable = ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; });
    in
      {
        nixosConfigurations = {
          cunderthunt = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = attrs;
            modules = [
              module-unstable
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
