{ pkgs, lib, ... }: let
  monitor = ",preferred,auto,1.2";
in {
  home.packages = with pkgs; [
    kando # Pie menu.

    grim  # Screenshot.
    slurp # Screen region selection.

    (writeShellScriptBin "hyprland-toggle-upside-down" ''
      #!/usr/bin/env bash
      # Turn screen upside down:
      # https://www.reddit.com/r/hyprland/comments/114rlm4/hyprctl_command_for_screen_rotation/
      [[ $DESKTOP_SESSION != "hyprland" ]] && exit 1
      PREP='hyprctl keyword monitor ${monitor}'
      if hyprctl monitors | grep -q 'transform: 0'; then
        PREP+=',transform,2'
      fi
      exec $PREP
    '')
  ];

  wayland.windowManager.hyprland.enable = true;
  # wayland.windowManager.hyprland.settings = lib.mkForce {
  wayland.windowManager.hyprland.settings = {
    inherit monitor;
    misc.disable_hyprland_logo = "true"; # Brought my own anime girl.

    # Fix apps that do not follow NIXOS_OZONE_WL:
    # https://www.reddit.com/r/hyprland/comments/194rk1o/comment/khi0k17/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    xwayland.force_zero_scaling = "true";

    gestures = {
      workspace_swipe = "true";
      workspace_swipe_fingers = "4";
    };
    input.accel_profile = "flat";
    input.touchpad = {
      natural_scroll = "true";
      disable_while_typing = "true";
      scroll_factor = "0.3"; # TODO
      clickfinger_behavior = "1"; # Two fingers to right click.
      # drag_3fg = "1";
    };
    device = lib.mkForce [{
      "name" = lib.mkDefault "elan0524:01-04f3:3215-touchpad";
      "sensitivity" =  "1.6";
    }];

    # l -> locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
    # r -> release, will trigger on release of a key.
    # c -> click, will trigger on release of a key or button as long as the mouse cursor stays inside binds:drag_threshold.
    # g -> drag, will trigger on release of a key or button as long as the mouse cursor moves outside binds:drag_threshold.
    # o -> longPress, will trigger on long press of a key.
    # e -> repeat, will repeat when held.
    # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
    # m -> mouse, see below.
    # t -> transparent, cannot be shadowed by other binds.
    # i -> ignore mods, will ignore modifiers.
    # s -> separate, will arbitrarily combine keys between each mod/key, see [Keysym combos](#keysym-combos) above.
    # d -> has description, will allow you to write a description for your bind.
    # p -> bypasses the app's requests to inhibit keybinds.


    bind = [
      # Copied from Arch.
      "\$mainMod ALT, h, movefocus, l"
      "\$mainMod ALT, l, movefocus, r"
      "\$mainMod ALT, k, movefocus, u"
      "\$mainMod ALT, j, movefocus, d"

      "\$mainMod SHIFT, h, movewindow, l"
      "\$mainMod SHIFT, l, movewindow, r"
      "\$mainMod SHIFT, k, movewindow, u"
      "\$mainMod SHIFT, j, movewindow, d"

      "\$mainMod ALT, up, exec, hyprland-toggle-upside-down"
      "\$mainMod, l, exec, hyprlock"
    ];

    # TODO: lower voice = stay mute, higher = auto unmute, step 10. Hold = step 2.
  };

  programs.eww = {
    enable = true;
  };
  programs.wofi = {
    enable = true;
  };
  programs.waybar = { # TODO: future: mouse spotlight effect
    enable = true;
    settings.mainBar = {
      modules-left = lib.mkForce [
        "pulseaudio/slider"
        "pulseaudio"
        "clock"
        "hyprland/workspaces"
        "hyprland/mode"
        "hyprland/scratchpad"
        "custom/media"
      ];
      modules-center = lib.mkForce [
        "hyprland/window"
      ];
      "modules-right" = lib.mkForce [
        "mpd"
        "idle_inhibitor"
        "network"
        "power-profiles-daemon"
        "cpu"
        "memory"
        "backlight"
        "backlight/slider"
        "keyboard-state"
        "sway/language"
        "battery"
        "battery#bat2"
        "tray"
        "custom/power"
      ];

	    "custom/arrow1" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };

	    "custom/arrow2" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };

	    "custom/arrow3" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };

	    "custom/arrow4" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };

	    "custom/arrow5" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };

	    "custom/arrow6" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };

	    "custom/arrow7" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };

	    "custom/arrow8" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };

	    "custom/arrow9" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };

	    "custom/arrow10" = {
	    	"format" = "";
	    	"tooltip" = false;
	    };
    };
    # style = ''
    #   /* Keyframes */
    #
    #   @keyframes blink-critical {
    #   	to {
    #   		/*color: @white;*/
    #   		background-color: @critical;
    #   	}
    #   }
    #
    #
    #   /* Styles */
    #
    #   /* Colors (gruvbox) */
    #   @define-color black	#282828;
    #   @define-color red	#cc241d;
    #   @define-color green	#98971a;
    #   @define-color yellow	#d79921;
    #   @define-color blue	#458588;
    #   @define-color purple	#b16286;
    #   @define-color aqua	#689d6a;
    #   @define-color gray	#a89984;
    #   @define-color brgray	#928374;
    #   @define-color brred	#fb4934;
    #   @define-color brgreen	#b8bb26;
    #   @define-color bryellow	#fabd2f;
    #   @define-color brblue	#83a598;
    #   @define-color brpurple	#d3869b;
    #   @define-color braqua	#8ec07c;
    #   @define-color white	#ebdbb2;
    #   @define-color bg2	#504945;
    #
    #
    #   @define-color warning 	@bryellow;
    #   @define-color critical	@red;
    #   @define-color mode	@black;
    #   @define-color unfocused	@bg2;
    #   @define-color focused	@braqua;
    #   @define-color inactive	@purple;
    #   @define-color sound	@brpurple;
    #   @define-color network	@purple;
    #   @define-color memory	@braqua;
    #   @define-color cpu	@green;
    #   @define-color temp	@brgreen;
    #   @define-color layout	@bryellow;
    #   @define-color battery	@aqua;
    #   @define-color date	@black;
    #   @define-color time	@white;
    #
    #   /* Reset all styles */
    #   * {
    #   	border: none;
    #   	border-radius: 0;
    #   	min-height: 0;
    #   	margin: 0;
    #   	padding: 0;
    #   	box-shadow: none;
    #   	text-shadow: none;
    #   	icon-shadow: none;
    #   }
    #
    #   /* The whole bar */
    #   #waybar {
    #   	background: rgba(40, 40, 40, 0.8784313725); /* #282828e0 */
    #   	color: @white;
    #   	font-family: JetBrains Mono, Siji;
    #   	font-size: 10pt;
    #   	/*font-weight: bold;*/
    #   }
    #
    #   /* Each module */
    #   #battery,
    #   #clock,
    #   #cpu,
    #   #language,
    #   #memory,
    #   #mode,
    #   #network,
    #   #pulseaudio,
    #   #temperature,
    #   #tray,
    #   #backlight,
    #   #idle_inhibitor,
    #   #disk,
    #   #user,
    #   #mpris {
    #   	padding-left: 8pt;
    #   	padding-right: 8pt;
    #   }
    #
    #   /* Each critical module */
    #   #mode,
    #   #memory.critical,
    #   #cpu.critical,
    #   #temperature.critical,
    #   #battery.critical.discharging {
    #   	animation-timing-function: linear;
    #   	animation-iteration-count: infinite;
    #   	animation-direction: alternate;
    #   	animation-name: blink-critical;
    #   	animation-duration: 1s;
    #   }
    #
    #   /* Each warning */
    #   #network.disconnected,
    #   #memory.warning,
    #   #cpu.warning,
    #   #temperature.warning,
    #   #battery.warning.discharging {
    #   	color: @warning;
    #   }
    #
    #   /* And now modules themselves in their respective order */
    #
    #   /* Current sway mode (resize etc) */
    #   #mode {
    #   	color: @white;
    #   	background: @mode;
    #   }
    #
    #   /* Workspaces stuff */
    #   #workspaces button {
    #   	/*font-weight: bold;*/
    #   	padding-left: 2pt;
    #   	padding-right: 2pt;
    #   	color: @white;
    #   	background: @unfocused;
    #   }
    #
    #   /* Inactive (on unfocused output) */
    #   #workspaces button.visible {
    #   	color: @white;
    #   	background: @inactive;
    #   }
    #
    #   /* Active (on focused output) */
    #   #workspaces button.focused {
    #   	color: @black;
    #   	background: @focused;
    #   }
    #
    #   /* Contains an urgent window */
    #   #workspaces button.urgent {
    #   	color: @black;
    #   	background: @warning;
    #   }
    #
    #   /* Style when cursor is on the button */
    #   #workspaces button:hover {
    #   	background: @black;
    #   	color: @white;
    #   }
    #
    #   #window {
    #   	margin-right: 35pt;
    #   	margin-left: 35pt;
    #   }
    #
    #   #pulseaudio {
    #   	background: @sound;
    #   	color: @black;
    #   }
    #
    #   #network {
    #   	background: @network;
    #   	color: @white;
    #   }
    #
    #   #memory {
    #   	background: @memory;
    #   	color: @black;
    #   }
    #
    #   #cpu {
    #   	background: @cpu;
    #   	color: @white;
    #   }
    #
    #   #temperature {
    #   	background: @temp;
    #   	color: @black;
    #   }
    #
    #   #language {
    #   	background: @layout;
    #   	color: @black;
    #   }
    #
    #   #battery {
    #   	background: @battery;
    #   	color: @white;
    #   }
    #
    #   #tray {
    #   	background: @date;
    #   }
    #
    #   #clock.date {
    #   	background: @date;
    #   	color: @white;
    #   }
    #
    #   #clock.time {
    #   	background: @time;
    #   	color: @black;
    #   }
    #
    #   #custom-arrow1 {
    #   	font-size: 11pt;
    #   	color: @time;
    #   	background: @date;
    #   }
    #
    #   #custom-arrow2 {
    #   	font-size: 11pt;
    #   	color: @date;
    #   	background: @layout;
    #   }
    #
    #   #custom-arrow3 {
    #   	font-size: 11pt;
    #   	color: @layout;
    #   	background: @battery;
    #   }
    #
    #   #custom-arrow4 {
    #   	font-size: 11pt;
    #   	color: @battery;
    #   	background: @temp;
    #   }
    #
    #   #custom-arrow5 {
    #   	font-size: 11pt;
    #   	color: @temp;
    #   	background: @cpu;
    #   }
    #
    #   #custom-arrow6 {
    #   	font-size: 11pt;
    #   	color: @cpu;
    #   	background: @memory;
    #   }
    #
    #   #custom-arrow7 {
    #   	font-size: 11pt;
    #   	color: @memory;
    #   	background: @network;
    #   }
    #
    #   #custom-arrow8 {
    #   	font-size: 11pt;
    #   	color: @network;
    #   	background: @sound;
    #   }
    #
    #   #custom-arrow9 {
    #   	font-size: 11pt;
    #   	color: @sound;
    #   	background: transparent;
    #   }
    #
    #   #custom-arrow10 {
    #   	font-size: 11pt;
    #   	color: @unfocused;
    #   	background: transparent;
    #   }
    # '';
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
      };
      listener = [{
        timeout = 60 * 5;
        on-timeout = "loginctl lock-session";
        ignore_inhibit = true;
      }];
    };
  };
  # services.hyprpaper = {
  #   enable = true;
  # };
  programs.hyprlock = {
    enable = true;
  };

  stylix = {
    # enable = true;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/ic-orange-ppl.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/blueforest.yaml";
  };
}
