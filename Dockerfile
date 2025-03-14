# Use Alpine Linux as the base image
FROM alpine:3.19

# Install Postfix and Go
RUN apk add --no-cache \
    postfix \
    go \
    && mkdir -p /var/spool/postfix/public \
    && chown postfix:postfix /var/spool/postfix/public \
    && chmod 755 /var/spool/postfix/public

# Copy Postfix configuration
COPY postfix_main.cf /etc/postfix/main.cf
COPY postfix_master.cf /etc/postfix/master.cf

# Copy the Go script
COPY cmd/spoof/main.go /app/spoof.go

# Copy the entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set working directory
WORKDIR /app

# Expose the high port for SMTP(2525)
EXPOSE 2525

# Use the entrypoint script to start Postfix and run the Go script
ENTRYPOINT ["/app/entrypoint.sh"]