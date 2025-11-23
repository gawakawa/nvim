{
  pkgs,
  plugins,
  tools ? [ ],
}:

let
  # Build treesitter parsers string
  treesitterParsers =
    let
      nvimTreesitter = plugins.nvim_treesitter;
    in
    pkgs.lib.concatStringsSep "," (map (parser: "${parser}") nvimTreesitter.dependencies);

  # Environment variables for placeholder substitution
  envVars = plugins // {
    treesitter_parsers = treesitterParsers;
  };

  # Build Neovim config derivation with placeholder substitution
  nvimConfig = pkgs.stdenv.mkDerivation (
    envVars
    // {
      pname = "neovim-config";
      version = "latest";

      src = ../../nvim;

      installPhase = ''
        mkdir -p $out

        # Copy all files
        cp -r $src/* $out/

        # Substitute all placeholders in all files
        for file in $(find $out -type f); do
          substituteAllInPlace "$file"
        done
      '';
    }
  );

in
# Create wrapper script
pkgs.writeShellScriptBin "nvim" ''
  export PATH=$PATH:${pkgs.lib.makeBinPath tools}
  export MY_CONFIG_PATH=${nvimConfig}
  exec ${pkgs.neovim-unwrapped}/bin/nvim -u ${nvimConfig}/init.lua "$@"
''
