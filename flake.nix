{
  description = "PRC library development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems =
        nixpkgs.lib.genAttrs systems (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};

            pythonEnv = pkgs.python312.withPackages (ps: with ps; [
              pip
              ipython
              numpy
              pandas
              polars
              pyarrow
              requests
              camelot
              pypdf2
            ]);
          in {
            default = pkgs.mkShell {
              packages = [
                pythonEnv

                pkgs.git
                pkgs.dvc

                pkgs.postgresql
                pkgs.sqlite
                pkgs.jq
                pkgs.coreutils
                pkgs.gnumake
              ];

              env = {
                PIP_DISABLE_PIP_VERSION_CHECK = "1";
                PYTHONUNBUFFERED = "1";
              };

              shellHook = ''
                echo "[data-shell] ${system}"
                python --version
              '';
            };
          });
    in {
      devShells = forAllSystems;
    };
}
