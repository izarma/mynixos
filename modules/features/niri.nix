{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    { pkgs, lib, ... }:
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      };
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!
        settings = {
          input.keyboard = {
            xkb.layout = "us, ua";
          };
          # spawn-at-startup = [
          #   (lib.getExe self'.packages.myNoctalia)
          # ];
          layout.gaps = 5;
          binds = {
            "Mod+Return".spawn-sh = lib.getExe pkgs.alacritty;
            "Mod+Q".close-window = _: { };
          };
        };
      };
    };
}
