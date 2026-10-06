# Backup Strategy

This document describes how I currently handle backups in my Unraid homelab.

I separate three things that are easy to mix up:

- parity for disk availability
- local backups for quick restores
- offsite backups for real disaster recovery

Parity is active, but I do not treat it as a backup.

---

## What I want from the backup setup

The backup setup should help me recover from realistic problems, not just from a failed disk.

The most important cases are:

- a broken Docker container update
- accidental deletion
- wrong configuration changes
- corrupted application data
- restoring important shares
- rebuilding the system without guessing where important data was stored
- losing the whole server, for example through theft, fire or ransomware

The setup now covers AppData backups, selected share-level backups, a dedicated local backup disk and an offsite backup for important data.

---

## Parity vs Backup

The Unraid array uses active parity protection.

Parity protects against the failure of a single data disk. That is useful, but it only helps with availability.

It does not protect against:

- accidental deletion
- file corruption
- ransomware
- broken updates
- misconfiguration
- user mistakes
- complete system loss
- theft, fire or water damage

Backups are planned separately from parity.

---

## Current Backup Layers

| Layer | Status | Purpose |
|---|---|---|
| Unraid parity | Implemented | Protection against a single data disk failure |
| AppData backup | Implemented | Recovery of Docker applications and service state |
| Weekly share backup | Implemented | Backup of photos and selected important data |
| Monthly share backup | Implemented | Backup of mostly static archive data |
| Local backup disk | Implemented | Dedicated local backup target |
| Offsite backup | Implemented | Protection against local system loss |
| Backup monitoring | Implemented | Alerts when a backup job fails or does not run |

---

## AppData Backup

AppData is one of the most important parts of the system. It contains the configuration and state of many Docker services.

Typical AppData contents:

- container configuration
- application databases
- reverse proxy configuration
- DNS/filtering configuration
- smart home service data
- password manager service data

If I had to rebuild the server, AppData would be one of the first things I would need back.

Services like Vaultwarden, Home Assistant, AdGuard Home and Nginx Proxy Manager are especially important for restore planning.

---

## Share-Level Backups

Share-level backups are used for selected user data.

The schedule depends on how often the data changes.

| Backup Type | Schedule | Retention | Scope |
|---|---:|---:|---|
| Weekly backup | `0 5 * * 1` | 8 versions | Photos and selected important data |
| Monthly backup | `30 5 1 * *` | 6 versions | Mostly static archive data |

I do not back up every share with the same frequency. Data that changes more often gets a shorter backup interval. Mostly static archive data is backed up less often.

---

## Local Backup Target

A dedicated 4 TB HDD is used as the local backup target.

This disk is separated from normal productive storage. I use it for quick restores and for keeping versioned copies of selected data.

The local backup disk is useful for:

- restoring deleted files
- rolling back selected folders
- recovering service data after a failed update
- quick restores without depending on the internet connection

It is still only a local backup. If the whole server is lost, this disk would likely be lost as well. That is why the offsite backup exists.

---

## Offsite Backup

The offsite backup is the last layer of the setup. It covers the case where the server and the local backup disk are both gone.

The offsite target is a Raspberry Pi with a dedicated 4 TB HDD at an offsite location. It connects to my network as a WireGuard client of the UniFi gateway (client-to-site), in its own VPN network separate from my remote devices. Only the Raspberry Pi itself is part of the tunnel, not the network at the offsite location.

| Part | Implementation |
|---|---|
| Backup tool | restic |
| Target | rest-server on the Raspberry Pi |
| Transport | WireGuard tunnel, client-to-site |
| Encryption | restic repository encryption |
| Schedule | Weekly, through Unraid User Scripts |
| Scope | Photos, important personal data, notes and Vaultwarden AppData |
| Monitoring | Uptime Kuma push monitor and Home Assistant notification |

restic backs up directly from the source shares, not from the local backup disk. This way the offsite copy does not depend on the local backup job being healthy.

### Append-only mode

The rest-server runs in append-only mode. The Unraid server can create new snapshots, but it cannot delete or overwrite existing ones.

For me, this is the most important part of the offsite design. If the Unraid server were compromised, for example by ransomware, an attacker still could not remove the offsite snapshots from the server side. I tested this: a `restic forget` from the Unraid server is rejected by the rest-server.

### Access to the offsite target

The offsite target is treated like an untrusted device in my network:

- only the Unraid server can reach it, and only on the services it actually needs
- the Raspberry Pi cannot open connections into my internal networks
- the rest-server only listens on the tunnel address and uses its own credentials
- SSH access is key-based only

### Consistency for Vaultwarden

Vaultwarden uses a database. To get a consistent snapshot, the backup script stops the Vaultwarden container for a short moment, runs the backup for its AppData and starts the container again right after.

### Monitoring

The weekly job reports to an Uptime Kuma push monitor. If the job fails or does not report in time, Uptime Kuma raises an alert. Home Assistant sends a push notification to my phone as a second alert path.

I tested the script against 14 failure scenarios before trusting it.

---

## Backup Script Approach

Share-level backups are handled through rsync-based scripts managed by the Unraid User Scripts plugin. The offsite backup uses a separate restic-based User Script.

The scripts are intentionally simple and readable. I prefer something I can understand later over a backup setup that works like magic until it breaks.

The current approach:

- separate jobs for different backup scopes
- clear schedules
- versioned backup directories and snapshots
- limited retention for the local backups
- monitoring for the offsite job
- sanitized public example script

A sanitized example is available here:

- [Share backup example](../scripts/share-backup-example.sh)

The public script is generic and does not contain my real private share names or paths.

---

## Retention

The backup jobs keep multiple versions instead of only the newest copy.

Current retention:

| Backup Type | Versions Kept |
|---|---:|
| Weekly backups | 8 |
| Monthly backups | 6 |
| Offsite backups | All snapshots, retention not set up yet |

Because the offsite repository is append-only, old snapshots cannot be removed from the Unraid server. Cleaning up has to happen on the offsite side. This is not set up yet, so at the moment all offsite snapshots are kept.

---

## Restore Planning

A backup is only useful if I know how to restore it.

The most important restore scenarios for me are:

- restore Docker AppData
- restore a selected share or folder
- bring DNS and reverse proxy services back quickly
- restore Home Assistant and MQTT/Zigbee services
- restore sensitive services like Vaultwarden carefully
- restore important data from the offsite backup after a complete server loss

Restore documentation is still something I want to improve. The next step is not only having backups, but also documenting test restores.

---

## Data Priority

Not all data has the same backup priority.

| Data Type | Priority | Backup Approach |
|---|---|---|
| AppData and service state | High | AppData backup |
| Password manager data | High | AppData backup, offsite backup and higher restore priority |
| Smart home configuration | High | AppData backup |
| Photos and important user data | High | Weekly backup and offsite backup |
| Private important data | High | Included in backup planning and offsite backup |
| Mostly static archive data | Medium | Monthly backup |
| Temporary test data | Low | Usually not backed up |
| Lab workloads | Low to medium | Depends on importance |

This helps me avoid wasting backup space on data that is temporary or easy to recreate.

---

## 3-2-1 Status

With the offsite backup in place, the important data now follows the 3-2-1 idea:

- primary data on the Unraid server
- a second copy on the dedicated local backup disk
- a third copy at an offsite location
- the offsite copy is protected against deletion from the server side

Still missing:

- documented restore tests
- a retention process for the offsite repository

---

## Open Points

Things I still want to improve:

- document AppData restore steps
- document selected share restore steps
- test restores and write down the results
- set up retention for the offsite repository
- review backup coverage when new services are added
