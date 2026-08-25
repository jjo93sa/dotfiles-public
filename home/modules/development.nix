{pkgs, ...}: {
  home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [pip virtualenv]))
    fd
    gh
    glab
    jq
    just
    k9s
    kubectl
    mtr
    nixd
    pipenv
    pv
    ripgrep
    shellcheck
    shfmt
    yamllint
    yq-go
  ];
}
