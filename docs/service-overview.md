# Service Overview

This document gives an overview of the main services running in my Unraid homelab.

The focus is not just on self-hosting applications, but on operating a small infrastructure environment with DNS, reverse proxying, backups, smart home services, monitoring and security-related components.

## Service Categories

The services are grouped by their role in the environment.

| Category | Services |
|---|---|
| DNS and name resolution | AdGuard Home, Unbound |
| Reverse proxy and security | Nginx Proxy Manager, CrowdSec |
| Password management | Vaultwarden |
| Smart home | Home Assistant, Mosquitto, Zigbee2MQTT, Matter Server |
| Photo management | Immich stack |
| Network visibility | WatchYourLAN |
| Knowledge and documentation | Kiwix, Joplin |
| Databases and backend services | PostgreSQL, Redis |

## Core Infrastructure Services

### AdGuard Home and Unbound

AdGuard Home and Unbound are used for internal DNS resolution and DNS filtering.

This is one of the core parts of the homelab because many internal services are accessed through local hostnames instead of direct IP addresses and ports.

Main purpose:

- Internal DNS resolution
- DNS rewrites for local services
- DNS filtering
- Better visibility into DNS requests
- Foundation for cleaner internal service access

### Nginx Proxy Manager and CrowdSec

Nginx Proxy Manager is used as the internal reverse proxy.

It helps provide cleaner access to internal services by using hostnames instead of direct IP and port combinations. CrowdSec is used as an additional security component around the proxy stack.

Main purpose:

- Internal reverse proxy
- Centralized service access
- HTTPS handling for internal services
- Additional security visibility through CrowdSec

The reverse proxy is used internally and does not mean that services are publicly exposed by default.

## Password Management

### Vaultwarden

Vaultwarden is used as a self-hosted password manager.

Because this service contains sensitive data, it is treated as one of the more critical services in the environment.

Main considerations:

- Should only be reachable through trusted access paths
- Needs reliable AppData backups
- Should not be included in screenshots with sensitive information
- Must be handled carefully during restore planning

## Smart Home Stack

### Home Assistant

Home Assistant is used as the central smart home platform.

It connects and automates smart home devices and is one of the important daily-use services in the homelab.

Main purpose:

- Smart home automation
- Device integration
- Central control point for automations
- Integration with MQTT, Zigbee and Matter components

### Mosquitto

Mosquitto is used as the MQTT broker.

It acts as a messaging layer for smart home components and is especially important for Zigbee2MQTT.

Main purpose:

- MQTT messaging
- Communication layer for smart home services
- Backend service for Zigbee2MQTT

### Zigbee2MQTT

Zigbee2MQTT is used to integrate Zigbee devices through MQTT.

This keeps the Zigbee setup flexible and makes devices available to Home Assistant through the MQTT broker.

Main purpose:

- Zigbee device integration
- MQTT-based communication
- Smart home device management

### Matter Server

The Matter Server is used for Matter integration with Home Assistant.

Main purpose:

- Matter device integration
- Support for newer smart home standards
- Home Assistant integration

## Photo Management

### Immich Stack

Immich is used for self-hosted photo management.

The Immich stack includes backend services such as PostgreSQL and Redis. Because it stores personal photos, it is included in the backup strategy.

Main purpose:

- Self-hosted photo management
- Personal photo storage
- Backend services with persistent data
- Important part of weekly backup planning

## Network Visibility

### WatchYourLAN

WatchYourLAN is used for basic LAN visibility.

It helps keep track of devices in the network and gives a simple overview of what is connected.

Main purpose:

- LAN device discovery
- Basic network inventory
- Visibility into connected devices

This is not a full monitoring solution, but it is useful for a homelab environment.

## Knowledge and Documentation Services

### Kiwix

Kiwix is used for offline knowledge access.

Main purpose:

- Offline documentation and knowledge resources
- Local access to selected content

### Joplin

Joplin is used as a self-hosted notes and documentation service.

Main purpose:

- Notes
- Documentation
- Personal knowledge management

## Database and Backend Services

Some services require backend databases or supporting services.

Examples:

| Service | Purpose |
|---|---|
| PostgreSQL | Database backend for selected applications |
| Redis | Cache/backend service for selected applications |

These services are treated as persistent services. Their data needs to be included in AppData and backup planning.

## Services Intentionally Not Documented in Detail

Not every container or workload is documented in this repository.

Some services are left out intentionally because they are either personal, temporary, experimental or not relevant for the infrastructure/security focus of this portfolio.

The goal of this repository is to document the infrastructure design, not to publish a full private service inventory.

## Operational Notes

General service operation principles:

- Persistent data should be stored outside the container itself
- Important service data should be covered by AppData backups
- Services should not be exposed publicly by default
- Internal access should use DNS and reverse proxying where useful
- Sensitive services should not be shown in screenshots with real data
- Test services should be separated from critical services where possible

## Restore-Relevant Services

Some services are more important for restoring the environment than others.

Higher priority services:

1. DNS services
2. Reverse proxy
3. Vaultwarden
4. Home Assistant
5. MQTT and Zigbee2MQTT
6. Immich stack
7. Documentation and supporting services

This restore order is not final, but it helps identify which services are most important during a failure.

## Summary

The service stack is built around practical homelab needs:

- DNS and internal service access
- Reverse proxying
- Password management
- Smart home infrastructure
- Photo management
- Basic network visibility
- Documentation and knowledge management

The important part is not only that the services are running, but that their data, access paths and backup requirements are understood and documented.
