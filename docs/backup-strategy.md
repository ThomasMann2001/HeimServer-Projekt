# Backup Strategy

This document describes how I currently handle backups in my Unraid homelab.

I separate three things that are easy to mix up:

- parity for disk availability
- local backups for quick restores
- offsite backups for real disaster recovery

Parity is already active, but I do not treat it as a backup.

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

For now, the setup is focused on AppData backups, selected share-level backups and a dedicated local backup disk. Offsite backup is still planned.

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
| Offsite backup | Planned | Protection against local system loss |

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
- testing backup jobs before adding offsite storage

It is still only a local backup. If the whole server is lost, this disk would likely be lost as well. That is why offsite backup is still an open point.

---

## Backup Script Approach

Share-level backups are handled through rsync-based scripts managed by the Unraid User Scripts plugin.

The scripts are intentionally simple and readable. I prefer something I can understand later over a backup setup that works like magic until it breaks.

The current approach:

- separate jobs for different backup scopes
- clear schedules
- versioned backup directories
- limited retention
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

This is a practical starting point for now. I may adjust the retention later depending on storage usage and how often I actually need older versions.

---

## Restore Planning

A backup is only useful if I know how to restore it.

The most important restore scenarios for me are:

- restore Docker AppData
- restore a selected share or folder
- bring DNS and reverse proxy services back quickly
- restore Home Assistant and MQTT/Zigbee services
- restore sensitive services like Vaultwarden carefully

Restore documentation is still something I want to improve. The next step is not only having backups, but also documenting test restores.

---

## Data Priority

Not all data has the same backup priority.

| Data Type | Priority | Backup Approach |
|---|---|---|
| AppData and service state | High | AppData backup |
| Password manager data | High | AppData backup and higher restore priority |
| Smart home configuration | High | AppData backup |
| Photos and important user data | High | Weekly backup |
| Private important data | High | Included in backup planning |
| Mostly static archive data | Medium | Monthly backup |
| Temporary test data | Low | Usually not backed up |
| Lab workloads | Low to medium | Depends on importance |

This helps me avoid wasting backup space on data that is temporary or easy to recreate.

---

## 3-2-1 Status

The setup is not a complete 3-2-1 backup strategy yet.

Current state:

- primary data on the Unraid array
- active parity protection for the array
- dedicated local backup disk
- AppData backup
- weekly and monthly share backups

Still missing:

- offsite backup for important data
- documented restore tests
- monitoring or notifications for failed backup jobs

---

## Open Points

Things I still want to improve:

- add offsite backup for important data
- document AppData restore steps
- document selected share restore steps
- test restores and write down the results
- add notifications for failed backup jobs
- review backup coverage when new services are added
