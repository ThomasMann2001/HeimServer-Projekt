# Security Concept

This document describes the current security approach of my Unraid homelab and the direction I want to improve it in.

The setup is still a homelab and not an enterprise environment. My goal is to apply practical security principles where they make sense: avoid unnecessary exposure, keep access controlled, separate services where possible and build a network design that can be improved over time.

## Security Goals

The main security goals are:

- Avoid exposing internal services directly to the public internet
- Use VPN as the preferred method for remote access
- Keep service access structured through internal DNS and reverse proxying
- Separate application data from container images
- Back up important service data and user data
- Prepare the network for VLANs and firewall rules
- Improve visibility into devices and services running in the network

## Current Access Model

The current access model is based on local network access and VPN.

| Access Type | Status | Notes |
|---|---|---|
| Local LAN access | Implemented | Normal access method inside the home network |
| VPN access | Implemented | Preferred method for remote access |
| Public port exposure | Avoided | Services are not exposed publicly by default |
| Internal reverse proxy | Implemented | Used for cleaner internal HTTPS/service access |
| VLAN segmentation | Planned | To be implemented with UniFi hardware |

The important point for me is that remote access should not depend on exposing every service directly to the internet. VPN access is the preferred path.

## Internal DNS

AdGuard Home and Unbound are used for internal DNS and filtering.

This allows services to be accessed through readable internal hostnames instead of IP addresses and port numbers. It also gives me one central place to manage DNS rewrites and internal name resolution.

Benefits:

- Easier access to internal services
- Less dependency on remembering IP addresses and ports
- Central DNS filtering
- Better visibility into DNS requests
- Cleaner base for future network segmentation

## Reverse Proxy

Nginx Proxy Manager is used as the internal reverse proxy.

The reverse proxy makes access to services cleaner and more consistent. Instead of accessing services directly through different ports, selected services can be reached through internal hostnames.

CrowdSec is used as an additional security component around the proxy stack. In the current setup it is mainly part of the hardening and visibility approach, not a replacement for proper firewall rules or careful exposure decisions.

## VPN-First Remote Access

Remote access is currently handled through VPN.

This is an intentional design decision. I prefer reaching internal services through a VPN tunnel instead of exposing them directly to the public internet.

This reduces the attack surface and keeps the setup easier to reason about.

Current approach:

- Internal services stay private by default
- Remote access happens through VPN
- Public exposure is avoided unless there is a clear reason
- Future firewall rules should document and enforce this access model more clearly

## Container Security Approach

Most services run as Docker containers on Unraid.

I use containers mainly for maintainability and separation. Containers are not treated as a complete security boundary, but they help keep services organized and easier to manage.

Current container design principles:

- Persistent data is stored outside the container itself
- AppData is separated from container images
- Services can be backed up and restored more easily
- Test/lab workloads should be separated from important services where possible
- Only required ports should be exposed internally

## Data and Backup Security

Backups are part of the security concept because they protect against more than just disk failure.

Important risks include:

- Accidental deletion
- Broken updates
- Misconfiguration
- File corruption
- Ransomware
- Complete system loss

Current backup-related security measures:

- AppData backup for service recovery
- Weekly backup for important changing data
- Monthly backup for mostly static data
- Dedicated local backup disk
- Backup share restricted to the required disk
- Offsite backup planned for important data

Unraid parity is not treated as a backup. It helps with disk availability, but it does not protect against deletion, corruption or user mistakes.

## Sensitive Services

Some services require extra care because they contain sensitive data.

Examples:

| Service | Security Consideration |
|---|---|
| Vaultwarden | Contains password manager data and must not be publicly exposed without a strong reason |
| Home Assistant | Controls smart home devices and should be limited to trusted access paths |
| Immich | Stores personal photos and should be included in backup planning |
| Reverse Proxy | Central access point for internal services |
| DNS Services | Important for internal service discovery and filtering |

For public documentation, I avoid publishing secrets, tokens, exact internal details or screenshots that expose sensitive information.

## Planned UniFi Security Improvements

A future network upgrade is planned with a UniFi Cloud Gateway Fibre and a U7 Lite access point.

The goal is to move from a mostly flat home network toward a more controlled network design with VLANs and firewall rules.

Planned improvements:

- Dedicated gateway/firewall with UniFi Cloud Gateway Fibre
- Managed Wi-Fi with U7 Lite
- Separate VLANs for trusted clients, servers, IoT and guests
- Firewall rules between network zones
- Better network visibility
- Cleaner VPN and remote access documentation

## Planned VLAN Design

The planned VLAN structure should separate different device types and reduce unnecessary trust between them.

| Zone | Purpose | Planned Access Concept |
|---|---|---|
| Trusted LAN | Main clients and admin devices | Access to selected internal services |
| Server VLAN | Unraid and infrastructure services | Restricted access from trusted networks |
| IoT VLAN | Smart home and IoT devices | Only required access to Home Assistant/MQTT |
| Guest VLAN | Guest devices | Internet-only access |
| VPN | Remote access | Access to selected internal services |

The goal is not to make the setup overly complex, but to avoid having every device in the same unrestricted network.

## Planned Firewall Direction

The future firewall rules should follow a simple principle:

> Allow only what is required and block everything else by default between VLANs.

Planned rule direction:

- Trusted clients may access selected server services
- VPN clients may access selected internal services
- IoT devices should only reach what they need
- Guest devices should not access internal services
- Server services should not be unnecessarily reachable from every network
- Management interfaces should be limited to trusted devices

## Documentation and Hardening Notes

Things I want to keep documented over time:

- Which services are exposed internally
- Which services are reachable through VPN
- Which ports are required
- Which data is included in backups
- How important services can be restored
- Which firewall rules are required once VLANs are implemented

## Current Limitations

The current setup is functional, but there are still areas to improve.

Known limitations:

- VLAN segmentation is not implemented yet
- Firewall rules are still planned
- Offsite backup is not implemented yet
- Restore tests need to be documented
- Monitoring and alerting can be improved
- Some screenshots and scripts need to be cleaned up before publishing

## Next Steps

Planned next steps:

- Implement UniFi Cloud Gateway Fibre
- Add U7 Lite access point
- Design VLANs for trusted clients, servers, IoT and guests
- Create firewall rules between VLANs
- Document VPN access more clearly
- Add offsite backup for important data
- Add sanitized screenshots and example configurations

## Summary

The current security approach is based on practical homelab principles:

- Keep services private by default
- Use VPN for remote access
- Avoid unnecessary public exposure
- Use internal DNS and reverse proxying for cleaner access
- Back up important application and user data
- Prepare the network for VLANs and firewall rules

The next major step is the UniFi-based network upgrade, which should make the security model easier to enforce and document.
