# Open hammerspoon
open -a Hammerspoon

# Use hammerspoon configuration
curl -o ~/.hammerspoon/init.lua https://gist.githubusercontent.com/cesalberca/bf06aa9c10b3cfa648284e2ffb7d09c2/raw/31d238ee7b47d06e6cb01f1a803636a2c2a300a4/init.lua

# Configure iTerm2 profile
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/iterm2"
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

# Install LTS Node
nvm install "lts/*"

# Change MacOS configuration
source $HOME/.dotfiles/plugins/dotfiles-cesalberca/os/.macos

# Login to iCloud
mas signin cesalberca@gmail.com

# Install app store's apps
mas install 1263070803 # Lungo

# Obtain  vendor and product ID for bluetooth device attached.
# Explanation:
# system_profiler SPBluetoothDataType       -- json show system specifications of the bluetooth in Json Format. To check all list can use system_profiler -listDataTypes
# grep -e                                   -- filter for both productID and vendor ID. Values are in Hexadecimal
# grep -o -e "\"0.*\""                      -- delete the 0x of Hexadecimal values
# tr -d '"'                                 -- delete the quotes remaining from the json output
# xargs -L1 printf "%d\n" {} 2>/dev/null    -- get all arguments from the previous filters and convert to hexadecimal, ensuring that all the error output goes to /dev/null
# grep -v 0                                 -- filter remaining 0 in the output to just get the desired ID
function get_bluetooth_device_info() {
    KEY_TO_FILTER=$1
    echo $(system_profiler SPBluetoothDataType -json 2>/dev/null | grep -e $KEY_TO_FILTER| grep -o -e "\"0.*\"" | tr -d '"' | xargs -L1 printf "%d\n" {} 2>/dev/null | grep -v 0)
}

# Obtain  vendor and product ID for bluetooth device attached.
# Explanation:
# ioreg -p IOUSB -c IOUSBDevice             -- information about mac USB devices
# grep -e class -e idVendor -e idProduct    -- filter for class, vendor and product
# grep -A2 "Apple Internal Keyboard"        -- filter for apple internal keyboard and two lines for the filtered vendor and product
# grep -o -e "$KEY_TO_FILTER.*$"            -- filter for the device information required
# grep -o -e \d+                            -- filter for getting just the number
function get_keyboard_device_info() {
    KEY_TO_FILTER=$1
    ioreg -p IOUSB -c IOUSBDevice | grep -e class -e idVendor -e idProduct| grep -A2 "Apple Internal Keyboard" | grep -o -e "$KEY_TO_FILTER.*$" | grep -o -e "\d\+"
}

function change_caps_lock_to_control() {
    VENDOR_ID=$1
    PRODUCT_ID=$2

    CAPS_LOCK_KEY_ID=30064771300
    CONTROL_KEY_ID=30064771129

    blue "Read current configuration of your keyboard"
    defaults -currentHost read -g | grep -e "$VENDOR_ID-$PRODUCT_ID"
    STATUS=$?
    if [[ $STATUS == 0 ]];
    then
        green "This device is already configured"
    else
        blue "Change Caps Lock to Control in bluetooth keyboard"
        defaults -currentHost write -g com.apple.keyboard.modifiermapping.$VENDOR_ID-$PRODUCT_ID-0 -array-add "<dict><key>HIDKeyboardModifierMappingDst</key><integer>$CAPS_LOCK_KEY_ID</integer><key>HIDKeyboardModifierMappingSrc</key><integer>$CONTROL_KEY_ID</integer></dict>"
        red "========================================="
        green "Success! This actions required restart"
        red "========================================="
    fi
}

# More information: https://apple.stackexchange.com/questions/13598/updating-modifier-key-mappings-through-defaults-command-tool
function change_caplock_to_control_in_keyboards() {

    BT_VENDOR_ID=$(get_bluetooth_device_info "device_vendorID")
    BT_PRODUCT_ID=$(get_bluetooth_device_info "device_productID")
    change_caps_lock_to_control $BT_VENDOR_ID $BT_PRODUCT_ID

    KEYBOARD_VENDOR_ID=$(get_keyboard_device_info "idVendor")
    KEYBOARD_PRODUCT_ID=$(get_keyboard_device_info "idProduct")
    change_caps_lock_to_control $KEYBOARD_VENDOR_ID $KEYBOARD_PRODUCT_ID
}

change_caplock_to_control_in_keyboards