{
  description = ''
    https://github.com/Endermanbugzjfc/dotnix | Unlicense

    Personal utilities to simply configurations. Feel free to opt in any of
    these in your setup!

    Note: use other names like `utilities` instead of `utils` when adding this
    flake to your inputs or otherwise conflicts with nixosConfigurations'
    built-in arguments might occur.

    For nixosModules: `imports = [ inputs.utilities.nixosModules.<...> ];`
    For overlays: `lib' = with lib; extend(composeManyExtensions [ inputs.utilities.overlays.<...> ])`
  '';

  outputs = { self }: {
    overlays.easy-merge = import ./easy-merge.nix;
    overlays.enable-multi = import ./enable-multi.nix;
    overlays.warn-dupe = import ./warn-dupe.nix;
    nixosModules.lazy-services = ./lazy-services.nix;
  };
}
