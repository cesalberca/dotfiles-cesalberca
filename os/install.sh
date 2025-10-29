# Create hushlogin
touch ~/.hushlogin

# Install oh my zsh
if [[ ! -d ~/.oh-my-zsh ]]; then
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Add 1password SSH keys
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Change MacOS configuration
source $HOME/.dotfiles/plugins/dotfiles-cesalberca/os/.macos

# Install app store's apps
mas install 1263070803 # Lungo
