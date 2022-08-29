ZSH_DISABLE_COMPFIX=true
export ZSH=$HOME/.oh-my-zsh

setopt GLOB_DOTS

plugins=(git npm zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

export PATH=/usr/local/bin:/usr/local/sbin:~/bin:$PATH
export EDITOR="/usr/local/Cellar/micro/2.0.8/bin/micro"

# Disable sharing history in iTerm2
unsetopt inc_append_history
unsetopt share_history

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

