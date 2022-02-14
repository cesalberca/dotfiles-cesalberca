alias gl="git log --all --decorate --oneline --graph"
alias gs="git status"
alias ll="ls -FGlAhp"
cd() { builtin cd "$@"; ls; }
alias cd..="cd ../"
alias ~="cd ~"
alias c="clear"
alias ip='ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk "{print $2}"'
alias publicIp="curl https://ipinfo.io/ip"
trash () { command mv "$@" ~/.Trash; }
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
alias work="cd ~/Workspace"
alias tmp="cd ~/Tmp"
alias typora="open -a typora"
alias python="python3"
alias webstorm="~/webstorm"