# vim:fileencoding=utf-8:foldmethod=marker

{ config, pkgs, lib, inputs, ... }: let
  utils = inputs.utilities.overlays;
  lib' = lib.extend(lib.composeManyExtensions [
    utils.easy-merge utils.enable-multi
  ]);
in lib'.easyMerge "m" {
# {{{ Shell
  m.shell-pkgs = {
    environment.systemPackages = with pkgs; [
      entr jq wl-clip-persist wget wl-clipboard p7zip ripgrep stow screen
      openssl

      colordiff
    ];
    programs.nushell.shellAliases.colourdiff = "colordiff";
  };
  m.shell-programs.programs = lib'.enableMulti ''
    bat direnv nix-direnv
  '';

  home.shell = config.g.shellIntegrations;
  m.shell-integrations = {
    options.g.shellIntegrations = lib.mkOption {
      default = {
        enableBashIntegration = true;
        enableNushellIntegration = true;
      };
      readOnly = true;
    };
    programs = lib'.enableMultiWith config.g.shellIntegrations ''
      yazi starship oxide
    '';
  };
# }}}

# {{{ Workflow
  m.workflow-pkgs.environment.systemPackages = with pkgs; [
    sublime-text sublime-merge # TODO: hyprland rule for smerge
  ];
  m.workflow-programs.programs = lib'.enableMulti ''
    git gh lazygit
    vim neovim
  '';
  programs.neovim.defaultEditor = true;

  m.keybase = {
    environment.systemPackages = with pkgs; [
      keybase keybase-gui
    ];
    lazy-services = ''
      keybase kbfs
    '';
  };
# }}}

# {{{ Language-specific Essentials
#     Tools that I will need before having enough time to scaffold a proper Flake project:

# Python
  m.python.environment.systemPackages = with pkgs; [
    (python3.withPackages (python-pkgs: with python-pkgs; [
      tkinter # For IDLE.
    ]))
  ];

# Nix
  # Enter a dev shell that has absolutely nothing except Bash built-in commands:
  programs.nushell.shellAliases.kccnp = "nix-shell --pure --expr '(import <nixpkgs> {}).mkShellNoCC {}'";
  # Enter Nix REPL and load Nixpkgs:
  programs.nushell.shellAliases.repl = "nix repl --expr 'import <nixpkgs> {}'";

# Rust
  m.rust.environment.systemPackages = with pkgs; [
    cargo rust-analyzer ra-multiplex
  ];

# }}}
}

# TODO: add Nix LSP

