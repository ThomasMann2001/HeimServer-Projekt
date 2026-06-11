# Service Overview

This document gives an overview of the main services running in my Unraid homelab.

The goal is not to document every single container I have ever tested. I want this file to show the services that are relevant for the infrastructure itself: DNS, reverse proxying, backups, smart home, internal documentation, network visibility and services with important persistent data.

Some personal, temporary or experimental workloads are intentionally left out.

---

## Service Categories

| Category | Services | Purpose |
|---|---|---|
| DNS and name resolution | AdGuard Home, Unbound | Internal DNS, filtering and upstream DNS resolution |
| Reverse proxy and security | Nginx Proxy Manager, CrowdSec | Internal service access and additional security visibility |
| Password management | Vaultwarden | Self-hosted password management |
| Smart home | Home Assistant, Mosquitto, Zigbee2MQTT, Matter Server | Smart home automation and device integration |
| Photo management | Immich stack | Self-hosted photo management |
| Network visibility | WatchYourLAN | Basic LAN device visibility |
| Knowledge and documentation | Kiwix, Joplin | Local knowledge, notes and documentation |
| Backend services | PostgreSQL, Redis | Databases and supporting services for applications |

---

## Core Infrastructure Services

### AdGuard Home and Unbound

AdGuard Home and Unbound are used for internal DNS resolution, DNS filtering and upstream DNS resolution.

This is one of the core parts of the homelab because many internal services are accessed through readable internal hostnames instead of direct IP addresses and ports.

Main purpose:

- Internal DNS resolution
- DNS rewrites for local services
- DNS filtering
- Better visibility into DNS requests
- Cleaner internal service access
- Foundation for reverse proxy usage

Internal hostnames, DNS rewrites and IP addresses are intentionally not published in this repository.

---

### Nginx Proxy Manager and CrowdSec

Nginx Proxy Manager is used as the internal reverse proxy.

It helps provide cleaner access to selected services by using hostnames instead of direct IP and port combinations. In my setup, the reverse proxy is mainly used for internal access and does not mean that services are publicly exposed by default.

CrowdSec is used as an additional security and visibility component around the proxy stack.

Main purpose:

- Internal reverse proxy
- Cleaner service access
- HTTPS handling for internal services
- Centralized access paths for selected services
- Additional security visibility through CrowdSec

The reverse proxy is not treated as a replacement for firewall rules, VPN access or careful service exposure decisions.

---

## Password Management

### Vaultwarden

Vaultwarden is used as a self-hosted password manager.

Because this service contains sensitive data, it is one of the most important services in the environment. It needs careful access control, reliable backups and a clear restore plan.

Main considerations:

- Should only be reachable through trusted access paths
- Must be included in AppData backup planning
- Should not be exposed publicly without a clear reason
- Should not appear in screenshots with sensitive information
- Needs extra care during restore testing and migration

---

## Smart Home Stack

### Home Assistant

Home Assistant is used as the central smart home platform.

It connects smart home devices, automations and integrations. Since it is used regularly and controls parts of the smart home environment, it is treated as an important service.

Main purpose:

- Smart home automation
- Device integration
- Central control point for automations
- Integration with MQTT, Zigbee and Matter components

Backup relevance:

- Configuration
- Automations
- Integrations
- Add-on and service state where relevant

---

### Mosquitto

Mosquitto is used as the MQTT broker.

It acts as a messaging layer for smart home components and is especially important for Zigbee2MQTT.

Main purpose:

- MQTT messaging
- Communication layer for smart home services
- Backend service for Zigbee2MQTT

---

### Zigbee2MQTT

Zigbee2MQTT is used to integrate Zigbee devices through MQTT.

This keeps the Zigbee setup flexible and makes devices available to Home Assistant through the MQTT broker.

Main purpose:

- Zigbee device integration
- MQTT-based communication
- Smart home device management
- Separation from vendor-specific bridges where possible

---

### Matter Server

The Matter Server is used for Matter integration with Home Assistant.

Main purpose:

- Matter device integration
- Support for newer smart home standards
- Home Assistant integration

---

## Photo Management

### Immich Stack

Immich is used for self-hosted photo management.

The Immich stack includes backend services such as PostgreSQL and Redis. Because it stores personal photos, it is included in backup planning.

Main purpose:

- Self-hosted photo management
- Personal photo storage
- Mobile photo backup workflow
- Backend services with persistent data

