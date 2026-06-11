# Security Concept

This document describes the security approach of my Unraid-based homelab.

The setup is not an enterprise environment, but I try to apply practical security principles where they make sense: keep services private by default, separate devices into different network zones, use VPN for remote access and make backups part of the overall security concept.

---

## Security Approach

The main idea is simple: internal services should not be reachable from everywhere just because they are running.

The current approach is based on:

- VPN-first remote access
- internal services private by default
- UniFi-based network segmentation
- firewall rules between network zones
- internal DNS through AdGuard Home and Unbound
- internal reverse proxying through Nginx Proxy Manager
- IDS/IPS on the UniFi gateway
- AppData and share-level backups
- careful handling of sensitive services like Vaultwarden

I try to keep the setup understandable. If I add an exception or allow traffic between zones, I want to know later why it exists.

---

## Current Security Measures

| Area | Status | Notes |
|---|---|---|
| VPN access | Implemented | Preferred method for remote access |
| Public exposure | Avoided by default | Internal services are not exposed directly unless there is a clear reason |
| Internal DNS | Implemented | AdGuard Home and Unbound are used for local name resolution and filtering |
| Reverse proxy | Implemented | Nginx Proxy Manager is used mainly for internal service access |
| VLAN segmentation | Implemented | Devices are separated by role and trust level |
| Firewall rules | Implemented | Traffic between zones is restricted |
| IDS/IPS | Enabled | Used on the UniFi gateway as an additional visibility layer |
| AppData backup | Implemented | Important for service recovery |
| Offsite backup | Planned | Still an open point for disaster recovery |

---

## Access Model

Remote access is handled through VPN. I prefer reaching services through a VPN tunnel instead of exposing them directly to the public internet.

| Source | Access idea |
|---|---|
| Management devices | Access to management interfaces and administrative services |
| Trusted clients | Access to selected internal services |
| VPN clients | Remote access to selected internal services |
| IoT devices | Limited access where smart home communication requires it |
| Guest devices | Internet-only access |
| Lab devices | Restricted testing access, separated from normal production services |

The important part for me is that access paths are intentional. A service being available on the network should not automatically mean that every device can reach it.

---

## Network Segmentation

The network has been migrated from a mostly flat home network to a segmented UniFi setup.

Current network zones:

| Zone | Purpose |
|---|---|
| Default / Native | Compatibility and transition network |
| Management | Network and admin devices |
| Trusted | Main trusted clients and daily-use devices |
| Untrusted | Less trusted client devices with restricted internal access |
| Server | Unraid and infrastructure services |
| Media | Media and TV devices |
| IoT | Smart home and IoT devices |
| Guest | Guest devices with internet-only access |
| Lab | Testing and lab devices |
| Print | Printer devices |
| VPN | Remote access to selected internal services |

The segmentation is not meant to make the network complicated for no reason. It helps me separate devices that should not fully trust each other.

More details: [Network Segmentation](network-roadmap.md)

---

## Firewall Approach

The firewall rules follow one basic rule: allow what is needed and block unnecessary lateral movement.

Current direction:

- management devices can access required management interfaces
- trusted clients can access selected internal services
- VPN clients can access selected internal services
- server services are not reachable from every network by default
- IoT devices are limited to required smart home communication
- guest devices are intended for internet-only access
- printer access is limited to printing-related traffic
- lab devices are separated from normal productive services where possible
- untrusted devices are not treated like trusted clients

I try not to create random allow rules just to make something work quickly. If an exception is needed, it should be documented or cleaned up later.

---

## Gateway Security and IDS/IPS

The UniFi gateway is used for routing, firewall rules, IDS/IPS and network management.

IDS/IPS is enabled as an additional visibility layer. I do not treat it as a replacement for segmentation, updates, backups or careful service exposure.

I mainly use it for:

- spotting suspicious traffic
- getting more visibility into network activity
- reviewing alerts when something looks unusual
- learning how normal traffic in my network behaves

For a homelab, I think the realistic goal is not to pretend that this is a full security operations setup. The useful part is building habits around visibility, review and clean network design.

---

## Internal DNS and Reverse Proxy

AdGuard Home and Unbound are used for internal DNS and filtering.

This makes service access cleaner because I do not have to rely on remembering IP addresses and port numbers for every service. It also gives me visibility into DNS requests and one central place for DNS-related changes.

Nginx Proxy Manager is used as the internal reverse proxy. It provides cleaner access to selected services and handles internal HTTPS access paths.

CrowdSec is used around the proxy stack as an additional security and visibility component. It is not a replacement for firewall rules or VPN-first access, but it adds another layer to the setup.

---

## VPN-First Remote Access

VPN is the preferred way to access internal services remotely.

This keeps the attack surface smaller and makes the setup easier to reason about. Instead of exposing many individual services, remote clients first connect through VPN and then access only the internal services they are allowed to use.

Current approach:

- internal services stay private by default
- remote access goes through VPN
- public exposure is avoided unless there is a clear reason
- firewall rules define what VPN clients can reach

---

## Container and Service Handling

Most services run as Docker containers on Unraid.

I use containers mainly for maintainability and separation. I do not treat containers as a perfect security boundary, but they help keep services organized and easier to back up or restore.

Current principles:

- persistent data is stored outside the container itself
- AppData is separated from container images
- only required ports should be exposed internally
- important containers need backup and restore planning
- test services should be separated from important services where possible

---

## Backup and Recovery

Backups are part of the security concept.

They help with problems that parity cannot solve, for example accidental deletion, broken updates, misconfiguration, corruption or ransomware.

Current backup-related measures:

- AppData backup for service recovery
- weekly backup for photos and selected important data
- monthly backup for mostly static archive data
- dedicated local backup disk
- backup data separated from normal productive storage
- offsite backup planned for important data

Unraid parity is active and protects against a single data disk failure. It is still not a backup.

More details: [Backup Strategy](backup-strategy.md)

---

## Sensitive Services

Some services need extra care because they contain sensitive data or control important parts of the environment.

| Service | Why it matters |
|---|---|
| Vaultwarden | Contains password manager data |
| Home Assistant | Controls smart home devices and automations |
| Immich | Stores personal photos |
| Nginx Proxy Manager | Central internal access point for selected services |
| AdGuard Home / Unbound | Important for internal DNS and filtering |
| UniFi Gateway | Central routing, firewall, IDS/IPS and network control component |
| Backup target | Should not be treated like normal shared storage |

For these services, access control and backups are more important than for temporary or experimental containers.

---

## Monitoring and Visibility

Visibility is still an area I want to improve, but there are already a few useful sources.

Current visibility sources:

- UniFi gateway statistics and security events
- IDS/IPS findings on the gateway
- DNS query visibility through AdGuard Home
- device visibility through UniFi and network tools
- service logs where needed

The next step is better alerting, especially for backup failures and network/security events that are worth reviewing.

---

## Open Points

Things I still want to improve:

- add offsite backup for important data
- document restore tests
- improve monitoring and alerting
- review firewall exceptions over time
- review IDS/IPS findings and tune the setup if needed
- keep DNS, reverse proxy and firewall documentation aligned
- add more sanitized screenshots and example configurations
