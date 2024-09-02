.PHONY: all windows darwin clean

all: clean windows darwin

windows:
	GOOS=windows GOARCH=386 go build -o bin/utm_login-windows-386.exe main.go
	GOOS=windows GOARCH=amd64 go build -o bin/utm_login-windows-amd64.exe main.go
	GOOS=windows GOARCH=arm go build -o bin/utm_login-windows-arm.exe main.go
	GOOS=windows GOARCH=arm64 go build -o bin/utm_login-windows-arm64.exe main.go

darwin:
	GOOS=darwin GOARCH=arm64 go build -o bin/utm_login-darwin-arm64 main.go
	GOOS=darwin GOARCH=amd64 go build -o bin/utm_login-darwin-amd64 main.go

clean:
	rm -rf bin