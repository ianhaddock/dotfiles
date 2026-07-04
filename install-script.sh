#!/bin/zsh
set -e

INSTALL_LIST="brew-install-list.txt"
DOTFILE_PATH="/Users/${USER}/Developer/dotfiles"
INSTALL_VERSION="v0.1.1"

last_installed=$(defaults read NSGlobalDomain IHScriptInstallDate)
last_installed_version=$(defaults read NSGlobalDomain IHScriptVersion)
install_date=$(date +"%Y-%m-%d %l:%M:%S +0000")
ask_to_continue=1

function usage() {
    echo ""
    echo "### This script will setup a MacOS environment for username '${USER}'."
    echo ""
    echo "This script will:"
    echo "* Install or update Homebrew and applications from ${INSTALL_LIST}"
    echo "* Install or update oh-my-zsh"
    echo "* Install dotfile config files"
    echo "* Create Developer directory and subdirectories" 
    echo "* Update Finder settings"
    echo ""
    echo "Administrator password may be required."
    echo ""
    echo "### Version: ${INSTALL_VERSION}"
    echo ""
}

if [ EUID = 0 ]; then
    echo "ERROR: This script should not be run as root. Exiting." ;
    exit 1;
fi

while getopts ":yr" opt; do
    case $opt in
        y)
            ask_to_continue=0
            ;;
        r)
            last_installed_version=""
            ;;
        \?)
            usage;
            echo "ERROR: Invalid option -$OPTARG"
            echo ""
            exit 1;
            ;;
    esac
done

if (( ask_to_continue )); then
    usage;
    if [ -n "$last_installed_version" ] ; then
      echo "WARNING: Version ${last_installed_version} was previously installed on: ${last_installed}"
      echo ""
    fi

    vared -p "Continue? <Y/n>: " -c answer
       if [ ! ${answer} = "Y" ] && [ ! ${answer} = "y" ]; then
           echo ""
           echo "Exiting."
           exit 1
       fi
fi

echo ""
echo "### Configure Homebrew:"
if ! command -v brew >/dev/null 2>&1 ; then
   echo "* Homebrew not found. Installing."
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   echo "* Homebrew installed, adding user profile"
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > /Users/${USER}/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   source ~/.zprofile
else
   echo "* Homebrew found. Updating."
   brew update
   brew upgrade
   brew cleanup
fi
echo "* Install apps:"
xargs brew install --quiet < ${INSTALL_LIST} 
sleep 1

echo ""
echo "### Configuring oh-my-zsh:"
if [ ! -d /Users/${USER}/.oh-my-zsh ]; then
  echo "* Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "* oh-my-zsh already installed. Updating."
  /Users/${USER}/.oh-my-zsh/tools/upgrade.sh -v silent
fi
sleep 1

echo ""
echo "### Apple Store: MAS"
echo "* update installed apps"
mas update
echo "* install apps"
# regex is for lines that start and end with numbers only
grep -G '^[0-9]*$' mas-install-list.txt | xargs -I {} mas get {}

echo ""
if ! pgrep oahd >/dev/null 2>&1 ; then
    echo "### Installing Rosetta"
    sudo softwareupdate --install-rosetta --agree-to-license
else
    echo "### Rosetta already installed"
fi

echo ""
echo "### Configuring dotfiles:"
if [ ! -f ~/.vim/autoload/plug.vim ]; then 
  echo "* Installing VIM Plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
if [ ! -d ${DOTFILE_PATH} ]; then
    echo "* Creating ${DOTFILE_PATH} directory"
    mkdir -pv ${DOTFILE_PATH} 
fi
if [ ! -f ${DOTFILE_PATH}/.zshrc ]; then
    echo "* Copying .zshrc file to dotfiles directory"
    cp -v ./.zshrc ${DOTFILE_PATH}
fi
if [ ! -f /Users/${USER}/.zshrc ]; then
    echo "* Linking .zshrc from dotfiles to home directory"
    cp -sv ${DOTFILE_PATH}/.zshrc /Users/${USER}/.zshrc
fi
if [ ! -f ${DOTFILE_PATH}/.vimrc ]; then
    echo "* Copying .vimrc files to dotfiles directory"
    cp -v ./.vimrc ${DOTFILE_PATH}
