# Backup Strategy

This document describes the backup approach for my Unraid homelab.

The goal is to protect the data and service configurations that would be annoying or time-consuming to rebuild. I do not back up every dataset with the same frequency. Instead, the backup schedule depends on how often the data changes and how important it is for recovery.

## Backup Goals

The main goals are:

- Keep Docker AppData recoverable
- Back up important user data on a regular schedule
- Keep backup targets separated from normal productive storage
- Avoid unnecessary full backups of rarely changed data
- Prepare the setup for an offsite backup target
- Move toward a complete 3-2-1 backup strategy

## Backup Overview

| Backup Type | Schedule | Scope | Purpose |
|---|---:|---|---|
| AppData Backup | Scheduled | Docker AppData and service state | Restore container configurations and application data |
| Weekly Backup | `0 5 * * 1` | Photos and selected important data | Protect data that changes more often |
| Monthly Backup | `30 5 1 * *` | Mostly static archive data | Back up data that rarely changes |
| Offsite Backup | Planned | Critical data | Complete the 3-2-1 backup strategy |

## AppData Backup

AppData is one of the most important parts of the system because it contains the state and configuration of many Docker services.

Typical AppData contents:

- Container configuration
- Application state
- Databases
- Service-specific files
- Reverse proxy configuration
- Home Assistant configuration
- Password manager data

Backing up AppData makes it possible to restore services without rebuilding the whole environment from scratch.

## Weekly Backup

The weekly backup runs every Monday at 05:00.

Cron schedule:

```cron
0 5 * * 1
```

This backup is used for data that changes more often and should be protected regularly.

Current focus:

- Photos
- Selected important user data

The weekly schedule is a compromise between protection and storage usage. It is frequent enough for important data, but not as heavy as a daily full backup.

## Monthly Backup

The monthly backup runs on the first day of the month at 05:30.

Cron schedule:

```cron
30 5 1 * *
```

This backup is used for mostly static data that does not change often.

Current focus:

- General data archive
- Rarely changed files
- Long-term storage data

A monthly schedule is enough here because this data does not change frequently.

## Local Backup Target

A dedicated 4 TB HDD is used as the local backup target.

The backup share is intentionally restricted to the required disk. This keeps the backup target separated from normal storage and avoids unnecessary access to other disks.

This local backup target is useful for quick restores, but it is not a complete backup strategy on its own. An offsite backup target is still planned for important data.

## Parity vs Backup

Unraid parity and backups have different purposes.

Parity helps with availability. Once parity is active, the array can tolerate the failure of one data disk.

Backups protect against other risks, for example:

- Accidental deletion
- Broken application updates
- File corruption
- Misconfiguration
- Ransomware
- Complete system loss
- User error

Because of that, parity is not treated as a replacement for backups.

## 3-2-1 Backup Roadmap

The current setup already includes local backups, but the full 3-2-1 strategy is still in progress.

Current state:

- Primary data on the Unraid array
- Local backup disk for selected data
- AppData backup for service recovery
- Weekly and monthly backup schedules

Planned improvements:

- Add an offsite backup target for critical data
- Document restore procedures
- Test sample restores regularly
- Add basic backup monitoring or notifications

## Restore Priorities

In case of a failure, the restore priority would be:

1. Unraid configuration
2. AppData and Docker service state
3. DNS and reverse proxy services
4. Password manager
5. Home Assistant and MQTT stack
6. Photos and private data
7. Less critical archive data
8. Lab and test workloads

## Current Limitations

The current backup setup is useful, but not final.

Known limitations:

- Offsite backup is not implemented yet
- Restore tests still need to be documented
- Backup monitoring can be improved
- Backup scripts should be cleaned up and anonymized before publishing

## Next Steps

Planned next steps:

- Add offsite backup for critical data
- Document at least one restore test
- Add sanitized example backup scripts
- Review backup permissions
- Add notification or monitoring for failed backup jobs
```
