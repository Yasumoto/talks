---
title: Cloud Native Home Lab
date: 2022-07-31
author: Joe Smith
---

# Cloud Native Home Lab

## Joe Smith ( @Yasumoto )

### July 31st 2022

### Southern California Linux Expo 19x

#### https://neuralink.com/careers

---

# Agenda

1. 🥼 Intro to Home Lab Experimentation
2. 🥾 Booting your systems with MaaS
3. 🏗️  Creating your deployment platform
4. ⚔️  Running self-hosted services

These slides are created with markdown and:

* https://github.com/d0c-s4vage/lookatme
* https://dot-to-ascii.ggerganov.com/

---

# About Joe

* Graduated from Chapman in 2010 with CS
* Worked on the SCaLE Community Committee for a few years!
* Helped build Google, Twitter, Slack, now Neuralink!
* Used to be "that student" dual-booting university computer labs with Ubuntu

---

# What we're building today

```
┌──────────────────┐
│   Task Server    │
└──────────────────┘
  │
  ▼
┌──────────────────┐
│ Kubernetes (k3s) │
└──────────────────┘
  │
  ▼
┌──────────────────┐
│       MaaS       │
└──────────────────┘
  │
  ▼
┌──────────────────┐
│ Physical Machine │
└──────────────────┘
  │
  ▼
┌──────────────────┐
│     Home Lab     │
└──────────────────┘
```

---

# Rediscovering my roots

Over the years, I'd forgotten what was so great & exciting about tinkering and trying new projects!

Very challenging to find a balance between "discover a powerful new tool" and "too many distractions!"

I'd mostly forgotten how to interact with hardware 😅

---

# New Job, New Perspective

* 🧠 Neuralink is embarking on a bold journey!
* First mission: Building medical devices for patients with spinal cord injuries
* Transitioning:
  * From "is this possible?!"
  * To "let's make this reliable, repeatable, and scalable!"

---

# Bringing Order to Chaos

* Many critical architectural decisions ahead
* Incorrect choices can delay progress
* How do we maintain velocity and experimentation?

> "High rate corrects many ills"

---

# Why Build a Home Lab?

* Experiment with technology
* Very low cost for failure
* Trial new architecture & workflows
* Re-learn how to deal with on-prem infrastructure!

---

# Provisoning

Infrastructure as a Service (IaaS)

We need to understand how to work with:

* Hardware
* Booting
* Networking

---

# Physical Hardware

* Servers (aka a spare laptop or "NUC")
  * Spare Laptop
  * "Next Unit of Computing" or NUC
* Switches
* Crossover cables
* Virtual Machines

---

# Servers

Highly recommend **not** using your daily driver... just in case.

Intel launched their small form-factor NUC boxes in 2013!

Our pals at System76 have us covered:

◾ https://system76.com/desktops/meerkat

Alternatively, just use an old laptop!

- Built-in screen, keyboard, battery backup
- Light and easy to move

---

# Switches

* Unmanaged Switch - No configuration, plug n' play
* Managed Switch - Customizable!
  * Can find an 8-port managed switch from Fortinet (108-E), Cisco, etc on ebay
  * Look for what your organization uses to get extra experience

---

# Crossover Cable

* Straight-through cable:
  * Pins on one end correspond exactly to the corresponding pins on the other end
  * Only works when plugged into an appropriate device, like a switch

* Crossover cable
  * Pins do not correspond
  * Input from one side goes to output on the other

https://en.wikipedia.org/wiki/Crossover_cable

---

# Virtualization

* Not everyone is privileged enough to have spare hardware

* Fortunately, tons of documentation to do this using tools like Gnome Boxes or `multipass`:

* https://maas.io/tutorials/build-a-maas-and-lxd-environment-in-30-minutes-with-multipass-on-ubuntu

---

# Booting

* Basic Input/Output System (BIOS)
* Unified Extensible Firmware Interface (UEFI)

* Thanks Adam Williamson!
* https://www.happyassassin.net/posts/2014/01/25/uefi-boot-how-does-that-actually-work-then/

---

# BIOS

* **Basic Input/Output System**
* Originally created in *1975*.
* Platform-specific firmware brings up BIOS
* Disks are structued with a Master Boot Record
* Replaced by UEFI firmware

---

# Boot Process 1/4

```
┌────────────────────┐
│        BIOS        │ Machine Firmware hands over control
└────────────────────┘
```

---

# Boot Process 2/4

