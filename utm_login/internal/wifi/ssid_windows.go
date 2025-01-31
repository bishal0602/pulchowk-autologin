//go:build windows

package wifi

import (
	"bufio"
	"bytes"
	"fmt"
	"os/exec"
	"strings"
)

// GetCurrentWifiSSID returns the SSID of the currently connected WiFi network.
//
// First attempts to use netsh command, falling back to PowerShell if netsh fails
// due to Windows Location services being disabled.
// See: https://learn.microsoft.com/en-us/windows/win32/nativewifi/wi-fi-access-location-changes
func GetCurrentWifiSSID() (string, error) {
	ssid, err := getSSIDFromNetsh()
	if err == nil {
		return ssid, nil
	}

	ssid, err = getSSIDFromPowerShell()
	if err == nil {
		return ssid, nil
	}

	return "", fmt.Errorf("unable to obtain SSID: %v, %v", err, err)
}

func getSSIDFromNetsh() (string, error) {
	cmd := exec.Command("netsh", "wlan", "show", "interfaces")

	var out bytes.Buffer
	cmd.Stdout = &out

	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("netsh failed: %w", err)
	}

	scanner := bufio.NewScanner(&out)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, " SSID") {
			return strings.TrimSpace(strings.SplitN(line, ":", 2)[1]), nil
		}
	}

	if err := scanner.Err(); err != nil {
		return "", fmt.Errorf("error reading netsh output: %w", err)
	}

	return "", fmt.Errorf("SSID not found in netsh output")
}

func getSSIDFromPowerShell() (string, error) {
	cmd := exec.Command("powershell", "-Command", `(Get-NetConnectionProfile).Name`)

	var out bytes.Buffer
	cmd.Stdout = &out

	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("powershell failed: %w", err)
	}

	ssid := strings.TrimSpace(out.String())
	if ssid == "" {
		return "", fmt.Errorf("SSID not found in PowerShell output")
	}

	return ssid, nil
}
