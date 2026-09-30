# Lessons Learned

This document collects problems from my homelab that took me longer than expected to solve.

I write them down because the actual cause was often not where I first looked. Next time I want to check the right thing first instead of repeating the same detour.

Each entry follows the same structure: what I saw, what the real cause was, how I fixed it and what I take from it.

---

## Overview

| Topic | Area | Status |
|---|---|---|
| Unraid web UI stops responding | Unraid / network | Cause found, manual fix known |
| macvlan on a VLAN in Unraid | Docker / network | Solved |
| Container in a VLAN cannot reach anything | Switching | Solved |
| Answers do not come back through the firewall | UniFi firewall | Solved |
| Firewall rule stops working for one device | UniFi firewall | Understood |
| Offsite backup setup | Backup / VPN | Solved |

---

## Unraid web UI stops responding

**What I saw**

The Unraid web UI was not reachable anymore, but Docker containers and the array kept running normally. This happened more than once.

**First assumption**

My first theory was that the log partition in RAM was running full and taking the web server down with it. When the problem happened again, the log partition was almost empty. So that theory was wrong.

**Actual cause**

- the onboard Realtek network card lost its link for a few seconds
- Unraid reacts to that by restarting its web server
- the old web server processes were still holding the ports
- the new web server could not bind to its port ("Address already in use")
- after five attempts it gave up and kept running without listening on any port

**Fix**

Stop the old web server processes and start it again, no reboot needed:

```bash
killall nginx; sleep 3; /etc/rc.d/rc.nginx start
```

A normal restart of the service did not work, because Unraid did not recognize the old processes as running.

**What I take from it**

- SSH is now always enabled, so I can fix this without a monitor or a reboot
- check the actual state before trusting an old theory

---

## macvlan on a VLAN in Unraid

**What I saw**

I wanted to run the Matter Server as a container with its own address in the IoT network. Creating a macvlan network for that VLAN failed with "device or resource busy".

**Actual cause**

Unraid builds every VLAN as a bridge, and the actual VLAN interface is attached to that bridge as a port. Docker could not use that interface for macvlan, because Unraid was already using it.

**Fix**

I removed the VLAN from Unraid's own network settings. Docker now creates the VLAN interface itself when the macvlan network is used. This also survives a reboot.

**What I take from it**

On Unraid it matters who owns a network interface. If Unraid and Docker both try to manage the same VLAN, one of them loses.

---

## Container in a VLAN cannot reach anything

**What I saw**

The Matter Server container had its address in the IoT network, but it could not even reach the gateway.

**First assumption**

I suspected the interface settings on the server and tried promiscuous mode first. That did not help.

**Actual cause**

On the switch port of the server, the IoT VLAN was not tagged. The packet counters showed it: another VLAN on the same interface had over a million received packets, the IoT VLAN had zero.

**Fix**

Added the IoT VLAN to the tagged VLANs of the server port in UniFi.

**What I take from it**

When a whole VLAN is silent, check the switch port first. Interface counters are a quick way to see if traffic arrives at all.

---

## Answers do not come back through the firewall

**What I saw**

Home Assistant could send requests to the Matter Server in the IoT network, but the connection did not work. The allow rule for that direction was in place.

**Actual cause**

There is a block rule from IoT to the internal networks. UniFi creates return rules automatically, but in the rule list they are placed below my own block rules. The answers from the Matter Server were blocked.

**Fix**

An explicit allow rule for return traffic from the Matter Server to Home Assistant, placed above the block rule. An old allow rule that was never really needed was disabled at the same time.

**What I take from it**

If a connection works in one direction but answers never arrive, check the return path and the rule order first.

---

## Firewall rule stops working for one device

**What I saw**

One phone could reach some internal services, but not others. Another phone in the same network with the same rule worked fine.

**Actual cause**

Firewall rules, VLAN overrides and fixed IPs in UniFi are bound to a client entry, which means a MAC address. The phone uses randomized MAC addresses and had shown up as several different clients over time. The rule still pointed to an old client entry.

**What I take from it**

- device-based rules are only as stable as the MAC address behind them
- UniFi does not warn when a rule points to an old client entry
- when a rule works for one device but not for another, compare the client entries first

---

## Offsite backup setup

Setting up the offsite backup with restic over a WireGuard tunnel had several smaller traps. None of them was hard to fix, but each one cost time.

| Problem | Cause | What I take from it |
|---|---|---|
| Backup data ended up in RAM | The backup ran before the disk was mounted and wrote into the empty mount point | Always make sure the target disk is actually mounted before anything writes to it |
| SSH connection dropped after starting WireGuard | The tunnel was configured to route all traffic, including the SSH session | Only route the networks that really need to go through the tunnel |
| Name resolution failed on the offsite target | The configured DNS server was only reachable through the tunnel, which did not exist yet at that point | Do not depend on the tunnel for things the tunnel itself needs |
| Updating SSH known hosts failed on Unraid | The Unraid boot drive uses FAT32, which does not support hardlinks, and SSH uses a hardlink when it updates the known hosts file | Keep in mind that the Unraid flash drive is not a normal Linux file system |

More details: [Backup Strategy](backup-strategy.md)
