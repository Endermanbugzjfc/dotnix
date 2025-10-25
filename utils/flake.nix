{
  description = ''
    https://github.com/Endermanbugzjfc/dotnix | Unlicense

    Personal utilities to simply configurations. Feel free to opt in any of
    these in your setup!
    For nixosModules: `imports = [ inputs.utilities.nixosModules.<...> ];`
    For overlays: `lib' = with lib; extend(composeManyExtensions [ inputs.utilities.overlays.<...> ])`

    All overlay utils have their unit tests so they should work stably even
    though they are not guaranteed to run fast. I will appreciate any
    improvement PRs!

    NOTE: use other names like `utilities` instead of `utils` when adding this
    flake to your inputs or otherwise conflicts with nixosConfigurations'
    built-in arguments might occur.
  '';

  outputs = { self }: {
    overlays.easy-merge = import ./easy-merge.nix;
    overlays.mk-list = import ./mk-list.nix;
    overlays.enable-multi = import ./enable-multi.nix;
    overlays.warn-dupe = import ./warn-dupe.nix;
    nixosModules.lazy-services = ./lazy-services.nix;
  };
}
