{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-home = {
      url = "github:bells307/nix-home";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nix-home }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        devConfigs = pkgs.buildEnv {
          name = "dev-configs";
          paths = [
            (pkgs.runCommand "nvim-config" {} ''
              mkdir -p $out/nvim
              cp -r ${nix-home}/nvim/nvim/* $out/nvim/
            '')
            (pkgs.runCommand "tmux-config" {} ''
              mkdir -p $out/tmux
              cp ${nix-home}/tmux/tmux.conf $out/tmux/
            '')
            (pkgs.runCommand "zsh-config" {} ''
              mkdir -p $out/zsh
              cp ${nix-home}/zsh/zshrc $out/zsh/.zshrc
            '')
            (pkgs.runCommand "lazygit-config" {} ''
              mkdir -p $out/lazygit
              cat > $out/lazygit/config.yml << 'EOF'
              gui:
                theme:
                  lightTheme: false
                  activeBorderColor:
                    - green
                    - bold
                  inactiveBorderColor:
                    - white
                  selectedLineBgColor:
                    - blue
              git:
                pagers:
                  diff: delta --dark --paging=never
                  log: delta --dark --paging=never
              EOF
            '')
          ];
        };
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
            yazi
          ];

          shellHook = ''
            export DEVENV_DIR="$PWD"

            mkdir -p "$DEVENV_DIR/data"
            mkdir -p "$DEVENV_DIR/state"

            # Используем конфигурации из nix store напрямую
            export XDG_CONFIG_HOME="${devConfigs}"
            export XDG_DATA_HOME="$DEVENV_DIR/data"
            export XDG_STATE_HOME="$DEVENV_DIR/state"
            export ZDOTDIR="${devConfigs}/zsh"

            export TMUX_CONF="${devConfigs}/tmux/tmux.conf"
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
