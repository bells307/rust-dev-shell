{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "rust-dev-shell";

          buildInputs = with pkgs; [
            rustc
            cargo
            rust-analyzer
            rustfmt
            clippy
            neovim
            tmux
            zsh
            git
            fzf
            zoxide
            lazygit
            just
            stylua
            nil
            taplo
            curl
          ];

          shellHook = ''
            export DEVENV_DIR="$PWD"

            mkdir -p "$DEVENV_DIR/data"
            mkdir -p "$DEVENV_DIR/state"

            export XDG_CONFIG_HOME="$DEVENV_DIR/config"
            export XDG_DATA_HOME="$DEVENV_DIR/data"
            export XDG_STATE_HOME="$DEVENV_DIR/state"
            export ZDOTDIR="$DEVENV_DIR/config/zsh"

            export TMUX_CONF="$DEVENV_DIR/config/tmux/tmux.conf"
            alias tmux="tmux -f $TMUX_CONF"

            export SHELL=${pkgs.zsh}/bin/zsh

            if [ -z "$ZSH_VERSION" ]; then
              exec ${pkgs.zsh}/bin/zsh
            fi
          '';

          RUST_BACKTRACE = "1";
          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
        };
      }
    );
}