```
┌────────────────────┐
│        BIOS        │ Machine Firmware hands over control
└────────────────────┘
  │
  ▼
┌────────────────────┐
│ Master Boot Record │ Knows how file systems are partitioned
└────────────────────┘   on the disk
```
---

# Boot Process 3/4

```
┌────────────────────┐
│        BIOS        │ Machine Firmware hands over control
└────────────────────┘
  │
  ▼
┌────────────────────┐
│ Master Boot Record │ Knows how file systems are partitioned
└────────────────────┘   on the disk
  │
  ▼
┌────────────────────┐
│ Boot Loader (GRUB) │ Code that can boot the operating system
└────────────────────┘   (Linux, of course)
```

---

# Boot Process 4/4

```
┌────────────────────┐
│        BIOS        │ Machine Firmware hands over control
└────────────────────┘
  │
  ▼
┌────────────────────┐
│ Master Boot Record │ Knows how file systems are partitioned
└────────────────────┘   on the disk
  │
  ▼
┌────────────────────┐
│ Boot Loader (GRUB) │ Code that can boot the operating system
└────────────────────┘   (Linux, of course)
  │
  ▼
┌────────────────────┐
│       Kernel       │ The code which controls your hardware,
└────────────────────┘   and makes it easier for applications to use!
```
---

# BIOS Limitations

* Only supports 16-bit processors
* Can only access 1 MB of system memory
* Only able to point at a disk in your machine and kick off the MBR
* No standard/easy way to boot from things other than disks
  * Bad for us! No network boot standard

---

# Unified Extensible Firmware Interface (UEFI)

* Intel started work on their Extensible Firmware Interface in the 90s
* In 2005, they contributed that to the UEFI Forum
* Members include Intel, Microsoft, Apple, Red Hat, and many many more folks
* Opportunity to create a standard that will work across many devices and Operating Systems
* Way more flexibility to build out additional support!

---

# UEFI

* 32- or 64-bit Processors
* Can access all system memory directly
* Uses GUID Partition Table (GPT) for disk scheme
* MaaS will create an EFI partition ( `/boot/efi` )
* Typically as `sda1`, it will be 512 MB as `FAT32`

---

```
❯ efibootmgr -v
BootCurrent: 0000
Timeout: 0 seconds
BootOrder: 2001,0000,3000,2002,2004
Boot0000* EFI Hard Drive (ASB3N553811503E0M-SK hynix PC711 HFS001TDE9X073N)     PciRoot(0x0)/Pci(0x2,0x4)/Pci(0x0,0x0)/NVMe(0x1,AC-E4-2E-00-25-56-94-E5)/HD(1,GPT,5adc6c19-af14-49b2-8395-2717f8281e25,0x800,0x100000)RC
Boot2001* EFI USB Device        RC
Boot3000* Internal Hard Disk or Solid State Disk        RC
```


---

# Networking

* Subnets
* Unicast vs. Broadcast
* DHCP
* PXE
* TFTP

---

# Subnets

* Still the same as your cloud subnets
* WiFi might be 192.168.1.0/24 (256 hosts)
* Likely want a separate subnet (192.168.200.0/24) for isolation
  * Especially during experimentation


---

# Unicast vs. Broadcast Messages

* Unicast:
  * When you know the receiver
  * Send a packet from my address (192.168.1.7) to Google (142.251.111.138)

* Broadcast:
  * Talk to _everyone_ who will listen - on your subnet
  * 192.168.1.255 is our network's broadcast address
  * 255.255.255.255 is the "everyone" address

---

# Unicast vs. Broadcast Messages

* Unicast:
  * When you know the receiver
  * Send a packet from my address (192.168.1.7) to Google (142.251.111.138)

---

# Dynamic Host Configuration Protocol (DHCP)

* Defined in October 1993
* What about when you first join a network?
* What the heck is the subnet I'm in?
* How do I configure myself?

---

# DORA

* Discover
  * Client broadcasts on 255.255.255.255

---

# DORA

* Discover
  * Client broadcasts on 255.255.255.255

* Offer
  * If there is a DHCP server (typically your WiFi router)
  * Reserve an IP address, respond back to that device

---

# DORA

* Discover
  * Client broadcasts on 255.255.255.255

* Offer
  * If there is a DHCP server (typically your WiFi router)
  * Reserve an IP address, respond back to that device

* Request
  * Client will officially request that IP

---

# DORA

* Discover
  * Client broadcasts on 255.255.255.255

* Offer
  * If there is a DHCP server (typically your WiFi router)
  * Reserve an IP address, respond back to that device

