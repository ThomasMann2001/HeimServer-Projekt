# Security Concept

This document describes the current security approach of my Unraid-based homelab.

The setup is still a homelab and not an enterprise environment. My goal is to apply practical security principles where they make sense: keep services private by default, avoid unnecessary exposure, separate devices into different network zones and make backups and restore planning part of the overall security concept.

Exact VLAN IDs, IP ranges, internal hostnames, secrets and detailed firewall rule names are intentionally not published in this repository.

---

## Security Goals

The main security goals are:

- Keep internal services private by default
- Use VPN as the preferred method for remote access
- Avoid direct public exposure of services unless there is a clear reason
- Use internal DNS and reverse proxying for cleaner service access
- Separate clients, servers, IoT devices, guests, printers and lab workloads
- Restrict traffic between network zones through firewall rules
- Keep important service data recoverable through backups
- Improve visibility into network traffic and connected devices
- Document security-relevant decisions in a way that is understandable later

---

## Current Access Model

The current access model is based on VPN-first remote access and segmented internal access.

| Access Type | Status | Notes |
|---|---|---|
| Local trusted access | Implemented | Used for normal access from trusted devices |
| VPN access | Implemented | Preferred method for remote access |
| Public service exposure | Avoided | Internal services are not exposed publicly by default |
| Internal DNS | Implemented | AdGuard Home and Unbound are used for internal name resolution |
| Internal reverse proxy | Implemented | Nginx Proxy Manager is used for internal HTTPS/service access |
| VLAN segmentation | Implemented | Network zones are separated through UniFi VLANs |
| Firewall rules | Implemented | Inter-zone traffic is restricted based on required access |
| IDS/IPS | Implemented | Enabled on the UniFi gateway as an additional visibility and protection layer |

The important point for me is that remote access should not depend on exposing every service directly to the internet. VPN access is the preferred path.

---

## Network Segmentation

The network has been migrated from a mostly flat home network to a UniFi-based segmented setup.

The goal is not to make the network unnecessarily complex. The goal is to avoid having every device in the same unrestricted network.

Current network zones:

| Zone | Purpose |
|---|---|
| Default / Native | Compatibility and transition network, kept minimal where possible |
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

Firewall rules are used to allow required traffic and block unnecessary lateral movement between zones.

More details: [Network Segmentation](network-roadmap.md)

---

## Firewall Approach

The firewall rules follow a simple principle:

> Allow only what is required between networks and block unnecessary access.

Implemented direction:

- Management devices can access required management interfaces.
- Trusted clients can access selected internal services.
- VPN clients can access selected internal services.
- Server services are not reachable from every network by default.
- IoT devices are restricted to required smart home communication.
- Guest devices are intended for internet-only access.
- Printer access is limited to required printing-related traffic.
- Lab devices are separated from normal production services where possible.
- Untrusted devices have restricted access and are not treated like trusted clients.

I try to keep exceptions understandable instead of adding random allow rules and forgetting why they exist.

---

## Gateway Security and IDS/IPS

The UniFi gateway is used as the main gateway, firewall and network controller.

IDS/IPS is enabled on the gateway as an additional visibility and protection layer. I do not treat IDS/IPS as a replacement for proper segmentation, updates, backups or careful service exposure.

The goal is to use it as one more layer:

- Detect suspicious traffic where possible
- Improve visibility into network activity
- Review alerts and findings when they appear
- Keep services private by default anyway
- Avoid relying on IDS/IPS as the only protection mechanism

This is still a homelab, so I do not claim that this is an enterprise-grade security setup. The goal is to build a practical and maintainable setup that improves over time.

---

## Internal DNS

AdGuard Home and Unbound are used for internal DNS and filtering.

This allows services to be accessed through readable internal hostnames instead of IP addresses and port numbers. It also gives me one central place to manage DNS rewrites and internal name resolution.

Benefits:

- Easier access to internal services
- Less dependency on remembering IP addresses and ports
- Central DNS filtering
- Adblocker
- Better visibility into DNS requests
- Cleaner integration with the segmented network design

Internal DNS details, real hostnames and internal IP addresses are not published in this repository.

---

## Reverse Proxy

Nginx Proxy Manager is used as the internal reverse proxy.

The reverse proxy makes access to services cleaner and more consistent. Instead of accessing services directly through different ports, selected services can be reached through internal hostnames.

CrowdSec is used as an additional security and visibility component around the proxy stack. In this setup it is part of the hardening and visibility approach, not a replacement for firewall rules, VPN access or careful exposure decisions.

