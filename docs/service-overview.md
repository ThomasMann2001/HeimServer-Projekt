# Service Overview

This document gives an overview of the main services running in my Unraid homelab.

It is not meant to be a full container inventory. I only document the services that are relevant for infrastructure, restore planning, access paths or persistent data.

Some personal, temporary or experimental containers are intentionally left out.

---

## Service Map

| Area | Services | Dependencies / Notes |
|---|---|---|
| DNS and name resolution | AdGuard Home, Unbound | Important for internal service access and filtering |
| Reverse proxy and security | Nginx Proxy Manager, CrowdSec | Used for internal HTTPS access and additional visibility |
| Password management | Vaultwarden | Sensitive service, high backup and restore priority |
| Smart home | Home Assistant, Mosquitto, Zigbee2MQTT, Matter Server | Home Assistant depends on MQTT, Zigbee and Matter integrations |
| Photo management | Immich | Depends on PostgreSQL, Redis and the photo library |
| Network visibility | WatchYourLAN | Basic device visibility inside the LAN |
| Monitoring | Uptime Kuma | Push monitoring and alerts for the offsite backup job |
| Knowledge and documentation | Kiwix, Joplin | Local knowledge base, notes and documentation |
| Backend services | PostgreSQL, Redis | Used by selected applications, especially services with persistent state |

---

## Core Infrastructure

### DNS: AdGuard Home and Unbound

AdGuard Home and Unbound are part of the base infrastructure.

They provide internal DNS resolution, filtering and upstream DNS resolution. If DNS is down, many internal services are still technically running, but access becomes much less convenient.

Why it matters:

- readable internal service names
- DNS filtering
- DNS query visibility
- foundation for clean reverse proxy usage

The work and gaming networks do not use AdGuard. They use the gateway's DNS with Quad9 as upstream.

For restore planning, DNS is one of the first services I would bring back.

---

### Reverse Proxy: Nginx Proxy Manager and CrowdSec

Nginx Proxy Manager is used for selected internal access paths.

The reverse proxy keeps service access cleaner because I do not have to remember every IP and port combination. In this setup it is mainly used internally and does not mean that services are publicly exposed by default.

CrowdSec adds another visibility and hardening layer around the proxy stack.

Why it matters:

- internal HTTPS access
- centralized access paths for selected services
- cleaner service URLs
- additional security visibility through CrowdSec

---

## Sensitive Services

### Vaultwarden

Vaultwarden is one of the most sensitive services in the environment because it contains password manager data.

For me, this means:

- access should stay limited to trusted paths
- AppData backups are critical
- it is included in the offsite backup
- restore steps should be tested carefully
- screenshots and logs must be handled carefully

For the offsite backup, the Vaultwarden container is stopped for a short moment so the database is in a consistent state, and started again right after.

Vaultwarden is high priority during restore planning, but it depends on the base infrastructure being available first.

---

## Smart Home Stack

Home Assistant is the central smart home service.

It uses Mosquitto as MQTT broker, Zigbee2MQTT for Zigbee devices and the Matter Server for Matter integration. These services belong together because Home Assistant loses a lot of functionality if the supporting services are missing.

Main dependencies:

| Service | Role |
|---|---|
| Home Assistant | Main smart home platform |
| Mosquitto | MQTT broker |
| Zigbee2MQTT | Zigbee device integration through MQTT |
| Matter Server | Matter integration for Home Assistant |

The Matter Server runs as a Docker container with its own address directly in the IoT network. Matter relies on mDNS and IPv6 in the local network, so the simplest option was to put the Matter Server directly into the IoT network. Home Assistant stays in the server network and only reaches the Matter Server through a specific firewall rule.

I decided against a separate VM for this. A container is enough and uses fewer resources on an always-on server.

Backup-relevant data includes Home Assistant configuration, automations, integrations and the persistent state of the supporting services.

---

## Photo Management

Immich is used for self-hosted photo management.

It is more than just one container. The photo library, database and supporting backend services belong together.

Main dependencies:

| Component | Role |
|---|---|
| Immich | Photo management application |
| PostgreSQL | Application database |
| Redis | Cache / supporting backend service |
| Photo library | Actual user data |

Because it stores personal photos, Immich is part of the backup planning. Restoring the container without its database and photo library would not be useful.

---

## Network Visibility and Monitoring

WatchYourLAN is used for basic LAN visibility.

It helps me notice new or unexpected devices and gives a quick overview of what is connected. This is especially useful now that the network is split into multiple zones.

Uptime Kuma is used for monitoring the offsite backup. The backup job reports to a push monitor after each run. If the report is missing or the job fails, I get an alert.

This is not meant to be a full monitoring stack, but it is useful enough for a homelab.

---

## Knowledge and Documentation

Kiwix and Joplin are used for local knowledge and documentation.

| Service | Use case |
|---|---|
| Kiwix | Offline knowledge and reference material |
| Joplin | Notes, documentation and project write-ups |

These services are not as critical as DNS, Vaultwarden or Home Assistant, but they are still useful during troubleshooting and documentation work.

---

## Restore Priority

If the server had to be rebuilt, I would not restore every service in a random order.

A rough restore order would be:

1. DNS services
2. Reverse proxy
3. Vaultwarden
4. Home Assistant
5. Mosquitto, Zigbee2MQTT and Matter Server
6. Immich stack including database and photo library
7. Monitoring
8. Documentation and knowledge services
9. Optional or experimental services

This order is not final, but it helps me think about dependencies. For example, DNS and reverse proxy services should come back early because many other services are easier to reach once they are running again.

If the local backup disk is lost together with the server, the offsite backup is the source for Vaultwarden and important personal data.

---

## Services Not Documented in Detail

Not every container or workload belongs in this public documentation.

Some services are left out because they are personal, temporary, experimental, not useful for the infrastructure focus or simply too sensitive to document publicly.

The point of this repository is not to publish a full private service inventory. It is meant to show how the main infrastructure pieces fit together and how I think about access, persistence and backups.

---

## Operating Notes

A few rules I try to follow when adding or changing services:

- keep persistent data outside the container itself
- check whether the service needs AppData, share-level or offsite backups
- expose only the ports that are actually required
- use internal DNS and reverse proxying where it makes access cleaner
- keep test services separated from important services where possible
- document dependencies before the service becomes hard to replace

For detailed access rules and backup planning, I use the dedicated documents:

- [Security Concept](security-concept.md)
- [Backup Strategy](backup-strategy.md)
- [Network Segmentation](network-roadmap.md)
- [Lessons Learned](lessons-learned.md)
