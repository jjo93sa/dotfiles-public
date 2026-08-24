{config, lib, ...}: let
  cfg = config.onePassword;
in {
  options.onePassword.sshAgentKeys = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        account = lib.mkOption {type = lib.types.str;};
        item = lib.mkOption {type = lib.types.str;};
        vault = lib.mkOption {type = lib.types.str;};
      };
    });
    default = [];
    description = "1Password items exposed through the user's SSH agent.";
  };

  config = lib.mkIf (cfg.sshAgentKeys != []) {
    xdg.configFile."1Password/ssh/agent.toml".text =
      lib.concatMapStringsSep "\n" (key: ''
        [[ssh-keys]]
        item = ${builtins.toJSON key.item}
        vault = ${builtins.toJSON key.vault}
        account = ${builtins.toJSON key.account}
      '')
      cfg.sshAgentKeys;
  };
}
