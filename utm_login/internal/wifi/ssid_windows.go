//go:build windows

package wifi

import (
	"bufio"
	"bytes"
	"fmt"
	"os/exec"
	"strings"
)

func GetCurrentWifiSSID() (string, error) {
	cmd := exec.Command("netsh", "wlan", "show", "interfaces")

	var out bytes.Buffer
	cmd.Stdout = &out

	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("error executing command: %w", err)
	}

	scanner := bufio.NewScanner(&out)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, " SSID") {
			return strings.TrimSpace(strings.SplitN(line, ":", 2)[1]), nil
		}
	}

	if err := scanner.Err(); err != nil {
		return "", fmt.Errorf("error reading command output: %w", err)
	}

	return "", fmt.Errorf("unable to obtain SSID")
}
