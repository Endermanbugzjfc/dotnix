# vim:fileencoding=utf-8:foldmethod=marker

{ config, pkgs, lib', ... }: lib'.easyMerge "m" {
# {{{ Shell
  m.shell-pkgs.environment.systemPackages = with pkgs; [
    entr jq wl-clip-persist wget wl-clipboard p7zip ripgrep stow screen
    openssl

    colordiff
  ];
  programs.nushell.shellAliases.colourdiff = "colordiff";
  m.shell-programs.programs = lib'.enableMulti ''
    bat direnv nix-direnv gpg

    nushell
  '';
  users.users.rickastley.shell = with pkgs; nushell;
  m.shell-services.services = lib'.enableMulti ''
    gnupg-agent
  '';
  services.gnupg-agent.enableSshSupport = true;

  m.shell-features.imports = [ ./features/nushell-yazi-cwd.nix ];
  m.shell-general-aliases.programs.nushell.shellAliases = {
    please = "sudo";
    fg = "job unfreeze";
    f = "job list";
    e = "enter";
  };

  home.shell = config.lib.shellIntegrations;
  lib.shellIntegrations = {
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };
  m.shell-integrated-programs.programs = lib'.enableMultiWith config.lib.shellIntegrations ''
    yazi starship oxide
    gnupg-agent
  '';
# }}}

# {{{ Workflow Beyond Shell
  m.wbs-pkgs.environment.systemPackages = with pkgs; [
    sublime-text sublime-merge # TODO: hyprland rule for smerge
  ];
  m.wbs-programs.programs = lib'.enableMulti ''
    git gh lazygit

    vim neovim
    docker-cli
  '';
  programs.neovim.defaultEditor = true;
  virtualisation.docker.enable = true;
# }}}

# {{{ Language-specific Setups
#     Stuff that I will need before having enough time to scaffold a proper Flake project:

  m.lang-pkgs.environment.systemPackages = with pkgs; [
    cargo rust-analyzer ra-multiplex

    (python3.withPackages (python-pkgs: with python-pkgs; [
      tkinter # For IDLE.
    ]))

    gnumake
  ];

  nix.settings.experimental-features = lib'.mkList "nix-command flakes";
  # Enter a dev shell that has absolutely nothing except Bash built-in commands:
  programs.nushell.shellAliases.kccnp = "nix-shell --pure --expr '(import <nixpkgs> {}).mkShellNoCC {}'";
  # Enter Nix REPL and load Nixpkgs:
  programs.nushell.shellAliases.repl = "nix repl --expr 'pkgs = import <nixpkgs> {}'";
# }}}
}

# TODO: add Nix LSP

