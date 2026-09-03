{pkgs, ...}: {
  home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [pip virtualenv]))
    alejandra
    deadnix
    fd
    gh
    glab
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
    tio
    yamllint
    yq-go
  ];
}
