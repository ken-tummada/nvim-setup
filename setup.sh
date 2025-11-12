#!usr/bin/sh

mkdir "$HOME/tmp"

curl -L -o "$HOME/tmp/nvim.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

mkdir -p "$HOME/.local"

tar -xzf "$HOME/tmp/nvim.tar.gz" -C "$HOME/.local" --strip-components=1

export PATH="$HOME/.local/bin:$PATH"

echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"

rm "$HOME/tmp/nvim.tar.gz"

mkdir -p "$HOME/.config/nvim"

ln -s ./init.lua "$HOME/.config/nvim/init.lua"
