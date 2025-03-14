#!/bin/sh

# Start Postfix in the background
/usr/sbin/postfix start

# Wait briefly to ensure Postfix is running
sleep 10

# Run the Go script
go run spoof.go

# Keep the container running by tailing the mail log
tail -f /var/log/mail.log