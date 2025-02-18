//go:build darwin

package wifi

import (
	"os/exec"
	"strings"
)

func GetCurrentWifiSSID() (string, error) {
	cmd := exec.Command("sh", "-c", "networksetup -getairportnetwork en0 | cut -c 24-")

	output, err := cmd.Output()
	if err != nil {
		return "", err
	}

	result := strings.TrimSpace(string(output))
	return result, nil
}
