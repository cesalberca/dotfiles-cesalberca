# Create hushlogin
touch ~/.hushlogin

# Install sdkman
curl -s "https://get.sdkman.io" | bash

# Install oh my zsh
if [[ ! -d ~/.oh-my-zsh ]]; then
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Change MacOS configuration
source $HOME/.dotfiles/plugins/dotfiles-cesalberca/os/.macos

# Login to iCloud
mas signin cesalberca@gmail.com

# Install app store's apps
mas install 1263070803 # Lungo
