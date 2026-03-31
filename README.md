# Asterisk CRM Docker — Plug & Play Setup

## What's inside
- Asterisk 20 with full PJSIP realtime (endpoints/aors/auths from PostgreSQL)
- PostgreSQL 16 with all CRM realtime tables pre-created
- Auto TLS cert generation on first boot (self-signed with correct SAN)
- All configs injected via environment variables — no manual file editing

## Quick Start

### 1. Edit .env
```
ASTERISK_IP=192.168.X.X   ← set to this machine's LAN IP (only required change)
```

### 2. Setup host directories (run once)
```bash
bash scripts/setup-host.sh
```
This creates `/var/lib/asterisk/sounds/custom` with correct permissions so the
Django backend can write IVR audio files that Asterisk can play.

### 3. Run

**New client (no existing PostgreSQL):**
```bash
docker compose --profile with-db up -d
```

**Existing PostgreSQL already running on this machine:**
```bash
docker compose up -d
```
Make sure `PG_HOST`, `PG_USER`, `PG_PASSWORD`, `PG_DB` in `.env` match your existing DB.

### 3. Verify
```bash
# Asterisk running
docker exec asterisk_pbx asterisk -rx "core show version"

# Realtime connected
docker exec asterisk_pbx asterisk -rx "realtime show pgsql status"

# Endpoints visible
docker exec asterisk_pbx asterisk -rx "pjsip show endpoints"
```

## Ports
| Port | Protocol | Purpose |
|------|----------|---------|
| 5060 | UDP | SIP — GSM gateway / Dinstar registration |
| 8089 | TCP | WSS — WebRTC softphone |
| 8088 | TCP | HTTP |
| 5038 | TCP | AMI — Django backend |
| 5432 | TCP | PostgreSQL |
| 10000-20000 | UDP | RTP media |

## Connecting Django backend
Set these in your TelecomProvider configuration:
```
ws_server:    wss://<ASTERISK_IP>:8089/ws
sip_domain:   <ASTERISK_IP>
cdr_db_host:  <ASTERISK_IP>
cdr_db_port:  5432
cdr_db_name:  asterisk_cdr
cdr_db_user:  asterisk
cdr_db_pass:  asterisk123  (or whatever PG_PASSWORD is set to)
```

## Connecting Dinstar / GSM Gateway
In Dinstar web admin → SIP settings:
```
SIP Server:   <ASTERISK_IP>
Port:         5060
Username:     <whatever you set in CRM trunk form>
Password:     <whatever you set in CRM trunk form>
```

## Persistent data
- `postgres_data` — all DB data survives restarts
- `asterisk_keys` — TLS cert survives restarts (no re-generation)
- `asterisk_recordings` — call recordings
- `asterisk_moh` — music on hold files

## Useful commands
```bash
# Asterisk CLI
docker exec -it asterisk_pbx asterisk -r

# View logs
docker logs -f asterisk_pbx
docker logs -f asterisk_db

# Restart just Asterisk
docker compose restart asterisk

# Stop everything
docker compose down

# Full reset (wipes DB)
docker compose down -v
```
