#! /usr/bin/env bash
set -e
###########################################################################
#
# Chromium Bootstrap Installer
# https://github.com/polymimetic/ansible-role-chromium
#
# This script is intended to replicate the ansible role in a shell script
# format. It can be useful for debugging purposes or as a quick installer
# when it is inconvenient or impractical to run the ansible playbook.
#
# Usage:
# wget -qO - https://raw.githubusercontent.com/polymimetic/ansible-role-chromium/master/install.sh | bash
#
###########################################################################

if [ `id -u` = 0 ]; then
  printf "\033[1;31mThis script must NOT be run as root\033[0m\n" 1>&2
  exit 1
fi

###########################################################################
# Constants and Global Variables
###########################################################################

readonly GIT_REPO="https://github.com/polymimetic/ansible-role-chromium.git"
readonly GIT_RAW="https://raw.githubusercontent.com/polymimetic/ansible-role-chromium/master"

###########################################################################
# Basic Functions
###########################################################################

# Output Echoes
# https://github.com/cowboy/dotfiles
function e_error()   { echo -e "\033[1;31m✖  $@\033[0m";     }      # red
function e_success() { echo -e "\033[1;32m✔  $@\033[0m";     }      # green
function e_info()    { echo -e "\033[1;34m$@\033[0m";        }      # blue
function e_title()   { echo -e "\033[1;35m$@.......\033[0m"; }      # magenta

###########################################################################
# Install Chromium
# https://www.chromium.org/Home
#
# http://www.chromium.org/administrators/linux-quick-start
# http://www.chromium.org/administrators/policy-list-3
# https://www.chromium.org/administrators/configuring-other-preferences
# http://www.chromium.org/developers/how-tos/run-chromium-with-flags
# https://askubuntu.com/questions/743894/how-do-i-automatically-apply-the-same-theme-to-chromium-for-all-new-users
# https://decentraleyes.org/configure-https-everywhere/
###########################################################################

install_chromium() {
  e_title "Installing Chromium"

  local chromium_files="${SCRIPT_PATH}/files/chromium"

  local chromium_extensions=(
    cjpalhdlnbpafiamejdnhcphjbkeiagm # uBlock
    pgdnlhfefecpicbbihgmbmffkjpaplco # uBlock extra
    hdokiejnpimakedhajhdlcegeplioahd # Lastpass
    # nngceckbapebfimnlniiiahkandclblb # Bitwarden
    bcjindcccaagfpapjjmafapmmgkkhgoa # JSON Formatter
    fhbjgbiflinjbdggehcddcbncdddomop # Postman
    bhlhnicpbhignbdhedgjhgdocnmhomnp # ColorZilla
    gcbommkclmclpchllfjekcdonpmejbdp # HTTPs Everywhere
    pkehgijcmpdhfbdbbnkijodmdjhbjlgp # Privacy Badger
    ldpochfccmkkmhdbclfhpagapcfdljkj # DecentralEyes
  )

  # Install Chromium
  sudo apt-get install -yq chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg-extra

  # Configure chromium preferences
  if [[ -d "${HOME}/.config/chromium/Default"  ]]; then
    rm -r "${HOME}/.config/chromium/Default"
  fi
  mkdir -p "${HOME}/.config/chromium/Default"
  cp "${chromium_files}/Preferences" "${HOME}/.config/chromium/Default"

  # Configure chromium policies
  if [[ ! -d "/etc/chromium-browser/policies/recommended" ]]; then
    sudo mkdir -p "/etc/chromium-browser/policies/recommended"
  fi
  sudo cp "${chromium_files}/user-policy.json" "/etc/chromium-browser/policies/recommended"

  # Configure chromium extensions
  if [[ ! -d "/usr/share/chromium-browser/extensions" ]]; then
    sudo mkdir -p "/usr/share/chromium-browser/extensions"
  fi

  for i in ${chromium_extensions}; do
    sudo cp "${chromium_files}/extension.json" "/usr/share/chromium-browser/extensions/$i.json"
  done

  e_success "Chromium installed"
}

###########################################################################
# Program Start
###########################################################################

program_start() {
  install_chromium
}

program_start