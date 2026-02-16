#!/bin/sh -eu
# Copyright (c) Tailscale Inc
# Copyright (c) 2024 The Brave Authors
# Copyright (c) 2026 hynjjn (github.com/hynjjn)
# SPDX-License-Identifier: BSD-3-Clause
#
# This script installs the VS Code using the OS's package manager
# Requires: coreutils, grep, sh and one of sudo/doas/run0/pkexec/sudo-rs
# Source: https://github.com/brave/install.sh

GLIBC_VER_MIN="2.26"
APT_VER_MIN="1.1"

main() {
    ## Check if VS Code can run on this system

    case "$(uname)" in
        Darwin) error "Please go to https://code.visualstudio.com/Download to download the Mac app";;
        *) glibc_supported;;
    esac

    case "$(uname -m)" in
        aarch64|x86_64|armv7l) ;;
        *) error "Unsupported architecture $(uname -m). Only 64-bit x86 or ARM machines are supported.";;
    esac

    ## Locate the necessary tools

    case "$(whoami)" in
        root) sudo="";;
        *) sudo="$(first_of sudo doas run0 pkexec sudo-rs)" || error "Please install sudo/doas/run0/pkexec/sudo-rs to proceed.";;
    esac

    case "$(first_of curl wget)" in
        wget) curl="wget -qO-";;
        *) curl="curl -fsS";;
    esac

    echo "Installing VS Code"

    if available apt-get && apt_supported; then
        export DEBIAN_FRONTEND=noninteractive
        show $sudo apt-get update || apt_error
        show $sudo apt-get install -y curl apt-transport-https wget gpg
        $curl "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor | \
            show $sudo install -DTm644 /dev/stdin "/usr/share/keyrings/microsoft.gpg"

	printf "Types: deb\nURIs: https://packages.microsoft.com/repos/code\nSuites: stable\nComponents: main\nArchitectures: amd64 arm64 armhf\nSigned-By: /usr/share/keyrings/microsoft.gpg\n" | \
            show $sudo install -DTm644 /dev/stdin "/etc/apt/sources.list.d/vscode.sources"

        show $sudo rm -f /etc/apt/sources.list.d/vscode.list
        show $sudo apt-get update
        show $sudo apt-get install code -y
        
    elif available dnf || available yum; then
        dnf_pkg="$(first_of dnf yum)"
        show $sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	printf "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n" | \
            show $sudo install -DTm644 /dev/stdin "/etc/yum.repos.d/vscode.repo"
	show $sudo $dnf_pkg install -y code

    elif available eopkg; then
        show $sudo eopkg update-repo -y
        show $sudo eopkg install -y vscode

    elif available pacman; then
        aur_helper="$(first_of paru pikaur yay)" ||
            error "Could not find an AUR helper. Please install paru/pikaur/yay to proceed." "" \
                  "You can find more information about AUR helpers at https://wiki.archlinux.org/title/AUR_helpers"
        show "$aur_helper" -S --needed --noconfirm visual-studio-code-bin

    elif available zypper; then
        show $sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        printf "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\nautorefresh=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n" | \
            show $sudo install -DTm644 /dev/stdin "/etc/zypp/repos.d/vscode.repo"
        show $sudo zypper --non-interactive --gpg-auto-import-keys refresh
        show $sudo zypper --non-interactive install code
        
    elif available rpm-ostree; then
        $curl "https://packages.microsoft.com/yumrepos/vscode/config.repo" | \
            show $sudo install -DTm644 /dev/stdin "/etc/yum.repos.d/vscode.repo"
        show $sudo rpm-ostree install -y --idempotent code

    else
        error "Could not find a supported package manager. Only apt/dnf/eopkg/pacman(+paru/pikaur/yay)/rpm-ostree/yum/zypper are supported."
    fi

    installed_bin=$(first_of code vscode)
    if [ -n "$installed_bin" ]; then
        echo "Installation complete! Start VS Code by typing: $installed_bin"
    else
        echo "Installation complete!"
    fi
}

# Helpers
available() { command -v "${1:?}" >/dev/null; }
first_of() { for c in "${@:?}"; do if available "$c"; then echo "$c"; return 0; fi; done; return 1; }
show() { (set -x; "${@:?}"); }
error() { exec >&2; printf "Error: "; printf "%s\n" "${@:?}"; exit 1; }
newer() { [ "$(printf "%s\n%s" "$1" "$2"|sort -V|head -n1)" = "${2:?}" ]; }
supported() { newer "$2" "${3:?}" || error "Unsupported ${1:?} version ${2:-<empty>}. Only $1 versions >=$3 are supported."; }
glibc_supported() { supported glibc "$(ldd --version 2>/dev/null|head -n1|grep -oE '[0-9]+\.[0-9]+$' || true)" "${GLIBC_VER_MIN:?}"; }
apt_error() { error 'The "apt-get update" command is not working on your system. The VSCode installer cannot proceed. Please try again after fixing your system configuration.'; }
apt_supported() { supported apt "$(apt-get -v|head -n1|cut -d' ' -f2)" "${APT_VER_MIN:?}"; }

main

