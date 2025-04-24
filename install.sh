#!/usr/bin/env bash

set -e

###############################################################################
#                                   global                                    #
###############################################################################

###################
#  documentation  #
###################

# Update mirrorlist with the fastest mirrors
# sudo pacman-mirrors --fasttrack

# Limit to 5 mirrors
# An optional number can be supplied to limit the number of mirrors
# in the mirrorlist
# sudo pacman-mirrors --fasttrack 5

# Mirrors for your country only
# Not all countries have mirrors, if geoip returns a country not
# in the pool all mirrors will be used.
# sudo pacman-mirrors --geoip

# Mirrors for Canada and United States
# sudo pacman-mirrors --country United_States,Canada

# Always run after pacman-mirrors
# sudo pacman -Syyu

###############
#  variables  #
###############

DIR_DEVEL="${HOME}/devel/"
DIR_PERSONAL="${DIR_DEVEL}/personal"
DIR_REPOS="${DIR_DEVEL}/repos"

DIR_REPOS_DEV="${DIR_REPOS}/dev"
DIR_REPOS_TOOLS="${DIR_REPOS}/tools"
DIR_REPOS_EMBEDDED="${DIR_REPOS}/embedded"
DIR_REPOS_UI="${DIR_REPOS}/ui"

DIR_DOTFILES="${HOME}/.dotfiles"

URL_ARM_32_TOOLCHAIN_11_2="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf.tar.xz"
URL_ARM_64_TOOLCHAIN_11_2="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu.tar.xz"
DIR_TOOLCHAINS="${HOME}/.toolchains"
DIR_ARM_32_TOOLCHAIN="${DIR_TOOLCHAINS}/11.2/aarch32"
DIR_ARM_64_TOOLCHAIN="${DIR_TOOLCHAINS}/11.2/aarch64"

TEMP_GNOME_CONFIG=/tmp/org.gnome.ini.tmp
BACKGROUND_IMAGE="${HOME}/.wallpapers/wallpaper_001.jpg"
SCREENSAVER_IMAGE="${HOME}/.wallpapers/wallpaper_002.jpg"

##################
#  repositories  #
##################

REPO_DOTFILES="https://github.com/syedelec/.dotfiles.git"
REPO_TILIX="https://github.com/syedelec/tilix.git"
REPO_QOGIR_GTK_THEME="https://github.com/vinceliuice/Qogir-theme"
REPO_QOGIR_ICN_THEME="https://github.com/vinceliuice/Qogir-icon-theme"

############
#  pacman  #
############

pacman_groups=(
    base base-devel dlang-dmd multilib-devel go
)
pacman_utils=(
    cpio unzip cmake xclip xsel xterm evtest cairo net-tools pam
    xcb-util-image xcb-util-keysyms tk dos2unix gdu cups help2man repo
    nmap gnu-netcat lsof detox sshfs lzop aspell-en bind-tools ctags
    boost catch2 fmt mbedtls nlohmann-json acpica dtc autoconf-archive
    gptfdisk bc git-cliff navi ventoy virt-manager swtpm minisign
    qemu-user-static qemu-user-static-binfmt xorg-apps ouch
)
pacman_dev=(
    vim neovim python-pynvim
    dub ldc meson
    python-pip
    rustup
)
pacman_tools=(
    docker docker-compose docker-buildx openssl wget curl git ripgrep
    fd bat fzf rofi stow tree yay lynx firefox cmus cppcheck shellcheck
    meld android-tools cargo efitools deluge evince dialog binwalk
    jq texlive-core bash-language-server python-lsp-server git-delta
    clang jre11-openjdk tree-sitter tree-sitter-cli duf nvme-cli mpd
    mattermost-desktop whois arp-scan uncrustify sd wireguard-tools
    telegram-desktop tcpdump wireshark-cli speedtest-cli keepassxc
    valgrind mplayer mpc fdupes pngquant python-sphinx-autobuild
    python-myst-parser perl-io-socket-ssl perl-authen-sasl
)
pacman_customization=(
    arc-gtk-theme bash-completion feh neofetch gnome-tweaks
    gnome-shell-extension-caffeine
)
pacman_fonts=(
    ttf-roboto ttf-roboto-mono ttf-font-awesome ttf-fira-code ttf-fira-sans
    ttf-fira-mono ttf-lato ttf-droid cantarell-fonts
    terminus-font ttf-terminus-nerd noto-fonts
)
pacman_lib=(
    libcurl-compat libev libx11 libxkbcommon-x11 gnu-efi-libs
)

