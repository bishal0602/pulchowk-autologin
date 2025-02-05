package main

import (
	"flag"
	"log"
	"os"
	"strings"
	"utm_login/internal/utm"
	"utm_login/internal/wifi"
)

func main() {
	username := flag.String("username", "", "Your Campus Login Username")
	password := flag.String("password", "", "Your Campus Login Password")
	flag.Parse()

	if *username == "" || *password == "" {
		log.Fatalf("Require flags: %s -username=<username> -password=<password>", os.Args[0])
	}

	campusSSIDs := []string{"Block A", "Block B", "Block C", "PC_ELEXCOMP", "PC-ELEXCOMP", "CITPC", "CIT AP", "PC-Civil"}

	wifiSSID, err := wifi.GetCurrentWifiSSID()
	if err != nil {
		log.Fatalf("Failed to get current wifi SSID: %v", err)
	}
	if !hasPrefix(wifiSSID, campusSSIDs) {
		log.Printf("Not connected to campus wifi. Current wifi: %s Exiting.", wifiSSID)
		return
	}

	if err := utm.LoginToUTM(*username, *password, 5); err != nil {
		log.Fatalf("Failed to login to UTM: %v", err)
	}

	log.Println("Successfully logged in to campus UTM server.")
}

func hasPrefix(ssid string, prefixes []string) bool {
	for _, prefix := range prefixes {
		if strings.HasPrefix(ssid, prefix) {
			return true
		}
	}
	return false
}
