{pkgs, ...}: {
  home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [pip virtualenv]))
    alejandra
    deadnix
    fd
    gh
    glab
    grepcidr
    jq
    just
    k9s
    kubectl
    lua5_4
    mtr
    nh
    nixd
    pipenv
    pv
    ripgrep
    shellcheck
    shfmt
    statix
    tree-sitter
    tio
    yamllint
    yq-go
  ];
}
