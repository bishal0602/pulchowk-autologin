//go:build linux

package wifi

import (
	"fmt"
	"os/exec"
	"strings"
)

func GetCurrentWifiSSID() (string, error) {
	cmd := exec.Command("iwgetid", "-r")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("error executing command: %v", err)
	}

	return strings.TrimSpace(string(output)), nil
}
