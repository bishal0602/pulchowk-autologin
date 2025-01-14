# Pulchowk Wifi Auto Login
Zero click login to Pulchowk Campus WiFi's UTM server whenever you connect to campus network for Windows devices(currently). No more dealing with those laggy UTM login pages!

> [!WARNING]  
> This program requires elevated system privileges to work properly. Make sure you trust the author(that would be me) and the source code before running it.

## Installation (Windows)

1. Open PowerShell and run:
```ps1
irm https://dist.bishal0602.com.np/pcampus/installer.ps1 | iex
```
2. Enter your campus username and password when prompted.
3. Allow administrator access when requested.
4. That's it! You're all set.

## How it works?
When you connect to any WiFi network, the login program is triggered by Windows Task Scheduler Network Profile Events and it checks if you are connected to campus WiFis. And if you are, you are automagically logged in to the campus UTM login server with your credentials.

## Linux/MacOS Support
Tested in `Debian/Ubuntu` based distros, but unsure about other distros like Feodra or Arch. The core login logic is written in Go, so it should be relatively straightforward to adapt for other platforms.

### Installation
```shell
#Install curl if not installed
sudo apt-get -y install curl

#Download installer script and run with sudo priviledges
curl -s -o installer.sh https://dist.bishal0602.com.np/pcampus/installer.sh && \
sudo chmod 755 installer.sh && \
sudo ./installer.sh
```

### Unschedule
```shell
#To just unschedule
## Run unscheduler script with sudo priviledges along with the env file
## It just removes the dispatcher script from the system directory.
## You can still schedule it again without running installer.sh again.
sudo ~/.pulchowk_utm_login/unscheduler.sh ~/.pulchowk_utm_login/.env

#To schedule autologin again after unscheduling
## Run scheduler script with sudo priviledges along with the env file
sudo ~/.pulchowk_utm_login/scheduler.sh ~/.pulchowk_utm_login/.env
```

### Uninstall
```shell
#1. Run the unschedule script at first
# .... Its in just upper code block

#2. Remove the directory containing scripts and env file
## i.e. ~/.pulchowk_utm_login
rm -r ~/.pulchowk_utm_login
```

## Android Support
Background network change event listeners seem to be heavily restricted/deprecated on Android. Implementing a continous background service to monitor network changes would be highly energy-inefficient. Or you would need an app/widget that would do the login for you. So, I figured it wasn’t worth the hassle.

## Want to uninstall?
Just run the `windows/unscheduler.ps1` then remove the downloaded `PulchowkWifiAutoLogin` folder.