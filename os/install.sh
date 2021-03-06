# Open hammerspoon
open -a Hammerspoon

# Use hammerspoon configuration
curl -o ~/.hammerspoon/init.lua https://gist.githubusercontent.com/cesalberca/bf06aa9c10b3cfa648284e2ffb7d09c2/raw/31d238ee7b47d06e6cb01f1a803636a2c2a300a4/init.lua

# Configure iTerm2 profile
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string $HOME/.dotfiles/plugins/dotfiles-cesalberca/iterm2
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# Create hushlogin
touch ~/.hushlogin

# Install sdkman
curl -s "https://get.sdkman.io" | bash

# Install oh my zsh
if [[ ! -d ~/.oh-my-zsh ]]; then
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Change MacOS configuration
source $HOME/.dotfiles/plugins/dotfiles-cesalberca/os/.macos

# Login to iCloud
mas signin cesalberca@gmail.com

# Install app store's apps
mas install 1263070803 # Lungo