* Request
  * Client will officially request that IP

* Acknowledge
  * Server gives thumbs up; that's your address!

---

# PXE

---

# Trivial File Transfer Protocol (TFTP)

* First defined in 1980
* https://datatracker.ietf.org/doc/html/rfc906

---

# MaaS

> Very fast server provisioning for your ~~data centre~~ home lab

* For machines that can netboot, no need for carrying around a USB thumbdrive
* A few ways to tie together a machine in MaaS, easiest to network boot while on the MaaS network

---

# MaaS Components

* `regiond`: Region Controller
  * One per "area" aka our house or apartment
* PostgreSQL Database
  * Stores state for Region Controller
* `rackd`: Rack Controller
  * One per network subnet
  * Also probably just one
  * Stateless!

---

# Typical MaaS Flow 1/5


```
┌──────────────────────────────────────────┐
│               Add machine                │
└──────────────────────────────────────────┘
  │
  │ Built-in Commissioning Scripts
  ▼
┌──────────────────────────────────────────┐
│                Enlistment                │
└──────────────────────────────────────────┘
```

---

# Typical MaaS Flow 2/5


```
┌──────────────────────────────────────────┐
│               Add machine                │
└──────────────────────────────────────────┘
  │ Built-in Commissioning Scripts
  ▼
┌──────────────────────────────────────────┐
│                Enlistment                │
└──────────────────────────────────────────┘
  │
  ▼
┌──────────────────────────────────────────┐
│                   New                    │
└──────────────────────────────────────────┘
```

---

# Typical MaaS Flow 3/5


```
┌──────────────────────────────────────────┐
│               Add machine                │
└──────────────────────────────────────────┘
  │
  │ Built-in Commissioning Scripts
  ▼
┌──────────────────────────────────────────┐
│                Enlistment                │
└──────────────────────────────────────────┘
  │
  ▼
┌──────────────────────────────────────────┐
│                   New                    │
└──────────────────────────────────────────┘
  │ Built-in & Custom Commissioning Scripts
  ▼
┌──────────────────────────────────────────┐
│                Commission                │
└──────────────────────────────────────────┘
```

---

# Typical MaaS Flow 4/5


```
┌──────────────────────────────────────────┐
│               Add machine                │
└──────────────────────────────────────────┘
  │
  │ Built-in Commissioning Scripts
  ▼
┌──────────────────────────────────────────┐
│                Enlistment                │
└──────────────────────────────────────────┘
  │
  ▼
┌──────────────────────────────────────────┐
│                   New                    │
└──────────────────────────────────────────┘
  │ Built-in & Custom Commissioning Scripts
  ▼
┌──────────────────────────────────────────┐
│                Commission                │
└──────────────────────────────────────────┘
  │ SSH Keys, NTP, gather information
  ▼
┌──────────────────────────────────────────┐
│                  Ready                   │
└──────────────────────────────────────────┘
```

---

# MaaS Commissioning

* After Commissioning, MaaS needs to make sure the machine is in status `Allocated`

* This reserves the machine, and means it can be Deployed

---

# Typical MaaS Flow 5/5


```
┌──────────────────────────────────────────┐
│               Add machine                │
└──────────────────────────────────────────┘
  │ Built-in Commissioning Scripts
  ▼
┌──────────────────────────────────────────┐
│                Enlistment                │
└──────────────────────────────────────────┘
  │
  ▼
┌──────────────────────────────────────────┐
│                   New                    │
└──────────────────────────────────────────┘
  │ Built-in & Custom Commissioning Scripts
  ▼
┌──────────────────────────────────────────┐
│                Commission                │
└──────────────────────────────────────────┘
  │ SSH Keys, NTP, gather information
  ▼
┌──────────────────────────────────────────┐
│                  Ready                   │
└──────────────────────────────────────────┘
  │
  ▼
┌──────────────────────────────────────────┐
│                  Deploy                  │
└──────────────────────────────────────────┘
```

---

# Custom Configuration Templates

* Located on `regiond` server
* At `/var/snap/maas/current/preseeds/`

|     Phase     |  Filename Prefix  |
|---------------|-------------------|
|   Enlistment  |    `enlist`       |
| Commissioning |  `commissioning`  |
| Installation  |     `curtin`      |

https://maas.io/docs/about-customising-machines#heading--templates


---

# Commissioning 1/7


