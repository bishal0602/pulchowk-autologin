package wifi

import (
	"fmt"
	"os/exec"
	"runtime"
	"strings"
)

func GetCurrentWifiSSID() (string, error) {
	var cmd *exec.Cmd

	switch runtime.GOOS {
	case "windows":
		cmd = exec.Command("netsh", "wlan", "show", "interfaces")
	case "darwin":
		cmd = exec.Command("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport", "-I")
	case "linux":
		cmd = exec.Command("iwgetid", "-r")
	default:
		return "", fmt.Errorf("unsupported operating system: %s", runtime.GOOS)
	}

	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("error executing command: %v", err)
	}

	ssid := parseSSID(string(output), runtime.GOOS)
	return ssid, nil
}

func parseSSID(output, os string) string {
	switch os {
	case "windows":
		for _, line := range strings.Split(output, "\n") {
			if strings.Contains(line, "SSID") {
				return strings.TrimSpace(strings.Split(line, ":")[1])
			}
		}
	case "darwin":
		for _, line := range strings.Split(output, "\n") {
			if strings.Contains(line, "SSID:") {
				return strings.TrimSpace(strings.Split(line, ":")[1])
			}
		}
	case "linux":
		return strings.TrimSpace(output)
	}
	return ""
}
