{ self, inputs, ... }: {
  flake.nixosConfigurations.izasus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.izasusConfiguration
    ];
  };

  perSystem = { system, ... }: {
      packages.izasus = self.nixosConfigurations.izasus.config.system.build.toplevel;
    };
}
