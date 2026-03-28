#!/bin/bash
set -e

KEYS_DIR=/etc/asterisk/keys
CERT=$KEYS_DIR/asterisk.pem
KEY=$KEYS_DIR/asterisk.key
IP=${ASTERISK_IP:-127.0.0.1}

echo "==> Asterisk Docker Entrypoint"
echo "    IP:          $IP"
echo "    PG Host:     $PG_HOST:$PG_PORT"
echo "    PG DB:       $PG_DB"

# ── 1. Generate self-signed cert if not present ───────────────────────────────
mkdir -p $KEYS_DIR
if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
    echo "==> Generating TLS certificate for $IP"
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
        -subj "/C=US/ST=State/L=City/O=CRM/CN=$IP" \
        -addext "subjectAltName=IP:$IP,IP:127.0.0.1,DNS:localhost,DNS:asterisk.local" \
        -keyout $KEY \
        -out $CERT
    echo "==> Certificate generated"
else
    echo "==> Using existing certificate"
fi
chmod 640 $CERT $KEY
chown asterisk:asterisk $CERT $KEY

# ── 2. Inject env vars into config templates ──────────────────────────────────
echo "==> Writing Asterisk configs"

# pjsip.conf — inject IP into webrtc_endpoint template
sed -i "s|media_address=ASTERISK_IP_PLACEHOLDER|media_address=$IP|g" /etc/asterisk/pjsip.conf
sed -i "s|media_address=127.0.0.1|media_address=$IP|g" /etc/asterisk/pjsip.conf

# extensions.conf — inject GSM gateway IP for outbound
GSM_IP=${GSM_GATEWAY_IP:-192.168.0.200}
sed -i "s|GSM_GATEWAY_IP_PLACEHOLDER|$GSM_IP|g" /etc/asterisk/extensions.conf
sed -i "s|cert_file=.*|cert_file=$CERT|g" /etc/asterisk/pjsip.conf
sed -i "s|priv_key_file=.*|priv_key_file=$KEY|g" /etc/asterisk/pjsip.conf
sed -i "s|dtls_cert_file=.*|dtls_cert_file=$CERT|g" /etc/asterisk/pjsip.conf
sed -i "s|dtls_private_key=.*|dtls_private_key=$KEY|g" /etc/asterisk/pjsip.conf

# rtp.conf — inject localnet so Asterisk knows its own network
cat > /etc/asterisk/rtp.conf << EOF
[general]
rtpstart=10000
rtpend=20000
icesupport=yes
stunaddr=stun.l.google.com:19302
; localnet tells Asterisk which IPs are local — critical for correct RTP routing
localnet=0.0.0.0/0
EOF

# http.conf — inject cert
sed -i "s|tlscertfile=.*|tlscertfile=$CERT|g" /etc/asterisk/http.conf
sed -i "s|tlsprivatekey=.*|tlsprivatekey=$KEY|g" /etc/asterisk/http.conf

# manager.conf — inject AMI secret
sed -i "s|secret = .*|secret = $AMI_SECRET|g" /etc/asterisk/manager.conf

# ari.conf — inject password and allowed origins
sed -i "s|password = .*|password = $ARI_PASSWORD|g" /etc/asterisk/ari.conf
sed -i "s|allowed_origins = .*|allowed_origins = $ALLOWED_ORIGINS|g" /etc/asterisk/ari.conf

# res_pgsql.conf — inject DB connection
cat > /etc/asterisk/res_pgsql.conf << EOF
[general]
dbhost=$PG_HOST
dbport=$PG_PORT
dbname=$PG_DB
dbuser=$PG_USER
dbpass=$PG_PASSWORD
requirements=warn
EOF

# cdr_pgsql.conf
cat > /etc/asterisk/cdr_pgsql.conf << EOF
[global]
hostname=$PG_HOST
dbname=$PG_DB
table=cdr
password=$PG_PASSWORD
user=$PG_USER
port=$PG_PORT
EOF

# cel_pgsql.conf
cat > /etc/asterisk/cel_pgsql.conf << EOF
[global]
hostname=$PG_HOST
dbname=$PG_DB
table=cel
password=$PG_PASSWORD
user=$PG_USER
port=$PG_PORT
EOF

# ── 3. Wait for PostgreSQL ────────────────────────────────────────────────────
echo "==> Waiting for PostgreSQL at $PG_HOST:$PG_PORT"
until PGPASSWORD=$PG_PASSWORD psql -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -c "SELECT 1" > /dev/null 2>&1; do
    echo "    PostgreSQL not ready, retrying in 2s..."
    sleep 2
done
echo "==> PostgreSQL ready"

# ── 4. Sync media_address in realtime DB ─────────────────────────────────────
# This fixes one-way audio — ensures ALL endpoints in ps_endpoints use the
# correct LAN IP for RTP, including agent extensions and trunk endpoints.
# Runs on every container start so IP changes are always picked up.
echo "==> Syncing media_address=$IP in ps_endpoints"
PGPASSWORD=$PG_PASSWORD psql -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -c \
    "UPDATE ps_endpoints SET media_address='$IP', dtls_cert_file='$CERT', dtls_private_key='$KEY' WHERE media_address IS NULL OR media_address='' OR media_address='127.0.0.1';" \
    2>/dev/null && echo "==> ps_endpoints synced" || echo "==> ps_endpoints sync skipped (table may be empty)"

# ── 5. Fix ownership ─────────────────────────────────────────────────────────
chown -R asterisk:asterisk /etc/asterisk /var/spool/asterisk /var/lib/asterisk /var/log/asterisk 2>/dev/null || true

# ── 6. Start Asterisk ─────────────────────────────────────────────────────────
echo "==> Starting Asterisk"
exec asterisk -f -C /etc/asterisk/asterisk.conf
