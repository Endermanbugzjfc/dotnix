# The official Waybar config converted to home-manager definition.
# https://github.com/Alexays/Waybar/blob/cae5f9a56f88bdd4306860b22740a33e7957e5bc/resources/config.jsonc
#
# NOTE:
# This module configures Waybar without enabling it! Please add this:
# ```
# programs.waybar.enable
# ```
#
# (For more information, see ./default.nix).

{ lib, ... }: {
  programs.waybar.settings.mainBar = {
# "layer" = lib.mkDefault "top"; # Waybar at top layer
# "position" = lib.mkDefault "bottom"; # Waybar position (top|bottom|left|right)
    "height" = lib.mkDefault 30; # Waybar height (to be removed for auto height)
# "width" = lib.mkDefault 1280; # Waybar width
      "spacing" = lib.mkDefault 4; # Gaps between modules (4px)
# Choose the order of the modules
      "modules-left" = [
      "sway/workspaces"
        "sway/mode"
        "sway/scratchpad"
        "custom/media"
      ];
    "modules-center" = [
      "sway/window"
    ];
    "modules-right" = [
      "mpd"
        "idle_inhibitor"
        "pulseaudio"
        "network"
        "power-profiles-daemon"
        "cpu"
        "memory"
        "temperature"
        "backlight"
        "keyboard-state"
        "sway/language"
        "battery"
        "battery#bat2"
        "clock"
        "tray"
        "custom/power"
    ];
# Modules configuration
# "sway/workspaces" = {
#     "disable-scroll" = lib.mkDefault true;
#     "all-outputs" = lib.mkDefault true;
#     "warp-on-scroll" = lib.mkDefault false;
#     "format" = lib.mkDefault "{name}: {icon}";
#     "format-icons" = {
#         "1" = lib.mkDefault "";
#         "2" = lib.mkDefault "";
#         "3" = lib.mkDefault "";
#         "4" = lib.mkDefault "";
#         "5" = lib.mkDefault "";
#         "urgent" = lib.mkDefault "";
#         "focused" = lib.mkDefault "";
#         "default" = lib.mkDefault "";
#     };
# };
    "keyboard-state" = {
      "numlock" = lib.mkDefault true;
      "capslock" = lib.mkDefault true;
      "format" = lib.mkDefault "{name} {icon}";
      "format-icons" = {
        "locked" = lib.mkDefault "";
        "unlocked" = lib.mkDefault "";
      };
    };
    "sway/mode" = {
      "format" = lib.mkDefault "<span style=\"italic\">{}</span>";
    };
    "sway/scratchpad" = {
      "format" = lib.mkDefault "{icon} {count}";
      "show-empty" = lib.mkDefault false;
      "format-icons" = ["" ""];
      "tooltip" = lib.mkDefault true;
      "tooltip-format" = lib.mkDefault "{app}: {title}";
    };
    "mpd" = {
      "format" = lib.mkDefault "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
      "format-disconnected" = lib.mkDefault "Disconnected ";
      "format-stopped" = lib.mkDefault "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
      "unknown-tag" = lib.mkDefault "N/A";
      "interval" = lib.mkDefault 5;
      "consume-icons" = {
        "on" = lib.mkDefault " ";
      };
      "random-icons" = {
        "off" = lib.mkDefault "<span color=\"#f53c3c\"></span> ";
        "on" = lib.mkDefault " ";
      };
      "repeat-icons" = {
        "on" = lib.mkDefault " ";
      };
      "single-icons" = {
        "on" = lib.mkDefault "1 ";
      };
      "state-icons" = {
        "paused" = lib.mkDefault "";
        "playing" = lib.mkDefault "";
      };
      "tooltip-format" = lib.mkDefault "MPD (connected)";
      "tooltip-format-disconnected" = lib.mkDefault "MPD (disconnected)";
    };
    "idle_inhibitor" = {
      "format" = lib.mkDefault "{icon}";
      "format-icons" = {
        "activated" = lib.mkDefault "";
        "deactivated" = lib.mkDefault "";
      };
    };
    "tray" = {
# "icon-size" = lib.mkDefault 21;
      "spacing" = lib.mkDefault 10;
# "icons" = {
#   "blueman" = lib.mkDefault "bluetooth";
#   "TelegramDesktop" = lib.mkDefault "$HOME/.local/share/icons/hicolor/16x16/apps/telegram.png";
# }
    };
    "clock" = {
# "timezone" = lib.mkDefault "America/New_York";
      "tooltip-format" = lib.mkDefault "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      "format-alt" = lib.mkDefault "{:%Y-%m-%d}";
    };
    "cpu" = {
      "format" = lib.mkDefault "{usage}% ";
      "tooltip" = lib.mkDefault false;
    };
    "memory" = {
      "format" = lib.mkDefault "{}% ";
    };
    "temperature" = {
# "thermal-zone" = lib.mkDefault 2;
# "hwmon-path" = lib.mkDefault "/sys/class/hwmon/hwmon2/temp1_input";
      "critical-threshold" = lib.mkDefault 80;
# "format-critical" = lib.mkDefault "{temperatureC}°C {icon}";
      "format" = lib.mkDefault "{temperatureC}°C {icon}";
      "format-icons" = ["" "" ""];
    };
    "backlight" = {
# "device" = lib.mkDefault "acpi_video1";
      "format" = lib.mkDefault "{percent}% {icon}";
      "format-icons" = ["" "" "" "" "" "" "" "" ""];
    };
    "battery" = {
      "states" = {
# "good" = lib.mkDefault 95;
        "warning" = lib.mkDefault 30;
        "critical" = lib.mkDefault 15;
      };
      "format" = lib.mkDefault "{capacity}% {icon}";
      "format-full" = lib.mkDefault "{capacity}% {icon}";
      "format-charging" = lib.mkDefault "{capacity}% ";
      "format-plugged" = lib.mkDefault "{capacity}% ";
      "format-alt" = lib.mkDefault "{time} {icon}";
# "format-good" = lib.mkDefault ""; # An empty format will hide the module
# "format-full" = lib.mkDefault "";
      "format-icons" = ["" "" "" "" ""];
    };
    "battery#bat2" = {
      "bat" = lib.mkDefault "BAT2";
    };
    "power-profiles-daemon" = {
      "format" = lib.mkDefault "{icon}";
      "tooltip-format" = lib.mkDefault "Power profile: {profile}\nDriver: {driver}";
      "tooltip" = lib.mkDefault true;
      "format-icons" = {
        "default" = lib.mkDefault "";
        "performance" = lib.mkDefault "";
        "balanced" = lib.mkDefault "";
        "power-saver" = lib.mkDefault "";
      };
    };
    "network" = {
# "interface" = lib.mkDefault "wlp2*"; # (Optional) To force the use of this interface
      "format-wifi" = lib.mkDefault "{essid} ({signalStrength}%) ";
      "format-ethernet" = lib.mkDefault "{ipaddr}/{cidr} ";
      "tooltip-format" = lib.mkDefault "{ifname} via {gwaddr} ";
      "format-linked" = lib.mkDefault "{ifname} (No IP) ";
      "format-disconnected" = lib.mkDefault "Disconnected ⚠";
      "format-alt" = lib.mkDefault "{ifname}: {ipaddr}/{cidr}";
    };
    "pulseaudio" = {
# "scroll-step" = lib.mkDefault 1; # %, can be a float
      "format" = lib.mkDefault "{volume}% {icon} {format_source}";
      "format-bluetooth" = lib.mkDefault "{volume}% {icon} {format_source}";
      "format-bluetooth-muted" = lib.mkDefault " {icon} {format_source}";
      "format-muted" = lib.mkDefault " {format_source}";
      "format-source" = lib.mkDefault "{volume}% ";
      "format-source-muted" = lib.mkDefault "";
      "format-icons" = {
        "headphone" = lib.mkDefault "";
        "hands-free" = lib.mkDefault "";
        "headset" = lib.mkDefault "";
        "phone" = lib.mkDefault "";
        "portable" = lib.mkDefault "";
        "car" = lib.mkDefault "";
        "default" = ["" "" ""];
      };
      "on-click" = lib.mkDefault "pavucontrol";
    };
    "custom/media" = {
      "format" = lib.mkDefault "{icon} {text}";
      "return-type" = lib.mkDefault "json";
      "max-length" = lib.mkDefault 40;
      "format-icons" = {
        "spotify" = lib.mkDefault "";
        "default" = lib.mkDefault "🎜";
      };
      "escape" = lib.mkDefault true;
      "exec" = lib.mkDefault "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder
# "exec" = lib.mkDefault "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null"; # Filter player based on name
    };
    "custom/power" = {
      "format"  = lib.mkDefault "⏻ ";
      "tooltip" = lib.mkDefault false;
      "menu" = lib.mkDefault "on-click";
      "menu-file" = lib.mkDefault "$HOME/.config/waybar/power_menu.xml"; # Menu file in resources folder
      "menu-actions" = {
        "shutdown" = lib.mkDefault "shutdown";
        "reboot" = lib.mkDefault "reboot";
        "suspend" = lib.mkDefault "systemctl suspend";
        "hibernate" = lib.mkDefault "systemctl hibernate";
      };
    };
  };
}
