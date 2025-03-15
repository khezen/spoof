FROM alpine:3.19

RUN apk add --no-cache \
    postfix \
    go \
    cyrus-sasl \
    ca-certificates \
    rng-tools \
    && mkdir -p /var/spool/postfix/public /var/log /var/mail \
    && chown postfix:postdrop /var/spool/postfix/public \
    && chgrp -R postdrop /var/spool/postfix \
    && chmod 755 /var/spool/postfix/public /var/log /var/mail \
    && echo "127.0.0.1 localhost" >> /etc/hosts

COPY etc/postfix/main.cf /etc/postfix/main.cf
COPY etc/postfix/master.cf /etc/postfix/master.cf
COPY etc/postfix/sasl_passwd /etc/postfix/sasl_passwd
COPY cmd/spoof/main.go /app/cmd/spoof/main.go
COPY entrypoint.sh /app/entrypoint.sh

# Set permissions
RUN chmod +x /app/entrypoint.sh \
    && chmod 600 /etc/postfix/sasl_passwd \
    && chown root:root /etc/postfix/sasl_passwd

WORKDIR /app
EXPOSE 2525
ENTRYPOINT ["/app/entrypoint.sh"]