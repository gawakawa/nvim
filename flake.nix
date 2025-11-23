{
  description = "Neovim configuration with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
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
