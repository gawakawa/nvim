{ pkgs, ps-pkgs }:

with pkgs;
[
  # For telescope
  ripgrep
  fd

  # For LSP servers
  (callPackage ./pkgs/rustowl { })
  asm-lsp
  bash-language-server
  clang-tools
  clojure-lsp
  deno
  gopls
  # haskell-language-server is managed per-project via haskell.nix
  # haskell-language-server
  prisma-language-server
  ps-pkgs.purescript-language-server
  rust-analyzer
  ruff
  terraform-ls

  # For formatters (conform.nvim)
  nixfmt
  shfmt
  (rust-bin.stable.latest.minimal.override { extensions = [ "rustfmt" ]; })
  ps-pkgs.purs-tidy
  # ruff (already included for LSP)
  biome
  gotools # provides goimports
  go # provides gofmt
  golines
  fourmolu
  haskellPackages.cabal-fmt

  # For linters (nvim-lint)
  shellcheck
  tflint
  oxlint
  statix
  deadnix
  selene
]
