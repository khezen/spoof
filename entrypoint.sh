#!/bin/sh

# Start Postfix in the background
/usr/sbin/postfix start &

# Run the Go script
go run cmd/spoof/main.go

/usr/sbin/postfix stop
