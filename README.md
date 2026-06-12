# kurushimee dotfiles

## WSL setup

1. `sudo apt update && sudo apt upgrade -y`
2. `sudo apt install -y git gh curl wget unzip ripgrep fd-find jq python3-full pip pipx build-essential wl-clipboard wslu`
3. `sudo snap install --classic helix`

### Node

1. `curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -`
2. `sudo apt-get install -y nodejs`
3. `sudo npm i -g npm`
4. **Bun:** `curl -fsSL https://bun.sh/install | bash`

### Rust

- `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

### LSP / formatters / linters

- **Generic:** `sudo npm i -g vscode-langservers-extracted`
- **GitHub Actions:** `sudo npm i -g gh-actions-language-server`
- **JavaScript/TypeScript:** `sudo npm i -g typescript typescript-language-server`
- **Markdown:** `sudo snap install marksman`
- **Python:** `sudo apt-get install -y python3-pylsp && pipx install black`
- **Rust:** `rustup component add rust-analyzer && rustup component add clippy`
- **Shell:** `sudo npm i -g bash-language-server && sudo snap install shellcheck shfmt`
- **TOML:** `cargo install taplo-cli --locked --features lsp`

### Codex

1. `sudo apt update`
2. `sudo apt install -y bubblewrap apparmor-profiles apparmor-utils`
3. `sudo install -m 0644 /usr/share/apparmor/extra-profiles/bwrap-userns-restrict /etc/apparmor.d/bwrap-userns-restrict`
4. `sudo apparmor_parser -r /etc/apparmor.d/bwrap-userns-restrict`
5. `sudo systemctl reload apparmor.service`
