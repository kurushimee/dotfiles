# kurushimee dotfiles

## WSL setup

```bash
sudo apt update && sudo apt upgrade -y
```

### Fix VPN

WSL HTTPS streams may stall/time out when using a VPN in tun mode on Windows. WSL’s Linux TCP path is basically intermittently breaking. To fix:

```bash
sudo tee /etc/sysctl.d/99-wsl-tcp-timeout-workaround.conf >/dev/null <<'EOF'
net.ipv4.tcp_timestamps = 0
EOF

sudo sysctl --system
```

Additionally, if this doesn't persist, can try adding to `/etc/wsl.conf`:
```
[boot]
systemd=true
command=sysctl -w net.ipv4.tcp_timestamps=0
```

### Essentials

```bash
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

### Pi

Note on `observational-memory` extension: if using a `fireworks`-provider model, you HAVE to `/login` into fireworks and manually enter your API key, so that it is saved in `auth.json`. This is what I've found to be the case, it ignores the environment variable and errors out otherwise.
