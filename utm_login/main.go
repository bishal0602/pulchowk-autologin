package main

import (
	"flag"
	"log"
	"os"
	"slices"
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

	campusSSIDs := []string{"PC_ELEXCOMP", "PC-ELEXCOMP", "CITPC", "CIT AP", "PC-Civil"}

	wifiSSID, err := wifi.GetCurrentWifiSSID()
	if err != nil {
		log.Fatalf("Failed to get current wifi SSID: %v", err)
	}
	if !slices.Contains(campusSSIDs, wifiSSID) {
		log.Printf("Not connected to campus wifi. Current wifi: %s Exiting.", wifiSSID)
		return
	}

	if err := utm.LoginToUTM(*username, *password, 3); err != nil {
		log.Fatalf("Failed to login to UTM: %v", err)
	}

	log.Println("Successfully logged in to campus UTM server.")
}
