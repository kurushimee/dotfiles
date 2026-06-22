# kurushimee dotfiles

## WSL setup

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git gh curl wget zstd zip unzip ripgrep fd-find jq python3-full pip pipx build-essential wl-clipboard wslu
sudo snap install --classic helix
```

### NodeJS & Bun

```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm i -g npm
curl -fsSL https://bun.sh/install | bash
```

### Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### LSP / formatters / linters

- **Generic:** `bun a -g vscode-langservers-extracted`
- **JavaScript/TypeScript:** `bun a -g typescript typescript-language-server`
- **Markdown:** `sudo snap install marksman`
- **Python:** `sudo apt-get install -y python3-pylsp && pipx install black`
- **Rust:** `rustup component add rust-analyzer && rustup component add clippy`
- **Shell:** `bun a -g bash-language-server && sudo snap install shellcheck shfmt`
- **TOML:** `cargo install taplo-cli --locked --features lsp`
- **YAML:** `bun a -g yaml-language-server@next`

### Codex

```bash
sudo apt update
sudo apt install -y bubblewrap apparmor-profiles apparmor-utils
sudo install -m 0644 /usr/share/apparmor/extra-profiles/bwrap-userns-restrict /etc/apparmor.d/bwrap-userns-restrict
sudo apparmor_parser -r /etc/apparmor.d/bwrap-userns-restrict
sudo systemctl reload apparmor.service
```