```
.
        ┌───────────────────────────────────────────────────────────────┐
        │                                                               │
        │             target machine                                    │
        │                                                               │
        └───────────────────────────────────────────────────────────────┘
          │
          │
          │ 1. dhcp
          ▼
        ┌───────────────────────────────────────────────────────────────┐
        │                  rackd                                        │
        └───────────────────────────────────────────────────────────────┘
```

---

# Commissioning 2/7

```
.
        ┌───────────────────────────────────────────────────────────────┐
        │                                                               │
        │             target machine                                    │
        │                                                               │
        └───────────────────────────────────────────────────────────────┘
          │
          │
          │ 1. dhcp
          ▼
        ┌───────────────────────────────────────────────────────────────┐
        │                  rackd                                        │
        └───────────────────────────────────────────────────────────────┘
          │
          │ 2. fetch boot metadata (TFTP)
          │ Kernel, boot args, initrd/squashfs
          ▼
        ┌─────────────────────────────────────┐
        │               regiond               │
        └─────────────────────────────────────┘
```

---

# Commissioning 3/7


```
.
        ┌───────────────────────────────────────────────────────────────┐
        │                                                               │
        │             target machine                                    │
        │                                                               │ ◀┐
        └───────────────────────────────────────────────────────────────┘  │
          │                                                                │
          │                                                                │
          │ 1. dhcp                                                        │ 3. PXE Config
          ▼                                                                │
        ┌───────────────────────────────────────────────────────────────┐  │
        │                  rackd                                        │ ─┘
        └───────────────────────────────────────────────────────────────┘
          │
          │ 2. fetch boot metadata (TFTP)
          │ Kernel, boot args, initrd/squashfs
          ▼
        ┌─────────────────────────────────────┐
        │               regiond               │
        └─────────────────────────────────────┘
```

---

# Commissioning 4/7


```
 4. Boot Ubuntu from PXE
        ┌───────────────────────────────────────────────────────────────┐
┌────── │                                                               │
│       │             target machine                                    │
└─────▶ │                                                               │ ◀┐
        └───────────────────────────────────────────────────────────────┘  │
          │                                                                │
          │                                                                │
          │ 1. dhcp                                                        │ 3. PXE Config
          ▼                                                                │
        ┌───────────────────────────────────────────────────────────────┐  │
        │                  rackd                                        │ ─┘
        └───────────────────────────────────────────────────────────────┘
          │
          │ 2. fetch boot metadata (TFTP)
          │ Kernel, boot args, initrd/squashfs
          ▼
        ┌─────────────────────────────────────┐
        │               regiond               │
        └─────────────────────────────────────┘
```

---

# Commissioning 5/7

```
 4. Boot Ubuntu from PXE
        ┌───────────────────────────────────────────────────────────────┐
┌────── │                                                               │
│       │             target machine                                    │
└─────▶ │                                                               │ ◀┐
        └───────────────────────────────────────────────────────────────┘  │
          │                │                                               │
          │                │ 5. Fetch cloud-init                           │
          │ 1. dhcp        │ from regiond                                  │ 3. PXE Config
          ▼                ▼                                               │
        ┌───────────────────────────────────────────────────────────────┐  │
        │                  rackd                                        │ ─┘
        └───────────────────────────────────────────────────────────────┘
          │
          │ 2. fetch boot metadata (TFTP)
          │ Kernel, boot args, initrd/squashfs
          ▼
        ┌─────────────────────────────────────┐
        │               regiond               │
        └─────────────────────────────────────┘
```
---

# Commissioning 6/7

```
 4. Boot Ubuntu from PXE
        ┌───────────────────────────────────────────────────────────────┐
┌────── │                                                               │
│       │             target machine                                    │
└─────▶ │                                                               │ ◀┐
        └───────────────────────────────────────────────────────────────┘  │
          │                │                       │                       │
          │                │ 5. Fetch cloud-init   │ 6. Publish metadata   │
          │ 1. dhcp        │ from regiond          │ up to regiond         │ 3. PXE Config
          ▼                ▼                       ▼                       │
        ┌───────────────────────────────────────────────────────────────┐  │
        │                  rackd                                        │ ─┘
        └───────────────────────────────────────────────────────────────┘
          │
          │ 2. fetch boot metadata (TFTP)
          │ Kernel, boot args, initrd/squashfs
          ▼
        ┌─────────────────────────────────────┐
        │               regiond               │
        └─────────────────────────────────────┘
```

---

# Commissioning 7/7


