# Pulchowk Wifi Auto Login
Zero click login to Pulchowk Campus WiFi's UTM server whenever you connect to campus network. No more dealing with those laggy UTM login pages!

> [!WARNING]  
> This program requires elevated system privileges to work properly. Make sure you trust the author(that would be me) and the source code before running it.


- [Install](#installation)
  - [Windows](#windows)
  - [Linux/macOS](#linuxmacos)
- [How It Works](#how-it-works)
- [Platform-Specific Notes](#platform-specific-notes)
  - [Android](#android)
  - [Linux Distros](#linux-distros)
- [Uninstall](#uninstall)
  - [Windows](#windows-2)
  - [Linux/macOS](#linuxmacos-2)

---

## Installation

### Windows
1. Open PowerShell and run:
```powershell
irm https://dist.bishal0602.com.np/pcampus/installer.ps1 | iex
```
2. Enter your campus username and password when prompted.
3. Allow administrator access when requested.
4. That's it! You're all set.

### Linux/macOS
#### Prerequisites
- Ensure `curl` is installed:
```bash
sudo apt-get -y install curl
```
#### Install
1. Download and run the installer script:
```bash
curl -s -o installer.sh https://dist.bishal0602.com.np/pcampus/installer.sh && \
sudo chmod 755 installer.sh && \
sudo ./installer.sh
```

## How it works?

### Windows
When you connect to any WiFi network, the login program is triggered by Windows Task Scheduler Network Profile Events and it checks if you are connected to campus WiFis. And if you are, you are automagically logged in to the campus UTM login server with your credentials.

### Linux/MacOS
On Linux/MacOS, the program integrates with the system's `NetworkManager` to monitor network events. A dispatcher script listens for interface events. When a campus WiFi network is detected, the program automatically logs in to the UTM server.

## Platform-Specific Notes

### Android
Background network change event listeners seem to be heavily restricted/deprecated on Android. Implementing a continous background service to monitor network changes would be highly energy-inefficient. Or you would need an app/widget that would do the login for you. So, I figured it wasn’t worth the hassle.

### Linux Distros
Tested on Debian/Ubuntu-based distributions. Other distributions like Fedora or Arch may require minor adjustments due to differing system configurations. 


## Uninstall

### Windows
Just run the `unscheduler.ps1` then remove the downloaded `PulchowkWifiAutoLogin` folder.

### Linux/macOS
#### Unschedule
- To unschedule auto-login:
```bash
# Removes the dispatcher file ensuring it no longer triggers the login process
sudo ~/.pulchowk_utm_login/unscheduler.sh ~/.pulchowk_utm_login/.env
```

- To reschedule auto-login after unscheduling:
```bash
sudo ~/.pulchowk_utm_login/scheduler.sh ~/.pulchowk_utm_login/.env
```

#### Uninstall
1. Unschedule auto-login (see above).
2. Remove the script directory:
```bash
rm -r ~/.pulchowk_utm_login
```