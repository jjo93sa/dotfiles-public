{pkgs, ...}: {
  home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [pip virtualenv]))
    fd
    jq
    kubectl
    mtr
    nixd
    pipenv
    ripgrep
    yamllint
  ];
}