Current reverse proxy approach:

- Used mainly for internal service access
- Internal services are private by default
- Public exposure is avoided unless there is a clear reason
- Access paths should stay documented and understandable

---

## VPN-First Remote Access

Remote access is handled through VPN.

This is an intentional design decision. I prefer reaching internal services through a VPN tunnel instead of exposing them directly to the public internet.

This reduces the attack surface and makes the setup easier to reason about.

Current approach:

- Internal services stay private by default
- Remote access happens through VPN
- Public exposure is avoided by default
- VPN access is limited to selected internal services
- Firewall rules should document and enforce this access model

---

## Container Security Approach

Most services run as Docker containers on Unraid.

I use containers mainly for maintainability and separation. Containers are not treated as a complete security boundary, but they help keep services organized and easier to manage.

Current container design principles:

- Persistent data is stored outside the container itself
- AppData is separated from container images
- Services can be backed up and restored more easily
- Test and lab workloads should be separated from important services where possible
- Only required ports should be exposed internally
- Important containers should have clear backup and restore planning

---

## Data and Backup Security

Backups are part of the security concept because they protect against more than just disk failure.

Important risks include:

- Accidental deletion
- Broken updates
- Misconfiguration
- File corruption
- Ransomware
- Complete system loss
- Theft, fire or water damage

Current backup-related security measures:

- AppData backup for service recovery
- Weekly backup for photos and selected important data
- Monthly backup for mostly static archive data
- Dedicated local backup disk
- Backup data separated from normal productive storage
- Offsite backup planned for important data

Unraid parity is active, but it is not treated as a backup. It helps with disk availability and protects against a single data disk failure, but it does not protect against deletion, corruption, ransomware or user mistakes.

More details: [Backup Strategy](backup-strategy.md)

---

## Sensitive Services

Some services require extra care because they contain sensitive data or control important parts of the environment.

| Service | Security Consideration |
|---|---|
| Vaultwarden | Contains password manager data and must be protected carefully |
| Home Assistant | Controls smart home devices and should be limited to trusted access paths |
| Immich | Stores personal photos and should be included in backup planning |
| Nginx Proxy Manager | Central internal access point for selected services |
| AdGuard Home / Unbound | Important for internal DNS, filtering and name resolution |
| UniFi Gateway | Central firewall, routing, IDS/IPS and network control component |
| Backup target | Should not be treated like normal shared storage |

For public documentation, I avoid publishing secrets, tokens, exact internal details or screenshots that expose sensitive information.

---

## Public Documentation Hygiene

This repository is public, so not every detail belongs here.

Intentionally not published:

- Exact VLAN IDs
- Internal IP ranges
- Internal hostnames and DNS rewrites
- Detailed firewall rule names
- Real share names with private information
- Secrets, tokens, certificates or private keys
- WireGuard/private VPN configuration
- Screenshots with serial numbers, MAC addresses or sensitive device names

The goal is to document the design and learning process without exposing unnecessary internal details.

---

## Monitoring and Visibility

Visibility is an important part of the setup.

Current visibility sources include:

- UniFi gateway statistics and security events
- IDS/IPS findings on the gateway
- DNS query visibility through AdGuard Home
- Device visibility through UniFi and network monitoring tools
- Service logs where needed

This area can still be improved. I want to add better alerting and make important events easier to review over time.

---

## Current Limitations

The current setup is functional, but there are still areas to improve.

Known limitations:

- Offsite backup is still planned
- Restore tests need better documentation
- Monitoring and alerting can be improved
- Firewall exceptions should be reviewed over time
- IDS/IPS findings should be reviewed and tuned where useful
- Some screenshots and scripts still need to be cleaned up before publishing

---

## Next Steps

Planned next steps:

- Add offsite backup for important data
- Document restore tests
- Improve monitoring and alerting
- Review firewall exceptions over time
- Review IDS/IPS findings and tune the setup if needed
- Keep DNS, reverse proxy and firewall documentation aligned
- Add more sanitized screenshots and example configurations

---

## Summary

The current security approach is based on practical homelab principles:

- Keep services private by default
- Use VPN for remote access
- Avoid unnecessary public exposure
- Use internal DNS and reverse proxying for cleaner access
- Segment the network into different trust zones
- Restrict traffic between zones with firewall rules
- Use IDS/IPS as an additional visibility and protection layer
- Back up important application and user data
- Keep public documentation sanitized

The setup is not meant to be perfect. It is a real environment that I use, maintain and improve over time.