```
 4. Boot Ubuntu from PXE
        ┌───────────────────────────────────────────────────────────────┐
┌────── │                                                               │
│       │             target machine                                    │
└─────▶ │                                                               │ ◀┐
        └───────────────────────────────────────────────────────────────┘  │
          │                │                       │                       │
          │                │ 5. Fetch cloud-init   │ 6. Publish metadata   │
          │ 1. dhcp        │ from regiond          │ up to regiond         │ 3. PXE Config
          ▼                ▼                       ▼                       │
        ┌───────────────────────────────────────────────────────────────┐  │
        │                  rackd                                        │ ─┘
        └───────────────────────────────────────────────────────────────┘
          │
          │ 2. fetch boot metadata (TFTP)
          │ Kernel, boot args, initrd/squashfs
          ▼
        ┌─────────────────────────────────────┐
        │               regiond               │
        └─────────────────────────────────────┘
          │
          │ 7. Persist machine details
          ▼
        ┌─────────────────────────────────────┐
        │             postgresql              │
        └─────────────────────────────────────┘
```

---

# Deployment

* Follows similar process, but is _not_ an ephemeral environment anymore.
* Uses the `curtin` installer, then `cloud-init` to configure on first boot

---

# curtin

* `curtin` is a tool for installing an operating system as quickly as possible
* Similar to `Kickstart` or `debian-installer`
* Customization here helps ensure the same setup across many installs/machines
* https://git.launchpad.net/curtin/tree/

---

# curtin 1/7

* Install Environment boot
  * Kicked off via LiveCD or PXE

---

# curtin 2/7


* Install Environment boot
* Early Commands
  * Load modules
  * Hardware & Environment setup
  * `apt` update, for example

---

# curtin 3/7

* Install Environment boot
* Early Commands
* Partitioning
  * Wipe disks
  * Setup RAID if needed
  * Write out fstab "template"

---

# curtin 4/7

* Install Environment boot
* Early Commands
* Partitioning
* Network Discovery and Setup
  * Write out template

---

# curtin 5/7

* Install Environment boot
* Early Commands
* Partitioning
* Network Discovery and Setup
* Extraction of sources
  * Preferably a root filesystem image

---

# curtin 6/7

* Install Environment boot
* Early Commands
* Partitioning
* Network Discovery and Setup
* Extraction of sources
* Hook for installed OS to customize itself
  * Uses preseed files from MaaS for additional setup

---

# curtin 7/7

* Install Environment boot
* Early Commands
* Partitioning
* Network Discovery and Setup
* Extraction of sources
* Hook for installed OS to customize itself
* Final Commands
  * Send an HTTP request saying installation is complete!
  * curtin supports a `Reporting Framework`
  * Can post to somewhere like Slack

---

# Cloud-init

* Setup the machine immediately on first boot
* Runs when MaaS sets a machine to `Deployed`
* Custom configuration is per-deployment
* Unique tweaks just for this instance

---

# Configuring our OS & Platform

* How do we configure a basic Ubuntu install?
  * `Cloud-init`!
* Even with all this, re-provisioning a whole server is too slow for a deployment

> All Problems in Computer Science Can Be Solved by Another Layer of Indirection
  - David Wheeler

* Time for Joe to actually learn Kube (sorry Tricia & Jordan)
  * k3s!

---

# Keeping tabs on our lab

* I'm too spoiled by pretty graphs
  * Node Exporter
  * Prometheus
  * Grafana

---

# Hey, this is quite robust

* What can I run that will matter?
* Omnifocus is still great, but proprietary!
  * 🤯 https://taskwarrior.org/
* CLI-based TODO app
* Task Server for syncing

---

# Task Server

* Upstream supports directly-installing on hosts
* This is where we get flexibility
  * Normally prefer to leverage upstream
* Thank you https://github.com/yhaenggi!

---

# Taskserver Docker

* https://github.com/Yasumoto/taskserver-docker

---

# Taskserver Kubernetes

* https://github.com/Yasumoto/taskserver-kubernetes

---

# What we've built today

```
┌──────────────────┐
│   Task Server    │
└──────────────────┘
  │
  ▼
┌──────────────────┐
│ Kubernetes (k3s) │
└──────────────────┘
  │
  ▼
┌──────────────────┐
│       MaaS       │
└──────────────────┘
  │
  ▼
┌──────────────────┐
│ Physical Machine │
└──────────────────┘
  │
  ▼
┌──────────────────┐
│     Home Lab     │
└──────────────────┘
```

---

# More resources

* https://selfhosted.show
* https://100daysofhomelab.com/
