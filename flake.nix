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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-servers-nix.url = "github:natsukium/mcp-servers-nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
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

      imports = [ inputs.treefmt-nix.flakeModule ];

      flake = {
        lib =
          let
            forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
          in
          forAllSystems (
            system:
            let
              pkgs = import inputs.nixpkgs {
                inherit system;
                config.allowUnfree = true;
                overlays = [ (import inputs.rust-overlay) ];
              };
            in
            {
              makeNeovimWrapper =
                {
                  tools ? [ ],
                }:
                let
                  plugins = import ./nix/plugins.nix { inherit pkgs; };
                in
                pkgs.callPackage ./nix/lib/make-neovim-wrapper.nix {
                  inherit plugins tools;
                };
            }
          );
      };

      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        let
          mcpConfig = inputs.mcp-servers-nix.lib.mkConfig pkgs {
            programs = {
              fetch.enable = true;
              nixos.enable = true;
            };
          };
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
                tools = import ./nix/tools.nix { inherit pkgs; };
              in
              pkgs.callPackage ./nix/lib/make-neovim-wrapper.nix {
                inherit plugins tools;
              };

            mcp-config = mcpConfig;
          };

          devShells.default = pkgs.mkShell {
            shellHook = ''
              cat ${mcpConfig} > .mcp.json
              echo "Generated .mcp.json"
            '';
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              stylua.enable = true;
            };
          };
        };
    };
}
