# Unraid Homelab Infrastructure

## Kurzbeschreibung

Dieses Repository dokumentiert mein privates Unraid-basiertes Homelab.

Der Fokus liegt auf Storage-Design, Docker-Services, Backup-Strategie inklusive Offsite-Backup, internem DNS, Reverse Proxying, VPN-first Zugriff sowie einer umgesetzten UniFi-basierten VLAN- und Firewall-Segmentierung.

Das Projekt dient als praxisnahe Lern- und Dokumentationsumgebung für Systemadministration, Self-Hosting, Netzwerksicherheit, Backup-/Restore-Planung und den Betrieb eigener Infrastruktur.

---

## Project Overview

This is my personal Unraid-based homelab. I use it to run and document storage, Docker services, internal infrastructure, backups, smart home components and a segmented UniFi network.

It is a real environment that I use, maintain and improve over time.

Main focus areas:

- Unraid storage design
- Docker-based services
- AppData, share and offsite backups
- VPN-first remote access
- Internal DNS and reverse proxying
- Smart home infrastructure
- UniFi-based firewall and VLAN segmentation

---

## Privacy & Public Documentation

This is a public portfolio repository. I leave out internal details that are not needed to understand the design.

Not included in this repository:

- exact VLAN IDs
- internal IP ranges
- internal hostnames and DNS rewrites
- detailed firewall rule names
- real share names with private information
- secrets, tokens, certificates and private keys
- private VPN configuration
- the location of the offsite backup target
- screenshots with serial numbers, MAC addresses or sensitive device names

The idea is to document the setup, decisions and learning process without publishing unnecessary internal details.

---

## Current Status

| Area | Status |
|---|---|
| Unraid server | Running |
| Docker services | Running |
| Internal DNS | Implemented with AdGuard Home and Unbound |
| Internal reverse proxy | Implemented with Nginx Proxy Manager |
| VPN-first remote access | Implemented |
| Local backups | Implemented for AppData and selected shares |
| Offsite backup | Implemented with restic over a WireGuard site-to-site tunnel |
| Backup monitoring | Implemented with Uptime Kuma and Home Assistant notifications |
| Array parity | Implemented with an 8 TB parity disk |
| Private data disk | Implemented with a dedicated 4 TB disk |
| UniFi gateway/firewall | Implemented |
| VLAN segmentation | Implemented |
| Firewall rules | Implemented between network zones |
| Gateway IDS/IPS | Enabled on the UniFi gateway |

---

## Hardware

| Component | Model / Description |
|---|---|
| Case | Jonsbo N6 |
| Mainboard | Gigabyte B760M DS3H DDR4 |
| CPU | Intel Core i5-12500T |
| Memory | 32 GiB DDR4 |
| PSU | NZXT Core Gold 750 W |
| SATA Expansion | M.2 PCIe SATA expansion adapter for additional SATA ports |
| Operating System | Unraid |
| Offsite backup target | Raspberry Pi 3 Model B+ with a 4 TB HDD |

---

## Hardware Build

![Jonsbo N6 Homelab Build](screenshots/sanitized/jonsbo-n6-front.jpg)

The system is built in a compact Jonsbo N6 case with up to nine drive bays. It is used as my Unraid-based homelab for storage, Docker services, backups and lab workloads.

---

## Storage Overview

I try to keep the storage layout easy to understand: application data, long-term data, backups, private data and lab workloads each have their own role.

| Device | Model | Capacity | Purpose |
|---|---:|---:|---|
| NVMe SSD | WD Red SN700 | 500 GB | AppData, Docker data and cache |
| HDD | WDC WD80EFPX | 8 TB | Main data disk |
| HDD | Parity disk | 8 TB | Unraid parity protection |
| HDD | WDC WD40EFRX | 4 TB | Local backup target |
| HDD | Private data disk | 4 TB | Private and important data |
| SATA SSD | Micron 1100 MTFDDAK256TBN | 256 GB | Virtual machines, testing and experiments |
| HDD (offsite) | WDC WD40EFAX | 4 TB | Offsite backup target |

Important design notes:

- The NVMe SSD is used for Docker AppData and cache workloads.
- The Unraid array is used for long-term data storage.
- Active parity protects the array against a single data disk failure.
- Parity is not treated as a replacement for backups.
- A dedicated 4 TB HDD is used as the local backup target.
- A separate 4 TB HDD is used for private and important data.
- A separate SATA SSD is used for VMs and lab/testing workloads.
- Additional SATA connectivity is provided through an M.2 PCIe SATA expansion adapter.
- A second 4 TB HDD at an offsite location holds the offsite backup.

