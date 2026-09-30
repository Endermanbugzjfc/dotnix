# Check-rebar prints the GPU PCIe addresses on my desktop computer.
# This will be useful to find the beginning address that changes on every kernel updates, which
# is needed to setup VRAM-swap.

{
  perSystem = { pkgs, ... }: {
    packages.script-apps-check-rebar = pkgs.writeShellScriptBin "check-rebar" ''
      [ "$(uname -n)" != "${flake.lib.hostnames.rig}" ] && echo "This command won't produce intended outputs on this machine" && exit 1

      cat /sys/bus/pci/devices/0000:09:00.0/resource
    '';
  }
}
