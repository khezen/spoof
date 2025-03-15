#!/bin/sh

# Start Postfix in the background
/usr/sbin/postfix start &

# Run the Go script
go run cmd/spoof/main.go
sleep 10
/usr/sbin/postfix stop

cat /var/log/mail.log
