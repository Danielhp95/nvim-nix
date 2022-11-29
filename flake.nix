{
  description = "Sarios's nvim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix2vim.url = "github:gytis-ivaskevicius/nix2vim";
    nix2vim.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { nixpkgs, nix2vim, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {allowUnfree = true;};
      overlays = [
        nix2vim.overlay
        (import ./overlays/default.nix)
      ];
    };
    neovimConfig = import ./neovim-pkg.nix {
      inherit pkgs;
      dsl = nix2vim.outputs.lib.dsl;
    };

  in rec {
    apps.${system} = rec {
      nvim = {
        type = "app";
        program = "${packages.${system}.default}/bin/nvim";
      };
      default = nvim;
    };

    devShells.${system} = {
      default = pkgs.mkShell {
        buildInputs = [(pkgs.neovimBuilder neovimConfig)];
      };
    };

    overlays.default = final: prev: {
      neovimSarios = packages.${system}.neovimSarios;
      #  neovimPlugins = pkgs.neovimPlugins; What do do about this?
    };

    packages.${system} = rec {
      default = neovimSarios;
      neovimSarios = (pkgs.neovimBuilder neovimConfig);
    };
  };
}
