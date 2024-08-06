# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="eastwood"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export EDITOR='hx'

export HELIX_RUNTIME='~/src/helix/runtime'

path+=('/home/kurushimee/.local/bin')
export PATH
