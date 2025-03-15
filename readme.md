# DMARC Tester

A lightweight Dockerized SMTP server built with Postfix on Alpine Linux, designed for testing DMARC configurations. This project includes a Go script (`cmd/spoof/main.go`) to send spoofed emails, allowing you to verify how your DMARC policies handle unauthenticated senders. The SMTP server runs on a high port (2525) to avoid requiring root privileges.

## Features
- Runs Postfix SMTP server in a Docker container on port 2525.
- Includes a Go script (`cmd/spoof/main.go`) to send test emails with spoofed headers.
- Configurable for local or external DMARC testing.
- Lightweight Alpine Linux base image (~20MB).
- Logs to `/var/log/mail.log` for debugging.

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/) installed on your system.
- [Go](https://golang.org/doc/install) (optional, only if testing the script outside the container).
- A domain with DMARC configured (optional, for real-world testing).

## Project Structure
```
dmarc/
├── Dockerfile         # Builds the Alpine-based Postfix and Go environment
├── etc/
│   └── postfix/
│       ├── main.cf     # Postfix main configuration
│       └── master.cf   # Postfix service definitions (port 2525 and postlog)
|       └── sasl_passwd # Authentication to remote email service when relay is enabled
├── cmd/
│   └── spoof/
│       └── main.go    # Go script to send test emails
├── entrypoint.sh      # Starts Postfix and runs the Go script
└── README.md          # This file
```

## Setup Instructions

### 1. Clone or Create the Project
If this is part of a repository:
```bash
git clone <repository-url>
cd dmarc
```
Otherwise, create the `dmarc/` directory and copy the files as shown above.

### 2. Customize Configuration (Optional)
- **Edit `etc/postfix/main.cf`:**
  - Replace `yourdomain.com` with your domain for realistic spoofing.
  - Adjust `mynetworks` for security if not testing locally (e.g., `127.0.0.0/8`).
- **Edit `cmd/spoof/main.go`:**
  - Update `from` and `to` email addresses for your test scenario.
  - Change `smtpServer` to your host’s IP for external testing.

### 3. Build the Docker Image
```bash
docker build -t dmarc-tester .
```

### 4. Run the Container
```bash
docker run -d -p 2525:2525 --name dmarc-server dmarc-tester
```
- `-p 2525:2525`: Maps port 2525 on your host to the container.
- The container starts Postfix, sends a test email via `cmd/spoof/main.go`, and tails the log.

### 5. Check Logs
```bash
docker logs dmarc-server
```
Expect to see:
- Postfix startup messages.
- "Test email sent successfully!" from the Go script.
- Mail log entries.

## Usage


### Testing DMARC
1. Update `cmd/spoof/main.go`:
   - Set `from` to an email address belonging the to domain for which you want to test your DMARC policy.
   - Set `to` to an external email address (e.g., your inbox).
   - Set `smtpServer` to your host’s IP if running on a remote machine.
2. Rebuild and rerun the container:
   ```bash
   docker build -t dmarc-tester .
   docker run -d -p 2525:2525 --name dmarc-server dmarc-tester
   ```
3. Verify the email arrives and check your DMARC reports (e.g., via `rua` in your DMARC DNS record).


## Troubleshooting
- **"Postfix integrity check failed"**: Ensure `etc/postfix/master.cf` includes the `postlog` service.
- **Email not sending**: Check logs for errors (e.g., network issues, Postfix not running).
- **Port inaccessible**: Verify port 2525 is open on your host (`sudo ufw allow 2525` or equivalent).

## Notes
- **Security**: This is an open relay (`mynetworks = 0.0.0.0/0`) for testing. Restrict access in production.
- **TLS**: Not enabled. Add certificates and update `etc/postfix/main.cf` for secure connections if needed.
- **Port**: Uses 2525 to avoid privileged port issues. Change in `etc/postfix/master.cf` and Docker `-p` if desired.

## Extending the Project
- Add TLS: Install `openssl`, generate certs, and configure `smtpd_tls_*` in `etc/postfix/main.cf`.
- External Relay: Adjust relay configuration in `etc/postfix/main.cf` for real-world email delivery.
  - in this case you also need to update `etc/postfix/sasl_passwd`. 
  - Exemple for gmail:
    - Go to https://myaccount.google.com/apppasswords.
    - Sign in with your account.
    - Copy the 16-character password (e.g., abcd efgh ijkl mnop) and replace your-app-password with it (remove spaces).
    - Example: [smtp.gmail.com]:587 your-address@gmail.com:abcdefghijklmnop

## License
This project is unlicensed—use it freely for testing purposes.
