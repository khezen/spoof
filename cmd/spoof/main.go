package main

import (
	"fmt"
	"log"
	"net/smtp"
)

func main() {
	var (
		// Configuration
		from       = "test@yourdomain.com" // Spoofed sender
		to         = "user@localhost"      // Recipient
		smtpServer = "localhost"           // Docker host
		smtpPort   = "2525"
		subject    = "SMTP Server Test"
		body       = "This is a test email from my custom SMTP server."
		msg        = []byte(fmt.Sprintf(
			"To: %s\r\n"+
				"From: %s\r\n"+
				"Subject: %s\r\n"+
				"\r\n"+
				"%s\r\n", to, from, subject, body))
		addr           = fmt.Sprintf("%s:%s", smtpServer, smtpPort)
		auth smtp.Auth = nil
	)
	fmt.Printf("Sending test email from %s to %s...", from, to)
	err := smtp.SendMail(addr, auth, from, []string{to}, msg)
	if err != nil {
		log.Fatalf("Failed to send email: %v", err)
	}
	fmt.Println("Test email sent successfully!")
}