More details: [Storage Layout](docs/storage-layout.md)

---

## Service Stack

The services are grouped by their role in the environment. Not every private, temporary or experimental container is documented here.

| Area | Services | Purpose |
|---|---|---|
| DNS and filtering | AdGuard Home, Unbound | Internal DNS, filtering and name resolution |
| Reverse proxy and security | Nginx Proxy Manager, CrowdSec | Internal HTTPS routing and additional visibility |
| Password management | Vaultwarden | Self-hosted password management |
| Smart home | Home Assistant, Mosquitto, Zigbee2MQTT, Matter Server | Smart home automation and device integration |
| Photo management | Immich stack | Self-hosted photo management |
| Network visibility | WatchYourLAN | Basic LAN device visibility |
| Monitoring | Uptime Kuma | Monitoring and alerts for the offsite backup |
| Knowledge and documentation | Kiwix, Joplin | Notes and offline/local knowledge resources |
| Backend services | PostgreSQL, Redis | Databases and supporting services |

The important part for me is not just that the containers are running. I also want to understand their dependencies, access paths and backup requirements.

More details: [Service Overview](docs/service-overview.md)

---

## Architecture

The current setup uses Unraid as the central storage and container host. Network access is handled through a UniFi-based setup with VLAN segmentation and firewall rules.

```mermaid
flowchart TD
    Internet((Internet))
    UCG["UniFi Cloud Gateway Fiber<br/>Gateway / Firewall / IDS/IPS"]
    Flex8["USW Flex 2.5G 8<br/>Main Switch"]
    FlexMini["USW Flex Mini 2.5G<br/>Additional Switch"]
    AP["U6+ Access Point"]
    Unraid["Unraid Server"]
    WiredClients["Wired Clients"]
    WiFiClients["Wi-Fi / IoT Devices"]
    Offsite["Offsite Backup Target<br/>Raspberry Pi + 4 TB HDD"]

    Internet --> UCG
    UCG -->|"direct connection"| Unraid
    UCG -->|"10G uplink"| Flex8
    UCG -->|"PoE"| AP
    Flex8 --> FlexMini
    Flex8 --> WiredClients
    FlexMini --> WiredClients
    AP --> WiFiClients
    UCG -.->|"WireGuard site-to-site"| Offsite

    subgraph UnraidHost["Unraid Host"]
        Docker["Docker Engine"]
        Cache["NVMe SSD - AppData / Cache"]
        ArrayStorage["Unraid Array - Data Storage"]
        BackupDisk["Dedicated Backup Disk"]
        LabSSD["SATA SSD - VMs / Lab"]
    end

    Unraid --> Docker
    Unraid --> Cache
    Unraid --> ArrayStorage
    Unraid --> BackupDisk
    Unraid --> LabSSD
```

More details: [Architecture](docs/architecture.md)

---

## Backup Strategy

The backup setup is based on how often the data changes and how important it is for restoring the system.

| Backup Type | Schedule | Scope | Purpose |
|---|---:|---|---|
| AppData Backup | Scheduled | Docker AppData and service state | Restore container configurations and application data |
| Weekly Backup | `0 5 * * 1` | Photos and selected important data | Protect data that changes more often |
| Monthly Backup | `30 5 1 * *` | Mostly static archive data | Back up data that rarely changes |
| Offsite Backup | Weekly | Photos, important personal data and Vaultwarden | Protect against losing the whole server |

The local backup disk is useful for quick restores. The offsite backup covers the case where the server and the local backup disk are both gone.

The offsite backup uses restic over a WireGuard site-to-site tunnel. The target runs in append-only mode, so the Unraid server can add new snapshots but cannot delete existing ones. Even a compromised server could not remove the offsite copies.

Unraid parity and backups are treated as separate things:

- Parity helps with disk availability and protects against a single data disk failure.
- Backups protect against deletion, broken updates, corruption, misconfiguration and complete system loss.

More details: [Backup Strategy](docs/backup-strategy.md)

---

## Security Approach

The current security approach is based on keeping services private by default, using VPN for remote access and separating devices through VLANs and firewall rules.

Current measures:

