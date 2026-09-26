{ self, inputs, ... }: {
  flake.nixosModules.rust = { config, pkgs, ... }: {
    nixpkgs.overlays = [ inputs.fenix.overlays.default ];
    environment.systemPackages = [
      (pkgs.fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
        "rust-analyzer"
      ])
    ];
  };
}
