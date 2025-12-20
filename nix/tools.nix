{ pkgs, ps-pkgs }:

with pkgs;
[
  # For telescope
  ripgrep
  fd

  # For LSP servers
  (callPackage ./pkgs/rustowl { })
  asm-lsp
  clang-tools
  clojure-lsp
  deno
  gopls
  haskell-language-server
  prisma-language-server
  ps-pkgs.purescript-language-server
  rust-analyzer
  ruff
  terraform-ls

  # For formatters (conform.nvim)
  nixfmt
  rustfmt
  ps-pkgs.purs-tidy
  # ruff (already included for LSP)
  biome
  gotools # provides goimports
  go # provides gofmt
  golines
  fourmolu
  haskellPackages.cabal-fmt
]