Backup relevance:

- Photo library
- Database
- Application configuration
- Supporting backend data

Personal photo content and private paths are intentionally not documented in detail.

---

## Network Visibility

### WatchYourLAN

WatchYourLAN is used for basic LAN visibility.

It helps keep track of devices in the network and gives a simple overview of what is connected. This is useful in a segmented network because it helps me notice new or unexpected devices more easily.

Main purpose:

- LAN device discovery
- Basic network inventory
- Visibility into connected devices

This is not meant to be a full monitoring solution, but it is useful for a homelab environment.

---

## Knowledge and Documentation Services

### Kiwix

Kiwix is used for offline knowledge access.

Main purpose:

- Offline documentation and knowledge resources
- Local access to selected content
- Useful reference material even without internet access

---

### Joplin

Joplin is used as a notes and documentation service.

Main purpose:

- Notes
- Documentation
- Personal knowledge management
- Project notes and technical write-ups

---

## Database and Backend Services

Some services require backend databases or supporting services.

| Service | Purpose |
|---|---|
| PostgreSQL | Database backend for selected applications |
| Redis | Cache/backend service for selected applications |

These services are important because they often contain application state. Even if they are not always accessed directly, they need to be included in AppData and backup planning.

---

## Access Model

The services are private by default.

The general access model is:

- Local trusted clients access selected internal services
- Remote access is handled through VPN
- Internal DNS is used for clean service names
- Nginx Proxy Manager is used for selected internal access paths
- Services are not exposed publicly by default
- Firewall rules and VLANs restrict access between network zones

Exact access paths, internal hostnames, IP addresses and firewall rule names are intentionally not published.

More details:

- [Security Concept](security-concept.md)
- [Network Segmentation](network-roadmap.md)

---

## Backup Relevance

Not every service has the same backup priority.

| Priority | Services / Data | Reason |
|---|---|---|
| High | Vaultwarden | Contains sensitive password manager data |
| High | Home Assistant | Important smart home configuration and automations |
| High | AdGuard Home / Unbound | Important for internal DNS and service access |
| High | Nginx Proxy Manager | Important for internal reverse proxy configuration |
| High | Immich stack | Personal photos and application database |
| Medium | Joplin | Notes and documentation |
| Medium | WatchYourLAN | Useful network visibility data |
| Medium | Kiwix | Useful but mostly reproducible content |
| Depends | Lab or test services | Only backed up if the data is important |

AppData backups are important because they contain the configuration and state of many of these services.

More details: [Backup Strategy](backup-strategy.md)

---

## Restore-Relevant Services

Some services are more important during a restore than others.

A rough restore priority would be:

1. DNS services
2. Reverse proxy
3. Vaultwarden
4. Home Assistant
5. Mosquitto and Zigbee2MQTT
6. Immich stack
7. Documentation and supporting services
8. Optional or experimental services

This order is not final, but it helps me think about what needs to come back first after a failure.

---

## Services Intentionally Not Documented in Detail

Not every container or workload is documented in this repository.

Some services are left out intentionally because they are:

- Personal
- Temporary
- Experimental
- Not relevant for the infrastructure focus
- Not useful for a public portfolio
- Too sensitive to document publicly

The goal of this repository is to document the infrastructure design and operational thinking, not to publish a full private service inventory.

---

## Operational Notes

General service operation principles:

- Persistent data should be stored outside the container itself.
- Important service data should be covered by AppData backups.
- Services should not be exposed publicly by default.
- Internal access should use DNS and reverse proxying where useful.
- Sensitive services should not be shown in screenshots with real data.
- Test services should be separated from critical services where possible.
- New services should be reviewed for backup and access requirements.
- Public documentation should stay sanitized.

---

## Current Limitations

The service stack is running, but there are still areas to improve.

Current limitations and improvement areas:

- Restore procedures should be documented better.
- Monitoring and alerting can be improved.
- Some service dependencies should be documented more clearly.
- Backup coverage should be reviewed when new services are added.
- More sanitized screenshots can be added later.

---

## Summary

The service stack is built around practical homelab needs:

- DNS and internal service access
- Reverse proxying
- Password management
- Smart home infrastructure
- Photo management
- Basic network visibility
- Local documentation and knowledge management
- Backend services with persistent data

The important part is not only that these services are running. The important part is that their access paths, dependencies, persistent data and backup requirements are understood and documented.
