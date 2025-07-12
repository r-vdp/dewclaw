{ lib, config, ... }:

{
  options.packages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = ''
      Extra packages to install. These are merely names of packages available
      to apk through the package source lists configured on the device.
    '';
  };

  config = {
    deploySteps.packages = lib.mkIf (config.packages != [ ]) {
      priority = 80;
      apply = ''
        apk update
        ${lib.concatMapStringsSep "\n" (
          pkg:
          # sh
          ''
            if ! apk info | grep -qE '^${pkg}$'; then
              apk add ${pkg}
            else
              echo "${pkg} already installed, skipping"
            fi
          '') config.packages}
      '';
    };
  };
}
