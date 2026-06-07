


## About

- Download and install the latest v2rayN application on Ubuntu Desktop.
- **Smart Installation**: Detects if run with `sudo` (install for all users) or without (install only for current user).
- Adds v2rayN icon to the appropriate application menu (system-wide or user-specific).

## Installation

**Dependencies:** `unzip`, `wget`

Install dependencies:
```bash
sudo apt install unzip wget
```

To install, run the following commands:

```bash
git clone https://github.com/mammadnet/v2rayN-installer.git
cd v2rayN-installer
```

**For system-wide installation (all users):**
```bash
sudo ./v2rayN_installer.sh
```

**For single-user installation (current user only):**
```bash
./v2rayN_installer.sh
```

> ℹ️ The script automatically checks for root privileges. If run with `sudo`, it installs to system directories. If run as a normal user, it installs to the user's local paths.
