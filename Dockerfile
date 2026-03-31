FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    asterisk \
    asterisk-config \
    asterisk-modules \
    asterisk-core-sounds-en \
    asterisk-moh-opsound-wav \
    postgresql-client \
    openssl \
    gettext-base \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy all config templates
COPY asterisk/config/ /etc/asterisk/

# Copy schema — applied on every start against whatever DB is configured
COPY postgres/init.sql /docker-entrypoint-initdb.d/init.sql

# Copy entrypoint
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Asterisk ports
# 5060 UDP  — SIP (trunk/GSM gateway)
# 8088 TCP  — HTTP
# 8089 TCP  — HTTPS/WSS (WebRTC)
# 5038 TCP  — AMI
# 10000-20000 UDP — RTP
EXPOSE 5060/udp 8088 8089 5038

CMD ["/entrypoint.sh"]
