package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/smtp"
	"time"
)

func waitForPostfix(addr string, timeout time.Duration) error {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	ticker := time.NewTicker(100 * time.Millisecond) // Check every 100ms
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return fmt.Errorf("timeout waiting for Postfix to start on %s: %v", addr, ctx.Err())
		case <-ticker.C:
			conn, err := net.DialTimeout("tcp", addr, 500*time.Millisecond)
			if err == nil {
				conn.Close()
				return nil // Postfix is ready
			}
		}
	}
}

func main() {
	var (
		// Configuration
		from       = "test@mydomain.com"          // Spoofed sender
		to         = "receiver@anotherdomain.com" // Recipient
		smtpServer = "localhost"                  // Docker host
		smtpPort   = "2525"
		subject    = "SMTP Server Test"
		body       = "This is a test email from my custom SMTP server."
		msg        = []byte(fmt.Sprintf(
			"To: %s\r\n"+
				"From: %s\r\n"+
				"Subject: %s\r\n"+
				"\r\n"+
				"%s\r\n", to, from, subject, body))
		addr    = net.JoinHostPort(smtpServer, smtpPort)
		auth    smtp.Auth
		timeout = 20 * time.Second
	)
	// Wait for Postfix to be ready
	log.Printf("Waiting for Postfix to start on %s...", addr)
	if err := waitForPostfix(addr, timeout); err != nil {
		log.Fatalf("Failed to wait for Postfix: %v", err)
	}
	log.Printf("Postfix is ready on %s", addr)
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	done := make(chan error, 1)
	fmt.Printf("Sending test email from %s to %s...", from, to)
	go func() {
		err := smtp.SendMail(addr, auth, from, []string{to}, msg)
		if err != nil {
			done <- fmt.Errorf("failed to send email: %v", err)
			return
		}
		done <- nil
	}()
	select {
	case <-ctx.Done():
		log.Fatalf("SMTP operation timed out after %v: %v", timeout, ctx.Err())
	case err := <-done:
		if err != nil {
			log.Fatalf("SMTP operation failed: %v", err)
		}
		fmt.Println("Test email sent successfully!")
	}
}
