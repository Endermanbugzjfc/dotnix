# vim:fileencoding=utf-8:foldmethod=marker

{ config, pkgs, lib', system, inputs, ... }: lib'.easyMerge "m" {
# {{{ Shell
  m.shell.environment.systemPackages = with pkgs; [
    entr jq wl-clip-persist wget wl-clipboard p7zip ripgrep stow screen
    openssl

    colordiff
  ];
  programs.nushell.shellAliases.colourdiff = "colordiff";
  m.shell.programs = lib'.enableMulti ''
    bat direnv nix-direnv gpg

    nushell
  '';
  users.users.rickastley.shell = with pkgs; nushell;
  m.shell-services.services.gnupg = lib'.enableMulti "agent";
  services.gnupg.agent.enableSshSupport = true;

  m.shell.imports = [ ./features/nushell-yazi-cwd.nix ];
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
  m."shell: with integrations".programs = lib'.enableMultiWith config.lib.shellIntegrations ''
    yazi starship oxide
    gnupg-agent
  '';
# }}}

# {{{ Workflow Beyond Shell
  m.wbs.environment.systemPackages = with pkgs; [
    sublime-text sublime-merge # TODO: hyprland rule for smerge
  ];
  m.wbs.programs = lib'.enableMulti ''
    git gh lazygit

    vim neovim
    docker-cli
  '';
  programs.neovim.defaultEditor = true;
  m.wbs.virtualisation = lib'.enableMulti "docker";
# }}}

# {{{ Nix-specific Setup
  m.nix.imports = [ inputs.agenix.packages.${system}.default ];
  m.nix.environment.systemPackages = with pkgs; [ nil ]; # Nix language server.
  nix.settings.experimental-features = lib'.mkList "nix-command flakes";
  # Enter a dev shell that has absolutely nothing except Bash built-in commands:
  programs.nushell.shellAliases.kccnp = "nix-shell --pure --expr '(import <nixpkgs> {}).mkShellNoCC {}'";
  # Enter Nix REPL and load Nixpkgs:
  programs.nushell.shellAliases.repl = "nix repl --expr 'pkgs = import <nixpkgs> {}'";
# }}}

# {{{ Other Languages-specific Setups
#     Stuff that I will need before having enough time to scaffold a proper Flake project:
  m.lang.environment.systemPackages = with pkgs; [
    cargo rust-analyzer ra-multiplex

    (python3.withPackages (python-pkgs: with python-pkgs; [
      tkinter # For IDLE.
    ]))

    gnumake
  ];
# }}}
}

# TODO: add Nix LSP

