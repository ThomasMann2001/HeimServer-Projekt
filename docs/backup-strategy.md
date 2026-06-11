# Backup Strategy

This document describes the backup strategy for my Unraid-based homelab.

The goal is to separate availability, backup and restore planning. Unraid parity, local backups and future offsite backups all have different purposes and should not be treated as the same thing.

---

## Goals

The main goals of the backup strategy are:

- Protect important service data
- Make Docker services recoverable
- Back up selected user data regularly
- Separate backup data from normal productive storage
- Keep backup jobs understandable and maintainable
- Avoid backing up unnecessary temporary data
- Prepare for a future offsite backup target
- Document restore planning and limitations

---

## Important Distinction: Parity vs Backup

The Unraid array uses active parity protection.

Parity helps with availability and protects against the failure of a single data disk. It allows the system to keep data available or rebuild data when one data disk fails.

Parity is not a backup.

Parity does not protect against:

- Accidental deletion
- File corruption
- Ransomware
- Misconfiguration
- Broken updates
- User mistakes
- Complete system loss
- Theft, fire or water damage

Backups are handled separately from parity.

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

AppData is one of the most important parts of the system because it contains the state and configuration of Docker services.

Typical AppData contents include:

- Container configuration
- Application databases
- Service state
- Reverse proxy configuration
- DNS/filtering configuration
- Smart home service data
- Password manager service data

The AppData backup is used to make services recoverable after a broken update, misconfiguration, disk issue or system migration.

Important services such as Vaultwarden, Home Assistant, AdGuard Home and Nginx Proxy Manager are treated as higher-priority services for backup and restore planning.

---

## Share-Level Backups

Share-level backups are used for selected user data.

The backup schedule depends on how often the data changes.

| Backup Type | Schedule | Retention | Scope |
|---|---:|---:|---|
| Weekly backup | `0 5 * * 1` | 8 versions | Photos and selected important data |
| Monthly backup | `30 5 1 * *` | 6 versions | Mostly static archive data |

The goal is not to back up every file with the same frequency. Frequently changing data is backed up more often, while mostly static archive data is backed up less often.

Real share names and private paths are intentionally not published in this repository.

---

## Local Backup Target

A dedicated 4 TB HDD is used as the local backup target.

This disk is separated from the normal productive storage layout. The goal is to avoid mixing active data and backup data on the same logical storage area.

The local backup disk is useful for:

- Quick restores
- Recovering accidentally deleted files
- Rolling back selected data
- Restoring service data after a failed update
- Testing backup jobs before adding offsite storage

However, a local backup disk is not enough for a complete backup strategy. It does not protect against full system loss, theft, fire, water damage or other local disasters.

---

## Backup Script Approach

Share-level backups are handled through rsync-based scripts managed by the Unraid User Scripts plugin.

The backup scripts are designed to be understandable and predictable.

The general approach is:

- Use separate jobs for different backup scopes
- Use clear schedules
- Use versioned backup directories
- Keep a limited number of backup versions
- Avoid publishing private share names or internal paths
- Keep public examples sanitized

A sanitized example script is available here:

- [Share backup example](../scripts/share-backup-example.sh)

The public script is intentionally generic. It does not include real share names, private paths, internal hostnames or sensitive information.

---

## Retention Strategy

The current retention strategy keeps multiple backup versions instead of only keeping the newest copy.

This helps with cases where a problem is noticed later, for example after accidental deletion or corruption.

Current retention:

| Backup Type | Versions Kept |
|---|---:|
| Weekly backups | 8 |
| Monthly backups | 6 |

This is a practical starting point for the current storage size and importance of the data. Retention can be adjusted later if storage requirements or restore requirements change.

---

## Restore Planning

A backup is only useful if it can be restored.

Current restore planning focuses on:

- Restoring Docker AppData
- Restoring selected share data
- Understanding which services depend on which data
- Keeping backup paths and schedules documented
- Avoiding undocumented one-off backup jobs

Restore testing should be documented more clearly over time.

Planned restore documentation:

- AppData restore procedure
- Selected share restore procedure
- Service-specific restore notes
- Restore test results
- Recovery order for important services

---

## 3-2-1 Backup Status

The long-term goal is to move closer to a 3-2-1 backup strategy.

Current state:

- Primary data on the Unraid array
- Active parity protection for the array
- Dedicated local backup disk for selected data
- AppData backup for service recovery
- Weekly and monthly share backups

Still missing:

- Offsite backup for important data
- Better restore documentation
- Regular restore testing
- Monitoring/notifications for failed backup jobs

---

## Data Classification

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

This classification helps avoid wasting backup space on temporary or easily reproducible data.

---

## Security Considerations

Backup data can contain sensitive information.

For this reason:

- Real backup paths are not published
- Real share names are not published
- Secrets, keys and tokens are not included in public examples
- Screenshots are sanitized before publishing
- Backup scripts in this repository are examples only

Backup targets should also be protected from unnecessary access. A backup disk should not be treated like normal shared storage.

---

## Current Limitations

The backup setup is functional, but not finished.

Current limitations:

- Offsite backup is still planned
- Restore tests need better documentation
- Monitoring/notifications for failed backup jobs should be improved
- Long-term retention may need adjustment over time
- Backup coverage should be reviewed when new services are added

---

## Future Improvements

Planned improvements:

- Add offsite backup for important data
- Document AppData restore procedure
- Document selected share restore procedure
- Add restore test notes
- Add monitoring or notifications for failed backup jobs
- Review retention strategy over time
- Keep backup scripts and documentation aligned

---

## Summary

The backup strategy separates parity, local backups and future offsite backups.

Current state:

- Unraid parity is active
- AppData backup is implemented
- Weekly backups are implemented for photos and selected important data
- Monthly backups are implemented for mostly static archive data
- A dedicated local backup disk is used
- Offsite backup is still planned

The setup is already useful for local recovery, but the long-term goal is to improve restore documentation, testing and offsite protection.