fi
if [ ! -f /Users/${USER}/.vimrc ]; then
    echo "* Linking .vimrc from dotfiles to home directory"
    cp -sv ${DOTFILE_PATH}/.vimrc /Users/${USER}/.vimrc
fi
if [ ! -f ${DOTFILE_PATH}/.screenrc ]; then
    echo "* Add screen config"
    cp -v ./.screenrc ${DOTFILE_PATH}/.screenrc
    cp -sv ${DOTFILE_PATH}/.screenrc /Users/${USER}/.screenrc
fi
if [ ! -f ${DOTFILE_PATH}/.screen_layout ]; then
    echo "* add screen layout"
    cp -v ./.screen_layout ${DOTFILE_PATH}/.screen_layout
    cp -sv ${DOTFILE_PATH}/.screen_layout /Users/${USER}/.screen_layout
fi

echo ""
echo "### Creating directories:"
mkdir -p /Users/${USER}/Developer/logs-iterm2

echo ""
echo "### Export current com.apple.finder config"
mkdir -pv ./finder-config-backups
defaults export com.apple.Finder ./finder-config-backups/com.apple.finder.defaults_$(date +%Y-%m-%d_%H%M%S)

echo ""
echo "### Login screen settings:"
echo "* Set login text"
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "all that is gold does not glitter, not all who wander are lost"

echo ""
echo "### Keyboard and smart text settings:"
echo "* Setting key repeat"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
echo "* Disable automatic capitalization, double-space is period, automatic spelling correction"
defaults write NSAutomaticCapitalizationEnabled -int 0
defaults write NSAutomaticPeriodSubstitutionEnabled -int 0
defaults write NSAutomaticQuoteSubstitutionEnabled -int 0
defaults write NSAutomaticSpellingCorrectionEnabled -int 0

echo ""
echo "### Finder views:"
echo "* Search current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo ""
echo "### Finder settings:"
echo "* show all extensions"
defaults write AppleShowAllExtensions -bool true
echo "* Dont warn on empty trash"
defaults write com.apple.finder WarnOnEmptyTrash -int 0
echo "* Dont show media on desktop."
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -int 0
defaults write com.apple.finder ShowHardDrivesOnDesktop -int 0
defaults write com.apple.finder ShowMountedServersOnDesktop -int 0
defaults write com.apple.finder ShowRemovableMediaOnDesktop -int 0
echo "* Keep application windows on quit"
defaults write com.apple.NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true
echo "* Set alert sound to Funky"
defaults write NSGlobalDomain com.apple.sound.beep.sound "/System/Library/Sounds/Funk.aiff"

echo ""
echo "### Finder window options:"
echo "* show pathbar"
defaults write com.apple.finder ShowPathbar -int 1
echo "* show statusbar"
defaults write com.apple.finder ShowStatusBar -int 1
echo "* show previewpane"
defaults write com.apple.finder ShowPreviewPane -int 1
echo "* hide recent tags"
defaults write com.apple.finder ShowRecentTags -int 0
echo "* Always open in column view"
defaults write com.apple.finder AlwaysOpenWindowsInColumnView -int 1
echo "* Set new windows open to home directory"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
echo "* Expand save window by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
sleep 1

echo ""
echo "### Configure Timemachine:"
echo "* do not prompt to use new hard drives as timemachine targets"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo ""
echo "### Configure the Dock:"
echo "* Set tile size to 48"
defaults write com.apple.Dock tilesize -int 48
echo "* Do not show recents"
defaults write com.apple.dock "show-recents" -int 0
echo "* Enable autohide with 0 delay"
defaults write com.apple.Dock autohide -bool true
defaults write com.apple.Dock autohide-delay -float 0
echo "* Remove defaults"
dockutil -r all
sleep 1   # required to make sure all defaults are removed
echo "* Add System Settings"
dockutil -a /System/Applications/System\ Settings.app
echo "* Display Downloads folder as stack"
dockutil --display stack -a ~/Downloads
sleep 1

echo ""
echo "### Finishing up"
echo "* setting install date ${install_date}"
defaults write NSGlobalDomain IHScriptInstallDate -date "${install_date}"
echo "* setting install version ${INSTALL_VERSION}"
defaults write NSGlobalDomain IHScriptVersion -string "${INSTALL_VERSION}"
echo ""
echo "Done."
echo ""
exit 0
