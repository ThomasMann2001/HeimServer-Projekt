# Storage Layout

This document describes the storage design of the Unraid homelab. The goal is to separate application data, productive data, backups and experimental workloads into clearly defined storage roles.

## Storage Overview

| Device | Model | Capacity | Purpose |
|---|---:|---:|---|
| NVMe SSD | WD Red SN700 | 500 GB | AppData, Docker data and cache |
| HDD | WDC WD80EFPX | 8 TB | Main data disk for productive data |
| HDD | Planned parity disk | 8 TB or larger | Unraid parity protection |
| HDD | WDC WD40EFRX | 4 TB | Local backup target |
| HDD | Private data disk | 4 TB planned | Private/important data, parity protected once added |
| HDD | Additional data disk | 8 TB or larger planned | Future expansion if required |
| SATA SSD | Micron 1100 MTFDDAK256TBN | 256 GB | Virtual machines, testing and experiments |

## Design Principles

The storage layout follows a role-based design:

- Fast NVMe storage is used for AppData, Docker workloads and cache.
- Productive data is stored on the Unraid array.
- Important array data is protected through Unraid parity.
- Backups are stored on a dedicated backup disk.
- Experimental workloads are separated onto a dedicated SATA SSD.
- Future expansion is planned through an additional 8 TB or larger disk if required.

## Cache and AppData

The WD Red SN700 NVMe SSD is used for application data and cache workloads. This keeps container data, databases and service state separate from the larger HDD-based array.

Typical data stored here:

- Docker AppData
- Container configuration
- Application state
- Databases used by self-hosted services
- Cache workloads before data is moved to the array

## Array Design

The Unraid array is used for persistent data storage. The current main data disk is an 8 TB WDC WD80EFPX.

A parity disk of at least 8 TB is planned because the parity disk must be at least as large as the largest data disk in the array. This allows the array to tolerate a single disk failure once parity is active.

## Backup Disk

The 4 TB WDC WD40EFRX is used as a dedicated local backup target.

The backup share is intentionally restricted to the required data disk. This reduces unnecessary access to other disks and keeps the backup target separated from normal productive storage.

## Private Data Disk

A separate 4 TB disk is planned for private and important data once parity protection is active. This helps separate sensitive personal data from general-purpose storage.

## VM and Lab SSD

The Micron 1100 SATA SSD is reserved for virtual machines, testing and experiments.

This separation makes it possible to test systems and services without mixing temporary lab data with productive data or backup targets.

## Future Expansion

The system is prepared for an additional 8 TB or larger data disk if the current storage capacity becomes insufficient.

The final decision depends on future storage requirements. If the existing 8 TB data disk remains sufficient, expansion can be delayed.
