{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
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
    mkdir -p "$DEVENV_DIR/data"
    mkdir -p "$DEVENV_DIR/state"

    export XDG_CONFIG_HOME="$DEVENV_DIR/config"
    export XDG_DATA_HOME="$DEVENV_DIR/data"
    export XDG_STATE_HOME="$DEVENV_DIR/state"
    export ZDOTDIR="$DEVENV_DIR/config/zsh"

    export TMUX_CONF="$DEVENV_DIR/config/tmux/tmux.conf"
    alias tmux="tmux -f $TMUX_CONF"

    export SHELL=${pkgs.zsh}/bin/zsh

    echo "Configurations loaded from: $DEVENV_DIR/config"
    echo "Data stored in: $DEVENV_DIR/data"
    echo ""

    if [ -z "$ZSH_VERSION" ]; then
      exec ${pkgs.zsh}/bin/zsh
    fi
  '';

  RUST_BACKTRACE = "1";
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}