#########
#  yay  #
#########

yay_tools=(
    google-chrome teams teamviewer sublime-text-4 ticktick
)
yay_utils=(
    bfs bitwise zoxide tio libtree zoom standardnotes-desktop
)
yay_customization=(
    tela-icon-theme colorpicker
)

###############################################################################
#                                setup install                                #
###############################################################################
sudo sed -i 's|^#\(ParallelDownloads.*\)|\1|' /etc/pacman.conf
sudo sed -i 's|^#\(Color.*\)|\1|' /etc/pacman.conf

echo "======= Enable default session as X11 ======="

sudo sed -i 's|^#\(WaylandEnable.*\)|\1|' /etc/gdm/custom.conf

echo "======= Change default shell ======="

sudo chsh -s /bin/bash

###############################################################################
#                                   install                                   #
###############################################################################

yay_args="--needed --noconfirm --cleanmenu=false --diffmenu=false --editmenu=false"
pacman_args="--needed --noconfirm"

echo "======= Update current packages ======="

sudo pacman ${pacman_args} -Syyu

echo "======= Install groups ======="

# for groups we need to install one by one
for group in ${pacman_groups[*]}; do
    sudo pacman -S ${pacman_args} ${group}
done

echo "======= Install 'ARCH' packages ======="

sudo pacman -Sy ${pacman_args}           \
    ${pacman_utils[*]}                   \
    ${pacman_dev[*]}                     \
    ${pacman_tools[*]}                   \
    ${pacman_customization[*]}           \
    ${pacman_fonts[*]}                   \
    ${pacman_lib[*]}

echo "======= Install 'AUR' packages ======="

yay -Sy ${yay_args}                      \
    ${yay_tools[*]}                      \
    ${yay_utils[*]}                      \
    ${yay_customization[*]}

###############################################################################
#                                architecture                                 #
###############################################################################

echo "======= Setup 'DIRS' ======="

# ├── devel
# │    ├── personal
# │    └── repos
# │        ├── dev
# │        ├── embedded
# │        ├── tools
# │        └── ui
# └── .toolchains
#      └── [version]
#         ├── aarch32
#         └── aarch64

mkdir -p "${DIR_PERSONAL}"

mkdir -p "${DIR_REPOS_UI}"
mkdir -p "${DIR_REPOS_DEV}"
mkdir -p "${DIR_REPOS_TOOLS}"
mkdir -p "${DIR_REPOS_EMBEDDED}"

mkdir -p "${DIR_ARM_32_TOOLCHAIN}"
mkdir -p "${DIR_ARM_64_TOOLCHAIN}"

###############################################################################
#                                 toolchains                                  #
###############################################################################

echo "======= Install toolchains ======="

if [[ ! -d "${DIR_ARM_32_TOOLCHAIN}" ]]; then
    wget -cO- "${URL_ARM_32_TOOLCHAIN_11_2}" | \
        tar xf - -J -C "${DIR_ARM_32_TOOLCHAIN}" --strip-components=1
fi

if [[ ! -d "${DIR_ARM_64_TOOLCHAIN}" ]]; then
    wget -cO- "${URL_ARM_64_TOOLCHAIN_11_2}" | \
        tar xf - -J -C "${DIR_ARM_64_TOOLCHAIN}" --strip-components=1
fi

###############################################################################
#                                 activation                                  #
###############################################################################

echo "======= Install dotfiles ======="

