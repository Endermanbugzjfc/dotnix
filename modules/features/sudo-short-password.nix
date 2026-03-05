# This feature allows users to have password for sudo that are different from the login password.
# WARNING: the passwords are stored in plain text in the Nix Store. Do NOT use this module on shared machines.
# WARNING 2: this module uses experimental and/or hidden options in NixOS.

# https://github.com/NixOS/nixpkgs/blob/fabb8c9deee281e50b1065002c9828f2cf7b2239/nixos/modules/security/pam.nix#L154

{ config, lib, pkgs, ... }: let
  cfg = config.sudo-short-password;
in {
  options.sudo-short-password = let
    userOpts = { name, ... }: {
      options = {
        name = lib.mkOption {
          type = with lib.types; str;
          description = "Name of the account";
          default = name;
        };
        password = lib.mkOption {
          type = with lib.types; passwdEntry str;
          description = ''
            The short sudo password for the account

            Sudo will accept both this and the original login password of the account.

            To set multiple short passwords for the same acount,
            you might want to leverage the `dbs` option.

            WARNING: the passwords are stored in plain text in the Nix Store.
            Do NOT use this module on shared machines.
          '';
        };
      };
    };
  in {
    enable = lib.mkEnableOption "short passwords for sudo";
    users = lib.mkOption {
      type = with lib.types; attrsOf (submodule userOpts);
      description = "User accounts and their short password for sudo";
      default = {};
    };
    extraDb = lib.mkOption {
      type = with lib.types; lines;
      description = ''
        Extra entries at the end of the database

        The text must end with a new line.
      '';
      default = "";
      example = ''
        rickastley
        00
      '';
    };
    dbs = let
      dbEntries = lib.mapAttrsToList (user: opts: ''
        ${user}
        ${opts.password}
      '') cfg.users;
      dbText = (lib.concatStrings dbEntries) + cfg.extraDb;
      dbInput = pkgs.writeText "sudo-short-password-entries" dbText;
      db = pkgs.runCommand "sudo-short-password.db" {
        # Note: pam_userdb.so is linked to DB 4.8:
        inherit (pkgs) db48;
      } ''
        $db48/bin/db_load -T -t hash -f ${dbInput} $out
      '';
    in lib.mkOption {
      type = with lib.types; listOf package;
      description = "A list of packages that are Berkeley DB 4.8 database file (*.db)";
      default = [ db ];
    };
    followingRule = lib.mkOption {
      type = with lib.types; str;
      description = ''
        Name of the rule that should be arranged after all the rules of sudo-short-password

        Note: each item in the `dbs` option is a separate rule, each other has a order-gap of 10.
        The rules are in reversed order. That is, the last item in `dbs` comes first.

        To get the name of other rules, see "/etc/pam.d/sudo".
        Their name will show in the comments, alongside their Nix-assigned order value.
      '';
      default = "unix";
    };
  };

  config.security.pam.services.sudo.rules.auth = lib.mkIf (cfg.enable) (let
    baseOrder = config.security.pam.services.sudo.rules.auth.${cfg.followingRule}.order;
    rules = builtins.listToAttrs (lib.imap1 (index: db: {
      name = db.name;
      value = {
        order = baseOrder - index * 10;
        control = "sufficient";
        modulePath = "${pkgs.pam}/lib/security/pam_userdb.so";
        settings.db = lib.removeSuffix ".db" db;
      };
    }) cfg.dbs);
  in rules);
}
