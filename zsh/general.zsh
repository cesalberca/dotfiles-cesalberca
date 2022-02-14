# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_DISABLE_COMPFIX=true
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME=powerlevel10k/powerlevel10k
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

