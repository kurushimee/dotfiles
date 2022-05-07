if status is-interactive
    # Nix configuration.
    fenv source $HOME/.nix-profile/etc/profile.d/nix.sh
    fenv export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels{NIX_PATH:+:$NIX_PATH}
    fenv source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh

    # Enable Starship prompt.
    starship init fish | source

    # Neovim alias for vim.
    alias vim="nvim"
end
