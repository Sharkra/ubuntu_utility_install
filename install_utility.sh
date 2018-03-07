#!/bin/bash

function echo_green() { echo -e "\033[1;32m$1\033[0m"; }
function echo_red() { echo -e "\033[1;31m$1\033[0m"; }
function echo_blue() { echo -e "\033[1;34m$1\033[0m"; }

function checkPackagesInstalled() {
  if dpkg -s "$@" > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

function checkRepoExists() {
  if ls /etc/apt/sources.list.d | grep -q ".*${1}.*"; then
    return 0
  else
    return 1
  fi
}

function exportToBashrc() {
    if grep -F -q -x "$@" $HOME/.bashrc; then
        echo_green "Path already in bash. Not echoing it in."
    else
        echo_red "Path not in bash. Echo it into bashrc."
        echo "$@" >> $HOME/.bashrc
    fi
    source $HOME/.bashrc
}

function installPackages() {
  if checkPackagesInstalled "$@"; then
    echo_green "Package(s) Installed"
  else
    echo_blue "Installing \"$@\""
    sudo apt install -y "$@"
  fi
}

function installDebPackage(){

  if checkPackagesInstalled "$1"; then
    echo_green "Package Installed"
  else
    echo_blue "Downloading $1"
    cd /tmp
    wget "$2" -O "$1".deb
    echo_blue "Installing $1"
    sudo dpkg -i "$1".deb
    sudo apt install -f
  fi
}

###################################################################################
############ START ################################################################
###################################################################################

sudo apt update
sudo apt -y upgrade

############ Utility ############
echo_blue "Installing Utility"
installPackages guake \
                terminator \
                gdebi \
                git \
                gksu \
                unity-tweak-tool \
                redshift \
                redshift-gtk;

############ Hardware Monitoring ############
echo_blue "Installing Hardware Monitoring"
installPackages indicator-multiload \
                lm-sensors \
                hddtemp \
                psensor;

############  ATOM ############
echo_blue "Installing Atom"
if checkPackagesInstalled atom; then
  echo_green "Already Installed"
else
  if checkRepoExists atom; then
    echo "Repository Exists. Not adding again"
  else
    sudo add-apt-repository ppa:webupd8team/atom;
    sudo apt update
  fi
  sudo apt install -y atom;
fi

############ Git Aware Prompt ############
echo_blue "Installing Git Aware Prompt"
if [ ! -d "$HOME/.bash" ]; then
    mkdir -p $HOME/.bash
fi
cd $HOME/.bash
if [ ! -d git-aware-prompt ]; then
  git clone git://github.com/jimeh/git-aware-prompt.git
fi

exportToBashrc "export GITAWAREPROMPT=\$HOME/.bash/git-aware-prompt"
exportToBashrc "source \${GITAWAREPROMPT}/main.sh"
exportToBashrc "export PS1=\"\\\${debian_chroot:+(\\\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \[\\\$txtcyn\]\\\$git_branch\[\\\$txtred\]\\\$git_dirty\[\\\$txtrst\]\\\$\""

############ IMAGE STUFF ############
echo_blue "Installing Image Stuff"
installPackages krita \
                rawtherapee \
                vlc

if checkPackagesInstalled openshot-qt;
then
  echo_green "Image stuff already installed"
else
  if checkRepoExists openshot; then
    echo "Repository Exists. Not adding again"
  else
    sudo add-apt-repository ppa:openshot.developers/ppa
    sudo apt update
  fi
  sudo apt install -y openshot-qt;
fi

############ Chat STUFF ############
echo_blue "Installing Chat Stuff"
installDebPackage slack-desktop https://downloads.slack-edge.com/linux_releases/slack-desktop-3.0.5-amd64.deb
installDebPackage skypeforlinux https://go.skype.com/skypeforlinux-64.deb

############ Chrome install ############
echo_blue "Installing Chrome"
installDebPackage google-chrome-stable https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

############ MagicWormhole ############
echo_blue "Installing MagicWormhole"
if pip show magic-wormhole > /dev/null 2 | grep -q magic-wormhole; then
  echo_green "Already installed"
else
  if checkPackagesInstalled python-pip build-essential python-dev libffi-dev libssl-dev;
  then
    echo_green "MagicWormhole already installed"
  else
    sudo apt-get install python-pip build-essential python-dev libffi-dev libssl-dev
    pip install --upgrade pip
    sudo pip install magic-wormhole
    exportToBashrc "alias wormhole-send=\"\$HOME/.local/bin/wormhole send\""
    exportToBashrc "alias wormhole-receive=\"\$HOME/.local/bin/wormhole receive\" "
  fi
fi

############ Spotify ############
echo_blue "Installing Spotify"
if checkPackagesInstalled spotify-client;
then
  echo_green "Spotify already installed"
else
  if checkRepoExists spotify; then
    echo "Repository Exists. Not adding again"
  else
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
  fi
  sudo apt install -y spotify-client;
fi

############ VisualStudioCode install ############

echo_blue "Installing VisualStudioCode"
installDebPackage code https://go.microsoft.com/fwlink/?LinkID=760868
