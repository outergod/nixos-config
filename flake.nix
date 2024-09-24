{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    # anyrun.url = "github:anyrun-org/anyrun";
    # anyrun.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };
  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.cunderthunt = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };
  };
}
