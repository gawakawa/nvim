{ pkgs, ps-pkgs }:

let
  telescope = with pkgs; [
    fd
    ripgrep
  ];

  lsp = with pkgs; [
    asm-lsp
    bash-language-server
    clang-tools
    clojure-lsp
    deno
    gopls
    lua-language-server
    prisma-language-server
    ps-pkgs.purescript-language-server
    ruff
    rust-analyzer
    (callPackage ./pkgs/rustowl { })
    terraform-ls
  ];

  formatters = with pkgs; [
    biome
    fourmolu
    go
    golines
    gotools
    haskellPackages.cabal-fmt
    nixfmt
    ps-pkgs.purs-tidy
    ruff
    (rust-bin.stable.latest.minimal.override { extensions = [ "rustfmt" ]; })
    shfmt
    terraform
  ];

  linters = with pkgs; [
    actionlint
    deadnix
    markdownlint-cli2
    oxlint
    selene
    shellcheck
    statix
    stylelint
    textlint
    tflint
  ];
in
pkgs.lib.unique (telescope ++ lsp ++ formatters ++ linters)
