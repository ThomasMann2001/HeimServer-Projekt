# Storage Layout

This document describes the current storage layout of my Unraid-based homelab.

The goal of the storage design is to separate different workload types instead of placing everything on one disk or pool. Application data, long-term storage, backups, private data and lab workloads each have their own role.

---

## Storage Overview

| Device | Model | Capacity | Purpose |
|---|---:|---:|---|
| NVMe SSD | WD Red SN700 | 500 GB | AppData, Docker data and cache |
| HDD | WDC WD80EFPX | 8 TB | Main data disk |
| HDD | Parity disk | 8 TB | Unraid parity protection |
| HDD | WDC WD40EFRX | 4 TB | Local backup target |
| HDD | Private data disk | 4 TB | Private and important data |
| SATA SSD | Micron 1100 MTFDDAK256TBN | 256 GB | Virtual machines, testing and experiments |

Additional SATA connectivity is provided through an M.2 PCIe SATA expansion adapter. This allows the compact Jonsbo N6 build to use more drive bays than the mainboard alone would provide.

---

## Design Goals

The storage layout follows a few simple principles:

- Keep Docker AppData and cache workloads on SSD storage
- Use the Unraid array for long-term data storage
- Use parity for disk availability
- Keep backups separate from normal productive data
- Keep private and important data separated from general storage
- Use a separate SSD for virtual machines, testing and lab workloads
- Keep the layout understandable and easy to expand later

---

## NVMe SSD - AppData and Cache

The WD Red SN700 NVMe SSD is used for AppData, Docker data and cache-related workloads.

This keeps frequently changing application data away from the slower HDD array and improves responsiveness for containerized services.

Typical data on this SSD includes:

- Docker AppData
- Application databases
- Container configuration data
- Cache workloads
- Frequently changing service data

This data is important for service recovery and is included in the AppData backup strategy.

---

## Unraid Array

The Unraid array is used for long-term data storage.

The current main data disk is an 8 TB WDC WD80EFPX. The array also uses an 8 TB parity disk.

The parity disk is at least as large as the largest data disk in the array, which is required for Unraid parity protection. With parity active, the array can tolerate the failure of one data disk.

Parity is not treated as a backup. It does not protect against accidental deletion, corruption, ransomware, misconfiguration or user mistakes.

---

## Private Data Disk

A separate 4 TB disk is used for private and important data.

The goal is to keep sensitive personal data separated from general-purpose storage. Since parity is active, this disk is also protected by Unraid parity against a single data disk failure.

Private data is still included in the backup planning separately. Parity only helps with availability and does not replace backups.

---

## Local Backup Disk

A dedicated 4 TB HDD is used as a local backup target.

This disk is used for selected AppData and share-level backups. It is separated from the normal productive storage layout to reduce the risk of mixing active data and backup data.

The local backup disk is useful for quick restores, but it is not the final backup concept. An offsite backup target is still planned for important data.

More details: [Backup Strategy](backup-strategy.md)

---

## SATA SSD - VMs and Lab Workloads

A separate 256 GB SATA SSD is used for virtual machines, testing and lab workloads.

The purpose of this disk is to keep experimental workloads away from the main data array and from important Docker AppData.

Example use cases:

- Virtual machines
- Temporary test environments
- Lab workloads
- Experiments that should not affect productive data

---

## Hardware and Drive Bays

The system is built in a Jonsbo N6 case. The case provides enough drive bays for parity, data disks, backup storage, private data and future expansion.

Drive labels, serial numbers and barcodes are intentionally redacted before publishing screenshots.

---

## Backup Considerations

The storage layout is designed with backups in mind.

Important points:

- AppData is backed up separately because it is required for service recovery.
- Selected user data is backed up weekly.
- Mostly static archive data is backed up monthly.
- The local backup disk is only one backup layer.
- Offsite backup is still planned for important data.
- Parity is not considered a backup.

---

## Future Expansion

The current storage layout is sufficient for now.

The Jonsbo N6 still provides enough drive bays for future expansion if storage requirements change later. At the moment, no additional data disk is planned.

Possible future improvements:

- Add offsite backup storage
- Add more storage if data requirements increase
- Improve restore documentation
- Document restore tests
- Add more monitoring for disk health and backup jobs

---

## Summary

The storage layout separates different workload types into clear roles:

- NVMe SSD for AppData, Docker data and cache
- Unraid array for long-term data storage
- Active parity for single data disk failure protection
- Dedicated local backup disk
- Separate private data disk
- Separate SATA SSD for VMs and lab workloads

This keeps the system easier to understand, easier to maintain and safer to expand over time.
