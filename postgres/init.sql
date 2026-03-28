-- Asterisk CRM Realtime Database Schema
-- All tables required for full realtime operation

CREATE TABLE IF NOT EXISTS ps_endpoints (
    id VARCHAR(40) NOT NULL PRIMARY KEY,
    transport VARCHAR(40), aors VARCHAR(200), auth VARCHAR(40),
    context VARCHAR(40), disallow VARCHAR(200) DEFAULT 'all',
    allow VARCHAR(200) DEFAULT 'opus,ulaw,alaw',
    direct_media VARCHAR(3) DEFAULT 'no', dtmf_mode VARCHAR(20) DEFAULT 'rfc4733',
    external_media_address VARCHAR(40), force_rport VARCHAR(3) DEFAULT 'yes',
    ice_support VARCHAR(3) DEFAULT 'yes', identify_by VARCHAR(80),
    mailboxes VARCHAR(40), moh_suggest VARCHAR(40) DEFAULT 'default',
    outbound_auth VARCHAR(40), outbound_proxy VARCHAR(40),
    rewrite_contact VARCHAR(3) DEFAULT 'yes', rtp_ipv6 VARCHAR(3) DEFAULT 'no',
    rtp_symmetric VARCHAR(3) DEFAULT 'yes', send_diversion VARCHAR(3) DEFAULT 'yes',
    send_pai VARCHAR(3) DEFAULT 'no', send_rpid VARCHAR(3) DEFAULT 'no',
    timers_min_se INTEGER DEFAULT 90, timers VARCHAR(3) DEFAULT 'yes',
    timers_sess_expires INTEGER DEFAULT 1800, callerid VARCHAR(100),
    callerid_privacy VARCHAR(40), callerid_tag VARCHAR(40),
    "100rel" VARCHAR(3) DEFAULT 'yes', aggregate_mwi VARCHAR(3) DEFAULT 'yes',
    trust_id_inbound VARCHAR(3) DEFAULT 'no', trust_id_outbound VARCHAR(3) DEFAULT 'no',
    use_ptime VARCHAR(3) DEFAULT 'no', use_avpf VARCHAR(3) DEFAULT 'yes',
    media_encryption VARCHAR(20) DEFAULT 'dtls', inband_progress VARCHAR(3) DEFAULT 'no',
    call_group VARCHAR(40), pickup_group VARCHAR(40),
    named_call_group VARCHAR(40), named_pickup_group VARCHAR(40),
    device_state_busy_at INTEGER DEFAULT 0, t38_udptl VARCHAR(3) DEFAULT 'no',
    fax_detect VARCHAR(3) DEFAULT 'no', t38_udptl_nat VARCHAR(3) DEFAULT 'no',
    t38_udptl_ipv6 VARCHAR(3) DEFAULT 'no', tone_zone VARCHAR(40), language VARCHAR(40),
    one_touch_recording VARCHAR(3) DEFAULT 'no',
    record_on_feature VARCHAR(40) DEFAULT 'automixmon',
    record_off_feature VARCHAR(40) DEFAULT 'automixmon',
    rtp_engine VARCHAR(40) DEFAULT 'asterisk',
    allow_transfer VARCHAR(3) DEFAULT 'yes', allow_subscribe VARCHAR(3) DEFAULT 'yes',
    sdp_owner VARCHAR(40) DEFAULT '-', sdp_session VARCHAR(40) DEFAULT 'Asterisk',
    tos_audio INTEGER DEFAULT 0, tos_video INTEGER DEFAULT 0,
    sub_min_expiry INTEGER DEFAULT 0, from_domain VARCHAR(40), from_user VARCHAR(40),
    mwi_from_user VARCHAR(40), dtls_verify VARCHAR(40) DEFAULT 'fingerprint',
    dtls_rekey INTEGER DEFAULT 0,
    dtls_cert_file VARCHAR(200) DEFAULT '/etc/asterisk/keys/asterisk.pem',
    dtls_private_key VARCHAR(200) DEFAULT '/etc/asterisk/keys/asterisk.key',
    dtls_cipher VARCHAR(200), dtls_ca_file VARCHAR(200), dtls_ca_path VARCHAR(200),
    dtls_setup VARCHAR(20) DEFAULT 'active', dtls_fingerprint VARCHAR(40) DEFAULT 'SHA-256',
    srtp_tag_32 VARCHAR(3) DEFAULT 'no',
    media_use_received_transport VARCHAR(3) DEFAULT 'yes',
    rtcp_mux VARCHAR(3) DEFAULT 'yes', webrtc VARCHAR(3) DEFAULT 'yes',
    dtls_auto_generate_cert VARCHAR(3) DEFAULT 'no',
    rtp_keepalive INTEGER DEFAULT 15, bundle VARCHAR(3) DEFAULT 'no',
    max_audio_streams INTEGER DEFAULT 1, max_video_streams INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS ps_contacts (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    uri VARCHAR(511),
    expiration_time BIGINT,
    qualify_frequency INTEGER DEFAULT 0,
    outbound_proxy VARCHAR(255),
    path TEXT,
    user_agent VARCHAR(255),
    qualify_timeout FLOAT DEFAULT 3.0,
    reg_server VARCHAR(20),
    authenticate_qualify VARCHAR(3) DEFAULT 'no',
    via_addr VARCHAR(40),
    via_port INTEGER DEFAULT 0,
    call_id VARCHAR(255),
    endpoint VARCHAR(40),
    prune_on_boot VARCHAR(3) DEFAULT 'no'
);

CREATE TABLE IF NOT EXISTS ps_endpoint_id_ips (
    id VARCHAR(40) NOT NULL PRIMARY KEY,
    endpoint VARCHAR(40),
    match VARCHAR(80),
    srv_lookups VARCHAR(3) DEFAULT 'yes',
    match_header VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS ps_endpoints (
    id VARCHAR(40) NOT NULL PRIMARY KEY,
    contact VARCHAR(255), default_expiration INTEGER DEFAULT 3600,
    mailboxes VARCHAR(80), max_contacts INTEGER DEFAULT 5,
    minimum_expiration INTEGER DEFAULT 60, remove_existing VARCHAR(3) DEFAULT 'yes',
    qualify_frequency INTEGER DEFAULT 30, authenticate_qualify VARCHAR(3) DEFAULT 'no',
    maximum_expiration INTEGER DEFAULT 7200, outbound_proxy VARCHAR(40),
    support_path VARCHAR(3) DEFAULT 'no', qualify_timeout FLOAT DEFAULT 3.0,
    voicemail_extension VARCHAR(40)
);

CREATE TABLE IF NOT EXISTS ps_auths (
    id VARCHAR(40) NOT NULL PRIMARY KEY,
    auth_type VARCHAR(20) DEFAULT 'userpass',
    nonce_lifetime INTEGER DEFAULT 32, md5_cred VARCHAR(40),
    password VARCHAR(80), realm VARCHAR(40), username VARCHAR(40)
);

CREATE TABLE IF NOT EXISTS asterisk_queues (
    name VARCHAR(80) NOT NULL PRIMARY KEY,
    musiconhold VARCHAR(80) DEFAULT 'default',
    context VARCHAR(80) DEFAULT 'default',
    timeout INTEGER DEFAULT 30, ringinuse VARCHAR(3) DEFAULT 'no',
    announce_frequency INTEGER DEFAULT 0, retry INTEGER DEFAULT 5,
    wrapuptime INTEGER DEFAULT 5, maxlen INTEGER DEFAULT 0,
    servicelevel INTEGER DEFAULT 60, strategy VARCHAR(40) DEFAULT 'rrmemory',
    joinempty VARCHAR(80) DEFAULT 'yes', leavewhenempty VARCHAR(80) DEFAULT 'no',
    reportholdtime VARCHAR(3) DEFAULT 'no', memberdelay INTEGER DEFAULT 0,
    weight INTEGER DEFAULT 0, timeoutrestart VARCHAR(3) DEFAULT 'no',
    autofill VARCHAR(3) DEFAULT 'yes', autopause VARCHAR(10) DEFAULT 'no',
    announce_holdtime VARCHAR(10) DEFAULT 'no',
    announce_position VARCHAR(10) DEFAULT 'yes'
);

CREATE TABLE IF NOT EXISTS asterisk_queue_members (
    queue_name VARCHAR(80) NOT NULL,
    interface VARCHAR(80) NOT NULL,
    uniqueid VARCHAR(80) NOT NULL,
    membername VARCHAR(80), state_interface VARCHAR(80),
    penalty INTEGER DEFAULT 0, paused INTEGER DEFAULT 0,
    user_id INTEGER, is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (queue_name, interface)
);

CREATE TABLE IF NOT EXISTS asterisk_voicemail (
    uniqueid SERIAL PRIMARY KEY,
    context VARCHAR(80) DEFAULT 'default',
    mailbox VARCHAR(80), password VARCHAR(80),
    fullname VARCHAR(80), email VARCHAR(80),
    tz VARCHAR(30) DEFAULT 'UTC',
    deletevoicemail VARCHAR(10) DEFAULT 'no',
    attach VARCHAR(20) DEFAULT 'yes',
    stamp TIMESTAMP,
    CONSTRAINT uq_voicemail_context_mailbox UNIQUE (context, mailbox)
);

CREATE TABLE IF NOT EXISTS ivr_menus (
    id SERIAL PRIMARY KEY, organization_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL, description VARCHAR(255),
    context_name VARCHAR(40) NOT NULL, greeting_file VARCHAR(200),
    timeout INTEGER DEFAULT 5, invalid_sound VARCHAR(200) DEFAULT 'invalid',
    max_retries INTEGER DEFAULT 3, is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(), updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ivr_options (
    id SERIAL PRIMARY KEY, organization_id UUID NOT NULL,
    menu_id INTEGER REFERENCES ivr_menus(id) ON DELETE CASCADE,
    digit VARCHAR(5) NOT NULL, description VARCHAR(100),
    action VARCHAR(20) NOT NULL, destination VARCHAR(80) NOT NULL,
    UNIQUE(menu_id, digit, organization_id)
);

CREATE TABLE IF NOT EXISTS asterisk_extensions (
    id SERIAL PRIMARY KEY, organization_id UUID NOT NULL,
    context VARCHAR(40), exten VARCHAR(40),
    priority INTEGER DEFAULT 1, app VARCHAR(40), appdata VARCHAR(256),
    UNIQUE(context, exten, priority, organization_id)
);

CREATE TABLE IF NOT EXISTS call_routing_rules (
    id SERIAL PRIMARY KEY, organization_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL, rule_type VARCHAR(20) NOT NULL,
    priority INTEGER DEFAULT 0, is_active BOOLEAN DEFAULT TRUE,
    time_start TIME, time_end TIME, days_of_week VARCHAR(50),
    required_skill VARCHAR(80), caller_id_pattern VARCHAR(80),
    destination_type VARCHAR(20) NOT NULL, destination VARCHAR(80) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS agent_skills (
    id SERIAL PRIMARY KEY, organization_id UUID NOT NULL,
    user_id INTEGER NOT NULL, extension VARCHAR(40) NOT NULL,
    skill VARCHAR(80) NOT NULL, level INTEGER DEFAULT 1,
    UNIQUE(user_id, skill, organization_id)
);

CREATE TABLE IF NOT EXISTS asterisk_moh (
    id SERIAL PRIMARY KEY, organization_id UUID NOT NULL,
    name VARCHAR(80) UNIQUE NOT NULL, mode VARCHAR(20) DEFAULT 'files',
    directory VARCHAR(200), is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS asterisk_moh_files (
    id SERIAL PRIMARY KEY, organization_id UUID NOT NULL,
    moh_id INTEGER REFERENCES asterisk_moh(id) ON DELETE CASCADE,
    filename VARCHAR(200), file_path VARCHAR(500), order_num INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS sim_trunks (
    id SERIAL PRIMARY KEY, organization_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL, gateway_ip INET NOT NULL,
    gateway_port INTEGER DEFAULT 5060, sim_slots INTEGER DEFAULT 1,
    sip_username VARCHAR(80) NOT NULL, sip_password VARCHAR(80) NOT NULL,
    inbound_context VARCHAR(80) DEFAULT '',
    inbound_dest_type VARCHAR(20) DEFAULT 'queue',
    inbound_dest VARCHAR(80), outbound_prefix VARCHAR(10),
    notes TEXT, is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(), updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cdr (
    id BIGSERIAL PRIMARY KEY,
    calldate TIMESTAMP NOT NULL DEFAULT NOW(),
    clid VARCHAR(80) NOT NULL DEFAULT '',
    src VARCHAR(80) NOT NULL DEFAULT '',
    dst VARCHAR(80) NOT NULL DEFAULT '',
    dcontext VARCHAR(80) NOT NULL DEFAULT '',
    channel VARCHAR(80) NOT NULL DEFAULT '',
    dstchannel VARCHAR(80) NOT NULL DEFAULT '',
    lastapp VARCHAR(80) NOT NULL DEFAULT '',
    lastdata VARCHAR(80) NOT NULL DEFAULT '',
    duration INTEGER NOT NULL DEFAULT 0,
    billsec INTEGER NOT NULL DEFAULT 0,
    disposition VARCHAR(45) NOT NULL DEFAULT '',
    amaflags INTEGER NOT NULL DEFAULT 0,
    accountcode VARCHAR(20) NOT NULL DEFAULT '',
    uniqueid VARCHAR(150) NOT NULL DEFAULT '',
    userfield VARCHAR(255) NOT NULL DEFAULT '',
    linkedid VARCHAR(150) DEFAULT '',
    sequence INTEGER DEFAULT 0,
    peeraccount VARCHAR(80) DEFAULT ''
);

CREATE TABLE IF NOT EXISTS cel (
    id BIGSERIAL PRIMARY KEY,
    eventtype VARCHAR(30) NOT NULL,
    eventtime TIMESTAMP NOT NULL DEFAULT NOW(),
    cid_name VARCHAR(80) NOT NULL DEFAULT '',
    cid_num VARCHAR(80) NOT NULL DEFAULT '',
    cid_ani VARCHAR(80) NOT NULL DEFAULT '',
    cid_rdnis VARCHAR(80) NOT NULL DEFAULT '',
    cid_dnid VARCHAR(80) NOT NULL DEFAULT '',
    exten VARCHAR(80) NOT NULL DEFAULT '',
    context VARCHAR(80) NOT NULL DEFAULT '',
    channame VARCHAR(80) NOT NULL DEFAULT '',
    appname VARCHAR(80) NOT NULL DEFAULT '',
    appdata VARCHAR(80) NOT NULL DEFAULT '',
    amaflags INTEGER NOT NULL DEFAULT 0,
    accountcode VARCHAR(20) NOT NULL DEFAULT '',
    uniqueid VARCHAR(150) NOT NULL DEFAULT '',
    linkedid VARCHAR(150) NOT NULL DEFAULT '',
    peer VARCHAR(80) NOT NULL DEFAULT '',
    userdeftype VARCHAR(255) NOT NULL DEFAULT '',
    extra VARCHAR(512) NOT NULL DEFAULT ''
);

-- Permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO asterisk;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO asterisk;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO asterisk;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO asterisk;
