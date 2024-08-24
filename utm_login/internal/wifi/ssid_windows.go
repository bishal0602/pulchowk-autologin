//go:build windows

package wifi

import (
	"fmt"
	"os/exec"
	"strings"
)

func GetCurrentWifiSSID() (string, error) {
	cmd := exec.Command("netsh", "wlan", "show", "interfaces")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("error executing command: %v", err)
	}
	ssid := ""
	for _, line := range strings.Split(string(output), "\n") {
		if strings.Contains(line, " SSID") {
			ssid = strings.TrimSpace(strings.Split(line, ":")[1])
		}
	}
	return ssid, nil
}
