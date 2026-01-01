# Dotfiles

Script to install Homebrew, apps, oh-my-zsh, dotfiles, create directories, and adjust MacOS settings to my prefernces.

### Config files

* .vimrc
* .screenrc
* .bash_profile
* brew-installed.txt

## Install

* Enable full disk access for terminal app to allow changes to universalaccess:
  - `System Settings -> Privacy & Security -> Fill Disk Access`
* Chmod `0744` or `+x` `install-script.sh` and run it
* Administrator password required to install Homebrew

### Notes

* To reset Dock for testing `defaults delete com.apple.dock; killall Dock`
* When manually changing Dock settings, clear preferences cache and restart dock to see changes
  - `killall cfprefsd`
  - `killall Dock`

### Applications not in brew

* MakeMKV

### ToDo

* add Developer directory to sidebar
* add home directory to sidebar
* set FK_DefaultListViewSettings -> calculateAllSizes -> true
* set computername `sudo systemsetup -setcomputername`
