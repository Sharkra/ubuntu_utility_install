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

####################################### START #####################################

sudo apt update
sudo apt -y upgrade
echo_blue "Installing Utility"
if checkPackagesInstalled guake \
                          terminator \
                          gdebi \
                          git \
                          gksu \
                          unity-tweak-tool \
                          redshift \
                          redshift-gtk;
then
  echo_green "Utility stuff already installed"
else
  sudo apt install -y guake \
                      terminator \
                      gdebi \
                      git \
                      gksu \
                      unity-tweak-tool \
                      redshift \
                      redshift-gtk;
fi

############  ATOM ##################
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

######## Hardware Monitoring ############
echo_blue "Installing Hardware Monitoring"
if checkPackagesInstalled indicator-multiload \
                          lm-sensors \
                          hddtemp \
                          psensor;
then
  echo_green "Already Installed"
else
  sudo apt update
  sudo apt install -y indicator-multiload \
                      lm-sensors \
                      hddtemp \
                      psensor;
fi

############## Git Aware Prompt ###################
echo_blue "Installing Git Aware Prompt"
if [ ! -d "$HOME/.bash" ]; then
    mkdir -p $HOME/.bash
fi
cd $HOME/.bash
if [ ! -d git-aware-prompt ]; then
  git clone git://github.com/jimeh/git-aware-prompt.git
fi

exportToBashrc "export GITAWAREPROMPT=~/.bash/git-aware-prompt"
exportToBashrc source \${GITAWAREPROMPT}/main.sh
exportToBashrc "export PS1=\"\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \[\$txtcyn\]\$git_branch\[\$txtred\]\$git_dirty\[\$txtrst\]\$\""

############# IMAGE STUFF ######################
echo_blue "Installing Image Stuff"
if checkPackagesInstalled krita \
                          rawtherapee \
                          vlc \
                          openshot-qt;
then
  echo_green "Image stuff already installed"
else
  if checkRepoExists openshot; then
    echo "Repository Exists. Not adding again"
  else
    sudo add-apt-repository ppa:openshot.developers/ppa
    sudo apt update
  fi
  sudo apt install -y krita \
                      rawtherapee \
                      vlc \
                      openshot-qt;
fi

############## Chat STUFF #################
echo_blue "Installing Chat Stuff"
if checkPackagesInstalled slack-desktop;
then
  echo_green "Slack stuff already installed"
else
  cd /tmp
  wget https://downloads.slack-edge.com/linux_releases/slack-desktop-3.0.5-amd64.deb
  sudo dpkg -i slack-desktop-3.0.5-amd64.deb
  sudo apt install -f
fi
if checkPackagesInstalled skypeforlinux;
then
  echo_green "Skype already installed"
else
  cd /tmp
  wget https://go.skype.com/skypeforlinux-64.deb
  sudo dpkg -i skypeforlinux-64.deb
  sudo apt install -f
fi

#################### Chrome install #######################
echo_blue "Installing Chrome"
if checkPackagesInstalled google-chrome-stable;
then
  echo_green "Chrome stuff already installed"
else
  cd /tmp
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb
  sudo apt install -f;
fi


################## MagicWormhole ##################
echo_blue "Installing MagicWormhole"
if pip show magic-wormhole > /dev/null 2 | grep -q magic-wormhole; then
  echo_green "Already installed"
else
  if checkPackagesInstalled python-pip build-essential python-dev libffi-dev libssl-dev;
  then
    echo_green "MagicWormhole stuff already installed"
  else
    sudo apt-get install python-pip build-essential python-dev libffi-dev libssl-dev
    pip install --upgrade pip
    sudo pip install magic-wormhole
    exportToBashrc "alias wormhole-send=\"\$HOME/.local/bin/wormhole send\""
    exportToBashrc "alias wormhole-receive=\"\$HOME/.local/bin/wormhole receive\" "
  fi
fi

############# Spotify ######################
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

#################### VisualStudioCode install #######################
echo_blue "Installing VisualStudioCode"
if [ -d "\$HOME/Programs/VSCode-linux-x64" ];
then
  echo_green "VisualStudioCode stuff already installed"
else
  if [ ! -d "$HOME/Programs" ]; then
      mkdir -p $HOME/Programs
  fi
  cd /tmp
  if [ ! -f VisualStudioCode ]; then
    wget -O VisualStudioCode https://go.microsoft.com/fwlink/?LinkID=620884
  fi
  tar -xf VisualStudioCode -C $HOME/Programs
  sudo ln -s $HOME/Programs/VSCode-linux-x64 /usr/local/bin/vcode
fi
