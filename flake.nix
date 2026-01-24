{
  description = "Neovim configuration with Nix";

  nixConfig = {
    extra-substituters = [ "https://gawakawa.cachix.org" ];
    extra-trusted-public-keys = [
      "gawakawa.cachix.org-1:lpOOgOfyO68izReEj8TMxjnNRlgUsk4lwJ2KAGF5Xso="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    purescript-overlay.url = "github:thomashoneyman/purescript-overlay";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-servers-nix.url = "github:natsukium/mcp-servers-nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-lean4 = {
      url = "github:leanprover/vscode-lean4";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      inherit systems;

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
      ];

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        let
          ciPackages = with pkgs; [ ];

          devPackages = ciPackages ++ config.pre-commit.settings.enabledPackages;

          mcpConfig = inputs.mcp-servers-nix.lib.mkConfig (import inputs.mcp-servers-nix.inputs.nixpkgs {
            inherit system;
          }) { programs.nixos.enable = true; };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ (import inputs.rust-overlay) ];
          };

          packages = {
            default =
              let
                plugins = import ./nix/plugins.nix { inherit pkgs; };
                ps-pkgs = inputs.purescript-overlay.packages.${system};
                treefmtPkgs = {
                  inherit (config.treefmt.programs)
                    oxfmt
                    fourmolu
                    gofmt
                    goimports
                    cabal-fmt
                    nixfmt
                    ruff-format
                    rustfmt
                    shfmt
                    terraform
                    ;
                };
                tools = import ./nix/tools.nix { inherit pkgs ps-pkgs treefmtPkgs; };
              in
              pkgs.callPackage ./nix/lib/make-neovim-wrapper.nix {
                inherit plugins tools;
                inherit (inputs) vscode-lean4;
              };

            ci = pkgs.buildEnv {
              name = "ci";
              paths = ciPackages;
            };

            mcp-config = mcpConfig;
          };

          pre-commit.settings.hooks = {
            treefmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;
            actionlint.enable = true;
            selene.enable = true;
          };

          devShells.default = pkgs.mkShell {
            buildInputs = devPackages;
            shellHook = ''
              ${config.pre-commit.shellHook}
              cat ${mcpConfig} > .mcp.json
              echo "Generated .mcp.json"
            '';
          };

          treefmt = {
            programs = {
              nixfmt = {
                enable = true;
                includes = [ "*.nix" ];
              };
              stylua = {
                enable = true;
                includes = [ "*.lua" ];
              };
            };
          };
        };
    };
}
