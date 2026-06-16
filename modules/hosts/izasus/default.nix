{ self, inputs, ... }: {
  flake.nixosConfigurations.izasus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.izasusConfiguration
    ];
  };
}