- VPN-first remote access is implemented.
- Internal services are not exposed publicly by default.
- Internal DNS is handled through AdGuard Home and Unbound. The work and gaming networks use the gateway's DNS with Quad9 instead.
- Nginx Proxy Manager is used as an internal reverse proxy.
- CrowdSec is used as an additional security and visibility component.
- UniFi gateway/firewall is implemented.
- VLAN segmentation is implemented for different device groups.
- Firewall rules are used to restrict traffic between network zones.
- IDS/IPS is enabled on the UniFi gateway as an additional visibility layer.
- Sensitive services such as Vaultwarden are treated as higher-priority services for backups and access control.
- Backup targets are separated from normal productive storage.
- The offsite backup is append-only and can only be reached from the Unraid server.

Open points I still want to improve:

- Better restore documentation and restore testing
- Restrict what less trusted zones can reach on the gateway itself
- Set up retention for the offsite backup repository
- Ongoing cleanup and documentation of network exceptions

More details: [Security Concept](docs/security-concept.md)

---

## Network Segmentation

The network has been migrated from a mostly flat home network to a UniFi-based setup with VLAN segmentation and firewall rules.

Current network components:

| Component | Role |
|---|---|
| UniFi Cloud Gateway Fiber | Gateway, firewall, IDS/IPS, VPN and network controller |
| Unraid server | Server and infrastructure services, connected directly to the gateway |
| U6+ | Managed Wi-Fi access point, connected directly to the gateway via PoE |
| USW Flex 2.5G 8 | Main 2.5G switch, connected to the gateway with a 10G uplink |
| USW Flex Mini 2.5G | Additional 2.5G switch for wired clients |

The Unraid server is connected directly to the UniFi Cloud Gateway Fiber. The main switch is connected to the gateway through a 10G uplink. The U6+ access point is also connected directly to the gateway via PoE.

Current network zones:

| Zone | Purpose |
|---|---|
| Default / Native | Kept minimal for compatibility and transition purposes |
| Management | Network and admin devices |
| Trusted | Main trusted clients and daily-use devices |
| Untrusted | Less trusted client devices with restricted internal access |
| Server | Unraid and infrastructure services |
| Media | Media and TV devices |
| IoT | Smart home and IoT devices |
| Guest | Guest devices in UniFi's hotspot zone with internet-only access |
| Work | Work devices with their own company VPN, isolated from internal networks |
| Gaming | Consoles and gaming PCs, internet-only access with unfiltered DNS |
| Lab | Testing and lab devices |
| Print | Printer devices |
| VPN | Remote access to selected internal services and the offsite backup tunnel |

I try to keep the network simple enough to maintain, while still separating devices that should not fully trust each other.

More details: [Network Roadmap](docs/network-roadmap.md)

---

## Documentation

The repository is split into several documentation files:

| Document | Description |
|---|---|
| [Architecture](docs/architecture.md) | Current Unraid architecture, access model and UniFi network design |
| [Storage Layout](docs/storage-layout.md) | Storage roles, AppData/cache design, array layout and current disk layout |
| [Backup Strategy](docs/backup-strategy.md) | AppData backup, weekly/monthly backups, offsite backup and 3-2-1 status |
| [Security Concept](docs/security-concept.md) | VPN-first access, internal DNS, reverse proxying and VLAN segmentation |
| [Network Roadmap](docs/network-roadmap.md) | UniFi network design, network zones and firewall direction |
| [Service Overview](docs/service-overview.md) | Overview of the main infrastructure and application services |
| [Lessons Learned](docs/lessons-learned.md) | Problems that took longer than expected, their real causes and fixes |

---

## Roadmap

| Status | Item |
|---|---|
| Done | Add 8 TB parity disk |
| Done | Add dedicated 4 TB private data disk |
| Done | Implement UniFi gateway/firewall |
| Done | Create VLAN segmentation |
| Done | Add firewall rules between network zones |
| Done | Document core network zones and access concept |
| Done | Add offsite backup target |
| Done | Add monitoring/notifications for failed backup jobs |
| Done | Add separate network for work devices |
| Done | Add separate network for gaming devices |
| Done | Move guest network into UniFi's hotspot zone |
| In progress | Keep storage, backup and network documentation up to date |
| Planned | Document restore tests |
| Planned | Restrict gateway access for less trusted zones |
| Planned | Set up retention for the offsite backup repository |
| Planned | Add more sanitized screenshots and example configurations |

---

## Notes

This repository is intended as a technical portfolio and documentation project.

It focuses on how the environment is planned, operated and improved over time. Private workloads, secrets and sensitive configuration details are intentionally not included.
