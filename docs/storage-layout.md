# Storage Layout

This document describes the current storage layout of my Unraid homelab.

I try to keep storage roles separated instead of putting everything on one disk or pool. AppData, long-term data, backups, private data and lab workloads each have a clear place.

---

## Disk Layout

| Device | Model | Capacity | Role |
|---|---:|---:|---|
| NVMe SSD | WD Red SN700 | 500 GB | AppData, Docker data and cache |
| HDD | WDC WD80EFPX | 8 TB | Main data disk |
| HDD | Parity disk | 8 TB | Unraid parity protection |
| HDD | WDC WD40EFRX | 4 TB | Local backup target |
| HDD | Private data disk | 4 TB | Private and important data |
| SATA SSD | Micron 1100 MTFDDAK256TBN | 256 GB | VMs, testing and lab workloads |

Additional SATA connectivity is provided through an M.2 PCIe SATA expansion adapter. This allows the Jonsbo N6 build to use more drive bays than the mainboard alone would provide.

---

## Storage Roles

| Storage Area | Purpose |
|---|---|
| NVMe SSD | Fast storage for Docker AppData, databases and frequently changing service data |
| Unraid array | Long-term data storage |
| Parity disk | Protection against a single data disk failure |
| Local backup disk | Backup target for selected data |
| Private data disk | Separate storage for private and important data |
| SATA SSD | Virtual machines, tests and lab workloads |

The layout is not meant to be overly complex. I mainly want to avoid mixing temporary workloads, important AppData, long-term data and backups without a clear reason.

---

## NVMe SSD - AppData and Cache

The WD Red SN700 NVMe SSD is used for Docker AppData, container data and cache-related workloads.

This keeps frequently changing application data away from the HDD array and makes services feel more responsive.

Typical data on this SSD includes:

- Docker AppData
- application databases
- container configuration
- frequently changing service data
- cache workloads

This data is important for service recovery and is included in the AppData backup strategy.

---

## Unraid Array and Parity

The Unraid array is used for long-term data storage.

The current main data disk is an 8 TB WDC WD80EFPX. The array also has an active 8 TB parity disk.

Parity protects against the failure of one data disk, but it is not a backup. It does not protect against accidental deletion, corruption, ransomware, misconfiguration or user mistakes.

I keep this separation clear because it is easy to treat parity as more than it actually is.

---

## Private Data Disk

A separate 4 TB disk is used for private and important data.

The reason for separating it is mostly operational: I want private data to have a clear place in the storage layout instead of being mixed into random general-purpose shares.

This disk is protected by Unraid parity like the other data disks in the array, but it still needs separate backup planning.

---

## Local Backup Disk

A dedicated 4 TB HDD is used as the local backup target.

It is separated from normal productive storage and used for selected AppData and share-level backups. This makes quick restores easier and keeps backup data away from day-to-day storage.

The local backup disk is useful, but it is still only local. Offsite backup is still planned for important data.

More details: [Backup Strategy](backup-strategy.md)

---

## SATA SSD - VMs and Lab Workloads

A separate 256 GB SATA SSD is used for virtual machines, testing and lab workloads.

I use this disk to keep experimental workloads away from the main array and away from important Docker AppData.

Example use cases:

- virtual machines
- temporary test environments
- lab workloads
- experiments that should not affect productive data

---

## Hardware and Drive Bays

The system is built in a Jonsbo N6 case. The case gives the build enough drive bays for parity, data disks, backup storage, private data and future expansion.

The current layout is sufficient for now, but the case leaves room to expand later if storage requirements change.

---

## Backup Considerations

The storage layout is planned around restore scenarios.

Important points:

- AppData is backed up separately because it is required for service recovery.
- Selected user data is backed up weekly.
- Mostly static archive data is backed up monthly.
- The local backup disk is only one backup layer.
- Offsite backup is still planned.
- Parity is not considered a backup.

---

## Expansion Notes

At the moment, no additional data disk is planned.

Possible future changes:

- add offsite backup storage
- add more storage if data requirements increase
- document restore tests
- improve monitoring for disk health and failed backup jobs
