{pkgs, config, lib, ...}: {
  # Link ZSH function directory
  xdg.configFile = {
    "zsh/zsh_funcs" = {
      # Store-manage the functions instead of relying on the checkout path.
      source = ../../files/configs/zsh/zsh_funcs;
      recursive = true;
    };
  };

  # Zsh shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ff = "fastfetch";

      # git
      gaa = "git add --all";
      gcam = "git commit --all --message";
      gcl = "git clone";
      gco = "git checkout";
      ggl = "git pull";
      ggp = "git push";

      # kubectl
      k = "kubectl";
      kgno = "kubectl get node";
      kdno = "kubectl describe node";
      kgp = "kubectl get pods";
      kep = "kubectl edit pods";
      kdp = "kubectl describe pods";
      kdelp = "kubectl delete pods";
      kgs = "kubectl get svc";
      kes = "kubectl edit svc";
      kds = "kubectl describe svc";
      kdels = "kubectl delete svc";
      kgi = "kubectl get ingress";
      kei = "kubectl edit ingress";
      kdi = "kubectl describe ingress";
      kdeli = "kubectl delete ingress";
      kgns = "kubectl get namespaces";
      kens = "kubectl edit namespace";
      kdns = "kubectl describe namespace";
      kdelns = "kubectl delete namespace";
      kgd = "kubectl get deployment";
      ked = "kubectl edit deployment";
      kdd = "kubectl describe deployment";
      kdeld = "kubectl delete deployment";
      kgsec = "kubectl get secret";
      kdsec = "kubectl describe secret";
      kdelsec = "kubectl delete secret";

      ld = "lazydocker";
      lg = "lazygit";

      repo = "cd $HOME/Documents/repositories";
      temp = "cd $HOME/Downloads/temp";

      v = "nvim";
      vi = "nvim";
      vim = "nvim";

      prompt-compact = "export STARSHIP_CONFIG=${config.xdg.configHome}/starship/starship-compact.toml";
      prompt-dense = "export STARSHIP_CONFIG=${config.xdg.configHome}/starship/starship.toml";

      ls = "eza --icons always"; # default view
      ll = "eza -bhl --icons --group-directories-first"; # long list
      la = "eza -abhl --icons --group-directories-first"; # all list
      lt = "eza --tree --level=2 --icons"; # tree

      # Use zoxide for cd
      cd = "z";
    };

    # Home Manager replaced initExtra* with one ordered initContent option.
    # Order 550 runs the fpath setup before completion is initialized.
    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        fpath+=("${config.xdg.configHome}"/zsh/zsh_funcs)
      '')
      ''
        # kubectl auto-complete
        source <(kubectl completion zsh)

        # bindings
        bindkey -v
        bindkey '^A' beginning-of-line
        bindkey '^E' end-of-line
        bindkey '^H' backward-delete-word
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word
        bindkey \^K kill-line

        # open commands in $EDITOR with C-e
        autoload -z edit-command-line
        zle -N edit-command-line
        bindkey "^x^e" edit-command-line

        # Autoload our functions
        autoload cal cdr extract myip rmk roll xargs zvm_after_init zvm_after_lazy_keybindings

        # zsh-syntax-highlighting defaults unknown commands to red and bold.
        # Keep the warning colour without changing the font weight.
        ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'

      ''
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "kubectl"
        "web-search"
      ];
    };
    plugins = [
      {
        # will source nix-zsh-completions
        name = "nix-zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "nix-community";
          repo = "nix-zsh-completions";
          rev = "0.5.1";
          hash = "sha256-bgbMc4HqigqgdkvUe/CWbUclwxpl17ESLzCIP8Sz+F8=";
        };
      }
      {
        # will source zsh-syntax-highlighting.plugin.zsh
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0";
          hash = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
        };
      }
      {
        # will source zsh-autosuggestions.plugin.zsh
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.1";
          hash = "sha256-vpTyYq9ZgfgdDsWzjxVAE7FZH4MALMNZIFyEOBLm5Qo=";
        };
      }
      {
        # Pin the repository because fetchgit otherwise follows a moving HEAD.
        name = "zsh-vim-mode";
        src = pkgs.fetchgit {
          url = "https://github.com/softmoth/zsh-vim-mode.git";
          rev = "7db6c2c8fced78ea2131a4c5236a901a0a2ae2f5";
          hash = "sha256-thpKyMw6ozYqqINchu4QL+4yo49f5Dv5pE3c54Cc2uc=";
        };
      }
      {
        # Pin fzf-git.sh so upstream changes cannot invalidate the fixed hash.
        name = "fzf-git";
        src = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/junegunn/fzf-git.sh/d5b0a5dcd1e073b8bfca45338d5dfad3e5642471/fzf-git.sh";
          hash = "sha256-4HSvELCF6E4Wt4pDltZBdEuc8EbfCEzAWL9/SEYp/Pc=";
        };
      }
    ];
    sessionVariables = {
      EZA_CONFIG_DIR = "${config.home.homeDirectory}/.config/eza";
      OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES";
      KEYTIMEOUT= "40";
      ZVM_VI_EDITOR = "nvim";
      ZVM_VI_INSERT_ESCAPE_BINDKEY = "jk";
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=5";
    };
    syntaxHighlighting.enable = true;

  };
}
