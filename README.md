# WifiAutoLogin
Zero click login to Pulchowk Campus WiFi's UTM server whenever you connect to campus network for Windows devices(currently). No more dealing with those laggy UTM login pages!

> [!WARNING]  
> This program requires elevated system privileges to work properly. Make sure you trust the source the author(that would be me) and the code before running it.

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
Currently, this tool only supports Windows as I haven't worked with Linux/MacOS systems much. So, If you'd like to contribute and help port this to Linux/MacOS, your help would be greatly appreciated! The core login logic is written in Go, so it should be relatively straightforward to adapt for other platforms.

## Want to uninstall?
Just run the `windows/unscheduler.ps1` then remove the downloaded `PulchowkWifiAutoLogin` folder.
   