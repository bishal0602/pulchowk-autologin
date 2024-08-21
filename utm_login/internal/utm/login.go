package utm

import (
	"bytes"
	"crypto/tls"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"time"
)

func LoginToUTM(username, password string, retries int) error {
	timestamp := strconv.FormatInt(time.Now().UnixNano()/1e6, 10)

	data := url.Values{}
	data.Set("username", username)
	data.Set("mode", "191")
	data.Set("password", password)
	data.Set("productType", "0")
	data.Set("a", timestamp)

	headers := map[string]string{
		"Host":            "10.100.1.1:8090",
		"Accept-Encoding": "gzip, deflate, br, zstd",
		"Origin":          "https://10.100.1.1:8090",
		"Referer":         "https://10.100.1.1:8090/httpclient.html",
		"Sec-Fetch-Dest":  "empty",
		"Sec-Fetch-Mode":  "cors",
		"Sec-Fetch-Site":  "same-origin",
		"DNT":             "1",
		"Sec-GPC":         "1",
		"User-Agent":      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0",
		"Accept":          "*/*",
		"Accept-Language": "en-US,en;q=0.5",
		"Content-Type":    "application/x-www-form-urlencoded",
	} // adding lots of headers for "reasons" ;)

	// Retry, Timeout & SSL Policy
	retryDelay := 2 * time.Second
	client := &http.Client{
		Timeout: 10 * time.Second,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true, // Ignore SSL certificate errors
			},
		},
	}

	// Retry loop
	for i := 0; i < retries; i++ {
		req, err := http.NewRequest("POST", "https://10.100.1.1:8090/login.xml", bytes.NewBufferString(data.Encode()))
		if err != nil {
			return fmt.Errorf("error creating request: %v", err)
		}
		for key, value := range headers {
			req.Header.Set(key, value)
		}

		response, err := client.Do(req)
		if err != nil {
			log.Printf("Error making request (attempt %d/%d): %v\n", i+1, retries, err)
			if i < retries-1 {
				time.Sleep(retryDelay)
			}
			continue
		}
		defer response.Body.Close()

		log.Println("Response Status:", response.Status)
		return nil
	}
	return fmt.Errorf("failed to make a successful request after %d retries", retries)
}
