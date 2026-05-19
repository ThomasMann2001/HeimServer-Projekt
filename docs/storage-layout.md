# Storage Layout

This document describes how storage is currently planned and used in my Unraid homelab.

The main idea is to keep application data, user data, backups and lab workloads separated as much as possible. This makes the system easier to maintain, back up and expand later.

## Storage Overview

| Device | Model | Capacity | Purpose |
|---|---:|---:|---|
| NVMe SSD | WD Red SN700 | 500 GB | AppData, Docker data and cache |
| HDD | WDC WD80EFPX | 8 TB | Main data disk |
| HDD | Planned parity disk | 8 TB or larger | Unraid parity protection |
| HDD | WDC WD40EFRX | 4 TB | Local backup target |
| HDD | Private data disk | 4 TB planned | Private and important data |
| HDD | Additional data disk | 8 TB or larger planned | Future expansion if required |
| SATA SSD | Micron 1100 MTFDDAK256TBN | 256 GB | Virtual machines, testing and experiments |

## Design Principles

The storage layout is based on clear roles:

- The NVMe SSD is used for AppData, Docker workloads and cache.
- The main HDD is used for persistent user data.
- A dedicated parity disk is planned to protect the Unraid array against a single disk failure.
- A separate HDD is used as a local backup target.
- Private and important data will be separated onto its own disk once the planned storage layout is complete.
- The SATA SSD is reserved for VMs, testing and experiments.
- Future expansion is planned with an additional 8 TB or larger disk if the current capacity is no longer enough.

## Cache and AppData

The WD Red SN700 NVMe SSD is used for AppData and cache workloads.

This keeps container data and application state separate from the larger HDD-based array. It also makes it easier to back up and restore services, because most container-related data is stored in one clearly defined place.

Typical data stored here:

- Docker AppData
- Container configuration
- Application state
- Databases used by self-hosted services
- Cache data before it is moved to the array

## Array Design

The Unraid array is used for long-term data storage.

The current main data disk is an 8 TB WDC WD80EFPX. A parity disk of at least 8 TB is planned, because the parity disk must be at least as large as the largest data disk in the array.

Once parity is active, the array can tolerate the failure of one data disk. I still treat parity only as availability protection, not as a replacement for backups.

## Backup Disk

The 4 TB WDC WD40EFRX is used as a dedicated local backup target.

The backup share is intentionally restricted to the required disk. This keeps the backup target separated from normal storage and avoids unnecessary access to other disks.

This local backup is useful for quick restores, but it is not a complete 3-2-1 backup strategy on its own. An offsite backup target is planned for important data.

## Private Data Disk

A separate 4 TB disk is planned for private and important data.

The goal is to keep sensitive personal data separate from general-purpose storage. Once parity is active and the disk is added to the array, this data will also be covered by Unraid parity protection.

## VM and Lab SSD

The Micron 1100 SATA SSD is reserved for virtual machines, testing and experiments.

I do not want temporary lab workloads mixed with productive data or backup targets. Keeping this on a separate SSD makes it easier to test things without affecting the main storage layout.

## Future Expansion

The system is prepared for additional storage if needed.

The next expansion would likely be an additional 8 TB or larger HDD. If a disk larger than 8 TB is added later, the parity disk would also need to be at least that size.

For now, expansion depends on actual storage usage. If the current 8 TB data disk remains sufficient, the additional disk can be delayed.
