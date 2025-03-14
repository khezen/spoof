# Use Alpine Linux as the base image
FROM alpine:3.19

# Install Postfix and Go
RUN apk add --no-cache \
    postfix \
    go \
    && mkdir -p /var/spool/postfix/public \
    && chown postfix:postfix /var/spool/postfix/public \
    && chmod 755 /var/spool/postfix/public

# Copy Postfix configuration files from etc/postfix/
COPY etc/postfix/main.cf /etc/postfix/main.cf
COPY etc/postfix/master.cf /etc/postfix/master.cf

# Copy the Go script
COPY cmd/spoof/main.go /app/cmd/spoof/main.go

# Copy the entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set working directory
WORKDIR /app

# Expose the high port (2525)
EXPOSE 2525

# Use the entrypoint script to start Postfix and run the Go script
ENTRYPOINT ["/app/entrypoint.sh"]