# Enable XWayland, Hyprland and its dependencies.
# Further configurations can be done via home-manager or within the classic
# `.config` folder.

{ pkgs, lib, ... }: {
  programs.hyprland = {
    enable = true;
    # nvidiaPatches = true
    xwayland.enable = true;
  };
  services.xserver.enable = false;
  xdg.portal = {
    enable = lib.mkDefault true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  environment.sessionVariables = {
    # Hint Electron apps to use Wayland.
    # List of programs that do not follow this variable:
    # - Python IDLE
    NIXOS_OZONE_WL = "1";

    # If your cursor becomes invisible:
    # WRL_NO_HARDWARE_CURSORS = "1";
  };
  hardware = {
    graphics.enable = true;
    # Most Wayland compositors need this:
    # nvidia.modesetting.enable = true;
  };

  programs.waybar.enable = lib.mkDefault true;
  environment.systemPackages = with pkgs; [ kitty ];
}
