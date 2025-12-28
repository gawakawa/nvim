{
  pkgs,
  plugins,
  tools ? [ ],
}:

let
  # Fetch Lean abbreviations and convert to Lua table
  leanAbbreviations = pkgs.stdenv.mkDerivation {
    name = "lean-abbreviations";

    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/leanprover/vscode-lean4/master/lean4-unicode-input/src/abbreviations.json";
      hash = "sha256-zDp44YGskOFzp6o0toUne+ikMFrN+aH464CVWj/NFbE=";
    };

    nativeBuildInputs = [ pkgs.jq ];
    dontUnpack = true;

    buildPhase = ''
      # Filter out entries with $CURSOR (bracket pairs with cursor positioning)
      # These require LuaSnip insert nodes for proper cursor placement - not yet implemented
      # TODO: Convert $CURSOR to LuaSnip insert nodes, e.g., { t("⟨"), i(1), t("⟩") }
      # JSON → Lua table conversion
      ${pkgs.jq}/bin/jq -r '
        to_entries
        | map(select(.value | contains("$CURSOR") | not))
        | map("  [" + ("\\"+.key | @json) + "] = " + (.value | @json))
        | "return {\n" + join(",\n") + "\n}"
      ' < $src > lean_abbreviations.lua
    '';

    installPhase = ''
      mkdir -p $out
      cp lean_abbreviations.lua $out/
    '';
  };

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

        # Ensure write permissions for creating new directories
        chmod -R u+w $out

        # Copy Lean abbreviations
        mkdir -p $out/lua/data
        cp ${leanAbbreviations}/lean_abbreviations.lua $out/lua/data/

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
