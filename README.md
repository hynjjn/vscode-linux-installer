# VS Code Universal Linux Installer

Microsoft was too lazy to make the universal script for installing VS Code. I made it for them.

## 🚀 Quick Start

You can run the installer directly via `curl` or `wget`:

```bash
curl -fsSL https://raw.githubusercontent.com/hynjjn/vscode-linux-installer/main/install.sh | sh
```

---

## 🛠️ Features

- **Multi-Distro Support**: Works with `apt`, `dnf`, `yum`, `pacman`, `zypper`, `eopkg`, and `rpm-ostree`.
- **Automatic GPG Setup**: Securely imports Microsoft's signing keys and sets up the modern DEB822 `.sources` format on Debian/Ubuntu.
- **Architecture Detection**: Supports `x86_64` (64-bit PC), `aarch64` (ARM64), and `armv7l` (Raspberry Pi).

## 📦 Supported Distributions

| Family | Distributions |
| :--- | :--- |
| **Debian** | Ubuntu, Debian, Linux Mint, Pop!_OS, Kali, Elementary |
| **Fedora** | Fedora, RHEL, CentOS, AlmaLinux, Rocky Linux |
| **Arch** | Arch Linux, Manjaro, EndeavourOS (requires `paru`, `yay`, or `pikaur`) |
| **SUSE** | openSUSE Tumbleweed, Leap, SLE |
| **Solus** | Solus |
| **Immutable** | Fedora Silverblue, Fedora Kinoite (via `rpm-ostree`) |

## 🛡️ Requirements

- A 64-bit or ARM-based Linux system.
- `glibc` version 2.26 or higher.
- Core utilities (`grep`, `sh`, `coreutils`).

## 📜 License & Credits

This script is licensed under the **BSD 3-Clause License**.

- Based on the [Brave Browser Installer](https://github.com/brave/install.sh).
- Logic inspired by [Tailscale](https://github.com/tailscale/tailscale).
- Modified and maintained by [hynjjn](https://github.com/hynjjn).

---
*Disclaimer: This script is an independent community project and is not officially affiliated with Microsoft Corporation.*