if [[ ! -d "${DIR_DOTFILES}" ]]; then
    git clone --recursive "${REPO_DOTFILES}" "${DIR_DOTFILES}" 1>/dev/null
fi

cd "${DIR_DOTFILES}"

find * -maxdepth 0 -type d -exec stow --adopt {} \;
bat cache --build 1>/dev/null

###############################################################################
#                                 gnome theme                                 #
###############################################################################

echo "======= Setup 'GNOME' theme ======="

mkdir -p "${HOME}/.themes"
mkdir -p "${HOME}/.icons"

if [[ ! -d "${DIR_REPOS_UI}/Qogir-theme" ]]; then
    git clone --recursive "${REPO_QOGIR_GTK_THEME}" "${DIR_REPOS_UI}/Qogir-theme" 1>/dev/null --depth 1
else
    echo "${DIR_REPOS_UI}/Qogir-theme already exists"
fi

cd "${DIR_REPOS_UI}/Qogir-theme"
./install.sh -d "${HOME}/.themes" -t default -c dark -i default --tweaks square

if [[ ! -d "${DIR_REPOS_UI}/Qogir-icon-theme" ]]; then
    git clone --recursive "${REPO_QOGIR_ICN_THEME}" "${DIR_REPOS_UI}/Qogir-icon-theme" 1>/dev/null --depth 1
else
    echo "${DIR_REPOS_UI}/Qogir-icon-theme already exists"
fi
cd "${DIR_REPOS_UI}/Qogir-icon-theme"
./install.sh -d "${HOME}/.icons" -t default -c dark

###############################################################################
#                               gnome settings                                #
###############################################################################

echo "======= Setup 'GNOME' ======="

cp ${DIR_DOTFILES}/.gnome/org.gnome.ini ${TEMP_GNOME_CONFIG}
dconf load /org/gnome/ < ${TEMP_GNOME_CONFIG}

# dynamically set background/screensaver image
gsettings set org.gnome.desktop.background picture-uri file://${BACKGROUND_IMAGE}
gsettings set org.gnome.desktop.background picture-uri-dark file://${BACKGROUND_IMAGE}
gsettings set org.gnome.desktop.screensaver picture-uri file://${SCREENSAVER_IMAGE}

# activate night light mode with temperature color
gsettings get org.gnome.settings-daemon.plugins.color night-light-temperature
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 5000

sudo dconf update

rm -f ${TEMP_GNOME_CONFIG}

###############################################################################
#                                  services                                   #
###############################################################################

echo "======= Setup 'SYSTEMD' ======="

sudo systemctl disable bluetooth
sudo systemctl disable cups
sudo systemctl enable --now docker

grep -q docker /etc/group || sudo groupadd docker
sudo usermod -aG docker ${USER}
sudo usermod -aG uucp,tty ${USER}

###############################################################################
#                                   sysctl                                    #
###############################################################################

echo "======= Setup 'SYSCTL' ======="

echo kernel.dmesg_restrict = 0 | sudo tee -a /etc/sysctl.d/10-local.conf >/dev/null
sudo sysctl --quiet --system

###############################################################################
#                               build terminal                                #
###############################################################################

echo "======= Setup 'TERMINAL' ======="

if [[ ! -d "${DIR_REPOS_TOOLS}/tilix" ]]; then
    git clone --recursive "${REPO_TILIX}" "${DIR_REPOS_TOOLS}/tilix" 1>/dev/null
else
    echo "${DIR_REPOS_TOOLS}/tilix already exists"
fi

cd "${DIR_REPOS_TOOLS}/tilix"
dub build --build=release &> /dev/null
sudo ./install.sh &> /dev/null
dconf load /com/gexperts/Tilix/ < "${DIR_DOTFILES}/tilix/.config/tilix/tilix.conf"

###############################################################################
#                                neovim config                                #
###############################################################################

# nvim -c 'PlugInstall --sync' -c '<\CR>' -c 'qa'

echo "======= Installation done ======="
